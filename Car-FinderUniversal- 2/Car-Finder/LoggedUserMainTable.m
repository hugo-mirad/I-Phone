//
//  MainTableForLoggedUser.m
//  Car-Finder
//
//  Created by Mac on 22/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "LoggedUserMainTable.h"

#import "CommonMethods.h"

//#import "MyCarsForUploadingPhotos.h"
#import "PackagesListViewController.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "AFNetworking.h"

#import "CarRecord.h"


#import "LoginViewController.h"

#import "AboutUs.h"

@interface LoggedUserMainTable()

@property(strong,nonatomic) NSMutableArray *arrayOfLoggedUserOperations,*allCarRecordsArray;

@property(assign,nonatomic) BOOL forCarDetails;

@property(strong,nonatomic) NSArray *carIdsArray;

@property(strong,nonatomic) NSOperationQueue *opQueue,*opQueueForGettingPackageDetails;

@property(assign,nonatomic) BOOL isShowingLandscapeView;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;


- (void)loadCarIdsFromDict;
- (void)retrieveCars:(NSArray *)carIdsArray;
-(void)retrieveCarWithId:(NSString *)carId;
//- (void)logout;
- (void)retrievePackageDetails:(NSString *)uid;

//- (void)backButtonTapped;
- (void)callLoggedUserOperationFailedMethod:(NSError *)error;
- (void)handleOperationError:(NSError *)error;
- (void)handleJSONError:(NSError *)error;

@end

@implementation LoggedUserMainTable

@synthesize arrayOfLoggedUserOperations=_arrayOfLoggedUserOperations,forCarDetails=_forCarDetails;


@synthesize carIdsArray=_carIdsArray,allCarRecordsArray=_allCarRecordsArray, opQueue=_opQueue,opQueueForGettingPackageDetails=_opQueueForGettingPackageDetails;

@synthesize arrayOfAllCarRecordObjects=_arrayOfAllCarRecordObjects;

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
   
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *dict=[defaults objectForKey:@"RegistrationDictKey"];
    
    
    //NSDictionary *dict=[self.loginResultArray objectAtIndex:0];
    NSString *title=[dict objectForKey:@"Name"];
  
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
       [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        navtitle.textColor=[UIColor  whiteColor];
        
        
    } else {
        navtitle.textColor=[UIColor  colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];

        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        //load resources for iOS 7
        
    }
    navtitle.text=title; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    
    //for background image;
    self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    [self.tableView setSeparatorColor:[UIColor blackColor]];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
   // self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    
    self.arrayOfLoggedUserOperations=[[NSMutableArray alloc] initWithObjects:@"Registration Information",@"Packages", @"Customer Support", nil];
    
    UIBarButtonItem *doneBarButton=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem=doneBarButton;
    
    UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logoutButtonTapped:)];
    self.navigationItem.rightBarButtonItem=logoutButton;
    
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
    [self.indicator stopAnimating];
    //self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //if (!self.allCarRecordsArray) {
    self.allCarRecordsArray=[[NSMutableArray alloc] initWithCapacity:1];
    //}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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
    if (self.arrayOfLoggedUserOperations && self.arrayOfLoggedUserOperations.count) {
        return self.arrayOfLoggedUserOperations.count;
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
    cell.textLabel.text=[self.arrayOfLoggedUserOperations objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    //remove user interaction as user may double tap causing multiple pushes of navigation controller
    [self.tableView setUserInteractionEnabled:NO];
    
    NSInteger rowSelected=indexPath.row;
    
    if (rowSelected==0) {
        [self performSegueWithIdentifier:@"RegistrationInfoViewControllerSegue" sender:nil];
    }
    else if (rowSelected==1) {
        //[self performSegueWithIdentifier:@"PackagesListViewControllerSegue" sender:self.loginResultArray];
        [self.indicator startAnimating];
        
        
        //get UId from NSUserDefaults
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSString *uid=[defaults valueForKey:UID_KEY];
        [self retrievePackageDetails:uid];
    }
    else if (rowSelected==2) {
        [self performSegueWithIdentifier:@"CustomerSupportSegue" sender:nil];
        
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return 52.0f;
}


#pragma mark - Prepare For Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //enable userinteraction on table view that was disabled in tableView:didSelectRow:atIndexPath:
    [self.tableView setUserInteractionEnabled:YES];
    
    if ([segue.identifier isEqualToString:@"PackagesListViewControllerSegue"]) {
        PackagesListViewController *packagesListViewController=[segue destinationViewController];
        packagesListViewController.packagesDetailsArray=(NSArray *)sender;
        packagesListViewController.arrayOfAllCarRecordObjects=self.arrayOfAllCarRecordObjects;
    }
}



-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
    
    [self.indicator stopAnimating];
}

- (void)loadCarIdsFromDict
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *registrationDict=[defaults valueForKey:@"RegistrationDictKey"];
    
    NSString *carIdsStr=[registrationDict objectForKey:@"CarIDs"];
    
    self.carIdsArray=[carIdsStr componentsSeparatedByString:@","];
    
    
}

- (void)retrieveCars:(NSArray *)carIdsArray
{
    //call web service with each object in above array and store the results in array containing dicts (cars)
    for (NSString *carid in carIdsArray) {
        [self retrieveCarWithId:carid];
    }
    
}

-(void)retrieveCarWithId:(NSString *)carId
{
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
   
    
    NSString *urlString=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/FindCarID/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",carId,retrieveduuid];
    
    
    NSURL *regInfoUrl = [NSURL URLWithString:urlString];
    
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *regInfoUrlReq = [NSURLRequest requestWithURL:regInfoUrl cachePolicy:policy timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:regInfoUrlReq];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])
             
         {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
         }
         
     }];
    
    __weak LoggedUserMainTable *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         
         
         
         //call service executed succesfully
         NSError *error2=nil;
         NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
         if(error2==nil)
         {
             
             NSArray *carIDResultArray = [wholeResult objectForKey:@"FindCarIDResult"];
             
             NSDictionary *someCar = [carIDResultArray objectAtIndex:0];
             
             //add this car to allCarRecordsArray
             
             [weakSelf.allCarRecordsArray addObject:[[CarRecord alloc] initWithDictionary:someCar]];
             NSString *lastCarId=[weakSelf.carIdsArray objectAtIndex:[weakSelf.carIdsArray count]-1];
             if ([carId isEqualToString:lastCarId]) {
                 [weakSelf hideActivityViewer];
                 
                 //do this if there are car id's
                 if (weakSelf.allCarRecordsArray && weakSelf.allCarRecordsArray.count) {
                    [weakSelf performSegueWithIdentifier:@"MyCarsForUploadingPhotosSegue" sender:nil];
                 }
                 else
                 {
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Cars Yet" message:@"You have not added any cars." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
                     alert=nil;
                     
                     
                 }
             }
             
         }
         else
         {
             
             NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
             [weakSelf handleJSONError:error2];
         }
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                         NSString *lastCarId=[weakSelf.carIdsArray objectAtIndex:[weakSelf.carIdsArray count]-1];
                                         if ([carId isEqualToString:lastCarId]) {
                                             [weakSelf hideActivityViewer];
                                         }
                                         
                                         
                                         NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
                                         [weakSelf handleOperationError:error];
                                     }];
    
    if (!self.opQueue) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"LoggedUserMainTableQueueForGettingCars"];
        [self.opQueue setMaxConcurrentOperationCount:1];
        
    }
    [self.opQueue addOperation:operation];
    //operation=nil;
    
    
    
}

#pragma mark - Operation Failed Error Handling

- (void)callLoggedUserOperationFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
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
        alert.message=@"UCE Car Finder could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
}

- (void)handleOperationError:(NSError *)error
{
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callLoggedUserOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callLoggedUserOperationFailedMethod:error2];
    
}


- (void)retrievePackageDetails:(NSString *)uid
{
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    //http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetPackageDetailsByUID/120/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/12345/
    
    NSString *packageDetailsServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetPackageDetailsByUID/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@", uid,retrieveduuid,sessionID] ; //]@"din9030231534",@"dinesh"];
    
    //calling service
    NSURL *URL = [NSURL URLWithString:packageDetailsServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak LoggedUserMainTable *weakSelf=self;
    __block BOOL noPackages=NO;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        if(error2==nil)
        {
            
            //weakSelf.featuresArray=[wholeResult objectForKey:@"GetCarFeaturesResult"];
            NSArray *packagesResultArray=[wholeResult objectForKey:@"GetPackageDetailsByUIDResult"];
            
            
            //check status
            if ([packagesResultArray count]==0) {
                noPackages=YES;
            }
            else
            {
                //check for valid session
                NSDictionary *packageDict=[packagesResultArray objectAtIndex:0];
                if ([[packageDict objectForKey:@"_AASuccess"] isEqualToString:@"Success"])
                {
                    
                    
                    //perform segue here
                    [weakSelf performSegueWithIdentifier:@"PackagesListViewControllerSegue" sender:packagesResultArray];
                }
                else if ([[packageDict objectForKey:@"_AASuccess"] isEqualToString:@"Session timed out"])
                {
                    //go to login screen
                   UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    alert=nil;
                    
                    
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    
                }
                else
                {
                    [weakSelf handleOperationError:nil];
                }
                
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
        [weakSelf hideActivityViewer];
               noPackages=NO;
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error);
        [weakSelf handleOperationError:error];
    }];
    
    if (self.opQueueForGettingPackageDetails==nil) {
        self.opQueueForGettingPackageDetails=[[NSOperationQueue alloc] init];
        [self.opQueueForGettingPackageDetails setName:@"opQueueForGettingPackageDetails in LoggedUserMainTable"];
        [self.opQueueForGettingPackageDetails setMaxConcurrentOperationCount:1];
    }
    else
    {
        [self.opQueueForGettingPackageDetails cancelAllOperations];
    }
    
    [self.opQueueForGettingPackageDetails addOperation:operation];
}

#pragma mark - Done Button

- (void)done:(id)sender
{
    if (self.opQueue.operationCount>0) {
        [self.opQueue cancelAllOperations];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
    
    __weak LoggedUserMainTable *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        rightBarButton.enabled=YES;
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        //NSLog(@"wholeResult=%@",wholeResult);
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
                [weakSelf callLoggedUserOperationFailedMethod:nil];
                
            }
            
        }
        else
        {
            //handle JSON error here
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
            //[weakSelf handleJSONError:error2];
            rightBarButton.enabled=YES;
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        
        //call service failed
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error);
        [weakSelf handleOperationError:error];
    }];
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"Logout Queue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    else
    {
        [self.opQueue cancelAllOperations];
    }
    
    [self.opQueue addOperation:operation];
}

#pragma mark - Orientation Notif
- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !self.isShowingLandscapeView)
    {
        self.isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && self.isShowingLandscapeView)
    {
        self.isShowingLandscapeView = NO;
    }
}

-(void)dealloc
{
    _carIdsArray=nil;
    _arrayOfLoggedUserOperations=nil;
    _allCarRecordsArray=nil;
    _opQueue=nil;
    _opQueueForGettingPackageDetails=nil;
 
}
@end
