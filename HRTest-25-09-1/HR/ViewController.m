//
//  ViewController.m
//  HR
//
//  Created by Venkata Chinni on 7/29/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "ViewController.h"
#import "EmployeeDetailViewController.h"
#import "MBProgressHUD.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AFNetworking.h"
//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


@interface ViewController ()
{
    BOOL yesForLoad;
}


@property(strong,nonatomic) AFHTTPClient *networkConnection;
@property(strong,nonatomic) NSMutableData *empMbLogindata;
//for xml parsing
@property(strong,nonatomic) NSXMLParser *xmlParser;

@property(copy,nonatomic) NSString *currentelementValueStr;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

     [[UIApplication sharedApplication] setStatusBarHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strMoveTOEmpDtView = [cmpEmpDetailDefaults objectForKey:@"oneTimeLoginKey"];
    
    
    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
        if ([strMoveTOEmpDtView isEqualToString:@"Success"])
        {
            UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"EmpDetailID"];
            [self.navigationController pushViewController:objAddContactViewCon animated:YES];
        }
//    }
//    else
//    {
//        
//        
//    }
  
    TPKeyboardAvoidingScrollView *scrollView=[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    
    scrollView.showsVerticalScrollIndicator=YES;
    scrollView.scrollEnabled=YES;
    scrollView.userInteractionEnabled=YES;
        
    UIView *loginBackgroundView = [[UIView alloc] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
    loginBackgroundView.Frame = CGRectMake(self.view.frame.size.width/2-140, self.view.frame.size.height/2-160, 280, 320);
    }
    else
    {
    loginBackgroundView.Frame = CGRectMake(self.view.frame.size.width/2-250, self.view.frame.size.height/2-350, 500, 480);
        
    }
    loginBackgroundView.backgroundColor = [UIColor colorWithRed:254.0/255 green:254.0/255 blue:254.0/255 alpha:1.0];
    [scrollView addSubview:loginBackgroundView];
    
    loginBackgroundView.layer.shadowOffset = CGSizeMake(1, 0);
    loginBackgroundView.layer.shadowOpacity = 0.30;
    loginBackgroundView.layer.cornerRadius = 4.0;
    
    UIImageView *imageview = [[UIImageView alloc] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        imageview.Frame = CGRectMake(loginBackgroundView.frame.size.width/2-20,-30, 50, 50);
    }
    else
    {
        imageview.Frame = CGRectMake(loginBackgroundView.frame.size.width/2-45,-60, 90, 90);
    }
    imageview.image = [UIImage imageNamed:@"brandLogo.png"];
    [loginBackgroundView addSubview:imageview];
    
    
    UILabel *whiteLbl = [[UILabel alloc] init];
    whiteLbl.text = @"Welcome to Attendance Master";
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    whiteLbl.frame =  CGRectMake(loginBackgroundView.frame.size.width/2-130, 10, 260, 50);
        whiteLbl.font = [UIFont boldSystemFontOfSize:16];
    }
    else
    {
    whiteLbl.frame =  CGRectMake(loginBackgroundView.frame.size.width/2-160, 30, 320, 50);
        whiteLbl.font = [UIFont boldSystemFontOfSize:20];
    }
    
    whiteLbl.textAlignment = NSTextAlignmentCenter;
    whiteLbl.textColor = [UIColor blackColor];//103, 106, 108
    whiteLbl.backgroundColor = [UIColor clearColor];
    [loginBackgroundView addSubview:whiteLbl];
    
    UILabel *lineLbl = [[UILabel alloc] init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
     lineLbl.frame =  CGRectMake(0, 60, loginBackgroundView.frame.size.width, 1);
    }
    else
    {
        lineLbl.frame =  CGRectMake(0, 100, loginBackgroundView.frame.size.width, 1);
    }
    lineLbl.backgroundColor = [UIColor colorWithRed:211.0/255 green:211.0/255 blue:211.0/255 alpha:1.0];
    [loginBackgroundView addSubview:lineLbl];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    cmpCodeTextField=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-110, lineLbl.frame.origin.y+24, 220, 34)];
        cmpCodeTextField.font = [UIFont systemFontOfSize:15];
    }
    else
    {
    cmpCodeTextField=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-210, lineLbl.frame.origin.y+34, 420, 44)];
        cmpCodeTextField.font = [UIFont systemFontOfSize:18];
    }
    cmpCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    cmpCodeTextField.placeholder = @"Company code";
    cmpCodeTextField.secureTextEntry = YES;
    cmpCodeTextField.textAlignment=NSTextAlignmentLeft;
    cmpCodeTextField.textColor=[UIColor blackColor];
    cmpCodeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    cmpCodeTextField.returnKeyType = UIReturnKeyDone;
    cmpCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cmpCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cmpCodeTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [loginBackgroundView addSubview:cmpCodeTextField];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    empCompanyIDTF=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-110, cmpCodeTextField.frame.origin.y+cmpCodeTextField.frame.size.height+8, 220, 34)];
        empCompanyIDTF.font = [UIFont systemFontOfSize:15];
    }
    else
    {
    empCompanyIDTF=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-210, cmpCodeTextField.frame.origin.y+cmpCodeTextField.frame.size.height+16, 420, 44)];
        empCompanyIDTF.font = [UIFont systemFontOfSize:18];
    }
    
    empCompanyIDTF.borderStyle = UITextBorderStyleRoundedRect;
    
    empCompanyIDTF.placeholder = @"Emp ID";
    empCompanyIDTF.textAlignment=NSTextAlignmentLeft;
    empCompanyIDTF.secureTextEntry = YES;
    empCompanyIDTF.textColor=[UIColor blackColor];
    empCompanyIDTF.autocorrectionType = UITextAutocorrectionTypeNo;
    empCompanyIDTF.returnKeyType = UIReturnKeyDone;
    empCompanyIDTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    empCompanyIDTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    empCompanyIDTF.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [loginBackgroundView addSubview:empCompanyIDTF];

    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    passwordTextField=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-110, empCompanyIDTF.frame.origin.y+empCompanyIDTF.frame.size.height+8, 220, 34)];
        passwordTextField.font = [UIFont systemFontOfSize:15];
    }
    else
    {
    passwordTextField=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-210, empCompanyIDTF.frame.origin.y+empCompanyIDTF.frame.size.height+16, 420, 44)];
        passwordTextField.font = [UIFont systemFontOfSize:18];
    }
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    passwordTextField.placeholder = @"Password";
    passwordTextField.secureTextEntry = YES;
    passwordTextField.textAlignment=NSTextAlignmentLeft;
    passwordTextField.textColor=[UIColor blackColor];
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.delegate = self;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [loginBackgroundView addSubview:passwordTextField];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    secureCodeTextField=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-110, passwordTextField.frame.origin.y+passwordTextField.frame.size.height+8, 220, 34)];
        secureCodeTextField.font = [UIFont systemFontOfSize:15];
    }
    else
    {
        secureCodeTextField=[[UITextField alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-210, passwordTextField.frame.origin.y+passwordTextField.frame.size.height+16, 420, 44)];
        secureCodeTextField.font = [UIFont systemFontOfSize:18];
    }
    secureCodeTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    secureCodeTextField.placeholder = @"Secure code";
    secureCodeTextField.secureTextEntry = YES;
    secureCodeTextField.textAlignment=NSTextAlignmentLeft;
    secureCodeTextField.textColor=[UIColor blackColor];
    secureCodeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    secureCodeTextField.returnKeyType = UIReturnKeyDone;
    secureCodeTextField.delegate = self;
    secureCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    secureCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    secureCodeTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [loginBackgroundView addSubview:secureCodeTextField];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    _radiobutton1 = [[UIButton alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-110, secureCodeTextField.frame.origin.y+secureCodeTextField.frame.size.height+20, 22, 22)];
    }
    else
    {
        _radiobutton1 = [[UIButton alloc] initWithFrame:CGRectMake(loginBackgroundView.frame.size.width/2-210, secureCodeTextField.frame.origin.y+secureCodeTextField.frame.size.height+30, 40, 40)];
    }
    [_radiobutton1 setTag:0];
    
    [_radiobutton1 setBackgroundImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateSelected];//UIControlStateSelected
    [_radiobutton1 setBackgroundImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];//UIControlStateNormal
    
    [_radiobutton1 addTarget:self action:@selector(radiobuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [loginBackgroundView addSubview:_radiobutton1];
    
    
    UILabel *remLbl = [[UILabel alloc] init];
    remLbl.text = @"Remember me";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    remLbl.frame =  CGRectMake(_radiobutton1.frame.origin.x + _radiobutton1.frame.size.width-16, secureCodeTextField.frame.origin.y+secureCodeTextField.frame.size.height+4, 120, 50);
        
        remLbl.font = [UIFont boldSystemFontOfSize:10];
    }
    else
    {
    remLbl.frame =  CGRectMake(_radiobutton1.frame.origin.x + _radiobutton1.frame.size.width+14, secureCodeTextField.frame.origin.y+secureCodeTextField.frame.size.height+20, 120, 50);
        remLbl.font = [UIFont boldSystemFontOfSize:16];

    }
    remLbl.textAlignment = NSTextAlignmentCenter;
    remLbl.textColor = [UIColor colorWithRed:103.0/255.0 green:106.0/255.0 blue:108.0/255.0 alpha:1.0];//103, 106, 108
    remLbl.backgroundColor = [UIColor clearColor];
    [loginBackgroundView addSubview:remLbl];

    
    UIButton *SignInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [SignInButton addTarget:self action:@selector(EmployeeloginButtonTapped)forControlEvents:UIControlEventTouchDown];
    [SignInButton setTitle:@"Login" forState:UIControlStateNormal];
    [SignInButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];//24, 167, 138
    [SignInButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    SignInButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    SignInButton.frame = CGRectMake(remLbl.frame.origin.x + remLbl.frame.size.width+10, secureCodeTextField.frame.origin.y+secureCodeTextField.frame.size.height+18, 80.0, 30.0);
    }
    else
    {
    SignInButton.frame = CGRectMake(remLbl.frame.origin.x + remLbl.frame.size.width+120, secureCodeTextField.frame.origin.y+secureCodeTextField.frame.size.height+28, 120.0, 50.0);
    }
    SignInButton.layer.cornerRadius = 4.0;
    [loginBackgroundView addSubview:SignInButton];
    
    SignInButton.layer.shadowOffset = CGSizeMake(1, 0);
    SignInButton.layer.shadowOpacity = 0.30;
    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        
//    }
//    else
//    {
//        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
//           {
//               
//               //portrait logic
//           }
//           else
//           {
//               
//               //landcapeLogic
//           }
//    }
    
    comEmpDetailsDictionary = [[NSMutableDictionary alloc] init];
    
    //Create and add the Activity Indicator to splashView
//    activityIndicator = [[UIActivityIndicatorView alloc] init];
//    activityIndicator.color = [UIColor grayColor];
//    activityIndicator.alpha = 1.0;
//    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    activityIndicator.hidden = YES;
//    [scrollView addSubview:activityIndicator];
   
    saveDefaults = YES;
    
    NSUserDefaults *saveDefalt = [NSUserDefaults standardUserDefaults];
    BOOL tempBool =  [saveDefalt boolForKey:@"yesForLoadKey"];
   
    if (tempBool == YES)
    {
        NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
        NSString *strCmpName = [defaultsLocal objectForKey:@"cmpCodeTextFieldKey"];
        NSString *strEmpName = [defaultsLocal objectForKey:@"empCompanyIDTFKey"];
        
        cmpCodeTextField.text = strCmpName;
        empCompanyIDTF.text = strEmpName;
    }
    else if(tempBool == NO)
    {
        NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
        [defaultsLocal  removeObjectForKey:@"cmpCodeTextFieldKey"];
        [defaultsLocal removeObjectForKey:@"empCompanyIDTFKey"];
        
    }
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, loginBackgroundView.frame.origin.y+loginBackgroundView.frame.size.height);
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_locationManager startUpdatingLocation];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
   // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

-(void)radiobuttonSelected:(id)sender{
    
    
    switch ([sender tag]) {
        case 0:
            if([_radiobutton1 isSelected]==YES)
            {
                [_radiobutton1 setSelected:NO];
                
                saveDefaults = YES;
                
            }
            else
            {
                saveDefaults = NO;
                
                yesForLoad = NO;
                NSUserDefaults *saveDefalt = [NSUserDefaults standardUserDefaults];
                [saveDefalt removeObjectForKey:@"yesForLoadKey"];
                [saveDefalt setBool:yesForLoad forKey:@"yesForLoadKey"];
                [saveDefalt synchronize];
                
                [_radiobutton1 setSelected:YES];
            }
            
            break;
           default:
            break;
    }
    
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
    NSString *currentLatitude = [[NSString alloc]
                                 initWithFormat:@"%+.4f",
                                 newLocation.coordinate.latitude];
    latitudeStr = currentLatitude;
    NSLog(@"latitudeStr--%@",latitudeStr);
    
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"%+.4f",
                                  newLocation.coordinate.longitude];
    
    longitudeStr = currentLongitude;
    NSLog(@"longitudeStr--%@",longitudeStr);
    
   // fromLabel.text =  [NSString stringWithFormat:@"%@ %@",latitudeStr,longitudeStr ];
    
}
-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
    
    
}
// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)EmployeeloginButtonTapped
{
    [self.view endEditing:YES];
    
    
     //[self EntryLoginImp];
    
    if (cmpCodeTextField.text.length != 0 && empCompanyIDTF.text.length != 0 && passwordTextField.text.length !=0 && secureCodeTextField.text.length != 0)
    {
        [self EntryLoginImp];
        //[activityIndicator startAnimating];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.view.userInteractionEnabled = NO;
//        if(passwordTextField.text.length >= 5 && passwordTextField.text.length <= 10)
//        {
//            
//            if(secureCodeTextField.text.length >= 3 && secureCodeTextField.text.length <= 8)
//            {
//                
//                if ([passwordTextField.text rangeOfCharacterFromSet:upperCaseChars].location != NSNotFound && [passwordTextField.text rangeOfCharacterFromSet:lowerCaseChars].location != NSNotFound &&  [passwordTextField.text rangeOfCharacterFromSet:numbers].location != NSNotFound && [passwordTextField.text rangeOfCharacterFromSet:specialCharacterSet].location != NSNotFound)
//                {
//                    
//                    
//                    if ([secureCodeTextField.text rangeOfCharacterFromSet:upperCaseChars].location != NSNotFound && [secureCodeTextField.text rangeOfCharacterFromSet:lowerCaseChars].location != NSNotFound && [secureCodeTextField.text rangeOfCharacterFromSet:numbers].location != NSNotFound)
//                    
//                    {
//                        
//                        
//                        [self EntryLoginImp];
//                        
//                        [activityIndicator startAnimating];
//                        self.view.userInteractionEnabled = NO;
//                        
//                        
//                        
//                        
//                        
////                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
////                                                                        message:@"Good string"
////                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////                        [alert show];
//                    }
//                    else
//                    {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                        message:@"Please Ensure that you have at least one lower case letter, one upper case letter, one digit character in Secure code"
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    }
//                    
//
//                    
//                    
//                    
//                    
//                   
//                }
//                else
//                {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                    message:@"Please Ensure that you have at least one lower case letter, one upper case letter and one special character in Password"
//                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
//                }
//                
//                
//                
//                
//            }
//            else
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                message:@"Please Enter Secure code must be 3 to 8 charecters"
//                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//            }
//            
//            
//            
//            
//            
//        }
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:@"Please Enter password must be 5 to 10 charecters"
//                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//        }
//        
//        
        
        
        
        
        
        

    }
    else if(cmpCodeTextField.text.length == 0 && empCompanyIDTF.text.length == 0 && passwordTextField.text.length ==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }

    else if(cmpCodeTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Company code" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
                              
    }
    else if(empCompanyIDTF.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Emp ID" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if(passwordTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if(secureCodeTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Secure code" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)EntryLoginImp
{

    if (saveDefaults == YES)
    {
        NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
        [defaultsLocal setObject:cmpCodeTextField.text forKey:@"cmpCodeTextFieldKey"];
        [defaultsLocal setObject:empCompanyIDTF.text forKey:@"empCompanyIDTFKey"];
        [defaultsLocal setObject:secureCodeTextField.text forKey:@"empsecureCodeTextFielKey"];
        [defaultsLocal setObject:passwordTextField.text forKey:@"empPasswordTextFielKey"];
        [defaultsLocal synchronize];
        
            yesForLoad = YES;
        NSUserDefaults *saveDefalt = [NSUserDefaults standardUserDefaults];
        [saveDefalt setBool:yesForLoad forKey:@"yesForLoadKey"];
        [saveDefalt synchronize];
    }
    else
    {
        saveDefaults = NO;
    }
    
    
    [_locationManager stopUpdatingLocation];
    NSString *cmpCode = [cmpCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userID = [empCompanyIDTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//empCompanyIDTF.text
    NSString *pwd = [passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//passwordTextField.text
     NSString *secureCode = [secureCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    NSLog(@"cmpCode--%@ userID--%@ pwd--%@ secureCode--%@",cmpCode,userID,pwd,secureCode);

    
    NSUserDefaults *cmpPWDDefault = [NSUserDefaults standardUserDefaults];
    [cmpPWDDefault setObject:pwd forKey:@"storedcmpPWDKey"];
    [cmpPWDDefault setObject:secureCode forKey:@"storedcmpSecureCodeKey"];
    [cmpPWDDefault synchronize];
    
    NSString *logitudeCmp = [longitudeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    longitudeStr = nil;
    NSString *latitudeCmp = [latitudeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    latitudeStr = nil;
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSString *authID = @"FF5DE32E-15E0-4CE7-A9B6-081801502CB4-CEB15C37";
    NSString *mobileName = [@"iPhone" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    [deviceIDandMobileName setObject:authID forKey:@"authIDKey"];
    [deviceIDandMobileName setObject:mobileName forKey:@"mobileNameKey"];
    [deviceIDandMobileName synchronize];

    
   NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<CheckEmpLoginMobile xmlns=\"http://tempuri.org/\">"
    "<CompanyCode>%@</CompanyCode>"
    "<empCompanyID>%@</empCompanyID>"
    "<Password>%@</Password>"
    "<secureCode>%@</secureCode>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "<mobileName>%@</mobileName>"
    "</CheckEmpLoginMobile>"
    "</soap:Body>"
    "</soap:Envelope>",cmpCode,userID,pwd,secureCode,logitudeCmp,latitudeCmp,deviceID,authID,mobileName];
    
    NSLog(@"VIEW: cmpCode--%@,userID--%@,pwd-%@,logitudeCmp--%@,latitudeCmp--%@,deviceID--%@,authID--%@,mobileName--%@",cmpCode,userID,pwd,logitudeCmp,latitudeCmp,deviceID,authID,mobileName);
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
   // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/CheckEmpLoginMobile" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if( theConnection )
    {
        webData = [NSMutableData data] ;
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    [self webServiceCallToSaveDataFailedWithError:error];
    NSLog(@"ERROR with theConenction");
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//   
//    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
//    NSLog(@"theXML: %@", theXML);
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
    xmlParser = nil;
    
}
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    [_locationManager startUpdatingLocation];
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            //alert.message=@"Attendance master cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==-1001)
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
        alert.message=@"Attendance master could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
}

#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
        _currentelementValueStr=[[NSString alloc]init];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    _currentelementValueStr = string;
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"AaSuccess1"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CmpLoginSuccessKey"];
    }
    else if ([elementName isEqualToString:@"EmpCompanyID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpCompanyIDKey"];
    }
    else if ([elementName isEqualToString:@"Designation"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpDesgnationKey"];
    }
    else if ([elementName isEqualToString:@"EmpID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpIDKey"];
    }
    else if ([elementName isEqualToString:@"BusinessFname"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpBusinessnameKey"];
    }
    else if ([elementName isEqualToString:@"BusinessLastname"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpBusinessLastnameKey"];
    }
    else if ([elementName isEqualToString:@"ShiftName"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpShiftNameKey"];
    }
    else if ([elementName isEqualToString:@"ShiftID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpShiftIDKey"];
    }
    else if ([elementName isEqualToString:@"ScheduleStart"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpScheduleStartKey"];
    }
    else if ([elementName isEqualToString:@"ScheduleEnd"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpScheduleEndKey"];
    }
    else if ([elementName isEqualToString:@"Photo"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LoginEmpPhotoKey"];
    }
    else if ([elementName isEqualToString:@"OfficeCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeCodeKey"];
    }
    else if ([elementName isEqualToString:@"CompanyCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyCodeKey"];
    }
 
    _currentelementValueStr = nil;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    NSString *empLoginSuccess = [comEmpDetailsDictionary objectForKey:@"CmpLoginSuccessKey"];
    
    if ([empLoginSuccess isEqualToString:@"Success"])
    {
         [_locationManager stopUpdatingLocation];
        NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
        [cmpEmpDetailDefaults setObject:comEmpDetailsDictionary forKey:@"comEmpDetailsDictionaryKey"];
        [cmpEmpDetailDefaults setObject:empLoginSuccess forKey:@"oneTimeLoginKey"];
        [cmpEmpDetailDefaults synchronize];
        
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"EmpDetailID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];
    }
    else if([empLoginSuccess isEqualToString:@"Failed"])
        
    {
        [_locationManager startUpdatingLocation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Unable to process the request due to Server/Network Problem" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([empLoginSuccess isEqualToString:@"Invalid"])
        
    {
        [_locationManager startUpdatingLocation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The Company code or Emp id or Password you have entered is incorrect" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([empLoginSuccess isEqualToString:@"No records found"])
        
    {
        [_locationManager startUpdatingLocation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Invalid company code,emp id and password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [_locationManager startUpdatingLocation];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:empLoginSuccess delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
