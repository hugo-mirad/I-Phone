//
//  EmergencyContactDetViewController.m
//  HRTest
//
//  Created by Venkata Chinni on 8/25/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "EmergencyContactDetViewController.h"
#import "NoteViewController.h"
#import "FPPopoverController.h"
#import "MBProgressHUD.h"
//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics



@interface EmergencyContactDetViewController ()

{
    int typeofParsing;
}

@property(copy,nonatomic) NSString *currentelementValueStr;


@end

@implementation EmergencyContactDetViewController

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
    
    typeofParsing = 1;
    _CmpEmpDetailsDic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *cmpEmpDetailDefaults = [NSUserDefaults standardUserDefaults];
    _CmpEmpDetailsDic = [cmpEmpDetailDefaults objectForKey:@"comEmpDetailsDictionaryKey"];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;

    
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
    cmpNameLabel.text = @"Emergency contact details";
    cmpNameLabel.numberOfLines = 1;
    cmpNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    cmpNameLabel.adjustsFontSizeToFitWidth = YES;
    cmpNameLabel.minimumScaleFactor = 10.0f/12.0f;
    cmpNameLabel.clipsToBounds = YES;
    cmpNameLabel.backgroundColor = [UIColor clearColor];
    cmpNameLabel.textColor = [UIColor whiteColor];
    cmpNameLabel.textAlignment = NSTextAlignmentCenter;
   [topNaviView addSubview:cmpNameLabel];
    
    
    
    
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
    }    [topNaviView addSubview:backButton];
    
//    UITableView *contactTableView = [[UITableView alloc ] initWithFrame:CGRectMake(0, topNaviView.frame.origin.y+topNaviView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-topNaviView.frame.origin.y+topNaviView.frame.size.height)];
//    contactTableView.backgroundColor = [UIColor clearColor];
   
    
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
    
    if (typeofParsing == 1)
    {
        [self EmergencyContactDetailsImplementation];
    }
    
    
}



-(void)EmergencyContactDetailsImplementation
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
    "<GetEmpEmergencyContactDetails xmlns=\"http://tempuri.org/\">"
    "<CompanyCode>%@</CompanyCode>"
    "<EmpCompanyID>%@</EmpCompanyID>"
    "<longitude>%@</longitude>"
    "<latitude>%@</latitude>"
    "<mobileName>%@</mobileName>"
    "<deviceCode>%@</deviceCode>"
    "<authenticationID>%@</authenticationID>"
    "</GetEmpEmergencyContactDetails>"
    "</soap:Body>"
    "</soap:Envelope>",cmpCode,empCmpyID,logitudeCmp,latitudeCmp,mobileName,deviceID,authID];
    
    NSURL *url = [NSURL URLWithString:@"http://test4.unitedcarexchange.com/Attendanceservice/service.asmx"];//Use this or below
    
    
    // NSURL *url = [NSURL URLWithString:@"http://test7.hugomirad.com/Attendanceservice/service.asmx"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://tempuri.org/GetEmpEmergencyContactDetails" forHTTPHeaderField:@"SOAPAction"];
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
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
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
        
//        [MBProgressHUD  hideHUDForView:self.view animated:YES];
//        self.view.userInteractionEnabled = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
//        NSString *strXMl = [[NSString alloc]initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
//        NSLog(@"XML is : %@", strXMl);

    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    xmlParser.delegate = self;
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"GetEmpEmergencyContactDetailsResult"])
    {
        if (arrayParsedList)
        {
            arrayParsedList = nil;
        }
        arrayParsedList = [[NSMutableArray alloc]init];
    }
    
    else if ([elementName isEqualToString:@"EmergencyContactInfo"])
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
    
    if ([elementName isEqualToString:@"EmergencyContactInfo"])
    {
        [arrayParsedList addObject:objEmp];
    }
    
    else if ([elementName isEqualToString:@"AAsuccess"])
    {
        objEmp.strAAsuccess = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ContactFName"])
    {
        objEmp.strContactFName = currentElementValue;
    }
    else if ([elementName isEqualToString:@"ContactLName"])
    {
        objEmp.strContactLName = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Relation"])
    {
        objEmp.strRelation = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Phone"])
    {
        objEmp.strPhone = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Address"])
    {
        objEmp.strAddress = currentElementValue;
    }
    else if ([elementName isEqualToString:@"City"])
    {
        objEmp.strCity = currentElementValue;
    }
    else if ([elementName isEqualToString:@"StateCode"])
    {
        objEmp.strStateCode = currentElementValue;
    }
    else if ([elementName isEqualToString:@"StateID"])
    {
        objEmp.strStateID = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Zip"])
    {
        objEmp.strZip = currentElementValue;
    }
    else if ([elementName isEqualToString:@"Email"])
    {
        objEmp.strEmail = currentElementValue;
    }
    else if ([elementName isEqualToString:@"EmergContactID"])
    {
        objEmp.strEmergContactID = currentElementValue;
    }
    


}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *successStr = objEmp.strAAsuccess;
    
    if ([successStr isEqualToString:@"Success"])
    {
        
        contactTableView = [[UITableView alloc] init];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
            contactTableView.frame = CGRectMake(12, 60, self.view.frame.size.width-24, self.view.frame.size.height-348);
            UIView *backView = [[UIView alloc] init];
            [backView setBackgroundColor:[UIColor clearColor]];
            
            [contactTableView setBackgroundView:backView];
            }else{
            contactTableView.frame = CGRectMake(12, 80, self.view.frame.size.width-24, self.view.frame.size.height-348);
            contactTableView.backgroundColor = [UIColor clearColor];
            
            }
        }
        else
        {
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
            {
                contactTableView.frame = CGRectMake(24, 100, self.view.frame.size.width-48, self.view.frame.size.height-891);
                UIView *backView = [[UIView alloc] init];
                [backView setBackgroundColor:[UIColor clearColor]];
                
                [contactTableView setBackgroundView:backView];
            }else{
                contactTableView.frame = CGRectMake(24, 100, self.view.frame.size.width-48, self.view.frame.size.height-891);
                contactTableView.backgroundColor = [UIColor clearColor];
                
            }

        }
        contactTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        contactTableView.dataSource = self;
        contactTableView.delegate = self;
        [self.view addSubview:contactTableView];
        
        contactTableView.layer.cornerRadius = 3.0;
    }
    else if ([successStr isEqualToString:@"No records found"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:successStr delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    [MBProgressHUD  hideHUDForView:self.view animated:YES];
    self.view.userInteractionEnabled = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayParsedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
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
    
    
    
    cell.textLabel.text = obj.strContactFName;
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = selectedCell.textLabel.text;
    EmpScheduledDetailsBO *obj = (EmpScheduledDetailsBO *) [arrayParsedList objectAtIndex:indexPath.row];
    
//    NSString *boldFontName = [[UIFont boldSystemFontOfSize:12] fontName];
//    NSString *yourString = [NSString stringWithFormat:@"Relation : %@",obj.strRelation];
//    NSRange boldedRange = NSMakeRange(0, 10);
//    
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:yourString];
//    
//    [attrString beginEditing];
//    //[attrString addAttribute:kCTFontAttributeName value:boldFontName range:boldedRange];
//    
//    [attrString endEditing];
    
    
    
    NSString *relationStr = obj.strRelation;
    NSString *phoneStr = obj.strPhone;
    NSString *emailStr = obj.strEmail;
    
    NSString *addrStr = obj.strAddress;
    NSString *cityStr = obj.strCity;
    NSString *stateStr = obj.strStateCode;
    NSString *zipStr = obj.strZip;
    
    NSString *finalAddress;
    
    if ([addrStr isEqualToString:@"Emp"] && [cityStr isEqualToString:@"Emp"] && ([stateStr isEqualToString:@"Emp"] || [stateStr isEqualToString:@"UN"]) && [zipStr isEqualToString:@"Emp"])
    {
        finalAddress = @"";
    }
    else
    {
        finalAddress = [NSString stringWithFormat:@"%@, %@, %@, %@",addrStr,cityStr,stateStr,zipStr];
    }
    
    
    
    if ( [relationStr isEqualToString:@"Emp"])
    {
        relationStr = @"";
    }
    if ( [phoneStr isEqualToString:@"Emp"])
    {
        phoneStr = @"";
    }
    if ( [emailStr isEqualToString:@"Emp"])
    {
        emailStr = @"";
    }

//     UIAlertView *alert = [[UIAlertView alloc]init];
//    [alert addButtonWithTitle:@"OK"];
//    
//    alert.Title = cellText;
//    alert.message =  [NSString stringWithFormat: @"Relation : %@ \n phone# %@ \n Email: %@ \n  Address: %@ ",relationStr,phoneStr,emailStr,finalAddress];
//    
//    
//    [alert show];
    
    
    int typeOfEmpDetails = 890;
    
    NSUserDefaults *defalts = [NSUserDefaults standardUserDefaults];
    [defalts setInteger:typeOfEmpDetails forKey:@"typeOfEmpDetailsKey"];
    [defalts synchronize];
    
     NoteViewController *objNote = [self.storyboard instantiateViewControllerWithIdentifier:@"NoteView"];
    
    objNote.strSelName = cellText;
    objNote.strSelNameRela = relationStr;
    objNote.strSelNameRelaPhoneNum = phoneStr;
    objNote.strSelNameEmailID = emailStr;
    objNote.strSelNameRelaAddr = finalAddress;
    
    FPPopoverController *pop = [[FPPopoverController alloc]initWithViewController:objNote];
    pop.contentSize = CGSizeMake(320,210);
    [pop presentPopoverFromView:selectedCell];
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
