//
//  MyReportsViewController.m
//  HRTest
//
//  Created by Venkata Chinni on 8/27/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "MyReportsViewController.h"
#import "ShiftSchTopButtonViewController.h"
#import "MBProgressHUD.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


@interface MyReportsViewController ()

@end

@implementation MyReportsViewController

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
    
    
//    activityIndicator = [[UIActivityIndicatorView alloc] init];
//    activityIndicator.color = [UIColor whiteColor];
//    activityIndicator.alpha = 1.0;
//    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    activityIndicator.hidden = YES;
//    [self.view addSubview:activityIndicator];
    
    
    
    typeofParsing = 10;
     _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
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
    cmpNameLabel.text = @"My Reports";
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;
    
    [topNaviView addSubview:cmpNameLabel];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    backView = [[UIView alloc] initWithFrame:CGRectMake(12,topNaviView.frame.size.height+ 10, self.view.frame.size.width-24, 40)];
    }
    else
    {
    backView = [[UIView alloc] initWithFrame:CGRectMake(24,topNaviView.frame.size.height+ 10, self.view.frame.size.width-48, 50)];
    }
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    backView.layer.cornerRadius = 3;
    
    
    
    
    reportsButtons= [UIButton buttonWithType:UIButtonTypeCustom];
    [reportsButtons setTitle:@"Weekly Details" forState:UIControlStateNormal];
    [reportsButtons addTarget:self action:@selector(ReportsButtonTapped:) forControlEvents:UIControlEventTouchDown];
     [reportsButtons setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     reportsButtons.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
     reportsButtons.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        reportsButtons.frame = CGRectMake(10.0, 5.0, backView.frame.size.width, 30.0);
    }
    else
    {
        reportsButtons.frame = CGRectMake(10.0, 5.0,  backView.frame.size.width, 30.0);
    }
    }
    else
    {
        reportsButtons.frame = CGRectMake(10.0, 5.0,  backView.frame.size.width, 40.0);
    }
    
    [backView addSubview:reportsButtons];
    reportsButtons.userInteractionEnabled = NO;
    
    
    UIImageView *imgView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
     imgView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 4, 24, 24)];
    }
    else
    {
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(620, 4, 34, 34)];
    }
    imgView.image = [UIImage imageNamed:@"down_arrow.png"];
    [reportsButtons addSubview:imgView];
    
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    underBackView = [[UIView alloc] initWithFrame:CGRectMake(12,backView.frame.origin.y+backView.frame.size.height+ 1, self.view.frame.size.width-24, 30)];
    }
    else
    {
    underBackView = [[UIView alloc] initWithFrame:CGRectMake(24,backView.frame.origin.y+backView.frame.size.height+ 1, self.view.frame.size.width-48, 40)];
    }
    underBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:underBackView];
    underBackView.layer.cornerRadius = 3;
    underBackView.hidden = YES;
    
    
    currentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [currentButton setTitle:@"Current" forState:UIControlStateNormal];
    [currentButton addTarget:self action:@selector(UserCurrentButtonTapped)forControlEvents:UIControlEventTouchDown];
    [currentButton setBackgroundColor:[UIColor clearColor]];
    [currentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        currentButton.frame = CGRectMake(underBackView.frame.size.width/2-30, 1.0, 60.0, 26.0);
    }
    else
    {
        currentButton.frame = CGRectMake(underBackView.frame.size.width/2-30, 2.0, 60.0, 26.0);
        currentButton.layer.cornerRadius = 2;
        currentButton.layer.borderColor = [[UIColor grayColor] CGColor];
        currentButton.layer.borderWidth = 1.0;
    }
    }
    else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            currentButton.frame = CGRectMake(underBackView.frame.size.width/2-30, 3.0, 80.0, 34.0);
        }
        else
        {
            currentButton.frame = CGRectMake(underBackView.frame.size.width/2-30, 3.0, 80.0, 34.0);
            currentButton.layer.cornerRadius = 2;
            currentButton.layer.borderColor = [[UIColor grayColor] CGColor];
            currentButton.layer.borderWidth = 1.0;
        }
    }
    currentButton.hidden = YES;
    [underBackView addSubview:currentButton];
    
    
    
    
    previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousButton setTitle:@"Previous" forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(UserPreviousButtonTapped)forControlEvents:UIControlEventTouchDown];
    [previousButton setBackgroundColor:[UIColor clearColor]];
    [previousButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    previousButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
   
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        previousButton.frame = CGRectMake(50, 2.0, 60.0, 26.0);
    }
    else
    {
        previousButton.frame = CGRectMake(50, 2.0, 60.0, 26.0);
        previousButton.layer.cornerRadius = 2;
        previousButton.layer.borderColor = [[UIColor grayColor] CGColor];
        previousButton.layer.borderWidth = 1.0;
    }
    }
    else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            previousButton.frame = CGRectMake(60, 3.0, 80.0, 34.0);
        }
        else
        {
            previousButton.frame = CGRectMake(60, 3.0, 80.0, 34.0);
            previousButton.layer.cornerRadius = 2;
            previousButton.layer.borderColor = [[UIColor grayColor] CGColor];
            previousButton.layer.borderWidth = 1.0;
        }
    }
    [underBackView addSubview:previousButton];
    
    
    
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(UserNextButtonTapped)forControlEvents:UIControlEventTouchDown];
   // [nextButton setBackgroundColor:[UIColor yellowColor]];
    //[nextButton setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        nextButton.frame = CGRectMake(180, 2.0, 60.0, 26.0);
    }
    else
    {
        nextButton.frame = CGRectMake(180, 2.0, 60.0, 26.0);
        nextButton.layer.cornerRadius = 2;
        nextButton.layer.borderColor = [[UIColor grayColor] CGColor];
        nextButton.layer.borderWidth = 1.0;
    }
    }
    else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            nextButton.frame = CGRectMake(180, 3.0, 80.0, 34.0);
        }
        else
        {
            nextButton.frame = CGRectMake(180, 3.0, 80.0, 34.0);
            nextButton.layer.cornerRadius = 2;
            nextButton.layer.borderColor = [[UIColor grayColor] CGColor];
            nextButton.layer.borderWidth = 1.0;
        }
    }
    [underBackView addSubview:nextButton];
    nextButton.hidden = YES;
    previousButton.hidden = YES;
    currentButton.hidden = YES;
    
   
    
}
-(void) didSelectRowShiftName:(NSString *) ShiftName ShiftIDEmp:(NSString *) ShiftID
{
    
}
-(void)ReportsButtonTapped:(id) sender
{
     UIButton *but = (UIButton *) sender;
    NSInteger fromReport = 999;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:fromReport forKey:@"fromReportKey"];
    [def synchronize];
    
     ShiftSchTopButtonViewController *objReportButn = [self.storyboard instantiateViewControllerWithIdentifier:@"ShiftSchTopButtonID"];
    objReportButn.delegate = self;
    pop = [[FPPopoverController alloc]initWithViewController:objReportButn];
    pop.contentSize = CGSizeMake(200,170);
    [pop presentPopoverFromView:but];
    
    
}

-(void) didSelectRowReportName:(NSString *) ReportName
{
//    activityIndicator.color = [UIColor colorWithRed:46.0/255.0 green:45.0/255.0 blue:46.0/255.0 alpha:1.0];
//    
//    activityIndicator.center = CGPointMake(contactTableView.frame.size.width/2, contactTableView.frame.size.height/2);
//    [contactTableView addSubview:activityIndicator];
    
    [pop dismissPopoverAnimated:YES];
    
    [reportsButtons setTitle:ReportName forState:UIControlStateNormal];
    reportsButtons.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
 
    if ([ReportName isEqualToString:@"Weekly-Detail"])
    {
        
        currentButton.userInteractionEnabled = YES;
        previousButton.userInteractionEnabled = YES;
        nextButton.userInteractionEnabled = YES;
        
        [self GetWeekDailyReports];
    }
    if ([ReportName isEqualToString:@"Weekly-Summary"])
    {
        currentButton.userInteractionEnabled = NO;
        previousButton.userInteractionEnabled = NO;
        nextButton.userInteractionEnabled = NO;
      //  activityIndicator.color = [UIColor grayColor];
        [self WeeklySummeryReportsImplementation];
    }
    else if ([ReportName isEqualToString:@"Monthly-Summary"])
    {
        currentButton.userInteractionEnabled = NO;
        previousButton.userInteractionEnabled = NO;
        nextButton.userInteractionEnabled = NO;
      //  activityIndicator.color = [UIColor grayColor];
        [self MonthReportImpelementation];
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
    
    
    if (typeofParsing == 10)
    {
  
        [self GetWeekDailyReports];
    }
    else if (typeofParsing == 12)
    {
        [self WeeklySummeryReportsImplementation];
    }
    else if (typeofParsing ==13)
    {
        [self MonthReportImpelementation];
    }
    
}

-(void)GetWeekDailyReports
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    typeofParsing = 12;
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
   // NSString *empCmpyID = @"hm116";
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    NSDateFormatter *dateFormatterA = [[NSDateFormatter alloc] init];
    [dateFormatterA setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatterA setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatterA setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *todayDate = [NSDate date];
  //  NSString *currentTime = [dateFormatterA stringFromDate:todayDate];

 
    NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc] init];
    [dateFormatterr setDateFormat:@"EEEE"];
    NSLog(@"%@", [dateFormatterr stringFromDate:[NSDate date]]);
    NSString *dayOfWeekDayIfSat = [dateFormatterr stringFromDate:todayDate];

    
    NSDate *DateForEndDate;
    if ([dayOfWeekDayIfSat isEqualToString:@"Saturday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Sunday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-1];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    
    else if ([dayOfWeekDayIfSat isEqualToString:@"Monday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-2];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Tuesday"])
    {
       
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-3];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Wednesday"])
    {
       
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-4];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Thursday"])
    {
       
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-5];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Friday"])
    {
      
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-6];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
   
    endDatelastWeek =[dateFormatter stringFromDate:DateForEndDate];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:-6];
    
    NSDate * startDateLWeek2 = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:DateForEndDate options:0];
    
    startDatelastWeek =[dateFormatter stringFromDate:startDateLWeek2];
    
    
    
    /*For hide the Last start date*///////////////////////////////////////////-
    
    [componentsToSubtract setWeek:-12];
    [componentsToSubtract setDay:1];
    
    NSDate * priviousLaststartDateLWeekD = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:DateForEndDate options:0];
    
    
    NSDateFormatter *dF = [[NSDateFormatter alloc] init];
    [dF setDateFormat:@"EEEE"];
    NSString * priviousLaststartDateLWeekDay = [dF stringFromDate:priviousLaststartDateLWeekD];
    
    NSDate *DateForLastWeekStartDay;
    if ([priviousLaststartDateLWeekDay isEqualToString:@"Saturday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-6];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    else if ([priviousLaststartDateLWeekDay isEqualToString:@"Sunday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:0];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    
    else if ([priviousLaststartDateLWeekDay isEqualToString:@"Monday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-1];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    else if ([priviousLaststartDateLWeekDay isEqualToString:@"Tuesday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-2];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    else if ([priviousLaststartDateLWeekDay isEqualToString:@"Wednesday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-3];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    else if ([priviousLaststartDateLWeekDay isEqualToString:@"Thursday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-4];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    else if ([priviousLaststartDateLWeekDay isEqualToString:@"Friday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-5];
        
        DateForLastWeekStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviousLaststartDateLWeekD options:0];
    }
    
    
    
    NSDateFormatter *dFF = [[NSDateFormatter alloc] init];
    [dFF setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dFF setDateFormat:@"yyyy-MM-dd"];
    
    NSString *lastDateForWeek12  = [dFF stringFromDate:DateForLastWeekStartDay];
    
    NSDate *DatelastDateForWeek12 = [dFF dateFromString:lastDateForWeek12];
    NSDate *dateStepByWeekStrtWeek12 = [dFF dateFromString:previousstartDatelastWeek];
    
    if ([DatelastDateForWeek12 isEqualToDate:dateStepByWeekStrtWeek12])
       {
           // previousButton.hidden = YES;
           
           previousButton.hidden = NO;
           previousButton.userInteractionEnabled = NO;
           previousButton.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
           
           previousButtonHideStatus = YES;
           
           
        }
        else
       {
            previousButton.hidden = NO;
           previousButton.userInteractionEnabled = YES;
           previousButton.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0];
            [previousButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           previousButtonHideStatus = NO;
        }
    
    if (previousOrNextButton == 2)
    {
        endDatelastWeek = previousendDatelastWeek;
        startDatelastWeek = previousstartDatelastWeek;
        
    }
   else if (previousOrNextButton == 3)
    {
        
        endDatelastWeek = previousendDatelastWeek;
        startDatelastWeek = previousstartDatelastWeek;
  
    }
    
    
     NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<GetWeeklyDetailReport xmlns=\"http://tempuri.org/\">"
    "<empCompanyID>%@</empCompanyID>"
    "<companyCode>%@</companyCode>"
    "<startDate>%@</startDate>"
    "<endDate>%@</endDate>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<mobileName>%@</mobileName>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "</GetWeeklyDetailReport>"
    "</soap:Body>"
    "</soap:Envelope>",empCmpyID,cmpCode,startDatelastWeek,endDatelastWeek,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetWeeklyDetailReport" forHTTPHeaderField:@"SOAPAction"];
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

-(void)WeeklySummeryReportsImplementation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    typeofParsing = 13;
    ifThisWeekSummery = 123456;
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
   
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    //NSString *empCmpyID = @"hm116";
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    
    NSDate *todayDate = [NSDate date];
    
    NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc] init];
    [dateFormatterr setDateFormat:@"EEEE"];
    NSLog(@"%@", [dateFormatterr stringFromDate:[NSDate date]]);
    NSString *dayOfWeekDayIfSat = [dateFormatterr stringFromDate:todayDate];
    
    
    NSDate *DateForEndDate;
    if ([dayOfWeekDayIfSat isEqualToString:@"Saturday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Sunday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-1];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    
    else if ([dayOfWeekDayIfSat isEqualToString:@"Monday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-2];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Tuesday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-3];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Wednesday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-4];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Thursday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-5];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    else if ([dayOfWeekDayIfSat isEqualToString:@"Friday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-6];
        
        DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
    }
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    tempPrviWeekEndDate = [dateFormatter stringFromDate:DateForEndDate];
    
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setWeek:-12];
    [componentsToSubtract setDay:1];
    NSDate *stDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:DateForEndDate options:0];
    
    
    
    NSString *dayOfWeekDayIfSunToStart = [dateFormatterr stringFromDate:stDate];;
    
    
    
    NSDate *DateForStrtDate;
    if ([dayOfWeekDayIfSunToStart isEqualToString:@"Saturday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-6];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    else if ([dayOfWeekDayIfSunToStart isEqualToString:@"Sunday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:0];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    
    else if ([dayOfWeekDayIfSunToStart isEqualToString:@"Monday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-1];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    else if ([dayOfWeekDayIfSunToStart isEqualToString:@"Tuesday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-2];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    else if ([dayOfWeekDayIfSunToStart isEqualToString:@"Wednesday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-3];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    else if ([dayOfWeekDayIfSunToStart isEqualToString:@"Thursday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-4];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    else if ([dayOfWeekDayIfSunToStart isEqualToString:@"Friday"])
    {
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-5];
        
        DateForStrtDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:stDate options:0];
    }
    
    tempPrviWeekStrtDate = [dateFormatter stringFromDate:DateForStrtDate];

    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<GetWeekSummaryReport xmlns=\"http://tempuri.org/\">"
    "<empCompanyID>%@</empCompanyID>"
    "<startDate>%@</startDate>"
    "<endDate>%@</endDate>"
    "<companyCode>%@</companyCode>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<mobileName>%@</mobileName>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "</GetWeekSummaryReport>"
    "</soap:Body>"
    "</soap:Envelope>",empCmpyID,tempPrviWeekStrtDate,tempPrviWeekEndDate,cmpCode,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetWeekSummaryReport" forHTTPHeaderField:@"SOAPAction"];
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
-(void)MonthReportImpelementation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    typeofParsing = 14;
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
   // NSString *empCmpyID = @"hm116";
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *comps=[[NSDateComponents alloc] init];
    comps.month=-1;
    comps = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSDate * startDateOfMonth = [self returnDateForMonth:comps.month year:comps.year day:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    endDate =[dateFormatter stringFromDate:startDateOfMonth];
    
    comps = [calendar components:unitFlags fromDate:startDateOfMonth];
    
    NSDate * endDateinYear = [self returnDateForMonth:comps.month-11 year:comps.year day:1];
    
    // Write signe in date
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
   startDate =[dateFormatter1 stringFromDate:endDateinYear];
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
   " <soap:Body>"
   " <GetMonthSummaryReport xmlns=\"http://tempuri.org/\">"
   " <empCompanyID>%@</empCompanyID>"
   " <startDate>%@</startDate>"
   " <endDate>%@</endDate>"
   " <companyCode>%@</companyCode>"
   " <longitude>%@</longitude>"
   " <latitude>%@</latitude>"
   " <mobileName>%@</mobileName>"
   " <deviceCode>%@</deviceCode>"
   " <authenticationID>%@</authenticationID>"
   " </GetMonthSummaryReport>"
   " </soap:Body>"
   " </soap:Envelope>",empCmpyID,startDate,endDate,cmpCode,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetMonthSummaryReport" forHTTPHeaderField:@"SOAPAction"];
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
- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:components];
}

- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year week:(NSInteger) week day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    [components setWeek:week];
    [components setMonth:month];
    [components setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:components];
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
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
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
//
    reportsButtons.userInteractionEnabled = YES;
    NSString *strXMl = [[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    NSLog(@"XML is : %@", strXMl);
//    
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"GetWeeklyDetailReportResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
    else if ([elementName isEqualToString:@"mobileEmpInfo"])
    {
        if (objEmpReports)
        {
            objEmpReports = nil;
        }
        
        objEmpReports = [[EmpReportsDetailsBO alloc]init];
    }
   else if ([elementName isEqualToString:@"GetWeekSummaryReportResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
   else if ([elementName isEqualToString:@"GetMonthSummaryReportResult"])
   {
       if (arrayParsedList)
       {
           arrayParsedList = nil;
       }
       arrayParsedList = [[NSMutableArray alloc]init];
   }
    
    else if ([elementName isEqualToString:@"ReportInfo"])
    {
        if (objWeekReports)
        {
            objWeekReports = nil;
        }
        
        objWeekReports = [[EmpWeekSummeryReportsBO alloc]init];
    }

    
    
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
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
    
    if ([elementName isEqualToString:@"GetWeeklyDetailReportResult"])
    {
        
        
    }
  
    else if ([elementName isEqualToString:@"mobileEmpInfo"])
    {
        [arrayParsedList addObject:objEmpReports];
    }
   
    else if ([elementName isEqualToString:@"AaSuccess1"])
    {
        objEmpReports.strAaSuccess1 = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Date"])
    {
        objEmpReports.strDate = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignInDate"])
    {
        objEmpReports.strSignInDate = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignOutDate"])
    {
        objEmpReports.strSignOutDate = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpCompanyID"])
    {
        objEmpReports.strEmpCompanyID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"TotalHrs"])
    {
        objEmpReports.strTotalHrs = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Designation"])
    {
        objEmpReports.strDesignation = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpID"])
    {
        objEmpReports.strEmpID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ShiftName"])
    {
        objEmpReports.strShiftName = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Deptname"])
    {
        objEmpReports.strDeptname = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignInTime"])
    {
        objEmpReports.strSignInTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignOutTime"])
    {
        objEmpReports.strSignOutTime = currentElementValue;
    }
    
    else if ([elementName isEqualToString:@"CompanyCode"])
    {
        objEmpReports.strCompanyCode = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Day"])
    {
        objEmpReports.strDay = currentElementValue;
    }
    
    else if ([elementName isEqualToString:@"CompanyID"])
    {
        objEmpReports.strCompanyID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"TotalWorkedDays"])
    {
        objEmpReports.strTotalWorkedDays = currentElementValue;
    }
    
    else if ([elementName isEqualToString:@"TotalWorkedHrs"])
    {
        objEmpReports.strTotalWorkedHrs = currentElementValue;
    }
    
    else if ([elementName isEqualToString:@"IsMultiple"])
    {
        objEmpReports.strIsMultiple = currentElementValue;
    }
    
    else if ([elementName isEqualToString:@"CompanyID"])
    {
        objEmpReports.strCompanyID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"AttendanceCode"])
    {
        objEmpReports.strAttendanceCode = currentElementValue;
    }
//week && monthly summery reports
    
    if ([elementName isEqualToString:@"GetWeeklyDetailReportResult"])
    {
        
    }
    if ([elementName isEqualToString:@"GetMonthSummaryReportResult"])
    {
        
    }    
    else if ([elementName isEqualToString:@"ReportInfo"])
    {
        [arrayParsedList addObject:objWeekReports];
    }
    else if ([elementName isEqualToString:@"AASuccess"])
    {
        objWeekReports.strAASuccess = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpFName"])
    {
        objWeekReports.strEmpFName = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpLName"])
    {
        objWeekReports.strEmpLName = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpCompanyID"])
    {
        objWeekReports.strEmpCompanyID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpDesignation"])
    {
        objWeekReports.strEmpDesignation = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmpID"])
    {
        objWeekReports.strEmpID = currentElementValue;
    }
    
    else if ([elementName isEqualToString:@"StartDate"])
    {
        objWeekReports.strStartDate = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EndDate"])
    {
        objWeekReports.strEndDate = currentElementValue;
    }
    else if ([elementName isEqualToString:@"TotalDays"])
    {
        objWeekReports.strTotalDays = currentElementValue;
    }
    else if ([elementName isEqualToString:@"WorkedDays"])
    {
        objWeekReports.strWorkedDays = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Holidays"])
    {
        objWeekReports.strHolidays = currentElementValue;
    }
    else if ([elementName isEqualToString:@"TotalHrs"])
    {
        objWeekReports.strTotalHrs = currentElementValue;
    }
    else if ([elementName isEqualToString:@"TotalHrsTime"])
    {
        objWeekReports.strTotalHrsTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"TotalWorkedHrs"])
    {
        objWeekReports.strTotalWorkedHrs = currentElementValue;
    }
    else if ([elementName isEqualToString:@"GrandTotalWDays"])
    {
        objWeekReports.strGrandTotalWDays = currentElementValue;
    }
    else if ([elementName isEqualToString:@"GrandTotalWHrs"])
    {
        objWeekReports.strGrandTotalWHrs = currentElementValue;
    }
    else if ([elementName isEqualToString:@"GrandTotalWHrsTime"])
    {
        objWeekReports.strGrandTotalWHrsTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Month"])
    {
        objWeekReports.strMonth = currentElementValue;
    }
  
    currentElementValue = nil;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([arrayParsedList count])
    {
        if (contactTableView)
        {
            [contactTableView reloadData];
            
            
            NSDate *todayDate = [NSDate date];
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc] init];
            [dateFormatterr setDateFormat:@"EEEE"];
            NSLog(@"%@", [dateFormatterr stringFromDate:[NSDate date]]);
            NSString *dayOfWeekDayIfSat = [dateFormatterr stringFromDate:todayDate];
            
            
            NSDate *DateForEndDate;
            if ([dayOfWeekDayIfSat isEqualToString:@"Saturday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-7];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            else if ([dayOfWeekDayIfSat isEqualToString:@"Sunday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-1];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            
            else if ([dayOfWeekDayIfSat isEqualToString:@"Monday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-2];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            else if ([dayOfWeekDayIfSat isEqualToString:@"Tuesday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-3];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            else if ([dayOfWeekDayIfSat isEqualToString:@"Wednesday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-4];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            else if ([dayOfWeekDayIfSat isEqualToString:@"Thursday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-5];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            else if ([dayOfWeekDayIfSat isEqualToString:@"Friday"])
            {
                
                NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                [componentsToSubtract setDay:-6];
                
                DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
            }
            
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSString *stOne =[dateFormatter stringFromDate:DateForEndDate];
            
            NSDate *dat = [dateFormatter dateFromString:stOne];
            
            
//            NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
//            [componentsToSubtract setDay:7];
//            NSDate *futureDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:dat options:0];
            
            
            
            
            if([dat compare:[NSDate date]] == NSOrderedAscending) {
                // dateOne is before dateTwo
                nextButton.hidden = NO;
                nextButton.userInteractionEnabled = NO;
                [nextButton setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]];
               
                if (previousButtonHideStatus == YES)
                {
                   // previousButton.hidden = YES;
                    
                    previousButton.hidden = NO;
                    previousButton.userInteractionEnabled = NO;
                    previousButton.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
                }
                else
                {
                    previousButton.hidden = NO;
                    
                    previousButton.userInteractionEnabled = YES;
                    previousButton.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0];
                     [previousButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                currentButton.hidden = YES;
            }
            else
            {
                nextButton.hidden = NO;
                nextButton.userInteractionEnabled = YES;
                [nextButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
                [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                if (previousButtonHideStatus == YES)
                {
                   // previousButton.hidden = YES;
                    
                    previousButton.hidden = NO;
                    previousButton.userInteractionEnabled = NO;
                    previousButton.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
                }
                else
                {
                    //previousButton.hidden = NO;
                    
                    previousButton.hidden = NO;
                    previousButton.userInteractionEnabled = YES;
                    previousButton.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0];
                     [previousButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                //previousButton.hidden = NO;
                currentButton.hidden = YES;
            }
            
            
            if (previousOrNextButton == 2)
            {
                
                
                if([prviDayEnd compare:dat] == NSOrderedAscending) {
                    // dateOne is before dateTwo
                    nextButton.hidden = NO;
                    nextButton.userInteractionEnabled = YES;
                    [nextButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
                    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    if (previousButtonHideStatus == YES)
                    {
                       // previousButton.hidden = YES;
                        
                        previousButton.hidden = NO;
                        previousButton.userInteractionEnabled = NO;
                        previousButton.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
                    }
                    else
                    {
                        //previousButton.hidden = NO;
                        
                        previousButton.hidden = NO;
                        previousButton.userInteractionEnabled = YES;
                        previousButton.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0];
                         [previousButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                   // previousButton.hidden = NO;
                    currentButton.hidden = YES;
                }
                
                //nextButton.hidden = NO;
            }
            else if (previousOrNextButton == 3)
            {
                NSDate *temDate = [dateFormatter dateFromString:endDatelastWeek];
                
                if([temDate compare:dat ] == NSOrderedSame) {
                    // dateOne is before dateTwo
                   // nextButton.hidden = YES;
                     nextButton.hidden = NO;
                    nextButton.userInteractionEnabled = NO;
                    [nextButton setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]];
                    if (previousButtonHideStatus == YES)
                    {
                       // previousButton.hidden = YES;
                        
                        previousButton.hidden = NO;
                        previousButton.userInteractionEnabled = NO;
                        previousButton.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
                    }
                    else
                    {
                       // previousButton.hidden = NO;
                        
                        previousButton.hidden = NO;
                        previousButton.userInteractionEnabled = YES;
                        previousButton.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0];
                         [previousButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                    currentButton.hidden = YES;
                }
                else
                {
                    nextButton.hidden = NO;
                    nextButton.userInteractionEnabled = YES;
                    [nextButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
                    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                
                //nextButton.hidden = NO;
            }

            
            
            
            
        }
        else
        {
            contactTableView = [[UITableView alloc] init];
            // contactTableView.tag = 1;
            contactTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            // contactTableView.backgroundColor = [UIColor clearColor];
            contactTableView.dataSource = self;
            contactTableView.delegate = self;
            [self.view addSubview:contactTableView];
            [contactTableView setShowsVerticalScrollIndicator:NO];
            
            contactTableView.layer.cornerRadius = 3.0;
            if (typeofParsing == 12)
            {
//                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//                {
//                
//                    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
//                    {
//                    contactTableView.frame = CGRectMake(12, 130, self.view.frame.size.width-24, self.view.frame.size.height-170);
//                    UIView *backViewTV = [[UIView alloc] init];
//                    [backViewTV setBackgroundColor:[UIColor clearColor]];
//                    [contactTableView setBackgroundView:backViewTV];
//                    }
//                    else
//                    {
//                    contactTableView.frame = CGRectMake(12, 150, self.view.frame.size.width-24, self.view.frame.size.height-170);
//                    contactTableView.backgroundColor = [UIColor clearColor];
//                    }
//                }
//                else
//                {
//                    
//                    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
//                    {
//                        contactTableView.frame = CGRectMake(12, 160, self.view.frame.size.width-24, self.view.frame.size.height-170);
//                        UIView *backViewTV = [[UIView alloc] init];
//                        [backViewTV setBackgroundColor:[UIColor clearColor]];
//                        [contactTableView setBackgroundView:backViewTV];
//                    }
//                    else
//                    {
//                        contactTableView.frame = CGRectMake(12, 180, self.view.frame.size.width-24, self.view.frame.size.height-170);
//                        contactTableView.backgroundColor = [UIColor clearColor];
//                    }
//                    
//                    
//                    
//                }

                
                
                
                NSDate *todayDate = [NSDate date];
                NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc] init];
                [dateFormatterr setDateFormat:@"EEEE"];
                NSLog(@"%@", [dateFormatterr stringFromDate:[NSDate date]]);
                NSString *dayOfWeekDayIfSat = [dateFormatterr stringFromDate:todayDate];
                
                
                NSDate *DateForEndDate;
                if ([dayOfWeekDayIfSat isEqualToString:@"Saturday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-7];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                else if ([dayOfWeekDayIfSat isEqualToString:@"Sunday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-1];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                
                else if ([dayOfWeekDayIfSat isEqualToString:@"Monday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-2];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                else if ([dayOfWeekDayIfSat isEqualToString:@"Tuesday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-3];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                else if ([dayOfWeekDayIfSat isEqualToString:@"Wednesday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-4];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                else if ([dayOfWeekDayIfSat isEqualToString:@"Thursday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-5];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                else if ([dayOfWeekDayIfSat isEqualToString:@"Friday"])
                {
                    
                    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
                    [componentsToSubtract setDay:-6];
                    
                    DateForEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:todayDate options:0];
                }
                
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                NSString *stOne =[dateFormatter stringFromDate:DateForEndDate];
                
                NSDate *dat = [dateFormatter dateFromString:stOne];
                
                
                
                if([dat compare:[NSDate date]] == NSOrderedAscending) {
                    // dateOne is before dateTwo
                    //nextButton.hidden = YES;
                     nextButton.hidden = NO;
                    nextButton.userInteractionEnabled = NO;
                    [nextButton setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]];
                    //[nextButton setBackgroundColor:[UIColor redColor]];
                    previousButton.hidden = NO;
                    currentButton.hidden = YES;
                }
                else
                {
                    nextButton.hidden = NO;
                    nextButton.userInteractionEnabled = YES;
                    [nextButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
                    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    previousButton.hidden = NO;
                    currentButton.hidden = YES;
                }
                
            }
//            else
//            {
//                
//                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
//                {
//                    contactTableView.frame = CGRectMake(12, 100, self.view.frame.size.width-24, self.view.frame.size.height-140);
//                    UIView *backViewTV = [[UIView alloc] init];
//                    [backViewTV setBackgroundColor:[UIColor clearColor]];
//                    [contactTableView setBackgroundView:backViewTV];
//                }
//                else
//                {
//                    contactTableView.frame = CGRectMake(12, 120, self.view.frame.size.width-24, self.view.frame.size.height-140);
//                    contactTableView.backgroundColor = [UIColor clearColor];
//                }
//            }
           // contactTableView.backgroundColor = [UIColor whiteColor];
           
        }
        
        
        if(typeofParsing == 12)
        {
             underBackView.hidden = NO;
            
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
         {
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                contactTableView.frame = CGRectMake(12, 130, self.view.frame.size.width-24, self.view.frame.size.height-180);
                UIView *backViewTV = [[UIView alloc] init];
                [backViewTV setBackgroundColor:[UIColor clearColor]];
                [contactTableView setBackgroundView:backViewTV];
            }
            else
            {
                contactTableView.frame = CGRectMake(12, 150, self.view.frame.size.width-24, self.view.frame.size.height-180);
                contactTableView.backgroundColor = [UIColor clearColor];
            }
            
         }
        else
         {
             if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
             {
                 contactTableView.frame = CGRectMake(24, 200, self.view.frame.size.width-48, self.view.frame.size.height-690);
                 UIView *backViewTV = [[UIView alloc] init];
                 [backViewTV setBackgroundColor:[UIColor clearColor]];
                 [contactTableView setBackgroundView:backViewTV];
             }
             else
             {
                 contactTableView.frame = CGRectMake(24, 200, self.view.frame.size.width-48, self.view.frame.size.height-170);
                 contactTableView.backgroundColor = [UIColor clearColor];
             }
                
         }
            [contactTableView reloadData];
            contactTableView.tag = 1;
            
            
        }
        else if(typeofParsing == 13)
        {
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
            
                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                {
                contactTableView.frame = CGRectMake(12, 100, self.view.frame.size.width-24, self.view.frame.size.height-140);
                UIView *backViewTV = [[UIView alloc] init];
                [backViewTV setBackgroundColor:[UIColor clearColor]];
                [contactTableView setBackgroundView:backViewTV];
                }
                else
                {
                contactTableView.frame = CGRectMake(12, 120, self.view.frame.size.width-24, self.view.frame.size.height-140);
                contactTableView.backgroundColor = [UIColor clearColor];
                }
            }
            else
            {
                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                {
                    contactTableView.frame = CGRectMake(24, 150, self.view.frame.size.width-48, self.view.frame.size.height-170);
                    UIView *backViewTV = [[UIView alloc] init];
                    [backViewTV setBackgroundColor:[UIColor clearColor]];
                    [contactTableView setBackgroundView:backViewTV];
                }
                else
                {
                    contactTableView.frame = CGRectMake(24, 150, self.view.frame.size.width-48, self.view.frame.size.height-170);
                    contactTableView.backgroundColor = [UIColor clearColor];
                }
                
            }
            
            underBackView.hidden = YES;
            [contactTableView reloadData];
            contactTableView.tag = 2;
        }
        
        else if(typeofParsing == 14)
        {
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                
                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                {
                    contactTableView.frame = CGRectMake(12, 100, self.view.frame.size.width-24, self.view.frame.size.height-140);
                    UIView *backViewTV = [[UIView alloc] init];
                    [backViewTV setBackgroundColor:[UIColor clearColor]];
                    [contactTableView setBackgroundView:backViewTV];
                }
                else
                {
                    contactTableView.frame = CGRectMake(12, 120, self.view.frame.size.width-24, self.view.frame.size.height-140);
                    contactTableView.backgroundColor = [UIColor clearColor];
                }
            }
            else
            {
                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
                {
                    contactTableView.frame = CGRectMake(24, 150, self.view.frame.size.width-48, self.view.frame.size.height-170);
                    UIView *backViewTV = [[UIView alloc] init];
                    [backViewTV setBackgroundColor:[UIColor clearColor]];
                    [contactTableView setBackgroundView:backViewTV];
                }
                else
                {
                    contactTableView.frame = CGRectMake(24, 150, self.view.frame.size.width-48, self.view.frame.size.height-170);
                    contactTableView.backgroundColor = [UIColor clearColor];
                }
                
            }
            
             underBackView.hidden = YES;
            [contactTableView reloadData];
            contactTableView.tag = 3;
            
        }
        
}
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No records found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    
    ///[contactTableView reloadData];
    
    
    
    
    
    
}
-(void)UserCurrentButtonTapped
{
    
    previousOrNextButton = 222222;
    [self GetWeekDailyReports];

    
}
-(void)UserPreviousButtonTapped
{
    
    previousOrNextButton = 2;
    
    NSDateFormatter *dateFormatterr2 = [[NSDateFormatter alloc] init];
    [dateFormatterr2 setDateFormat:@"yyyy-MM-dd"];
    NSDate *priviStDate = [dateFormatterr2 dateFromString:startDatelastWeek];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:-1];
     prviDayEnd = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviStDate options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    previousendDatelastWeek =[dateFormatter stringFromDate:prviDayEnd];
    
    [componentsToSubtract setDay:-6];
    
     NSDate *prviStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:prviDayEnd options:0];
    previousstartDatelastWeek =[dateFormatter stringFromDate:prviStartDay];
    
    [self GetWeekDailyReports];
    
}
-(void)UserNextButtonTapped
{
    previousOrNextButton = 3;
    
    NSDateFormatter *dateFormatterr2 = [[NSDateFormatter alloc] init];
    [dateFormatterr2 setDateFormat:@"yyyy-MM-dd"];
    NSDate *priviStDate = [dateFormatterr2 dateFromString:endDatelastWeek];
    
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:1];
    NSDate *prviDayEndN = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:priviStDate options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    previousstartDatelastWeek =[dateFormatter stringFromDate:prviDayEndN];
    
    [componentsToSubtract setDay:6];
    
    NSDate *prviStartDay = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:prviDayEndN options:0];
    previousendDatelastWeek  =[dateFormatter stringFromDate:prviStartDay];

        [self GetWeekDailyReports];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [arrayParsedList count];
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    return 50;
    }
    else
    {
        return 60;
    }
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (typeofParsing == 12)
//    {
//        
//    }
//    else if (typeofParsing == 13)
//    {
//        
//    }
//}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    // 1. The view for the header
    UIView* headerView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    }
    else
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    }
    
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    headerView.layer.borderWidth = 0.6;
    
    // 3. Add a label
    UILabel* headerLabel = [[UILabel alloc] init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        headerLabel.frame = CGRectMake(10, 4, tableView.frame.size.width - 5, 20);
        headerLabel.font = [UIFont boldSystemFontOfSize:13.0];
    }
    else
    {
        headerLabel.frame = CGRectMake(20, 2, tableView.frame.size.width - 5, 28);
        headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor blackColor];
    
    headerLabel.textAlignment = NSTextAlignmentLeft;
    // 4. Add the label to the header view
    [headerView addSubview:headerLabel];
    
    UILabel* totalDaysInWeekLabel = [[UILabel alloc] init];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        totalDaysInWeekLabel.frame = CGRectMake(10, 24, 100, 20);
        totalDaysInWeekLabel.font = [UIFont boldSystemFontOfSize:12.0];

    }
    else
    {
        totalDaysInWeekLabel.frame = CGRectMake(20, 30, 300, 23);
        totalDaysInWeekLabel.font = [UIFont boldSystemFontOfSize:14.0];

    }
    totalDaysInWeekLabel.backgroundColor = [UIColor clearColor];
    totalDaysInWeekLabel.textColor = [UIColor blackColor];
    totalDaysInWeekLabel.textAlignment = NSTextAlignmentLeft;
    
    // 4. Add the label to the header view
    [headerView addSubview:totalDaysInWeekLabel];
    
    UILabel* totalHrsInWeekLabel = [[UILabel alloc] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        totalHrsInWeekLabel.frame = CGRectMake(140, 24, 120, 20);
        totalHrsInWeekLabel.font = [UIFont boldSystemFontOfSize:12.0];
    }
    else
    {
        totalHrsInWeekLabel.frame = CGRectMake(230, 30, 300, 23);
        totalHrsInWeekLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    totalHrsInWeekLabel.backgroundColor = [UIColor clearColor];
    totalHrsInWeekLabel.textColor = [UIColor blackColor];
    
    totalHrsInWeekLabel.textAlignment = NSTextAlignmentLeft;
    // 4. Add the label to the header view
    [headerView addSubview:totalHrsInWeekLabel];
    
    
    if (typeofParsing == 12)
    {
       // currentButton.backgroundColor = [UIColor clearColor];
       // nextButton.backgroundColor = [UIColor clearColor];
       // previousButton.backgroundColor = [UIColor clearColor];
        
        //headerLabel.font = [UIFont boldSystemFontOfSize:12.0];
        
       
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//2014/08/27
        NSDate *dateStart = [dateFormat dateFromString:startDatelastWeek];
        NSDate *dateEnd = [dateFormat dateFromString:endDatelastWeek];
       // NSDate *formateddate = [];
        [dateFormat setDateFormat:@"MM/dd/yyy"];
        
      NSString *tempstartDatelastWeek = [dateFormat stringFromDate:dateStart];
      NSString *tempendDatelastWeek = [dateFormat stringFromDate:dateEnd];
         weekStartendDateDetails = [NSString stringWithFormat:@"%@ to %@",tempstartDatelastWeek,tempendDatelastWeek];
      
    
        headerLabel.text = [NSString stringWithFormat:@"Weekly-Detail :  %@",weekStartendDateDetails];
        
        
          EmpReportsDetailsBO *objWeekDaily = (EmpReportsDetailsBO *) [arrayParsedList objectAtIndex:section];
        
        NSString *totalWorkedDaysStr = objWeekDaily.strTotalWorkedDays;
         NSString *totalWorkedHrsStr = objWeekDaily.strTotalWorkedHrs;
        
        if ([totalWorkedDaysStr isEqualToString:@"Emp"]) {
            
            totalWorkedDaysStr = @"N/A";
        }
        if ([totalWorkedHrsStr isEqualToString:@"Emp"])
        {
            totalWorkedHrsStr = @"N/A";
        }
        
         totalDaysInWeekLabel.text = [NSString stringWithFormat:@"Total Days :  %@",totalWorkedDaysStr];
        
        totalHrsInWeekLabel.text = [NSString stringWithFormat:@"Total Hrs :  %@",totalWorkedHrsStr];
        
        
    }
    else if (typeofParsing == 13)
    {
       // currentButton.backgroundColor = [UIColor grayColor];
      //  nextButton.backgroundColor = [UIColor grayColor];
      //  previousButton.backgroundColor = [UIColor grayColor];
        
        
        
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//2014/08/27
        NSDate *weekDateStart = [dateFormat dateFromString:tempPrviWeekStrtDate];
        NSDate *weekDateEnd = [dateFormat dateFromString:tempPrviWeekEndDate];
        // NSDate *formateddate = [];
        [dateFormat setDateFormat:@"MM/dd/yyy"];

        NSString *tempWeekstartDatelastWeek = [dateFormat stringFromDate:weekDateStart];
        NSString *tempWeekendDatelastWeek = [dateFormat stringFromDate:weekDateEnd];
        
     NSString *weekSummeryStartendDateDetails = [NSString stringWithFormat:@"%@ to %@",tempWeekstartDatelastWeek,tempWeekendDatelastWeek];
        
        
        headerLabel.text = [NSString stringWithFormat:@"Weekly-Summary:  %@",weekSummeryStartendDateDetails];
        

        
         EmpWeekSummeryReportsBO *objWeekSummery = (EmpWeekSummeryReportsBO *) [arrayParsedList objectAtIndex:section];
        
         totalDaysInWeekLabel.text = [NSString stringWithFormat:@"Total Days :  %@",objWeekSummery.strGrandTotalWDays];
        
        totalHrsInWeekLabel.text = [NSString stringWithFormat:@"Total Hrs :  %@",objWeekSummery.strGrandTotalWHrsTime];
        
        
        
        // headerLabel.text = @"Weekly-Summery Report";
        
        
        
        
    }
    else if (typeofParsing == 14)
    {
       // currentButton.backgroundColor = [UIColor grayColor];
      //  nextButton.backgroundColor = [UIColor grayColor];
     //   previousButton.backgroundColor = [UIColor grayColor];
        
        
        
        
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];//2014/08/27
        NSDate *monthDateStart = [dateFormat dateFromString:startDate];
        NSDate *monthDateEnd = [dateFormat dateFromString:endDate];
        // NSDate *formateddate = [];
        [dateFormat setDateFormat:@"MM/dd/yyy"];
        
        NSString *tempMonthstartDatelastWeek = [dateFormat stringFromDate:monthDateStart];
        NSString *tempMonthendDatelastWeek = [dateFormat stringFromDate:monthDateEnd];
        
        
        NSString *monthSummeryStartendDateDetails = [NSString stringWithFormat:@"%@ to %@",tempMonthstartDatelastWeek,tempMonthendDatelastWeek];
        
        
        headerLabel.text = [NSString stringWithFormat:@"Monthly-Summary:  %@",monthSummeryStartendDateDetails];

        
        
        EmpWeekSummeryReportsBO *objWeekSummery = (EmpWeekSummeryReportsBO *) [arrayParsedList objectAtIndex:section];
        
        totalDaysInWeekLabel.text = [NSString stringWithFormat:@"Total Days :  %@",objWeekSummery.strGrandTotalWDays];
        
        totalHrsInWeekLabel.text = [NSString stringWithFormat:@"Total Hrs :  %@",objWeekSummery.strGrandTotalWHrsTime];
        
        
        
        
        
        
        
        
        // headerLabel.text = @"Monthly-Summery: ";
    }
    // 5. Finally return
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
    if (typeofParsing == 12)
    {
    return 36.0;
    }
    else if (typeofParsing == 13)
    {
        return 80.0;
    }
    else if (typeofParsing == 14)
    {
       return 80.0;
    }
    }
    else
    {
        if (typeofParsing == 12)
        {
            return 40.0;
        }
        else if (typeofParsing == 13)
        {
            return 90.0;
        }
        else if (typeofParsing == 14)
        {
            return 90.0;
        }

    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        //Week daily report
        
        UILabel *weekDayDateLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            weekDayDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 100.0, 24.0)];
            weekDayDateLabel.font = [UIFont boldSystemFontOfSize:12];
        }
        else
        {
            weekDayDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 100.0, 24.0)];
            weekDayDateLabel.font = [UIFont boldSystemFontOfSize:14];
        }
        
        [weekDayDateLabel setTag:1];
        
        weekDayDateLabel.textColor = [UIColor blackColor];
        [weekDayDateLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDayDateLabel];
        
        
        UILabel *weekDaySignDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 30.0, 130.0, 24.0)];
        [weekDaySignDateLabel setTag:2];
        weekDaySignDateLabel.font = [UIFont boldSystemFontOfSize:10];
        weekDaySignDateLabel.textColor = [UIColor blackColor];
        [weekDaySignDateLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDaySignDateLabel];
        
        
        UILabel *weekDaySigInOutNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(136.0, 5.0, 100.0, 24.0)];
        [weekDaySigInOutNameLabel setTag:3];
        weekDaySigInOutNameLabel.text = @"SignIN/Out Time";
        weekDaySigInOutNameLabel.font = [UIFont boldSystemFontOfSize:12];
        weekDaySigInOutNameLabel.textColor = [UIColor blackColor];
        [weekDaySigInOutNameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDaySigInOutNameLabel];
        
       
        /*
         UILabel *weekDaySigInOutTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(126.0, 30.0, 100.0, 24.0)];
        [weekDaySigInOutTimeLabel setTag:4];
        //weekDaySigInOutTimeLabel.text = @"SignIN/Out Time";
        weekDaySigInOutTimeLabel.font = [UIFont boldSystemFontOfSize:10];
        weekDaySigInOutTimeLabel.textColor = [UIColor blackColor];
        [weekDaySigInOutTimeLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDaySigInOutTimeLabel];
        */
        //**Drag the upside because hide the title
        
        UILabel *weekDaySigInOutTimeLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            weekDaySigInOutTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 5.0, 120.0, 24.0)];
            weekDaySigInOutTimeLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            weekDaySigInOutTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 5.0, 120.0, 24.0)];
            weekDaySigInOutTimeLabel.font = [UIFont systemFontOfSize:12];
        }
        
        [weekDaySigInOutTimeLabel setTag:4];
        //weekDaySigInOutTimeLabel.text = @"SignIN/Out Time";
        
        weekDaySigInOutTimeLabel.textColor = [UIColor blackColor];
        [weekDaySigInOutTimeLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDaySigInOutTimeLabel];
        
        
        
        UILabel *weekDayTtHrsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(234.0, 5.0, 80.0, 24.0)];
        [weekDayTtHrsNameLabel setTag:5];
        weekDayTtHrsNameLabel.text = @"Work Hrs";
        weekDayTtHrsNameLabel.font = [UIFont boldSystemFontOfSize:12];
        weekDayTtHrsNameLabel.textColor = [UIColor blackColor];
        [weekDayTtHrsNameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDayTtHrsNameLabel];
        
        /*
        UILabel *weekDayTtHrsLabel = [[UILabel alloc] initWithFrame:CGRectMake(234.0, 30.0, 80.0, 24.0)];
        [weekDayTtHrsLabel setTag:6];
        weekDayTtHrsLabel.font = [UIFont boldSystemFontOfSize:10];
        weekDayTtHrsLabel.textColor = [UIColor blackColor];
        [weekDayTtHrsLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDayTtHrsLabel];
        *///**Drag the upside because hide the title
        
        UILabel *weekDayTtHrsLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            weekDayTtHrsLabel = [[UILabel alloc] initWithFrame:CGRectMake(246.0, 5.0, 80.0, 24.0)];
            weekDayTtHrsLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            weekDayTtHrsLabel = [[UILabel alloc] initWithFrame:CGRectMake(380.0, 5.0, 80.0, 30.0)];
            weekDayTtHrsLabel.font = [UIFont systemFontOfSize:14];
        }
        [weekDayTtHrsLabel setTag:6];
        
        weekDayTtHrsLabel.textColor = [UIColor blackColor];
        [weekDayTtHrsLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekDayTtHrsLabel];
        
        
        //Week Reports
        UILabel *weekLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 6.0, 50.0, 24.0)];
        weekLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
        weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 6.0, 50.0, 30.0)];
        weekLabel.font = [UIFont systemFontOfSize:14];
            
        }
        [weekLabel setTag:7];
        weekLabel.text = @"Week :";
        weekLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [weekLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekLabel];
        
        
        
        UILabel *WeekDateLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            WeekDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(52.0, 6.0, 160.0, 24.0)];
            WeekDateLabel.font = [UIFont systemFontOfSize:12];

        }
        else
        {
           WeekDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 6.0, 360.0, 30.0)];
            WeekDateLabel.font = [UIFont systemFontOfSize:14];

        }
        [WeekDateLabel setTag:8];
        
        WeekDateLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [WeekDateLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:WeekDateLabel];
        
        
        UILabel *nameLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 30.0, 100.0, 24.0)];
            nameLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30.0, 200.0, 30.0)];
            nameLabel.font = [UIFont systemFontOfSize:14];
        }
        [nameLabel setTag:9];
        
        nameLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabel];
        
        
        UILabel *totalworkedDaysinWeekLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            totalworkedDaysinWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 30.0, 140.0, 24.0)];
            totalworkedDaysinWeekLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            totalworkedDaysinWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 30.0, 240.0, 30.0)];
            totalworkedDaysinWeekLabel.font = [UIFont systemFontOfSize:14];
        }
        [totalworkedDaysinWeekLabel setTag:10];
        
        totalworkedDaysinWeekLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [totalworkedDaysinWeekLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:totalworkedDaysinWeekLabel];
        
        
        UILabel *totalHrsInWeekLabel;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            totalHrsInWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 54.0, 100.0, 24.0)];
            totalHrsInWeekLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            totalHrsInWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 54.0, 200.0, 30.0)];
            totalHrsInWeekLabel.font = [UIFont systemFontOfSize:14];
        }
        [totalHrsInWeekLabel setTag:11];
        
        totalHrsInWeekLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [totalHrsInWeekLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:totalHrsInWeekLabel];
        
        
        UILabel *totalworkedHrsInWeekLabel ;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            totalworkedHrsInWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 54.0, 150.0, 24.0)];
            totalworkedHrsInWeekLabel.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            totalworkedHrsInWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 54.0, 250.0, 30.0)];
            totalworkedHrsInWeekLabel.font = [UIFont systemFontOfSize:14];
        }
        [totalworkedHrsInWeekLabel setTag:12];
        
        totalworkedHrsInWeekLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [totalworkedHrsInWeekLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:totalworkedHrsInWeekLabel];
    
//        
        //Month reports
        UILabel *weekLabelM;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            weekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 6.0, 50.0, 24.0)];
            weekLabelM.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            weekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 6.0, 80.0, 30.0)];
            weekLabelM.font = [UIFont systemFontOfSize:14];
        }
        [weekLabelM setTag:13];
        weekLabelM.text = @"Month :";
        weekLabelM.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [weekLabelM setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:weekLabelM];
        
        
        UILabel *WeekDateLabelM;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            WeekDateLabelM = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 6.0, 100.0, 24.0)];
            WeekDateLabelM.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            WeekDateLabelM = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 6.0, 260.0, 30.0)];
            WeekDateLabelM.font = [UIFont systemFontOfSize:14];
        }
        [WeekDateLabelM setTag:14];
        
        WeekDateLabelM.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [WeekDateLabelM setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:WeekDateLabelM];
        
        
        UILabel *nameLabelM;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            nameLabelM = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 30.0, 100.0, 24.0)];
            nameLabelM.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            nameLabelM = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30.0, 200.0, 24.0)];
            nameLabelM.font = [UIFont systemFontOfSize:14];
        }
        [nameLabelM setTag:15];
        
        nameLabelM.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [nameLabelM setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabelM];
        
        
        UILabel *totalworkedDaysinWeekLabelM;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        totalworkedDaysinWeekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 30.0, 140.0, 24.0)];
            totalworkedDaysinWeekLabelM.font = [UIFont systemFontOfSize:12];
        }
        else
        {
        totalworkedDaysinWeekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 30.0, 240.0, 30.0)];
            totalworkedDaysinWeekLabelM.font = [UIFont systemFontOfSize:14];
        }
        [totalworkedDaysinWeekLabelM setTag:16];
        
        totalworkedDaysinWeekLabelM.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [totalworkedDaysinWeekLabelM setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:totalworkedDaysinWeekLabelM];
        
        UILabel *totalHrsInWeekLabelM;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        totalHrsInWeekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 54.0, 100.0, 24.0)];
            totalHrsInWeekLabelM.font = [UIFont systemFontOfSize:12];
        }
        else
        {
         totalHrsInWeekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 54.0, 200.0, 30.0)];
            totalHrsInWeekLabelM.font = [UIFont systemFontOfSize:14];
        }
        [totalHrsInWeekLabelM setTag:17];
        
        totalHrsInWeekLabelM.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [totalHrsInWeekLabelM setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:totalHrsInWeekLabelM];
        
        
        UILabel *totalworkedHrsInWeekLabelM;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        totalworkedHrsInWeekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(130.0, 54.0, 150.0, 24.0)];
            totalworkedHrsInWeekLabelM.font = [UIFont systemFontOfSize:12];
        }
        else
        {
        totalworkedHrsInWeekLabelM = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 54.0, 250.0, 30.0)];
            totalworkedHrsInWeekLabelM.font = [UIFont systemFontOfSize:14];
        }
        [totalworkedHrsInWeekLabelM setTag:18];
        
        totalworkedHrsInWeekLabelM.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [totalworkedHrsInWeekLabelM setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:totalworkedHrsInWeekLabelM];
        
        
    }
    
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
    else
    {
        //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    if (contactTableView.tag == 1)
    {
        UILabel *weekLabel = (UILabel *) [cell.contentView viewWithTag:7];
        weekLabel.hidden = YES;
        
        UILabel *weekDateLabel = (UILabel *) [cell.contentView viewWithTag:8];
        weekDateLabel.hidden = YES;
        
        UILabel *totalDaysLabel = (UILabel *) [cell.contentView viewWithTag:9];
        totalDaysLabel.hidden = YES;
        
        UILabel *totalworkedDaysinWeekLabelLabel = (UILabel *) [cell.contentView viewWithTag:10];
        totalworkedDaysinWeekLabelLabel.hidden = YES;
        
        UILabel *totalHrsInWeekLabelLabel = (UILabel *) [cell.contentView viewWithTag:11];
        totalHrsInWeekLabelLabel.hidden = YES;
        
        UILabel *totalWorkedHrsInWeekLabel = (UILabel *) [cell.contentView viewWithTag:12];
        totalWorkedHrsInWeekLabel.hidden = YES;
        
        UILabel *weekLabelM = (UILabel *) [cell.contentView viewWithTag:13];
        weekLabelM.hidden = YES;
        
        UILabel *weekDateLabelMS = (UILabel *) [cell.contentView viewWithTag:14];
        weekDateLabelMS.hidden = YES;
        
        UILabel *totalDaysLabelMS = (UILabel *) [cell.contentView viewWithTag:15];
        totalDaysLabelMS.hidden = YES;
        
        UILabel *totalworkedDaysinWeekLabelLabelMS = (UILabel *) [cell.contentView viewWithTag:16];
        totalworkedDaysinWeekLabelLabelMS.hidden = YES;
        
        UILabel *totalHrsInWeekLabelLabelMS = (UILabel *) [cell.contentView viewWithTag:17];
        totalHrsInWeekLabelLabelMS.hidden = YES;
        
        UILabel *totalWorkedHrsInWeekLabelMS = (UILabel *) [cell.contentView viewWithTag:18];
        totalWorkedHrsInWeekLabelMS.hidden = YES;
        
        UILabel *weekDaySigInOutNameLabel = (UILabel *) [cell.contentView viewWithTag:3];
        weekDaySigInOutNameLabel.hidden = YES;
        UILabel *weekDayTtHrsNameLabel = (UILabel *) [cell.contentView viewWithTag:5];
        weekDayTtHrsNameLabel.hidden = YES;
        
        EmpReportsDetailsBO *objWeekDaily = (EmpReportsDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];

        
         NSString *strDateToWeekDay = objWeekDaily.strDay;
        
        UILabel *weekDayRepLabel = (UILabel *) [cell.contentView viewWithTag:1];
        weekDayRepLabel.hidden = NO;
        weekDayRepLabel.text = strDateToWeekDay;
        
        
        NSString *signInTime = objWeekDaily.strSignInTime;
        
        NSString *signOutTime = objWeekDaily.strSignOutTime;
        
        if ([signInTime isEqualToString:@"Emp"])
        {
            signInTime = @"N/A";
        }
        else
        {
            signInTime = objWeekDaily.strSignInTime;
        }
        
        if ([signOutTime isEqualToString:@"Emp"])
        {
            signOutTime = @"N/A";
        }
        else
        {
            signOutTime = objWeekDaily.strSignOutTime;
        }
        
        UILabel *weekDaySigInOutTimeLabel1 = (UILabel *) [cell.contentView viewWithTag:4];
        weekDaySigInOutTimeLabel1.hidden = NO;
        
        NSString *sinInSignOutTime = [NSString stringWithFormat:@"%@ - %@",signInTime,signOutTime];
      
        
        UILabel *weekDayTtHrsLabel1 = (UILabel *) [cell.contentView viewWithTag:6];
        weekDayTtHrsLabel1.hidden = NO;
        NSString *hrsADay = objWeekDaily.strTotalHrs;
        
        BOOL hideHrs = NO;
        
        if ([sinInSignOutTime isEqualToString:@"N/A - N/A"])
        {
            weekDaySigInOutTimeLabel1.text = @"N/A";
            hideHrs = YES;
        }
        else
        {
            weekDaySigInOutTimeLabel1.text = sinInSignOutTime;
            
            
        }
        
        hrsADay = objWeekDaily.strTotalHrs;
        
        if (hideHrs == YES)
        {
            weekDayTtHrsLabel1.hidden = YES;
            hideHrs = NO;
        }
        else if ([hrsADay isEqualToString:@"Emp"])
            
        {
            
            weekDayTtHrsLabel1.text = @"N/A";
        }
        else
        {
             weekDayTtHrsLabel1.text = hrsADay;
            
        }
        
        
         NSString *multipleSignInRes = objWeekDaily.strIsMultiple;
        [cell setUserInteractionEnabled:YES];
//        if ([multipleSignInRes isEqualToString:@"True"])
//        {
//            [cell setUserInteractionEnabled:YES];
//            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
//        }
//        else
//        {
//            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            [cell setUserInteractionEnabled:NO];
//        }
        
        
    }
    
    if (contactTableView.tag == 2 )
    {
        [cell setUserInteractionEnabled:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UILabel *weekDayRepLabel = (UILabel *) [cell.contentView viewWithTag:1];
        weekDayRepLabel.hidden = YES;
        UILabel *weekDaySignDateLabel1 = (UILabel *) [cell.contentView viewWithTag:2];
        weekDaySignDateLabel1.hidden = YES;
        UILabel *weekDaySigInOutNameLabel = (UILabel *) [cell.contentView viewWithTag:3];
        weekDaySigInOutNameLabel.hidden = YES;
        UILabel *weekDaySigInOutTimeLabel1 = (UILabel *) [cell.contentView viewWithTag:4];
        weekDaySigInOutTimeLabel1.hidden = YES;
        UILabel *weekDayTtHrsNameLabel = (UILabel *) [cell.contentView viewWithTag:5];
        weekDayTtHrsNameLabel.hidden = YES;
        UILabel *weekDayTtHrsLabel1 = (UILabel *) [cell.contentView viewWithTag:6];
        weekDayTtHrsLabel1.hidden = YES;
        
        UILabel *weekLabelM = (UILabel *) [cell.contentView viewWithTag:13];
        weekLabelM.hidden = YES;

        UILabel *weekDateLabelMS = (UILabel *) [cell.contentView viewWithTag:14];
        weekDateLabelMS.hidden = YES;
        
        UILabel *totalDaysLabelMS = (UILabel *) [cell.contentView viewWithTag:15];
        totalDaysLabelMS.hidden = YES;
        
        UILabel *totalworkedDaysinWeekLabelLabelMS = (UILabel *) [cell.contentView viewWithTag:16];
        totalworkedDaysinWeekLabelLabelMS.hidden = YES;
        
        UILabel *totalHrsInWeekLabelLabelMS = (UILabel *) [cell.contentView viewWithTag:17];
        totalHrsInWeekLabelLabelMS.hidden = YES;
        
        UILabel *totalWorkedHrsInWeekLabelMS = (UILabel *) [cell.contentView viewWithTag:18];
        totalWorkedHrsInWeekLabelMS.hidden = YES;
        
        
        UILabel *weekLabel = (UILabel *) [cell.contentView viewWithTag:7];
        weekLabel.hidden = NO;
        
        
        
    EmpWeekSummeryReportsBO *objWeek = (EmpWeekSummeryReportsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    
        NSString *startDate1;
        if (ifThisWeekSummery == 123456) {
            startDate1 = objWeek.strStartDate;
        }
        
    
    NSString *endDate1 = objWeek.strEndDate;
    
    NSString *schEmpTime = [NSString stringWithFormat:@"%@ to %@",startDate1,endDate1];
    
    UILabel *weekDateLabel = (UILabel *) [cell.contentView viewWithTag:8];
    weekDateLabel.hidden = NO;
    weekDateLabel.text = schEmpTime;

    UILabel *totalDaysLabel = (UILabel *) [cell.contentView viewWithTag:9];
        totalDaysLabel.hidden = NO;
    totalDaysLabel.text = [NSString stringWithFormat:@"Total days : %@",objWeek.strTotalDays];
    
    UILabel *totalworkedDaysinWeekLabelLabel = (UILabel *) [cell.contentView viewWithTag:10];
    totalworkedDaysinWeekLabelLabel.hidden = NO;
    totalworkedDaysinWeekLabelLabel.text = [NSString stringWithFormat:@"Worked days       : %@",objWeek.strWorkedDays];
    
    UILabel *totalHrsInWeekLabelLabel = (UILabel *) [cell.contentView viewWithTag:11];
        totalHrsInWeekLabelLabel.hidden = NO;
    totalHrsInWeekLabelLabel.text = [NSString stringWithFormat:@"Total Hrs   : %@",objWeek.strTotalHrsTime];

    UILabel *totalWorkedHrsInWeekLabel = (UILabel *) [cell.contentView viewWithTag:12];
        totalWorkedHrsInWeekLabel.hidden = NO;
    totalWorkedHrsInWeekLabel.text = [NSString stringWithFormat:@"Total worked Hrs : %@",objWeek.strTotalWorkedHrs];
    
    }
    else if (contactTableView.tag == 3)
    {
        [cell setUserInteractionEnabled:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UILabel *weekDayRepLabel = (UILabel *) [cell.contentView viewWithTag:1];
        weekDayRepLabel.hidden = YES;
        UILabel *weekDaySignDateLabel1 = (UILabel *) [cell.contentView viewWithTag:2];
        weekDaySignDateLabel1.hidden = YES;
        UILabel *weekDaySigInOutNameLabel = (UILabel *) [cell.contentView viewWithTag:3];
        weekDaySigInOutNameLabel.hidden = YES;
        UILabel *weekDaySigInOutTimeLabel1 = (UILabel *) [cell.contentView viewWithTag:4];
        weekDaySigInOutTimeLabel1.hidden = YES;
        UILabel *weekDayTtHrsNameLabel = (UILabel *) [cell.contentView viewWithTag:5];
        weekDayTtHrsNameLabel.hidden = YES;
        UILabel *weekDayTtHrsLabel1 = (UILabel *) [cell.contentView viewWithTag:6];
        weekDayTtHrsLabel1.hidden = YES;
        
        
        
        UILabel *weekLabel = (UILabel *) [cell.contentView viewWithTag:7];
        weekLabel.hidden = YES;
        
        UILabel *weekDateLabel = (UILabel *) [cell.contentView viewWithTag:8];
        weekDateLabel.hidden = YES;
        
        UILabel *totalDaysLabel = (UILabel *) [cell.contentView viewWithTag:9];
        totalDaysLabel.hidden = YES;
        
        UILabel *totalworkedDaysinWeekLabelLabel = (UILabel *) [cell.contentView viewWithTag:10];
        totalworkedDaysinWeekLabelLabel.hidden = YES;
        
        UILabel *totalHrsInWeekLabelLabel = (UILabel *) [cell.contentView viewWithTag:11];
        totalHrsInWeekLabelLabel.hidden = YES;
        
        UILabel *totalWorkedHrsInWeekLabel = (UILabel *) [cell.contentView viewWithTag:12];
        totalWorkedHrsInWeekLabel.hidden = YES;
        
        UILabel *weekLabelM = (UILabel *) [cell.contentView viewWithTag:13];
        weekLabelM.hidden = NO;
        
        EmpWeekSummeryReportsBO *objWeek = (EmpWeekSummeryReportsBO *) [arrayParsedList objectAtIndex:indexPath.row];
        
        NSString *startDate2 = objWeek.strStartDate;
        NSString *endDate2 = objWeek.strEndDate;
        
        NSString *schEmpTime = [NSString stringWithFormat:@"%@ to %@",startDate2,endDate2];
        
        
        NSString *monthReport = objWeek.strMonth;
        UILabel *weekDateLabelMS = (UILabel *) [cell.contentView viewWithTag:14];
        weekDateLabelMS.hidden = NO;
       // weekDateLabelMS.text = schEmpTime;
        weekDateLabelMS.text = monthReport;
        
        UILabel *totalDaysLabelMS = (UILabel *) [cell.contentView viewWithTag:15];
        totalDaysLabelMS.hidden = NO;
        totalDaysLabelMS.text = [NSString stringWithFormat:@"Total days : %@",objWeek.strTotalDays];
        
        UILabel *totalworkedDaysinWeekLabelLabelMS = (UILabel *) [cell.contentView viewWithTag:16];
        totalworkedDaysinWeekLabelLabelMS.hidden = NO;
        totalworkedDaysinWeekLabelLabelMS.text = [NSString stringWithFormat:@"Worked days       : %@",objWeek.strWorkedDays];
        
        UILabel *totalHrsInWeekLabelLabelMS = (UILabel *) [cell.contentView viewWithTag:17];
        totalHrsInWeekLabelLabelMS.hidden = NO;
        totalHrsInWeekLabelLabelMS.text = [NSString stringWithFormat:@"Total Hrs   : %@",objWeek.strTotalHrsTime];
        
        UILabel *totalWorkedHrsInWeekLabelMS = (UILabel *) [cell.contentView viewWithTag:18];
        totalWorkedHrsInWeekLabelMS.hidden = NO;
        totalWorkedHrsInWeekLabelMS.text = [NSString stringWithFormat:@"Total worked Hrs : %@",objWeek.strTotalWorkedHrs];
        
    }

    //cell.textLabel.text = obj.strTotalHrs;
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
   
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    
UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    EmpReportsDetailsBO *objWeekDaily = (EmpReportsDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    
    NSString *dateStr = objWeekDaily.strDate;
    NSString *weekDaySelecCell1 = objWeekDaily.strDay ;
    
    
    NSInteger fromReport = 888;
    
    NSUserDefaults *def1 = [NSUserDefaults standardUserDefaults];
    [def1 setInteger:fromReport forKey:@"fromReportKeyDidSelc"];
    [def1 setObject:dateStr forKey:@"dateStrFromDidSelcKey"];
    [def1 setObject:weekDaySelecCell1 forKey:@"weekDaySelecCell1Key"];
    [def1 synchronize];

    
    
    ShiftSchTopButtonViewController *objReportButn = [self.storyboard instantiateViewControllerWithIdentifier:@"ShiftSchTopButtonID"];
    objReportButn.delegate = self;
    pop = [[FPPopoverController alloc]initWithViewController:objReportButn];
    pop.contentSize = CGSizeMake(220,180);
    [pop presentPopoverFromView:selectedCell];
    [selectedCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [tableView reloadData];
   //
    
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
