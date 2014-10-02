//
//  UserProfileViewController.m
//  HR
//
//  Created by Venkata Chinni on 7/31/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "UserProfileViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MBProgressHUD.h"
//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

@interface UserProfileViewController ()


@property(copy,nonatomic) NSString *currentelementValueStr;



@end

@implementation UserProfileViewController

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
    
    //self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1.0];
    typeofParsing = 1;
    
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    comEmpDetailsDictionary = [[NSMutableDictionary alloc] init];
    
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
    
    
    
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(UserBackButtonTapped)forControlEvents:UIControlEventTouchDown];
    //[backButton setTitle:@"Back" forState:UIControlStateNormal];
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
    cmpNameLabel.text = @"My profile";
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;
    [topNaviView addSubview:cmpNameLabel];
    
    
    TPKeyboardAvoidingScrollView *scrollView;
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        // Load resources for iOS 6.1 or earlier
       scrollView =[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, topNaviView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-topNaviView.frame.size.height)];
        
    } else {
        // Load resources for iOS 7 or later
        scrollView =[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, topNaviView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-topNaviView.frame.size.height)];
    }
    [self.view addSubview:scrollView];
    
    
    
    //Employee Details
    UIView *EmpDetailView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        EmpDetailView = [[UIView alloc] initWithFrame:CGRectMake(12, 10, self.view.frame.size.width-24, 490)];
    }
    else
    {
        EmpDetailView = [[UIView alloc] initWithFrame:CGRectMake(24, 10, self.view.frame.size.width-48, 490)];
    }
    
    EmpDetailView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:EmpDetailView];
    
    EmpDetailView.layer.cornerRadius = 3;
    EmpDetailView.layer.shadowOffset = CGSizeMake(0, 0);
    EmpDetailView.layer.shadowColor = [[UIColor blackColor] CGColor];
    EmpDetailView.layer.shadowRadius = 1;
    EmpDetailView.layer.shadowOpacity = 0.50;
    
    UILabel *empDetailLbl = [[UILabel alloc] init];
    empDetailLbl.text = @"Employee Details";
    empDetailLbl.frame =  CGRectMake(10, 2, 280, 30);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    empDetailLbl.font = [UIFont boldSystemFontOfSize:14];
    empDetailLbl.textAlignment = NSTextAlignmentLeft;
    empDetailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    empDetailLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:empDetailLbl];
    
    
//    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [editButton addTarget:self action:@selector(EmployeeEditButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
//    [editButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    editButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    editButton.frame = CGRectMake(self.view.frame.size.width-60, 5.0, 40.0, 20.0);
//    editButton.layer.cornerRadius = 2.0;
//    [EmpDetailView addSubview:editButton];
    
    
//    EmpSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [EmpSaveButton addTarget:self action:@selector(EmployeeSaveButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [EmpSaveButton setTitle:@"Save" forState:UIControlStateNormal];
//    [EmpSaveButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [EmpSaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    EmpSaveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    EmpSaveButton.frame = CGRectMake(self.view.frame.size.width-editButton.frame.size.width-70, 5.0, 40.0, 20.0);
//    EmpSaveButton.hidden = YES;
//    EmpSaveButton.layer.cornerRadius = 2.0;
//    [EmpDetailView addSubview:EmpSaveButton];
//    
//    
//    EmpCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [EmpCancelButton addTarget:self action:@selector(EmployeeCancelButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [EmpCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [EmpCancelButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [EmpCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    EmpCancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    EmpCancelButton.frame = CGRectMake(self.view.frame.size.width-editButton.frame.size.width-EmpSaveButton.frame.size.width-80, 5.0, 40.0, 20.0);
//    EmpCancelButton.hidden = YES;
//    EmpCancelButton.layer.cornerRadius = 2.0;
//    [EmpDetailView addSubview:EmpCancelButton];
    
    UILabel *deviderlbl;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        deviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width-24, 1)];
    }
    else
    {
        deviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width-48, 1)];
    }
    
    deviderlbl.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];//(238,238,238)
    [EmpDetailView addSubview:deviderlbl];
    
    
    //UIImageView *preArrowImage =[[UIImageView alloc]init ];
    AsyncImageView *preArrowImage = [[AsyncImageView alloc]init];
    //preArrowImage.image =[UIImage imageNamed:@"user.png"];
    preArrowImage.frame = CGRectMake(20, 40, 100, 100);
    preArrowImage.tag = 2;
    [EmpDetailView addSubview:preArrowImage];
    
    preArrowImage.layer.shadowOffset = CGSizeMake(0, 2);
    preArrowImage.layer.shadowOpacity = 0.25;
    preArrowImage.layer.cornerRadius = 2.0;
    preArrowImage.layer.borderWidth = 3.0;
    preArrowImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    // preArrowImage.layer.shadowColor = [UIColor purpleColor].CGColor;
    
    
//    UIButton *ResetPasscodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [ResetPasscodeButton addTarget:self action:@selector(ResetPasscodeButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [ResetPasscodeButton setTitle:@"Reset passcode" forState:UIControlStateNormal];
//    [ResetPasscodeButton setBackgroundColor:[UIColor colorWithRed:24.0/255.0 green:167.0/255.0 blue:138.0/255.0 alpha:1.0]];//24, 167, 138
//    [ResetPasscodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    ResetPasscodeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
//    ResetPasscodeButton.frame = CGRectMake(preArrowImage.frame.size.width+40, 54.0, 120.0, 26.0);
//    ResetPasscodeButton.layer.cornerRadius = 2.0;
//    [EmpDetailView addSubview:ResetPasscodeButton];
//    
//    
//    UIButton *ResetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [ResetPasswordButton addTarget:self action:@selector(ResetPasswordButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [ResetPasswordButton setTitle:@"Reset password" forState:UIControlStateNormal];
//    [ResetPasswordButton setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:83.0/255.0 blue:82.0/255.0 alpha:1.0]];//24, 167, 138
//    [ResetPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    ResetPasswordButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
//    ResetPasswordButton.frame = CGRectMake(preArrowImage.frame.size.width+40, 90.0, 120.0, 26.0);
//    ResetPasswordButton.layer.cornerRadius = 2.0;
//    [EmpDetailView addSubview:ResetPasswordButton];
    
    
    UILabel *empIDLbl = [[UILabel alloc] init];
    empIDLbl.text = @"EmpID ";
    empIDLbl.frame =  CGRectMake(20, 150, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    empIDLbl.font = [UIFont boldSystemFontOfSize:13];
    empIDLbl.textAlignment = NSTextAlignmentLeft;
    empIDLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    empIDLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:empIDLbl];
    
    UILabel *empIDValueLbl = [[UILabel alloc] init];
    //empIDValueLbl.text = @"HM107 ";
    empIDValueLbl.tag  = 3;
    empIDValueLbl.frame =  CGRectMake(130, 150, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    empIDValueLbl.font = [UIFont systemFontOfSize:12];
    empIDValueLbl.textAlignment = NSTextAlignmentLeft;
    empIDValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    empIDValueLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:empIDValueLbl];
    
    
    
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.text = @"Name ";
    nameLbl.frame =  CGRectMake(20, 180, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    nameLbl.font = [UIFont boldSystemFontOfSize:13];
    nameLbl.textAlignment = NSTextAlignmentLeft;
    nameLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    nameLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:nameLbl];
    
    nameValueLbl = [[UILabel alloc] init];
    //nameValueLbl.text = @"MC Smith ";
    nameValueLbl.tag = 4;
    nameValueLbl.frame =  CGRectMake(130, 180, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    nameValueLbl.font = [UIFont systemFontOfSize:12];
    nameValueLbl.textAlignment = NSTextAlignmentLeft;
    nameValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    nameValueLbl.backgroundColor = [UIColor clearColor];
    nameValueLbl.hidden = NO;
    [EmpDetailView addSubview:nameValueLbl];
    
    //Edit textfield for Emp name
    empDetailNameTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 180, 180, 28)]; //80, 230, 220, 30
    empDetailNameTF.placeholder = @"Enter Employee Name";
    empDetailNameTF.backgroundColor=[UIColor clearColor];
    empDetailNameTF.borderStyle=UITextBorderStyleRoundedRect;
    empDetailNameTF.font=[UIFont systemFontOfSize:13];
    empDetailNameTF.textColor = [UIColor blackColor];
    empDetailNameTF.textAlignment=NSTextAlignmentLeft;
    empDetailNameTF.autocorrectionType=UITextAutocorrectionTypeNo;
    empDetailNameTF.keyboardType=UIKeyboardTypeDefault;
    empDetailNameTF.returnKeyType=UIReturnKeyDone;
    empDetailNameTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    empDetailNameTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //empDetailNameTF.tag=3;
    empDetailNameTF.hidden = YES;
    empDetailNameTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:empDetailNameTF];
   
    
    UILabel *businessNameLbl = [[UILabel alloc] init];
    businessNameLbl.text = @"Bussiness Name ";
    businessNameLbl.frame =  CGRectMake(20, 210, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    businessNameLbl.font = [UIFont boldSystemFontOfSize:13];
    businessNameLbl.textAlignment = NSTextAlignmentLeft;
    businessNameLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    businessNameLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:businessNameLbl];
    
    businessNameValueLbl = [[UILabel alloc] init];
   // businessNameValueLbl.text = @"Smith ";
    businessNameValueLbl.tag = 5;
    businessNameValueLbl.frame =  CGRectMake(130, 210, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    businessNameValueLbl.font = [UIFont systemFontOfSize:12];
    businessNameValueLbl.textAlignment = NSTextAlignmentLeft;
    businessNameValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    businessNameValueLbl.backgroundColor = [UIColor clearColor];
    businessNameValueLbl.hidden = NO;
    [EmpDetailView addSubview:businessNameValueLbl];
    
    
    //Edit textfield for Business name
    businessNameTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 210, 180, 28)]; //80, 230, 220, 30
    businessNameTF.placeholder = @"Enter Business Name";
    businessNameTF.backgroundColor=[UIColor clearColor];
    businessNameTF.borderStyle=UITextBorderStyleRoundedRect;
    businessNameTF.font=[UIFont systemFontOfSize:13];
    businessNameTF.textColor = [UIColor blackColor];
    businessNameTF.textAlignment=NSTextAlignmentLeft;
    businessNameTF.autocorrectionType=UITextAutocorrectionTypeNo;
    businessNameTF.keyboardType=UIKeyboardTypeDefault;
    businessNameTF.returnKeyType=UIReturnKeyDone;
    businessNameTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    businessNameTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //businessNameTF.tag=3;
    businessNameTF.hidden = YES;
    businessNameTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:businessNameTF];
    
    
    UILabel *empTypeLbl = [[UILabel alloc] init];
    empTypeLbl.text = @"Emp Type ";
    empTypeLbl.frame =  CGRectMake(20, 240, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    empTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    empTypeLbl.textAlignment = NSTextAlignmentLeft;
    empTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    empTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:empTypeLbl];
    
    empTypeValueLbl = [[UILabel alloc] init];
   // empTypeValueLbl.text = @"Employee ";
    empTypeValueLbl.tag = 6;
    empTypeValueLbl.frame =  CGRectMake(130, 240, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    empTypeValueLbl.font = [UIFont systemFontOfSize:12];
    empTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    empTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    empTypeValueLbl.backgroundColor = [UIColor clearColor];
    empTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:empTypeValueLbl];
    
    //Edit textfield for Employee Type
    empTypeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 240, 180, 28)]; //80, 230, 220, 30
    empTypeTF.placeholder = @"Enter Employee Type";
    empTypeTF.backgroundColor=[UIColor clearColor];
    empTypeTF.borderStyle=UITextBorderStyleRoundedRect;
    empTypeTF.font=[UIFont systemFontOfSize:13];
    empTypeTF.textColor = [UIColor blackColor];
    empTypeTF.textAlignment=NSTextAlignmentLeft;
    empTypeTF.autocorrectionType=UITextAutocorrectionTypeNo;
    empTypeTF.keyboardType=UIKeyboardTypeDefault;
    empTypeTF.returnKeyType=UIReturnKeyDone;
    empTypeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    empTypeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
   // empTypeTF.tag=3;
    empTypeTF.hidden = YES;
    empTypeTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:empTypeTF];

    
    UILabel *depmntTypeLbl = [[UILabel alloc] init];
    depmntTypeLbl.text = @"Department ";
    depmntTypeLbl.frame =  CGRectMake(20, 270, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    depmntTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    depmntTypeLbl.textAlignment = NSTextAlignmentLeft;
    depmntTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    depmntTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:depmntTypeLbl];
    
    depmntTypeValueLbl = [[UILabel alloc] init];
    //depmntTypeValueLbl.text = @"Software development ";
    depmntTypeValueLbl.tag = 7;
    depmntTypeValueLbl.frame =  CGRectMake(130, 270, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    depmntTypeValueLbl.font = [UIFont systemFontOfSize:12];
    depmntTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    depmntTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    depmntTypeValueLbl.backgroundColor = [UIColor clearColor];
    depmntTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:depmntTypeValueLbl];
    
    
    
    //Edit textfield for department Type
    depmntTypeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 270, 180, 28)]; //80, 230, 220, 30
    depmntTypeTF.placeholder = @"Enter Department Type";
    depmntTypeTF.backgroundColor=[UIColor clearColor];
    depmntTypeTF.borderStyle=UITextBorderStyleRoundedRect;
    depmntTypeTF.font=[UIFont systemFontOfSize:13];
    depmntTypeTF.textColor = [UIColor blackColor];
    depmntTypeTF.textAlignment=NSTextAlignmentLeft;
    depmntTypeTF.autocorrectionType=UITextAutocorrectionTypeNo;
    depmntTypeTF.keyboardType=UIKeyboardTypeDefault;
    depmntTypeTF.returnKeyType=UIReturnKeyDone;
    depmntTypeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    depmntTypeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
   // depmntTypeTF.tag=3;
    depmntTypeTF.hidden = YES;
    depmntTypeTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:depmntTypeTF];

    
    
    UILabel *shiftTypeLbl = [[UILabel alloc] init];
    shiftTypeLbl.text = @"Shift ";
    shiftTypeLbl.frame =  CGRectMake(20, 300, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    shiftTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    shiftTypeLbl.textAlignment = NSTextAlignmentLeft;
    shiftTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    shiftTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:shiftTypeLbl];
    
    shiftTypeValueLbl = [[UILabel alloc] init];
    //shiftTypeValueLbl.text = @"Shift A ";
    shiftTypeValueLbl.tag = 8;
    shiftTypeValueLbl.frame =  CGRectMake(130, 300, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    shiftTypeValueLbl.font = [UIFont systemFontOfSize:12];
    shiftTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    shiftTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    shiftTypeValueLbl.backgroundColor = [UIColor clearColor];
    shiftTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:shiftTypeValueLbl];
    
    
    
    //Edit textfield for Shift Type
    shiftTypeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 300, 180, 28)]; //80, 230, 220, 30
    shiftTypeTF.placeholder = @"Enter Shift Type";
    shiftTypeTF.backgroundColor=[UIColor clearColor];
    shiftTypeTF.borderStyle=UITextBorderStyleRoundedRect;
    shiftTypeTF.font=[UIFont systemFontOfSize:13];
    shiftTypeTF.textColor = [UIColor blackColor];
    shiftTypeTF.textAlignment=NSTextAlignmentLeft;
    shiftTypeTF.autocorrectionType=UITextAutocorrectionTypeNo;
    shiftTypeTF.keyboardType=UIKeyboardTypeDefault;
    shiftTypeTF.returnKeyType=UIReturnKeyDone;
    shiftTypeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    shiftTypeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
   // shiftTypeTF.tag=3;
    shiftTypeTF.hidden = YES;
    shiftTypeTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:shiftTypeTF];
    
    
    
    UILabel *scheduleTypeLbl = [[UILabel alloc] init];
    scheduleTypeLbl.text = @"Schedule ";
    scheduleTypeLbl.frame =  CGRectMake(20, 330, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    scheduleTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    scheduleTypeLbl.textAlignment = NSTextAlignmentLeft;
    scheduleTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    scheduleTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:scheduleTypeLbl];
    
    scheduleTypeValueLbl = [[UILabel alloc] init];
   // scheduleTypeValueLbl.text = @"9:00AM-6:00PM";
    scheduleTypeValueLbl.tag = 9;
    scheduleTypeValueLbl.frame =  CGRectMake(130, 330, 180, 28);
    scheduleTypeValueLbl.numberOfLines = 0;
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    scheduleTypeValueLbl.font = [UIFont systemFontOfSize:12];
    scheduleTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    scheduleTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    scheduleTypeValueLbl.backgroundColor = [UIColor clearColor];
    scheduleTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:scheduleTypeValueLbl];
    
    
    //Edit textfield for schedule Time
    scheduleTimeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 330, 180, 28)]; //80, 230, 220, 30
    scheduleTimeTF.placeholder = @"Enter Schedule time Type";
    scheduleTimeTF.backgroundColor=[UIColor clearColor];
    scheduleTimeTF.borderStyle=UITextBorderStyleRoundedRect;
    scheduleTimeTF.font=[UIFont systemFontOfSize:13];
    scheduleTimeTF.textColor = [UIColor blackColor];
    scheduleTimeTF.textAlignment=NSTextAlignmentLeft;
    scheduleTimeTF.autocorrectionType=UITextAutocorrectionTypeNo;
    scheduleTimeTF.keyboardType=UIKeyboardTypeDefault;
    scheduleTimeTF.returnKeyType=UIReturnKeyDone;
    scheduleTimeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    scheduleTimeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //scheduleTimeTF.tag=3;
    scheduleTimeTF.hidden = YES;
    scheduleTimeTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:scheduleTimeTF];

    
    
    UILabel *lunchTimeLbl = [[UILabel alloc] init];
    lunchTimeLbl.text = @"Lunch break ";
    lunchTimeLbl.frame =  CGRectMake(20, 360, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    lunchTimeLbl.font = [UIFont boldSystemFontOfSize:13];
    lunchTimeLbl.textAlignment = NSTextAlignmentLeft;
    lunchTimeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    lunchTimeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:lunchTimeLbl];
    
    lunchTimeValueLbl = [[UILabel alloc] init];
    //lunchTimeValueLbl.text = @"1:00PM-2:00PM ";
    lunchTimeValueLbl.tag = 10;
    lunchTimeValueLbl.frame =  CGRectMake(130, 360, 180, 28);
    lunchTimeValueLbl.numberOfLines = 0;
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    lunchTimeValueLbl.font = [UIFont systemFontOfSize:12];
    lunchTimeValueLbl.textAlignment = NSTextAlignmentLeft;
    lunchTimeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    lunchTimeValueLbl.backgroundColor = [UIColor clearColor];
    lunchTimeValueLbl.hidden = NO;
    [EmpDetailView addSubview:lunchTimeValueLbl];
    
    
    UILabel *designationTypeLbl = [[UILabel alloc] init];
    designationTypeLbl.text = @"Designation ";
    designationTypeLbl.frame =  CGRectMake(20, 390, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    designationTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    designationTypeLbl.textAlignment = NSTextAlignmentLeft;
    designationTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    designationTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:designationTypeLbl];
    
    designationTypeValueLbl = [[UILabel alloc] init];
   // designationTypeValueLbl.text = @"Junior Software Engineer ";
    designationTypeValueLbl.tag = 11;
    designationTypeValueLbl.frame =  CGRectMake(130, 390, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    designationTypeValueLbl.font = [UIFont systemFontOfSize:12];
    designationTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    designationTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    designationTypeValueLbl.backgroundColor = [UIColor clearColor];
    designationTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:designationTypeValueLbl];
    
    
    //Edit textfield for designation Type
    designationTypeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 390, 180, 28)]; //80, 230, 220, 30
    designationTypeTF.placeholder = @"Enter Designation";
    designationTypeTF.backgroundColor=[UIColor clearColor];
    designationTypeTF.borderStyle=UITextBorderStyleRoundedRect;
    designationTypeTF.font=[UIFont systemFontOfSize:13];
    designationTypeTF.textColor = [UIColor blackColor];
    designationTypeTF.textAlignment=NSTextAlignmentLeft;
    designationTypeTF.autocorrectionType=UITextAutocorrectionTypeNo;
    designationTypeTF.keyboardType=UIKeyboardTypeDefault;
    designationTypeTF.returnKeyType=UIReturnKeyDone;
    designationTypeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    designationTypeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //designationTypeTF.tag=3;
    designationTypeTF.hidden = YES;
    designationTypeTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:designationTypeTF];
    
    
    UILabel *startDateTypeLbl = [[UILabel alloc] init];
    startDateTypeLbl.text = @"Start date ";
    startDateTypeLbl.frame =  CGRectMake(20, 420, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    startDateTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    startDateTypeLbl.textAlignment = NSTextAlignmentLeft;
    startDateTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    startDateTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:startDateTypeLbl];
    
    startDateTypeValueLbl = [[UILabel alloc] init];
   // startDateTypeValueLbl.text = @"No value from server ";
    startDateTypeValueLbl.tag = 12;
    startDateTypeValueLbl.frame =  CGRectMake(130, 420, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    startDateTypeValueLbl.font = [UIFont systemFontOfSize:12];
    startDateTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    startDateTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    startDateTypeValueLbl.backgroundColor = [UIColor clearColor];
    startDateTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:startDateTypeValueLbl];
    
    
    
    //Edit textfield for Start date
    startdateTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 420, 180, 28)]; //80, 230, 220, 30
    startdateTF.placeholder = @"Enter Strat date";
    startdateTF.backgroundColor=[UIColor clearColor];
    startdateTF.borderStyle=UITextBorderStyleRoundedRect;
    startdateTF.font=[UIFont systemFontOfSize:13];
    startdateTF.textColor = [UIColor blackColor];
    startdateTF.textAlignment=NSTextAlignmentLeft;
    startdateTF.autocorrectionType=UITextAutocorrectionTypeNo;
    startdateTF.keyboardType=UIKeyboardTypeDefault;
    startdateTF.returnKeyType=UIReturnKeyDone;
    startdateTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    startdateTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //startdateTF.tag=3;
    startdateTF.hidden = YES;
    startdateTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:startdateTF];
    
    
    UILabel *activeTypeLbl = [[UILabel alloc] init];
    activeTypeLbl.text = @"Status ";
    activeTypeLbl.frame =  CGRectMake(20, 450, 110, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    activeTypeLbl.font = [UIFont boldSystemFontOfSize:13];
    activeTypeLbl.textAlignment = NSTextAlignmentLeft;
    activeTypeLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    startDateTypeLbl.backgroundColor = [UIColor clearColor];
    [EmpDetailView addSubview:activeTypeLbl];
    
    activeTypeValueLbl = [[UILabel alloc] init];
   // activeTypeValueLbl.text = @"Yes ";
    activeTypeValueLbl.tag = 13;
    activeTypeValueLbl.frame =  CGRectMake(130, 450, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    activeTypeValueLbl.font = [UIFont systemFontOfSize:12];
    activeTypeValueLbl.textAlignment = NSTextAlignmentLeft;
    activeTypeValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    activeTypeValueLbl.backgroundColor = [UIColor clearColor];
    activeTypeValueLbl.hidden = NO;
    [EmpDetailView addSubview:activeTypeValueLbl];
    
    
    
    //Edit textfield for Start date
    activeTypeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 450, 180, 28)]; //80, 230, 220, 30
    activeTypeTF.placeholder = @"Enter Active status";
    activeTypeTF.backgroundColor=[UIColor clearColor];
    activeTypeTF.borderStyle=UITextBorderStyleRoundedRect;
    activeTypeTF.font=[UIFont systemFontOfSize:13];
    activeTypeTF.textColor = [UIColor blackColor];
    activeTypeTF.textAlignment=NSTextAlignmentLeft;
    activeTypeTF.autocorrectionType=UITextAutocorrectionTypeNo;
    activeTypeTF.keyboardType=UIKeyboardTypeDefault;
    activeTypeTF.returnKeyType=UIReturnKeyDone;
    activeTypeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    activeTypeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //activeTypeTF.tag=3;
    activeTypeTF.hidden = YES;
    activeTypeTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [EmpDetailView addSubview:activeTypeTF];

    
    //Personal Details
    
    UIView *personalDetailView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        personalDetailView = [[UIView alloc] initWithFrame:CGRectMake(12, 510, self.view.frame.size.width-24, 290)];
    }
    else
    {
        personalDetailView = [[UIView alloc] initWithFrame:CGRectMake(24, 510, self.view.frame.size.width-48, 290)];
    }
    
    personalDetailView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:personalDetailView];
    personalDetailView.layer.cornerRadius = 3;
    
    personalDetailView.layer.shadowOffset = CGSizeMake(0, 0);
    personalDetailView.layer.shadowColor = [[UIColor blackColor] CGColor];
    personalDetailView.layer.shadowRadius = 1;
    personalDetailView.layer.shadowOpacity = 0.50;
    
    UILabel *persDetailLbl = [[UILabel alloc] init];
    persDetailLbl.text = @"Personal Details";
    persDetailLbl.frame =  CGRectMake(10, 2, 280, 30);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    persDetailLbl.font = [UIFont boldSystemFontOfSize:14];
    persDetailLbl.textAlignment = NSTextAlignmentLeft;
    persDetailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    persDetailLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:persDetailLbl];
    
    
//    UIButton *persButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [persButton addTarget:self action:@selector(PersonEditButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [persButton setTitle:@"Edit" forState:UIControlStateNormal];
//    [persButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [persButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    persButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    persButton.frame = CGRectMake(self.view.frame.size.width-60, 5.0, 40.0, 20.0);
//    [personalDetailView addSubview:persButton];
//    
//    
//    
//    
//    
//    persDetailSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [persDetailSaveButton addTarget:self action:@selector(persDetailSaveButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [persDetailSaveButton setTitle:@"Save" forState:UIControlStateNormal];
//    [persDetailSaveButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [persDetailSaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    persDetailSaveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    persDetailSaveButton.frame = CGRectMake(self.view.frame.size.width-editButton.frame.size.width-70, 5.0, 40.0, 20.0);
//    persDetailSaveButton.hidden = YES;
//    [personalDetailView addSubview:persDetailSaveButton];
//    
//    
//    persDetailCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [persDetailCancelButton addTarget:self action:@selector(PersonCancelButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [persDetailCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//    [persDetailCancelButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [persDetailCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    persDetailCancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    persDetailCancelButton.frame = CGRectMake(self.view.frame.size.width-editButton.frame.size.width-EmpSaveButton.frame.size.width-80, 5.0, 40.0, 20.0);
//    persDetailCancelButton.hidden = YES;
//    [personalDetailView addSubview:persDetailCancelButton];
//
    UILabel *persdeviderlbl;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
         persdeviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width-24, 1)];
    }
    else
    {
         persdeviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width-48, 1)];
        
    }
   
    persdeviderlbl.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];//(238,238,238)
    [personalDetailView addSubview:persdeviderlbl];

    
//    UILabel *perGendLbl = [[UILabel alloc] init];
//    perGendLbl.text = @"Gender ";
//    perGendLbl.frame =  CGRectMake(20, 40, 60, 28);
//    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
//    perGendLbl.font = [UIFont boldSystemFontOfSize:13];
//    perGendLbl.textAlignment = NSTextAlignmentLeft;
//    perGendLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    perGendLbl.backgroundColor = [UIColor clearColor];
//    [personalDetailView addSubview:perGendLbl];
//    
//    perGendValueLbl = [[UILabel alloc] init];
//    //perGendValueLbl.text = @"Male ";
//    perGendValueLbl.tag = 14;
//    perGendValueLbl.frame =  CGRectMake(130, 40, 180, 28);
//    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
//    perGendValueLbl.font = [UIFont systemFontOfSize:12];
//    perGendValueLbl.textAlignment = NSTextAlignmentLeft;
//    perGendValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    perGendValueLbl.backgroundColor = [UIColor clearColor];
//    perGendValueLbl.hidden = NO;
//    [personalDetailView addSubview:perGendValueLbl];
    
    
    
    
//    //Person Details Edit textfield for Gender
//    perGendTypeTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 40, 180, 28)]; //80, 230, 220, 30
//    perGendTypeTF.placeholder = @"Enter Active status";
//    perGendTypeTF.backgroundColor=[UIColor clearColor];
//    perGendTypeTF.borderStyle=UITextBorderStyleRoundedRect;
//    perGendTypeTF.font=[UIFont systemFontOfSize:13];
//    perGendTypeTF.textColor = [UIColor blackColor];
//    perGendTypeTF.textAlignment=NSTextAlignmentLeft;
//    perGendTypeTF.autocorrectionType=UITextAutocorrectionTypeNo;
//    perGendTypeTF.keyboardType=UIKeyboardTypeDefault;
//    perGendTypeTF.returnKeyType=UIReturnKeyDone;
//    perGendTypeTF.clearButtonMode=UITextFieldViewModeWhileEditing;
//    perGendTypeTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//   // perGendTypeTF.tag=3;
//    perGendTypeTF.hidden = YES;
//    perGendTypeTF.delegate=self;
//    //self.phoneNumberTextField.userInteractionEnabled = NO;
//    [personalDetailView addSubview:perGendTypeTF];
    
    
    
    
    UILabel *perDBLbl = [[UILabel alloc] init];
    perDBLbl.text = @"Date of birth";
    perDBLbl.frame =  CGRectMake(20, 40, 100, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    perDBLbl.font = [UIFont boldSystemFontOfSize:13];
    perDBLbl.textAlignment = NSTextAlignmentLeft;
    perDBLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    perDBLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:perDBLbl];
    
    perDBValueLbl = [[UILabel alloc] init];
   // perDBValueLbl.text = @"18/03/1988 ";
    perDBValueLbl.tag = 15;
    perDBValueLbl.frame =  CGRectMake(130, 40, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    perDBValueLbl.font = [UIFont systemFontOfSize:12];
    perDBValueLbl.textAlignment = NSTextAlignmentLeft;
    perDBValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    perDBValueLbl.backgroundColor = [UIColor clearColor];
    perDBValueLbl.hidden = NO;
    [personalDetailView addSubview:perDBValueLbl];
    
    
    //Person Details Edit textfield for person Date of Birth
    perDBValueTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 40, 180, 28)]; //80, 230, 220, 30
    perDBValueTF.placeholder = @"Enter Active status";
    perDBValueTF.backgroundColor=[UIColor clearColor];
    perDBValueTF.borderStyle=UITextBorderStyleRoundedRect;
    perDBValueTF.font=[UIFont systemFontOfSize:13];
    perDBValueTF.textColor = [UIColor blackColor];
    perDBValueTF.textAlignment=NSTextAlignmentLeft;
    perDBValueTF.autocorrectionType=UITextAutocorrectionTypeNo;
    perDBValueTF.keyboardType=UIKeyboardTypeDefault;
    perDBValueTF.returnKeyType=UIReturnKeyDone;
    perDBValueTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    perDBValueTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //perDBValueTF.tag=3;
    perDBValueTF.hidden = YES;
    perDBValueTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [personalDetailView addSubview:perDBValueTF];
    
    
    UILabel *phNumLbl = [[UILabel alloc] init];
    phNumLbl.text = @"Phone#";
    phNumLbl.frame =  CGRectMake(20, 70, 100, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    phNumLbl.font = [UIFont boldSystemFontOfSize:13];
    phNumLbl.textAlignment = NSTextAlignmentLeft;
    phNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    phNumLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:phNumLbl];
    
    phNumValueLbl = [[UILabel alloc] init];
    //phNumValueLbl.text = @"123-456-7890 ";
    phNumValueLbl.tag = 16;
    phNumValueLbl.frame =  CGRectMake(130, 70, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    phNumValueLbl.font = [UIFont systemFontOfSize:12];
    phNumValueLbl.textAlignment = NSTextAlignmentLeft;
    phNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    phNumValueLbl.backgroundColor = [UIColor clearColor];
    phNumValueLbl.hidden = NO;
    [personalDetailView addSubview:phNumValueLbl];
    
    
    //Person Details Edit textfield for phone number of Birth
    phNumValueTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 70, 180, 28)]; //80, 230, 220, 30
    phNumValueTF.placeholder = @"Enter Active status";
    phNumValueTF.backgroundColor=[UIColor clearColor];
    phNumValueTF.borderStyle=UITextBorderStyleRoundedRect;
    phNumValueTF.font=[UIFont systemFontOfSize:13];
    phNumValueTF.textColor = [UIColor blackColor];
    phNumValueTF.textAlignment=NSTextAlignmentLeft;
    phNumValueTF.autocorrectionType=UITextAutocorrectionTypeNo;
    phNumValueTF.keyboardType=UIKeyboardTypeDefault;
    phNumValueTF.returnKeyType=UIReturnKeyDone;
    phNumValueTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    phNumValueTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
   // phNumValueTF.tag=3;
    phNumValueTF.hidden = YES;
    phNumValueTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [personalDetailView addSubview:phNumValueTF];
    
    
    UILabel *mobNumLbl = [[UILabel alloc] init];
    mobNumLbl.text = @"Mobile#";
    mobNumLbl.frame =  CGRectMake(20, 100, 100, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    mobNumLbl.font = [UIFont boldSystemFontOfSize:13];
    mobNumLbl.textAlignment = NSTextAlignmentLeft;
    mobNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    mobNumLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:mobNumLbl];
    
    mobNumValueLbl = [[UILabel alloc] init];
   // mobNumValueLbl.text = @"123-456-7890 ";
    mobNumValueLbl.tag = 17;
    mobNumValueLbl.frame =  CGRectMake(130, 100, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    mobNumValueLbl.font = [UIFont systemFontOfSize:12];
    mobNumValueLbl.textAlignment = NSTextAlignmentLeft;
    mobNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    mobNumValueLbl.backgroundColor = [UIColor clearColor];
    mobNumValueLbl.hidden = NO;
    [personalDetailView addSubview:mobNumValueLbl];

    //Person Details Edit textfield for Mobile number of Birth
    mobNumValueTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 100, 180, 28)]; //80, 230, 220, 30
    mobNumValueTF.placeholder = @"Enter Mobile number";
    mobNumValueTF.backgroundColor=[UIColor clearColor];
    mobNumValueTF.borderStyle=UITextBorderStyleRoundedRect;
    mobNumValueTF.font=[UIFont systemFontOfSize:13];
    mobNumValueTF.textColor = [UIColor blackColor];
    mobNumValueTF.textAlignment=NSTextAlignmentLeft;
    mobNumValueTF.autocorrectionType=UITextAutocorrectionTypeNo;
    mobNumValueTF.keyboardType=UIKeyboardTypeDefault;
    mobNumValueTF.returnKeyType=UIReturnKeyDone;
    mobNumValueTF.clearButtonMode=UITextFieldViewModeWhileEditing;
    mobNumValueTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  //  mobNumValueTF.tag=3;
    mobNumValueTF.hidden = YES;
    mobNumValueTF.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [personalDetailView addSubview:mobNumValueTF];
   
    
    
    
    UILabel *addrNumLbl = [[UILabel alloc] init];
    addrNumLbl.text = @"Address";
    
    addrNumLbl.frame =  CGRectMake(20, 190, 100, 28);//(20, 216, 100, 28)
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    addrNumLbl.font = [UIFont boldSystemFontOfSize:13];
    addrNumLbl.textAlignment = NSTextAlignmentLeft;
    addrNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    addrNumLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:addrNumLbl];
    
    
    UILabel *colunLbl = [[UILabel alloc] init];
    colunLbl.text = @": S";
    colunLbl.font = [UIFont boldSystemFontOfSize:11];
    colunLbl.frame =  CGRectMake(129, 190, 3, 28);//
     [personalDetailView addSubview:colunLbl];
    
    
    UILabel *addrNumValueLbl = [[UILabel alloc] init];
   // addrNumValueLbl.text = @"106 jorg Avenu,600/10 chicago,VT 23132 ";
    
    addrNumValueLbl.tag = 18;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    addrNumValueLbl.frame =  CGRectMake(134, 198, 160, 70);//(130, 216, 180, 28)
    }
    else
    {
        addrNumValueLbl.frame =  CGRectMake(134, 196, 300, 70);
    }
    addrNumValueLbl.numberOfLines = 0;
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    addrNumValueLbl.font = [UIFont systemFontOfSize:12];
    addrNumValueLbl.textAlignment = NSTextAlignmentLeft;
    addrNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    addrNumValueLbl.backgroundColor = [UIColor clearColor];
    
    [personalDetailView addSubview:addrNumValueLbl];
    
    
    UILabel *perEmailLbl = [[UILabel alloc] init];
    perEmailLbl.text = @"Personal email";
    perEmailLbl.frame =  CGRectMake(20, 130, 100, 28);//(20, 140, 100, 28)
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    perEmailLbl.font = [UIFont boldSystemFontOfSize:13];
    perEmailLbl.textAlignment = NSTextAlignmentLeft;
    perEmailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    perEmailLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:perEmailLbl];
    
    UILabel *perEmailValueLbl = [[UILabel alloc] init];
    //perEmailValueLbl.text = @"test@email.com ";
    perEmailValueLbl.tag = 19;
    perEmailValueLbl.frame =  CGRectMake(130, 130, 180, 28);//(130, 120, 180, 66)
    perEmailValueLbl.numberOfLines = 0;
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    perEmailValueLbl.font = [UIFont systemFontOfSize:12];
    perEmailValueLbl.textAlignment = NSTextAlignmentLeft;
    perEmailValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    perEmailValueLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:perEmailValueLbl];
    
    UILabel *busEmailLbl = [[UILabel alloc] init];
    busEmailLbl.text = @"Business email";
    busEmailLbl.frame =  CGRectMake(20, 160, 100, 28);//(20, 186, 100, 28)
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    busEmailLbl.font = [UIFont boldSystemFontOfSize:13];
    busEmailLbl.textAlignment = NSTextAlignmentLeft;
    busEmailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    busEmailLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:busEmailLbl];
    
    UILabel *busEmailValueLbl = [[UILabel alloc] init];
    //busEmailValueLbl.text = @"test@email.com ";
    busEmailValueLbl.tag = 20;
    busEmailValueLbl.frame =  CGRectMake(130, 160, 180, 28);//(130, 186, 180, 28)
    busEmailValueLbl.numberOfLines = 0;
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    busEmailValueLbl.font = [UIFont systemFontOfSize:12];
    busEmailValueLbl.textAlignment = NSTextAlignmentLeft;
    busEmailValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    busEmailValueLbl.backgroundColor = [UIColor clearColor];
    [personalDetailView addSubview:busEmailValueLbl];
    
//    UILabel *driverLicenseNumLbl = [[UILabel alloc] init];
//    driverLicenseNumLbl.text = @"Driver License#";
//    driverLicenseNumLbl.frame =  CGRectMake(20, 276, 100, 28);
//    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
//    driverLicenseNumLbl.font = [UIFont boldSystemFontOfSize:13];
//    driverLicenseNumLbl.textAlignment = NSTextAlignmentLeft;
//    driverLicenseNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    driverLicenseNumLbl.backgroundColor = [UIColor clearColor];
//    [personalDetailView addSubview:driverLicenseNumLbl];
//    
//    UILabel *driverLicenseNumValueLbl = [[UILabel alloc] init];
//    //driverLicenseNumValueLbl.text = @"SF23234B ";
//    driverLicenseNumValueLbl.tag = 21;
//    driverLicenseNumValueLbl.frame =  CGRectMake(130, 276, 180, 28);
//    driverLicenseNumValueLbl.numberOfLines = 0;
//    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
//    driverLicenseNumValueLbl.font = [UIFont systemFontOfSize:12];
//    driverLicenseNumValueLbl.textAlignment = NSTextAlignmentLeft;
//    driverLicenseNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    driverLicenseNumValueLbl.backgroundColor = [UIColor clearColor];
//    [personalDetailView addSubview:driverLicenseNumValueLbl];
//    
//    
//    
//    UILabel *ssnLbl = [[UILabel alloc] init];
//    ssnLbl.text = @"SSN";
//    ssnLbl.frame =  CGRectMake(20, 306, 100, 28);
//    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
//    ssnLbl.font = [UIFont boldSystemFontOfSize:13];
//    ssnLbl.textAlignment = NSTextAlignmentLeft;
//    ssnLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    ssnLbl.backgroundColor = [UIColor clearColor];
//    [personalDetailView addSubview:ssnLbl];
//    
//    UILabel *ssnValueLbl = [[UILabel alloc] init];
//    //ssnValueLbl.text = @"NA ";
//    ssnValueLbl.tag = 22;
//    ssnValueLbl.frame =  CGRectMake(130, 306, 180, 28);
//    ssnValueLbl.numberOfLines = 0;
//    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
//    ssnValueLbl.font = [UIFont systemFontOfSize:12];
//    ssnValueLbl.textAlignment = NSTextAlignmentLeft;
//    ssnValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
//    ssnValueLbl.backgroundColor = [UIColor clearColor];
//    [personalDetailView addSubview:ssnValueLbl];
//    
    
    
    //Salary/Tax Details
    
    /*
    
    UIView *salaryDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 870, self.view.frame.size.width, 170)];
    salaryDetailView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:salaryDetailView];
    
    
    salaryDetailView.layer.shadowOffset = CGSizeMake(0, 0);
    salaryDetailView.layer.shadowColor = [[UIColor blackColor] CGColor];
    salaryDetailView.layer.shadowRadius = 1;
    salaryDetailView.layer.shadowOpacity = 0.50;
    
    UILabel *salaryDetailViewLbl = [[UILabel alloc] init];
    salaryDetailViewLbl.text = @"Salary/Tax Details";
    salaryDetailViewLbl.frame =  CGRectMake(10, 2, 280, 30);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    salaryDetailViewLbl.font = [UIFont boldSystemFontOfSize:14];
    salaryDetailViewLbl.textAlignment = NSTextAlignmentLeft;
    salaryDetailViewLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    salaryDetailViewLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:salaryDetailViewLbl];
    
    */
//    UIButton *salEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [salEditButton addTarget:self action:@selector(SalaryTaxEditButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [salEditButton setTitle:@"Edit" forState:UIControlStateNormal];
//    [salEditButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [salEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    salEditButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    salEditButton.frame = CGRectMake(self.view.frame.size.width-60, 5.0, 40.0, 20.0);
//    [salaryDetailView addSubview:salEditButton];
    
    
    /*
    UILabel *salTaxdeviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 1)];
    salTaxdeviderlbl.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];//(238,238,238)
    [salaryDetailView addSubview:salTaxdeviderlbl];
    
    
    
    UILabel *wagesLbl = [[UILabel alloc] init];
    wagesLbl.text = @"Wages ";
    wagesLbl.frame =  CGRectMake(20, 40, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    wagesLbl.font = [UIFont boldSystemFontOfSize:13];
    wagesLbl.textAlignment = NSTextAlignmentLeft;
    wagesLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    wagesLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:wagesLbl];
    
    UILabel *wagesValueLbl = [[UILabel alloc] init];
    wagesValueLbl.text = @"NA ";
    wagesValueLbl.frame =  CGRectMake(130, 40, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    wagesValueLbl.font = [UIFont systemFontOfSize:12];
    wagesValueLbl.textAlignment = NSTextAlignmentLeft;
    wagesValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    wagesValueLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:wagesValueLbl];
    
    
    UILabel *salLbl = [[UILabel alloc] init];
    salLbl.text = @"Salary ";
    salLbl.frame =  CGRectMake(20, 70, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    salLbl.font = [UIFont boldSystemFontOfSize:13];
    salLbl.textAlignment = NSTextAlignmentLeft;
    salLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    salLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:salLbl];
    
    UILabel *salValueLbl = [[UILabel alloc] init];
    salValueLbl.text = @"Rs 15,000 ";
    salValueLbl.frame =  CGRectMake(130, 70, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    salValueLbl.font = [UIFont systemFontOfSize:12];
    salValueLbl.textAlignment = NSTextAlignmentLeft;
    salValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    salValueLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:salValueLbl];
    
    
    UILabel *marriedLbl = [[UILabel alloc] init];
    marriedLbl.text = @"Married ";
    marriedLbl.frame =  CGRectMake(20, 100, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    marriedLbl.font = [UIFont boldSystemFontOfSize:13];
    marriedLbl.textAlignment = NSTextAlignmentLeft;
    marriedLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    marriedLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:marriedLbl];
    
    UILabel *marriedValueLbl = [[UILabel alloc] init];
    marriedValueLbl.text = @"NO ";
    marriedValueLbl.frame =  CGRectMake(130, 100, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    marriedValueLbl.font = [UIFont systemFontOfSize:12];
    marriedValueLbl.textAlignment = NSTextAlignmentLeft;
    marriedValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    marriedValueLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:marriedValueLbl];
    
    
    UILabel *deductionsLbl = [[UILabel alloc] init];
    deductionsLbl.text = @"Deductions ";
    deductionsLbl.frame =  CGRectMake(20, 130, 100, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    deductionsLbl.font = [UIFont boldSystemFontOfSize:13];
    deductionsLbl.textAlignment = NSTextAlignmentLeft;
    deductionsLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    deductionsLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:deductionsLbl];
    
    UILabel *deductionsValueLbl = [[UILabel alloc] init];
    deductionsValueLbl.text = @"2,000 ";
    deductionsValueLbl.frame =  CGRectMake(130, 130, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    deductionsValueLbl.font = [UIFont systemFontOfSize:12];
    deductionsValueLbl.textAlignment = NSTextAlignmentLeft;
    deductionsValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    deductionsValueLbl.backgroundColor = [UIColor clearColor];
    [salaryDetailView addSubview:deductionsValueLbl];
    
    
    
    //Emergency contact details
    
    
    
    UIView *emergencyContactDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 1050, self.view.frame.size.width, 600)];
    emergencyContactDetailView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:emergencyContactDetailView];
    
    
    emergencyContactDetailView.layer.shadowOffset = CGSizeMake(0, 0);
    emergencyContactDetailView.layer.shadowColor = [[UIColor blackColor] CGColor];
    emergencyContactDetailView.layer.shadowRadius = 1;
    emergencyContactDetailView.layer.shadowOpacity = 0.50;
    
    UILabel *emergencyContactDetailViewLbl = [[UILabel alloc] init];
    emergencyContactDetailViewLbl.text = @"Emergency Contact Details";
    emergencyContactDetailViewLbl.frame =  CGRectMake(10, 2, 280, 30);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    emergencyContactDetailViewLbl.font = [UIFont boldSystemFontOfSize:14];
    emergencyContactDetailViewLbl.textAlignment = NSTextAlignmentLeft;
    emergencyContactDetailViewLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    emergencyContactDetailViewLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:emergencyContactDetailViewLbl];
    
    
    UILabel *emergencyContacteviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 1)];
    emergencyContacteviderlbl.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];//(238,238,238)
    [emergencyContactDetailView addSubview:emergencyContacteviderlbl];
    
    
    //Firest contact person
    
    
    UILabel *fstNameLbl = [[UILabel alloc] init];
    fstNameLbl.text = @"Name ";
    fstNameLbl.frame =  CGRectMake(20, 40, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstNameLbl.font = [UIFont boldSystemFontOfSize:13];
    fstNameLbl.textAlignment = NSTextAlignmentLeft;
    fstNameLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstNameLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstNameLbl];
    
    UILabel *fstNameValueLbl = [[UILabel alloc] init];
    fstNameValueLbl.text = @"Gopi S ";
    fstNameValueLbl.frame =  CGRectMake(130, 40, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstNameValueLbl.font = [UIFont systemFontOfSize:12];
    fstNameValueLbl.textAlignment = NSTextAlignmentLeft;
    fstNameValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstNameValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstNameValueLbl];

    
//    UIButton *fstPersonEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [fstPersonEditButton addTarget:self action:@selector(FirstPersonEditButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [fstPersonEditButton setTitle:@"Edit" forState:UIControlStateNormal];
//    [fstPersonEditButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [fstPersonEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    fstPersonEditButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    fstPersonEditButton.frame = CGRectMake(self.view.frame.size.width-60, 40.0, 40.0, 20.0);
//    [emergencyContactDetailView addSubview:fstPersonEditButton];

    
    
    
    
    UILabel *fstPhNumLbl = [[UILabel alloc] init];
    fstPhNumLbl.text = @"Phone# ";
    fstPhNumLbl.frame =  CGRectMake(20, 70, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstPhNumLbl.font = [UIFont boldSystemFontOfSize:13];
    fstPhNumLbl.textAlignment = NSTextAlignmentLeft;
    fstPhNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstPhNumLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstPhNumLbl];
    
    UILabel *fstPhNumValueLbl = [[UILabel alloc] init];
    fstPhNumValueLbl.text = @"897-456-1201 ";
    fstPhNumValueLbl.frame =  CGRectMake(130, 70, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstPhNumValueLbl.font = [UIFont systemFontOfSize:12];
    fstPhNumValueLbl.textAlignment = NSTextAlignmentLeft;
    fstPhNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstPhNumValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstPhNumValueLbl];
    
    
    UILabel *fstEmailLbl = [[UILabel alloc] init];
    fstEmailLbl.text = @"Email ";
    fstEmailLbl.frame =  CGRectMake(20, 100, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstEmailLbl.font = [UIFont boldSystemFontOfSize:13];
    fstEmailLbl.textAlignment = NSTextAlignmentLeft;
    fstEmailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstEmailLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstEmailLbl];
    
    UILabel *fstEmailValueLbl = [[UILabel alloc] init];
    fstEmailValueLbl.text = @"test@gmail.com ";
    fstEmailValueLbl.frame =  CGRectMake(130, 100, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstEmailValueLbl.font = [UIFont systemFontOfSize:12];
    fstEmailValueLbl.textAlignment = NSTextAlignmentLeft;
    fstEmailValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstEmailValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstEmailValueLbl];
    
    
    UILabel *fstRelationLbl = [[UILabel alloc] init];
    fstRelationLbl.text = @"Relation ";
    fstRelationLbl.frame =  CGRectMake(20, 130, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstRelationLbl.font = [UIFont boldSystemFontOfSize:13];
    fstRelationLbl.textAlignment = NSTextAlignmentLeft;
    fstRelationLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstRelationLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstRelationLbl];
    
    UILabel *fstRelationValueLbl = [[UILabel alloc] init];
    fstRelationValueLbl.text = @"Friend ";
    fstRelationValueLbl.frame =  CGRectMake(130, 130, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstRelationValueLbl.font = [UIFont systemFontOfSize:12];
    fstRelationValueLbl.textAlignment = NSTextAlignmentLeft;
    fstRelationValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstRelationValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstRelationValueLbl];
    
    
    
    UILabel *fstAddLbl = [[UILabel alloc] init];
    fstAddLbl.text = @"Address ";
    fstAddLbl.frame =  CGRectMake(20, 170, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstAddLbl.font = [UIFont boldSystemFontOfSize:13];
    fstAddLbl.textAlignment = NSTextAlignmentLeft;
    fstAddLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstAddLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstAddLbl];
    
    UILabel *fstAddValueLbl = [[UILabel alloc] init];
    fstAddValueLbl.text = @"106 jorg Avenu,600/10 chicago,VT 23132 ";
    fstAddValueLbl.frame =  CGRectMake(130, 150, 180, 66);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    fstAddValueLbl.font = [UIFont systemFontOfSize:12];
    fstAddValueLbl.numberOfLines = 0;
    fstAddValueLbl.textAlignment = NSTextAlignmentLeft;
    fstAddValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    fstAddValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:fstAddValueLbl];
    
    
    
    
    
    //Second contact person
    
    
    UILabel *secContactDeviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 1)];
    secContactDeviderlbl.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];//(238,238,238)
    [emergencyContactDetailView addSubview:secContactDeviderlbl];
    
    
    
    UILabel *secNameLbl = [[UILabel alloc] init];
    secNameLbl.text = @"Name ";
    secNameLbl.frame =  CGRectMake(20, 230, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secNameLbl.font = [UIFont boldSystemFontOfSize:13];
    secNameLbl.textAlignment = NSTextAlignmentLeft;
    secNameLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secNameLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secNameLbl];
    
    UILabel *secNameValueLbl = [[UILabel alloc] init];
    secNameValueLbl.text = @"Gopi S ";
    secNameValueLbl.frame =  CGRectMake(130, 230, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secNameValueLbl.font = [UIFont systemFontOfSize:12];
    secNameValueLbl.textAlignment = NSTextAlignmentLeft;
    secNameValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secNameValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secNameValueLbl];
    
//    
//    UIButton *secPersonEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [secPersonEditButton addTarget:self action:@selector(SecondPersonEditButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [secPersonEditButton setTitle:@"Edit" forState:UIControlStateNormal];
//    [secPersonEditButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [secPersonEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    secPersonEditButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    secPersonEditButton.frame = CGRectMake(self.view.frame.size.width-60, 230.0, 40.0, 20.0);
//    [emergencyContactDetailView addSubview:secPersonEditButton];
//    
    
    UILabel *secPhNumLbl = [[UILabel alloc] init];
    secPhNumLbl.text = @"Phone# ";
    secPhNumLbl.frame =  CGRectMake(20, 260, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secPhNumLbl.font = [UIFont boldSystemFontOfSize:13];
    secPhNumLbl.textAlignment = NSTextAlignmentLeft;
    secPhNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secPhNumLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secPhNumLbl];
    
    UILabel *secPhNumValueLbl = [[UILabel alloc] init];
    secPhNumValueLbl.text = @"897-456-1201 ";
    secPhNumValueLbl.frame =  CGRectMake(130, 260, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secPhNumValueLbl.font = [UIFont systemFontOfSize:12];
    secPhNumValueLbl.textAlignment = NSTextAlignmentLeft;
    secPhNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secPhNumValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secPhNumValueLbl];
    
    
    UILabel *secEmailLbl = [[UILabel alloc] init];
    secEmailLbl.text = @"Email ";
    secEmailLbl.frame =  CGRectMake(20, 290, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secEmailLbl.font = [UIFont boldSystemFontOfSize:13];
    secEmailLbl.textAlignment = NSTextAlignmentLeft;
    secEmailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secEmailLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secEmailLbl];
    
    UILabel *secEmailValueLbl = [[UILabel alloc] init];
    secEmailValueLbl.text = @"test@gmail.com ";
    secEmailValueLbl.frame =  CGRectMake(130, 290, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secEmailValueLbl.font = [UIFont systemFontOfSize:12];
    secEmailValueLbl.textAlignment = NSTextAlignmentLeft;
    secEmailValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secEmailValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secEmailValueLbl];
    
    
    UILabel *secRelationLbl = [[UILabel alloc] init];
    secRelationLbl.text = @"Relation ";
    secRelationLbl.frame =  CGRectMake(20, 320, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secRelationLbl.font = [UIFont boldSystemFontOfSize:13];
    secRelationLbl.textAlignment = NSTextAlignmentLeft;
    secRelationLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secRelationLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secRelationLbl];
    
    UILabel *secRelationValueLbl = [[UILabel alloc] init];
    secRelationValueLbl.text = @"Friend ";
    secRelationValueLbl.frame =  CGRectMake(130, 320, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secRelationValueLbl.font = [UIFont systemFontOfSize:12];
    secRelationValueLbl.textAlignment = NSTextAlignmentLeft;
    secRelationValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secRelationValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secRelationValueLbl];
    
    
    
    UILabel *secAddLbl = [[UILabel alloc] init];
    secAddLbl.text = @"Address ";
    secAddLbl.frame =  CGRectMake(20, 360, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secAddLbl.font = [UIFont boldSystemFontOfSize:13];
    secAddLbl.textAlignment = NSTextAlignmentLeft;
    secAddLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secAddLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secAddLbl];
    
    UILabel *secAddValueLbl = [[UILabel alloc] init];
    secAddValueLbl.text = @"106 jorg Avenu,600/10 chicago,VT 23132 ";
    secAddValueLbl.frame =  CGRectMake(130, 340, 180, 66);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    secAddValueLbl.font = [UIFont systemFontOfSize:12];
    secAddValueLbl.numberOfLines = 0;
    secAddValueLbl.textAlignment = NSTextAlignmentLeft;
    secAddValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    secAddValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:secAddValueLbl];
    
    
    
    
    //Third contact person
    
    
    UILabel *thirdContactDeviderlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, self.view.frame.size.width, 1)];
    thirdContactDeviderlbl.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];//(238,238,238)
    [emergencyContactDetailView addSubview:thirdContactDeviderlbl];
    
    
    UILabel *thirdNameLbl = [[UILabel alloc] init];
    thirdNameLbl.text = @"Name ";
    thirdNameLbl.frame =  CGRectMake(20, 420, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdNameLbl.font = [UIFont boldSystemFontOfSize:13];
    thirdNameLbl.textAlignment = NSTextAlignmentLeft;
    thirdNameLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdNameLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdNameLbl];
    
    UILabel *thirdNameValueLbl = [[UILabel alloc] init];
    thirdNameValueLbl.text = @"Gopi S ";
    thirdNameValueLbl.frame =  CGRectMake(130, 420, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdNameValueLbl.font = [UIFont systemFontOfSize:12];
    thirdNameValueLbl.textAlignment = NSTextAlignmentLeft;
    thirdNameValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdNameValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdNameValueLbl];
    
//    
//    UIButton *thirdPersonEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [thirdPersonEditButton addTarget:self action:@selector(ThirdPersonEditButtonTapped)forControlEvents:UIControlEventTouchDown];
//    [thirdPersonEditButton setTitle:@"Edit" forState:UIControlStateNormal];
//    [thirdPersonEditButton setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:172.0/255.0 blue:89.0/255.0 alpha:1.0]];//24, 167, 138
//    [thirdPersonEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    thirdPersonEditButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    thirdPersonEditButton.frame = CGRectMake(self.view.frame.size.width-60, 420.0, 40.0, 20.0);
//    [emergencyContactDetailView addSubview:thirdPersonEditButton];
    
    
    UILabel *thirdPhNumLbl = [[UILabel alloc] init];
    thirdPhNumLbl.text = @"Phone# ";
    thirdPhNumLbl.frame =  CGRectMake(20, 450, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdPhNumLbl.font = [UIFont boldSystemFontOfSize:13];
    thirdPhNumLbl.textAlignment = NSTextAlignmentLeft;
    thirdPhNumLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdPhNumLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdPhNumLbl];
    
    UILabel *thirdPhNumValueLbl = [[UILabel alloc] init];
    thirdPhNumValueLbl.text = @"897-456-1201 ";
    thirdPhNumValueLbl.frame =  CGRectMake(130, 450, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdPhNumValueLbl.font = [UIFont systemFontOfSize:12];
    thirdPhNumValueLbl.textAlignment = NSTextAlignmentLeft;
    thirdPhNumValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdPhNumValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdPhNumValueLbl];
    
    
    UILabel *thirdEmailLbl = [[UILabel alloc] init];
    thirdEmailLbl.text = @"Email ";
    thirdEmailLbl.frame =  CGRectMake(20, 480, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdEmailLbl.font = [UIFont boldSystemFontOfSize:13];
    thirdEmailLbl.textAlignment = NSTextAlignmentLeft;
    thirdEmailLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdEmailLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdEmailLbl];
    
    UILabel *thirdEmailValueLbl = [[UILabel alloc] init];
    thirdEmailValueLbl.text = @"test@gmail.com ";
    thirdEmailValueLbl.frame =  CGRectMake(130, 480, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdEmailValueLbl.font = [UIFont systemFontOfSize:12];
    thirdEmailValueLbl.textAlignment = NSTextAlignmentLeft;
    thirdEmailValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdEmailValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdEmailValueLbl];
    
    
    UILabel *thirdRelationLbl = [[UILabel alloc] init];
    thirdRelationLbl.text = @"Relation ";
    thirdRelationLbl.frame =  CGRectMake(20, 510, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdRelationLbl.font = [UIFont boldSystemFontOfSize:13];
    thirdRelationLbl.textAlignment = NSTextAlignmentLeft;
    thirdRelationLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdRelationLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdRelationLbl];
    
    UILabel *thirdRelationValueLbl = [[UILabel alloc] init];
    thirdRelationValueLbl.text = @"Friend ";
    thirdRelationValueLbl.frame =  CGRectMake(130, 510, 180, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdRelationValueLbl.font = [UIFont systemFontOfSize:12];
    thirdRelationValueLbl.textAlignment = NSTextAlignmentLeft;
    thirdRelationValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdRelationValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdRelationValueLbl];
    
    
    
    UILabel *thirdAddLbl = [[UILabel alloc] init];
    thirdAddLbl.text = @"Address ";
    thirdAddLbl.frame =  CGRectMake(20, 550, 60, 28);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdAddLbl.font = [UIFont boldSystemFontOfSize:13];
    thirdAddLbl.textAlignment = NSTextAlignmentLeft;
    thirdAddLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdAddLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdAddLbl];
    
    UILabel *thirdAddValueLbl = [[UILabel alloc] init];
    thirdAddValueLbl.text = @"106 jorg Avenu,600/10 chicago,VT 23132 ";
    thirdAddValueLbl.frame =  CGRectMake(130, 530, 180, 66);
    //    whiteLbl.font = [UIFont fontWithName:@"Zapfino" size:16];
    thirdAddValueLbl.font = [UIFont systemFontOfSize:12];
    thirdAddValueLbl.numberOfLines = 0;
    thirdAddValueLbl.textAlignment = NSTextAlignmentLeft;
    thirdAddValueLbl.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    thirdAddValueLbl.backgroundColor = [UIColor clearColor];
    [emergencyContactDetailView addSubview:thirdAddValueLbl];
    
    */

    
    scrollView.contentSize=CGSizeMake(self.view.frame.size.width, personalDetailView.frame.origin.y+personalDetailView.frame.size.height+20);
    
//    activityIndicator = [[UIActivityIndicatorView alloc] init];
//    activityIndicator.color = [UIColor grayColor];
//    activityIndicator.alpha = 1.0;
//    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    activityIndicator.hidden = YES;
//    [activityIndicator startAnimating];
//    [self.view addSubview:activityIndicator];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
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
    
    if (typeofParsing == 1)
    {
        [self UserProfileImplementation];
    }
    
    
}


-(void)UserProfileImplementation
{
    typeofParsing = 2;
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    
     NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<GetEmpProfile xmlns=\"http://tempuri.org/\">"
    "<companyCode>%@</companyCode>"
    "<empCompanyID>%@</empCompanyID>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<mobileName>%@</mobileName>"
    "</GetEmpProfile>"
    "</soap:Body>"
    "</soap:Envelope>",cmpCode,empCmpyID,deviceID,authID,logitudeCmp,latitudeCmp,mobileName];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetEmpProfile" forHTTPHeaderField:@"SOAPAction"];
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
     [_locationManager stopUpdatingLocation];
    [self webServiceCallToSaveDataFailedWithError:error];
    NSLog(@"ERROR with theConenction");
    
}
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
   
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=self;
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (buttonIndex== 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (typeofParsing == 1)
    {
//        NSString *strXMl = [[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
//        NSLog(@"XML is : %@", strXMl);
    }
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
}
#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"GetEmpProfileResult"])
    {
        
    }
    
    else if ([elementName isEqualToString:@"empProfileInfo"])
    {
        _currentelementValueStr = [[NSString alloc] init];
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    _currentelementValueStr = string;
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"AASuccess"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"AASuccessKey"];
    }
    else if ([elementName isEqualToString:@"EmpActive"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpActiveKey"];
    }
    else if ([elementName isEqualToString:@"CompanyCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyCodeKey"];
    }
    else if ([elementName isEqualToString:@"CompanyID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyIDKey"];
    }
    else if ([elementName isEqualToString:@"CompanyAddress"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyAddressKey"];
    }
    else if ([elementName isEqualToString:@"CompanyCity"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyCityKey"];
    }
    else if ([elementName isEqualToString:@"CompanyStateCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyStateCodeKey"];
    }
    else if ([elementName isEqualToString:@"CompanyZip"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyZipKey"];
    }
    else if ([elementName isEqualToString:@"CompanyLogo"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyLogoKey"];
    }
    else if ([elementName isEqualToString:@"CompanySmallLogo"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanySmallLogoKey"];
    }
    else if ([elementName isEqualToString:@"ViewAll"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ViewAllKey"];
    }
    else if ([elementName isEqualToString:@"OfficeCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeCodeKey"];
    }
    
    else if ([elementName isEqualToString:@"OfficeID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeIDKey"];
    }
    else if ([elementName isEqualToString:@"OfficeAddress"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeAddressKey"];
    }
    else if ([elementName isEqualToString:@"OfficeCity"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeCityKey"];
    }
    else if ([elementName isEqualToString:@"OfficeState"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeStateKey"];
    }
    else if ([elementName isEqualToString:@"OfficeStateCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeStateCodeKey"];
    }
    else if ([elementName isEqualToString:@"OfficeZip"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"OfficeZipKey"];
    }
    else if ([elementName isEqualToString:@"EmpFname"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpFnameKey"];
    }
    else if ([elementName isEqualToString:@"EmpLname"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpLnameKey"];
    }
    else if ([elementName isEqualToString:@"BusinessFname"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"BusinessFnameKey"];
    }
    else if ([elementName isEqualToString:@"BusinessLname"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"BusinessLnameKey"];
    }
    
    else if ([elementName isEqualToString:@"Gender"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"GenderKey"];
    }
    else if ([elementName isEqualToString:@"DateOfBirth"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"DateOfBirthKey"];
    }
    else if ([elementName isEqualToString:@"DateOfJoin"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"DateOfJoinKey"];
    }
    else if ([elementName isEqualToString:@"DateOfQuit"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"DateOfQuitKey"];
    }
    else if ([elementName isEqualToString:@"QuitReason"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"QuitReasonKey"];
    }
    else if ([elementName isEqualToString:@"EmpType"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpTypeKey"];
    }
    else if ([elementName isEqualToString:@"DepartmentName"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"DepartmentNameKey"];
    }
    else if ([elementName isEqualToString:@"ShiftName"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ShiftNameKey"];
    }
    else if ([elementName isEqualToString:@"ShiftStart"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ShiftStartKey"];
    }
    else if ([elementName isEqualToString:@"ShiftEnd"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ShiftEndKey"];
    }
    
    
    else if ([elementName isEqualToString:@"ScheduleStart"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ScheduleStartKey"];
    }
    else if ([elementName isEqualToString:@"SchduleEnd"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"SchduleEndKey"];
    }
    else if ([elementName isEqualToString:@"LunchStart"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LunchStartKey"];
    }
    else if ([elementName isEqualToString:@"LunchEnd"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LunchEndKey"];
    }
    else if ([elementName isEqualToString:@"Isschvariable"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"IsschvariableKey"];
    }
    else if ([elementName isEqualToString:@"IsLunchFixed"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"IsLunchFixedKey"];
    }
    else if ([elementName isEqualToString:@"LunchDuration"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"LunchDurationKey"];
    }
    else if ([elementName isEqualToString:@"EmpAddress"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpAddressKey"];
    }
    else if ([elementName isEqualToString:@"EmpCity"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpCityKey"];
    }
    else if ([elementName isEqualToString:@"EmpStateCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpStateCodeKey"];
    }
    
    
    
    else if ([elementName isEqualToString:@"EmpZip"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpZipKey"];
    }
    else if ([elementName isEqualToString:@"CompanyWeb"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyWebKey"];
    }
    else if ([elementName isEqualToString:@"DeptCode"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"DeptCodeKey"];
    }
    else if ([elementName isEqualToString:@"CompanyName"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"CompanyNameKey"];
    }
    else if ([elementName isEqualToString:@"EmpID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpIDKey"];
    }
    else if ([elementName isEqualToString:@"EmpCompanyID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpCompanyIDKey"];
    }
    else if ([elementName isEqualToString:@"EmpDesignation"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpDesignationKey"];
    }
    else if ([elementName isEqualToString:@"EmpPhone"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpPhoneKey"];
    }
    else if ([elementName isEqualToString:@"EmpofficeEmail"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpofficeEmailKey"];
    }
    else if ([elementName isEqualToString:@"EmpEmail"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpEmailKey"];
    }

    
    
    else if ([elementName isEqualToString:@"IslunchBreak"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"IslunchBreakKey"];
    }
    else if ([elementName isEqualToString:@"EmpHomePhone"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpHomePhoneKey"];
    }
    else if ([elementName isEqualToString:@"EmpPhoto"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpPhotoKey"];
    }
    else if ([elementName isEqualToString:@"TemplateColor"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"TemplateColorKey"];
    }
    else if ([elementName isEqualToString:@"Timezone"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"TimezoneKey"];
    }
    else if ([elementName isEqualToString:@"TimeZoneDescription"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"TimeZoneDescriptionKey"];
    }
    else if ([elementName isEqualToString:@"TimeZoneID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"TimeZoneIDKey"];
    }
    else if ([elementName isEqualToString:@"ShiftID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ShiftIDKey"];
    }
    else if ([elementName isEqualToString:@"ScheduleID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ScheduleIDKey"];
    }
    else if ([elementName isEqualToString:@"EmpTypeID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"EmpTypeIDKey"];
    }

    else if ([elementName isEqualToString:@"DeptID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"DeptIDKey"];
    }
    else if ([elementName isEqualToString:@"ScheduleID"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"TagLineKey"];
    }
    else if ([elementName isEqualToString:@"TaglineHeading"])
    {
        [comEmpDetailsDictionary setObject:_currentelementValueStr forKey:@"ETaglineHeadingKey"];
    }

    
    _currentelementValueStr = nil;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"comEmpDetailsDictionary--%@",comEmpDetailsDictionary);
    
    NSString *successStr = [comEmpDetailsDictionary objectForKey:@"AASuccessKey"];
    if ([successStr isEqualToString:@"Success"])
    {
//        UILabel *empName = (UILabel *)[self.view viewWithTag:1];
//        
//       //
//        NSString *empBEmpFName = [comEmpDetailsDictionary objectForKey:@"BusinessFnameKey"];
//        NSString *empBEmpLName = [comEmpDetailsDictionary objectForKey:@"BusinessLnameKey"];
//        
//        
//        if ([empBEmpLName isEqualToString:@"Emp"] || [empBEmpLName isEqual:[NSNull null]])
//        {
//            empName.text = empBEmpFName;
//        }
//        else
//        {
//            empName.text = [NSString stringWithFormat:@"%@ %@",empBEmpFName,empBEmpLName];
//        }
        
        //UIImageView *preArrowImage =(UIImageView *)[self.view viewWithTag:2];
        AsyncImageView *preArrowImage = (AsyncImageView *)[self.view viewWithTag:2];
        
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *imgURL = [comEmpDetailsDictionary objectForKey:@"EmpPhotoKey"];
            NSString *urlStr = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            
            //set your image on main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (data != nil) {
                    [preArrowImage setImage:[UIImage imageWithData:data]];
                }
                else
                {
                    [preArrowImage setImage:[UIImage imageNamed:@"user.png"]];
                }
                
            });    
        });
        
        
         UILabel *empCmpID = (UILabel *)[self.view viewWithTag:3];
        
        NSString *empIDStr = [comEmpDetailsDictionary objectForKey:@"EmpCompanyIDKey"];
        
        if ([empIDStr isEqualToString:@"Emp"] || [empIDStr isEqual:[NSNull null]])
        {
            
            empCmpID.text = @": ";

        }
        else
        {
            empCmpID.text = [NSString stringWithFormat:@": %@",empIDStr];

        }
        
        UILabel *empPersName = (UILabel *)[self.view viewWithTag:4];
        
        NSString *empFName = [comEmpDetailsDictionary objectForKey:@"EmpFnameKey"];
        NSString *empLName = [comEmpDetailsDictionary objectForKey:@"EmpLnameKey"];
        
        
       // UILabel *empGenderLbl = (UILabel *)[self.view viewWithTag:14];
        
        NSString *empGendereStr = [comEmpDetailsDictionary objectForKey:@"GenderKey"];
        
        if ([empGendereStr isEqualToString:@"Emp"] || [empGendereStr isEqual:[NSNull null]])
        {
            
            empGendereStr = @"";
            
        }
        
        
        
        
        
        if ([empLName isEqualToString:@"Emp"] || [empLName isEqual:[NSNull null]])
        {
            empPersName.text = [NSString stringWithFormat:@":%@ %@",empGendereStr,empFName];
        }
        else
        {
            empPersName.text = [NSString stringWithFormat:@":%@ %@ %@",empGendereStr,empFName,empLName];
        }
        
        
        UILabel *empCmpDescName = (UILabel *)[self.view viewWithTag:5];
        
        NSString *empCmpFName = [comEmpDetailsDictionary objectForKey:@"BusinessFnameKey"];
        NSString *empCmpLName = [comEmpDetailsDictionary objectForKey:@"BusinessLnameKey"];
        
        
        
        if ([empCmpLName isEqualToString:@"Emp"] || [empCmpLName isEqual:[NSNull null]])
        {
            empCmpDescName.text = [NSString stringWithFormat:@":%@ %@ ",empGendereStr,empCmpFName];
        }
        else
        {
            empCmpDescName.text = [NSString stringWithFormat:@":%@ %@ %@",empGendereStr,empCmpFName,empCmpLName];
        }

        
        
        UILabel *empTypeLbl = (UILabel *)[self.view viewWithTag:6];
        
        NSString *empTypeStr = [comEmpDetailsDictionary objectForKey:@"EmpTypeKey"];
        
        if ([empTypeStr isEqualToString:@"Emp"] || [empTypeStr isEqual:[NSNull null]])
        {
            
            empTypeLbl.text = @": ";
            
        }
        else
        {
            empTypeLbl.text = [NSString stringWithFormat:@": %@ ",empTypeStr];
            
        }
        
        
         UILabel *empDepartmentNameLbl = (UILabel *)[self.view viewWithTag:7];
        
        NSString *empDepartmentNameStr = [comEmpDetailsDictionary objectForKey:@"DepartmentNameKey"];
        
        if ([empDepartmentNameStr isEqualToString:@"Emp"] || [empDepartmentNameStr isEqual:[NSNull null]])
        {
            
            empDepartmentNameLbl.text = @": ";
            
        }
        else
        {
            empDepartmentNameLbl.text = [NSString stringWithFormat:@": %@ ",empDepartmentNameStr];
            
        }

        
        UILabel *empShiftNameLbl = (UILabel *)[self.view viewWithTag:8];
        
        NSString *empShiftNameStr = [comEmpDetailsDictionary objectForKey:@"ShiftNameKey"];
        
        if ([empShiftNameStr isEqualToString:@"Emp"] || [empShiftNameStr isEqual:[NSNull null]])
        {
            
            empShiftNameLbl.text = @": ";
            
        }
        else
        {
            empShiftNameLbl.text = [NSString stringWithFormat:@": %@ ",empShiftNameStr];
            
        }
        
        
        UILabel *empScheduleStartEndLbl = (UILabel *)[self.view viewWithTag:9];
        
        NSString *empScheduleStartTime = [comEmpDetailsDictionary objectForKey:@"ScheduleStartKey"];
        NSString *empSchduleEndTime = [comEmpDetailsDictionary objectForKey:@"SchduleEndKey"];
        
        
        if ([empScheduleStartTime isEqualToString:@"Emp"] || [empScheduleStartTime isEqual:[NSNull null]] || [empSchduleEndTime isEqualToString:@"Emp"] || [empSchduleEndTime isEqual:[NSNull null]])
        {
            empScheduleStartEndLbl.text = @": ";
        }
        else
        {
            empScheduleStartEndLbl.text = [NSString stringWithFormat:@": %@ - %@",empScheduleStartTime,empSchduleEndTime];
        }

        
        
        
        
        UILabel *empLunchStartEndLbl = (UILabel *)[self.view viewWithTag:10];
        
        NSString *empLunchStartTime = [comEmpDetailsDictionary objectForKey:@"LunchStartKey"];
        NSString *empLunchEndTime = [comEmpDetailsDictionary objectForKey:@"LunchEndKey"];
        
        
        if ([empLunchStartTime isEqualToString:@"Emp"] || [empLunchStartTime isEqual:[NSNull null]] || [empLunchEndTime isEqualToString:@"Emp"] || [empLunchEndTime isEqual:[NSNull null]])
        {
            empLunchStartEndLbl.text = @": ";
        }
        else
        {
            empLunchStartEndLbl.text = [NSString stringWithFormat:@": %@ - %@",empLunchStartTime,empLunchEndTime];
        }
        
        
        
        
        
        UILabel *empDesgLbl = (UILabel *)[self.view viewWithTag:11];
        
        NSString *empDesignationStr = [comEmpDetailsDictionary objectForKey:@"EmpDesignationKey"];
        
        if ([empDesignationStr isEqualToString:@"Emp"] || [empDesignationStr isEqual:[NSNull null]])
        {
            
            empDesgLbl.text = @": ";
            
        }
        else
        {
            empDesgLbl.text = [NSString stringWithFormat:@": %@ ",empDesignationStr];
            
        }

    
       // tag 12 no value from server(startDateTypeValueLbl)
        UILabel *empStartLbl = (UILabel *)[self.view viewWithTag:12];
        
        NSString *empStartStr = [comEmpDetailsDictionary objectForKey:@"DateOfJoinKey"];
        
        //NSString *empStartStr = @"N/A";
        if ([empStartStr isEqualToString:@"Emp"] || [empStartStr isEqual:[NSNull null]])
        {
            
            empStartLbl.text = @": ";
            
        }
        else
        {
            empStartLbl.text = [NSString stringWithFormat:@": %@ ",empStartStr];
            
        }
        
        UILabel *empActiveLbl = (UILabel *)[self.view viewWithTag:13];
        
        NSString *empActiveStr = [comEmpDetailsDictionary objectForKey:@"EmpActiveKey"];
        
        
        if ([empActiveStr isEqualToString:@"True"])
        {
            empActiveStr = @"Active";
        }
        else
        {
            empActiveStr = @"Inactive";
        }
        
        if ([empActiveStr isEqualToString:@"Emp"] || [empActiveStr isEqual:[NSNull null]])
        {
            
            empActiveLbl.text = @": ";
            
        }
        else
        {
            
            empActiveLbl.text = [NSString stringWithFormat:@": %@ ",empActiveStr];
            
        }

        
//        UILabel *empGenderLbl = (UILabel *)[self.view viewWithTag:14];
//        
//        NSString *empGendereStr = [comEmpDetailsDictionary objectForKey:@"GenderKey"];
//        
//        if ([empGendereStr isEqualToString:@"Emp"] || [empGendereStr isEqual:[NSNull null]])
//        {
//            
//            empGenderLbl.text = @"";
//            
//        }
//        else
//        {
//            empGenderLbl.text = empGendereStr;
//            
//        }

        
        
        
        UILabel *empDateOfBirthLbl = (UILabel *)[self.view viewWithTag:15];
        
        NSString *empDateOfBirthStr = [comEmpDetailsDictionary objectForKey:@"DateOfBirthKey"];
        
        if ([empDateOfBirthStr isEqualToString:@"Emp"] || [empDateOfBirthStr isEqual:[NSNull null]])
        {
            
            empDateOfBirthLbl.text = @": ";
            
        }
        else
        {
            empDateOfBirthLbl.text = [NSString stringWithFormat:@": %@ ",empDateOfBirthStr];
            
        }

        
        
        UILabel *empEmpHomePhoneLbl = (UILabel *)[self.view viewWithTag:16];
        
        NSString *empEmpHomePhoneStr = [comEmpDetailsDictionary objectForKey:@"EmpHomePhoneKey"];
        
        if ([empEmpHomePhoneStr isEqualToString:@"Emp"] || [empEmpHomePhoneStr isEqual:[NSNull null]])
        {
            
            empEmpHomePhoneLbl.text = @": ";
            
        }
        else
        {
            empEmpHomePhoneLbl.text = [NSString stringWithFormat:@": %@ ",empEmpHomePhoneStr];
            
        }
        
        
        UILabel *empEmpPhoneLbl = (UILabel *)[self.view viewWithTag:17];
        
        NSString *empEmpPhoneStr = [comEmpDetailsDictionary objectForKey:@"EmpPhoneKey"];
        
        if ([empEmpPhoneStr isEqualToString:@"Emp"] || [empEmpPhoneStr isEqual:[NSNull null]])
        {
            
            empEmpPhoneLbl.text = @": ";
            
        }
        else
        {
            empEmpPhoneLbl.text = [NSString stringWithFormat:@": %@ ",empEmpPhoneStr];
            
        }

        
        UILabel *empEmpAddressLbl = (UILabel *)[self.view viewWithTag:18];
        
        NSString *empEmpAddressStr = [comEmpDetailsDictionary objectForKey:@"EmpAddressKey"];
        
        NSString *empEmpCityStr = [comEmpDetailsDictionary objectForKey:@"EmpCityKey"];
        NSString *empEmpStateCodeStr = [comEmpDetailsDictionary objectForKey:@"EmpStateCodeKey"];
        NSString *empEmpZipStr = [comEmpDetailsDictionary objectForKey:@"EmpZipKey"];
        
        
        if ([empEmpAddressStr isEqualToString:@"Emp"] || [empEmpAddressStr isEqual:[NSNull null]])
        {
            
            empEmpAddressStr = @"";
            
        }
//        else
//        {
//            empEmpAddressStr = [NSString stringWithFormat:@"%@",empEmpAddressStr];
//            
//        }
        
        if ([empEmpCityStr isEqualToString:@"Emp"] || [empEmpCityStr isEqual:[NSNull null]])
        {
            
            empEmpCityStr = @"";
            
        }
//        else
//        {
//            empEmpCityStr = [NSString stringWithFormat:@"%@",empEmpCityStr];
//            
//        }
        
        if ([empEmpStateCodeStr isEqualToString:@"Emp"] || [empEmpStateCodeStr isEqual:[NSNull null]])
        {
            
            empEmpStateCodeStr = @"";
            
        }
//        else
//        {
//            empEmpStateCodeStr = [NSString stringWithFormat:@"%@",empEmpStateCodeStr];
//            
//        }
        if ([empEmpZipStr isEqualToString:@"Emp"] || [empEmpZipStr isEqual:[NSNull null]])
        {
            
            empEmpZipStr = @"";
            
        }
//        else
//        {
//            empEmpZipStr = [NSString stringWithFormat:@"%@",empEmpZipStr];
//            
//        }
        
        NSString *finalAddString = [NSString stringWithFormat:@"%@, %@, %@, %@",empEmpAddressStr,empEmpCityStr,empEmpStateCodeStr,empEmpZipStr];
        
        empEmpAddressLbl.text = finalAddString;
        [empEmpAddressLbl sizeToFit];
        
        //empEmpAddressLbl.backgroundColor = [UIColor yellowColor];

        
        UILabel *empEmailLbl = (UILabel *)[self.view viewWithTag:19];
        
        NSString *empEmailStr = [comEmpDetailsDictionary objectForKey:@"EmpEmailKey"];
        
        if ([empEmailStr isEqualToString:@"Emp"] || [empEmailStr isEqual:[NSNull null]])
        {
            
            empEmailLbl.text = @": ";
            
        }
        else
        {
            empEmailLbl.text = [NSString stringWithFormat:@": %@ ",empEmailStr];
            
        }

        
        UILabel *empofficeEmailLbl = (UILabel *)[self.view viewWithTag:20];
        
        NSString *empofficeEmailStr = [comEmpDetailsDictionary objectForKey:@"EmpofficeEmailKey"];
        
        if ([empofficeEmailStr isEqualToString:@"Emp"] || [empofficeEmailStr isEqual:[NSNull null]])
        {
            
            empofficeEmailLbl.text = @": ";
            
        }
        else
        {
            empofficeEmailLbl.text = [NSString stringWithFormat:@": %@ ",empofficeEmailStr];
            
        }
        
//        UILabel *empdriverLicenseNumLbl = (UILabel *)[self.view viewWithTag:21];
//        
////        NSString *empdriverLicenseNumValueStr = [comEmpDetailsDictionary objectForKey:@"EmpofficeEmailKey"];
//        
//        NSString *empdriverLicenseNumValueStr = @"N/A";
//        
//        if ([empdriverLicenseNumValueStr isEqualToString:@"Emp"] || [empdriverLicenseNumValueStr isEqual:[NSNull null]])
//        {
//            
//            empdriverLicenseNumLbl.text = @"N/A";
//            
//        }
//        else
//        {
//            empdriverLicenseNumLbl.text = empdriverLicenseNumValueStr;
//            
//        }
//        
//        
//        UILabel *empssnValueLbl = (UILabel *)[self.view viewWithTag:22];
//        
//        //        NSString *empdriverLicenseNumValueStr = [comEmpDetailsDictionary objectForKey:@"EmpofficeEmailKey"];
//        
//        NSString *empdssnValueStr = @"N/A";
//        
//        if ([empdssnValueStr isEqualToString:@"Emp"] || [empdssnValueStr isEqual:[NSNull null]])
//        {
//            
//            empssnValueLbl.text = @"N/A";
//            
//        }
//        else
//        {
//            empssnValueLbl.text = empdssnValueStr;
//            
//        }
//        
//        
        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:successStr delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }

    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



//-(void)ResetPasscodeButtonTapped
//{
//    NSLog(@"Reset Passcode Button Tapped");
//}
//-(void)ResetPasswordButtonTapped
//{
//    NSLog(@"Reset Password Button Tapped");
//}
-(void)EmployeeEditButtonTapped
{
    NSLog(@"Employee Edit button tapped");
    //Emp Edit Tapped
     EmpSaveButton.hidden = NO;
     EmpCancelButton.hidden = NO;
    
    //Emp Details label and text fields
    nameValueLbl.hidden = YES;
    empDetailNameTF.hidden = NO;
    
    businessNameValueLbl.hidden = YES;
    businessNameTF.hidden = NO;
    
    empTypeValueLbl.hidden = YES;
    empTypeTF.hidden = NO;
    
    depmntTypeValueLbl.hidden = YES;
    depmntTypeTF.hidden = NO;
    
    shiftTypeValueLbl.hidden = YES;
    shiftTypeTF.hidden = NO;
    
    scheduleTypeValueLbl.hidden = YES;
    scheduleTimeTF.hidden = NO;
    
    designationTypeValueLbl.hidden = YES;
    designationTypeTF.hidden = NO;
    
    startDateTypeValueLbl.hidden = YES;
    startdateTF.hidden = NO;
    
    activeTypeValueLbl.hidden = YES;
    activeTypeTF.hidden = NO;
    
    
    
    
    
    
    
}
-(void)EmployeeSaveButtonTapped
{
    NSLog(@"Employee Save button tapped");
    
}
-(void)EmployeeCancelButtonTapped
{
    
    
    NSLog(@"Employee Close button tapped");
    
    
    EmpSaveButton.hidden = YES;
    EmpCancelButton.hidden = YES;
    
    //Emp Details edit view
    nameValueLbl.hidden = NO;
    empDetailNameTF.text = nil;
    empDetailNameTF.hidden = YES;
    
    businessNameValueLbl.hidden = NO;
    businessNameTF.text = nil;
    businessNameTF.hidden = YES;
    
    empTypeValueLbl.hidden = NO;
    empTypeTF.text = nil;
    empTypeTF.hidden = YES;
    
    depmntTypeValueLbl.hidden = NO;
    depmntTypeTF.text = nil;
    depmntTypeTF.hidden = YES;
    
    shiftTypeValueLbl.hidden = NO;
    shiftTypeTF.text = nil;
    shiftTypeTF.hidden = YES;
    
    scheduleTypeValueLbl.hidden = NO;
    scheduleTimeTF.text = nil;
    scheduleTimeTF.hidden = YES;
    
    designationTypeValueLbl.hidden = NO;
    designationTypeTF.text = nil;
    designationTypeTF.hidden = YES;
    
    startDateTypeValueLbl.hidden = NO;
    startdateTF.text = nil;
    startdateTF.hidden = YES;
    
    activeTypeValueLbl.hidden = NO;
    activeTypeTF.text = nil;
    activeTypeTF.hidden = YES;
    
    
    
    
}
-(void)PersonEditButtonTapped
{
    NSLog(@"Person Edit button tapped");
    //Person Details edit tapped
    
    persDetailSaveButton.hidden = NO;
    persDetailCancelButton.hidden = NO;
    
    //Person Details label and text fields
    
    perGendValueLbl.hidden = YES;
    perGendTypeTF.hidden = NO;
    
    perDBValueLbl.hidden = YES;
    perDBValueTF.hidden = NO;
    
    phNumValueLbl.hidden = YES;
    phNumValueTF.hidden = NO;
    
    mobNumValueLbl.hidden = YES;
    mobNumValueTF.hidden = NO;
    
}
-(void)persDetailSaveButtonTapped
{
    NSLog(@"Person Save button tapped");
}
-(void)PersonCancelButtonTapped
{
    NSLog(@"Person Cancel button tapped");
    
    persDetailSaveButton.hidden = YES;
    persDetailCancelButton.hidden = YES;
    
    //Person Details label and text field
    perGendValueLbl.hidden = NO;
    perGendTypeTF.text = nil;
    perGendTypeTF.hidden = YES;
    
    perDBValueLbl.hidden = NO;
    perDBValueTF.text = nil;
    perDBValueTF.hidden = YES;
    
    phNumValueLbl.hidden = NO;
    phNumValueTF.text = nil;
    phNumValueTF.hidden = YES;
    
    mobNumValueLbl.hidden = NO;
    mobNumValueTF.text = nil;
    mobNumValueTF.hidden = YES;

}
-(void)SalaryTaxEditButtonTapped
{
    NSLog(@"Salary Tax Edit button tapped");
}
-(void)FirstPersonEditButtonTapped
{
    NSLog(@"First Contact Edit button tapped");
}
-(void)SecondPersonEditButtonTapped
{
    
    NSLog(@"Second Contact Edit button tapped");
    
}
-(void)ThirdPersonEditButtonTapped
{
     NSLog(@"Third Contact Edit button tapped");
    
}
-(void)UserBackButtonTapped
{
    
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"User profile Back button tapped");
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
