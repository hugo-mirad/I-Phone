//
//  PackageDetailsViewController.m
//  Car-Finder
//
//  Created by Mac on 22/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PackagesListViewController.h"

#import "PackageDetailsInfoViewController.h"
#import "CommonMethods.h"
#import "CarRecord.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "AFNetworking.h"

#import "CheckButton.h"
#import "UIButton+Glossy.h"

@interface PackagesListViewController()

@property(strong,nonatomic) NSMutableArray *arrayOfPackageNames;

@property(strong,nonatomic) NSOperationQueue *opQueue;

@property(strong,nonatomic) AFHTTPClient * Client;
@property(strong,nonatomic) UIAlertView *addPackAlert;

@property(strong, nonatomic) CheckButton   *addPackageBtn;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation PackagesListViewController

@synthesize arrayOfPackageNames=_arrayOfPackageNames;

@synthesize packagesDetailsArray=_packagesDetailsArray,arrayOfAllCarRecordObjects=_arrayOfAllCarRecordObjects,opQueue=_opQueue,Client=_Client,addPackAlert=_addPackAlert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=@"Packages List"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    UIImage* image3 = [UIImage imageNamed:@"BackAll.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width/2-20, image3.size.height/2-20);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(done:)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *lb= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem =lb;
    lb=nil;
    
    UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] init];
    logoutButton.target = self;
    logoutButton.action = @selector(logoutButtonTapped:);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [logoutButton setTitleTextAttributes:dic forState:UIControlStateNormal];
    [logoutButton setTitle:[NSString stringWithFormat:@"Logout"]];
    logoutButton.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem=logoutButton;
    
    
    //for background image;
    self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    
    self.arrayOfPackageNames=[[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *dict in self.packagesDetailsArray) {
        NSString *packageName=[NSString stringWithFormat:@"%@ (Package ID: %@)",[dict objectForKey:@"_Description"],[dict objectForKey:@"_PackageID"]];
        [self.arrayOfPackageNames addObject:packageName];
        
        
    }
    
    
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
    
    [self.indicator stopAnimating];

    
}
- (void)done:(id)sender
{
  
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.arrayOfPackageNames && self.arrayOfPackageNames.count) {
        return self.arrayOfPackageNames.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text=[self.arrayOfPackageNames objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor lightGrayColor];
    bgColorView.layer.cornerRadius = 7;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, tableView.bounds.size.width, 44.0)]; //height same as in heightForFooterInSection //prev width 150
    
    
    //custom add pref button code
 //   CheckButton   *addPackageBtn;
    _addPackageBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
    _addPackageBtn.tag=21;
    _addPackageBtn.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [_addPackageBtn setTitle:@"ADD PACKAGE" forState:UIControlStateNormal];
    [_addPackageBtn setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
   [_addPackageBtn addTarget:self action:@selector(addPackageBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
    //Button with 0 border so it's shape like image shape
    _addPackageBtn.layer.shadowRadius = 1.0f;
    _addPackageBtn.layer.shadowOpacity = 0.5f;
    _addPackageBtn.layer.shadowOffset = CGSizeZero;
    //Font size of title
    _addPackageBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
  // [_addPackageBtn setBackgroundImage:[UIImage imageNamed:@"AddPackageBtn"] forState:UIControlStateNormal];
   [customView addSubview:_addPackageBtn];
    
    
    //auto layout code
    [_addPackageBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *addPackageBtnConstraint=[NSLayoutConstraint constraintWithItem:_addPackageBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:customView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [customView addConstraint:addPackageBtnConstraint];
    
    addPackageBtnConstraint=[NSLayoutConstraint constraintWithItem:_addPackageBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:customView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [customView addConstraint:addPackageBtnConstraint];
    
    addPackageBtnConstraint=[NSLayoutConstraint constraintWithItem:_addPackageBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:160];
    [customView addConstraint:addPackageBtnConstraint];
    
    addPackageBtnConstraint=[NSLayoutConstraint constraintWithItem:_addPackageBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
    [customView addConstraint:addPackageBtnConstraint];
    
    return customView;
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //set back button item for next view
    UIBarButtonItem *leftBarButton=[[UIBarButtonItem alloc] initWithTitle:@"Packages" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=leftBarButton;
    
    NSDictionary *dict=[self.packagesDetailsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"PackageDetailsInfoViewControllerSegue" sender:dict];
}

#pragma mark - Logout Button
- (void)logoutButtonTapped:(id)sender
{
    UIBarButtonItem *rightBarButton=self.navigationItem.rightBarButtonItem;
    rightBarButton.enabled=NO;
    
    /*
     http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLogoutMobile/{UserID}/{SessionID}/{AuthenticationID}/{CustomerID}/
     */
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    NSString *uid=[defaults valueForKey:UID_KEY];
    
    
    NSString *logoutServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLogoutMobile/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/", uid,sessionID,retrieveduuid] ; //]@"din9030231534",@"dinesh"];
    
    //calling service
    NSURL *URL = [NSURL URLWithString:logoutServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak PackagesListViewController *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[weakSelf hideActivityViewer];
        rightBarButton.enabled=YES;
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        if(error2==nil)
        {
            
            NSString *logoutResult=[wholeResult objectForKey:@"PerformLogoutMobileResult"];
            
            
            //check status
            
            if ([logoutResult isEqualToString:@"Success"])
            {
                //perform segue here
                //go to login screen
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                
                
            }
            else
            {
                [weakSelf packagesListOperationFailedMethod:nil];
                
            }
            
        }
        else
        {
            //handle JSON error here
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
            [weakSelf handleJSONError:error2];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[weakSelf hideActivityViewer];
        rightBarButton.enabled=YES;
        
        //call service failed
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error);
        [weakSelf handleOperationError:error];
    }];
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"PackagesList Queue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    else
    {
        [self.opQueue cancelAllOperations];
    }
    
    [self.opQueue addOperation:operation];
}

- (void)addPackageBtnTapped:(id)sender event:(id)event
{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.indicator startAnimating];
    self.indicator.color = [UIColor redColor];
//#warning call new 'Add Package' service here
    [_addPackageBtn setUserInteractionEnabled:NO];
    
    self.Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
    
    NSDictionary * parameters = nil;
    /*
    http://www.unitedcarexchange.com/MobileService/CarService.asmx/AddPackageRequestMobile?UID="UID"&AuthenticationID="AID"&CustomerID="CID"&SessionID="SessionID"
     */
    
    //
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    NSString *uid=[defaults valueForKey:UID_KEY];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"UID",@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",@"AuthenticationID",retrieveduuid,@"CustomerID",sessionID,@"SessionID",nil];
    
    
    [self.Client setParameterEncoding:AFJSONParameterEncoding];
    [self.Client postPath:@"MobileService/CarService.asmx/AddPackageRequestMobile" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.indicator stopAnimating];
        
     //   [self mailServiceCallSuccessMethod];
        
        if ([operation.responseString isEqualToString:@"Success"])
        
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Our service representative will contact you shortly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;

             [_addPackageBtn setUserInteractionEnabled:YES];
            
            
        }
        else if ([operation.responseString isEqualToString:@"Session timed out"])
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.indicator stopAnimating];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.indicator stopAnimating];
        
             //if status code=0, the operation was cancelled
        [self packagesListOperationFailedMethod:error];
        
    }];

       
}


#pragma mark - Operation Failed Error Handling

- (void)packagesListOperationFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
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
        alert.message=@"MobiCarz could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
}

- (void)handleOperationError:(NSError *)error
{
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in PackagesListViewController" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self packagesListOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in PackagesListViewController" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self packagesListOperationFailedMethod:error2];
    
}


#pragma mark - Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PackageDetailsInfoViewControllerSegue"]) {
        PackageDetailsInfoViewController *packageDetailsInfoViewController=[segue destinationViewController];
        
        NSDictionary *packageDict=(NSDictionary *)sender;
        packageDetailsInfoViewController.packageDetailsDict=packageDict;
        
        //send the car record that match the package id
        NSMutableArray *arrayOfCarRecordsForThisPackage=[[NSMutableArray alloc] initWithCapacity:1];
        
        //NSLog(@"package details dict=%@",(NSDictionary *)sender);
        
        for (CarRecord *cr in self.arrayOfAllCarRecordObjects) {
            if ([[cr packageID] isEqualToString:[packageDict objectForKey:@"_PackageID"]]) {
                
                [arrayOfCarRecordsForThisPackage addObject:cr];
            }
        }
        
        packageDetailsInfoViewController.arrayOfCarRecordsForThisPackage=arrayOfCarRecordsForThisPackage;
        
    }
}

- (void)dealloc {
    _packagesDetailsArray=nil;
    _arrayOfPackageNames=nil;
    
}
@end
