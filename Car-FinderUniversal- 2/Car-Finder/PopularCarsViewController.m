//
//  PopularCarsViewController.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/8/13.
//
//

#import "PopularCarsViewController.h"

#import "PopularCarsCell.h"
#import "PopularCarsCellInfo.h"
#import "DetailView.h"
#import "AppDelegate.h"
#import "CarRecord.h"
#import "CheckZipCode.h"
#import "QuartzCore/QuartzCore.h"
#import "CFNetwork/CFNetwork.h"
#import "AFNetworking.h"

#import "CommonMethods.h"

#define IPHONECELLWIDTHFORRESULTS 100

#define IPHONECELLHEIGHTFORRESULTS 108

#define IPADCELLWIDTHFORRESULTS 108

#define IPADCELLHEIGHTFORRESULTS 124

#define IPHONECARS 18


@interface PopularCarsViewController ()

@property(strong,nonatomic) NSMutableArray *arrayOfPopularCarsCellInfoObjects;

@property(assign,nonatomic) NSInteger lastPageCellsCount,loadRowsAtEndCounterMain,loadRowsAtTopCounterMain,currentPage,totalPages,userScrolledToBottom,userScrolledToTop,lowestPageNumInMemory;

@property(assign,nonatomic) BOOL operationStarted,loadingAtTop,loadingAtBottom,collectionViewStopped;

@property(copy,nonatomic) NSString *usersZipCodeFromWiFi,*zipStr;

@property(strong,nonatomic) NSOperationQueue *CustomTableNSOperationQueue,*homeScreenThumbnailQueue;

@property(strong,nonatomic) UIAlertView *noResultsAlert,*updateZipAlert,*invalidZipAlert,*didSendZipAlert;

@property(strong,nonatomic) UIBarButtonItem *rightBarbutton;

@property(strong,nonatomic) CarRecord *carRecordToSendToDetailView;

@property(strong,nonatomic) NSInvocationOperation *op1,*op2;

@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;

@property(strong,nonatomic) FindCurrentZip *findZip;

@property (nonatomic, strong) UILabel *footerLabel,*headerLabel;

@property(strong,nonatomic) NSBlockOperation *blockOperation1,*blockOperation2,*blockOperationLoadingAtTop1,*blockOperationLoadingAtTop2;

@property(assign,nonatomic) BOOL isShowingLandscapeView;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;


@end

@implementation PopularCarsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Static Methods

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

#pragma mark - Private Methods

-(void)loadNextOrPreviousPage
{
    
    if(self.currentPage==1 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //loading page2
        
        
        HomeScreenOperation *hso2=[[HomeScreenOperation alloc]init];
        hso2.pageNoReceived=self.currentPage;
        hso2.pageSizeReceived=IPHONECARS;
        hso2.usersZipReceived=self.zipStr;
        //hso2.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso2];
        self.operationStarted=YES;
        
    }
    else if(self.currentPage==2 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //loading page3
        
        
        HomeScreenOperation *hso3=[[HomeScreenOperation alloc]init];
        hso3.pageNoReceived=self.currentPage;
        hso3.pageSizeReceived=IPHONECARS;
        hso3.usersZipReceived=self.zipStr;
        //hso3.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso3];
        self.operationStarted=YES;
    }
    else if(self.currentPage==3 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //loading page4
        
        
        HomeScreenOperation *hso4=[[HomeScreenOperation alloc]init];
        hso4.pageNoReceived=self.currentPage;
        hso4.pageSizeReceived=IPHONECARS;
        hso4.usersZipReceived=self.zipStr;
        //hso4.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso4];
        self.operationStarted=YES;
    }
    else if(self.currentPage==4 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        
        HomeScreenOperation *hso5=[[HomeScreenOperation alloc]init];
        hso5.pageNoReceived=self.currentPage;
        hso5.pageSizeReceived=IPHONECARS;
        hso5.usersZipReceived=self.zipStr;
        //hso5.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso5];
        self.operationStarted=YES;
        
    }
    
    else if(self.currentPage>=5 && self.currentPage<=14 && (self.currentPage+1)<=self.totalPages && !self.operationStarted && (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad))
    {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        
        HomeScreenOperation *hso6=[[HomeScreenOperation alloc]init];
        hso6.pageNoReceived=self.currentPage;
        hso6.pageSizeReceived=IPHONECARS;
        hso6.usersZipReceived=self.zipStr;
        //hso6.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso6];
        self.operationStarted=YES;
        
    }
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
}


-(void)loadRowsAtTop:(NSNumber *)receivedLowestPageNumInMemory //this parameter is not required as we are maintaining a ivar for lowestPageNumInMemory and updating it in this method
{
    if (!self.operationStarted) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.loadRowsAtTopCounterMain++;
        self.loadingAtTop=YES;
        self.loadingAtBottom=NO;
        
        self.lowestPageNumInMemory=self.lowestPageNumInMemory-1;
        
        
        HomeScreenOperation *hso1=[[HomeScreenOperation alloc]init];
        hso1.pageNoReceived=self.lowestPageNumInMemory;
        hso1.pageSizeReceived=IPHONECARS;
        hso1.usersZipReceived=self.zipStr;
        //hso1.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso1];
        self.operationStarted=YES;
    }
    
    
}

-(void)loadRowsAtEnd:(NSNumber *)receivedCurrentPage
{
    if (!self.operationStarted) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        
        self.loadRowsAtEndCounterMain++;
        self.loadingAtBottom=YES;
        self.loadingAtTop=NO;
        
        self.currentPage=[receivedCurrentPage integerValue]+1;
        
        
        HomeScreenOperation *hso1=[[HomeScreenOperation alloc]init];
        hso1.pageNoReceived=self.currentPage;
        hso1.pageSizeReceived=IPHONECARS;
        hso1.usersZipReceived=self.zipStr;
        //hso1.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso1];
        self.operationStarted=YES;
    }
}

-(void)loadFirstPageResults
{
    if (!self.operationStarted) {
        
        

         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //self.tableView.userInteractionEnabled=NO;
        
        //disable updatezip button
        [self.rightBarbutton setEnabled:NO];
        [self.indicator startAnimating];
        //... do your reload or expensive operations
        
        //loading page1
        self.currentPage=1;
        
        HomeScreenOperation *hso1=[[HomeScreenOperation alloc]init];
        hso1.pageNoReceived=self.currentPage;
        hso1.pageSizeReceived=IPHONECARS;
        hso1.usersZipReceived=self.zipStr;
        //hso1.delegate=self;
        [self.CustomTableNSOperationQueue addOperation:hso1];
        self.operationStarted=YES;
        //hso1=nil;
        
    }
}

- (void)loadImagesForOnscreenCells
{
    
    NSArray *visibleCells = [self.collectionView indexPathsForVisibleItems];
    NSArray* sortedIndexPaths = [visibleCells sortedArrayUsingSelector:@selector(compare:)];
    
    NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    
    for (NSIndexPath *ip in sortedIndexPaths)
    {
        PopularCarsCellInfo *pcCellInfo=[self.arrayOfPopularCarsCellInfoObjects objectAtIndex:ip.row];
        PopularCarsCell *cell=(PopularCarsCell *)[self.collectionView cellForItemAtIndexPath:ip];
        
        if (!pcCellInfo.car.hasImage && [[pcCellInfo car] carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",pcCellInfo.car.carid]])
            {
                cell.imageView.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner startAnimating];
                [self startDownloadForCarRecord:pcCellInfo.car forIndexPath:ip forCar:1];
            }
            
        }
        
    }
  
    
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
            
            NSData *data=(NSData *)responseObject;
            
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                record.thumbnailUIImage=image;
                [self downloadDidFinishDownloading:record forImage:image forCar:num];
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            record.failedToDownload=YES;
            [self download:record forCar:num didFailWithError:error];
        }];
        
        
        NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]]; //gives all carids
        
        if (![pendingCarids containsObject:[NSString stringWithFormat:@"%d",record.carid]]) {
            
            [self.downloadsInProgress setObject:operation forKey:[NSString stringWithFormat:@"%d",record.carid]];
            
            [self.homeScreenThumbnailQueue addOperation:operation];
            
        }
    }
}

-(void)deletePreviousResults
{
    
    //if there is already data in the tableview, delete it and continue loading page 1
    //initialize all ivars as in viewdidload or viewwillappear
    //cancel any operrations that might be running
    if ([[self arrayOfPopularCarsCellInfoObjects] count]>0) {
        
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
        NSInteger countOfObjects=[self.arrayOfPopularCarsCellInfoObjects count];
        
        NSIndexSet *indexSetOfCells2Delete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, countOfObjects)];
        
        NSMutableArray *cellIndicesToBeDeleted = [NSMutableArray array];
        
        for (int i=0; i<countOfObjects; i++) {
            NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
            [cellIndicesToBeDeleted addObject:ip2];
        }
        
        
        [self.arrayOfPopularCarsCellInfoObjects removeObjectsAtIndexes:indexSetOfCells2Delete];
        
        __weak PopularCarsViewController *weakSelf=self;
        [self.collectionView performBatchUpdates:^{
            [weakSelf.collectionView deleteItemsAtIndexPaths:cellIndicesToBeDeleted];
        } completion:^(BOOL finished) {
            nil;
        }];
        
        
        
        
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

-(void)validateZip:(NSString *)zipToValidate
{
    //disable screen as user may click on any visible car(if present)
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.collectionView.userInteractionEnabled=NO;
    
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.CustomTableNSOperationQueue addOperation:checkZipCode];
    checkZipCode=nil;
    
}

-(void)showZipInUpdateZipLabel:(NSString *)zipValue
{
    NSString *zipStrToDisplyAccessibilityLabel=nil;
    if(zipValue==nil || [zipValue isEqualToString:@"0"])
    {
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip N/A"]];
        zipStrToDisplyAccessibilityLabel=@"Zip";
        
    }
    else
    {
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip %@",zipValue]];
        zipStrToDisplyAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",zipValue];
    }
    self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
}

#pragma mark - UCE Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSInteger nRows = [self.collectionView numberOfItemsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForItem:i inSection:0];
        
        PopularCarsCellInfo *pcCellInfo=[self.arrayOfPopularCarsCellInfoObjects objectAtIndex:indexPath.item];
        
        if (carNum==1) {
            if (pcCellInfo.car.carid==record.carid) {
                
                PopularCarsCell *cell=(PopularCarsCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.spinner stopAnimating];
                cell.imageView.image=img;
                cell.imageView.alpha=1.0f;
                [cell.imageView setNeedsDisplay];
                
                
                break;
            }
        }
        
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
    
}


- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSInteger nRows = [self.collectionView numberOfItemsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForItem:i inSection:0];
        
        PopularCarsCellInfo *pcCellInfo=[self.arrayOfPopularCarsCellInfoObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (pcCellInfo.car.carid==record.carid) {
                
                PopularCarsCell *cell=(PopularCarsCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.spinner stopAnimating];
                if ([error code]==-1011) { //Error Domain=AFNetworkingErrorDomain Code=-1011 "Expected status code in (200-299), got 404"
                    cell.imageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                }
                else
                {
                    cell.imageView.image=[[UIImage alloc] initWithCGImage:nil]; //[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                }
                cell.imageView.alpha=1.0f;
                [cell.imageView setNeedsDisplay];
                
                
                break;
            }
        }
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
}

#pragma mark - Cancelling, suspending, resuming queues / operations

//this is for cancelling thumbnails only. cancelling normal operations will have bad consequences as this method is called from many places
- (void)cancelAllOperations {
    [self.homeScreenThumbnailQueue cancelAllOperations];
}

#pragma mark - Zip Handling
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

#pragma mark - NavBar Button Handling
-(void)HomeButtonTapped
{
   
    //[self dismissModalViewControllerAnimated:YES];
    UIStoryboard *mainStoryboard;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    }
    else //iPad
    {
        mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard-iPad" bundle:nil];
    }
    
    UINavigationController *initViewController = [mainStoryboard instantiateInitialViewController];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate.window  setRootViewController:initViewController];
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - ViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //declare our class that it will handle cell reuse
    //[self.collectionView registerClass:[PopularCarsCell class] forCellWithReuseIdentifier:@"PopularCarsCellId"];
    
    //self.arrayOfPopularCarsCellObjects=[@[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg",@"8.jpg",@"9.jpg",@"10.jpg",@"11.jpg",@"12.jpg"] mutableCopy];
    
    UIBarButtonItem *LeftBarButtonHome=[[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(HomeButtonTapped)];
    self.navigationItem.leftBarButtonItem=LeftBarButtonHome;
    

    
    
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
    navtitle.text=@"Popular Cars"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;

    
    self.arrayOfPopularCarsCellInfoObjects=[[NSMutableArray alloc] init];
    
    
    
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
    

    //for background image;
    self.collectionView.backgroundView = [CommonMethods backgroundImageOnCollectionView:self.collectionView];
    
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
    
    self.loadingAtBottom=YES;
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
    //[self setupTableViewFooter];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.zipStr=[defaults valueForKey:@"homeZipValue"];
    
    NSString *zipStrToDisply=nil;
    NSString *zipStrToDisplyAccessibilityLabel=nil;
    
    if(self.zipStr!=nil)
    {
        zipStrToDisply=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        zipStrToDisplyAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        
    }
    else
    {
        zipStrToDisply=@"Zip N/A";
        zipStrToDisplyAccessibilityLabel=@"Zip";
        
    }
    self.rightBarbutton=[[UIBarButtonItem alloc]initWithTitle:zipStrToDisply style:UIBarButtonItemStyleBordered target:self action:@selector(updateZip)];
    
    //accessibility
    self.rightBarbutton.isAccessibilityElement=YES;
    self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
    self.navigationItem.rightBarButtonItem=self.rightBarbutton;
    
    self.operationStarted=NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    
    //check if zip is already present in userdefaults. If not present, then get it from GPS
    
    if (self.zipStr==nil) {
        //disable zip barbutton first and enable it again after receiving result
        self.rightBarbutton.enabled=NO;
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
    
    self.blockOperation1 = [NSBlockOperation new];
    self.blockOperation2 = [NSBlockOperation new];
    
    self.blockOperationLoadingAtTop1=[NSBlockOperation new];
    self.blockOperationLoadingAtTop2=[NSBlockOperation new];
    
    
    }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noResultsForThisZipNotifMethod:) name:@"NoResultsForThisZipNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(errorFindingLocationNotifMethod:) name:@"ErrorFindingLocationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(workingArrayFromHomeScreenOperationNotifMethod:) name:@"WorkingArrayFromHomeScreenOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(homeScreenOperationFailedNotifMethod:) name:@"HomeScreenOperationFailedNotif" object:nil];
    
    [self.indicator stopAnimating];
    
    self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if(self.currentPage==0)
    {
        //[self setupTableViewFooter];
        
        //disable zip barbutton first and enable it again after receiving result
        self.rightBarbutton.enabled=NO;
        
        //call findcurrentzip class to get zip
        FindCurrentZip *tempFindZip=[[FindCurrentZip alloc]init];
        self.findZip=tempFindZip;
        self.findZip.delegate=self;
        [self.findZip FindingZipCode];
        tempFindZip=nil;
    }
    else if(self.currentPage==1 && IsEmpty(self.arrayOfPopularCarsCellInfoObjects) && self.zipStr!=nil && !self.operationStarted) //i.e., user moved to other screen even before first page cars are displayed, and then came back to this screen again
    {
        self.operationStarted=NO;
        [self loadFirstPageResults];
    }
    else if(self.currentPage==1 && IsEmpty(self.arrayOfPopularCarsCellInfoObjects) && self.zipStr!=nil && self.operationStarted) //i.e., user moved to other screen even before first page cars are displayed, and then came back to this screen again
    {
        //self.operationStarted=NO;
        [self loadFirstPageResults];
    }
    else
    {
        [self loadImagesForOnscreenCells];
    }
    
    //for handling interrruption of first 5 page downloads
    NSInteger maxPagesToShowAtATime;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        maxPagesToShowAtATime=5;
    } else {
        maxPagesToShowAtATime=15;
    }
    
    if (self.arrayOfPopularCarsCellInfoObjects.count && ceilf(self.arrayOfPopularCarsCellInfoObjects.count/IPHONECARS)<maxPagesToShowAtATime && ceilf(self.arrayOfPopularCarsCellInfoObjects.count/IPHONECARS)+1<=self.totalPages && !self.operationStarted) //(!self.operationStarted) //if item is greater than 9*2 and less than 36*2. i.e., user moved to another screen even before first 5 pages are downloaded and came back to this screen again
    {
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                
                self.userScrolledToBottom=1;
                self.op1=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadRowsAtEnd:) object:[NSNumber numberWithInteger:self.currentPage-1]];
                
                [self.CustomTableNSOperationQueue addOperation:self.op1];
            }
        }
    }
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NoResultsForThisZipNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ErrorFindingLocationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"WorkingArrayFromHomeScreenOperationNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"HomeScreenOperationFailedNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //if user prematurely moves to another tab, remove tableviewfooter and hide activityviewer
    
    self.findZip.delegate=nil;
    //[self updateTableViewFooter];
    if(self.currentPage==1)
    {
        //if there are no cars displayed, then set currentPage = 0. otherwise, let the current page be 1
        if(!IsEmpty(self.arrayOfPopularCarsCellInfoObjects))
        {
            PopularCarsCellInfo *pcCellInfo=[self.arrayOfPopularCarsCellInfoObjects objectAtIndex:0];
            CarRecord *carRecord=[pcCellInfo car];
            
            
            if(carRecord==nil)
            {
                self.currentPage=0;
            }
        }
        else if (IsEmpty(self.arrayOfPopularCarsCellInfoObjects))
        {
            self.operationStarted=NO;
        }
    }
    
    [self cancelAllOperations];
    self.operationStarted=NO;
    
    //call hideactivityviewer if it is still present
    if ([CommonMethods activityViewerStillAnimating:self.view]) {
        [CommonMethods hideActivityViewer:self.view];
    }
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self cancelAllOperations];
    
    for (PopularCarsCellInfo *pcCellInfo in self.arrayOfPopularCarsCellInfoObjects) {
        if (pcCellInfo.car!=nil) {
            if(pcCellInfo.car.hasImage)
            {
                pcCellInfo.car.thumbnailUIImage=nil;
            }
        }
        
    }
}

#pragma mark - CollectionView Data Source Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.arrayOfPopularCarsCellInfoObjects && self.arrayOfPopularCarsCellInfoObjects.count) {
        return self.arrayOfPopularCarsCellInfoObjects.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PopularCarsCell *cell=(PopularCarsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PopularCarsCellId" forIndexPath:indexPath];
    
    if (self.arrayOfPopularCarsCellInfoObjects.count>0)
    {
        
        
        // Configure the cell...
        
        //get CustomCellInfo object and use it to design the custom cell
        
        PopularCarsCellInfo *pcCellInfo=[self.arrayOfPopularCarsCellInfoObjects objectAtIndex:indexPath.item];
        if(pcCellInfo==nil)
            return nil;
        
        
        //code For Placing Dollar Symbol and Comma
        
        NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
        
        // get car record
        if([[pcCellInfo car] carid])
        {
            
            cell.yearLabel.text=[NSString stringWithFormat:@"%d",pcCellInfo.car.year];
            [cell.yearLabel setTextColor:[UIColor whiteColor]];
            
            NSString *priceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:pcCellInfo.car.price]];
            if(pcCellInfo.car.price==0)
            {
                priceVal=@"";
            }
            cell.price.text=priceVal;
            [cell.price setTextColor:[UIColor whiteColor]];
            
            cell.makeModel.text=[self combinedStr:pcCellInfo.car.make model:pcCellInfo.car.model];
            [cell.makeModel setTextColor:[UIColor whiteColor]];
            
            if(pcCellInfo.car.hasImage)
            {
                [cell.spinner stopAnimating];
                cell.imageView.image = pcCellInfo.car.thumbnailUIImage;
                cell.imageView.alpha=1.0f;
                [cell.imageView setNeedsDisplay];
            }
            else if(pcCellInfo.car.failedToDownload)
            {
                [cell.spinner stopAnimating];
                //cell.imageView.image=[UIImage imageNamed:@"tileimage.png"];
                cell.imageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                cell.imageView.alpha=1.0f;
                [cell.imageView setNeedsDisplay];
                
            }
            else
            {
                [cell.spinner startAnimating];
                cell.imageView.image = [[UIImage alloc] initWithCIImage:nil];
                
                if (!self.collectionView.dragging && !self.collectionView.decelerating)
                {
                    [self startDownloadForCarRecord:pcCellInfo.car forIndexPath:indexPath forCar:1];
                    //
                }
                
            }
            
            ///
            cell.imageView.tag=pcCellInfo.car.carid;
            
            
            //accessibility
            cell.imageView.isAccessibilityElement=YES;
            if ([[pcCellInfo car] price]>0) {
                cell.imageView.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@ %d",[[pcCellInfo car] year],[[pcCellInfo car] make],[[pcCellInfo car] model],[[pcCellInfo car] price]];
            } else {
                cell.imageView.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@",[[pcCellInfo car] year],[[pcCellInfo car] make],[[pcCellInfo car] model]];
            }
            
            
        }
        else
        {
            cell.makeModel.text=nil;
            cell.price.text=nil;
            cell.yearLabel.text=nil;
            cell.imageView.image = [[UIImage alloc] initWithCIImage:nil];
            [cell.spinner stopAnimating];
            
        }
        
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        CGSize sizeOfCell=CGSizeMake(IPHONECELLWIDTHFORRESULTS, IPHONECELLHEIGHTFORRESULTS);
        return sizeOfCell;
    } else {
        CGSize sizeOfCell=CGSizeMake(IPADCELLWIDTHFORRESULTS, IPADCELLHEIGHTFORRESULTS);
        return sizeOfCell;
    }
    return CGSizeZero;
}
/*
 - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{}
 - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{}
 */

#pragma mark - CollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSInteger tempTag=gestRecognizer.view.tag;
    
    PopularCarsCellInfo *pcCellInfo=self.arrayOfPopularCarsCellInfoObjects[indexPath.item];
    if (self.carRecordToSendToDetailView!=nil) {
        self.carRecordToSendToDetailView=nil;
    }
    self.carRecordToSendToDetailView=[pcCellInfo car];
    
    
    [self performSegueWithIdentifier:@"DetailViewSegue" sender:nil];
}

#pragma mark - Deleting and Adding Cars

- (void)deleteCarsWithResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)startingIndexPosition totalCarsToDelete:(NSInteger)carsTodelete
{
    NSIndexSet *indexSetOfCellsToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, IPHONECARS)];
    //if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
    [self.arrayOfPopularCarsCellInfoObjects removeObjectsAtIndexes:indexSetOfCellsToDelete];
    //}
    
    
    
    //
    NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i=0; i<IPHONECARS; i++) {
        NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
        [cellIndicesToBeDeleted addObject:ip2];
    }
    
    
    
    
    CGPoint tableviewOffset2=[self.collectionView contentOffset];
    
    CGPoint tempOffset2=tableviewOffset2;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        tempOffset2.y-=(6*IPHONECELLHEIGHTFORRESULTS)+6*10; //10 is default interline spaceing between cells
    } else {
        tempOffset2.y-=(3*IPADCELLHEIGHTFORRESULTS)+3*10; //10 is default interline spaceing between cells
    }
    
    tableviewOffset2=tempOffset2;
    
    @try
    {
        
        [UIView setAnimationsEnabled:NO];
        __weak PopularCarsViewController *weakSelf=self;
        //if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [self.collectionView performBatchUpdates:^{
            
            [weakSelf.collectionView deleteItemsAtIndexPaths:cellIndicesToBeDeleted];
            
        } completion:^(BOOL finished) {
            //nil;
            [weakSelf.collectionView setContentOffset:tableviewOffset2 animated:NO];
            [UIView setAnimationsEnabled:YES];
            
        }];
        //}
  
    }
    @catch (NSException *except)
    {
        NSLog(@"DEBUG: failure to batch update.  %@", except.description);
    }
    
}

- (void)addCarsUsingResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)startingIndexPosition totalCarsToAdd:(NSInteger)carsToAdd
{
    
    //
    NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
    //calculate the [self.arrayOfPopularCarsCellInfoObjects count]. This gives us the number of rows to add in table.
    //NSInteger count1=[self.arrayOfPopularCarsCellInfoObjects count];
    NSInteger count1=[self.collectionView numberOfItemsInSection:0];
    
    //go to last row and add there
    for (int i=count1; i<count1+[mArray count]; i++) {
        NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
        [cellIndicesToAdd addObject:ip2];
    }
    
    [self.arrayOfPopularCarsCellInfoObjects addObjectsFromArray:mArray]; /////
    //
    
    @try {
        __weak PopularCarsViewController *weakSelf=self;
        [self.collectionView performBatchUpdates:^{
            NSLog(@"before inserting items in collection count is %d",[weakSelf.collectionView numberOfItemsInSection:0]);
            [weakSelf.collectionView insertItemsAtIndexPaths:cellIndicesToAdd];
        } completion:^(BOOL finished) {
            //nil;
            NSLog(@"after inserting items in collection count is %d",[weakSelf.collectionView numberOfItemsInSection:0]);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"DEBUG: failure to batch update.  %@", exception.description);
    }
    @finally {
        nil;
    }
    
}

- (void)deleteCarsFromBottomWithResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)lastPageStartingIndex totalCarsToDelete:(NSInteger)carsToDelete
{
    NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] initWithCapacity:1];
    NSIndexSet *indexSet4=nil;

        indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(lastPageStartingIndex, carsToDelete)];
        for (int i=lastPageStartingIndex; i<lastPageStartingIndex+carsToDelete; i++) {
            NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
            [cellIndicesToBeDeleted addObject:ip2];
        }
    
    [self.arrayOfPopularCarsCellInfoObjects removeObjectsAtIndexes:indexSet4];
   
       @try {
        __weak PopularCarsViewController *weakSelf=self;
        [UIView setAnimationsEnabled:NO];
        [self.collectionView performBatchUpdates:^{
            NSLog(@"before deleting from bottom collectionview count=%d",[weakSelf.collectionView numberOfItemsInSection:0]);
            [weakSelf.collectionView deleteItemsAtIndexPaths:cellIndicesToBeDeleted];
        } completion:^(BOOL finished) {
            //nil;
            NSLog(@"after deleting from bottom collectionview count=%d",[weakSelf.collectionView numberOfItemsInSection:0]);
            
            
            [weakSelf.blockOperationLoadingAtTop2 addExecutionBlock:^{
                [weakSelf addCarsAtTopUsingResultArray:mArray startingIndexPosition:0 totalCarsToAdd:IPHONECARS];
            }];
            
            //[weakSelf.blockOperation2 addDependency:self.blockOperation1];
            [self.blockOperationLoadingAtTop2 start];
            weakSelf.blockOperationLoadingAtTop2=nil;
            weakSelf.blockOperationLoadingAtTop2=[NSBlockOperation new];
            
            [UIView setAnimationsEnabled:YES];
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"DEBUG: failure to batch update.  %@", exception.description);
    }
    @finally {
        nil;
    }
    
    //change self.currentPage value appropriately
    self.currentPage--;

}

- (void)addCarsAtTopUsingResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)startingIndexPosition totalCarsToAdd:(NSInteger)carsToAdd
{
    NSIndexSet *indexSetForTopRows = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, IPHONECARS)];
    
    NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
    
    //NSInteger heightForNewRows=108*3;
    //go to first row and add there
    for (int i=0; i<mArray.count; i++) {
        NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
        [cellIndicesToAdd addObject:ip2];
    }
   
    //we have add data at the beginning of array, so use insertObjects:atIndexes method
    NSLog(@"before adding at top to arrayOfPopularCarsCellInfoObjects count=%d",self.arrayOfPopularCarsCellInfoObjects.count);
    [self.arrayOfPopularCarsCellInfoObjects insertObjects:mArray atIndexes:indexSetForTopRows];
    NSLog(@"after adding at top to arrayOfPopularCarsCellInfoObjects count=%d",self.arrayOfPopularCarsCellInfoObjects.count);
    
    CGPoint collectionViewOffset5=self.collectionView.contentOffset;
    
    CGPoint collectionViewOffset6=collectionViewOffset5;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        collectionViewOffset6.y+=(6*IPHONECELLHEIGHTFORRESULTS)+6*10; //10 is default interline spaceing between cells
    } else {
        collectionViewOffset6.y+=(3*IPADCELLHEIGHTFORRESULTS)+3*10; //10 is default interline spaceing between cells
    }
    collectionViewOffset5=collectionViewOffset6;
    
    @try {
        [UIView setAnimationsEnabled:NO];
        __weak PopularCarsViewController *weakSelf=self;
        [self.collectionView performBatchUpdates:^{
            [weakSelf.collectionView insertItemsAtIndexPaths:cellIndicesToAdd];
        } completion:^(BOOL finished) {
            //nil;
            [weakSelf.collectionView setContentOffset:collectionViewOffset5 animated:NO];
            [UIView setAnimationsEnabled:YES];
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"DEBUG: failure to batch update.  %@", exception.description);
    }
    @finally {
        nil;
    }
    
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
        [self.indicator stopAnimating];
    }
    
    NSArray *mArray=[[notif userInfo] valueForKey:@"HomeScreenOperationResultsKey"];
    
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
       PopularCarsCellInfo *pcCellInfo=[mArray objectAtIndex:0];
    CarRecord *car1=[pcCellInfo car];
    //self.totalPages=[[car1 pageCount]integerValue]; //_pageCount field val is getting wrong from service
    self.totalPages=ceil([[car1 totalRecords]integerValue]*1.0/IPHONECARS);
    
    if([mArray count]>0)
    {
        if(self.loadingAtBottom)
        {
            
            NSInteger testCounter=0;
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
                testCounter=self.currentPage-5-self.lowestPageNumInMemory+1;
            } else {
                testCounter=self.currentPage-15-self.lowestPageNumInMemory+1;
            }
            
            if(testCounter>0)
            {
                if (self.currentPage==self.totalPages) { //we have to set lastPageCellsCount when loading at bottom that too when 6th or higher page is retrieved. This is because currentpage will be equal to totalpages when adding first page in reverse order. ie., if total pages to 45, when loading 40th page.
                    self.lastPageCellsCount=[mArray count];
                }
                else
                {
                    self.lastPageCellsCount=IPHONECARS;
                }
                
          
                // if currentPage-lowestPageInMemory >0, we have to first delete the lowestPageInMemory, then add the received data
                __weak PopularCarsViewController *weakSelf=self;
                
                [self.blockOperation1 addExecutionBlock:^{
                    //[weakSelf deleteCarsWithResultArray:mArray startingIndexPosition:0 totalCarsToDelete:weakSelf.lastPageCellsCount]; //startingIndexPosition=0 rowsToDelete: iphone:3
                    [weakSelf addCarsUsingResultArray:mArray startingIndexPosition:0 totalCarsToAdd:[mArray count]];
                }];
                
                [self.blockOperation1 start];
                
                
                [self.blockOperation2 addExecutionBlock:^{
                    //[weakSelf addCarsUsingResultArray:mArray startingIndexPosition:0 totalCarsToAdd:[mArray count]];
                    [weakSelf deleteCarsWithResultArray:mArray startingIndexPosition:0 totalCarsToDelete:weakSelf.lastPageCellsCount]; //startingIndexPosition=0 rowsToDelete: iphone:3
                }];
                
                [self.blockOperation2 addDependency:self.blockOperation1];
                [self.blockOperation2 start];
                self.blockOperation1=nil;
                self.blockOperation1=[NSBlockOperation new];
                
                self.blockOperation2=nil;
                self.blockOperation2=[NSBlockOperation new];
                
                //one page data deleted from top. so lowest page number increased by 1
                //self.lowestPageNumInMemory++;
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
                    self.lowestPageNumInMemory=self.currentPage-5+1;
                } else {
                    self.lowestPageNumInMemory=self.currentPage-15+1;
                }
                
                
                [self loadNextOrPreviousPage];
                
            }
            else
            {
                NSInteger count1=[self.arrayOfPopularCarsCellInfoObjects count];
                
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
                
                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                }
                [self.arrayOfPopularCarsCellInfoObjects addObjectsFromArray:mArray];
              
                @try
                {
                    __weak PopularCarsViewController *weakSelf=self;
                    [self.collectionView performBatchUpdates:^{
                        [weakSelf.collectionView insertItemsAtIndexPaths:cellIndicesToAdd];
                    } completion:^(BOOL finished) {
                        nil;
                    }];
                }
                @catch(NSException *exception)
                {
                    NSLog(@"DEBUG: failure to batch update.  %@", exception.description);
                }
                [self loadNextOrPreviousPage];
            }
        }
        else if(self.loadingAtTop)
        {
            
            NSInteger testCounter=0;
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
                testCounter=self.currentPage-5-self.lowestPageNumInMemory+1;
            } else {
                testCounter=self.currentPage-15-self.lowestPageNumInMemory+1;
            }
            
            if(testCounter>0)
            {
                
                NSInteger lastPageStartingIndex;
                if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
                    lastPageStartingIndex=72; //18*5-18 18 is page size. 5 is total pages for iphone
                } else {
                    lastPageStartingIndex=252; //18*15-18 
                }
                
                
                
                int numberOfCarsToDelete;
                if (self.currentPage==self.totalPages)
                {
                    numberOfCarsToDelete=self.lastPageCellsCount;
                }
                else
                {
                    numberOfCarsToDelete=IPHONECARS;
                }
                __weak PopularCarsViewController *weakSelf=self;
                
                [self.blockOperationLoadingAtTop1 addExecutionBlock:^{
                    [weakSelf deleteCarsFromBottomWithResultArray:mArray startingIndexPosition:lastPageStartingIndex totalCarsToDelete:numberOfCarsToDelete]; //startingIndexPosition=0 rowsToDelete: iphone:3
                }];
                
                [self.blockOperationLoadingAtTop1 start];
                        ///////////////
                self.blockOperationLoadingAtTop1=nil;
                self.blockOperationLoadingAtTop1=[NSBlockOperation new];
                
                [self loadNextOrPreviousPage];
                
                
                
            }
        }
        //}
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
        [self.indicator stopAnimating];
    }
    
    
    self.footerLabel.text =@"Connection Failed ...";
    [self.footerLabel setNeedsDisplay];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //self.tableView.userInteractionEnabled=YES;
    
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    
    if ([error code]==kCFURLErrorNotConnectedToInternet) {
        alert.title=@"No Internet Connection";
        alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
        [self.navigationController popViewControllerAnimated:YES];

    }
    else if([error code]==-1001)
    {
        alert.title=@"Error Occured";
        alert.message=@"The request timed out.";
    }
    else
    {
        alert.title=@"Server Error";
        alert.message=@"UCE Car Finder cannot retrieve data due to server error.";
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
    
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //self.tableView.userInteractionEnabled=YES;
    
    //enable updatezip button
    if (![self.rightBarbutton isEnabled]) {
        [self.rightBarbutton setEnabled:YES];
        [self.indicator stopAnimating];
    }
    
    [self.footerLabel removeFromSuperview];
    
    if (self.currentPage==1) {
        
        //[self setupTableViewHeader];
        
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
        
        if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
            if(self.currentPage>5)
            {
                self.lowestPageNumInMemory=self.currentPage-5+1;
            }
            
        } else {
            if(self.currentPage>15)
            {
                self.lowestPageNumInMemory=self.currentPage-15+1;
            }
            
        }
        
        self.currentPage--;
    }
}

-(void)checkZipCodeNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    
    //remove activityviewer which was show in validatezip method
    self.collectionView.userInteractionEnabled=YES;
    
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
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
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
            alert.message=@"UCE Car Finder cannot retrieve data due to server error.";
        }
        
        self.footerLabel.backgroundColor=[UIColor clearColor];
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
        
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip %@",self.zipStr]];
        NSString *zipStrToDisplyAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
        
        self.operationStarted=NO;
        [self loadFirstPageResults];
    }
}

#pragma mark - Zip Delegates
-(void)errorFindingLocationNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(errorFindingLocationNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.findZip.delegate=nil;
    self.findZip=nil;
    
    //NSLog(@"WIFI Hot Spot error in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    
    NSString *message=nil,*title=nil;
    
    
    self.usersZipCodeFromWiFi=nil;
    self.zipStr=self.usersZipCodeFromWiFi;
    
    title=@"Enter Zip";
    message=@"Enter Zip code to search for cars in your local area or skip to search all.";
    
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
    
    //enable updatezip button
    if (![self.rightBarbutton isEnabled]) {
        [self.rightBarbutton setEnabled:YES];
        [self.indicator stopAnimating];
    }
    
    NSString *message=nil,*title=nil;
    
    if(zipVal!=nil)
    {
        self.usersZipCodeFromWiFi=zipVal;
        self.zipStr=self.usersZipCodeFromWiFi;
    }
    title=@"Enter Zip";
    message=@"Enter Zip code to search for cars in your local area or skip to search all cars.";
    
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

#pragma mark - Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DetailViewSegue"])
    {
        
        DetailView *cardetailview=[segue destinationViewController];
        cardetailview.delegate=self;
        
        //uncomment later
        cardetailview.carRecordFromFirstView=self.carRecordToSendToDetailView;
        self.carRecordToSendToDetailView=nil;
        
        
    }
    
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
    NSArray *visibleCellsIndexPaths=[self.collectionView indexPathsForVisibleItems];
    if (!visibleCellsIndexPaths ||!visibleCellsIndexPaths.count) {
        return;
    }
    NSIndexPath *iPath=[visibleCellsIndexPaths objectAtIndex:0];
    
    
    
    if (!self.collectionViewStopped) {
        [self loadImagesForOnscreenCells];
        self.collectionViewStopped=YES;
    }
    
    NSInteger topReachLimit,bottomReachLimit;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        topReachLimit=17; //approx of IPHONECARS*1-1 (ending of first page)
        bottomReachLimit=70; //approx of IPHONECARS*4-2 (beginning of last page)
    } else {
        topReachLimit=17; //IPHONECARS*5
        bottomReachLimit=228; //IPHONECARS*11-x
    }
    if (iPath.item<=topReachLimit && !self.operationStarted) { //currentOffset<=3*122
       // NSLog(@"we are at the top. iPath.item=%d",iPath.item);
        //call loadRowsAtTop. send it self.lowestPageNumInMemory
        //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
        if(self.loadRowsAtTopCounterMain==1)
            if(self.lowestPageNumInMemory>1)
            {
                self.userScrolledToTop=1;
                self.op2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadRowsAtTop:) object:[NSNumber numberWithInteger:self.lowestPageNumInMemory]];
                
                [self.CustomTableNSOperationQueue addOperation:self.op2];
            }
    }
    else if (iPath.item>=bottomReachLimit && !self.operationStarted) {//12 is 4 pages*3 cells per page(for tableview)
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                NSLog(@"calling first op at bottom");
                
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
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self cancelAllOperations];
    self.collectionViewStopped=NO;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2
    
    if (!decelerate) {
        [self loadImagesForOnscreenCells]; //this line is not getting executed. check on device
        
    }
}

#pragma mark - AlertView Delegate
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
            //[self updateTableViewHeader];
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

#pragma mark - DetailView Delegate Method

-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord
{
    
    //get all visible indexpaths
    NSArray *visibleIPaths=[self.collectionView indexPathsForVisibleItems];
    PopularCarsCellInfo *cci;
    
    for (NSIndexPath *ip in visibleIPaths) {
        cci=[self.arrayOfPopularCarsCellInfoObjects objectAtIndex:ip.row];
        
        if ([[cci car] carid]==[aRecord carid]) {
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:ip]];
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
    
}

@end
