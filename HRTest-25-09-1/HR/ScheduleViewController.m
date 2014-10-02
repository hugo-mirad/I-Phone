//
//  ScheduleViewController.m
//  HR
//
//  Created by Venkata Chinni on 7/31/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ShiftSchTopButtonViewController.h"
#import "MBProgressHUD.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

@interface ScheduleViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property(copy,nonatomic) NSString *allEmployeesScheduledElementValueStr,*allEmpSingnedInElementValueStr,*allEmpSingnedOutElementValueStr;

@property (nonatomic, assign) BOOL locationImpCalled;



@end

@implementation ScheduleViewController

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
    
    typeofParsing = 1;
    
       // Do any additional setup after loading the view.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
    
    dictMain = [[NSMutableDictionary alloc]init];
    
    
  //  self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1.0];
//    UIView *topNaviView;
    
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

    
    UIView *underBackView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        underBackView = [[UIView alloc] initWithFrame:CGRectMake(12,topNaviView.frame.origin.y+topNaviView.frame.size.height+2, self.view.frame.size.width-24, 40)];
    }
    else
    {
        underBackView = [[UIView alloc] initWithFrame:CGRectMake(24,topNaviView.frame.origin.y+topNaviView.frame.size.height+10, self.view.frame.size.width-48, 40)];
    }
    underBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:underBackView];
    underBackView.layer.cornerRadius = 3;

    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(UserBackButtonTapped)forControlEvents:UIControlEventTouchDown];
    //[backButton setTitle:@"Back" forState:UIControlStateNormal];
     [backButton setImage:[UIImage imageNamed:@"menuicon.png"] forState:UIControlStateNormal];
    
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
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
    
    
    
    
    shiftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shiftButton addTarget:self action:@selector(UserShiftAButtonTapped:)forControlEvents:UIControlEventTouchDown];
    //[shiftButton setTitle:@"Shift A" forState:UIControlStateNormal];
    [shiftButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [shiftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shiftButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
        shiftButton.frame = CGRectMake(74.0, 5.0, 60.0, 30.0);//(5.0, 10.0, 60.0, 30.0)
        }
        else
        {
        shiftButton.frame = CGRectMake(74.0, 5.0, 60.0, 30.0);//5.0, 20.0, 60.0, 30.0
        }
    }
    else
    {
        shiftButton.frame = CGRectMake(180.0, 5.0, 60.0, 30.0);
        
    }
    [underBackView addSubview:shiftButton];
    
    shiftButton.layer.cornerRadius = 3;
    
    
    
   UIButton  *refeshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refeshButton addTarget:self action:@selector(UserRefreshButtonTapped)forControlEvents:UIControlEventTouchDown];
    [refeshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [refeshButton setBackgroundColor:[UIColor colorWithRed:53.0/255.0 green:159.0/255.0 blue:224.0/255.0 alpha:1.0]];
    [refeshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    refeshButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
        refeshButton.frame = CGRectMake(164.0, 5.0, 60.0, 30.0);//(5.0, 10.0, 60.0, 30.0)
        }
        else
        {
        refeshButton.frame = CGRectMake(164.0, 5.0, 60.0, 30.0);//5.0, 20.0, 60.0, 30.0
        }
    }
    else
    {
        refeshButton.frame = CGRectMake(460.0, 5.0, 60.0, 30.0);
    }
    [underBackView addSubview:refeshButton];
    
    refeshButton.layer.cornerRadius = 3;
    
    
    
    
    tableViewData = [[UITableView alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
        
        tableViewData.frame = CGRectMake(12, underBackView.frame.origin.y+underBackView.frame.size.height+8, self.view.frame.size.width-24, self.view.frame.size.height-topNaviView.frame.origin.y-topNaviView.frame.size.height-56);
        //                UIView *backView = [[UIView alloc] init];
        //                [backView setBackgroundColor:[UIColor clearColor]];
        //                [tableViewData setBackgroundView:backView];
        
        }
        else
        {
        tableViewData.frame = CGRectMake(12, underBackView.frame.origin.y+underBackView.frame.size.height+8, self.view.frame.size.width-24, self.view.frame.size.height-topNaviView.frame.origin.y-topNaviView.frame.size.height-60);
        //_tableView.frame = CGRectMake(0, todaySchView.frame.origin.y+todaySchView.frame.size.height, self.view.frame.size.width, 144);
        //  tableViewData.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        tableViewData.frame = CGRectMake(24, underBackView.frame.origin.y+underBackView.frame.size.height+8, self.view.frame.size.width-48, self.view.frame.size.height-topNaviView.frame.origin.y-topNaviView.frame.size.height-60);
        
    }
    tableViewData.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:tableViewData];
    tableViewData.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableViewData.dataSource = self;
    tableViewData.delegate = self;
    //typeofParsing = 999;
    [tableViewData reloadData];
    tableViewData.layer.cornerRadius = 3;
    [tableViewData setShowsVerticalScrollIndicator:NO];
    tableViewData.hidden = YES;
    
    
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
    cmpNameLabel.text = @"Office Status";
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;
    
    [topNaviView addSubview:cmpNameLabel];
    
    
   SectionTitles = [[NSArray alloc] initWithObjects:@"Scheduled", @"Signed In",@"Signed Out",nil];
    
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    
    //Create and add the Activity Indicator to splashView
//    activityIndicator = [[UIActivityIndicatorView alloc] init];
//    activityIndicator.color = [UIColor whiteColor];
//    activityIndicator.alpha = 1.0;
//    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    activityIndicator.hidden = YES;
//    [activityIndicator startAnimating];
//    [self.view addSubview:activityIndicator];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}
-(void)UserRefreshButtonTapped
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    typeofParsing = 1;
    [_locationManager startUpdatingLocation];
    
    //[self methodName];
    
}
-(void)UserShiftAButtonTapped:(id) sender
{
    UIButton *but = (UIButton *) sender;
    
    
    
    //the controller we want to present as a popover
     ShiftSchTopButtonViewController *objShiftButn = [self.storyboard instantiateViewControllerWithIdentifier:@"ShiftSchTopButtonID"];
    objShiftButn.delegate = self;

    pop = [[FPPopoverController alloc]initWithViewController:objShiftButn];
    //pop.arrowDirection = FPPopoverNoArrow;
    //objNote.contentSizeForViewInPopover = CGSizeMake(100, 50);
    pop.contentSize = CGSizeMake(180,160);
    [pop presentPopoverFromView:but];
    
}
-(void) didSelectRowShiftName:(NSString *) ShiftName ShiftIDEmp:(NSString *) ShiftID
{
    [pop dismissPopoverAnimated:YES];
    
    [shiftButton setTitle:ShiftName forState:UIControlStateNormal];
    
    shiftIDFromSelection =ShiftID;
    shiftNameFromSelection = ShiftName;
    shiftIDbool = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self methodName];
}




-(void)methodName
{
    [self AllUsersScheduledImplementation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
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
        [self methodName];
    }
    else if (typeofParsing == 100)
    {
        [self UsersSignedInImplementation];
    }
    else if (typeofParsing == 101)
    {
        [self UsersSignedOutImplementation];
    }
}

-(void)AllUsersScheduledImplementation

{
   
    if (shiftIDbool == YES)
    {
       dictMain = nil;
        [arrayHeader removeAllObjects];
        dictMain = [[NSMutableDictionary alloc]init];
       // [tableViewData reloadData];
    }
    else
    {
        [tableViewData reloadData];
    }
    typeofParsing = 100;
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    NSString *empShiftID;
    
    if (shiftIDbool == YES)
    {
        empShiftID = shiftIDFromSelection;
       // shiftIDbool = NO;
    }
    else
    {
       empShiftID = [_CmpEmpDetailsDic objectForKey:@"LoginEmpShiftIDKey"];

        
    }
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *signOutDateWithTimeStr =[dateFormatter stringFromDate:date];
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                            " <soap:Body>"
                            " <GetScheduleEmpDetailsMobile xmlns=\"http://tempuri.org/\">"
                            " <companyCode>%@</companyCode>"
                            " <empCompanyID>%@</empCompanyID>"
                            " <shiftID>%@</shiftID> "
                            " <currentDate>%@</currentDate>"
                            " <deviceCode>%@</deviceCode>"
                            " <authenticationID>%@</authenticationID>"
                            " <longitude>%@</longitude>"
                            " <latitude>%@</latitude>"
                            " <mobileName>%@</mobileName>"
                            " </GetScheduleEmpDetailsMobile>"
                            " </soap:Body>"
                             " </soap:Envelope>",cmpCode,empCmpyID,empShiftID,signOutDateWithTimeStr,deviceID,authID,logitudeCmp,latitudeCmp,mobileName];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below

    
   //NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetScheduleEmpDetailsMobile" forHTTPHeaderField:@"SOAPAction"];
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
-(void)UsersSignedInImplementation
{
    typeofParsing = 101;

    //[_locationManager stopUpdatingLocation];
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    //NSString *empShiftID = [_CmpEmpDetailsDic objectForKey:@"LoginEmpShiftIDKey"];
    
    
    NSString *empShiftID;
    
    if (shiftIDbool == YES)
    {
        empShiftID = shiftIDFromSelection;
        //shiftIDbool = NO;
    }
    else
    {
        empShiftID = [_CmpEmpDetailsDic objectForKey:@"LoginEmpShiftIDKey"];
        
        
    }
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *signOutDateWithTimeStr =[dateFormatter stringFromDate:date];
    
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
   " <soap:Body>"
   " <GetSignInEmpDetailsMobile xmlns=\"http://tempuri.org/\">"
   " <companyCode>%@</companyCode>"
   " <empCompanyID>%@</empCompanyID>"
   "<shiftID>%@</shiftID>"
   " <currentDate>%@</currentDate>"
   " <deviceCode>%@</deviceCode>"
   "  <authenticationID>%@</authenticationID>"
   " <longitude>%@</longitude>"
   "  <latitude>%@</latitude>"
   "  <mobileName>%@</mobileName>"
   "  </GetSignInEmpDetailsMobile>"
   "  </soap:Body>"
   "  </soap:Envelope>",cmpCode,empCmpyID,empShiftID,signOutDateWithTimeStr,deviceID,authID,logitudeCmp,latitudeCmp,mobileName];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below

    
   // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetSignInEmpDetailsMobile" forHTTPHeaderField:@"SOAPAction"];
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


-(void)UsersSignedOutImplementation
{
    typeofParsing = 102;

    //[_locationManager stopUpdatingLocation];
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
   // NSString *empShiftID = [_CmpEmpDetailsDic objectForKey:@"LoginEmpShiftIDKey"];
    
    
    NSString *empShiftID;
    
    if (shiftIDbool == YES)
    {
        empShiftID = shiftIDFromSelection;
        tempBoolinbool = YES;
        //shiftIDbool = NO;
    }
    else
    {
        empShiftID = [_CmpEmpDetailsDic objectForKey:@"LoginEmpShiftIDKey"];
        
        
    }
    
    // Write signe in date
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSString *signOutDateWithTimeStr =[dateFormatter stringFromDate:date];
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                            " <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                            " <soap:Body>"
                            " <GetSignOutEmpDetailsMobile xmlns=\"http://tempuri.org/\">"
                            " <companyCode>%@</companyCode>"
                            " <empCompanyID>%@</empCompanyID>"
                            "<shiftID>%@</shiftID>"
                            " <currentDate>%@</currentDate>"
                            " <deviceCode>%@</deviceCode>"
                             "<authenticationID>%@</authenticationID>"
                             "<longitude>%@</longitude>"
                            " <latitude>%@</latitude>"
                            " <mobileName>%@</mobileName>"
                            " </GetSignOutEmpDetailsMobile>"
                            " </soap:Body>"
                            " </soap:Envelope>",cmpCode,empCmpyID,empShiftID,signOutDateWithTimeStr,deviceID,authID,logitudeCmp,latitudeCmp,mobileName];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below

    
    //NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetSignOutEmpDetailsMobile" forHTTPHeaderField:@"SOAPAction"];
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
    if ([elementName isEqualToString:@"GetScheduleEmpDetailsMobileResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
    else if ([elementName isEqualToString:@"GetSignInEmpDetailsMobileResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
    else if ([elementName isEqualToString:@"GetSignOutEmpDetailsMobileResult"])
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
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    currentElementValue = [[NSMutableString alloc]initWithString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"GetScheduleEmpDetailsMobileResult"])
    {
        if ([objEmp.strAaSuccess1 caseInsensitiveCompare:@"No records found"] == NSOrderedSame)
        {
            tempBoolForSchdRecords = YES;
        }
        else
        {
            tempBoolForSchdRecords = NO;
            [dictMain setObject:arrayParsedList forKey:@"GetScheduleEmpDetailsMobileResultKey"];
        }
    }
   
    else if ([elementName isEqualToString:@"GetSignInEmpDetailsMobileResult"])
    {
        if ([objEmp.strAaSuccess1 caseInsensitiveCompare:@"No records found"] == NSOrderedSame)
        {
            tempBoolForSigINRecords = YES;
        }
        else
        {
            tempBoolForSigINRecords = NO;
            [dictMain setObject:arrayParsedList forKey:@"GetSignInEmpDetailsMobileResultKey"];
        }
    }
    
    else if ([elementName isEqualToString:@"GetSignOutEmpDetailsMobileResult"])
    {
        if ([objEmp.strAaSuccess1 caseInsensitiveCompare:@"No records found"] == NSOrderedSame)
        {
            tempBoolForSigOutRecords = YES;
        }
        else
        {
            tempBoolForSigOutRecords = NO;
            [dictMain setObject:arrayParsedList forKey:@"GetSignOutEmpDetailsMobileResultKey"];
        }
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
        NSString *photo =[currentElementValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        objEmp.strPhoto = photo;
    }
    else if ([elementName isEqualToString:@"SignInTime"])
    {
        objEmp.strSignInTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignOutTime"])
    {
        objEmp.strSignOutTime = currentElementValue;
    }
    
    currentElementValue = nil;
}


-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
    
    if (tempBoolForSchdRecords && tempBoolForSigINRecords && tempBoolForSigOutRecords )
    {
        
       NSString *aaSuccess1Str = objEmp.strAaSuccess1;
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:aaSuccess1Str delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
            tableViewData.hidden = YES;
        [tableViewData reloadData];
        tempBoolForSchdRecords = NO;
        tempBoolForSigINRecords = NO;
        tempBoolForSigOutRecords = NO;
    }
    
    else
    {
        
   
    
    NSString *aaSuccess1Str = objEmp.strAaSuccess1;
    
   if ([aaSuccess1Str isEqualToString:@"Failed"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Unable to process the request due to Server/Network Problem" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }

   
   else
  
   {
        if (typeofParsing == 100)
        {
            [_locationManager startUpdatingLocation];
        }
        else if (typeofParsing == 101)
        {
            [_locationManager startUpdatingLocation];
        }
        else if (typeofParsing == 102)
        {
            typeofParsing = 999;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.view.userInteractionEnabled = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            arrayHeader = [NSMutableArray arrayWithArray:[dictMain allKeys]];
            
            
            if (tableViewData)
            {
                tableViewData.hidden = NO;
                [tableViewData reloadData];
                
            }
            else
            {
            
                tableViewData.hidden = NO;
                [tableViewData reloadData];


         }
            
            NSString *empShiftName;
           
            if (shiftIDbool == YES)
            {
                [tableViewData reloadData];
                empShiftName = shiftNameFromSelection;
                //shiftIDbool = NO;
            }
            else
            {
              empShiftName = [_CmpEmpDetailsDic objectForKey:@"LoginEmpShiftNameKey"];
                
            }
            
                [shiftButton setTitle:empShiftName forState:UIControlStateNormal];
            
           
        }
    
    }
        
}
    
    
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



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [dictMain count];
}
- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
   if (section == 0)
    {
    return @" ";
    }
   else if(section == 1)
    {
   return @" ";
    }
   else
   {
   return @" ";
   }

//    return [SectionTitles objectAtIndex:section];
    
    
}

//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UILabel *myLabel = [[UILabel alloc] init];
//    myLabel.frame = CGRectMake(0, 5, self.view.frame.size.width, 20);
//    myLabel.font = [UIFont boldSystemFontOfSize:14];
//    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//    myLabel.textAlignment = NSTextAlignmentCenter;
//    
//    UIView *headerView = [[UIView alloc] init];
//    [headerView addSubview:myLabel];
//    
//    return headerView;
//}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 0)
//        return 1.0f;
//    return 1.0f;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray *array = [dictMain objectForKey:[arrayHeader objectAtIndex:section]];
    return [array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 72;
    }
    else if (indexPath.section == 1)
    {
        return 98;
    }
    else
    {
        return 108;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        cell.layer.shadowOffset = CGSizeMake(1, 0);
        cell.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.layer.shadowRadius = 1;
        cell.layer.shadowOpacity = 0.25;
        
        
        
        AsyncImageView *imgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(4, 6, 60, 60)]; // your cell's height should be greater than 48 for this.
        // UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        imgView.tag = 1;
        [cell.contentView addSubview:imgView];
        
        
        imgView.layer.shadowOffset = CGSizeMake(1, 0);
        imgView.layer.shadowOpacity = 0.25;
        imgView.layer.borderWidth = 1.0;
        imgView.layer.borderColor = [[UIColor grayColor] CGColor];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 4.0, 200.0, 20.0)];
        [nameLabel setTag:2];
        nameLabel.font = [UIFont boldSystemFontOfSize:14];
        nameLabel.textColor = [UIColor blackColor ];
//        nameLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];//(51,51,51)
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *desgLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 22.0, 200.0, 18.0)];
        [desgLabel setTag:3];
        desgLabel.font = [UIFont systemFontOfSize:12];
        desgLabel.textColor = [UIColor grayColor];
//        desgLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];//102,102,102
        [desgLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:desgLabel];
        
        UILabel *SchTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 40.0, 100.0, 18.0)];
        [SchTimeLabel setTag:4];
        SchTimeLabel.text = @"Schedule Time :  ";
        SchTimeLabel.font = [UIFont systemFontOfSize:12];
        SchTimeLabel.textColor = [UIColor blackColor];
//        SchTimeLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];
        [SchTimeLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:SchTimeLabel];
        
        UILabel *SchTimeLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(170.0, 40.0, 200.0, 18.0)];
        [SchTimeLabel1 setTag:5];
        SchTimeLabel1.font = [UIFont systemFontOfSize:12];
        SchTimeLabel1.textColor = [UIColor grayColor];
//        SchTimeLabel1.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];
        [SchTimeLabel1 setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:SchTimeLabel1];
        
        UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 58.0, 100.0, 18.0)];
        [loginLabel setTag:6];
        loginLabel.text = @"Login Time       : ";
        loginLabel.font = [UIFont systemFontOfSize:12];
        loginLabel.textColor = [UIColor blackColor ];
//        loginLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];
        [loginLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:loginLabel];
        
        UILabel *loginLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(170.0, 58.0, 200.0, 18.0)];
        [loginLabel1 setTag:7];
        loginLabel1.font = [UIFont systemFontOfSize:12];
        loginLabel1.textColor = [UIColor colorWithRed:130.0/255.0 green:198.0/255.0 blue:33.0/255.0 alpha:1.0];//130, 198, 33
//        loginLabel1.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];
        [loginLabel1 setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:loginLabel1];
        
        UILabel *logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 76.0, 100.0, 18.0)];
        [logoutLabel setTag:8];
        logoutLabel.text = @"Logout Time     : ";
        logoutLabel.font = [UIFont systemFontOfSize:12];
        logoutLabel.textColor = [UIColor blackColor ];
//        logoutLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];
        [logoutLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:logoutLabel];
        
        UILabel *logoutLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(170.0, 76.0, 200.0, 18.0)];
        [logoutLabel1 setTag:9];
        logoutLabel1.font = [UIFont systemFontOfSize:13];
        logoutLabel1.textColor = [UIColor colorWithRed:239.0/255.0 green:83.0/255.0 blue:82.0/255.0 alpha:1.0];//239, 83, 82
//        logoutLabel1.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0 ];
        [logoutLabel1 setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:logoutLabel1];
        
        UIImageView *imgViewAva;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
        imgViewAva = [[UIImageView alloc] initWithFrame:CGRectMake(260, 10, 16, 16)]; // your cell's height should be greater than 48 for this.
        }
        else
        {
            imgViewAva = [[UIImageView alloc] initWithFrame:CGRectMake(660, 10, 16, 16)];
        }
        imgViewAva.tag = 12;
        [cell.contentView addSubview:imgViewAva];
    }
//    cell.layer.shouldRasterize = YES;
//    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
   //cell.backgroundColor = [UIColor whiteColor];
    
    
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
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
   
    NSMutableArray *array = [dictMain objectForKey:[arrayHeader objectAtIndex:indexPath.section]];
    
    EmpScheduledDetailsBO *obj = (EmpScheduledDetailsBO *) [array objectAtIndex:indexPath.row];
    
    
    AsyncImageView *imgView = (AsyncImageView *) [cell.contentView viewWithTag:1];
    
   // UIImageView *imgView = (UIImageView *) [cell.contentView viewWithTag:1];
    
    NSString *imgURL = obj.strPhoto;

    
    if (imgURL != nil)
    {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
       // NSString *urlStr = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // NSLog(@"imgURL--%@,urlStr--%@",urlStr,imgURL);
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
        
       
        dispatch_async(dispatch_get_main_queue(), ^{
          
            if (data != nil)
            {
                [imgView setImage:[UIImage imageWithData:data]];
               // data = nil;
            }
            else
            {
                [imgView setImage:[UIImage imageNamed:@"user.png"]];
            }
           
            
            
        });
    });
    
    }
    else
    {
        [imgView setImage:[UIImage imageNamed:@"user.png"]];
    }

    
   
    
    
    UILabel *nameLabel = (UILabel *) [cell.contentView viewWithTag:2];
    nameLabel.text = obj.strBusinessFname;
    
    
    UILabel *desgLabel = (UILabel *) [cell.contentView viewWithTag:3];
    
    
    NSString *desigStr =  obj.strDesignation;
    if ([desigStr isEqualToString:@"Emp"])
    {
        desgLabel.text = @"-";
    }
    else
        
    {
        desgLabel.text = desigStr;
    }
    
    
    //UILabel *SchTimeLabel = (UILabel *) [cell.contentView viewWithTag:4];
    
    UILabel *SchTimeLabel1 = (UILabel *) [cell.contentView viewWithTag:5];
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
//    
//    NSDate *dateStart = [formatter dateFromString:obj.strScheduleStart];
//    NSDate *dateEnd = [formatter dateFromString:obj.strScheduleEnd];
//    
//    [formatter setDateFormat:@"hh:mm a"];
//    NSString *startDate = [formatter stringFromDate:dateStart];
//    NSString *endDate = [formatter stringFromDate:dateEnd];
    
    
    NSString *startDate = obj.strScheduleStart;
    NSString *endDate = obj.strScheduleEnd;
    NSString *strScheduleTime = [startDate stringByAppendingFormat:@" - %@", endDate];
    SchTimeLabel1.text = strScheduleTime;
    
    
    UILabel *loginLabel = (UILabel *) [cell.contentView viewWithTag:6];
    UILabel *loginLabel1 = (UILabel *) [cell.contentView viewWithTag:7];

//    if (indexPath.section == 1 || indexPath.section == 2)
//    {
//        loginLabel.hidden = NO;
//        loginLabel1.hidden = NO;
//        loginLabel1.text = obj.strSignInTime;
//    }
//    else
//    {
//        loginLabel.hidden = YES;
//        loginLabel1.hidden = YES;
//    }
//    
//    
    UILabel *logoutLabel = (UILabel *) [cell.contentView viewWithTag:8];
    UILabel *logoutLabel1 = (UILabel *) [cell.contentView viewWithTag:9];
    
    
//    if (indexPath.section == 2)
//    {
//        logoutLabel.hidden = NO;
//        logoutLabel1.hidden = NO;
//        logoutLabel1.text = obj.strSignOutTime;
//    }
//    else
//    {
//        logoutLabel.hidden = YES;
//        logoutLabel1.hidden = YES;
//    }
//
    
    
    UIImageView *imgViewAva = (UIImageView *) [cell.contentView viewWithTag:12];
    
//    if (indexPath.section == 0)
//        {
//    if (typeofParsing == 101)
//    {
//        imgViewAva.image = [UIImage imageNamed:@"green-circle-icone-4156-128.png"];
//    }
//   else if (typeofParsing == 102)
//   {
//        imgViewAva.image = [UIImage imageNamed:@"red-circle-icone-5751-128.png"];
//   }
//    else
//    {
//         imgViewAva.image = [UIImage imageNamed:@"gray-circle-icone-6920-128.png"];
//    }
//        }
//    else if (indexPath.section == 1)
//    {
//        if (typeofParsing == 101)
//        {
//            imgViewAva.image = [UIImage imageNamed:@"green-circle-icone-4156-128.png"];
//        }
//        else if (typeofParsing == 102)
//        {
//            imgViewAva.image = [UIImage imageNamed:@"red-circle-icone-5751-128.png"];
//        }
//        else
//        {
//            imgViewAva.image = [UIImage imageNamed:@"gray-circle-icone-6920-128.png"];
//        }
//    }
//    else if (indexPath.section == 2)
//    {
//        if (typeofParsing == 101)
//        {
//            imgViewAva.image = [UIImage imageNamed:@"green-circle-icone-4156-128.png"];
//        }
//        else if (typeofParsing == 102)
//        {
//            imgViewAva.image = [UIImage imageNamed:@"red-circle-icone-5751-128.png"];
//        }
//        else
//        {
//            imgViewAva.image = [UIImage imageNamed:@"gray-circle-icone-6920-128.png"];
//        }
//    }
    
    if ([[arrayHeader objectAtIndex:indexPath.section] isEqualToString:@"GetScheduleEmpDetailsMobileResultKey"])
    {
        imgViewAva.image = [UIImage imageNamed:@"gray-circle-icone-6920-128.png"];
        
        loginLabel.hidden = YES;
        loginLabel1.hidden = YES;
        
        logoutLabel.hidden = YES;
        logoutLabel1.hidden = YES;

    }
    else if ([[arrayHeader objectAtIndex:indexPath.section] isEqualToString:@"GetSignInEmpDetailsMobileResultKey"])
    {
        imgViewAva.image = [UIImage imageNamed:@"green-circle-icone-4156-128.png"];
        
        loginLabel.hidden = NO;
        loginLabel1.hidden = NO;
        loginLabel1.text = obj.strSignInTime;
        
        logoutLabel.hidden = YES;
        logoutLabel1.hidden = YES;
    }
    else if ([[arrayHeader objectAtIndex:indexPath.section] isEqualToString:@"GetSignOutEmpDetailsMobileResultKey"])
    {
        imgViewAva.image = [UIImage imageNamed:@"red-circle-icone-5751-128.png"];
        
        loginLabel.hidden = NO;
        loginLabel1.hidden = NO;
        loginLabel1.text = obj.strSignInTime;
        
        logoutLabel.hidden = NO;
        logoutLabel1.hidden = NO;
        logoutLabel1.text = obj.strSignOutTime;

    }

//    if (indexPath.section == 0)
//    {
//        imgViewAva.image = [UIImage imageNamed:@"gray-circle-icone-6920-128.png"];
//    }
//    if (indexPath.section == 1)
//    {
//        imgViewAva.image = [UIImage imageNamed:@"green-circle-icone-4156-128.png"];
//    }
//    else if (indexPath.section == 2)
//    {
//        imgViewAva.image = [UIImage imageNamed:@"red-circle-icone-5751-128.png"];
//    }
   
  
    return cell;
    
    
}




-(void)UserBackButtonTapped
{
    typeofParsing = 0;
    [self.navigationController popViewControllerAnimated:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
