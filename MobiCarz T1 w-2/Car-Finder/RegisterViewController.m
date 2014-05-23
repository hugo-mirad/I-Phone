//
//  RegisterViewController.m
//  Car-Finder
//
//  Created by Mac on 20/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"

#import "CommonMethods.h"

//for glossy button
#import "CheckButton.h"
#import "UIButton+Glossy.h"

#import "AFNetworking.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

#import "TPKeyboardAvoidingScrollView.h"

#import "LoginViewController.h"


@interface RegisterViewController()

@property(strong,nonatomic) NSOperationQueue *opQueue;

@property(strong,nonatomic) TPKeyboardAvoidingScrollView *scrollView2;

@property(strong,nonatomic) UITextField *fNameTextField,*lNameTextField,*emailTextField,*confirmEmailTextField,*phoneTextField;

@property(strong,nonatomic) UIImageView *activityImageView;
@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;
@property(strong,nonatomic) UIImageView *backgroundImageView;
@property(strong,nonatomic) CheckButton *registerButton;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

- (void)registerNewUserWithFname:(NSString *)name phone:(NSString *)phone email:(NSString *)email;

- (void)registerOperationFailedMethod:(NSError *)error;
- (void)handleOperationError:(NSError *)error;
- (void)handleJSONError:(NSError *)error;

- (void)findAndresignFirstResponderIfAny;

@end

@implementation RegisterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

static inline BOOL IsEmpty(id thing)

{
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

-(void)showActivityViewer
{
    if (self.isShowingLandscapeView) {
        [CommonMethods showActivityViewerForLandscape:self.view];
    }
    else
    {
        [CommonMethods showActivityViewer:self.view];
    }
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
        UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];

    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text = @"Registration"; //
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    self.navigationItem.titleView=navtitle;
    navtitle=nil;
    
    
    UIImage* image3 = [UIImage imageNamed:@"BackAll.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width/2-20, image3.size.height/2-20);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(backToResultsButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    
    UIBarButtonItem *lb= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem =lb;
    lb=nil;
    
    
    
    UIView *superview = self.view;
    self.backgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"back.png"]];
    
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [superview addSubview:self.backgroundImageView];
    
    
    
    [self.backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //left of av
    
    
    
    avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //right of av
    
    avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //bottom of av
    
    
    avAConstraint1 =
    [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:0
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:avAConstraint1]; //top of av to top of self.view
    
    self.scrollView2=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height)]; //150 49 for tab bar
    
    //
    self.scrollView2.showsVerticalScrollIndicator=YES;
    self.scrollView2.scrollEnabled=YES;
    self.scrollView2.userInteractionEnabled=YES;
    
    //
    [self.backgroundImageView addSubview:self.scrollView2];
    //autolayout
    [self.scrollView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView2 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView2 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self.backgroundImageView addConstraint:scrollView1Constraint];
    }else{
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationController.navigationBar.frame.size.height];
        [self.backgroundImageView addConstraint:scrollView1Constraint];
        
    }
    
  
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    
    
    //create cameraviewcontroller object and set its delegate to self, so that we can reload car record for gallery
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    
    {
        UILabel *nameLabel=[[UILabel alloc] init];
        self.fNameTextField=[[UITextField alloc] init];
        self.lNameTextField=[[UITextField alloc] init];
        UILabel *emailLabel=[[UILabel alloc] init];
        self.emailTextField=[[UITextField alloc] init];
        UILabel *confirmEmailLabel=[[UILabel alloc] init];
        self.confirmEmailTextField=[[UITextField alloc] init];
        UILabel *phoneLabel=[[UILabel alloc] init];
        self.phoneTextField=[[UITextField alloc] init];
        self.registerButton=[CheckButton buttonWithType:UIButtonTypeCustom];
        
            nameLabel.frame = CGRectMake(20, 24, 86, 21);
            self.fNameTextField.frame = CGRectMake(20, 58, 128, 31);
            self.lNameTextField.frame = CGRectMake(172, 58, 128, 31);
            emailLabel.frame = CGRectMake(20, 110, 56, 21);
            self.emailTextField.frame = CGRectMake(20, 144, 280, 31);
            confirmEmailLabel.frame = CGRectMake(20, 192, 130, 21);
            self.confirmEmailTextField.frame =CGRectMake(20, 226, 280, 31);
            phoneLabel.frame = CGRectMake(20, 270, 70, 21);
            self.phoneTextField.frame = CGRectMake(20, 304, 128, 31);
            self.registerButton.frame=CGRectMake(124, 354, 90, 37);

        
        //  UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 24, 86, 21)];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.text=@"Name:*";
        nameLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:nameLabel];
                //
        
        //self.fNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 58, 128, 31)];
        self.fNameTextField.backgroundColor=[UIColor whiteColor];
        self.fNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.fNameTextField.font = [UIFont systemFontOfSize:15];
        self.fNameTextField.placeholder = @"First Name";
        self.fNameTextField.textAlignment=NSTextAlignmentLeft;
        self.fNameTextField.textColor=[UIColor blackColor];
        self.fNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.fNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.fNameTextField.returnKeyType = UIReturnKeyDone;
        self.fNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.fNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.fNameTextField.tag=1;
        self.fNameTextField.delegate = self;
        [self.scrollView2 addSubview:self.fNameTextField];
        
        //
       // self.lNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(172, 58, 128, 31)];
        self.lNameTextField.backgroundColor=[UIColor whiteColor];
        self.lNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.lNameTextField.font = [UIFont systemFontOfSize:15];
        self.lNameTextField.placeholder = @"Last Name";
        self.lNameTextField.textAlignment=NSTextAlignmentLeft;
        self.lNameTextField.textColor=[UIColor blackColor];
        self.lNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.lNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.lNameTextField.returnKeyType = UIReturnKeyDone;
        self.lNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.lNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.lNameTextField.tag=2;
        self.lNameTextField.delegate = self;
        [self.scrollView2 addSubview:self.lNameTextField];
        
       // UILabel *emailLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 110, 56, 21)];
        emailLabel.backgroundColor=[UIColor clearColor];
        emailLabel.text=@"Email:*";
        emailLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:emailLabel];
        
        //
       // self.emailTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 144, 280, 31)];
        self.emailTextField.backgroundColor=[UIColor whiteColor];
        self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailTextField.font = [UIFont systemFontOfSize:15];
        self.emailTextField.placeholder = @"Email";
        self.emailTextField.textAlignment=NSTextAlignmentLeft;
        self.emailTextField.textColor=[UIColor blackColor];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.returnKeyType = UIReturnKeyDone;
        self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailTextField.tag=3;
        self.emailTextField.delegate = self;
        [self.scrollView2 addSubview:self.emailTextField];
        
        //
       // UILabel *confirmEmailLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 192, 130, 21)];
        confirmEmailLabel.backgroundColor=[UIColor clearColor];
        confirmEmailLabel.text=@"Confirm Email:*";
        confirmEmailLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:confirmEmailLabel];
        
        //
       //self.confirmEmailTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 226, 280, 31)];
        self.confirmEmailTextField.backgroundColor=[UIColor whiteColor];
        self.confirmEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.confirmEmailTextField.font = [UIFont systemFontOfSize:15];
        self.confirmEmailTextField.placeholder = @"Confirm Email";
        self.confirmEmailTextField.textAlignment=NSTextAlignmentLeft;
        self.confirmEmailTextField.textColor=[UIColor blackColor];
        self.confirmEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.confirmEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.confirmEmailTextField.returnKeyType = UIReturnKeyDone;
        self.confirmEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.confirmEmailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.confirmEmailTextField.tag=4;
        self.confirmEmailTextField.delegate = self;
        [self.scrollView2 addSubview:self.confirmEmailTextField];
        
        //
        //UILabel *phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 270, 70, 21)];
        phoneLabel.backgroundColor=[UIColor clearColor];
        phoneLabel.text=@"Phone:*";
        phoneLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:phoneLabel];
        
        //
       // self.phoneTextField=[[UITextField alloc] initWithFrame:CGRectMake(20, 304, 128, 31)];
        self.phoneTextField.backgroundColor=[UIColor whiteColor];
        self.phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.phoneTextField.font = [UIFont systemFontOfSize:15];
        self.phoneTextField.placeholder = @"Phone";
        self.phoneTextField.textAlignment=NSTextAlignmentLeft;
        self.phoneTextField.textColor=[UIColor blackColor];
        self.phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        self.phoneTextField.returnKeyType = UIReturnKeyDone;
        self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.phoneTextField.tag=5;
        self.phoneTextField.delegate = self;
        [self.scrollView2 addSubview:self.phoneTextField];
        
        //
//        self.registerButton=[CheckButton buttonWithType:UIButtonTypeCustom];
//        self.registerButton.frame=CGRectMake(124, 354, 90, 37);
        [self.registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.registerButton.tag=6;
        //[self.registerButton makeGlossy];
       // [self.registerButton setBackgroundImage:[UIImage imageNamed:@"Register.png"] forState:UIControlStateNormal];
        
        self.registerButton.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];

        [ self.registerButton setTitle:@"REGISTER" forState:UIControlStateNormal];
        [ self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        // [findACarButton.layer setBorderWidth:1];
        // findACarButton.layer.shadowColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f].CGColor;
        self.registerButton.layer.shadowRadius = 1.0f;
        self.registerButton.layer.shadowOpacity = 0.5f;
        self.registerButton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        self.registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];

                
        [self.scrollView2 addSubview:self.registerButton];
        
        
         [self.scrollView2 setContentSize:CGSizeMake(self.view.frame.size.width,400)];
        
        
    }
    else //iPad
        
    {
   
        UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(244, 100, 86, 21)];
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.text=@"Name:*";
        nameLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:nameLabel];
        
        
        self.fNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(244, 148, 128, 31)];
        self.fNameTextField.backgroundColor=[UIColor whiteColor];
        self.fNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.fNameTextField.font = [UIFont systemFontOfSize:15];
        self.fNameTextField.placeholder = @"First Name";
        self.fNameTextField.textAlignment=NSTextAlignmentLeft;
        self.fNameTextField.textColor=[UIColor blackColor];
        self.fNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.fNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.fNameTextField.returnKeyType = UIReturnKeyDone;
        self.fNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.fNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.fNameTextField.tag=1;
        self.fNameTextField.delegate = self;
        [self.scrollView2 addSubview:self.fNameTextField];
        
        //
        self.lNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(376, 148, 128, 31)];
        self.lNameTextField.backgroundColor=[UIColor whiteColor];
        self.lNameTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.lNameTextField.font = [UIFont systemFontOfSize:15];
        self.lNameTextField.placeholder = @"Last Name";
        self.lNameTextField.textAlignment=NSTextAlignmentLeft;
        self.lNameTextField.textColor=[UIColor blackColor];
        self.lNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.lNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.lNameTextField.returnKeyType = UIReturnKeyDone;
        self.lNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.lNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.lNameTextField.tag=2;
        self.lNameTextField.delegate = self;
        [self.scrollView2 addSubview:self.lNameTextField];
        
        UILabel *emailLabel=[[UILabel alloc] initWithFrame:CGRectMake(244, 200, 56, 21)];
        emailLabel.backgroundColor=[UIColor clearColor];
        emailLabel.text=@"Email:*";
        emailLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:emailLabel];
        
        //
        self.emailTextField=[[UITextField alloc] initWithFrame:CGRectMake(244, 240, 280, 31)];
        self.emailTextField.backgroundColor=[UIColor whiteColor];
        self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.emailTextField.font = [UIFont systemFontOfSize:15];
        self.emailTextField.placeholder = @"Email";
        self.emailTextField.textAlignment=NSTextAlignmentLeft;
        self.emailTextField.textColor=[UIColor blackColor];
        self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.returnKeyType = UIReturnKeyDone;
        self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.emailTextField.tag=3;
        self.emailTextField.delegate = self;
        [self.scrollView2 addSubview:self.emailTextField];
        
        //
        UILabel *confirmEmailLabel=[[UILabel alloc] initWithFrame:CGRectMake(244, 292, 130, 21)];
        confirmEmailLabel.backgroundColor=[UIColor clearColor];
        confirmEmailLabel.text=@"Confirm Email:*";
        confirmEmailLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:confirmEmailLabel];
        
        //
        self.confirmEmailTextField=[[UITextField alloc] initWithFrame:CGRectMake(244, 336, 280, 31)];
        self.confirmEmailTextField.backgroundColor=[UIColor whiteColor];
        self.confirmEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.confirmEmailTextField.font = [UIFont systemFontOfSize:15];
        self.confirmEmailTextField.placeholder = @"Confirm Email";
        self.confirmEmailTextField.textAlignment=NSTextAlignmentLeft;
        self.confirmEmailTextField.textColor=[UIColor blackColor];
        self.confirmEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.confirmEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.confirmEmailTextField.returnKeyType = UIReturnKeyDone;
        self.confirmEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.confirmEmailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.confirmEmailTextField.tag=4;
        self.confirmEmailTextField.delegate = self;
        [self.scrollView2 addSubview:self.confirmEmailTextField];
        
        //
        UILabel *phoneLabel=[[UILabel alloc] initWithFrame:CGRectMake(244, 386, 70, 21)];
        phoneLabel.backgroundColor=[UIColor clearColor];
        phoneLabel.text=@"Phone:*";
        phoneLabel.textColor = [UIColor blackColor];
        [self.scrollView2 addSubview:phoneLabel];
        
        //
        self.phoneTextField=[[UITextField alloc] initWithFrame:CGRectMake(244, 430, 128, 31)];
        self.phoneTextField.backgroundColor=[UIColor whiteColor];
        self.phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.phoneTextField.font = [UIFont systemFontOfSize:15];
        self.phoneTextField.placeholder = @"Phone";
        self.phoneTextField.textAlignment=NSTextAlignmentLeft;
        self.phoneTextField.textColor=[UIColor blackColor];
        self.phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        self.phoneTextField.returnKeyType = UIReturnKeyDone;
        self.phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.phoneTextField.tag=5;
        self.phoneTextField.delegate = self;
        [self.scrollView2 addSubview:self.phoneTextField];
        
        //
        self.registerButton=[CheckButton buttonWithType:UIButtonTypeCustom];
        self.registerButton.frame=CGRectMake(340, 500, 90, 37);
        [self.registerButton addTarget:self action:@selector(registerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        self.registerButton.tag=6;
        //[self.registerButton makeGlossy];
        //[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Register.png"] forState:UIControlStateNormal];
        self.registerButton.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];

        [ self.registerButton setTitle:@"REGISTER" forState:UIControlStateNormal];
        [ self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        // [findACarButton.layer setBorderWidth:1];
        // findACarButton.layer.shadowColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f].CGColor;
         self.registerButton.layer.shadowRadius = 1.0f;
         self.registerButton.layer.shadowOpacity = 0.5f;
         self.registerButton.layer.shadowOffset = CGSizeZero;
        //Font size of title
         self.registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //[ self.registerButton setShowsTouchWhenHighlighted:YES];
        
        //accessibility
        
        [self.scrollView2 addSubview:self.registerButton];
         [self.scrollView2 setContentSize:CGSizeMake(self.view.frame.size.width,600)];
        
    }
    
    self.opQueue=[[NSOperationQueue alloc] init];
    [self.opQueue setMaxConcurrentOperationCount:1];
    [self.opQueue setName:@"RegisterViewControllerOperationQueue"];
}



-(void)backToResultsButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    _fNameTextField.text=@"";
    _lNameTextField.text=@"";
    _emailTextField.text=@"";
    _confirmEmailTextField.text=@"";
    _phoneTextField.text=@"";
    [self.view.window endEditing: YES];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([textField isEqual:self.fNameTextField] || [textField isEqual:self.lNameTextField]) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 20) ? NO : YES;
    }
    else if ([textField isEqual:self.phoneTextField])
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 10) ? NO : YES;
    }
    return YES;
}

#pragma mark - Button Methods
- (void)registerButtonTapped
{
    NSString *name=[NSString stringWithFormat:@"%@ %@",self.fNameTextField.text,self.lNameTextField.text];
    
    if (IsEmpty(self.fNameTextField.text) || IsEmpty(self.lNameTextField.text)) {
        
        if (IsEmpty(self.fNameTextField.text)) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"First name Cannot Be Empty" message:@"Please enter your first name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;

            [self.fNameTextField becomeFirstResponder];
        }
        else if (IsEmpty(self.lNameTextField.text)) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Last name Cannot Be Empty" message:@"Please enter your last name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;

            [self.lNameTextField becomeFirstResponder];
        }
        return;
    }
    
    if (IsEmpty(self.emailTextField.text)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Enter Email" message:@"Please enter your email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.emailTextField becomeFirstResponder];
        return;
        
    }
    else if (![CommonMethods validateEmail:self.emailTextField.text]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Email" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.emailTextField becomeFirstResponder];
        return;
    }

    else if (IsEmpty(self.confirmEmailTextField.text)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Enter confirm Email" message:@"Please confirm your email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.confirmEmailTextField becomeFirstResponder];
        return;
        
    }
     else if (![CommonMethods validateEmail:self.confirmEmailTextField.text]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid confirm Email" message:@"Enter a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.confirmEmailTextField becomeFirstResponder];
        return;
    }
        
    
    // || ![CommonMethods validateEmail:self.confirmEmailTextField.text]
    //check if both email & confirm email are same
    if (![self.emailTextField.text isEqualToString:self.confirmEmailTextField.text]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Email Mismatch" message:@"Email and confirm email values does not match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        return;
        
    }
    
    
    
    if (IsEmpty(self.phoneTextField.text)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Enter phone number" message:@"phone number cannot be Empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.phoneTextField becomeFirstResponder];
        return;
        
    }
    else if ([self.phoneTextField.text length]>0 && [self.phoneTextField.text length]<10) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid phone number" message:@"Enter valid phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.phoneTextField becomeFirstResponder];
        return;
    }
    [self findAndresignFirstResponderIfAny]; //hide keypad if present
    
    //disable register button and enable again after web service result is retrieved
    self.registerButton.enabled=NO;
    
    //call service to register by sending registration data
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    [self registerNewUserWithFname:name phone:self.phoneTextField.text email:self.emailTextField.text];
    
    
}

- (void)registerNewUserWithFname:(NSString *)name phone:(NSString *)phone email:(NSString *)email
{
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    //http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/SendMobileRegistrationRequest/name/1234567890/name@email.com/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/12345/
    
    
    NSString *newRegistrationServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/SendMobileRegistrationRequest/%@/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",name,phone,email,retrieveduuid] ; //]@"din9030231534",@"dinesh"];
    newRegistrationServiceStr=[newRegistrationServiceStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //calling service
    NSURL *URL = [NSURL URLWithString:newRegistrationServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak RegisterViewController *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        self.registerButton.enabled=YES;
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        if(error2==nil)
        {
            
            BOOL newRegistrationResult=[[wholeResult objectForKey:@"SendMobileRegistrationRequestResult"] boolValue];
            
            
            //check status. If new registarion was successful, we get back true else false
            if (!newRegistrationResult) {
                //registration failed. handle error here
                NSLog(@"There was error in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
                
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"MobiCarz could not connect to the server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                
                
            }
            else
            {
                //success.
                
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Our service representative will contact you shortly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            
        }
        else
        {
            //handle JSON error here
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
            [weakSelf handleJSONError:error2];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        self.registerButton.enabled=YES;
        
        //call service failed
        //weakSelf.featuresFound=NO;
        //[weakSelf.featuresButton setHidden:YES];
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        [weakSelf handleOperationError:error];
    }];
    
    [self.opQueue addOperation:operation];
    
}


- (void)findAndresignFirstResponderIfAny
{
    for (UIView *subView in self.scrollView2.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            UITextField *tField=(UITextField *)subView;
            
            if ([tField isFirstResponder]) {
                [tField resignFirstResponder];
                break;
            }
        }
    }
}

#pragma mark - Operation Result Handing
- (void)registerOperationFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==kCFURLErrorTimedOut)
        {
            alert.title=@"Error Occured";
            alert.message=@"The request timed out.";
        }
        else
        {
            alert.title=@"Server Error";
            alert.message=[error localizedDescription];
        }
        
    }
    else //just for safe side though error object would not be nil
    {
        alert.title=@"Server Error";
        alert.message=@"MobiCarz could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
    
}

- (void)handleOperationError:(NSError *)error
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self registerOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self registerOperationFailedMethod:error2];
    
}

#pragma mark - Orientation Notif
- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !self.isShowingLandscapeView)
    {
        self.isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && self.isShowingLandscapeView)
    {
        self.isShowingLandscapeView = NO;
    }
}

- (void)dealloc {
    _opQueue=nil;
    
   // _scrollView2=nil;
    
    _fNameTextField=nil;
    _lNameTextField=nil;
    _emailTextField=nil;
    _confirmEmailTextField=nil;
    _phoneTextField=nil;
    
    _activityImageView=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
}

@end
