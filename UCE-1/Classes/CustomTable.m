//
//  CarsTable.m
//  XmlTable
//
//  Created by Mac on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomTable.h"

#import "CustomCell.h"
#import "CustomCellInfo.h"
#import "DetailView.h"
#import "AppDelegate.h"
#import "CarRecord.h"
#import "CheckZipCode.h"
#import "QuartzCore/QuartzCore.h"
#import "CFNetwork/CFNetwork.h"
#import "AFNetworking.h"

#import "CommonMethods.h"


@interface CustomTable()

@property(strong,nonatomic) NSMutableArray *arrayOfAllCustomCellInfoObjects;
@property(assign,nonatomic) NSInteger currentPage;
@property(assign,nonatomic) NSInteger lowestPageNumInMemory;
@property(assign,nonatomic) BOOL loadingAtTop,loadingAtBottom,initialLoad;


@property(nonatomic,strong)UITapGestureRecognizer *gestureRecognizer1,*gestureRecognizer2,*gestureRecognizer3,*spinner1GestureRecognizer,*spinner2GestureRecognizer,*spinner3GestureRecognizer;

@property(assign,nonatomic) NSInteger lastPageCellsCount,loadRowsAtEndCounterMain,loadRowsAtTopCounterMain,totalPages,userScrolledToBottom,userScrolledToTop;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *footerLabel;
@property(strong,nonatomic) UILabel *headerLabel;
@property(strong,nonatomic) UIAlertView *noResultsAlert,*updateZipAlert,*invalidZipAlert,*didSendZipAlert;

@property(strong,nonatomic) FindCurrentZip *findZip;
@property(copy,nonatomic) NSString *usersZipCodeFromWiFi,*zipStr;

@property(assign,nonatomic) BOOL tableviewStopped;

@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;

@property(strong,nonatomic) UIImageView *activityImageView;

@property(strong,nonatomic) NSOperationQueue *CustomTableNSOperationQueue,*homeScreenThumbnailQueue;

@property(strong,nonatomic) UIBarButtonItem *rightBarbutton;

@property(strong,nonatomic) CarRecord *carRecordToSendToDetailView;

@property(strong,nonatomic) NSInvocationOperation *op1,*op2;


@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(strong,nonatomic) NSNumberFormatter *priceFormatter;

@property(assign,nonatomic) BOOL operationStarted;

- (void)setupTableViewHeader;
- (void)setupTableViewFooter;
- (void)updateTableViewFooter;
- (void)updateTableViewHeader;

- (void)snapBottomCell;

- (void)cancelAllOperations;
- (void)loadImagesForOnscreenCells;

- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;
- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

-(void)deletePreviousResults;
-(void)showZipInUpdateZipLabel:(NSString *)zipValue;
-(void)loadFirstPageResults;
-(void)validateZip:(NSString *)zipToValidate;
-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num;
-(NSString *)combinedStr:(NSString *)make model:(NSString *)model;
-(void)imageViewClicked:(UITapGestureRecognizer*)gestRecognizer;

@end


@implementation CustomTable
@synthesize arrayOfAllCustomCellInfoObjects=_arrayOfAllCustomCellInfoObjects, currentPage=_currentPage, lowestPageNumInMemory=_lowestPageNumInMemory,loadingAtTop=_loadingAtTop,loadingAtBottom=_loadingAtBottom, gestureRecognizer1=_gestureRecognizer1,gestureRecognizer2=_gestureRecognizer2,gestureRecognizer3=_gestureRecognizer3, lastPageCellsCount=_lastPageCellsCount, activityIndicator=_activityIndicator, footerLabel=_footerLabel,noResultsAlert=_noResultsAlert,headerLabel=_headerLabel,usersZipCodeFromWiFi=_usersZipCodeFromWiFi,tableviewStopped=_tableviewStopped,downloadsInProgress=_downloadsInProgress;

@synthesize loadRowsAtEndCounterMain=_loadRowsAtEndCounterMain,loadRowsAtTopCounterMain=_loadRowsAtTopCounterMain,activityImageView=_activityImageView,totalPages=_totalPages,CustomTableNSOperationQueue=_CustomTableNSOperationQueue,userScrolledToBottom=_userScrolledToBottom,userScrolledToTop=_userScrolledToTop,updateZipAlert=_updateZipAlert,findZip=_findZip,rightBarbutton=_rightBarbutton;

@synthesize initialLoad=_initialLoad,carRecordToSendToDetailView=_carRecordToSendToDetailView,op1=_op1,op2=_op2,zipStr=_zipStr,spinner1GestureRecognizer=_spinner1GestureRecognizer,spinner2GestureRecognizer=_spinner2GestureRecognizer,spinner3GestureRecognizer=_spinner3GestureRecognizer,homeScreenThumbnailQueue=_homeScreenThumbnailQueue,invalidZipAlert=_invalidZipAlert,didSendZipAlert=_didSendZipAlert;

@synthesize showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel;
@synthesize priceFormatter=_priceFormatter;

@synthesize operationStarted=_operationStarted;

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


-(void)showActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    
    
    
    self.showActivityViewerImage=[UIImage imageWithData:imageData];
    
    
    self.activityImageView = [[UIImageView alloc] initWithImage:self.showActivityViewerImage];
    
    
    self.activityImageView.alpha = 1.0f;
    
    self.activityWheel=[[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(self.view.frame.size.width / 2 - 12, self.view.frame.size.height / 2 - 12, 24, 24)];
    
    
    self.activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleBottomMargin);
    
    [self.activityImageView addSubview:self.activityWheel];
    [self.view addSubview: self.activityImageView];
    
    [self.activityWheel startAnimating];
    
    
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self.activityWheel stopAnimating];
    
    [self.activityWheel removeFromSuperview];
    
    [self.activityImageView removeFromSuperview];
    //self.activityImageView.image = [[UIImage alloc] initWithCIImage:nil];
    
    //NSLog(@"home screen: self.activityImageView after nilling is %@",self.activityImageView);
}


-(void)loadNextOrPreviousPage
{
    //    NSLog(@"before reload data");
    //    [super reloadData];
    //[super.tableView endUpdates];
    //    NSLog(@"after reload data");
    
    
    if(self.currentPage==1 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        self.currentPage=self.currentPage+1;
        //loading page2
        
        
        HomeScreenOperation *hso2=[[HomeScreenOperation alloc]init];
        hso2.pageNoReceived=self.currentPage;
        hso2.pageSizeReceived=9;
        hso2.usersZipReceived=self.zipStr;
        //hso2.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso2];
        self.operationStarted=YES;
        //NSLog(@"after loading 2nd page, current page no is %d",self.currentPage);
        
    }
    else if(self.currentPage==2 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
        self.currentPage=self.currentPage+1;
        //loading page3
        
        
        HomeScreenOperation *hso3=[[HomeScreenOperation alloc]init];
        hso3.pageNoReceived=self.currentPage;
        hso3.pageSizeReceived=9;
        hso3.usersZipReceived=self.zipStr;
        //hso3.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso3];
        self.operationStarted=YES;
        //NSLog(@"after loading 3rd page, current page no is %d",self.currentPage);
    }
    else if(self.currentPage==3 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
        self.currentPage=self.currentPage+1;
        //loading page4
        
        
        HomeScreenOperation *hso4=[[HomeScreenOperation alloc]init];
        hso4.pageNoReceived=self.currentPage;
        hso4.pageSizeReceived=9;
        hso4.usersZipReceived=self.zipStr;
        //hso4.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso4];
        self.operationStarted=YES;
        //NSLog(@"after loading 4th page, current page no is %d",self.currentPage);
    }
    else if(self.currentPage==4 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        
        HomeScreenOperation *hso5=[[HomeScreenOperation alloc]init];
        hso5.pageNoReceived=self.currentPage;
        hso5.pageSizeReceived=9;
        hso5.usersZipReceived=self.zipStr;
        //hso5.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso5];
        self.operationStarted=YES;
        //NSLog(@"after loading 5th page, current page no is %d",self.currentPage);
        
    }
    
    else if(self.userScrolledToBottom==1 && self.currentPage+1<=self.totalPages && self.loadRowsAtEndCounterMain==2 && !self.operationStarted)
    {
        /*
         if ([self.tableView isEditing]) {
         NSLog(@"loadnextorpreviouspage: tableview is in editing mode");
         }
         else
         {
         NSLog(@"loadnextorpreviouspage: tableview is not in editing mode");
         }
         */
        self.userScrolledToBottom++;
        
        //loading another page
        self.currentPage=self.currentPage+1;
        
        
        HomeScreenOperation *hso2=[[HomeScreenOperation alloc]init];
        hso2.pageNoReceived=self.currentPage;
        hso2.pageSizeReceived=9;
        hso2.usersZipReceived=self.zipStr;
        //hso2.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso2];
        self.operationStarted=YES;
        //NSLog(@"after loading %dth page, current page no is %d lowestPageNumInMemory=%d",self.currentPage,self.currentPage,self.lowestPageNumInMemory);
    }
    
    else if(self.userScrolledToTop==1 && self.lowestPageNumInMemory>1 && self.loadRowsAtTopCounterMain==2 && !self.operationStarted)
    {
        
        self.userScrolledToTop++;
        
        //load another page
        self.lowestPageNumInMemory=self.lowestPageNumInMemory-1;
        
        
        HomeScreenOperation *hso2=[[HomeScreenOperation alloc]init];
        hso2.pageNoReceived=self.lowestPageNumInMemory;
        hso2.pageSizeReceived=9;
        hso2.usersZipReceived=self.zipStr;
        //hso2.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso2];
        self.operationStarted=YES;
        //NSLog(@"after loading %dth page, lowestPageNumInMemory is %d",self.lowestPageNumInMemory,self.lowestPageNumInMemory);
        //NSLog(@"after loading %dth page, current page no is %d lowestPageNumInMemory=%d",self.lowestPageNumInMemory,self.currentPage,self.lowestPageNumInMemory);
        
    }
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
}


-(void)loadRowsAtTop:(NSNumber *)receivedLowestPageNumInMemory //this parameter is not required as we are maintaining a ivar for lowestPageNumInMemory and updating it in this method
{
    if (!self.operationStarted) {
        self.loadRowsAtTopCounterMain++;
        self.loadingAtTop=YES;
        self.loadingAtBottom=NO;
        
        //NSLog(@"page number to load when adding previous pages is %d",self.lowestPageNumInMemory-1);
        self.lowestPageNumInMemory=self.lowestPageNumInMemory-1;
        
        
        HomeScreenOperation *hso1=[[HomeScreenOperation alloc]init];
        hso1.pageNoReceived=self.lowestPageNumInMemory;
        hso1.pageSizeReceived=9;
        hso1.usersZipReceived=self.zipStr;
        //hso1.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso1];
        self.operationStarted=YES;
    }
    
    
}

-(void)loadRowsAtEnd:(NSNumber *)receivedCurrentPage
{
    if (!self.operationStarted) {
        
        self.loadRowsAtEndCounterMain++;
        self.loadingAtBottom=YES;
        self.loadingAtTop=NO;
        
        self.currentPage=[receivedCurrentPage integerValue]+1;
        
        
        HomeScreenOperation *hso1=[[HomeScreenOperation alloc]init];
        hso1.pageNoReceived=self.currentPage;
        hso1.pageSizeReceived=9;
        hso1.usersZipReceived=self.zipStr;
        //hso1.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso1];
        self.operationStarted=YES;
    }
}


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
    
    [self cancelAllOperations];
    
    for (CustomCellInfo *cci in self.arrayOfAllCustomCellInfoObjects) {
        if (cci.car1!=nil) {
            if(cci.car1.hasImage)
            {
                cci.car1.thumbnailUIImage=nil;
            }
        }
        if (cci.car2!=nil) {
            if(cci.car2.hasImage)
            {
                cci.car2.thumbnailUIImage=nil;
            }
        }
        if (cci.car3!=nil) {
            if(cci.car3.hasImage)
            {
                cci.car3.thumbnailUIImage=nil;
            }
        }
    }
    
}

-(void)updateZip
{
    self.updateZipAlert=[[UIAlertView alloc]initWithTitle:@"Enter Zip Code" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [self.updateZipAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[self.updateZipAlert textFieldAtIndex:0] setDelegate:self];
    
    //take zip if present in right bar button and show inside text field so easy editing
    
    NSString *onlyZip=[CommonMethods findZipFromBarButtonTitle:self.rightBarbutton.title];
    [self.updateZipAlert textFieldAtIndex:0].text=onlyZip;
    [[self.updateZipAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [self.updateZipAlert show];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.arrayOfAllCustomCellInfoObjects=[NSMutableArray array];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    //    NSLog(@"height of nav bar is %.1f",self.navigationController.navigationBar.frame.size.height);
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //for background image;
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 122)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    self.tableView.backgroundView = av;
    
    //
    
    self.CustomTableNSOperationQueue=[[NSOperationQueue alloc]init];
    [self.CustomTableNSOperationQueue setName:@"CustomTableQueue"];
    [self.CustomTableNSOperationQueue setMaxConcurrentOperationCount:1];
    
    
    NSOperationQueue *tempHomeScreenThumbnailQueue=[[NSOperationQueue alloc]init];
    self.homeScreenThumbnailQueue=tempHomeScreenThumbnailQueue;
    [self.homeScreenThumbnailQueue setName:@"ThumbnailQueue"];
    [self.homeScreenThumbnailQueue setMaxConcurrentOperationCount:3];
    tempHomeScreenThumbnailQueue=nil;
    
    
    self.downloadsInProgress=[[NSMutableDictionary alloc]initWithCapacity:1];
    
    
    
    UIImageView *navimage2=[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"logo2" ofType:@"png"]]];
    navimage2.frame=CGRectMake(0, 0, 94, 25);
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:navimage2];
    [self.navigationItem setLeftBarButtonItem: customItem];
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
    navtitle.text=@"UCE Car Finder";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationController.navigationBar.topItem setTitleView:navtitle]; 
    navtitle=nil;
    //
    
    
    self.loadingAtBottom=YES;
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
    
    [self setupTableViewFooter];
    
    //check if zip is already present in userdefaults. If not present, then get it from GPS
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.zipStr=[defaults valueForKey:@"homeZipValue"];
    if (self.zipStr==nil) {
        
        //call findcurrentzip class to get zip
        FindCurrentZip *tempFindZip=[[FindCurrentZip alloc]init];
        self.findZip=tempFindZip;
        self.findZip.delegate=self;
        [self.findZip FindingZipCode];
        tempFindZip=nil;
    }
    else
    {
        [self loadFirstPageResults];
    }
    
    NSString *zipStrToDisply=nil;
    NSString *zipStrToDisplyAccessibilityLabel=nil;
    
    if(self.zipStr!=nil)
    {
        zipStrToDisply=[NSString stringWithFormat:@"Zip:%@",self.zipStr];
        zipStrToDisplyAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        
    }
    else
    {
        zipStrToDisply=@"Zip:";
        zipStrToDisplyAccessibilityLabel=@"Zip";
        
    }
    UIBarButtonItem *tempRightBarbutton=[[UIBarButtonItem alloc]initWithTitle:zipStrToDisply style:UIBarButtonItemStyleBordered target:self action:@selector(updateZip)];
    self.rightBarbutton=tempRightBarbutton;
    tempRightBarbutton=nil;
    //accessibility
    self.rightBarbutton.isAccessibilityElement=YES;
    self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
    
    self.navigationItem.rightBarButtonItem=self.rightBarbutton;
    
    self.operationStarted=NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //    NSLog(@"height of tab bar is %.2g",self.tabBarController.tabBar.frame.size.height);
    //    NSLog(@"height of navigation bar is %.2g",self.navigationController.navigationBar.frame.size.height);
    //    NSLog(@"height of tableview controller is %.2g",self.tableView.frame.size.height);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any stronged subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self cancelAllOperations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noResultsForThisZipNotifMethod:) name:@"NoResultsForThisZipNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(errorFindingLocationNotifMethod:) name:@"ErrorFindingLocationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(workingArrayFromHomeScreenOperationNotifMethod:) name:@"WorkingArrayFromHomeScreenOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(homeScreenOperationFailedNotifMethod:) name:@"HomeScreenOperationFailedNotif" object:nil];
    
    if(self.currentPage==0)
    {
        [self setupTableViewFooter];
        
        //call findcurrentzip class to get zip
        FindCurrentZip *tempFindZip=[[FindCurrentZip alloc]init];
        self.findZip=tempFindZip;
        self.findZip.delegate=self;
        [self.findZip FindingZipCode];
        tempFindZip=nil;
    }
    else
    {
        [self loadImagesForOnscreenCells];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!self.initialLoad)
    {
        self.initialLoad=YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NoResultsForThisZipNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ErrorFindingLocationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"WorkingArrayFromHomeScreenOperationNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"HomeScreenOperationFailedNotif" object:nil];
    
    //if user prematurely moves to another tab, remove tableviewfooter and hide activityviewer
    
    self.findZip.delegate=nil;
    [self hideActivityViewer];
    [self updateTableViewFooter];
    if(self.currentPage==1)
    {
        //if there are no cars displayed, then set currentzip = 0. otherwise, let the current page be 1
        if(!IsEmpty(self.arrayOfAllCustomCellInfoObjects))
        {
            CustomCellInfo *cci=[self.arrayOfAllCustomCellInfoObjects objectAtIndex:0];
            CarRecord *carRecord=[cci car1];
            
            NSLog(@"count of arrayOfAllCustomCellInfoObjects in !IsEmpty=%d self.currentPage=%d",[self.arrayOfAllCustomCellInfoObjects count],self.currentPage);
            
            if(carRecord==nil)
            {
                self.currentPage=0;
            }
        }
        
    }
    
    [self cancelAllOperations];
    
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
    if(self.arrayOfAllCustomCellInfoObjects && self.arrayOfAllCustomCellInfoObjects.count)
    {
        return [self.arrayOfAllCustomCellInfoObjects count];
    }
    else
    {
        return 0;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath              
{
    
    static NSString *CellIdentifier = @"carsTableCell";
    
    
    CustomCell *cell = (CustomCell *)[tableView
                                      dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = (CustomCell *)[[CustomCell alloc]
                              initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:CellIdentifier];
        
        
    }
    
    if ([self.arrayOfAllCustomCellInfoObjects count]>0) {
        
        
        // Configure the cell...
        
        //get CustomCellInfo object and use it to design the custom cell
        
        CustomCellInfo *cci=[self.arrayOfAllCustomCellInfoObjects objectAtIndex:indexPath.row];
        if(cci==nil)
            return nil;
        
        //code For Placing Dollar Symbol and Comma
        NSNumberFormatter *tempPriceFormatter=[[NSNumberFormatter alloc]init];
        self.priceFormatter=tempPriceFormatter;
        tempPriceFormatter=nil;
        [self.priceFormatter setLocale:[NSLocale currentLocale]];
        [self.priceFormatter setMaximumFractionDigits:0];
        [self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        
        
        
        // get car1 record
        if([[cci car1] carid])
        {
            
            cell.yearLabel1.text=[NSString stringWithFormat:@"%d",cci.car1.year];
            
            NSString *priceVal=[self.priceFormatter stringFromNumber:[NSNumber numberWithInteger:cci.car1.price]];
            if(cci.car1.price==0)
            {
                priceVal=@"";
            }
            cell.price1.text=priceVal; 
            
            cell.makeModel1.text=[self combinedStr:cci.car1.make model:cci.car1.model];
            
            
            
            if(cci.car1.hasImage)
            {
                [cell.spinner1 stopAnimating];
                cell.imageView1.image = cci.car1.thumbnailUIImage;
                cell.imageView1.alpha=1.0f;
                [cell.imageView1 setNeedsDisplay];
            }
            else if(cci.car1.failedToDownload)
            {
                [cell.spinner1 stopAnimating];
                //cell.imageView1.image=[UIImage imageNamed:@"tileimage.png"];
                cell.imageView1.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"tileimage" ofType:@"png"]];
                cell.imageView1.alpha=0.0f;
                [cell.imageView1 setNeedsDisplay];
                
            }
            else
            {
                [cell.spinner1 startAnimating];
                cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
                //           NSLog(@"image should be downloaded for %@ - %@ - %d image=%@",cci.car1.make,cci.car1.model,cci.car1.price,cci.car1.thumbnailUIImage);
                if (!self.tableView.dragging && !self.tableView.decelerating)
                {
                    //            NSLog(@"image should be downloaded for %@ - %@ - %d image=%@",cci.car1.make,cci.car1.model,cci.car1.price,cci.car1.thumbnailUIImage);
                    [self startDownloadForCarRecord:cci.car1 forIndexPath:indexPath forCar:1];
                    //
                }
            }
            
            ///
            cell.imageView1.tag=cci.car1.carid;
            
            
            UITapGestureRecognizer *tempGestureRecognizer1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            self.gestureRecognizer1 = tempGestureRecognizer1;
            tempGestureRecognizer1=nil;
            
            //NSLog(@"self.gestureRecognizer1 retain count after if = %ld",CFGetRetainCount((__bridge CFTypeRef)self.gestureRecognizer1));
            
            cell.imageView1.userInteractionEnabled = YES;
            [cell.imageView1 addGestureRecognizer:self.gestureRecognizer1];
            //NSLog(@"cell.imageView1 retain count after adding to imageview = %ld",CFGetRetainCount((__bridge CFTypeRef)cell.imageView1));
            
            //NSLog(@"self.gestureRecognizer1 retain count after adding to imageview = %ld",CFGetRetainCount((__bridge CFTypeRef)self.gestureRecognizer1));
            
            
            cell.spinner1.tag=cci.car1.carid;
            
            UITapGestureRecognizer *tempSpinner1GestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            self.spinner1GestureRecognizer = tempSpinner1GestureRecognizer;
            tempSpinner1GestureRecognizer=nil;
            
            
            cell.spinner1.userInteractionEnabled=YES;
            [cell.spinner1 addGestureRecognizer:self.spinner1GestureRecognizer];
            
            //accessibility
            cell.imageView1.isAccessibilityElement=YES;
            cell.imageView1.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@ %d",[[cci car1] year],[[cci car1] make],[[cci car1] model],[[cci car1] price]];
            
        }
        else
        {
            cell.makeModel1.text=nil;
            cell.price1.text=nil;
            cell.yearLabel1.text=nil;
            cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
            [cell.spinner1 stopAnimating];
            
        }
        
        // get car2 record
        if([[cci car2] carid])
        {
            
            cell.yearLabel2.text=[NSString stringWithFormat:@"%d",cci.car2.year];
            
            NSString *priceVal=[self.priceFormatter stringFromNumber:[NSNumber numberWithInteger:cci.car2.price]];
            if(cci.car2.price==0)
            {
                priceVal=@"";
            }
            
            cell.price2.text=priceVal; 
            
            cell.makeModel2.text=[self combinedStr:cci.car2.make model:cci.car2.model];
            
            if(cci.car2.hasImage)
            {
                [cell.spinner2 stopAnimating];
                cell.imageView2.image = cci.car2.thumbnailUIImage;
                cell.imageView2.alpha=1.0f;
                [cell.imageView2 setNeedsDisplay];
            }
            else if(cci.car2.failedToDownload)
            {
                [cell.spinner2 stopAnimating];
                cell.imageView2.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView2.alpha=0.0f;
                [cell.imageView2 setNeedsDisplay];
                
            }
            else
            {
                [cell.spinner2 startAnimating];
                cell.imageView2.image = [[UIImage alloc] initWithCIImage:nil];
                //           NSLog(@"image should be downloaded for %@ - %@ - %d image=%@",cci.car2.make,cci.car2.model,cci.car2.price,cci.car2.thumbnailUIImage);
                if (!self.tableView.dragging && !self.tableView.decelerating)
                {
                    //            NSLog(@"image should be downloaded for %@ - %@ - %d image=%@",cci.car2.make,cci.car2.model,cci.car2.price,cci.car2.thumbnailUIImage);
                    [self startDownloadForCarRecord:cci.car2 forIndexPath:indexPath forCar:2];
                }
            }
            
            ///
            cell.imageView2.tag=cci.car2.carid;
            UITapGestureRecognizer *tempGestureRecognizer2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            self.gestureRecognizer2 = tempGestureRecognizer2;
            tempGestureRecognizer2=nil;
            
            
            cell.imageView2.userInteractionEnabled = YES;
            [cell.imageView2 addGestureRecognizer:self.gestureRecognizer2];
            
            
            
            cell.spinner2.tag=cci.car2.carid;
            
            UITapGestureRecognizer *tempSpinner2GestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            self.spinner2GestureRecognizer = tempSpinner2GestureRecognizer;
            tempSpinner2GestureRecognizer=nil;
            
            
            cell.spinner2.userInteractionEnabled=YES;
            [cell.spinner2 addGestureRecognizer:self.spinner2GestureRecognizer];
            
            //accessibility
            cell.imageView2.isAccessibilityElement=YES;
            cell.imageView2.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@ %d",[[cci car2] year],[[cci car2] make],[[cci car2] model],[[cci car2] price]];
            
        }
        else
        {
            cell.makeModel2.text=nil;
            cell.price2.text=nil;
            cell.yearLabel2.text=nil;
            cell.imageView2.image = [[UIImage alloc] initWithCIImage:nil];
            [cell.spinner2 stopAnimating];
            
        }
        
        // get car3 record
        if([[cci car3] carid])
        {
            cell.yearLabel3.text=[NSString stringWithFormat:@"%d",cci.car3.year];
            
            NSString *priceVal=[self.priceFormatter stringFromNumber:[NSNumber numberWithInteger:cci.car3.price]];
            if(cci.car3.price==0)
            {
                priceVal=@"";
            }
            
            cell.price3.text=priceVal; 
            
            
            
            cell.makeModel3.text=[self combinedStr:cci.car3.make model:cci.car3.model];
            
            if(cci.car3.hasImage)
            {
                [cell.spinner3 stopAnimating];
                cell.imageView3.image = cci.car3.thumbnailUIImage;
                cell.imageView3.alpha=1.0f;
                [cell.imageView3 setNeedsDisplay];
            }
            else if(cci.car3.failedToDownload)
            {
                [cell.spinner3 stopAnimating];
                cell.imageView3.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView3.alpha=0.0f;
                [cell.imageView3 setNeedsDisplay];
                
            }
            else
            {
                [cell.spinner3 startAnimating];
                cell.imageView3.image = [[UIImage alloc] initWithCIImage:nil];
                //           NSLog(@"image should be downloaded for %@ - %@ - %d image=%@",cci.car3.make,cci.car3.model,cci.car3.price,cci.car3.thumbnailUIImage);
                if (!self.tableView.dragging && !self.tableView.decelerating)
                {
                    //            NSLog(@"image should be downloaded for %@ - %@ - %d image=%@",cci.car3.make,cci.car3.model,cci.car3.price,cci.car3.thumbnailUIImage);
                    [self startDownloadForCarRecord:cci.car3 forIndexPath:indexPath forCar:3];
                }
            }
            
            ///
            cell.imageView3.tag=cci.car3.carid;
            
            
            UITapGestureRecognizer *tempGestureRecognizer3=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            self.gestureRecognizer3 = tempGestureRecognizer3;
            tempGestureRecognizer3=nil;
            
            
            
            cell.imageView3.userInteractionEnabled = YES;
            [cell.imageView3 addGestureRecognizer:self.gestureRecognizer3];
            
            
            
            cell.spinner3.tag=cci.car3.carid;
            
            UITapGestureRecognizer *tempSpinner3GestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
            self.spinner3GestureRecognizer = tempSpinner3GestureRecognizer;
            tempSpinner3GestureRecognizer=nil;
            
            
            cell.spinner3.userInteractionEnabled=YES;
            [cell.spinner3 addGestureRecognizer:self.spinner3GestureRecognizer];
            
            //accessibility
            cell.imageView3.isAccessibilityElement=YES;
            cell.imageView3.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@ %d",[[cci car3] year],[[cci car3] make],[[cci car3] model],[[cci car3] price]];
            
        }
        else
        {
            cell.makeModel3.text=nil;
            cell.price3.text=nil;
            cell.yearLabel3.text=nil;
            cell.imageView3.image = [[UIImage alloc] initWithCIImage:nil];
            [cell.spinner3 stopAnimating];
            
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        //priceFormatter=nil;
    }
    
    cell.isAccessibilityElement=NO;
    return cell; 
    
}

#pragma mark -
#pragma mark UCE Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CustomCellInfo *cci=[self.arrayOfAllCustomCellInfoObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cci.car1.carid==record.carid) {
                
                CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=img;
                cell.imageView1.alpha=1.0f;
                [cell.imageView1 setNeedsDisplay];
                
                //NSLog(@"image updated for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
        else if (carNum==2) {
            if (cci.car2.carid==record.carid) {
                
                CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner2 stopAnimating];
                cell.imageView2.image=img;
                cell.imageView2.alpha=1.0f;
                [cell.imageView2 setNeedsDisplay];
                
                //NSLog(@"image updated for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
        else if (carNum==3) {
            if (cci.car3.carid==record.carid) {
                
                CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner3 stopAnimating];
                cell.imageView3.image=img;
                cell.imageView3.alpha=1.0f;
                [cell.imageView3 setNeedsDisplay];
                
                //NSLog(@"image updated for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
    //    NSLog(@"image came for %@ - %@ - %d carid=%d currentIndexPath=%@",record.make,record.model,record.price,record.carid,indexPath);
    
}


- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CustomCellInfo *cci=[self.arrayOfAllCustomCellInfoObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cci.car1.carid==record.carid) {
                
                CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView1.alpha=0.0f;
                [cell.imageView1 setNeedsDisplay];
                
                //NSLog(@"image failed for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
        else if (carNum==2) {
            if (cci.car2.carid==record.carid) {
                
                CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner2 stopAnimating];
                cell.imageView2.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView2.alpha=0.0f;
                [cell.imageView2 setNeedsDisplay];
                
                //NSLog(@"image failed for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
        else if (carNum==3) {
            if (cci.car3.carid==record.carid) {
                
                CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner3 stopAnimating];
                cell.imageView3.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView3.alpha=0.0f;
                [cell.imageView3 setNeedsDisplay];
                
                //NSLog(@"image failed for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
}





/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122;
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
}



#pragma mark - ScrollView Methods


-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //ensure that the end of scroll is fired
    
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //scroll view has stopped scrolling
    
    //now check if we are at bottom or top
    
    
	[self snapBottomCell];
    
    
    if (!self.tableviewStopped) {
        [self loadImagesForOnscreenCells];
        self.tableviewStopped=YES;
    }
    
    NSArray *visibleRowsIndexPaths=[self.tableView indexPathsForVisibleRows];
    NSIndexPath *iPath=[visibleRowsIndexPaths objectAtIndex:0];
    
    if (iPath.row<=3 && !self.operationStarted) { //currentOffset<=3*122
        //NSLog(@"we are at the top");
        //call loadRowsAtTop. send it self.lowestPageNumInMemory
        //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
        if(self.loadRowsAtTopCounterMain==1)
            if(self.lowestPageNumInMemory>1)
            {
                //NSLog(@"calling first op at top");
                                
                self.userScrolledToTop=1;
                
                self.op2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadRowsAtTop:) object:[NSNumber numberWithInteger:self.lowestPageNumInMemory]];
                
                [self.CustomTableNSOperationQueue addOperation:self.op2];
            }
    }
    else if (iPath.row>=12 && !self.operationStarted) {
        //NSLog(@"we are at the end");
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                //NSLog(@"calling first op at bottom");
                                
                self.userScrolledToBottom=1;
                self.op1=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadRowsAtEnd:) object:[NSNumber numberWithInteger:self.currentPage]];
                
                [self.CustomTableNSOperationQueue addOperation:self.op1];
            }   
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:nil afterDelay:0.3];
    
    [self snapBottomCell];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self cancelAllOperations];
    self.tableviewStopped=NO;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2
    if (!decelerate) {
        [self loadImagesForOnscreenCells]; //this line is not getting executed. check on device
    }
}


#pragma mark - 
#pragma mark - Cancelling, suspending, resuming queues / operations

//this is for cancelling thumbnails only. cancelling normal operations will have bad consequences as this method is called from many places
- (void)cancelAllOperations {
    [self.homeScreenThumbnailQueue cancelAllOperations];
}


- (void)loadImagesForOnscreenCells
{
    
    
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    NSArray* sortedIndexPaths = [visibleRows sortedArrayUsingSelector:@selector(compare:)];
    
    NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    
    for (NSIndexPath *ip in sortedIndexPaths)
    {        
        CustomCellInfo *cci=[self.arrayOfAllCustomCellInfoObjects objectAtIndex:ip.row];
        CustomCell *cell=(CustomCell *)[self.tableView cellForRowAtIndexPath:ip];
        
        if (!cci.car1.hasImage && [[cci car1] carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",cci.car1.carid]])
            {
                cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner1 startAnimating];
                [self startDownloadForCarRecord:cci.car1 forIndexPath:ip forCar:1];
            }    
            
        } 
        //
        if (!cci.car2.hasImage && [[cci car2] carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",cci.car2.carid]])
            {
                cell.imageView2.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner2 startAnimating];
                [self startDownloadForCarRecord:cci.car2 forIndexPath:ip forCar:2];
            }
            
        }  
        //
        if (!cci.car3.hasImage && [[cci car3] carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",cci.car3.carid]])
            {
                cell.imageView3.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner3 startAnimating];
                [self startDownloadForCarRecord:cci.car3 forIndexPath:ip forCar:3];
            }
            
        }
    }
    //    pendingCarids=nil;
    //    visibleRows=nil;
    //    sortedIndexPaths=nil;
    
}

#pragma mark - Notif methods
- (void)workingArrayFromHomeScreenOperationNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(workingArrayFromHomeScreenOperationNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    //enable updatezip button
    if (![self.rightBarbutton isEnabled]) {
        [self.rightBarbutton setEnabled:YES];
    }
    
    NSArray *mArray=[[notif userInfo] valueForKey:@"HomeScreenOperationResultsKey"];
    
    /*
    //test whether proper data is received
    
    for (CustomCellInfo *cci in mArray) {
        
        NSLog(@"Carid is =%d price is =%d",cci.car1.carid,cci.car1.price);
        
        NSLog(@"Carid is =%d price is =%d",cci.car2.carid,cci.car2.price);
        
        NSLog(@"Carid is =%d price is =%d",cci.car3.carid,cci.car3.price);
    }
    NSLog(@"mArray(ie., number of cells) received count = %d",[mArray count]);
    NSLog(@"self.arrayOfAllCustomCellInfoObjects before adding mArray cells=%@",self.arrayOfAllCustomCellInfoObjects);
    */
    [self hideActivityViewer];
    [self updateTableViewFooter];
    
    CustomCellInfo *cci=[mArray objectAtIndex:0];
    CarRecord *car1=[cci car1];
    //self.totalPages=[[car1 pageCount]integerValue]; //_pageCount field val is getting wrong from service
    self.totalPages=ceil([[car1 totalRecords]integerValue]*1.0/9.0);
    //NSLog(@"self.totalPages=%d",self.totalPages);
    
    if([mArray count]>0)
        if(self.loadingAtBottom)
        {
            
            [self updateTableViewHeader];           
            
            [self updateTableViewFooter];
            [self.activityIndicator stopAnimating];
            
            
            
            NSInteger testCounter=0;
            testCounter=self.currentPage-5-self.lowestPageNumInMemory+1;
            if(testCounter>0)
            {
                if (self.currentPage==self.totalPages) { //we have to set lastPageCellsCount when loading at bottom that too when 6th or higher page is retrieved. This is because currentpage will be equal to totalpages when adding first page in reverse order. ie., if total pages to 45, when loading 40th page.
                    self.lastPageCellsCount=[mArray count];
                }
                else
                {
                    self.lastPageCellsCount=3;
                }
                
                
                // if currentPage-lowestPageInMemory >0, we have to first delete the lowestPageInMemory, then add the received data
                
                CGPoint tableviewOffset2=[self.tableView contentOffset];
                CGPoint tempOffset2=tableviewOffset2;
                tempOffset2.y-=3*122;
                tableviewOffset2=tempOffset2;
                
                
                NSIndexSet *indexSetOfCellsToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
                [self.arrayOfAllCustomCellInfoObjects removeObjectsAtIndexes:indexSetOfCellsToDelete];
                
                
                //
                NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] initWithCapacity:1];
                for (int i=0; i<3; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToBeDeleted addObject:ip2];
                }
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView deleteRowsAtIndexPaths:cellIndicesToBeDeleted withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                [self.tableView setContentOffset:tableviewOffset2 animated:NO];
                
                
                
                
                //
                [self.arrayOfAllCustomCellInfoObjects addObjectsFromArray:mArray];
                
                //
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
                //calculate the [self.arrayOfAllCustomCellInfoObjects count]. This gives us the number of rows to add in table.
                //NSInteger count1=[self.arrayOfAllCustomCellInfoObjects count];
                NSInteger count1=[self.tableView numberOfRowsInSection:0];
                
                
                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                }
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView insertRowsAtIndexPaths:cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                [self.tableView setContentOffset:tableviewOffset2 animated:NO];
                
                
                //one page data deleted from top. so lowest page number increased by 1
                //self.lowestPageNumInMemory++;
                self.lowestPageNumInMemory=self.currentPage-5+1;
                
                [self loadNextOrPreviousPage];
                
            }
            else
            {
                NSInteger count1=[self.arrayOfAllCustomCellInfoObjects count];
                
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];

                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                    
                    
                }
                
                [self.arrayOfAllCustomCellInfoObjects addObjectsFromArray:mArray];
                
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView insertRowsAtIndexPaths:cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                
                [self loadNextOrPreviousPage];
            }
        }
        else if(self.loadingAtTop)
        {
            NSInteger testCounter=0;
            testCounter=self.currentPage-5-self.lowestPageNumInMemory+1;
            
            
            if(testCounter>0)
            {
                NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] initWithCapacity:1];
                NSIndexSet *indexSet4=nil;
                if (self.currentPage==self.totalPages) {
                    
                    indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(12, self.lastPageCellsCount)];
                    
                    
                    for (int i=12; i<12+self.lastPageCellsCount; i++) {
                        NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                        [cellIndicesToBeDeleted addObject:ip2];
                    }
                    
                }
                else
                {
                    indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(12, 3)];
                    for (int i=12; i<12+3; i++) {
                        NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                        [cellIndicesToBeDeleted addObject:ip2];
                    }
                }
                
                
                
                [self.arrayOfAllCustomCellInfoObjects removeObjectsAtIndexes:indexSet4];
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView deleteRowsAtIndexPaths:cellIndicesToBeDeleted withRowAnimation:UITableViewRowAnimationNone];
                
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                
                
                //change self.currentPage value appropriately
                self.currentPage--;
                
                ///////////////
                
                NSIndexSet *indexSetForTopRows = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
                //            NSLog(@"index set to add %@",indexSetForTopRows);
                
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
                
                NSInteger heightForNewRows=122*3;
                //go to first row and add there
                for (int i=0; i<3; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                }
                
                
                
                //we have add data at the beginning of array, so use insertObjects:atIndexes method
                [self.arrayOfAllCustomCellInfoObjects insertObjects:mArray atIndexes:indexSetForTopRows];
                
                
                //save current offset
                CGPoint tableviewOffset=[self.tableView contentOffset];
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView insertRowsAtIndexPaths:cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
                tableviewOffset.y += heightForNewRows;
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                [self.tableView setContentOffset:tableviewOffset animated:NO];

                [self loadNextOrPreviousPage];
            } 
        }
}

- (void)homeScreenOperationFailedNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(homeScreenOperationFailedNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    NSError *error=[[notif userInfo] valueForKey:@"HomeScreenOperationFailedNotifKey"];
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    //enable updatezip button
    if (![self.rightBarbutton isEnabled]) {
        [self.rightBarbutton setEnabled:YES];
    }
    
    
    self.footerLabel.text =@"Connection Failed ...";
    [self.footerLabel setNeedsDisplay];
    
    [self hideActivityViewer];
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    
    if ([error code]==kCFURLErrorNotConnectedToInternet) {
        alert.title=@"No Internet Connection";
        alert.message=@"UCE cannot retreive data as it is not connected to the Internet.";
    }
    else if([error code]==-1001)
    {
        alert.title=@"Error Occured";
        alert.message=@"The request timed out.";
    }
    else
    {
        alert.title=@"Server Error";
        alert.message=@"UCE cannot retreive data due to server error.";
    }
    [alert show];
    alert=nil;
    
    if(self.currentPage==1)
    {
        self.currentPage=0;
    }
    
}

-(void)noResultsForThisZipNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(noResultsForThisZipNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    [self hideActivityViewer];
    
    //enable updatezip button
    if (![self.rightBarbutton isEnabled]) {
        [self.rightBarbutton setEnabled:YES];
    }
    
    [self.footerLabel removeFromSuperview];
    
    if (self.currentPage==1) {
        
        [self setupTableViewHeader];
        
        UIAlertView *tempNoResultsAlert=[[UIAlertView alloc]initWithTitle:@"No Cars Found" message:@"Enter another zip code or see all cars?" delegate:self cancelButtonTitle:@"Use New Zip" otherButtonTitles:@"See All Cars", nil];
        self.noResultsAlert=tempNoResultsAlert;
        tempNoResultsAlert=nil;
        [self.noResultsAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[self.noResultsAlert textFieldAtIndex:0] setDelegate:self];
        if (!IsEmpty(self.zipStr)) {
            [self.noResultsAlert textFieldAtIndex:0].text=self.zipStr;
        }
        [[self.noResultsAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        
        [self.noResultsAlert show];
        
        self.totalPages=0;
    }
    else if (self.currentPage>1)
    {
        
        if(self.currentPage>5)
        {
            self.lowestPageNumInMemory=self.currentPage-5+1;
        }
        self.currentPage--;
    }
}

#pragma mark - Private Methods

- (void)snapBottomCell
{
	NSInteger cellHeight = 122; //Cells for my view are 122px tall. Sub your own height here
    
	NSInteger offsetOverage = (NSInteger) self.tableView.contentOffset.y % cellHeight;
	//Use the tableview's contentOffset property and the cell height to determine how much is being cut off
    
	if (offsetOverage > 0)
	{
		//If the overage is more than 0, we should figure out what the new offset needs to be
        
		NSInteger newOffset;
        
		if (offsetOverage >= (cellHeight/2))
		{
			newOffset = self.tableView.contentOffset.y + (cellHeight - offsetOverage);
			//If the overage is greater than or equal to half the height of a cell, pull the cell up so it's fully visible
		}
        
		else {
			newOffset = self.tableView.contentOffset.y - offsetOverage;
			//Else, push the cell out of view
		}
        
		//With the new offset determined, animate the movement:
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[self.tableView setContentOffset:CGPointMake(0, newOffset) animated:NO];
		[UIView commitAnimations];
        
	}
}

- (void)setupTableViewHeader 
{
    // set up label
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    label.font = [UIFont boldSystemFontOfSize:25];
    label.textColor = [UIColor blackColor];
    label.backgroundColor=[UIColor colorWithRed:0.792 green:0.788 blue:0.792 alpha:1.000];
    label.textAlignment = UITextAlignmentCenter;
    label.text=@"(empty)";
    
    self.headerLabel=label;
    [headerView addSubview:label];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)updateTableViewHeader
{
    [self.headerLabel removeFromSuperview];
    
    [self.headerLabel setNeedsDisplay];
    self.tableView.tableHeaderView=nil;
}

- (void)setupTableViewFooter 
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor=[UIColor colorWithRed:0.792 green:0.788 blue:0.792 alpha:1.000];
    label.textAlignment = UITextAlignmentCenter;
    label.text=@"loading ...";
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.tableView.tableFooterView = footerView;
}


- (void)updateTableViewFooter 
{
    if ([self.arrayOfAllCustomCellInfoObjects count] > 9) 
    {
        self.footerLabel.text =@"loading ...";
    }
    else if ([self.arrayOfAllCustomCellInfoObjects count] <= 9) 
    {
        [self.footerLabel removeFromSuperview];
    }
    
    [self.footerLabel setNeedsDisplay];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.updateZipAlert]) {
        //if the entered zip is not empty, if it not same as existing zip, validate it, save it to nsuserdefaults
        //self.updateZipAlert.delegate=nil;
        //self.updateZipAlert=nil;
        
        if(IsEmpty([self.updateZipAlert textFieldAtIndex:0].text) || [self.zipStr isEqualToString:[self.updateZipAlert textFieldAtIndex:0].text])
        {
            return;
        }
        else
        {
            //save this zip code for later use in notif result
            self.zipStr=[self.updateZipAlert textFieldAtIndex:0].text;
            [self validateZip:self.zipStr];
            
        }
    }
    else if ([alertView isEqual:self.noResultsAlert]) {
        //self.noResultsAlert.delegate=nil;
        
        if (buttonIndex==alertView.cancelButtonIndex) { // cancel button clicked "Reenter Zip"
            
            //show the original alertview again after removing Wi-Fi calculated zip
            
            
            //save this zip code for later use in notif result
            self.zipStr=[self.noResultsAlert textFieldAtIndex:0].text;
            
            [self validateZip:self.zipStr];
        }
        else
        {
            self.zipStr=@"0";
            [self showZipInUpdateZipLabel:self.zipStr];
            [self updateTableViewHeader]; 
            [self loadFirstPageResults];
        }
    }
    else if ([alertView isEqual:self.invalidZipAlert]) {
        
        if (buttonIndex==alertView.cancelButtonIndex) { // cancel button clicked
            
            return;
            
        }
        else
        {
            //take zip if present in right bar button and show inside text field so easy editing
            
            NSString *onlyZip=[CommonMethods findZipFromBarButtonTitle:self.rightBarbutton.title];
            
            //newly entered zip is same as that of whose cars are already showing on screen
            if ([onlyZip isEqualToString:[alertView textFieldAtIndex:0].text]) {
                self.zipStr=onlyZip;
                return;
            }
            
            if (IsEmpty([alertView textFieldAtIndex:0].text)) {
                //NSLog(@"user did not enter any value");
                //[self updateTableViewHeader]; 
                
                self.invalidZipAlert=[[UIAlertView alloc]initWithTitle:@"Invalid Zip" message:@"Enter a valid Zip code." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Ok", nil];
                [self.invalidZipAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [[self.invalidZipAlert textFieldAtIndex:0] setDelegate:self];
                [[self.invalidZipAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
                [self.invalidZipAlert show];
                
                
                return; //don't check other conditions
                
            }
            
            
            
            if([self.zipStr isEqualToString:[self.invalidZipAlert textFieldAtIndex:0].text])
            {
                
                
                self.invalidZipAlert=[[UIAlertView alloc]initWithTitle:@"Invalid Zip" message:@"Enter a valid Zip code." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Ok", nil];
                [self.invalidZipAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [[self.invalidZipAlert textFieldAtIndex:0] setDelegate:self];
                [[self.invalidZipAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
                [self.invalidZipAlert show];
                
            }
            else
            {
                self.zipStr=[self.invalidZipAlert textFieldAtIndex:0].text;
                [self validateZip:self.zipStr];
            }
            
        }
    }
    else if ([alertView isEqual:self.didSendZipAlert]) {
        
        if (buttonIndex==alertView.cancelButtonIndex) { // cancel button clicked
            //show cars with zip 0
            self.usersZipCodeFromWiFi=@"0";
            self.zipStr=@"0";
            
            [self showZipInUpdateZipLabel:self.zipStr];
            [self loadFirstPageResults];
            
        }
        else
        {
            //if the zip is not what we received, validate it
            
            //if the zip is same as what we received, call service with that zip
            if([self.usersZipCodeFromWiFi isEqualToString:[self.didSendZipAlert textFieldAtIndex:0].text])
            {
                self.zipStr=self.usersZipCodeFromWiFi;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:self.zipStr forKey:@"homeZipValue"];
                [defaults synchronize];
                
                [self showZipInUpdateZipLabel:self.zipStr];
                [self loadFirstPageResults];
                
            }
            else
            {
                self.zipStr=[self.didSendZipAlert textFieldAtIndex:0].text;
                [self validateZip:[self.didSendZipAlert textFieldAtIndex:0].text];
            }
        }
    }
    
}

-(void)validateZip:(NSString *)zipToValidate
{
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.CustomTableNSOperationQueue addOperation:checkZipCode];
    checkZipCode=nil;
    
    //disable screen as user may click on any visible car(if present)
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    
}

-(void)showZipInUpdateZipLabel:(NSString *)zipValue
{
    NSString *zipStrToDisplyAccessibilityLabel=nil;
    if(zipValue==nil || [zipValue isEqualToString:@"0"])
    {
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip:?"]];
        zipStrToDisplyAccessibilityLabel=@"Zip";
        
    }
    else
    {
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip:%@",zipValue]];
        zipStrToDisplyAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",zipValue];
    }
    self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
}


-(void)deletePreviousResults
{
    
    //if there is already data in the tableview, delete it and continue loading page 1
    //initialize all ivars as in viewdidload or viewwillappear
    //cancel any operrations that might be running
    if ([[self arrayOfAllCustomCellInfoObjects] count]>0) {
        
        //first cancel pending operations here
        //cancel any previous pending operations running on any of the queues
        //CustomTableNSOperationQueue,homeScreenThumbnailQueue
        if ([[self.CustomTableNSOperationQueue operations] count]>0) {
            [self.CustomTableNSOperationQueue cancelAllOperations];
        }
        
        if ([[self.homeScreenThumbnailQueue operations] count]>0) {
            [self.homeScreenThumbnailQueue cancelAllOperations];
        }
        
        
        //find count and delete all objects
        NSInteger countOfObjects=[self.arrayOfAllCustomCellInfoObjects count];
        
        NSIndexSet *indexSetOfCells2Delete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfObjects)];
        
        NSMutableArray *cellIndicesToBeDeleted = [NSMutableArray array];
        
        for (int i=0; i<countOfObjects; i++) {
            NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
            [cellIndicesToBeDeleted addObject:ip2];
        }
        
        
        [self.arrayOfAllCustomCellInfoObjects removeObjectsAtIndexes:indexSetOfCells2Delete];
        
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:cellIndicesToBeDeleted withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        
        
        // initialize ivars here
        
        [self.CustomTableNSOperationQueue cancelAllOperations];
        
        self.loadingAtBottom=YES;
        self.loadingAtTop=NO;
        self.currentPage=1;
        self.lowestPageNumInMemory=1;
        self.lastPageCellsCount=0;
        
        self.loadRowsAtEndCounterMain=1;
        self.loadRowsAtTopCounterMain=1;
    }
    
}

-(void)loadFirstPageResults
{
    if (!self.operationStarted) {
        
        
        //disable updatezip button
        [self.rightBarbutton setEnabled:NO];
        
        [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];  
        //... do your reload or expensive operations
        
        //loading page1
        self.currentPage=1;
        
        HomeScreenOperation *hso1=[[HomeScreenOperation alloc]init];
        hso1.pageNoReceived=self.currentPage;
        hso1.pageSizeReceived=9;
        hso1.usersZipReceived=self.zipStr;
        //hso1.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso1];
        self.operationStarted=YES;
        hso1=nil;
        //NSLog(@"after loading 1st page, current page no is %d",self.currentPage);
    }
}

-(void)checkZipCodeNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    
    //remove activityviewer which was show in validatezip method
    [self hideActivityViewer];
    
    if([[[notif userInfo] valueForKey:@"CheckZipCodeNotifKey"] isKindOfClass:[NSError class]])
    {
        
        NSError *error=[[notif userInfo] valueForKey:@"CheckZipCodeNotifKey"];
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        
        UIAlertView *alert=[[UIAlertView alloc]init];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        
        
        if ([error code]==kCFURLErrorNotConnectedToInternet)
        {
            self.footerLabel.text =@"Connection Failed ...";
            
            alert.title=@"No Internet Connection";
            alert.message=@"UCE cannot retreive data as it is not connected to the Internet.";
        }
        else if([error code]==-1001)
        {
            self.footerLabel.text =@"The request timed out.";
            
            alert.title=@"Error Occured";
            alert.message=@"The request timed out.";
        }
        else
        {
            self.footerLabel.text =@"Server Error ...";
            
            alert.title=@"Server Error";
            //alert.message=[error description];
            alert.message=@"UCE cannot retreive data due to server error.";
        }
        
        [self.footerLabel setNeedsDisplay];
        
        
        [alert show];
        alert=nil;
        
        ////
        
        return;
    }
    
    NSString *boolValStr=[[notif userInfo]valueForKey:@"CheckZipCodeNotifKey"];
    
    if(boolValStr==nil)
        return;
    
    if ([boolValStr isEqualToString:@"false"]) {
        //invalid zip entered
        //initialize zip value
        //self.zipStr=@"0";
        
        UIAlertView *tempInvalidZipAlert=[[UIAlertView alloc]initWithTitle:@"Invalid Zip" message:@"Enter a valid Zip code." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Ok", nil];
        self.invalidZipAlert=tempInvalidZipAlert;
        [self.invalidZipAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[self.invalidZipAlert textFieldAtIndex:0] setDelegate:self];
        if (!IsEmpty(self.zipStr)) {
            [self.invalidZipAlert textFieldAtIndex:0].text=self.zipStr;
        }
        [[self.invalidZipAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [self.invalidZipAlert show];
        tempInvalidZipAlert=nil;
        
    }
    else
    {
        [self deletePreviousResults];
        
        //now load first page depending on zip
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.zipStr forKey:@"homeZipValue"];
        [defaults synchronize];
        
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip:%@",self.zipStr]];
        NSString *zipStrToDisplyAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
        
        [self loadFirstPageResults];
    }
}

-(void)errorFindingLocationNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(errorFindingLocationNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.findZip.delegate=nil;
    self.findZip=nil;
    
    NSLog(@"WIFI Hot Spot error in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    
    NSString *message=nil,*title=nil;
    
    
    self.usersZipCodeFromWiFi=nil;
    self.zipStr=self.usersZipCodeFromWiFi;
    
    title=@"Enter Zip";
    message=@"Enter Zip code to get cars in your area.";
        
    //show alert view and load first page in the alertview delegate when depending on the zip user entered.
    
    UIAlertView *tempDidSendZipAlert=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Ok", nil];
    self.didSendZipAlert=tempDidSendZipAlert;
    [self.didSendZipAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[self.didSendZipAlert textFieldAtIndex:0] setDelegate:self];
    [self.didSendZipAlert textFieldAtIndex:0].text=@"";
    self.zipStr=@"";
    [[self.didSendZipAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [self.didSendZipAlert show];
    tempDidSendZipAlert=nil;
}

-(void)didSendZip:(NSString *)zipVal
{
    self.findZip.delegate=nil;
    self.findZip=nil;
    
    NSString *message=nil,*title=nil;
    
    if(zipVal!=nil)
    {
        self.usersZipCodeFromWiFi=zipVal;
        self.zipStr=self.usersZipCodeFromWiFi;
    }
    title=@"Enter Zip";
    message=@"Enter Zip code to get cars in your area.";
        
    //show alert view and load first page in the alertview delegate when depending on the zip user entered.
    
    UIAlertView *tempDidSendZipAlert=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Ok", nil];
    self.didSendZipAlert=tempDidSendZipAlert;
    [self.didSendZipAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[self.didSendZipAlert textFieldAtIndex:0] setDelegate:self];
    [self.didSendZipAlert textFieldAtIndex:0].text=self.usersZipCodeFromWiFi;
    self.zipStr=self.usersZipCodeFromWiFi;
    //[self.didSendZipAlert textFieldAtIndex:0].text=@"44146"; //38348
    //self.zipStr=@"44146";
    [[self.didSendZipAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [self.didSendZipAlert show];
    tempDidSendZipAlert=nil;
    
}

-(void)imageViewClicked:(UITapGestureRecognizer*)gestRecognizer
{
    NSInteger tempTag=gestRecognizer.view.tag;
    
    for (CustomCellInfo *cci in self.arrayOfAllCustomCellInfoObjects) {
        
        if (cci.car1!=nil) {
            
            if (tempTag == cci.car1.carid) {
                if (self.carRecordToSendToDetailView!=nil) {
                    self.carRecordToSendToDetailView=nil;
                }
                self.carRecordToSendToDetailView=[cci car1];
            }
        }
        
        if (cci.car2!=nil) {
            if (tempTag == cci.car2.carid) {
                if (self.carRecordToSendToDetailView!=nil) {
                    self.carRecordToSendToDetailView=nil;
                }
                self.carRecordToSendToDetailView=[cci car2];
            }
        }
        
        if (cci.car3!=nil) {
            if (tempTag == cci.car3.carid) {
                if (self.carRecordToSendToDetailView!=nil) {
                    self.carRecordToSendToDetailView=nil;
                }
                self.carRecordToSendToDetailView=[cci car3];
            }
        }
        
    }
    
    [self performSegueWithIdentifier:@"Detailviewsegue" sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Detailviewsegue"])
    {
        
        DetailView *cardetailview=[segue destinationViewController];
        cardetailview.delegate=self;
        
        //uncomment later
        
        
        cardetailview.carRecordFromFirstView=self.carRecordToSendToDetailView;
        self.carRecordToSendToDetailView=nil;
        
        
    }
    
    
}

-(NSString *)combinedStr:(NSString *)make model:(NSString *)model
{
    NSString *combined=nil;
    
    if ([make length]<=8) {
        combined=[make stringByAppendingFormat:@" %@",model];
    }
    else if(([model length]>8))
    {
        NSRange makeRange=NSMakeRange(0, 8);
        NSRange modelRange=NSMakeRange(0, 8);
        
        NSString *trimmedMake=[make substringWithRange:makeRange];
        NSString *trimmedModel=[model substringWithRange:modelRange];
        
        combined=[trimmedMake stringByAppendingFormat:@" %@",trimmedModel];
        
    }
    else
    {
        NSInteger freeSpaces=8-[model length];
        
        if ([make length]>(8+freeSpaces)) {
            NSRange finalMakeRange=NSMakeRange(0, 8+freeSpaces);
            make=[make substringWithRange:finalMakeRange];
        }
        combined=[make stringByAppendingFormat:@" %@",model];
    }
    
    return combined;
}

-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num
{
    
    if (!record.hasImage) {
        
        //create operation
        
        NSURL *URL = [NSURL URLWithString:record.imagePath];
        NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
        
        
        AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            //NSLog(@"download succeeded for car %d",num);
            NSData *data=(NSData *)responseObject;
            
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                record.thumbnailUIImage=image;
                [self downloadDidFinishDownloading:record forImage:image forCar:num];
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            //NSLog(@"download failed for car %d",num);
            record.failedToDownload=YES;
            [self download:record forCar:num didFailWithError:error];
        }];
        
        
        NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]]; //gives all carids
        
        if (![pendingCarids containsObject:[NSString stringWithFormat:@"%d",record.carid]]) {
            
            [self.downloadsInProgress setObject:operation forKey:[NSString stringWithFormat:@"%d",record.carid]];
            
            [self.homeScreenThumbnailQueue addOperation:operation];
            
            //            NSLog(@"carids in queue are %@",[self.downloadsInProgress allKeys]);
        }
    }
}


#pragma mark - DetailView Delegate Method

-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord
{
    //NSLog(@"thumbnailDidDownloadedInDetailView called");
    
    //get all visible indexpaths
    NSArray *visibleIPaths=[self.tableView indexPathsForVisibleRows];
    CustomCellInfo *cci;
    
    for (NSIndexPath *ip in visibleIPaths) {
        cci=[self.arrayOfAllCustomCellInfoObjects objectAtIndex:ip.row];
        
        if ([[cci car1] carid]==[aRecord carid]||[[cci car2] carid]==[aRecord carid]||[[cci car3] carid]==[aRecord carid]) {
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    detailView.delegate=nil;
}

#pragma mark - TextField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //this is for text field from didSendZip and checkZipCodeNotifMethod methods. If other text fields use this method, then use checking
    NSUInteger newLength = [textField.text length] + [string length] - range.length;

    return (newLength > 5) ? NO : YES;
}

-(void)dealloc
{
    //NSLog(@"CustomTable dealloc called");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NoResultsForThisZipNotif" object:nil];
    
    [self cancelAllOperations];
    
    _arrayOfAllCustomCellInfoObjects=nil;
    _gestureRecognizer1=nil;
    _gestureRecognizer2=nil;
    _gestureRecognizer3=nil;
    _spinner1GestureRecognizer=nil;
    _spinner2GestureRecognizer=nil;
    _spinner3GestureRecognizer=nil;
    _activityIndicator=nil;
    _footerLabel=nil;
    _headerLabel=nil;
    _noResultsAlert=nil;
    _updateZipAlert=nil;
    _invalidZipAlert=nil;
    _didSendZipAlert=nil;
    _findZip=nil;
    _usersZipCodeFromWiFi=nil;
    _zipStr=nil;
    _downloadsInProgress=nil;
    _activityImageView=nil;
    _CustomTableNSOperationQueue=nil;
    _homeScreenThumbnailQueue=nil;
    _rightBarbutton=nil;
    _carRecordToSendToDetailView=nil;
    _op1=nil;
    _op2=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
    _priceFormatter=nil;
}

@end
