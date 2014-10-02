//
//  MenuViewController.m
//  HR
//
//  Created by Venkata Chinni on 7/30/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "MenuViewController.h"
#import "FPPopoverController.h"
#import "MBProgressHUD.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics



@interface MenuViewController ()

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation MenuViewController

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
    
//self.view.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1.0];
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
        imageview.frame = CGRectMake(10,20, 52, 52);
    }
    imageview.image = [UIImage imageNamed:@"brandLogo.png"];
    [topNaviView addSubview:imageview];
  
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(UserBackButtonTapped)forControlEvents:UIControlEventTouchDown];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            backButton.frame = CGRectMake(270.0, 10.0, 36.0, 26.0);
        }
        else
        {
            backButton.frame = CGRectMake(270.0, 20.0, 40.0, 30.0);
        }
//        backButton.frame = CGRectMake(260.0, 10.0, 60.0, 30.0);
        
    }
    else
    {
        backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        backButton.frame = CGRectMake(680.0, 30.0, 60.0, 30.0);
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
        cmpNameLabel.font = [UIFont boldSystemFontOfSize:20];
        
    }
    else
    {
        cmpNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-150, 30, 300, 40)];
        cmpNameLabel.font = [UIFont boldSystemFontOfSize:24];
        
    }
    
    
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    
    cmpNameLabel.tag = 302;
    //
    
    NSString *strEmpFirstName = [_CmpEmpDetailsDic objectForKey:@"LoginEmpBusinessnameKey"];
    
    NSString *strLastName = [_CmpEmpDetailsDic objectForKey:@"LoginEmpBusinessLastnameKey"];
    
    NSString *empFullName = [NSString stringWithFormat:@"%@ %@",strEmpFirstName,strLastName];
    
    
    if ([strLastName isEqualToString:@"Emp"] || strLastName.length == 0)
    {
        cmpNameLabel.text = strEmpFirstName;
    }else
        
    {
        cmpNameLabel.text = empFullName;
        
    }
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;

    [topNaviView addSubview:cmpNameLabel];
    
    
    _tableView = [[UITableView alloc] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            _tableView.frame = CGRectMake(12, 51, self.view.frame.size.width-24, self.view.frame.size.height-170);
        UIView *backView = [[UIView alloc] init];
        [backView setBackgroundColor:[UIColor clearColor]];
        [_tableView setBackgroundView:backView];
        }
        else
        {
        _tableView.frame = CGRectMake(12, 71, self.view.frame.size.width-24, self.view.frame.size.height-120);
        _tableView.backgroundColor = [UIColor clearColor];

        }
    }
    else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            _tableView.frame = CGRectMake(24, 90, self.view.frame.size.width-48, self.view.frame.size.height-716);
            UIView *backView = [[UIView alloc] init];
            [backView setBackgroundColor:[UIColor clearColor]];
            [_tableView setBackgroundView:backView];
        }
        else
        {
            _tableView.frame = CGRectMake(24, 90, self.view.frame.size.width-48, self.view.frame.size.height-120);
            _tableView.backgroundColor = [UIColor clearColor];
            
        }
        
    }
   // _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [_tableView setShowsVerticalScrollIndicator:NO];

    
    _tableView.layer.cornerRadius = 3;
//    activityIndicator = [[UIActivityIndicatorView alloc] init];
//    activityIndicator.color = [UIColor grayColor];
//    activityIndicator.alpha = 1.0;
//    activityIndicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    activityIndicator.hidden = YES;
//    [self.view addSubview:activityIndicator];
    
    
    menuArray = [[NSMutableArray alloc] initWithObjects:@"Office Status",@"My Profile",@"My Reports",@"Emergency Contact",@"Change Password",@"Change Secure code",@"Logout", nil];
    [_tableView reloadData];
    
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

-(void)UserBackButtonTapped
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // return number of rows
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return cell
    
    
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    //cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];//rgb(85,85,85)
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    
    if (indexPath.row == 0)
    {
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleViewID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];
        
    }
    else if (indexPath.row == 1)
    {
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];
    }
    else if (indexPath.row == 2)
    {
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"MyReportsView"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];
        
    }
    else if (indexPath.row == 3)
    {
        
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"EmergencyContactDetailsID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];

    }
    else if (indexPath.row == 4)
    {
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];
    }
    else if (indexPath.row == 5)
    {
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePassCodeID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:YES];

    }
    else if (indexPath.row == 6)
    {
        [self LogoutButtonTapped];
        
    }

    
    
}


-(void)LogoutButtonTapped
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;

    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
    NSUserDefaults *defaultsLocal = [NSUserDefaults standardUserDefaults];
    
    NSString *oldPasswordStr = [defaultsLocal objectForKey:@"empPasswordTextFielKey"];
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<SetEmpLogout xmlns=\"http://tempuri.org/\">"
    "<CompanyCode>%@</CompanyCode>"
    "<empCompanyID>%@</empCompanyID>"
    "<Password>%@</Password>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "<mobileName>%@</mobileName>"
    "</SetEmpLogout>"
    "</soap:Body>"
    "</soap:Envelope>",cmpCode,empCmpyID,oldPasswordStr,logitudeCmp,latitudeCmp,deviceID,authID,mobileName];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below

   // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/SetEmpLogout" forHTTPHeaderField:@"SOAPAction"];
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
    
//    NSString *strXMl = [[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
//    NSLog(@"XML is : %@", strXMl);
    
    
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
}

#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"SetEmpLogoutResult"])
    {
        
        
    }
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    resultString = [[NSMutableString alloc]initWithString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"SetEmpLogoutResult"])
    {
        if ([resultString isEqualToString:@"Success"])
        {
            NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
            [cmpEmpDetailDefaults removeObjectForKey:@"oneTimeLoginKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"comEmpDetailsDictionaryKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"imgURLKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"empsecureCodeTextFielKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"fromReportKeyDidSelc"];
            [cmpEmpDetailDefaults removeObjectForKey:@"dateStrFromDidSelcKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"weekDaySelecCell1Key"];
//            [cmpEmpDetailDefaults removeObjectForKey:@"cmpCodeTextFieldKey"];
//            [cmpEmpDetailDefaults removeObjectForKey:@"empCompanyIDTFKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"empsecureCodeTextFielKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"empPasswordTextFielKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"storedcmpPWDKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"storedcmpSecureCodeKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"authIDKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"mobileNameKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"comEmpDetailsDictionaryKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"typeOfEmpDetailsKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"fromReportKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"fromReportKeyDidSelc"];
            [cmpEmpDetailDefaults removeObjectForKey:@"dateStrFromDidSelcKey"];
            [cmpEmpDetailDefaults removeObjectForKey:@"weekDaySelecCell1Key"];

           // NSUserDefaults *tempDefaults = [NSUserDefaults standardUserDefaults];
            
           [cmpEmpDetailDefaults removeObjectForKey:@"comEmpDetailsDicKey"];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Successfully Logout" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:resultString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];;
            [alert show];
        }
        
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0)
    {
        UIViewController *objAddContactViewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewID"];
        [self.navigationController pushViewController:objAddContactViewCon animated:NO];
        
    }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
    
    _tableView.userInteractionEnabled = YES;
}

- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    
    _tableView.userInteractionEnabled = YES;
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

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //if (section == 0)
        return 0.0f;
    //return 32.0f;
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
    
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
