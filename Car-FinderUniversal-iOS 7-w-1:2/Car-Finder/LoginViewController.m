//
//  LoginViewController.m
//  Car-Finder
//
//  Created by Mac on 20/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

#import "CommonMethods.h"

#import "CheckButton.h"

//for AFNetworking
#import "AFNetworking.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#import "NSString+UUID.h"



#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "LoggedUserMainTable.h"
#import "MyCarsList.h"
#import "CarRecord.h"
#import "AppDelegate.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <QuartzCore/QuartzCore.h>


@interface LoginViewController()

@property(strong,nonatomic) NSOperationQueue *opQueue;

@property(strong,nonatomic) NSArray *carIdsArray;
@property(strong,nonatomic) NSMutableArray *allCarRecordsArray;

@property(strong,nonatomic) UIWebView *registerButton;

@property(strong,nonatomic) TPKeyboardAvoidingScrollView *loginScrollView;

@property(strong,nonatomic) UITextField *userNameTextField,*passwordTextField;

@property(strong,nonatomic) CheckButton *loginButton;

@property(strong,nonatomic) UIImageView *backgroundImageView,*loginIView;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

@property(strong,nonatomic) UIActivityIndicatorView *indicator;
@property(strong, nonatomic) UIBarButtonItem *lefttHomeButton;


-(void)checkLoginStatus;
- (void)processLoginResult:(BOOL)loginResult withUserName:(NSString *)uName andPassword:(NSString *)uPassword loginResult:(NSArray *)resultArray andError:(NSError *)error;
-(void)registerInfoServiceImplemenation;


- (void)loadCarIdsFromDict;
- (void)retrieveCars:(NSArray *)carIdsArray;
-(void)retrieveCarWithId:(NSString *)carId;

@end

@implementation LoginViewController

@synthesize opQueue=_opQueue;


@synthesize carIdsArray=_carIdsArray,allCarRecordsArray=_allCarRecordsArray;

@synthesize registerButton=_registerButton,loginScrollView=_loginScrollView;

@synthesize userNameTextField=_userNameTextField,passwordTextField=_passwordTextField,loginButton=_loginButton;

@synthesize backgroundImageView=_backgroundImageView;

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

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    

    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        navtitle.textColor=[UIColor  whiteColor];
        
    } else {
        navtitle.textColor=[UIColor  colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
        
         [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        //load resources for iOS 7
        
    }
    navtitle.text=@"Login"; //
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    self.lefttHomeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(HomeButtonPressed)];
    
    
   
    self.navigationItem.leftBarButtonItem = self.lefttHomeButton;
    
    
    self.backgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"back.png"]];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self.view addSubview:self.backgroundImageView];
    
    
    
    //autolayout constraints
    
    UIView *superview = self.view;
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
    
    self.loginScrollView=[[TPKeyboardAvoidingScrollView alloc] init];   
    
    self.loginScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.loginScrollView.autoresizesSubviews = YES;
    self.loginScrollView.showsHorizontalScrollIndicator = NO;
    //self.loginScrollView.showsVerticalScrollIndicator = NO;


    self.loginScrollView.bounces = NO;
    //
    [self.backgroundImageView addSubview:self.loginScrollView];
    //autolayout
    [self.loginScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.loginScrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.loginScrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.loginScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.loginScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
   //
    self.loginIView=[[UIImageView alloc] init ];//]WithFrame:CGRectMake(self.view.center.x-140, self.view.center.y-89, 280, 178)];
        NSString *imageName=[[NSBundle mainBundle] pathForResource:@"login1" ofType:@"png"];
        self.loginIView.image=[UIImage imageWithContentsOfFile:imageName];
        [self.loginScrollView addSubview:self.loginIView];
    
      [self.loginIView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint* cn = [NSLayoutConstraint constraintWithItem:self.loginIView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.loginScrollView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0];
    [self.view addConstraint:cn];
    cn = [NSLayoutConstraint constraintWithItem:self.loginIView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.loginScrollView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                       constant:-20];
    [self.view addConstraint:cn];
    
    
    
    self.userNameTextField=[[UITextField alloc] init];//WithFrame:CGRectMake(40, 80, 240, 31)];
    self.userNameTextField.backgroundColor=[UIColor colorWithWhite:0.224 alpha:1.000];
    self.userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.userNameTextField.font = [UIFont systemFontOfSize:15];
    self.userNameTextField.placeholder = @"Username";
    self.userNameTextField.textAlignment=NSTextAlignmentLeft;
    self.userNameTextField.textColor=[UIColor whiteColor];
    self.userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userNameTextField.returnKeyType = UIReturnKeyDone;
    self.userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNameTextField.tag=1;
    self.userNameTextField.delegate = self;
    [self.loginScrollView addSubview:self.userNameTextField];
   //self.userNameTextField.text=@"tes8985693686";
    //autolayout
    [self.userNameTextField setTranslatesAutoresizingMaskIntoConstraints:NO];

    
    
    self.passwordTextField=[[UITextField alloc] init];//WithFrame:CGRectMake(40, 122, 240, 31)];
    self.passwordTextField.backgroundColor=[UIColor colorWithWhite:0.224 alpha:1.000];
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.font = [UIFont systemFontOfSize:15];
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.textAlignment=NSTextAlignmentLeft;
    self.passwordTextField.textColor=[UIColor whiteColor];
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    //passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordTextField.tag=2;
    self.passwordTextField.secureTextEntry=YES;
    self.passwordTextField.delegate = self;
    [self.loginScrollView addSubview:self.passwordTextField];
   //self.passwordTextField.text=@"123456";
    //layout
    [self.passwordTextField setTranslatesAutoresizingMaskIntoConstraints:NO];

    
    
    self.loginButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    //[self.loginButton setBackgroundImage:[UIImage imageNamed:@"LoginBtn"] forState:UIControlStateNormal];
    
    self.loginButton.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithRed:105.0f/255.0f green:90.0f/255.0f blue:85.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    self.loginButton.layer.shadowRadius = 2.0f;
    self.loginButton.layer.shadowOpacity = 0.5f;
    self.loginButton.layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
    
    [self.loginScrollView addSubview:self.loginButton];
    //autolayout
    [self.loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];


    
    UILabel *noAccountLabel=[[UILabel alloc] init];//WithFrame:CGRectMake(50, 204, 182, 21)];
    noAccountLabel.backgroundColor=[UIColor clearColor];
    noAccountLabel.text=@"Not a member yet?";
    [noAccountLabel setTextColor:[UIColor whiteColor]];
    //CGFloat fontSize=[UIFont systemFontOfSize:8.0f];
    [noAccountLabel setFont:[UIFont systemFontOfSize:4]];
    [self.loginScrollView addSubview:noAccountLabel];
    //autolayout
    [noAccountLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    

    
    NSString *testString;
    self.registerButton=[[UIWebView alloc]init];//WithFrame:CGRectMake(160, 200, 200, 31)]; //when using as button give y as 8
    self.registerButton.opaque=NO;
    [self.registerButton setBackgroundColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){

    testString = @"<a href = \"obj://registerButtonTapped\"><font color='white' size='1'><u><b>REGISTER NOW</b></u></color></a>";
    }
    else
    {
        testString = @"<a href = \"obj://registerButtonTapped\"><font color='white' size='2'><u><b>REGISTER NOW</b></u></color></a>";
    }
    //NSString *testString=[NSString stringWithFormat:@"<a href = \"obj://registerButtonTapped\"><font color='white' size='6'><u>REGISTER NOW</u></color></a>",(int)(fontSize-1.0f)];
    [self.registerButton loadHTMLString:testString baseURL:nil];
    self.registerButton.delegate=self;
    self.registerButton.backgroundColor=[UIColor clearColor];
    self.registerButton.scrollView.scrollEnabled=NO;
    [self.loginScrollView addSubview:self.registerButton];
    //autolayout
    [self.registerButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
    //iPhone 4
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        
       // LetterParams.DeviceType=1;//IPadRetina
        NSLayoutConstraint *userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTop multiplier:1 constant:14];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:22];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        
        //
        NSLayoutConstraint *passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        [self.view addConstraint:passwordTextFieldConstraint];
        //-------------
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.userNameTextField attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self.view addConstraint:passwordTextFieldConstraint];
        
        //

        
        
        NSLayoutConstraint *loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:12];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:22];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:120];
        [self.view addConstraint:loginButtonConstraint];

        
        
        //
        CGFloat fontSize=[UIFont systemFontSize];
        [noAccountLabel setFont:[UIFont systemFontOfSize:fontSize-4.0f]];
        
        NSLayoutConstraint *noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:6];
        [self.view addConstraint:noAccountLabelConstraint];
        
        noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:4];
        [self.view addConstraint:noAccountLabelConstraint];
        
        //
        NSLayoutConstraint *registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:noAccountLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:160];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:22];
        [self.view addConstraint:registerButtonConstraint];
    }else{
        
        NSLog(@"non retinaaaaaaa");
        
        
        NSLayoutConstraint *userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTop multiplier:1 constant:20];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:32];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        
        //
        NSLayoutConstraint *passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:14];
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        [self.view addConstraint:passwordTextFieldConstraint];
        //-------------
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.userNameTextField attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        [self.view addConstraint:passwordTextFieldConstraint];
        
        //
        
        
        
        NSLayoutConstraint *loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:18];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:120];
        [self.view addConstraint:loginButtonConstraint];
        
        
        
        //
        CGFloat fontSize=[UIFont systemFontSize];
        [noAccountLabel setFont:[UIFont systemFontOfSize:fontSize]];
        
        NSLayoutConstraint *noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:18];
        [self.view addConstraint:noAccountLabelConstraint];
        
        noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:14];
        [self.view addConstraint:noAccountLabelConstraint];
        
        //
        NSLayoutConstraint *registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:14];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:noAccountLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:6];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:160];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:registerButtonConstraint];
        
     
        
    }
        
    }
    else
    {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
            
            
            NSLayoutConstraint *userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
            [self.view addConstraint:userNameTextFieldConstraint];
            
            userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
            
            [self.view addConstraint:userNameTextFieldConstraint];
            
            userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
            
            [self.view addConstraint:userNameTextFieldConstraint];
            
            
            userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:24];
            
            [self.view addConstraint:userNameTextFieldConstraint];
            
            
            NSLayoutConstraint *passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
            
            
            [self.view addConstraint:passwordTextFieldConstraint];
            
            passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
            
            [self.view addConstraint:passwordTextFieldConstraint];
            
            passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
            
            [self.view addConstraint:passwordTextFieldConstraint];
            
            passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:24];
            
            [self.view addConstraint:passwordTextFieldConstraint];
            
            NSLayoutConstraint *loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
            [self.view addConstraint:loginButtonConstraint];
            
            loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            [self.view addConstraint:loginButtonConstraint];
            
            loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:24];
            [self.view addConstraint:loginButtonConstraint];
            
            loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:120];
            [self.view addConstraint:loginButtonConstraint];
            
            
            CGFloat fontSize=[UIFont systemFontSize];
            [noAccountLabel setFont:[UIFont systemFontOfSize:fontSize-4.0f]];
            NSLayoutConstraint *noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
            [self.view addConstraint:noAccountLabelConstraint];
            
            noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
            [self.view addConstraint:noAccountLabelConstraint];
            
            noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:90];
            [self.view addConstraint:noAccountLabelConstraint];
            
            noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:26];
            [self.view addConstraint:noAccountLabelConstraint];
            
            
            
            NSLayoutConstraint *registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:8];
            [self.view addConstraint:registerButtonConstraint];
            
            registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:noAccountLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:2];
            [self.view addConstraint:registerButtonConstraint];
            
            registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-2];
            [self.view addConstraint:registerButtonConstraint];
            
            registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:24];
            [self.view addConstraint:registerButtonConstraint];

            
        }else{
       // LetterParams.DeviceType=2;//IPad Non-Retina
        
        NSLayoutConstraint *userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTop multiplier:1 constant:20];
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        
        [self.view addConstraint:userNameTextFieldConstraint];
        
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        
        [self.view addConstraint:userNameTextFieldConstraint];
        
       
        userNameTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.userNameTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        
        [self.view addConstraint:userNameTextFieldConstraint];
        
        
        NSLayoutConstraint *passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:14];
        
        
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        
        [self.view addConstraint:passwordTextFieldConstraint];
        
        passwordTextFieldConstraint=[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        
        [self.view addConstraint:passwordTextFieldConstraint];

        
        
        NSLayoutConstraint *loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:18];
        [self.view addConstraint:loginButtonConstraint];
        
       loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [self.view addConstraint:loginButtonConstraint];
        
       loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:loginButtonConstraint];
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:136];
        [self.view addConstraint:loginButtonConstraint];

            CGFloat fontSize=[UIFont systemFontSize];
        [noAccountLabel setFont:[UIFont systemFontOfSize:fontSize+2.0f]];
        NSLayoutConstraint *noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:18];
        [self.view addConstraint:noAccountLabelConstraint];
        
        noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
        [self.view addConstraint:noAccountLabelConstraint];
        
        noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:140];
        [self.view addConstraint:noAccountLabelConstraint];
        
        noAccountLabelConstraint=[NSLayoutConstraint constraintWithItem:noAccountLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:noAccountLabelConstraint];

        
        
         NSLayoutConstraint *registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeBottom multiplier:1 constant:16];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:noAccountLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:12];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.loginIView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-6];
        [self.view addConstraint:registerButtonConstraint];
        
        registerButtonConstraint=[NSLayoutConstraint constraintWithItem:self.registerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:registerButtonConstraint];
        }
        }

    
    //
    self.opQueue=[[NSOperationQueue alloc]init];
    [self.opQueue setName:@"LoginCheckQueue"];
    [self.opQueue setMaxConcurrentOperationCount:1];
    
    CGRect frame = CGRectMake(self.view.frame.size.width/2-15, self.view.frame.size.height/2-15, 37, 37);
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [self.indicator startAnimating];
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.indicator sizeToFit];
    self.indicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleTopMargin |
                                  UIViewAutoresizingFlexibleBottomMargin);
    
    self.indicator.tag = 1;
    [self.view addSubview:self.indicator];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.lefttHomeButton.enabled = YES;
    
    //isShowingLandscapeView should be a BOOL declared in your header (.h)
    //self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    if (self.allCarRecordsArray!=nil) {
        self.allCarRecordsArray=nil;
    }
    self.allCarRecordsArray=[[NSMutableArray alloc] initWithCapacity:1];
   self.registerButton.userInteractionEnabled=YES;
    self.loginButton.enabled = YES;
    [self.indicator stopAnimating];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration
{
   
    //__weak LoginViewController *weakSelf=self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        
//      //  weakSelf.loginIView.frame = CGRectMake(self.view.frame.size.width/2-140, self.view.frame.size.height/2-89, 280, 178);
//    });

   
    
}



#pragma mark -Button Methods
- (void)loginButtonTapped
{
    
    [self.indicator startAnimating];
    
    if (IsEmpty(self.userNameTextField.text)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Username Cannot be Empty" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.userNameTextField becomeFirstResponder];
        return;
    }
    else if (IsEmpty(self.passwordTextField.text)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Password Cannot be Empty" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.passwordTextField becomeFirstResponder];
        return;
    }
    
    if ([self.userNameTextField isFirstResponder]) {
        [self.userNameTextField resignFirstResponder];
    }
    else if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    
    
    //disable login button and enable again after getting web service result
    self.loginButton.enabled=NO;
     self.registerButton.userInteractionEnabled=NO;
    self.lefttHomeButton.enabled = NO;

    //perform login action
    
    [self checkLoginStatus];
    //[self performSegueWithIdentifier:@"LoggedUserMainTableSegue" sender:nil];
}

- (void)registerButtonTapped
{
    self.loginButton.enabled = NO;
    [self performSegueWithIdentifier:@"RegisterViewControllerSegue" sender:nil];
}

-(void)HomeButtonPressed
{
    
    
    //[self dismissModalViewControllerAnimated:YES];
    UIStoryboard *mainStoryboard;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    }
    else //iPad
    {
        mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard-iPad" bundle:nil];
    }
    UINavigationController *initViewController = [mainStoryboard instantiateInitialViewController];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate.window  setRootViewController:initViewController];
    
}


#pragma mark - Private Methods
-(void)checkLoginStatus
{
    UITextField *userNameField=(UITextField *)[self.view viewWithTag:1];
    UITextField *passwordField=(UITextField *)[self.view viewWithTag:2];
    NSString *uName=[userNameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *uPassword=[passwordField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSString *loginServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLoginMobile/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@", uName,uPassword,retrieveduuid] ; //]@"din9030231534",@"dinesh"];
    
    
    //http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLoginMobile/din9030231534/dinesh/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/2DD7B986-0D72-4EC0-8709-A5AB82B32554
    
    //calling service
    NSURL *URL = [NSURL URLWithString:loginServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak LoginViewController *weakSelf=self;
    __block BOOL loginResult=NO;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        if(error2==nil)
        {
            
            NSArray *loginResultArray=[wholeResult objectForKey:@"PerformLoginMobileResult"];
            
            //check status
            if ([loginResultArray count]==0) {
                loginResult=NO;
            }
            else
            {
                NSDictionary *loginDict=[loginResultArray objectAtIndex:0];
                NSString *status=[loginDict objectForKey:@"AASuccess"];
                if ([status isEqualToString:@"User Existed"]) {
                    loginResult=YES;
                    
                    //store the value of UId field in NSUserDefaults for future use
                    //[SSKeychain setPassword:[loginDict objectForKey:@"UID"] forService:UID_USER_DEFAULTS_KEY account:@"user"];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[loginDict objectForKey:@"UID"] forKey:UID_KEY]; //storing in NSUserDefaults
                    [defaults setValue:[loginDict objectForKey:@"SessionID"] forKey:SESSIONID_KEY];
                    [defaults synchronize];
                    
                }
                else if ([status isEqualToString:@"Failure"])
                {
                    loginResult=NO;
                    self.registerButton.userInteractionEnabled=YES;
                    self.lefttHomeButton.enabled = YES;
                    
                }
                else
                {
                    loginResult=NO;
                }
                
            }
            [weakSelf processLoginResult:loginResult withUserName:uName andPassword:uPassword loginResult:loginResultArray andError:error2]; //check for resultValue=nil in method
            
        }
        else
        {
            loginResult=NO;
            
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
            [weakSelf processLoginResult:loginResult withUserName:nil andPassword:nil loginResult:nil andError:error2];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        
        //call service failed
        loginResult=NO;
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        [weakSelf processLoginResult:loginResult withUserName:nil andPassword:nil loginResult:nil andError:error];
        
        self.registerButton.userInteractionEnabled=YES;
        self.lefttHomeButton.enabled = YES;
    }];
    
    [self.opQueue addOperation:operation];
    
}

- (void)processLoginResult:(BOOL)loginResult withUserName:(NSString *)uName andPassword:(NSString *)uPassword loginResult:(NSArray *)resultArray andError:(NSError *)error
{
    //if YES, save in userdefaults. Then go to next segue
    if (error) {
        //enable loginbutton again as there was an error
        self.loginButton.enabled=YES;
        
        UIAlertView *alert=[[UIAlertView alloc]init];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        
        
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==-1001)
        {
            alert.title=@"Error Occured";
            alert.message=@"The request timed out.";
        }
        else
        {
            alert.title=@"Server Error";
            alert.message=@"UCE Car Finder cannot retrieve data due to server error.";
        }
        [alert show];
        alert=nil;
    }
    else if (loginResult) {
        //don't enable the login button now. we will enable that after call to registerInfoServiceImplemenation
        
        //download registration info data because it contains car ids
        [self registerInfoServiceImplemenation];
        
    }
    else if (!loginResult)
    {
        //enable loginbutton again as there was an error
        self.loginButton.enabled=YES;
        
        
        NSLog(@"user could not be validated");
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Username or Password" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        [self hideActivityViewer];
        
    }
}


-(void)dismissKeyboard {
    for (int aTag=1; aTag<=2; aTag++) {
        UITextField *aView=(UITextField *)[self.view viewWithTag:aTag];
        
        if ([aView isFirstResponder])
        {
            [aView resignFirstResponder];
        }
    }
}

- (void)callLoginOperationFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    //display alert
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
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
        alert.message=@"UCE Car Finder could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
    
    
}

- (void)handleOperationError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in LoginView" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callLoginOperationFailedMethod:error2];
    
}

- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in LoginViewController" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callLoginOperationFailedMethod:error2];
    
}

-(void)registerInfoServiceImplemenation
{
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *uid=[defaults valueForKey:UID_KEY];
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    NSString *urlString=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetUserRegistrationDetailsByID/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@",uid,retrieveduuid,sessionID];
    

    NSURL *regInfoUrlStr = [NSURL URLWithString:urlString];
    
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *regInfoUrlStrReq = [NSURLRequest requestWithURL:regInfoUrlStr cachePolicy:policy timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:regInfoUrlStrReq];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])
             
         {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
         }
         
     }];
    
    
    __weak LoginViewController *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         //[self hideActivityViewer];
         
         //call service executed succesfully
         NSError *error2=nil;
         NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
         if(error2==nil)
         {
             
             NSArray *regInfoArray = [wholeResult objectForKey:@"GetUserRegistrationDetailsByIDResult"];
             
             
             NSDictionary *registrationDict = [regInfoArray objectAtIndex:0];
             
             
             
             if ([[registrationDict objectForKey:@"AASucess"] isEqualToString:@"Success"]) {
                 //put this dictionary in NSUserDefaults
                 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                 [defaults setValue:registrationDict forKey:@"RegistrationDictKey"];
                 [defaults synchronize];
                 
                 
                 
                 if ([[registrationDict objectForKey:@"CarIDs"] isEqualToString:@"Emp"]) {
                     [weakSelf hideActivityViewer];
                     
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Cars Found" message:@"Please contact customer service and add car details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
                     alert=nil;
                     
                     //enable loginbutton again as there was an error
                     weakSelf.loginButton.enabled=YES;
                     
                 }
                 else
                 {
                     [weakSelf loadCarIdsFromDict];
                     [weakSelf retrieveCars:self.carIdsArray];
                 }
             }
             else //may be session expired, or other error. Session cannot expire because login was performed just a moment ago
             {
                 //enable loginbutton again as there was an error
                 weakSelf.loginButton.enabled=YES;
                 
                 NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
                 
             }
             
             
         }
         else
         {
             //enable loginbutton again as there was an error
             weakSelf.loginButton.enabled=YES;
             
             //handle json error here
             NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
             [weakSelf handleJSONError:error2];
             
         }
         
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         //enable loginbutton again as there was an error
                                         weakSelf.loginButton.enabled=YES;
                                         
                                         [weakSelf hideActivityViewer];
                                         
                                         
                                         NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
                                         [weakSelf handleOperationError:error];
                                     }];
    
    [self.opQueue addOperation:operation];
    
}



-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    [CommonMethods hideActivityViewer:self.view];
    [self.indicator stopAnimating];
}


#pragma mark - Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.view setUserInteractionEnabled:YES];
   
    if ([segue.identifier isEqualToString:@"MyCarsListSegue"]) {
        
        MyCarsList *myCarsList=[segue destinationViewController];
        //pass all cars
        myCarsList.arrayOfAllCarRecordObjects=self.allCarRecordsArray;
        
    }
   
}

#pragma mark - Getting Cars By Ids
- (void)loadCarIdsFromDict
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *registrationDict=[defaults valueForKey:@"RegistrationDictKey"];
    
    NSString *carIdsStr=[registrationDict objectForKey:@"CarIDs"];
    
    self.carIdsArray=[carIdsStr componentsSeparatedByString:@","];
   
}

- (void)retrieveCars:(NSArray *)carIdsArray
{
    //call web service with each object in above array and store the results in array containing dicts (cars)
    for (NSString *carid in carIdsArray) {
        [self retrieveCarWithId:carid];
    }
    
}

-(void)retrieveCarWithId:(NSString *)carId
{
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
   
    
    NSString *urlString=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/FindCarID/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",carId,retrieveduuid];
    
    
    NSURL *regInfoUrl = [NSURL URLWithString:urlString];
    
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *regInfoUrlReq = [NSURLRequest requestWithURL:regInfoUrl cachePolicy:policy timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:regInfoUrlReq];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])
             
         {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
         }
         
     }];
    
    __weak LoginViewController *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         //enable loginbutton again as there are no more internet calls
         weakSelf.loginButton.enabled=YES;
         
         //call service executed succesfully
         NSError *error2=nil;
         NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
         if(error2==nil)
         {
             
             NSArray *carIDResultArray = [wholeResult objectForKey:@"FindCarIDResult"];
             
             NSDictionary *someCar = [carIDResultArray objectAtIndex:0];
             
             
             //add this car to allCarRecordsArray
             CarRecord *record=[[CarRecord alloc] initWithDictionary:someCar];
             [weakSelf.allCarRecordsArray addObject:record];
             NSString *lastCarId=[weakSelf.carIdsArray objectAtIndex:[weakSelf.carIdsArray count]-1];
             if ([carId isEqualToString:lastCarId]) {
                 [weakSelf hideActivityViewer];
                 
                 //do this if there are car id's
                 if (weakSelf.allCarRecordsArray && weakSelf.allCarRecordsArray.count) {
                  
                     [weakSelf performSegueWithIdentifier:@"MyCarsListSegue" sender:nil];
                 }
                 else
                 {
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Cars Yet" message:@"You have not added any cars." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
                     alert=nil;
                     
                     
                 }
             }
             
         }
         else
         {
             
             NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
             [weakSelf handleJSONError:error2];
             
         }
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         //enable loginbutton again as there are no more internet calls
                                         weakSelf.loginButton.enabled=YES;
                                         
                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                         NSString *lastCarId=[weakSelf.carIdsArray objectAtIndex:[weakSelf.carIdsArray count]-1];
                                         if ([carId isEqualToString:lastCarId]) {
                                             [weakSelf hideActivityViewer];
                                         }
                                         
                                         
                                         NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
                                         
                                         [weakSelf handleOperationError:error];
                                     }];
    
    if (!self.opQueue) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"LoggedUserMainTableQueueForGettingCars"];
        [self.opQueue setMaxConcurrentOperationCount:1];
        
    }
    [self.opQueue addOperation:operation];
    //operation=nil;
    
    
    
}

#pragma mark - Text Field Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

#pragma mark - Webview Delegate Methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    
    //check if a html link is clicked
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        
        //get url from request
        NSURL *url=[request URL];
        
        //get the url scheme i.e., http or https or ftp or objc (in our case)
        
        if ([[url scheme] isEqualToString:@"obj"]) {
            //get a hold of webview so that we can use it later
            
            //we get the host part of url and use it as our method that we execute
            SEL method=NSSelectorFromString([url host]);
            //now execute that method
            if ([self respondsToSelector:method]) {
                [self performSelector:method withObject:nil afterDelay:0.1f];
                
            }
            return NO;
        }
    }
    return YES;
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

-(void)dealloc
{
    [_opQueue cancelAllOperations];
    

    
    _allCarRecordsArray=nil;
    _carIdsArray=nil;
    _opQueue=nil;
    _registerButton=nil;
    
}

@end




