//
//  EmailTheSeller.m
//  UCE
//
//  Created by Mac on 16/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailTheSeller.h"
#import "CarRecord.h"
#import "AFNetworking.h"
#import "UIButton+Glossy.h"

#import "CommonMethods.h"
#import "TPKeyboardAvoidingScrollView.h"


//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


@interface EmailTheSeller()

@property(strong,nonatomic) NSOperationQueue *emailOpQueue;
@property(strong,nonatomic) UIAlertView *emailSentAlert;
@property(strong,nonatomic) UITextField *fNameTextField,*lNameTextField,*phoneTextField,*cityTextField,*emailTextField;
@property(strong,nonatomic) UITextView *msgTextField;

- (void)mailServiceCallSuccessMethod;
- (void)mailServiceCallFailedMethod:(NSError *)error;

@end

@implementation EmailTheSeller




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



-(void)backBarButtonTapped
{
   
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.text=@"Enter Your Details"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor = [UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    //back button
    UIImage* image3 = [UIImage imageNamed:@"BackAll.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width/2-20, image3.size.height/2-20);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(backBarButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    
    UIBarButtonItem *lb= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem =lb;
    lb=nil;

    
    [self addcontroles];
    //[self addconstraints];
    
}

-(void)addcontroles
{
    TPKeyboardAvoidingScrollView *detailScrollView=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
        [self.view addSubview:detailScrollView];
    
    
    detailScrollView.showsVerticalScrollIndicator=YES;
   detailScrollView.scrollEnabled=YES;
    detailScrollView.userInteractionEnabled=YES;
    
     //autolayout
    [detailScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *scrollView1Constraint=[NSLayoutConstraint constraintWithItem:detailScrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:detailScrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraint:scrollView1Constraint];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:detailScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self.view addConstraint:scrollView1Constraint];
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:detailScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.view addConstraint:scrollView1Constraint];
        
    } else {
        
        //load resources for iOS 7
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:detailScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationController.navigationBar.frame.size.height];
        [self.view addConstraint:scrollView1Constraint];
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:detailScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-self.tabBarController.tabBar.frame.size.height];
        [self.view addConstraint:scrollView1Constraint];    }
    
    //create cameraviewcontroller object and set its delegate to self, so that we can reload car record for gallery
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        
    {
    
    UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 24, 100, 21)];
    nameLabel.backgroundColor=[UIColor clearColor];
    nameLabel.text=@"First Name:";
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.tag = 1;
    [detailScrollView addSubview:nameLabel];
    
    self.fNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 50, 280, 31)];
    self.fNameTextField.backgroundColor=[UIColor clearColor];
    self.fNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.fNameTextField.font = [UIFont systemFontOfSize:13];
    self.fNameTextField.placeholder = @"First Name";
    self.fNameTextField.textAlignment=NSTextAlignmentLeft;
    self.fNameTextField.textColor=[UIColor blackColor];
    self.fNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.fNameTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.fNameTextField.returnKeyType = UIReturnKeyDone;
    self.fNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.fNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.fNameTextField.tag=2;
    self.fNameTextField.delegate = self;
    self.fNameTextField.userInteractionEnabled = YES;
    [detailScrollView addSubview:self.fNameTextField];
    
    UILabel *lastNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 90, 100, 21)];
    lastNameLabel.backgroundColor=[UIColor clearColor];
    lastNameLabel.text=@"Last Name:";
    lastNameLabel.textColor = [UIColor blackColor];
    lastNameLabel.tag = 3;
    [detailScrollView addSubview:lastNameLabel];
    
    self.lNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 120, 280, 31)];
    self.lNameTextField.backgroundColor=[UIColor clearColor];
    self.lNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.lNameTextField.font = [UIFont systemFontOfSize:13];
    self.lNameTextField.placeholder = @"Last Name";
    self.lNameTextField.textAlignment=NSTextAlignmentLeft;
    self.lNameTextField.textColor=[UIColor blackColor];
    self.lNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.lNameTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.lNameTextField.returnKeyType = UIReturnKeyDone;
    self.lNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.lNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.lNameTextField.tag=4;
    self.lNameTextField.delegate = self;
    [detailScrollView addSubview:self.lNameTextField];

    
    UILabel *phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 160, 140, 21)];
    phoneLabel.backgroundColor=[UIColor clearColor];
    phoneLabel.text=@"Phone Number:*";
    phoneLabel.textColor = [UIColor blackColor];
    phoneLabel.tag = 5;
    [detailScrollView addSubview:phoneLabel];
    
    self.phoneTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 190, 280, 31)];
    self.phoneTextField.backgroundColor=[UIColor clearColor];
    self.phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneTextField.font = [UIFont systemFontOfSize:13];
    self.phoneTextField.placeholder = @"Enter your Phone Number *";
    self.phoneTextField.textAlignment=NSTextAlignmentLeft;
    self.phoneTextField.textColor=[UIColor blackColor];
    self.phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneTextField.returnKeyType = UIReturnKeyDone;
    self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneTextField.tag=6;
    self.phoneTextField.delegate = self;
    [detailScrollView addSubview:self.phoneTextField];

     UILabel *cityLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 230, 140, 21)];
     cityLabel.backgroundColor=[UIColor clearColor];
     cityLabel.text=@"City:";
     cityLabel.textColor = [UIColor blackColor];
     cityLabel.tag = 7;
     [detailScrollView addSubview:cityLabel];
    
        self.cityTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 260, 280, 31)];
        self.cityTextField.backgroundColor=[UIColor clearColor];
        self.cityTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.cityTextField.font = [UIFont systemFontOfSize:13];
        self.cityTextField.placeholder = @"Enter your City";
        self.cityTextField.textAlignment=NSTextAlignmentLeft;
        self.cityTextField.textColor=[UIColor blackColor];
        self.cityTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.cityTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.cityTextField.returnKeyType = UIReturnKeyDone;
        self.cityTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.cityTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.cityTextField.tag=8;
        self.cityTextField.delegate = self;
        [detailScrollView addSubview:self.cityTextField];
    
    
    
        UILabel *emailLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 300, 140, 21)];
        emailLabel.backgroundColor=[UIColor clearColor];
        emailLabel.text=@"Email Id:";
        emailLabel.textColor = [UIColor blackColor];
        emailLabel.tag = 9;
        [detailScrollView addSubview:emailLabel];
    
        self.emailTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 330, 280, 31)];
        self.emailTextField.backgroundColor=[UIColor clearColor];
        self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailTextField.font = [UIFont systemFontOfSize:13];
        self.emailTextField.placeholder = @"Enter your Email Id";
        self.emailTextField.textAlignment=NSTextAlignmentLeft;
        self.emailTextField.textColor=[UIColor blackColor];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.emailTextField.returnKeyType = UIReturnKeyDone;
        self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailTextField.tag=10;
        //  fNameTextField.delegate = self;
        [detailScrollView addSubview:self.emailTextField];
    
    
    
    
        UILabel *msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 380, 140, 21)];
        msgLabel.backgroundColor=[UIColor clearColor];
        msgLabel.text=@"Message:";
        msgLabel.textColor = [UIColor blackColor];
        msgLabel.tag = 11;
        [detailScrollView addSubview:msgLabel];
    
    
        self.msgTextField=[[UITextView alloc] initWithFrame:CGRectMake(20, 410, 280, 100)];
        self.msgTextField.backgroundColor=[UIColor clearColor];
        //self.msgTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.msgTextField.font = [UIFont systemFontOfSize:13];
        //self.msgTextField.text = @"Message";
        self.msgTextField.textAlignment=NSTextAlignmentLeft;
        self.msgTextField.textColor=[UIColor blackColor];
        self.msgTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.msgTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.msgTextField.returnKeyType = UIReturnKeyDefault;
        //self.msgTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.msgTextField.tag=12;
    //for border
    self.msgTextField.layer.cornerRadius = 5.0;
    self.msgTextField.clipsToBounds = YES;
    [self.msgTextField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.msgTextField.layer setBorderWidth:2.0];
    //  fNameTextField.delegate = self;
        [detailScrollView addSubview:self.msgTextField];
    
    
    
        self.sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame=CGRectMake(166, 530, 90, 31);
        //[self.sendButton setBackgroundImage:[UIImage imageNamed:@"SendBtn"] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.sendButton.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];

        [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        self.sendButton.layer.shadowRadius = 1.0f;
        self.sendButton.layer.shadowOpacity = 0.5f;
        self.sendButton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //[self.sendButton setShowsTouchWhenHighlighted:YES];
        
        
        
        
        
        self.sendButton.tag = 13;
        [detailScrollView addSubview:self.sendButton];
    
        self.cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame=CGRectMake(60, 530, 90, 31);
        //[self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.cancelButton.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        [self.cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        self.cancelButton.layer.shadowRadius = 1.0f;
        self.cancelButton.layer.shadowOpacity = 0.5f;
        self.cancelButton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //[self.sendButton setShowsTouchWhenHighlighted:YES];
        
        
        
        self.cancelButton.tag = 14;
        [detailScrollView addSubview:self.cancelButton];
    
    [detailScrollView setContentSize:CGSizeMake(self.view.frame.size.width,600)];

        }

    else{
        
        
        UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 50, 100, 21)];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.text=@"First Name:";
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.tag = 1;
        [detailScrollView addSubview:nameLabel];
        
        self.fNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 50, 280, 31)];
        self.fNameTextField.backgroundColor=[UIColor whiteColor];
        self.fNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.fNameTextField.font = [UIFont systemFontOfSize:13];
        self.fNameTextField.placeholder = @"First Name";
        self.fNameTextField.textAlignment=NSTextAlignmentLeft;
        self.fNameTextField.textColor=[UIColor blackColor];
        self.fNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.fNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.fNameTextField.returnKeyType = UIReturnKeyDone;
        self.fNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.fNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.fNameTextField.tag=2;
        self.fNameTextField.delegate = self;
        self.fNameTextField.userInteractionEnabled = YES;
        [detailScrollView addSubview:self.fNameTextField];
        
        UILabel *lastNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 120, 100, 21)];
        lastNameLabel.backgroundColor=[UIColor clearColor];
        lastNameLabel.text=@"Last Name:";
        lastNameLabel.textColor = [UIColor blackColor];
        lastNameLabel.tag = 3;
        [detailScrollView addSubview:lastNameLabel];
        
        self.lNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 120, 280, 31)];
        self.lNameTextField.backgroundColor=[UIColor whiteColor];
        self.lNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.lNameTextField.font = [UIFont systemFontOfSize:13];
        self.lNameTextField.placeholder = @"Last Name";
        self.lNameTextField.textAlignment=NSTextAlignmentLeft;
        self.lNameTextField.textColor=[UIColor blackColor];
        self.lNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.lNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.lNameTextField.returnKeyType = UIReturnKeyDone;
        self.lNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.lNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.lNameTextField.tag=4;
        self.lNameTextField.delegate = self;
        [detailScrollView addSubview:self.lNameTextField];
        
        
        UILabel *phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 190, 140, 21)];
        phoneLabel.backgroundColor=[UIColor clearColor];
        phoneLabel.text=@"Phone Number:*";
        phoneLabel.textColor = [UIColor blackColor];
        phoneLabel.tag = 5;
        [detailScrollView addSubview:phoneLabel];
        
        self.phoneTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 190, 280, 31)];
        self.phoneTextField.backgroundColor=[UIColor whiteColor];
        self.phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.phoneTextField.font = [UIFont systemFontOfSize:13];
        self.phoneTextField.placeholder = @"Enter your Phone Number *";
        self.phoneTextField.textAlignment=NSTextAlignmentLeft;
        self.phoneTextField.textColor=[UIColor blackColor];
        self.phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        self.phoneTextField.returnKeyType = UIReturnKeyDone;
        self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.phoneTextField.tag=6;
        self.phoneTextField.delegate = self;
        [detailScrollView addSubview:self.phoneTextField];
        
        UILabel *cityLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 260, 140, 21)];
        cityLabel.backgroundColor=[UIColor clearColor];
        cityLabel.text=@"City:";
        cityLabel.textColor = [UIColor blackColor];
        cityLabel.tag = 7;
        [detailScrollView addSubview:cityLabel];
        
        self.cityTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 260, 280, 31)];
        self.cityTextField.backgroundColor=[UIColor whiteColor];
        self.cityTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.cityTextField.font = [UIFont systemFontOfSize:13];
        self.cityTextField.placeholder = @"Enter your City";
        self.cityTextField.textAlignment=NSTextAlignmentLeft;
        self.cityTextField.textColor=[UIColor blackColor];
        self.cityTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.cityTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.cityTextField.returnKeyType = UIReturnKeyDone;
        self.cityTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.cityTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.cityTextField.tag=8;
        self.cityTextField.delegate = self;
        [detailScrollView addSubview:self.cityTextField];
        
        
        
        UILabel *emailLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 330, 140, 21)];
        emailLabel.backgroundColor=[UIColor clearColor];
        emailLabel.text=@"Email Id:";
        emailLabel.textColor = [UIColor blackColor];
        emailLabel.tag = 9;
        [detailScrollView addSubview:emailLabel];
        
        self.emailTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 330, 280, 31)];
        self.emailTextField.backgroundColor=[UIColor whiteColor];
        self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailTextField.font = [UIFont systemFontOfSize:13];
        self.emailTextField.placeholder = @"Enter your Email Id";
        self.emailTextField.textAlignment=NSTextAlignmentLeft;
        self.emailTextField.textColor=[UIColor blackColor];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.emailTextField.returnKeyType = UIReturnKeyDone;
        self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailTextField.tag=10;
        //  fNameTextField.delegate = self;
        [detailScrollView addSubview:self.emailTextField];
        
        
        
        
        UILabel *msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 410, 140, 21)];
        msgLabel.backgroundColor=[UIColor clearColor];
        msgLabel.text=@"Message:";
        msgLabel.textColor = [UIColor blackColor];
        msgLabel.tag = 11;
        [detailScrollView addSubview:msgLabel];
        
        
        self.msgTextField=[[UITextView alloc] initWithFrame:CGRectMake(150, 410, 280, 100)];
        self.msgTextField.backgroundColor=[UIColor whiteColor];
        //self.msgTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.msgTextField.font = [UIFont systemFontOfSize:13];
        //self.msgTextField.text = @"Message";
        self.msgTextField.textAlignment=NSTextAlignmentLeft;
        self.msgTextField.textColor=[UIColor blackColor];
        self.msgTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.msgTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.msgTextField.returnKeyType = UIReturnKeyDefault;
        //self.msgTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.msgTextField.tag=12;
        //for border
        self.msgTextField.layer.cornerRadius = 5.0;
        self.msgTextField.clipsToBounds = YES;
        [self.msgTextField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
        [self.msgTextField.layer setBorderWidth:2.0];
        //  fNameTextField.delegate = self;
        [detailScrollView addSubview:self.msgTextField];
        
        
        
        self.sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton.frame=CGRectMake(300, 550, 90, 31);
        //[self.sendButton setBackgroundImage:[UIImage imageNamed:@"SendBtn"] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.sendButton.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];

        [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
        [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        self.sendButton.layer.shadowRadius = 1.0f;
        self.sendButton.layer.shadowOpacity = 0.5f;
        self.sendButton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //[self.sendButton setShowsTouchWhenHighlighted:YES];

        self.sendButton.tag = 13;
        [detailScrollView addSubview:self.sendButton];
        
        self.cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame=CGRectMake(170, 550, 90, 31);
        //[self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.cancelButton.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
        [self.cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        self.cancelButton.layer.shadowRadius = 1.0f;
        self.cancelButton.layer.shadowOpacity = 0.5f;
        self.cancelButton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //[self.sendButton setShowsTouchWhenHighlighted:YES];
        
        
        self.cancelButton.tag = 14;
        [detailScrollView addSubview:self.cancelButton];
        
        [detailScrollView setContentSize:CGSizeMake(self.view.frame.size.width,600)];
    }
    
    
    
}
#pragma mark - TextView Delegates
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    
    self.msgTextField.textColor = [UIColor blackColor];
    return YES;
}


-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.msgTextField.text.length == 0){

        [self.msgTextField resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.msgTextField resignFirstResponder];
}

-(void)cancelButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)removeContinousDotsAndSpaces:(NSString *)str
{
    
    NSString *trimmedString = str;
    while ([trimmedString rangeOfString:@".."].location != NSNotFound) {
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@".." withString:@"."];
    }
    
    while ([trimmedString rangeOfString:@"  "].location != NSNotFound) {
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
 
    
    return trimmedString;
}



-(void)callEmailServiceWith:(NSString *)buyerEmailAddress buyerPhoneNumber:(NSString *)buyerPhoneNumber city:(NSString *)city fName:(NSString *)fName lName:(NSString *)lName comments:(NSString *)msg
{
    
    NSString *buyerEmail; //=IsEmpty(buyerEmailAddress)?@"info@unitedcarexchange.com":buyerEmailAddress;
    if (IsEmpty([buyerEmailAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerEmail=@"info@mobicarz.com";
    }
    else
    {
        buyerEmail=[self removeContinousDotsAndSpaces:buyerEmailAddress];
        buyerEmail=[buyerEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *buyerCity;
    if (IsEmpty([city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerCity=@" ";
    }
    else
    {
        buyerCity=[self removeContinousDotsAndSpaces:city];
        buyerCity=[buyerCity stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *buyerPhone=buyerPhoneNumber;
    
    NSString *buyerFirstName;
    if (IsEmpty([fName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerFirstName=@" ";
    }
    else
    {
        buyerFirstName=[fName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *buyerLastName;
    if (IsEmpty([lName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerLastName=@" ";
    }
    else
    {
        buyerLastName=[lName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *buyerComments;
    if (IsEmpty([msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerComments=@" ";
        
    }
    else
    {
        buyerComments=[self removeContinousDotsAndSpaces:msg];
        // buyerComments=[buyerComments stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//Commented Dec-3/12
    }
    
    
    NSString *ipAddress=@" ";
    
    //
    
    NSString *sellerphone;
    if (IsEmpty([[self.carRecordFromDetailView phone] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[[self.carRecordFromDetailView phone] isEqualToString:@"Emp"]) {
        sellerphone=@" ";
    }
    else
    {
        sellerphone=[self.carRecordFromDetailView phone];
    }
    
    
    NSString *sellerprice;
    NSString *sellerPriceStr=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    
    if (IsEmpty([sellerPriceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[sellerPriceStr isEqualToString:@"Emp"]) {
        sellerprice=@" ";
    }
    else
    {
        sellerprice=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    }
    
    
    NSString *carid=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView carid]];
    
    
    NSString *sYear;
    NSString *sYearStr=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView year]];
    if (IsEmpty([sYearStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[sYearStr isEqualToString:@"Emp"]) {
        sYear=@" ";
    }
    else
    {
        sYear=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView year]];
    }
    
    
    NSString *make=[[self.carRecordFromDetailView make] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *model=[[self.carRecordFromDetailView model] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *price;
    NSString *priceStr=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    if (IsEmpty([priceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[priceStr isEqualToString:@"Emp"]) {
        price=@" ";
    }
    else
    {
        price=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    }
    
       //
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSArray *keys=[NSArray arrayWithObjects:@"BuyerEmail",@"BuyerCity",@"BuyerPhone",@"BuyerFirstName",@"BuyerLastName",@"BuyerComments",@"IpAddress",@"Sellerphone",@"Sellerprice",@"Carid",@"sYear",@"Make",@"Model",@"price",@"ToEmail",@"AuthenticationID",@"CustomerID", nil];
    
    
    
    NSArray *values=[NSArray arrayWithObjects:buyerEmail,buyerCity,buyerPhone,buyerFirstName,buyerLastName,buyerComments,ipAddress,sellerphone,sellerprice,carid,sYear,make,model,price,[self.carRecordFromDetailView sellerEmail], @"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",retrieveduuid,nil];
    
  
    
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    __weak EmailTheSeller *weakSelf=self;
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"MobileService/CarService.asmx/SaveBuyerRequestMobile" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf hideActivityViewer];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
      //  NSLog(@"response string: %@ class of response string=%@", operation.responseString,NSStringFromClass([operation.responseString class]));
        
        
        
        self.sendButton.enabled=YES;
        
        [weakSelf mailServiceCallSuccessMethod];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        
        NSLog(@"error: %@", operation.responseString);
        NSLog(@"%d",operation.response.statusCode);
        self.sendButton.enabled=YES;
        
        //call service failed
        [self mailServiceCallFailedMethod:error];
        
    }];
    
    self.emailOpQueue=[[NSOperationQueue alloc]init];
    [self.emailOpQueue setName:@"EmailTheSeller Operation Queue"];
    [self.emailOpQueue setMaxConcurrentOperationCount:1];

}



#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==6) { //phone number
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 10) ? NO : YES;
    }
       return YES;
}


-(void)sendButtonTapped
{
    
    
    NSString *fName= self.fNameTextField.text;
    NSString *lName= self.lNameTextField.text;
    NSString *buyerPhoneNumber= self.phoneTextField.text;
    NSString *buyerEmailAddress= self.emailTextField.text;
    NSString *msg= self.msgTextField.text;
    NSString *city=self.cityTextField.text;
    
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc]init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    NSNumber *phoneNum=[numberFormatter numberFromString:buyerPhoneNumber];
    
    
    
    if (IsEmpty(phoneNum)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Enter phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.phoneTextField becomeFirstResponder];
        return;
        
    }
    else if ([self.phoneTextField.text length]>0 && [self.phoneTextField.text length]<10) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.phoneTextField becomeFirstResponder];
        return;
    }
    if (IsEmpty(buyerEmailAddress)) {
        buyerEmailAddress = @"";
    }
    else if(!IsEmpty(buyerEmailAddress))
    {
        buyerEmailAddress=[buyerEmailAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
             if (![CommonMethods validateEmail:buyerEmailAddress]) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Email" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                return;
            }
            else
            {
            }
        

//        
   }
//    numberFormatter=nil;
    
    [self callEmailServiceWith:buyerEmailAddress buyerPhoneNumber:buyerPhoneNumber city:city fName:fName lName:lName comments:msg];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
    return YES;
}

#pragma mark - Delegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![alertView isEqual:self.emailSentAlert])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)mailServiceCallSuccessMethod
{
    
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Your email has been sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
  
    
   
    
}

- (void)mailServiceCallFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    if([error code]==kCFURLErrorNotConnectedToInternet)
    {
        self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"No Internet Connection" message:@"MobiCarz could not send email as it is not connected to the Internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.emailSentAlert show];
    }
    else if([error code]==-1001)
    {
        self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"Error Occured" message:@"The request timed out." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.emailSentAlert show];
        
    }
    else
    {
        self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"Email Service Failed" message:@"MobiCarz could not connect to mail server." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      //  [self.emailSentAlert show];
    }
}


-(void)dealloc
{

    _carRecordFromDetailView=nil;
    
    [_emailOpQueue cancelAllOperations];
    _emailOpQueue=nil;
    
    _sendButton=nil;
    _cancelButton=nil;
}

@end



