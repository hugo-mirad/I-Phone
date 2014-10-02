//
//  ShiftSchTopButtonViewController.m
//  HRTest
//
//  Created by Venkata Chinni on 8/25/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "ShiftSchTopButtonViewController.h"
#import "FPPopoverController.h"


//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

@interface ShiftSchTopButtonViewController ()

@end

@implementation ShiftSchTopButtonViewController

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
    
    tempArray = [NSMutableArray arrayWithObjects:@"Weekly-Detail",@"Weekly-Summary",@"Monthly-Summary", nil];
    
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    
    activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.color = [UIColor whiteColor];
    activityIndicator.alpha = 1.0;
    //activityIndicator.frame =  CGRectMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f, 40, 40) ;
    NSUserDefaults *def1 = [NSUserDefaults standardUserDefaults];
    NSInteger fromReports2 =  [[def1 objectForKey:@"fromReportKeyDidSelc"]integerValue];
    if (fromReports2 == 888)
        
    {
        activityIndicator.frame = CGRectMake(60, 40, 75, 50);;
    }
    else
    {
        activityIndicator.frame = CGRectMake(45, 40, 75, 50);;
    }
    activityIndicator.hidden = YES;
    [self.view addSubview:activityIndicator];
    
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    _startLocation = nil;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
   NSInteger fromReports = [[def objectForKey:@"fromReportKey"] integerValue];
    
//    NSUserDefaults *def1 = [NSUserDefaults standardUserDefaults];
//    NSInteger fromReports2 =  [[def1 objectForKey:@"fromReportKeyDidSelc"]integerValue];
    
    
    if (fromReports == 999)
    
    {
        
        if (_tableView) {
            [_tableView reloadData];
        }
        
        else
        {
        
        _tableView = [[UITableView alloc] init];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            _tableView.frame = CGRectMake(4, 2, 160, 125);
            UIView *backView = [[UIView alloc] init];
            [backView setBackgroundColor:[UIColor clearColor]];
            
            [_tableView setBackgroundView:backView];
        }else{
            _tableView.frame = CGRectMake(0, 0, 160, 140);
            _tableView.backgroundColor = [UIColor clearColor];
            
        }
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
        }
        
       // _tableView.hidden = NO;
       // [_tableView reloadData];
        tableRows = 3;
      
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
         [def removeObjectForKey:@"fromReportKey"];
        
    }
    else if (fromReports2 == 888)
    
    {
        typeofParsing = 11;
        [_locationManager startUpdatingLocation];
        
        _tableView.hidden = NO;
        [_tableView reloadData];
        
        NSUserDefaults *def1 = [NSUserDefaults standardUserDefaults];
        [def1 removeObjectForKey:@"fromReportKeyDidSelc"];

    }
    else
    {
        _tableView.hidden = NO;
        [_tableView reloadData];
        typeofParsing = 10;
    [_locationManager startUpdatingLocation];

    }
    
  //  menuArray = [[NSMutableArray alloc] initWithObjects:@"Shift A",@"Shift B",@"Shift C", nil];
    
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
        [self EmpShiftDetailsImplementation];
    }
    else if (typeofParsing == 11)
    {
         NSUserDefaults *def1 = [NSUserDefaults standardUserDefaults];
          NSString *dateFromDidSectRow = [def1 objectForKey:@"dateStrFromDidSelcKey"];
        [self getSingleDayReportImplementation:dateFromDidSectRow];

    }
}

-(void)getSingleDayReportImplementation:(NSString *)dateFromSelectedRow
{

    typeofParsing = 777;
    
[activityIndicator startAnimating];
    
    
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
                             "<GetSingleDayReport xmlns=\"http://tempuri.org/\">"
                             "<empCompanyID>%@</empCompanyID>"
                             "<companyCode>%@</companyCode>"
                             "<startDate>%@</startDate>"
                             "<endDate>%@</endDate>"
                             "<longitude>%@</longitude>"
                             "<latitude>%@</latitude>"
                             "<mobileName>%@</mobileName>"
                             "<deviceCode>%@</deviceCode>"
                             "<authenticationID>%@</authenticationID>"
                             "</GetSingleDayReport>"
                             "</soap:Body>"
                             "</soap:Envelope>",empCmpyID,cmpCode,dateFromSelectedRow,dateFromSelectedRow,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetSingleDayReport" forHTTPHeaderField:@"SOAPAction"];
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

-(void)EmpShiftDetailsImplementation
{
    [activityIndicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    typeofParsing = 122;
    NSString *cmpCode = [_CmpEmpDetailsDic objectForKey:@"CompanyCodeKey"];
    NSString *empCmpyID = [_CmpEmpDetailsDic objectForKey:@"EmpCompanyIDKey"];
    
    
    NSString *deviceID = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    
    NSUserDefaults *deviceIDandMobileName = [NSUserDefaults standardUserDefaults];
    NSString *authID = [deviceIDandMobileName objectForKey:@"authIDKey"];
    NSString *mobileName = [deviceIDandMobileName objectForKey:@"mobileNameKey"];
    
    NSString *logitudeCmp = longitudeStr;
    NSString *latitudeCmp = latitudeStr;
    
     NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
   " <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
    "<soap:Body>"
    "<GetShiftsDetailsByEmp xmlns=\"http://tempuri.org/\">"
    "<companyCode>%@</companyCode>"
    "<empCompanyID>%@</empCompanyID>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<mobileName>%@</mobileName>"
    "</GetShiftsDetailsByEmp>"
    "</soap:Body>"
    "</soap:Envelope>",cmpCode,empCmpyID,deviceID,authID,logitudeCmp,latitudeCmp,mobileName];
    
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetShiftsDetailsByEmp" forHTTPHeaderField:@"SOAPAction"];
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
    if ([elementName isEqualToString:@"GetShiftsDetailsByEmpResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
    else if ([elementName isEqualToString:@"shiftInfo"])
    {
        if (objEmps)
        {
            objEmps = nil;
        }
        
        objEmps = [[EmpsShiftDetailsBO alloc]init];
    }
    
    if ([elementName isEqualToString:@"GetSingleDayReportResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
    else if ([elementName isEqualToString:@"mobileEmpInfo"])
    {
        if (objEmps)
        {
            objEmps = nil;
        }
        
        objEmps = [[EmpsShiftDetailsBO alloc]init];
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
    
    if ([elementName isEqualToString:@"GetShiftsDetailsByEmpResult"])
    {
       
        
    }
    else if ([elementName isEqualToString:@"shiftInfo"])
    {
        [arrayParsedList addObject:objEmps];
    }
    
    if ([elementName isEqualToString:@"GetSingleDayReportResult"])
    {
        
        
    }
    else if ([elementName isEqualToString:@"mobileEmpInfo"])
    {
        [arrayParsedList addObject:objEmps];
    }
    
    
    
    
    else if ([elementName isEqualToString:@"AaSuccess1"])
    {
         objEmps.strAaSuccess1 = currentElementValue;
    }
    else if ([elementName isEqualToString:@"StartTime"])
    {
        objEmps.strStartTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ShiftEnd"])
    {
        objEmps.strShiftEnd = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Shiftname"])
    {
        objEmps.strShiftname = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ShiftID"])
    {
       objEmps.strShiftID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"IsCrossOver"])
    {
        objEmps.strIsCrossOver = currentElementValue;
    }
    else if ([elementName isEqualToString:@"OfficeID"])
    {
        objEmps.strOfficeID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"CompanyID"])
    {
       objEmps.strCompanyID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"OfficeCode"])
    {
       objEmps.strOfficeCode = currentElementValue;
    }
    else if ([elementName isEqualToString:@"CompanyCode"])
    {
        objEmps.strCompanyCode = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ShiftStartTime"])
    {
      objEmps.strShiftStartTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ShiftEndTime"])
    {
        objEmps.strShiftEndTime = currentElementValue;
    }
    
//MultipleSignIn/Out SingleDay
    
    else if ([elementName isEqualToString:@"SignInTime"])
    {
        objEmps.strSignInTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"SignOutTime"])
    {
        objEmps.strSignOutTime = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Date"])
    {
        objEmps.strDate = currentElementValue;
    }
    
    
    
    currentElementValue = nil;
    
    
}
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.view.userInteractionEnabled = YES;
    
    [activityIndicator startAnimating];
    
    if (typeofParsing == 122)
    {
        
        if (_tableView) {
            [_tableView reloadData];
        }
        
        else
        {
    _tableView = [[UITableView alloc] init];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        _tableView.frame = CGRectMake(3, 0, 154, 120);
        UIView *backView = [[UIView alloc] init];
        [backView setBackgroundColor:[UIColor clearColor]];
        
        [_tableView setBackgroundView:backView];
    }
    else
    {
        _tableView.frame = CGRectMake(3, 0, 154, 120);
        _tableView.backgroundColor = [UIColor clearColor];
        
    }
            _tableView.tag = 123;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:self.tableView];
        }
    [activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }
    else
    {
       
        NSString *sucessStr = objEmps.strAaSuccess1;
        if ([sucessStr isEqualToString:@"No records found"])
        {
            
            
            UILabel *norecLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 160.0, 24.0)];
            
            norecLabel.font = [UIFont systemFontOfSize:15];
            norecLabel.text = @"No records found";
            norecLabel.textColor = [UIColor whiteColor];
            //        SchTimeLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];
            [norecLabel setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:norecLabel];
            
            [activityIndicator stopAnimating];
            
        }
        else
        {
        if (_tableView) {
            [_tableView reloadData];
        }
        
        else
        {
        
        _tableView = [[UITableView alloc] init];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            _tableView.frame = CGRectMake(5, 6, 190, 124);
            UIView *backView = [[UIView alloc] init];
            [backView setBackgroundColor:[UIColor clearColor]];
            
            [_tableView setBackgroundView:backView];
        }else{
            _tableView.frame = CGRectMake(5, 6, 190, 132);
            _tableView.backgroundColor = [UIColor clearColor];
            
        }
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:self.tableView];
        
        [activityIndicator stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        }
    }
    [_tableView setShowsVerticalScrollIndicator:NO];
    
}


- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    
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







#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // return number of rows
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableRows == 3)
    {
        return [tempArray count];
    }
    else
    {
        return [arrayParsedList count];
    }
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (typeofParsing == 777)
    {
        return 44;
    }
    else if (typeofParsing == 122)
    {
        return 30;
    }
    return 0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    // 1. The view for the header
    UIView* headerView = [[UIView alloc] init];
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithWhite:0.5f alpha:1.0f];
    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    headerView.layer.borderWidth = 0.6;
    
    // 3. Add a label
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(6, 4, tableView.frame.size.width - 5, 20);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor blackColor];
    
    headerLabel.textAlignment = NSTextAlignmentLeft;
    // 4. Add the label to the header view
    [headerView addSubview:headerLabel];
    
    UILabel* totalDaysInWeekLabel = [[UILabel alloc] init];
    totalDaysInWeekLabel.frame = CGRectMake(6, 24, 180, 20);
    totalDaysInWeekLabel.backgroundColor = [UIColor clearColor];
    totalDaysInWeekLabel.textColor = [UIColor blackColor];
    totalDaysInWeekLabel.font = [UIFont boldSystemFontOfSize:12.0];
    totalDaysInWeekLabel.textAlignment = NSTextAlignmentCenter;
    
    // 4. Add the label to the header view
    [headerView addSubview:totalDaysInWeekLabel];
    
    UILabel* totalHrsInWeekLabel = [[UILabel alloc] init];
    totalHrsInWeekLabel.frame = CGRectMake(140, 24, 120, 20);
    totalHrsInWeekLabel.backgroundColor = [UIColor clearColor];
    totalHrsInWeekLabel.textColor = [UIColor blackColor];
    totalHrsInWeekLabel.font = [UIFont boldSystemFontOfSize:12.0];
    totalHrsInWeekLabel.textAlignment = NSTextAlignmentLeft;
    // 4. Add the label to the header view
    [headerView addSubview:totalHrsInWeekLabel];
    
    
    if (typeofParsing == 777)
    {
        headerView.frame =   CGRectMake(10, 12, 200, 42);
        headerLabel.text = @"Mutiple sigin and signout times";
        headerLabel.font = [UIFont boldSystemFontOfSize:12.0];
        
        NSUserDefaults *def1 = [NSUserDefaults standardUserDefaults];
        NSString *weekDay = [def1  objectForKey:@"weekDaySelecCell1Key"];
        
        
//        EmpsShiftDetailsBO *obj = (EmpsShiftDetailsBO *) [arrayParsedList objectAtIndex:section];
//        totalDaysInWeekLabel.text = [NSString stringWithFormat:@"for %@ (%@)",weekDay,obj.strDate];
        totalDaysInWeekLabel.text = [NSString stringWithFormat:@"for %@ ",weekDay];
        
        [def1 removeObjectForKey:@"weekDaySelecCell1Key"];
    }
    else if (typeofParsing == 122)
    {
        headerView.frame =   CGRectMake(20, 12, 210, 42);
        headerLabel.font = [UIFont boldSystemFontOfSize:13.0];
        headerLabel.text = @"   Select Shift";
        
        
    }
    
    
        // 5. Finally return
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (typeofParsing == 777)
    {
    return 36;
    }
    else
    {
    return 40;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return cell
    
    
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *SchTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 160.0, 18.0)];
        SchTimeLabel.tag = 2222;
        SchTimeLabel.font = [UIFont systemFontOfSize:14];
        SchTimeLabel.textColor = [UIColor whiteColor];
        //        SchTimeLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];
        [SchTimeLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:SchTimeLabel];

        
    }
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        
    }
    else
    {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
     EmpsShiftDetailsBO *obj = (EmpsShiftDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    if (typeofParsing == 777)
    {
        NSString *signInTime = obj.strSignInTime;
         NSString *signOutTime = obj.strSignOutTime;
        
        if ([signInTime isEqualToString:@"Emp"]) {
            signInTime = @"N/A";
        }
        else if ([signOutTime isEqualToString:@"Emp"])
        {
            signOutTime = @"N/A";
        }
        
        NSString *mutiSignInSignOutTimes = [NSString stringWithFormat:@"%@ - %@",signInTime,signOutTime];
        
//        UILabel *SchTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 160.0, 18.0)];
//        SchTimeLabel.text = mutiSignInSignOutTimes;
//        SchTimeLabel.font = [UIFont systemFontOfSize:14];
//        SchTimeLabel.textColor = [UIColor whiteColor];
//        //        SchTimeLabel.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0 ];
//        [SchTimeLabel setBackgroundColor:[UIColor clearColor]];
//        [cell.contentView addSubview:SchTimeLabel];
        
        UILabel *SchTimeLabel = (UILabel *)[cell.contentView viewWithTag:2222];
        SchTimeLabel.text = mutiSignInSignOutTimes;
        
        cell.backgroundColor = [UIColor clearColor];
        
        
        
    }
    else
    {
    if (tableRows == 3)
    {
        cell.textLabel.text = [tempArray objectAtIndex:indexPath.row];
         cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    else
    {
      cell.textLabel.text = obj.strShiftname;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];//rgb(85,85,85)
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    //cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = selectedCell.textLabel.text;
    
    if (tableRows == 3)
    {
        [self.delegate didSelectRowReportName:cellText];
    }
    else
    {
        EmpsShiftDetailsBO *obj = (EmpsShiftDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
        
        [self.delegate didSelectRowShiftName:obj.strShiftname ShiftIDEmp:obj.strShiftID ];
    }
    
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
