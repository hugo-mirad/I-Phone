//
//  ChangePasswordViewController.m
//  HRTest
//
//  Created by Venkata Chinni on 8/11/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    
    upperCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
    lowerCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
    
    numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
    specialCharacterSet = [[NSCharacterSet
                            characterSetWithCharactersInString:specialCharacterString] invertedSet];
    
    lowerCaseLetter  = '\0',upperCaseLetter  = '\0',digit = '\0',specialCharacter = '\0';
    
    TPKeyboardAvoidingScrollView *scrollView=[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    
    scrollView.showsVerticalScrollIndicator=YES;
    scrollView.scrollEnabled=YES;
    scrollView.userInteractionEnabled=YES;
    
  //  self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1.0];
    UIView *topNaviView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            // Load resources for iOS 6.1 or earlier
            topNaviView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            
        }
        else
        {
            
            // Load resources for iOS 7 or later
            topNaviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        }
    }
    else
    {
        topNaviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        
    }
    topNaviView.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:27.0/255.0 blue:67.0/255.0 alpha:1.0];//47, 64, 80
    [self.view addSubview:topNaviView];
    
    
    
    UIImageView *imageview = [[UIImageView alloc] init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            imageview.frame = CGRectMake(10,4, 30, 30);
        }
        else
        {
            imageview.frame = CGRectMake(10,20, 32, 32);
        }
    }
    else
    {
        imageview.frame = CGRectMake(10,20, 52, 52);
    }
    imageview.image = [UIImage imageNamed:@"brandLogo.png"];
    [topNaviView addSubview:imageview];
    
    
    
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(UserBackButtonTapped)forControlEvents:UIControlEventTouchDown];
   // [backButton setTitle:@"Back" forState:UIControlStateNormal];
     [backButton setImage:[UIImage imageNamed:@"menuicon.png"] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
  
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            backButton.frame = CGRectMake(270.0, 10.0, 40.0, 30.0);//(250.0, 10.0, 60.0, 30.0)
        }
        else
        {
            backButton.frame = CGRectMake(270.0, 20.0, 40.0, 30.0);//250.0, 20.0, 60.0, 30.0
        }
    }
    else
    {
        //backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        backButton.frame = CGRectMake(680.0, 26.0, 66.0, 44.0);
    }
    [topNaviView addSubview:backButton];
    
    
    UILabel *cmpNameLabel;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            cmpNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 8, 200, 30)];
        }
        else
        {
            cmpNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, 200, 30)];
        }
        cmpNameLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    else
    {
        cmpNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-150, 30, 300, 40)];
        cmpNameLabel.font = [UIFont boldSystemFontOfSize:24];
        
    }

    cmpNameLabel.tag = 1;
    cmpNameLabel.text = @"Change Password";
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;
    [topNaviView addSubview:cmpNameLabel];
    
    
    UIView *backView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    backView = [[UIView alloc] initWithFrame:CGRectMake(12,topNaviView.frame.size.height+ 80, self.view.frame.size.width-24, 200)];
    }
    else
    {
     backView = [[UIView alloc] initWithFrame:CGRectMake(24,topNaviView.frame.size.height+ 80, self.view.frame.size.width-48, 300)];
    }
    backView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:backView];
    backView.layer.cornerRadius = 3;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        oldPswTextField=[[UITextField alloc] initWithFrame:CGRectMake(topNaviView.frame.size.width/2-143, 20, 260, 30)];//
        oldPswTextField.font = [UIFont systemFontOfSize:13];
    }
    else
    {
        oldPswTextField=[[UITextField alloc] initWithFrame:CGRectMake(topNaviView.frame.size.width/2-180, 30, 360, 40)];//
        oldPswTextField.font = [UIFont systemFontOfSize:15];
    }
    oldPswTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    oldPswTextField.placeholder = @"Old Password";
    oldPswTextField.textAlignment=NSTextAlignmentLeft;
    oldPswTextField.textColor=[UIColor blackColor];
    oldPswTextField.secureTextEntry = YES;
    oldPswTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    oldPswTextField.returnKeyType = UIReturnKeyDone;
    oldPswTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    oldPswTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    oldPswTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [backView addSubview:oldPswTextField];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        newPswTextField=[[UITextField alloc] initWithFrame:CGRectMake(topNaviView.frame.size.width/2-143, 60, 260, 30)];//
        newPswTextField.font = [UIFont systemFontOfSize:13];
    }
    else
    {
        newPswTextField=[[UITextField alloc] initWithFrame:CGRectMake(topNaviView.frame.size.width/2-180, 80, 360, 40)];//
        newPswTextField.font = [UIFont systemFontOfSize:15];
    }
    newPswTextField.borderStyle = UITextBorderStyleRoundedRect;
    newPswTextField.font = [UIFont systemFontOfSize:13];
    newPswTextField.placeholder = @"New Password";
    newPswTextField.secureTextEntry = YES;
    newPswTextField.textAlignment=NSTextAlignmentLeft;
    newPswTextField.textColor=[UIColor blackColor];
    newPswTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    newPswTextField.returnKeyType = UIReturnKeyDone;
    newPswTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    newPswTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newPswTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [backView addSubview:newPswTextField];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        confirmpswTextField=[[UITextField alloc] initWithFrame:CGRectMake(topNaviView.frame.size.width/2-143, 100, 260, 30)];//
        confirmpswTextField.font = [UIFont systemFontOfSize:13];
    }
    else
    {
        confirmpswTextField=[[UITextField alloc] initWithFrame:CGRectMake(topNaviView.frame.size.width/2-180, 130, 360, 40)];//
        confirmpswTextField.font = [UIFont systemFontOfSize:15];
    }
    confirmpswTextField.borderStyle = UITextBorderStyleRoundedRect;
    confirmpswTextField.font = [UIFont systemFontOfSize:13];
    confirmpswTextField.placeholder = @"Confirm Password";
    confirmpswTextField.secureTextEntry = YES;
    confirmpswTextField.textAlignment=NSTextAlignmentLeft;
    confirmpswTextField.textColor=[UIColor blackColor];
    confirmpswTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    confirmpswTextField.returnKeyType = UIReturnKeyDone;
    confirmpswTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    confirmpswTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    confirmpswTextField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [backView addSubview:confirmpswTextField];
    
    
    UIButton *changePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changePasswordButton addTarget:self action:@selector(EmployeeChangePasswordButtonTapped)forControlEvents:UIControlEventTouchDown];
    [changePasswordButton setTitle:@"Update" forState:UIControlStateNormal];
    [changePasswordButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];//24, 167, 138
    [changePasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    changePasswordButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        changePasswordButton.frame = CGRectMake(topNaviView.frame.size.width/2-98, 148.0, 180.0, 30.0);
    }
    else
    {
        changePasswordButton.frame = CGRectMake(topNaviView.frame.size.width/2-110, 190.0, 220.0, 40.0);
    }
    changePasswordButton.layer.cornerRadius = 4.0;
    [backView addSubview:changePasswordButton];
    
//    
//    activityIndicator = [[UIActivityIndicatorView alloc] init];
//    activityIndicator.color = [UIColor whiteColor];
//    activityIndicator.alpha = 1.0;
//    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    activityIndicator.hidden = YES;
//    [self.view addSubview:activityIndicator];
    
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
    
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"%+.4f",
                                  newLocation.coordinate.longitude];
    
    longitudeStr = currentLongitude;
    
}
-(void)EmployeeChangePasswordButtonTapped
{
    oldPassword = oldPswTextField.text;
    newPassword = newPswTextField.text;
    NSString *confirmPassword = confirmpswTextField.text;
   
    NSUserDefaults *cmpPWDDefault = [NSUserDefaults standardUserDefaults];
    NSString *oldCmpPWD = [cmpPWDDefault objectForKey:@"empPasswordTextFielKey"];
    
//    if (oldPswTextField.text.length != 0)
//    {
    
    
    if (oldPswTextField.text.length != 0 && newPswTextField.text.length != 0 &&  confirmPassword.length !=0 )
    {
        if ([oldPassword isEqualToString:oldCmpPWD])
        {
            if(confirmpswTextField.text.length >= 5 && confirmpswTextField.text.length <= 10 &&  newPswTextField.text.length >= 5 && newPswTextField.text.length <= 10)
            {

                if ([confirmpswTextField.text rangeOfCharacterFromSet:upperCaseChars].location != NSNotFound && [confirmpswTextField.text rangeOfCharacterFromSet:lowerCaseChars].location != NSNotFound &&  [confirmpswTextField.text rangeOfCharacterFromSet:numbers].location != NSNotFound && [confirmpswTextField.text rangeOfCharacterFromSet:specialCharacterSet].location != NSNotFound)
                {
                
                    if ([newPswTextField.text isEqualToString:confirmpswTextField.text])
                    {
                        
                        [self ChangePasswordImplementation];
                        
                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        self.view.userInteractionEnabled = NO;
                        self.view.userInteractionEnabled = NO;

                        
                        
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"New and Confirm Password must be same" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    }

                    
                    
                    
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"Please Ensure that you have at least one lower case letter, one upper case letter, one digit and one special character in Password"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
                
                
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Password must be 5 to 10 charecters and at least one lower case letter, one upper case letter, one digit and one special character in Password"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        
        }
        else
            
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"We didn't findout ur password with us" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }

        
        
    }
    else if(oldPswTextField.text.length == 0 && newPswTextField.text.length == 0 &&  confirmpswTextField.text.length ==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if(oldPswTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Old Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if(newPswTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter New Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if(confirmpswTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter confirm Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }

    
//    
//    
//    
//    
//    
//    
//    
//    if (oldPswTextField.text.length != 0 && newPswTextField.text.length != 0 &&  confirmPassword.length !=0 )
//        {
//            
//
//            if ([oldPassword isEqualToString:oldCmpPWD])
//            {
//                if ([newPswTextField.text isEqualToString:confirmpswTextField.text])
//                {
//
//                    if(confirmpswTextField.text.length >= 5 && confirmpswTextField.text.length <= 10 &&  newPswTextField.text.length >= 5 && newPswTextField.text.length <= 10)
//                    {
//                    
//                    
//                    if ([confirmpswTextField.text rangeOfCharacterFromSet:upperCaseChars].location != NSNotFound && [confirmpswTextField.text rangeOfCharacterFromSet:lowerCaseChars].location != NSNotFound &&  [confirmpswTextField.text rangeOfCharacterFromSet:numbers].location != NSNotFound && [confirmpswTextField.text rangeOfCharacterFromSet:specialCharacterSet].location != NSNotFound)
//                    {
//                        
//                        [self ChangePasswordImplementation];
//                        
//                        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                        self.view.userInteractionEnabled = NO;
//                            self.view.userInteractionEnabled = NO;
//                            
//                            
//                    }
//                    else
//                    {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                                        message:@"Please Ensure that you have at least one lower case letter, one upper case letter, one digit and one special character in Password"
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    }
//                    
//                    
//                    
//                    
//                }
//                else
//                {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                                    message:@"Password must be 5 to 10 charecters and at least one lower case letter, one upper case letter, one digit and one special character in Password"
//                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
//                }
//
//            }
//            else
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"New and Confirm Password must be same" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//            
//            
//            
//        }
//            else
//                
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"We didn't findout ur password with us" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//            
//        
//
//         
//      
//    }
//   else if(oldPswTextField.text.length == 0 && newPswTextField.text.length == 0 &&  confirmpswTextField.text.length ==0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//    
//    else if(oldPswTextField.text.length == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Old Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        
//    }
//    else if(newPswTextField.text.length == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter New Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//        
//    }
//    else if(confirmpswTextField.text.length == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter confirm Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//   
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter Old Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    
}

-(void)ChangePasswordImplementation
{
    

    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    NSString *empID = [_CmpEmpDetailsDic objectForKey:@"LoginEmpIDKey"];
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *signInDateWithTimeStr =[dateFormatter stringFromDate:date];
  
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    NSString *oldPasswordStr = oldPassword;
    NSString *newPasswordStr = newPassword;

    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
   " <soap:Body>"
    "<UpdatePasswordByEmpID xmlns=\"http://tempuri.org/\">"
    "<EmpID>%@</EmpID>"
    "<OldPassword>%@</OldPassword>"
    "<NewPassword>%@</NewPassword>"
    "<CompanyCode>%@</CompanyCode>"
    "<UpdatedBy>%@</UpdatedBy>"
    "<UpdatedDate>%@</UpdatedDate>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<mobileName>%@</mobileName>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "</UpdatePasswordByEmpID>"
    "</soap:Body>"
    "</soap:Envelope>",empCmpyID,oldPasswordStr,newPasswordStr,cmpCode,empID,signInDateWithTimeStr,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
   // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/UpdatePasswordByEmpID" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if( conn )
    {
        webData = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }

        
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self webServiceCallToSaveDataFailedWithError:error];
    NSLog(@"ERROR with theConenction");
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSString *strXMl = [[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"XML is : %@", strXMl);
    
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
}
#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"UpdatePasswordByEmpIDResult"])
    {
        
        //resultString = [[NSString alloc]init];
    }
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    resultString = [[NSMutableString alloc]initWithString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"UpdatePasswordByEmpIDResult"])
    {
        
        resultStr =  [resultString copy];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Successfully changed your Password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];;
//       
//       [alert show];
        
        
    }
    
}
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;

    if ([resultStr isEqualToString:@"Updated"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Successfully Updated your Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];;
        
        [alert show];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:resultStr delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];;
        
        [alert show];
    }
 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {
        
        NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
         [cmpEmpDetailDefaults removeObjectForKey:@"oneTimeLoginKey"];
        
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:NO];
        
    }
}


- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"Attendance master cannot retrieve data as it is not connected to the Internet.";
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




-(void)UserBackButtonTapped
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
