//
//  PreferenceResultsTable.m
//  UCE
//
//  Created by Mac on 18/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceResultsViewController.h"
#import "PreferenceResultsCollectionCell.h"

#import "CarRecord.h"
#import "PreferenceResultsCollectionCellInfo.h"
#import "DetailView.h"
#import "GetPreferenceCars.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "CommonMethods.h"


#define IPHONECELLWIDTHFORRESULTS 100

#define IPHONECELLHEIGHTFORRESULTS 108

#define IPADCELLWIDTHFORRESULTS 108

#define IPADCELLHEIGHTFORRESULTS 124

#define IPHONECARS 18


@interface  PreferenceResultsViewController()

@property(strong,nonatomic) NSMutableArray *arrayOfPreferenceTableCells;

@property(strong,nonatomic) NSOperationQueue *preferenceResultsTableNSOperationQueue,*preferenceResultsThumbnailQueue;

//loading 2 at a  time
@property(assign,nonatomic) NSInteger initialLoadRowsAtEndCounter1,initialLoadRowsAtEndCounter2,initialLoadRowsAtEndCounter3,initialLoadRowsAtEndCounter4;

@property(assign,nonatomic) NSInteger currentPage;

@property(assign,nonatomic) BOOL loadingAtTop,loadingAtBottom;

@property(assign,nonatomic) NSInteger loadRowsAtEndCounter,loadRowsAtTopCounter,lowestPageNumInMemory,lastPageCellsCount;

@property(copy,nonatomic) NSString *makeIdToSend,*modelIdToSend,*mileageToSend,*priceToSend,*yearToSend,*zipToSend;
@property(assign,nonatomic) NSInteger pageSizeToSend;

@property(strong,nonatomic) UITapGestureRecognizer *gestureRecognizer1,*gestureRecognizer2,*gestureRecognizer3;

@property(strong,nonatomic) NSInvocationOperation *op1,*op2;


@property(strong,nonatomic) UILabel *footerLabel;
@property(strong,nonatomic) UIActivityIndicatorView *activityIndicator;

@property(assign,nonatomic) NSInteger loadRowsAtEndCounterMain,loadRowsAtTopCounterMain,totalPages,userScrolledToTop,userScrolledToBottom;
@property(assign,nonatomic) NSInteger prefResultsCountReceived;//--

@property(assign,nonatomic) BOOL tableviewStopped,viewAppeared;

@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;

@property(strong,nonatomic) UIImageView *activityImageView;

@property(strong,nonatomic) UILabel *headerLabel;

@property(strong,nonatomic) UIBarButtonItem *rightBarbutton;

@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(assign,nonatomic) BOOL operationStarted;

@property(strong,nonatomic) NSBlockOperation *blockOperation1,*blockOperation2,*blockOperationLoadingAtTop1,*blockOperationLoadingAtTop2;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;


//- (void)setupTableViewFooter;
//- (void)updateTableViewFooter;

- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;

- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

- (void)loadImagesForOnscreenCells;
- (void)cancelAllOperations;
@end

@implementation PreferenceResultsViewController
@synthesize prefNameReceived=_prefNameReceived;

@synthesize arrayOfPreferenceTableCells=_arrayOfPreferenceTableCells,preferenceResultsTableNSOperationQueue=_preferenceResultsTableNSOperationQueue,initialLoadRowsAtEndCounter1=_initialLoadRowsAtEndCounter1,initialLoadRowsAtEndCounter2=_initialLoadRowsAtEndCounter2,initialLoadRowsAtEndCounter3=_initialLoadRowsAtEndCounter3,initialLoadRowsAtEndCounter4=_initialLoadRowsAtEndCounter4,currentPage=_currentPage,loadingAtTop=_loadingAtTop,loadingAtBottom=_loadingAtBottom,loadRowsAtEndCounter=_loadRowsAtEndCounter,loadRowsAtTopCounter=_loadRowsAtTopCounter,lowestPageNumInMemory=_lowestPageNumInMemory,lastPageCellsCount=_lastPageCellsCount,makeIdToSend=_makeIdToSend,modelIdToSend=_modelIdToSend,mileageToSend=_mileageToSend,priceToSend=_priceToSend,yearToSend=_yearToSend,zipToSend=_zipToSend,pageSizeToSend=_pageSizeToSend,gestureRecognizer1=_gestureRecognizer1,gestureRecognizer2=_gestureRecognizer2,gestureRecognizer3=_gestureRecognizer3,op1=_op1,op2=_op2,footerLabel=_footerLabel,activityIndicator=_activityIndicator,loadRowsAtEndCounterMain=_loadRowsAtEndCounterMain,loadRowsAtTopCounterMain=_loadRowsAtTopCounterMain,tableviewStopped=_tableviewStopped,downloadsInProgress=_downloadsInProgress;

@synthesize prefResultsCountReceived = _prefResultsCountReceived;
@synthesize totalPages=_totalPages,userScrolledToTop=_userScrolledToTop,userScrolledToBottom=_userScrolledToBottom,activityImageView=_activityImageView,headerLabel=_headerLabel,rightBarbutton=_rightBarbutton;

@synthesize preferenceResultsThumbnailQueue=_preferenceResultsThumbnailQueue,showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel;

@synthesize operationStarted=_operationStarted;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [self cancelAllOperations];
    
    for (PreferenceResultsCollectionCellInfo *prtCellInfo in self.arrayOfPreferenceTableCells) {
        if (prtCellInfo.car!=nil) {
            if(prtCellInfo.car.hasImage)
            {
                prtCellInfo.car.thumbnailUIImage=nil;
            }
        }
    }
}

-(void)showActivityViewer
{
    
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
    self.indicator.color = [UIColor redColor];
    
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.indicator stopAnimating];

}

-(void)loadNextOrPreviousPage
{
 
    
    if(self.currentPage==1 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //loading page2
        
        GetPreferenceCars *gpcars2=[[GetPreferenceCars alloc]init];
        gpcars2.makeIdReceived=self.makeIdToSend;
        gpcars2.modelIdReceived=self.modelIdToSend;
        gpcars2.mileageReceived=self.mileageToSend;
        gpcars2.priceReceived=self.priceToSend;
        gpcars2.yearReceived=self.yearToSend;
        gpcars2.zipReceived=self.zipToSend;
        gpcars2.pageSizeReceived=self.pageSizeToSend;
        
        gpcars2.pageNoReceived=self.currentPage;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars2];
        self.operationStarted=YES;
        gpcars2=nil;
        
    }
    else if(self.currentPage==2 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //loading page3
        
        
        GetPreferenceCars *gpcars3=[[GetPreferenceCars alloc]init];
        gpcars3.makeIdReceived=self.makeIdToSend;
        gpcars3.modelIdReceived=self.modelIdToSend;
        gpcars3.mileageReceived=self.mileageToSend;
        gpcars3.priceReceived=self.priceToSend;
        gpcars3.yearReceived=self.yearToSend;
        gpcars3.zipReceived=self.zipToSend;
        gpcars3.pageSizeReceived=self.pageSizeToSend;
        
        gpcars3.pageNoReceived=self.currentPage;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars3];
        self.operationStarted=YES;
        gpcars3=nil;
    }
    else if(self.currentPage==3 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //loading page4
        
        GetPreferenceCars *gpcars4=[[GetPreferenceCars alloc]init];
        gpcars4.makeIdReceived=self.makeIdToSend;
        gpcars4.modelIdReceived=self.modelIdToSend;
        gpcars4.mileageReceived=self.mileageToSend;
        gpcars4.priceReceived=self.priceToSend;
        gpcars4.yearReceived=self.yearToSend;
        gpcars4.zipReceived=self.zipToSend;
        gpcars4.pageSizeReceived=self.pageSizeToSend;
        
        gpcars4.pageNoReceived=self.currentPage;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars4];
        self.operationStarted=YES;
        gpcars4=nil;
    }
    else if(self.currentPage==4 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        GetPreferenceCars *gpcars5=[[GetPreferenceCars alloc]init];
        gpcars5.makeIdReceived=self.makeIdToSend;
        gpcars5.modelIdReceived=self.modelIdToSend;
        gpcars5.mileageReceived=self.mileageToSend;
        gpcars5.priceReceived=self.priceToSend;
        gpcars5.yearReceived=self.yearToSend;
        gpcars5.zipReceived=self.zipToSend;
        gpcars5.pageSizeReceived=self.pageSizeToSend;
        
        gpcars5.pageNoReceived=self.currentPage;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars5];
        self.operationStarted=YES;
        gpcars5=nil;
    }
    
    else if(self.currentPage>=5 && self.currentPage<=14 && (self.currentPage+1)<=self.totalPages && !self.operationStarted && (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad))
    {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        GetPreferenceCars *gpcars6=[[GetPreferenceCars alloc]init];
        gpcars6.pageNoReceived=self.currentPage;
        
        gpcars6.makeIdReceived=self.makeIdToSend;
        gpcars6.modelIdReceived=self.modelIdToSend;
        gpcars6.mileageReceived=self.mileageToSend;
        gpcars6.priceReceived=self.priceToSend;
        gpcars6.yearReceived=self.yearToSend;
        gpcars6.zipReceived=self.zipToSend;
        gpcars6.pageSizeReceived=self.pageSizeToSend;
        
        //gpcars6.pageNoReceived=self.lowestPageNumInMemory;
        
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars6];
        self.operationStarted=YES;
        
    }
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
}


-(void)loadRowsAtTop:(NSNumber *)receivedLowestPageNumInMemory //this parameter is not required as we are maintaining a ivar for lowestPageNumInMemory and updating it in this method
{
    if (!self.operationStarted)
    {
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        self.loadRowsAtTopCounterMain++;
        self.loadingAtTop=YES;
        self.loadingAtBottom=NO;
        
        //background thread to download xml
        self.lowestPageNumInMemory=self.lowestPageNumInMemory-1;
        
        GetPreferenceCars *gpcars1=[[GetPreferenceCars alloc]init];
        gpcars1.makeIdReceived=self.makeIdToSend;
        gpcars1.modelIdReceived=self.modelIdToSend;
        gpcars1.mileageReceived=self.mileageToSend;
        gpcars1.priceReceived=self.priceToSend;
        gpcars1.yearReceived=self.yearToSend;
        gpcars1.zipReceived=self.zipToSend;
        gpcars1.pageSizeReceived=self.pageSizeToSend;
        
        gpcars1.pageNoReceived=self.lowestPageNumInMemory;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars1];
        self.operationStarted=YES;
        gpcars1=nil;
    }
}

-(void)loadRowsAtEnd:(NSNumber *)receivedCurrentPage
{
    if (!self.operationStarted)
    {
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.loadRowsAtEndCounterMain++;
        self.loadingAtBottom=YES;
        self.loadingAtTop=NO;
        
        //background thread to download xml
        self.currentPage=[receivedCurrentPage integerValue]+1;
        
        GetPreferenceCars *gpcars1=[[GetPreferenceCars alloc]init];
        gpcars1.makeIdReceived=self.makeIdToSend;
        gpcars1.modelIdReceived=self.modelIdToSend;
        gpcars1.mileageReceived=self.mileageToSend;
        gpcars1.priceReceived=self.priceToSend;
        gpcars1.yearReceived=self.yearToSend;
        gpcars1.zipReceived=self.zipToSend;
        gpcars1.pageSizeReceived=self.pageSizeToSend;
        
        gpcars1.pageNoReceived=self.currentPage;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars1];
        self.operationStarted=YES;
        gpcars1=nil;
    }
    
}

-(NSDictionary *)getPlistForPreference:(NSString *)prefName
{
    //get pref from cache dir
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",prefName];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    NSMutableDictionary *carDictionaryToRead=nil;
    if (success)
    {
        carDictionaryToRead=[[NSMutableDictionary alloc] initWithContentsOfFile:writablePath];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ Not Found",prefName] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
    return carDictionaryToRead;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSMutableArray *tempArrayOfPreferenceTableCells=[[NSMutableArray alloc]init];
    self.arrayOfPreferenceTableCells=tempArrayOfPreferenceTableCells;
    tempArrayOfPreferenceTableCells=nil;
    
    // [self.collectionView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //for background image;
    //self.collectionView.backgroundView = [CommonMethods backgroundImageOnCollectionView:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    NSOperationQueue *tempPreferenceResultsTableNSOperationQueue=[[NSOperationQueue alloc]init];
    self.preferenceResultsTableNSOperationQueue=tempPreferenceResultsTableNSOperationQueue;
    tempPreferenceResultsTableNSOperationQueue=nil;
    [self.preferenceResultsTableNSOperationQueue setName:@"PreferenceResultsTableQueue"];
    [self.preferenceResultsTableNSOperationQueue setMaxConcurrentOperationCount:3];
    
    NSOperationQueue *tempPreferenceResultsThumbnailQueue=[[NSOperationQueue alloc]init];
    self.preferenceResultsThumbnailQueue=tempPreferenceResultsThumbnailQueue;
    tempPreferenceResultsThumbnailQueue=nil;
    [self.preferenceResultsThumbnailQueue setName:@"PreferenceResultsThumbnailQueue"];
    [self.preferenceResultsThumbnailQueue setMaxConcurrentOperationCount:3];
    
    NSMutableDictionary *tempDownloadsInProgress=[[NSMutableDictionary alloc]init];
    self.downloadsInProgress=tempDownloadsInProgress;
    tempDownloadsInProgress=nil;
    
    
    //[self setupTableViewFooter];
    self.loadingAtBottom=YES;
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
    
    
    //get details from dic to send to GetPreferenceCars nsoperation class
    NSDictionary *prefDict=[self getPlistForPreference:self.prefNameReceived];
    self.makeIdToSend=[prefDict objectForKey:@"makeIdSelected"];
    self.modelIdToSend=[prefDict objectForKey:@"modelIdSelected"];
    self.mileageToSend=[prefDict objectForKey:@"mileageSelected"];
    self.priceToSend=[prefDict objectForKey:@"priceIdSelected"];
    self.yearToSend=[prefDict objectForKey:@"yearSelected"];
    self.zipToSend=[prefDict objectForKey:@"zipSelected"];
    
    self.pageSizeToSend=IPHONECARS;
    //also to show make,model as title
    NSString *makeName=[prefDict objectForKey:@"makeNameSelected"];
    NSString *modelName=[prefDict objectForKey:@"modelNameSelected"];
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    

     navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=[NSString stringWithFormat:@"%@, %@",makeName,modelName]; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    
    
    UIImage* image3 = [UIImage imageNamed:@"BackAll.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width/2-20, image3.size.height/2-20);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(backToResultsButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    
    UIBarButtonItem *lb= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem =lb;
    lb=nil;
    

    
    self.operationStarted=NO;
    
    self.blockOperation1 = [NSBlockOperation new];
    self.blockOperation2 = [NSBlockOperation new];
    
    self.blockOperationLoadingAtTop1=[NSBlockOperation new];
    self.blockOperationLoadingAtTop2=[NSBlockOperation new];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    
    
    if (!self.operationStarted)
    {
        //[NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //loading page1
        self.initialLoadRowsAtEndCounter1=1;
        GetPreferenceCars *getPreferenceCars1=[[GetPreferenceCars alloc]init];
        
        getPreferenceCars1.makeIdReceived=self.makeIdToSend;
        getPreferenceCars1.modelIdReceived=self.modelIdToSend;
        getPreferenceCars1.mileageReceived=self.mileageToSend;
        getPreferenceCars1.priceReceived=self.priceToSend;
        getPreferenceCars1.yearReceived=self.yearToSend;
        getPreferenceCars1.zipReceived=self.zipToSend;
        getPreferenceCars1.pageSizeReceived=self.pageSizeToSend;
        
        getPreferenceCars1.pageNoReceived=self.currentPage;
        
        [self.preferenceResultsTableNSOperationQueue addOperation:getPreferenceCars1];
        self.operationStarted=YES;
        getPreferenceCars1=nil;
    }
    

}
-(void)backToResultsButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self cancelAllOperations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(preferenceResultsNotifMethod:) name:@"PreferenceResultsForPreferenceResultsTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPreferenceCarsOperationFailedNotifMethod:) name:@"GetPreferenceCarsOperationFailedNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countOfSearchResultsNotifMethod:) name:@"CountOfSearchResultsNotif" object:nil];
    
    
    
    if(self.currentPage==1 && IsEmpty(self.arrayOfPreferenceTableCells) && !self.operationStarted) //i.e., user moved to other screen even before first page cars are displayed, and then came back to this screen again
    {
        self.operationStarted=NO;
        //[self loadFirstPageResults];
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
    
    //for handling interrruption of first 5 page downloads
    if (self.arrayOfPreferenceTableCells.count && ceilf(self.arrayOfPreferenceTableCells.count/IPHONECARS)<maxPagesToShowAtATime && ceilf(self.arrayOfPreferenceTableCells.count/IPHONECARS)+1<=self.totalPages && !self.operationStarted) //(!self.operationStarted) //if item is greater than 9 and less than 36. i.e., user moved to another screen even before first 5 pages are downloaded and came back to this screen again
    {
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                self.userScrolledToBottom=1;
                self.op1=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadRowsAtEnd:) object:[NSNumber numberWithInteger:self.currentPage-1]];
                
                [self.preferenceResultsTableNSOperationQueue addOperation:self.op1];
            }
        }
    }
    
}
-(void)countOfSearchResultsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(countOfSearchResultsNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }

    if (self.currentPage==1) {
        [self hideActivityViewer];
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }

    
    self.operationStarted=NO;
    
    [self.footerLabel removeFromSuperview];
    
    
    self.prefResultsCountReceived=[[[notif userInfo] valueForKey:@"CountOfSearchResults"]integerValue];
    
    if (self.prefResultsCountReceived==0 && self.currentPage==1) {
        
        //[self setupTableViewHeader];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Cars Found" message:@"Please choose different Make/Model." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self popViewControllerBack];
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
#pragma mark - Private Methods

- (void)popViewControllerBack
{
    if (self.viewAppeared) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSDate *d = [NSDate dateWithTimeIntervalSinceNow: 0.3f];
        NSTimer *t = [[NSTimer alloc] initWithFireDate: d
                                              interval: 1
                                                target: self
                                              selector:@selector(popViewControllerBackFromTimer:)
                                              userInfo:nil repeats:YES];
        
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:t forMode: NSDefaultRunLoopMode];
        
        t=nil;
    }
}

- (void)popViewControllerBackFromTimer:(NSTimer *)timer
{
    if (self.viewAppeared) {
        
        [timer invalidate];
        [self.navigationController popViewControllerAnimated:YES];
    }
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PreferenceResultsForPreferenceResultsTable" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetPreferenceCarsOperationFailedNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self cancelAllOperations];
    self.operationStarted=NO;
    
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    return YES;
}


#pragma mark - Collection view data source


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if(self.arrayOfPreferenceTableCells && self.arrayOfPreferenceTableCells.count)
    {
        return [self.arrayOfPreferenceTableCells count];
    }
    else
    {
        return 0;
    }
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    PreferenceResultsCollectionCell *cell=(PreferenceResultsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PreferenceResultsCellID" forIndexPath:indexPath];
    
    // Configure the cell...
    PreferenceResultsCollectionCellInfo *cInfo=[self.arrayOfPreferenceTableCells objectAtIndex:indexPath.item];
    
    //code For Placing Dollar Symbol and Comma
    
    NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
    
    
    if([[cInfo car] carid])
    {
        cell.yearLabel.text=[NSString stringWithFormat:@"%d",cInfo.car.year];
        
        NSString *price1Val=[priceFormatter stringFromNumber:[NSNumber numberWithInt:[[cInfo car] price]]];
        if(cInfo.car.price==0)
        {
            price1Val=@"";
        }
        
        cell.price.text=price1Val;
        
        cell.makeModel.text=[self combinedStr:cInfo.car.make model:cInfo.car.model];
        
        //  code to add thumbnail - start
        
        if(cInfo.car.hasImage)
        {
            [cell.spinner stopAnimating];
            cell.imageView.image = cInfo.car.thumbnailUIImage;
            [cell.imageView setNeedsDisplay];
        }
        else if(cInfo.car.failedToDownload)
        {
            [cell.spinner stopAnimating];
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
                [self startDownloadForCarRecord:cInfo.car forIndexPath:indexPath forCar:1];
            }
        }
        
        cell.imageView.tag=[[cInfo car] carid];
        
        
        //accessibility
        cell.imageView.isAccessibilityElement=YES;
        if ([[cInfo car] price]>0) {
            cell.imageView.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@ %d",[[cInfo car] year],[[cInfo car] make],[[cInfo car] model],[[cInfo car] price]];
        } else {
            cell.imageView.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@",[[cInfo car] year],[[cInfo car] make],[[cInfo car] model]];
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
    
    cell.spinner.color = [UIColor grayColor];
    
    
    
    return cell;
    
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        CGSize sizeOfCell=CGSizeMake(100, 108);
        return sizeOfCell;
    } else {
        CGSize sizeOfCell=CGSizeMake(108, 124);
        return sizeOfCell;
    }
    return CGSizeZero;
}

#pragma mark - Private Methods

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
        
        __weak PreferenceResultsViewController *weakSelf=self;
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSData *data=(NSData *)responseObject;
            
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                record.thumbnailUIImage=image;
                [weakSelf downloadDidFinishDownloading:record forImage:image forCar:num];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            record.failedToDownload=YES;
            [weakSelf download:record forCar:num didFailWithError:error];
        }];
        
        
        NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]]; //gives all carids
        
        if (![pendingCarids containsObject:[NSString stringWithFormat:@"%d",record.carid]]) {
            
            [self.downloadsInProgress setObject:operation forKey:[NSString stringWithFormat:@"%d",record.carid]];
            
            [self.preferenceResultsThumbnailQueue addOperation:operation];
            
        }
        operation=nil;
    }
}

#pragma mark - MobiCarz Image Download Delegate Methods

- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    NSInteger nRows = [self.collectionView numberOfItemsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForItem:i inSection:0];
        
        PreferenceResultsCollectionCellInfo *prtci=[self.arrayOfPreferenceTableCells objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (prtci.car.carid==record.carid) {
                
                PreferenceResultsCollectionCell *cell=(PreferenceResultsCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.spinner stopAnimating];
                cell.imageView.image=img;
                [cell.imageView setNeedsDisplay];
                
                break;
            }
        }
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
    
}

- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error
{
    NSInteger nRows = [self.collectionView numberOfItemsInSection:0];
    
    NSIndexPath *indexPath;
    
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForItem:i inSection:0];
        
        PreferenceResultsCollectionCellInfo *prtci=[self.arrayOfPreferenceTableCells objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (prtci.car.carid==record.carid) {
                
                PreferenceResultsCollectionCell *cell=(PreferenceResultsCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.spinner stopAnimating];
                if ([error code]==-1011) { //Error Domain=AFNetworkingErrorDomain Code=-1011 "Expected status code in (200-299), got 404"
                    cell.imageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                }
                else
                {
                    cell.imageView.image=[[UIImage alloc] initWithCGImage:nil]; //[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                }
                cell.imageView.alpha=1.0f;
                //cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
                [cell.imageView setNeedsDisplay];
                
                
                break;
            }
        }
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
    
    
}


#pragma mark - CollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // NSString *imageName=self.arrayOfAllSearchResultsCustomCellInfoObjects[indexPath.item];
    
    PreferenceResultsCollectionCellInfo *cInfo=self.arrayOfPreferenceTableCells[indexPath.item];
    
    CarRecord *record=[cInfo car];
    
    [self performSegueWithIdentifier:@"PreferenceResultsSegue" sender:record];
    
}




#pragma mark - ScrollView Methods

- (void)snapBottomCell
{
    
}


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
    
    //now check if we are at bottom
    NSArray *visibleItemsIndexPaths=[self.collectionView indexPathsForVisibleItems];
    if (!visibleItemsIndexPaths ||!visibleItemsIndexPaths.count) {
        return;
    }
    NSIndexPath *iPath=[visibleItemsIndexPaths objectAtIndex:0];
    
    
	//[self snapBottomCell];
    
    
    if (!self.tableviewStopped) {
        [self loadImagesForOnscreenCells];
        self.tableviewStopped=YES;
    }
    
    NSInteger topReachLimit,bottomReachLimit;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        topReachLimit=17; //approx of IPHONECARS*1-1 (ending of first page)
        bottomReachLimit=70; //approx of IPHONECARS*4-2 (beginning of last page)
    } else {
        topReachLimit=17; //IPHONECARS*5
        bottomReachLimit=228; //IPHONECARS*11-x
    }
    
    if (iPath.row<=topReachLimit && !self.operationStarted) { //currentOffset<=3*122
        //call loadRowsAtTop. send it self.lowestPageNumInMemory
        //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
        if(self.loadRowsAtTopCounterMain==1)
            if(self.lowestPageNumInMemory>1)
            {
                self.userScrolledToTop=1;
                NSInvocationOperation *tempOp2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadRowsAtTop:) object:[NSNumber numberWithInteger:self.lowestPageNumInMemory]];
                self.op2=tempOp2;
                tempOp2=nil;
                [self.preferenceResultsTableNSOperationQueue addOperation:self.op2];
            }
    }
    
    // Change 132.0 to adjust the distance from bottom
    else if (iPath.row>=bottomReachLimit && !self.operationStarted) {
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                self.userScrolledToBottom=1;
                NSInvocationOperation *tempOp1=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadRowsAtEnd:) object:[NSNumber numberWithInteger:self.currentPage]];
                self.op1=tempOp1;
                tempOp1=nil;
                [self.preferenceResultsTableNSOperationQueue addOperation:self.op1];
                
            }
        }
    }
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:nil afterDelay:0.3];
    
    //for controlling image downloading
    
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:nil afterDelay:0.3];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self cancelAllOperations];
    self.tableviewStopped=NO;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [self loadImagesForOnscreenCells]; //this line is not getting executed. check on device
    }
}


#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)cancelAllOperations {
    [self.preferenceResultsThumbnailQueue cancelAllOperations];
}


- (void)loadImagesForOnscreenCells {
    NSArray *visibleRows = [self.collectionView indexPathsForVisibleItems];
    NSArray* sortedIndexPaths = [visibleRows sortedArrayUsingSelector:@selector(compare:)];
    
    NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    
    for (NSIndexPath *ip in sortedIndexPaths)
    {
        
        PreferenceResultsCollectionCellInfo *prtci=[self.arrayOfPreferenceTableCells objectAtIndex:ip.row];
        PreferenceResultsCollectionCell *cell=(PreferenceResultsCollectionCell *)[self.collectionView cellForItemAtIndexPath:ip];
       
        if (!prtci.car.hasImage && [[prtci car] carid]) {
            
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",prtci.car.carid]])
            {
                cell.imageView.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner startAnimating];
                [self startDownloadForCarRecord:prtci.car forIndexPath:ip forCar:1];
            }
            
        }
    }
}


#pragma mark - Prepare For Segue


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PreferenceResultsSegue"])
    {
        
        DetailView *cardetailview=[segue destinationViewController];
        cardetailview.delegate=self;
        
        CarRecord *record=(CarRecord *)sender;
        cardetailview.carRecordFromFirstView=record;
        cardetailview.fromPreferenceResults=YES;
        cardetailview.prefNameFromPrefResultsTable=self.prefNameReceived;
        
    }
}


#pragma mark - Notif Methods

- (void)getPreferenceCarsOperationFailedNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(getPreferenceCarsOperationFailedNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    NSError *error=[[notif userInfo] valueForKey:@"GetPreferenceCarsOperationFailedNotifKey"];
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    [self hideActivityViewer];
    //self.tableView.userInteractionEnabled=YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=self;
    [alert addButtonWithTitle:@"OK"];
    
    
    if ([error code]==kCFURLErrorNotConnectedToInternet) {
        alert.title=@"No Internet Connection";
        alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
    }
    else if([error code]==-1001)
    {
        alert.title=@"Error Occured";
        alert.message=@"The request timed out.";
    }
    else
    {
        alert.title=@"Server Error";
        //alert.message=[error description];
        alert.message=@"MobiCarz cannot retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
    
    if(self.currentPage==1)
    {
        self.currentPage=0;
    }
    
    //[self popViewControllerBack];
    
}

-(void)preferenceResultsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(preferenceResultsNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    [self hideActivityViewer];
    //self.tableView.userInteractionEnabled=YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //[self updateTableViewFooter];
    
    NSArray *mArray=[[notif userInfo]valueForKey:@"prefCarsArrayKey"];
    
    PreferenceResultsCollectionCellInfo *pCellInfo=[mArray objectAtIndex:0];
    CarRecord *car1=[pCellInfo car];
    //self.totalPages=[[car1 pageCount]integerValue];
    self.totalPages=ceil([[car1 totalRecords]integerValue]*1.0/9.0);
    
    
    if([mArray count]>0)
    {
        if(self.loadingAtBottom)
        {
            [self.activityIndicator stopAnimating];
            
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
                
                
                
                // if currentPage-lowestPageInMemory >0, we have to first delete the lowestPageInMemory, then add the received data
                __weak PreferenceResultsViewController *weakSelf=self;
                
                [self.blockOperation1 addExecutionBlock:^{
                    [weakSelf addCarsUsingResultArray:mArray startingIndexPosition:0 totalCarsToAdd:[mArray count]];
                }];
                
                [self.blockOperation1 start];
                
                
                [self.blockOperation2 addExecutionBlock:^{
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
                
                NSInteger count1=[self.arrayOfPreferenceTableCells count];
                
                NSMutableArray *cellIndicesToAdd=[[NSMutableArray alloc] initWithCapacity:1];
                
                
                
                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                    
                    
                }
                
                
                [self.arrayOfPreferenceTableCells addObjectsFromArray:mArray];
                
                
                @try
                {
                    __weak PreferenceResultsViewController *weakSelf=self;
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
                __weak PreferenceResultsViewController *weakSelf=self;
                
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
    }
}

#pragma mark - Deleting and Adding Cars

- (void)deleteCarsWithResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)startingIndexPosition totalCarsToDelete:(NSInteger)carsTodelete
{
    NSIndexSet *indexSetOfCellsToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, IPHONECARS)];
    //if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
    [self.arrayOfPreferenceTableCells removeObjectsAtIndexes:indexSetOfCellsToDelete];
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
        __weak PreferenceResultsViewController *weakSelf=self;
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
    //calculate the [self.arrayOfAllSearchResultsCustomCellInfoObjects count]. This gives us the number of rows to add in table.
    //NSInteger count1=[self.arrayOfAllSearchResultsCustomCellInfoObjects count];
    NSInteger count1=[self.collectionView numberOfItemsInSection:0];
    
    
    //go to last row and add there
    for (int i=count1; i<count1+[mArray count]; i++) {
        NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
        [cellIndicesToAdd addObject:ip2];
    }
    
    [self.arrayOfPreferenceTableCells addObjectsFromArray:mArray]; /////
    //
    
    [UIView setAnimationsEnabled:NO];
    @try {
        __weak PreferenceResultsViewController *weakSelf=self;
        [self.collectionView performBatchUpdates:^{
            NSLog(@"before inserting items in collection count is %d",[weakSelf.collectionView numberOfItemsInSection:0]);
            [weakSelf.collectionView insertItemsAtIndexPaths:cellIndicesToAdd];
        } completion:^(BOOL finished) {
            //nil;
            NSLog(@"after inserting items in collection count is %d",[weakSelf.collectionView numberOfItemsInSection:0]);
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


- (void)deleteCarsFromBottomWithResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)lastPageStartingIndex totalCarsToDelete:(NSInteger)carsToDelete
{
    NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] initWithCapacity:1];
    NSIndexSet *indexSet4=nil;
    
    indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(lastPageStartingIndex, carsToDelete)];
    for (int i=lastPageStartingIndex; i<lastPageStartingIndex+carsToDelete; i++) {
        NSIndexPath *ip2=[NSIndexPath indexPathForItem:i inSection:0];
        [cellIndicesToBeDeleted addObject:ip2];
    }
    
    
    NSLog(@"before deleting from bottom arrayOfAllSearchResultsCustomCellInfoObjects count=%d",self.arrayOfPreferenceTableCells.count);
    
    [self.arrayOfPreferenceTableCells removeObjectsAtIndexes:indexSet4];
    NSLog(@"after deleting from bottom arrayOfAllSearchResultsCustomCellInfoObjects count=%d",self.arrayOfPreferenceTableCells.count);
    
    
    @try {
        __weak PreferenceResultsViewController *weakSelf=self;
        [UIView setAnimationsEnabled:NO];
        [self.collectionView performBatchUpdates:^{
            NSLog(@"before deleting from bottom collectionview count=%d",[weakSelf.collectionView numberOfItemsInSection:0]);
            [weakSelf.collectionView deleteItemsAtIndexPaths:cellIndicesToBeDeleted];
        } completion:^(BOOL finished) {
            //nil;
            NSLog(@"after deleting from bottom collectionview count=%d",[weakSelf.collectionView numberOfItemsInSection:0]);
            
            
            [weakSelf.blockOperationLoadingAtTop2 addExecutionBlock:^{
                [weakSelf addCarsAtTopUsingResultArray:mArray startingIndexPosition:0 totalCarsToAdd:IPHONECARS];
                [UIView setAnimationsEnabled:YES];
            }];
            
            //[weakSelf.blockOperation2 addDependency:self.blockOperation1];
            [self.blockOperationLoadingAtTop2 start];
            weakSelf.blockOperationLoadingAtTop2=nil;
            weakSelf.blockOperationLoadingAtTop2=[NSBlockOperation new];
            
            
            
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
    [self.arrayOfPreferenceTableCells insertObjects:mArray atIndexes:indexSetForTopRows];
    
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
        __weak PreferenceResultsViewController *weakSelf=self;
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



#pragma mark - Detailview Delegate Method

-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord
{
    
    //get all visible indexpaths
    NSArray *visibleIPaths=[self.collectionView indexPathsForVisibleItems];
    PreferenceResultsCollectionCellInfo *cInfo;
    
    for (NSIndexPath *ip in visibleIPaths) {
        cInfo=[self.arrayOfPreferenceTableCells objectAtIndex:ip.row];
        
        if ([[cInfo car] carid]==[aRecord carid]) {
            
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:ip]];
        }
    }
    detailView.delegate=nil;
}

#pragma mark - AlertView Delegate Method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PreferenceResultsForPreferenceResultsTable" object:nil];
    [self cancelAllOperations];
    
    _prefNameReceived=nil;
    _arrayOfPreferenceTableCells=nil;
    _preferenceResultsTableNSOperationQueue=nil;
    _preferenceResultsThumbnailQueue=nil;
    _makeIdToSend=nil;
    _modelIdToSend=nil;
    _mileageToSend=nil;
    _priceToSend=nil;
    _yearToSend=nil;
    _zipToSend=nil;
    _gestureRecognizer1=nil;
    _gestureRecognizer2=nil;
    _gestureRecognizer3=nil;
    _op1=nil;
    _op2=nil;
    _footerLabel=nil;
    _activityIndicator=nil;
    _downloadsInProgress=nil;
    _activityImageView=nil;
    _headerLabel=nil;
    _rightBarbutton=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
    
}

@end
