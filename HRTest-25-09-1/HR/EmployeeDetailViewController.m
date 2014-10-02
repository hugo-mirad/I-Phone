//
//  EmployeeDetailViewViewController.m
//  HR
//
//  Created by Venkata Chinni on 7/29/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "EmployeeDetailViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#import "NoteViewController.h"
#import "FPPopoverController.h"



@interface EmployeeDetailViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property(strong,nonatomic) AFHTTPClient *networkConnection;
@property(strong,nonatomic) NSMutableData *empMbLogindata;
//for xml parsing

@property(copy,nonatomic) NSString *currentSignInElementValueStr,*currentSignOutElementValueStr;

@property (nonatomic, assign) BOOL SigninImplementation,SignOutImplementation;

@property (nonatomic, assign) BOOL SigninImplementationConnection,SignOutImplementationConnection;
@property (nonatomic, assign) BOOL SigninImplementationXMLParse,SignOutImplementationXMLParse;

@end

@implementation EmployeeDetailViewController

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
    
//    typeofparsing = 1;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    
    
   
    
   
    //comEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"MM/dd/yyyy EEEE"];
    NSString *datestr = [formatter stringFromDate:[NSDate date]];
    
    NSArray* componentsArray = [datestr componentsSeparatedByString:@" "];
    
    Currentdate = [componentsArray objectAtIndex:0];
    Currentday = [componentsArray objectAtIndex:1];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    NSString *strYesterday = [formatter stringFromDate:yesterday];
    
    NSArray* yesterdayArray = [strYesterday componentsSeparatedByString:@" "];
    
    yesterdaydate = [yesterdayArray objectAtIndex:0];
    yesterdayday = [yesterdayArray objectAtIndex:1];
    
    
   // self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1.0];
   
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
        
        topNaviView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        
    }
    
    topNaviView.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:27.0/255.0 blue:67.0/255.0 alpha:1.0];///47, 64, 80//19, 27, 67
    [self.view addSubview:topNaviView];
    
    
    UIImageView *imageview = [[UIImageView alloc] init ];
    
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
        imageview.frame = CGRectMake(20,20, 52, 52);
    }
    imageview.image = [UIImage imageNamed:@"brandLogo.png"];
    [topNaviView addSubview:imageview];
    
    
    
    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(UserMenuButtonTapped)forControlEvents:UIControlEventTouchDown];
    [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"menuicon.png"] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor clearColor]];
    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    menuButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
        menuButton.frame = CGRectMake(270.0, 10.0, 36.0, 26.0);
        }
        else
        {
        menuButton.frame = CGRectMake(270.0, 20.0, 40.0, 30.0);
        }
    }
    else
    {
        menuButton.frame = CGRectMake(680.0, 26.0, 66.0, 44.0);
        
    }
    [topNaviView addSubview:menuButton];
    
    
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    
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
    cmpNameLabel.tag = 302;
    
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;
    
    [topNaviView addSubview:cmpNameLabel];
    
    
    
  
    
    UIView *attBackView = [[UIView alloc ] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    attBackView.Frame  = CGRectMake(12, topNaviView.frame.size.height+10, self.view.frame.size.width-24, 240);
    }
    else
    {
    attBackView.Frame  = CGRectMake(24, topNaviView.frame.size.height+20, self.view.frame.size.width-48, 360);
    }
    attBackView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:247/255.0 alpha:1.0];
    [self.view addSubview:attBackView];
    
    attBackView.layer.cornerRadius = 4;
    attBackView.layer.shadowOffset = CGSizeMake(1, 0);
    attBackView.layer.shadowOpacity = 0.25;
    attBackView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    UIImageView *preArrowImage =[[UIImageView alloc]init ];
    preArrowImage.tag = 2121;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
        preArrowImage.frame = CGRectMake(attBackView.frame.size.width/2-60, 10, 120, 100);
        }
        else
        {
        preArrowImage.frame = CGRectMake(attBackView.frame.size.width/2-60, 15, 120, 100);
        }
    }
    else
    {
         preArrowImage.frame = CGRectMake(attBackView.frame.size.width/2-90, 25, 180, 140);
    }
    
    [attBackView addSubview:preArrowImage];
    preArrowImage.contentMode = UIViewContentModeScaleAspectFit;


    signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signInButton addTarget:self
               action:@selector(SignINTapped)
     forControlEvents:UIControlEventTouchUpInside];
    [signInButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    [signInButton setTitle:@"Attendence" forState:UIControlStateNormal];
    
    signInButton.layer.cornerRadius = 4.0;
    signInButton.tag = 1;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    signInButton.titleLabel.font = [UIFont systemFontOfSize:14];
    signInButton.frame = CGRectMake(attBackView.frame.size.width/2-50.0, 130, 100.0, 30.0);
    }
    else
    {
    signInButton.titleLabel.font = [UIFont systemFontOfSize:20];
    signInButton.frame = CGRectMake(attBackView.frame.size.width/2-80.0, 180, 160.0, 40.0);
    }
    [attBackView addSubview:signInButton];
    
    
    
    UILabel *desgLabel = [[UILabel alloc]init ];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        desgLabel.frame = CGRectMake(10, 170, 122, 22);
        desgLabel.font = [UIFont boldSystemFontOfSize:13];
        desgLabel.text = @"Designation        :";
    }
    else
    {
        desgLabel.frame = CGRectMake(20, 230, 200, 36);
        desgLabel.font = [UIFont boldSystemFontOfSize:20];
        desgLabel.text = @"Designation       :";
    }
    
    
    desgLabel.numberOfLines = 1;
    desgLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    desgLabel.adjustsFontSizeToFitWidth = YES;
    desgLabel.minimumScaleFactor = 10.0f/12.0f;
    desgLabel.clipsToBounds = YES;
    desgLabel.backgroundColor = [UIColor clearColor];
    desgLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    desgLabel.textAlignment = NSTextAlignmentLeft;
    [attBackView addSubview:desgLabel];
    
    
    UILabel *desgNameLabel = [[UILabel alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    desgNameLabel.Frame = CGRectMake(120, 170, 160, 22);//(150, 242, 150, 22)
        desgNameLabel.font = [UIFont systemFontOfSize:12];
    }
    else
    {
    desgNameLabel.Frame = CGRectMake(230, 230, 300, 36);
        desgNameLabel.font = [UIFont systemFontOfSize:18];
    }
    desgNameLabel.tag = 301;
    desgNameLabel.numberOfLines = 1;
    desgNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    desgNameLabel.adjustsFontSizeToFitWidth = YES;
    desgNameLabel.minimumScaleFactor = 10.0f/12.0f;
    desgNameLabel.clipsToBounds = YES;
    desgNameLabel.backgroundColor = [UIColor clearColor];
    desgNameLabel.textColor = [UIColor grayColor];
    desgNameLabel.textAlignment = NSTextAlignmentLeft;
    [attBackView addSubview:desgNameLabel];
    
    
    UILabel *schTimeLabel = [[UILabel alloc]init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    schTimeLabel.Frame = CGRectMake(10, 190, 122, 22);//(20, 264, 122, 22)
        schTimeLabel.font = [UIFont boldSystemFontOfSize:13];
        schTimeLabel.text = @"Schedule Time   :";
    }
    else
    {
        schTimeLabel.Frame = CGRectMake(20, 266, 200, 36);
        schTimeLabel.font = [UIFont boldSystemFontOfSize:18];
        schTimeLabel.text = @"Schedule Time     :";
        
    }
    
    
    schTimeLabel.numberOfLines = 1;
    schTimeLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    schTimeLabel.adjustsFontSizeToFitWidth = YES;
    schTimeLabel.minimumScaleFactor = 10.0f/12.0f;
    schTimeLabel.clipsToBounds = YES;
    schTimeLabel.backgroundColor = [UIColor clearColor];
    schTimeLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    schTimeLabel.textAlignment = NSTextAlignmentLeft;
    [attBackView addSubview:schTimeLabel];
   
    
    UILabel *schTLabel = [[UILabel alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    schTLabel.Frame = CGRectMake(120, 190, 160, 22);//(150, 264, 150, 22)
        schTLabel.font = [UIFont systemFontOfSize:12];
    }
    else
    {
    schTLabel.Frame = CGRectMake(230, 266, 200, 36);
        schTLabel.font = [UIFont systemFontOfSize:18];
    }
//
    schTLabel.tag = 300;
    schTLabel.numberOfLines = 1;
    schTLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    schTLabel.adjustsFontSizeToFitWidth = YES;
    schTLabel.minimumScaleFactor = 10.0f/12.0f;
    schTLabel.clipsToBounds = YES;
    schTLabel.backgroundColor = [UIColor clearColor];
    schTLabel.textColor = [UIColor grayColor];
    schTLabel.textAlignment = NSTextAlignmentLeft;
    [attBackView addSubview:schTLabel];
    
    
    UILabel *lunchBreakLabel = [[UILabel alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    lunchBreakLabel.Frame = CGRectMake(10, 210, 122, 22);//(150, 264, 150, 22)
         lunchBreakLabel.font = [UIFont boldSystemFontOfSize:13];
        lunchBreakLabel.text = @"Lunch Break       :";
    }
    else
    {
     lunchBreakLabel.Frame = CGRectMake(20, 306, 200, 36);
         lunchBreakLabel.font = [UIFont boldSystemFontOfSize:18];
        lunchBreakLabel.text = @"Lunch Break         :";
    }
    
   
    lunchBreakLabel.numberOfLines = 1;
    lunchBreakLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    lunchBreakLabel.adjustsFontSizeToFitWidth = YES;
    lunchBreakLabel.minimumScaleFactor = 10.0f/12.0f;
    lunchBreakLabel.clipsToBounds = YES;
    lunchBreakLabel.backgroundColor = [UIColor clearColor];
    lunchBreakLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    lunchBreakLabel.textAlignment = NSTextAlignmentLeft;
    [attBackView addSubview:lunchBreakLabel];
    
    UILabel *lunchBreakValueLabel = [[UILabel alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    lunchBreakValueLabel.frame = CGRectMake(120, 210, 160, 22);
        lunchBreakValueLabel.font = [UIFont systemFontOfSize:12];

    }
    else
    {
     lunchBreakValueLabel.frame = CGRectMake(230, 306, 200, 36);
        lunchBreakValueLabel.font = [UIFont systemFontOfSize:18];

    }
    
   // lunchBreakValueLabel.text = @"08.00 AM - 05.00 PM";
    lunchBreakValueLabel.tag = 666;
    lunchBreakValueLabel.numberOfLines = 1;
    lunchBreakValueLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    lunchBreakValueLabel.adjustsFontSizeToFitWidth = YES;
    lunchBreakValueLabel.minimumScaleFactor = 10.0f/12.0f;
    lunchBreakValueLabel.clipsToBounds = YES;
    lunchBreakValueLabel.backgroundColor = [UIColor clearColor];
    lunchBreakValueLabel.textColor = [UIColor grayColor];
    lunchBreakValueLabel.textAlignment = NSTextAlignmentLeft;
    [attBackView addSubview:lunchBreakValueLabel];
    
    
    
    
    
    
    
    
    hisBackView = [[UIView alloc ] init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
             hisBackView.Frame = CGRectMake(12, 300, self.view.frame.size.width-24, 30);
        }
        else
        {
             hisBackView.Frame = CGRectMake(12, 320, self.view.frame.size.width-24, 30);
        }
        
   
    }
    else
    {
        hisBackView.Frame = CGRectMake(24, 480, self.view.frame.size.width-48, 50);
    }
    hisBackView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:247/255.0 alpha:1.0];
    [self.view addSubview:hisBackView];
    
    hisBackView.layer.cornerRadius = 4;
    hisBackView.layer.shadowOffset = CGSizeMake(1, 0);
    hisBackView.layer.shadowOpacity = 0.25;
    hisBackView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        historyLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 1, 80, 28)];//(150, 264, 150, 22)
        historyLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    else
    {
         historyLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 80, 30)];
        historyLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    historyLabel.text = @" History ";
    
    historyLabel.numberOfLines = 1;
    historyLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    historyLabel.adjustsFontSizeToFitWidth = YES;
    historyLabel.minimumScaleFactor = 10.0f/12.0f;
    historyLabel.clipsToBounds = YES;
    historyLabel.backgroundColor = [UIColor clearColor];
    historyLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];//;[UIColor whiteColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];//rgb(85,85,85)
    historyLabel.textAlignment = NSTextAlignmentLeft;
    [hisBackView addSubview:historyLabel];
    
    historyLabel.layer.cornerRadius = 3;

    
    //[self EmpDetailsImplementation];
    
   // [self historyButtonTapped];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    historyButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0, 3.0, 30.0, 28.0)];
        
    }
    else
    {
    historyButton = [[UIButton alloc] initWithFrame:CGRectMake(630.0, 5.0, 50.0, 40.0)];
    }
    [historyButton setTag:0];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"up_arrow.png"] forState:UIControlStateSelected];//UIControlStateSelected//checked_checkbox.png
    [historyButton setBackgroundImage:[UIImage imageNamed:@"down_arrow.png"] forState:UIControlStateNormal];//UIControlStateNormal//unchecked_checkbox.png
    [historyButton addTarget:self action:@selector(HistorybuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [hisBackView addSubview:historyButton];

    
    signInButton.userInteractionEnabled = NO;
    historyButton.userInteractionEnabled = NO;
    menuButton.userInteractionEnabled = NO;
    
    
    
    
    
    NSURL *scriptUrl = [NSURL URLWithString:@"http://apps.wegenerlabs.com/hi.html"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
    {
         NSLog(@"Device is connected to the internet");
    }
    else
    {
        
        NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *dic =  [tempDefaults objectForKey:@"comEmpDetailsDicKey"];
        
        UILabel *cmpNameValueLabel = (UILabel *)[self.view viewWithTag:302];
        NSString *strEmpFirstName = [dic objectForKey:@"BusinessFnameKey"];
        NSString *strLastName = [dic objectForKey:@"BusinessLnameKey"];
        NSString *empFullName = [NSString stringWithFormat:@"%@ %@",strEmpFirstName,strLastName];
        
        if ([strLastName isEqualToString:@"Emp"] || strLastName.length == 0)
        {
            cmpNameValueLabel.text = strEmpFirstName;
        }
        else
        {
            cmpNameValueLabel.text = empFullName;
        }
        UIImageView *imgView = (UIImageView *)[self.view viewWithTag:2121];
        //    NSString *imgURL = [dic objectForKey:@"EmpPhoto"];
        //    NSString *urlStr = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //
        //    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //    [defaults setObject:data forKey:@"imgURLKey"];
        //    [defaults synchronize];
        //
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSData *data1 = [defaults objectForKey:@"imgURLKey"];
                if (data1  == nil)
                {
                    [imgView setImage:[UIImage imageNamed:@"user.png"]];
                }
                else
                {
                    [imgView setImage:[UIImage imageWithData:data1]];
                }
                
                
                
            });
        });
        
        UILabel *desgValueLabel = (UILabel *)[self.view viewWithTag:301];
        NSString *desgName = [dic objectForKey:@"EmpDesignationKey"];
        if ([desgName isEqualToString:@"Emp"])
        {
            desgValueLabel.text =@"-";
        }
        else
        {
            desgValueLabel.text = desgName;
        }
        
        UILabel *schValueLabel = (UILabel *)[self.view viewWithTag:300];
        
        NSString *scheduleStartTime = [dic objectForKey:@"ScheduleStartKey"];
        NSString *scheduleEndTime = [dic objectForKey:@"SchduleEndKey"];
        
        
        if ([scheduleStartTime isEqualToString:@"Emp"] || scheduleStartTime == NULL) {
            scheduleStartTime = @"N/A";
        }
        if ([scheduleEndTime isEqualToString:@"Emp"] || scheduleEndTime == NULL) {
            scheduleEndTime = @"N/A";
        }
        NSString *schEmpTime = [NSString stringWithFormat:@"%@ - %@",scheduleStartTime,scheduleEndTime];
        
        
        schValueLabel.text = schEmpTime;
        
        lunchStartTime = [dic objectForKey:@"LunchStartKey"];
        lunchEndTime = [dic objectForKey:@"LunchEndKey"];
        
        if ([lunchStartTime isEqualToString:@"Emp"] || lunchStartTime == NULL) {
            lunchStartTime = @"N/A";
        }
        if ([lunchEndTime isEqualToString:@"Emp"] || lunchEndTime == NULL) {
            lunchEndTime = @"N/A";
        }
        
        NSString *lunchBreakTime = [NSString stringWithFormat:@"%@ - %@",lunchStartTime,lunchEndTime];
        
        UILabel *lunchBreakValueLabel = (UILabel *)[self.view viewWithTag:666];//(150, 264, 150, 22)
        lunchBreakValueLabel.text = lunchBreakTime;
        
         NSLog(@"Device is not connected to the internet");
    }
//
    
    
    
    
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_locationManager startUpdatingLocation];
    
    [self EmpDetailsImplementation];
}
-(void)EmpDetailsImplementation
{
    typeofparsing = 2323232;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    
    
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *signInDateWithTimeStr =[dateFormatter stringFromDate:date];
    
     NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<GetEmployeeDetailsBYCurrentDate xmlns=\"http://tempuri.org/\">"
    "<companyCode>%@</companyCode>"
    "<empCompanyID>%@</empCompanyID>"
    "<CurrentDate>%@</CurrentDate>"
    "</GetEmployeeDetailsBYCurrentDate>"
    "</soap:Body>"
    "</soap:Envelope>",cmpCode,empCmpyID,signInDateWithTimeStr];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetEmployeeDetailsBYCurrentDate" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection =
    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    
    if( theConnection )
    {
        webData = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }

    
    
    
    
    
}

-(void)HistorybuttonSelected:(id)sender{
    
    
    switch ([sender tag]) {
        case 0:
            if([historyButton isSelected]==YES)
            {
                [historyButton setSelected:NO];
                
                todaySchView.hidden = YES;
                
                tableViewData.hidden  = YES;
                
                [tableViewData reloadData];
               // saveDefaults = YES;
                
            }
            else
            {
             //   saveDefaults = NO;
                
              //  yesForLoad = NO;
               // [self EmployeeSignInSignOutTVImplementation];
                [self tableViewCreating];
                
                [self historyButtonTapped];
                todaySchView.hidden = NO;
                
                tableViewData.hidden  = NO;
                
                [tableViewData reloadData];
                
                [historyButton setSelected:YES];
            }
            
            break;
        default:
            break;
    }
    
}
-(void)tableViewCreating
{
    if (tableViewData) {
        [tableViewData reloadData];
    }else{
        
        
        tableViewData = [[UITableView alloc] init];
        
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            tableViewData.frame = CGRectMake(12, hisBackView.frame.origin.y+hisBackView.frame.size.height, self.view.frame.size.width-24, self.view.frame.size.height-hisBackView.frame.origin.y-hisBackView.frame.size.height);
            UIView *backView = [[UIView alloc] init];
            [backView setBackgroundColor:[UIColor clearColor]];
            [tableViewData setBackgroundView:backView];
            
        }
        else
        {
            tableViewData.frame = CGRectMake(12, hisBackView.frame.origin.y+hisBackView.frame.size.height+2, self.view.frame.size.width-24, self.view.frame.size.height-hisBackView.frame.origin.y-hisBackView.frame.size.height);
            //_tableView.frame = CGRectMake(0, todaySchView.frame.origin.y+todaySchView.frame.size.height, self.view.frame.size.width, 144);
            tableViewData.backgroundColor = [UIColor clearColor];
        }
        
        }
        else
        {
            
            tableViewData.frame = CGRectMake(24, hisBackView.frame.origin.y+hisBackView.frame.size.height+2, self.view.frame.size.width-48, self.view.frame.size.height-hisBackView.frame.origin.y-hisBackView.frame.size.height);
            //_tableView.frame = CGRectMake(0, todaySchView.frame.origin.y+todaySchView.frame.size.height, self.view.frame.size.width, 144);
           // tableViewData.backgroundColor = [UIColor clearColor];
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                UIView *backView = [[UIView alloc] init];
                [backView setBackgroundColor:[UIColor clearColor]];
                [tableViewData setBackgroundView:backView];
            }
            else
            {
                tableViewData.backgroundColor = [UIColor clearColor];
            }
            
        }
        
        tableViewData.dataSource = self;
        tableViewData.delegate = self;
        [self.view addSubview:tableViewData];
       // tableViewData.backgroundColor = [UIColor clearColor];
        tableViewData.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        tableViewData.hidden  = NO;
        todaySchView.hidden = NO;
        [tableViewData setShowsVerticalScrollIndicator:NO];
    }
    
    [tableViewData reloadData];
}
-(void)historyButtonTapped
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [_locationManager startUpdatingLocation];
    
    typeofparsing = 2000;
     NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
   
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *signInDateWithTimeStr =[dateFormatter stringFromDate:date];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *StrType  = @"Emp";
    NSString *StrStart = @"Emp";
    
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                            " <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                            " <soap:Body>"
                             "<GetAttendanceReport xmlns=\"http://tempuri.org/\">"
                             "<empCompanyID>%@</empCompanyID>"
                             "<companyCode>%@</companyCode>"
                            " <currentDate>%@</currentDate>"
                             "<longitude>%@</longitude>"
                             "<latitude>%@</latitude>"
                            " <mobileName>%@</mobileName>"
                            " <deviceCode>%@</deviceCode>"
                            " <authenticationID>%@</authenticationID>"
                            " <type>%@</type>"
                             "<start>%@</start>"
                             "</GetAttendanceReport>"
                             "</soap:Body>"
                             "</soap:Envelope>",empCmpyID,cmpCode,signInDateWithTimeStr,logitudeCmp,latitudeCmp,mobileName,deviceID,authID,StrType,StrStart];
    
     NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
   // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetAttendanceReport" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection =
    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    
    if( theConnection )
    {
        webData = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }

    
}


-(void)SignINTapped
{
    [_locationManager startUpdatingLocation];
    
    NSString *fullName = [_CmpEmpDetailsDic objectForKey:@"LoginEmpBusinessnameKey"];
    
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:fullName
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Submit", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        // Alert style customization
        alert.tag = 10;
    [[alert textFieldAtIndex:0] setPlaceholder:@"Note(optional)"];
    
        
        [alert show];
    
        
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    errorAlert.tag = 30;
    [errorAlert show];
}


-(void)AttendenceImplementation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    typeofparsing = 101;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
     NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *signInDateWithTimeStr =[dateFormatter stringFromDate:date];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
//    NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
//    NSString *secureCodeStr = [defaultsLocal objectForKey:@"empsecureCodeTextFielKey"];
//    
//    NSString *StrSignInPasscode = secureCodeStr;
#warning secCode
    NSString *StrSignInPasscode = signInPasscode;
    NSString *StrSsignInNotes = signInNotes;
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap:Body>"
                             "<setEmpSignInOutMobile xmlns=\"http://tempuri.org/\">"
                             "<CompanyCode>%@</CompanyCode>"
                             "<empCompanyID>%@</empCompanyID>"
                             "<Passcode>%@</Passcode>"
                             "<signInDate>%@</signInDate>"
                             "<Notes>%@</Notes>"
                             "<longitude>%@</longitude>"
                             "<latitude>%@</latitude>"
                             "<mobileName>%@</mobileName>"
                             "<deviceCode>%@</deviceCode>"
                             "<authenticationID>%@</authenticationID>"
                             "</setEmpSignInOutMobile>"
                             "</soap:Body>"
                             "</soap:Envelope>",cmpCode,empCmpyID,StrSignInPasscode,signInDateWithTimeStr,StrSsignInNotes,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below

   // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/setEmpSignInOutMobile" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection =
    [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if( theConnection )
    {
        webData = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL");
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
    
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"%+.4f",
                                  newLocation.coordinate.longitude];
    
    longitudeStr = currentLongitude;
    
    
    
if (typeofparsing == 10)
    {
        [self AttendenceImplementation];
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
    
    
//    NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
//    
//    NSMutableDictionary *dic =  [tempDefaults objectForKey:@"comEmpDetailsDicKey"];
//    
//    UILabel *cmpNameValueLabel = (UILabel *)[self.view viewWithTag:302];
//    NSString *strEmpFirstName = [dic objectForKey:@"BusinessFnameKey"];
//    NSString *strLastName = [dic objectForKey:@"BusinessLnameKey"];
//    NSString *empFullName = [NSString stringWithFormat:@"%@ %@",strEmpFirstName,strLastName];
//    
//    if ([strLastName isEqualToString:@"Emp"] || strLastName.length == 0)
//    {
//        cmpNameValueLabel.text = strEmpFirstName;
//    }
//    else
//    {
//        cmpNameValueLabel.text = empFullName;
//    }
//    UIImageView *imgView = (UIImageView *)[self.view viewWithTag:2121];
////    NSString *imgURL = [dic objectForKey:@"EmpPhoto"];
////    NSString *urlStr = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////    
////    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
////    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////    [defaults setObject:data forKey:@"imgURLKey"];
////    [defaults synchronize];
////    
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSData *data1 = [defaults objectForKey:@"imgURLKey"];
//            if (data1  == nil)
//            {
//                [imgView setImage:[UIImage imageNamed:@"user.png"]];
//            }
//            else
//            {
//                [imgView setImage:[UIImage imageWithData:data1]];
//            }
//            
//            
//            
//        });
//    });
//    
//    UILabel *desgValueLabel = (UILabel *)[self.view viewWithTag:301];
//    NSString *desgName = [dic objectForKey:@"EmpDesignationKey"];
//    if ([desgName isEqualToString:@"Emp"])
//    {
//        desgValueLabel.text =@"-";
//    }
//    else
//    {
//        desgValueLabel.text = desgName;
//    }
//    
//    UILabel *schValueLabel = (UILabel *)[self.view viewWithTag:300];
//    
//    NSString *scheduleStartTime = [dic objectForKey:@"ScheduleStartKey"];
//    NSString *scheduleEndTime = [dic objectForKey:@"SchduleEndKey"];
//    
//    
//    if ([scheduleStartTime isEqualToString:@"Emp"] || scheduleStartTime == NULL) {
//        scheduleStartTime = @"N/A";
//    }
//    if ([scheduleEndTime isEqualToString:@"Emp"] || scheduleEndTime == NULL) {
//        scheduleEndTime = @"N/A";
//    }
//    NSString *schEmpTime = [NSString stringWithFormat:@"%@ - %@",scheduleStartTime,scheduleEndTime];
//    
//    
//    schValueLabel.text = schEmpTime;
//    
//    lunchStartTime = [dic objectForKey:@"LunchStartKey"];
//    lunchEndTime = [dic objectForKey:@"LunchEndKey"];
//    
//    if ([lunchStartTime isEqualToString:@"Emp"] || lunchStartTime == NULL) {
//        lunchStartTime = @"N/A";
//    }
//    if ([lunchEndTime isEqualToString:@"Emp"] || lunchEndTime == NULL) {
//        lunchEndTime = @"N/A";
//    }
//    
//    NSString *lunchBreakTime = [NSString stringWithFormat:@"%@ - %@",lunchStartTime,lunchEndTime];
//    
//    UILabel *lunchBreakValueLabel = (UILabel *)[self.view viewWithTag:666];//(150, 264, 150, 22)
//    lunchBreakValueLabel.text = lunchBreakTime;
    
  
    [self webServiceCallToSaveDataFailedWithError:error];
    NSLog(@"ERROR with theConenction");
    
    
    
    
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   NSString *strXMl = [[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"XML is : %@", strXMl);
    
    signInButton.userInteractionEnabled = YES;
    historyButton.userInteractionEnabled = YES;
    menuButton.userInteractionEnabled = YES;
    
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
}
#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
        if ([elementName isEqualToString:@"setEmpSignInOutMobileResult"])
        {
            
        }
    
        else if ([elementName isEqualToString:@"GetAttendanceReportResult"])
        {
            if (arrayParsedList)
            {
                arrayParsedList = nil;
            }
            arrayParsedList = [[NSMutableArray alloc]init];
        }
    
    
        else if ([elementName isEqualToString:@"mobileEmpInfo"])
        {
            if (objEmp)
            {
                objEmp = nil;
            }
            
            objEmp = [[EmpScheduledDetailsBO alloc]init];
        }
        else if ([elementName isEqualToString:@"GetEmployeeDetailsBYCurrentDateResult"])
        {
           
        }
        else if ([elementName isEqualToString:@"empProfileInfo"])
        {
            _currentelementValueStr = [[NSString alloc] init];
            comEmpDetailsDic = [[NSMutableDictionary alloc] init];
        }
    
    
    
        
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
   // NSLog(@"currentElementValue--%@,string--%@",currentElementValue,string);
    if (!currentElementValue)
    {
        currentElementValue = [[NSMutableString alloc]initWithString:string];
    }
    else
    {
        [currentElementValue appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    
    currentElementValue = [[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]mutableCopy];
    currentElementValue = [[currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""]mutableCopy];
    
    
    
     if ([elementName isEqualToString:@"GetEmployeeDetailsBYCurrentDateResult"])
    {
        
    }
    else if ([elementName isEqualToString:@"empProfileInfo"])
    {
      //  _currentelementValueStr = [[NSString alloc] init];
        // comEmpDetailsDic = [[NSMutableDictionary alloc] init];
    }
    
    
    
    if ([elementName isEqualToString:@"AASuccess"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"AASuccessKey"];
    }
    else if ([elementName isEqualToString:@"EmpFname"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"EmpFnameKey"];
    }
    else if ([elementName isEqualToString:@"BusinessFname"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"BusinessFnameKey"];
    }
    else if ([elementName isEqualToString:@"BusinessLname"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"BusinessLnameKey"];
    }
    else if ([elementName isEqualToString:@"ScheduleStart"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"ScheduleStartKey"];
    }
    else if ([elementName isEqualToString:@"SchduleEnd"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"SchduleEndKey"];
    }
    else if ([elementName isEqualToString:@"LunchStart"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"LunchStartKey"];
    }
    else if ([elementName isEqualToString:@"LunchEnd"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"LunchEndKey"];
    }
    else if ([elementName isEqualToString:@"EmpPhoto"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"EmpPhoto"];
    }
    else if ([elementName isEqualToString:@"EmpDesignation"])
    {
        [comEmpDetailsDic setObject:currentElementValue forKey:@"EmpDesignationKey"];
    }
    
    
    
    
    
   else if ([elementName isEqualToString:@"setEmpSignInOutMobileResult"])//setEmpSignInOutMobileResult
        
    {
        if ([currentElementValue caseInsensitiveCompare:@"Signed Out"] == NSOrderedSame)
        {
            UIAlertView *alertt = [[UIAlertView alloc]initWithTitle:@"" message:@"Successfully  Signed Out" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertt show];

        }
        else if ([currentElementValue caseInsensitiveCompare:@"Signed In"] == NSOrderedSame )
        {
            UIAlertView *alertt = [[UIAlertView alloc]initWithTitle:@"" message:@"Successfully  Signed In" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertt show];
        }
        else if ([currentElementValue caseInsensitiveCompare:@"Invalid"] == NSOrderedSame )
        {
            UIAlertView *alertt = [[UIAlertView alloc]initWithTitle:@"" message:@"Secure code you have entered is incorrect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertt show];
        }
        else
        {
            UIAlertView *alertt = [[UIAlertView alloc]initWithTitle:currentElementValue message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertt show];
       }
    }
    else if ([elementName isEqualToString:@"GetAttendanceReportResult"])
    {
        
    }
    else if ([elementName isEqualToString:@"mobileEmpInfo"])
    {
        [arrayParsedList addObject:objEmp];
    }
    else if ([elementName isEqualToString:@"AaSuccess1"])
    {
        objEmp.strAaSuccess1 = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpCompanyID"])
    {
        objEmp.strEmpCompanyID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Designation"])
    {
        objEmp.strDesignation = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpID"])
    {
        objEmp.strEmpID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"BusinessFname"])
    {
        objEmp.strBusinessFname = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ScheduleStart"])
    {
        objEmp.strScheduleStart = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ScheduleEnd"])
    {
        objEmp.strScheduleEnd = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Photo"])
    {
        objEmp.strPhoto = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignInTime"])
    {
        objEmp.strSignInTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignOutTime"])
    {
        objEmp.strSignOutTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"AttendID"])
    {
        objEmp.strAttendID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Day"])
    {
        objEmp.strDay = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignInDate"])
    {
        objEmp.strOnlySignInTime = currentElementValue;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        
        NSDate *dateStart = [formatter dateFromString:objEmp.strOnlySignInTime];
        
        objEmp.dateSignInTime = dateStart;
    }
    else if ([elementName isEqualToString:@"SignOutDate"])
    {
        objEmp.strOnlySignOutTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Notes"])
    {
        objEmp.strNotes = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ModifiedNotes"])
    {
        objEmp.strModifiedNotes = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Date"])
    {
        
        objEmp.strDate = currentElementValue;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        
        NSDate *dateStart = [formatter dateFromString:objEmp.strDate];
        
        objEmp.dateOnly = dateStart;
    }
    
    
//    else if ([elementName isEqualToString:@"LunchStart"])
//    {
//        objEmp.strLunchStart = currentElementValue;
//        
//        
//       
//    }
//    else if ([elementName isEqualToString:@"LunchEnd"])
//    {
//        objEmp.strLunchEnd = currentElementValue;
//        
//        
//    }

    
   // NSLog(@"currentElementValue--%@",currentElementValue);
    
    currentElementValue = nil;
    //NSLog(@"currentElementValue--%@",currentElementValue);

    
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    
    NSLog(@"[parseError code] %ld \n [[parser parserError] localizedDescription] %@\n [parser lineNumber] %d  \n [parser columnNumber] %d", (long)[parseError code],[[parser parserError] localizedDescription], [parser lineNumber],[parser columnNumber]);
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    //Success-11263
    
    
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    
    signInButton.userInteractionEnabled = YES;
    historyButton.userInteractionEnabled = YES;
    menuButton.userInteractionEnabled = YES;
    
    if (typeofparsing == 101)
    {
        [self historyButtonTapped];
    }
    else if ( typeofparsing == 2000)
    {
        NSString *aaSuccess1Str = objEmp.strAaSuccess1;

        if ([aaSuccess1Str isEqualToString:@"Failed"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Unable to process the request due to Server/Network Problem" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else if ([aaSuccess1Str caseInsensitiveCompare:@"no records found"] == NSOrderedSame)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:aaSuccess1Str delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else
        {

        if (tableViewData)
        {
            [tableViewData reloadData];
        }
#warning Here i'm commenting nsorder to display the tableview... check after if incorrect
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateOnly" ascending:NO];
        [arrayParsedList sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        }
    }
    
    if (typeofparsing == 2323232)
    {
        
        NSUserDefaults *dicUserDefaults = [NSUserDefaults standardUserDefaults];
        [dicUserDefaults setObject:comEmpDetailsDic  forKey:@"comEmpDetailsDicKey"];
        [dicUserDefaults synchronize];
        
        UILabel *cmpNameValueLabel = (UILabel *)[self.view viewWithTag:302];
        
        NSString *strEmpFirstName = [comEmpDetailsDic objectForKey:@"BusinessFnameKey"];
        NSString *strLastName = [comEmpDetailsDic objectForKey:@"BusinessLnameKey"];
        NSString *empFullName = [NSString stringWithFormat:@"%@ %@",strEmpFirstName,strLastName];
        
        
        if ([strLastName isEqualToString:@"Emp"] || strLastName.length == 0)
        {
            cmpNameValueLabel.text = strEmpFirstName;
        }else
            
        {
            cmpNameValueLabel.text = empFullName;
            
        }
        
        UIImageView *imgView = (UIImageView *)[self.view viewWithTag:2121];
        NSString *imgURL = [comEmpDetailsDic objectForKey:@"EmpPhoto"];
        NSString *urlStr = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"imgURLKey"];
        [defaults synchronize];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSData *data1 = [defaults objectForKey:@"imgURLKey"];
                if (data1  == nil)
                {
                    [imgView setImage:[UIImage imageNamed:@"user.png"]];
                }
                else
                {
                    [imgView setImage:[UIImage imageWithData:data1]];
                }
                
                
                
            });
        });
        
        UILabel *desgValueLabel = (UILabel *)[self.view viewWithTag:301];
        NSString *desgName = [comEmpDetailsDic objectForKey:@"EmpDesignationKey"];
        if ([desgName isEqualToString:@"Emp"])
        {
            desgValueLabel.text =@"-";
        }
        else
        {
            desgValueLabel.text = desgName;
        }
        
        UILabel *schValueLabel = (UILabel *)[self.view viewWithTag:300];
        
        NSString *scheduleStartTime = [comEmpDetailsDic objectForKey:@"ScheduleStartKey"];
        NSString *scheduleEndTime = [comEmpDetailsDic objectForKey:@"SchduleEndKey"];
        
        
        if ([scheduleStartTime isEqualToString:@"Emp"] || scheduleStartTime == NULL) {
            scheduleStartTime = @"N/A";
        }
        if ([scheduleEndTime isEqualToString:@"Emp"] || scheduleEndTime == NULL) {
            scheduleEndTime = @"N/A";
        }
        NSString *schEmpTime = [NSString stringWithFormat:@"%@ - %@",scheduleStartTime,scheduleEndTime];
        
        
        schValueLabel.text = schEmpTime;
        
        lunchStartTime = [comEmpDetailsDic objectForKey:@"LunchStartKey"];
        lunchEndTime = [comEmpDetailsDic objectForKey:@"LunchEndKey"];
        
        if ([lunchStartTime isEqualToString:@"Emp"] || lunchStartTime == NULL) {
            lunchStartTime = @"N/A";
        }
        if ([lunchEndTime isEqualToString:@"Emp"] || lunchEndTime == NULL) {
            lunchEndTime = @"N/A";
        }
        
        NSString *lunchBreakTime = [NSString stringWithFormat:@"%@ - %@",lunchStartTime,lunchEndTime];
        
        UILabel *lunchBreakValueLabel = (UILabel *)[self.view viewWithTag:666];//(150, 264, 150, 22)
        lunchBreakValueLabel.text = lunchBreakTime;
        
    }
    

    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView.tag == 30)
    {
       
        
    }
    else if (alertView.tag == 40)
    {
        if (buttonIndex== 0)
        {
            
           
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }

        
    }
  else if (alertView.tag == 10)
    {
        if (buttonIndex == 1)
        {
            
           signInNotes = [NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text];
            
            NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
            NSString *secureCodeStr = [defaultsLocal objectForKey:@"empsecureCodeTextFielKey"];

            signInPasscode = secureCodeStr;
            
                NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
            
               // typeofparsing = 10;
                [self AttendenceImplementation];
            }
    }

    else
    {
        if (buttonIndex == 1)
        {
            
            signInNotes = [NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text];

            NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
            NSString *secureCodeStr = [defaultsLocal objectForKey:@"empsecureCodeTextFielKey"];
            signInPasscode =  secureCodeStr;

            
                NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
            
                typeofparsing = 11;
               [_locationManager startUpdatingLocation];
     
        }
    }
}

- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    
    signInButton.userInteractionEnabled = YES;
    historyButton.userInteractionEnabled = YES;
    menuButton.userInteractionEnabled = YES;
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.tag = 40;
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

-(void)UserMenuButtonTapped
{
    UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewID"];
    
    [self.navigationController pushViewController:objAddContactViewCon animated:YES];
    
}
#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // return number of rows
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayParsedList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    return 38;
    }
    else
    {
    return 48;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return cell
    
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        nameLabel.Frame = CGRectMake(10.0, 9.0, 100.0, 20.0);
             nameLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
        nameLabel.Frame = CGRectMake(26.0, 9.0, 160.0, 30.0);
             nameLabel.font = [UIFont systemFontOfSize:18];
        }
        [nameLabel setTag:2];
       
        nameLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *nameLabel1 = [[UILabel alloc] init ];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            nameLabel1.frame = CGRectMake(90.0, 9.0, 140.0, 20.0);
            nameLabel1.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            nameLabel1.frame = CGRectMake(240.0, 9.0, 200.0, 30.0);
            nameLabel1.font = [UIFont systemFontOfSize:18];
        }
        [nameLabel1 setTag:3];
        
        nameLabel1.textColor = [UIColor blackColor];//[UIColor colorWithRed:239.0/255.0 green:83.0/255.0 blue:82.0/255.0 alpha:1.0];
        [nameLabel1 setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabel1];

        
//        UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//        {
//            noteButton.frame = CGRectMake(250, 9, 30, 20);
//        }
//        else
//        {
//            noteButton.frame = CGRectMake(620, 9, 32, 32);
//        }
//        noteButton.tag = 5;
//        noteButton.layer.borderWidth = 0.25;
//        noteButton.layer.cornerRadius = 4;
//        [noteButton.layer setMasksToBounds:YES];
//        [noteButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
//        
//        UIImage *btnImage = [UIImage imageNamed:@"Note.png"];
//        [noteButton setImage:btnImage forState:UIControlStateNormal];
//        [cell.contentView addSubview:noteButton];
        
        
        UIImageView *img = [[UIImageView alloc] init];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            img.frame = CGRectMake(250, 9, 30, 20);
        }
        else
        {
            img.frame = CGRectMake(640, 9, 32, 32);
        }
        img.tag = 5;
        
        UIImage *btnImage = [UIImage imageNamed:@"Note.png"];
        [img setImage:btnImage];
        img.layer.borderWidth = 0.25;
        img.layer.cornerRadius = 4;
        [img.layer setMasksToBounds:YES];
        [cell.contentView addSubview:img];
        
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
  
    }
    else
    {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
       
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 1)];
    separator.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:separator];
            
    
    }
    
    

    EmpScheduledDetailsBO *obj = (EmpScheduledDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    
    UILabel *nameLabel = (UILabel *) [cell.contentView viewWithTag:2];
    
    NSString *dayStr = obj.strDay;
    NSString *dateFmServ = obj.strDate;
    
    if ([dayStr isEqualToString:Currentday] && [dateFmServ isEqualToString:Currentdate])
    {
        
        dayStr = @"Today";
    }
    else if ([dayStr isEqualToString:yesterdayday] && [dateFmServ isEqualToString:yesterdaydate])
    {
        dayStr = @"Yesterday";
    }
    else
    {
        dayStr = obj.strDay;
    }
    
    nameLabel.text = dayStr;
    
    
    UILabel *nameLabel1 = (UILabel *) [cell.contentView viewWithTag:3];
    NSString *isempForSignin = obj.strSignInTime;
     NSString *isempForSignOut = obj.strSignOutTime;
    
    
    NSString *signInSignOutStr;
    
    
    if ([isempForSignin isEqualToString:@"Emp"])
    {
        isempForSignin = @"N/A";
    }
    else
    {
        isempForSignin = obj.strSignInTime;
    }
    
    if ([isempForSignOut isEqualToString:@"Emp"])
    {
        isempForSignOut = @"N/A";
    }
    else
    {
        isempForSignOut = obj.strSignOutTime;
    }
    
    signInSignOutStr = [NSString stringWithFormat:@"%@ - %@",isempForSignin,isempForSignOut];
    nameLabel1.text = signInSignOutStr;
    
    
  //  UIButton *noteButton = (UIButton *)[cell.contentView viewWithTag:5];
    
    UIImageView *noteButton = (UIImageView *)[cell.contentView viewWithTag:5];
    NSString *notestrValue = obj.strNotes;
    
    NSString *trimmedString = [notestrValue stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![trimmedString isEqualToString:@"Emp"] && [trimmedString length] != 0 )
    {
        if ([trimmedString isEqualToString:@"(null)"] || [trimmedString isEqualToString:@"(null) (null)"] ) {
            noteButton.hidden = YES;
            [cell setUserInteractionEnabled:NO];
        }
        else
        {
            noteButton.hidden = NO;
            [cell setUserInteractionEnabled:YES];
            //[noteButton addTarget:self action:@selector(NoteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    else
    {
        noteButton.hidden = YES;
        [cell setUserInteractionEnabled:NO];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  // [tableView setAllowsSelection:NO];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    EmpScheduledDetailsBO *obj = (EmpScheduledDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    
    NoteViewController *objNote = [self.storyboard instantiateViewControllerWithIdentifier:@"NoteView"];
    
    //NoteViewController *objNote = [[NoteViewController alloc]initWithNibName:@"NoteViewController" bundle:[NSBundle mainBundle]];
    
    NSString *onlyNotesStr = obj.strNotes;
    
    
    NSString *modifiedNotesStr = obj.strModifiedNotes;
    
    onlyNotesStr = [onlyNotesStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    modifiedNotesStr = [modifiedNotesStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *totalNotesStr;
    NSString *strModifiededNote;
    
    if (![modifiedNotesStr isEqualToString:@"Emp"] && ![modifiedNotesStr isEqual:[NSNull null]])
    {
        strModifiededNote = modifiedNotesStr;
    }
    
    
    if (![onlyNotesStr isEqualToString:@"Emp"] && ![onlyNotesStr isEqual:[NSNull null]])
    {
        totalNotesStr = onlyNotesStr;//[NSString stringWithFormat:@"%@\n",onlyNotesStr];//onlyNotesStr;
    }
    
    NSString *dayStr = obj.strDay;
    NSString *dateFmServ = obj.strDate;
    
    if ([dayStr isEqualToString:Currentday] && [dateFmServ isEqualToString:Currentdate])
    {
        
        dayStr = @"Today";
    }
    else if ([dayStr isEqualToString:yesterdayday] && [dateFmServ isEqualToString:yesterdaydate])
    {
        dayStr = @"Yesterday";
    }
    else
    {
        dayStr = obj.strDay;
    }
    objNote.dayStr = dayStr;
    objNote.strText = totalNotesStr;
    objNote.strModifidedNote = strModifiededNote;
    totalNotesStr = nil;
    strModifiededNote = nil;
    FPPopoverController *pop = [[FPPopoverController alloc]initWithViewController:objNote];
    //  pop.arrowDirection = FPPopoverNoArrow;
    //objNote.contentSizeForViewInPopover = CGSizeMake(100, 50);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        pop.contentSize = CGSizeMake(310,160);
    }
    else
    {
        pop.contentSize = CGSizeMake(350,240);
    }
    [pop presentPopoverFromView:selectedCell];
    
    
    
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //if (section == 0)
        return 0.0f;
    //return 32.0f;
}



-(void) NoteButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *) sender;
    
    UITableViewCell* cell;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
    cell = (UITableViewCell*)[[sender superview]superview];
    }
    else
    {
     cell = (UITableViewCell*)[[[sender superview]superview]superview];
    }
    
    NSIndexPath* indexPath = [tableViewData indexPathForCell:cell];
    
    
    EmpScheduledDetailsBO *obj = (EmpScheduledDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    
    NoteViewController *objNote = [self.storyboard instantiateViewControllerWithIdentifier:@"NoteView"];
    
    //NoteViewController *objNote = [[NoteViewController alloc]initWithNibName:@"NoteViewController" bundle:[NSBundle mainBundle]];
    
    NSString *onlyNotesStr = obj.strNotes;
    

    NSString *modifiedNotesStr = obj.strModifiedNotes;
    
    onlyNotesStr = [onlyNotesStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    modifiedNotesStr = [modifiedNotesStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *totalNotesStr;
    NSString *strModifiededNote;
    
   if (![modifiedNotesStr isEqualToString:@"Emp"] && ![modifiedNotesStr isEqual:[NSNull null]])
   {
       strModifiededNote = modifiedNotesStr;
   }
    
    
    if (![onlyNotesStr isEqualToString:@"Emp"] && ![onlyNotesStr isEqual:[NSNull null]])
    {
        totalNotesStr = onlyNotesStr;//[NSString stringWithFormat:@"%@\n",onlyNotesStr];//onlyNotesStr;
    }

    NSString *dayStr = obj.strDay;
    NSString *dateFmServ = obj.strDate;
    
    if ([dayStr isEqualToString:Currentday] && [dateFmServ isEqualToString:Currentdate])
    {
        
        dayStr = @"Today";
    }
    else if ([dayStr isEqualToString:yesterdayday] && [dateFmServ isEqualToString:yesterdaydate])
    {
        dayStr = @"Yesterday";
    }
    else
    {
        dayStr = obj.strDay;
    }
    objNote.dayStr = dayStr;
    objNote.strText = totalNotesStr;
    objNote.strModifidedNote = strModifiededNote;
    totalNotesStr = nil;
    strModifiededNote = nil;
    FPPopoverController *pop = [[FPPopoverController alloc]initWithViewController:objNote];
  //  pop.arrowDirection = FPPopoverNoArrow;
    //objNote.contentSizeForViewInPopover = CGSizeMake(100, 50);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    pop.contentSize = CGSizeMake(310,160);
    }
    else
    {
        pop.contentSize = CGSizeMake(350,240);
    }
    [pop presentPopoverFromView:btn];
    
    NSLog(@"pop.contentSize.width --%f",pop.contentSize.width );
//    pop.border = NO;
//    [pop setShadowsHidden:YES];
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
