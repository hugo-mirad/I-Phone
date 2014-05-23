//
//  PreferenceResultsTable.m
//  UCE
//
//  Created by Mac on 18/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceResultsTable.h"
#import "PreferenceResultsTableCell.h"
#import "CarRecord.h"
#import "PreferenceResultsTableCellInfo.h"
#import "DetailView.h"
#import "GetPreferenceCars.h"
#import "AFNetworking.h"
#import "AppDelegate.h"


@interface  PreferenceResultsTable()

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

@property(strong,nonatomic) CarRecord *carRecordToSendToDetailView;

@property(strong,nonatomic) UILabel *footerLabel;
@property(strong,nonatomic) UIActivityIndicatorView *activityIndicator;

@property(assign,nonatomic) NSInteger loadRowsAtEndCounterMain,loadRowsAtTopCounterMain,totalPages,userScrolledToTop,userScrolledToBottom;

@property(assign,nonatomic) BOOL tableviewStopped;

@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;

@property(strong,nonatomic) UIImageView *activityImageView;

@property(strong,nonatomic) UILabel *headerLabel;

@property(strong,nonatomic) UIBarButtonItem *rightBarbutton;

@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(assign,nonatomic) BOOL operationStarted;

- (void)setupTableViewFooter;
- (void)updateTableViewFooter;

- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;

- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

- (void)loadImagesForOnscreenCells;
- (void)cancelAllOperations;
@end

@implementation PreferenceResultsTable
@synthesize prefNameReceived=_prefNameReceived;

@synthesize arrayOfPreferenceTableCells=_arrayOfPreferenceTableCells,preferenceResultsTableNSOperationQueue=_preferenceResultsTableNSOperationQueue,initialLoadRowsAtEndCounter1=_initialLoadRowsAtEndCounter1,initialLoadRowsAtEndCounter2=_initialLoadRowsAtEndCounter2,initialLoadRowsAtEndCounter3=_initialLoadRowsAtEndCounter3,initialLoadRowsAtEndCounter4=_initialLoadRowsAtEndCounter4,currentPage=_currentPage,loadingAtTop=_loadingAtTop,loadingAtBottom=_loadingAtBottom,loadRowsAtEndCounter=_loadRowsAtEndCounter,loadRowsAtTopCounter=_loadRowsAtTopCounter,lowestPageNumInMemory=_lowestPageNumInMemory,lastPageCellsCount=_lastPageCellsCount,makeIdToSend=_makeIdToSend,modelIdToSend=_modelIdToSend,mileageToSend=_mileageToSend,priceToSend=_priceToSend,yearToSend=_yearToSend,zipToSend=_zipToSend,pageSizeToSend=_pageSizeToSend,gestureRecognizer1=_gestureRecognizer1,gestureRecognizer2=_gestureRecognizer2,gestureRecognizer3=_gestureRecognizer3,op1=_op1,op2=_op2,carRecordToSendToDetailView=_carRecordToSendToDetailView,footerLabel=_footerLabel,activityIndicator=_activityIndicator,loadRowsAtEndCounterMain=_loadRowsAtEndCounterMain,loadRowsAtTopCounterMain=_loadRowsAtTopCounterMain,tableviewStopped=_tableviewStopped,downloadsInProgress=_downloadsInProgress;


@synthesize totalPages=_totalPages,userScrolledToTop=_userScrolledToTop,userScrolledToBottom=_userScrolledToBottom,activityImageView=_activityImageView,headerLabel=_headerLabel,rightBarbutton=_rightBarbutton;

@synthesize preferenceResultsThumbnailQueue=_preferenceResultsThumbnailQueue,showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel;

@synthesize operationStarted=_operationStarted;

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
    
    for (PreferenceResultsTableCellInfo *prtCellInfo in self.arrayOfPreferenceTableCells) {
        if (prtCellInfo.car1!=nil) {
            if(prtCellInfo.car1.hasImage)
            {
                prtCellInfo.car1.thumbnailUIImage=nil;
            }
        }
        if (prtCellInfo.car2!=nil) {
            if(prtCellInfo.car2.hasImage)
            {
                prtCellInfo.car2.thumbnailUIImage=nil;
            }
        }
        if (prtCellInfo.car3!=nil) {
            if(prtCellInfo.car3.hasImage)
            {
                prtCellInfo.car3.thumbnailUIImage=nil;
            }
        }
    }
}

-(void)showActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    
    UIImage *tempImage=[UIImage imageWithData:imageData];
    
    self.showActivityViewerImage=tempImage;
    tempImage=nil;
    
    UIImageView *tempActivityImageView=[[UIImageView alloc] initWithImage:self.showActivityViewerImage];
    self.activityImageView = tempActivityImageView;
    tempActivityImageView=nil;
    self.showActivityViewerImage=nil;
    
    self.activityImageView.alpha = 1.0f;
    
    UIActivityIndicatorView *tempActivityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(self.view.frame.size.width / 2 - 12, self.view.frame.size.height / 2 - 12, 24, 24)];
    self.activityWheel=tempActivityWheel;
    
    self.activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleBottomMargin);
    
    [self.activityImageView addSubview:self.activityWheel];
    [self.view addSubview: self.activityImageView];
    
    [self.activityWheel startAnimating];
    
    tempActivityWheel=nil;
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self.activityWheel stopAnimating];
    
    [self.activityWheel removeFromSuperview];
    self.activityWheel=nil;
    
    [self.activityImageView removeFromSuperview];
    self.activityImageView.image=nil;
    self.activityImageView=nil;
    
    self.showActivityViewerImage=nil;
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
        //NSLog(@"after loading 2nd page, current page no is %d",self.currentPage);
        
    }
    else if(self.currentPage==2 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
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
        //NSLog(@"after loading 3rd page, current page no is %d",self.currentPage);
    }
    else if(self.currentPage==3 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
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
        //NSLog(@"after loading 4th page, current page no is %d",self.currentPage);
    }
    else if(self.currentPage==4 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        
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
        //NSLog(@"after loading 5th page, current page no is %d",self.currentPage);
    }
    else if(self.userScrolledToBottom==1 && self.currentPage+1<=self.totalPages && self.loadRowsAtEndCounterMain==2 && !self.operationStarted)
    {
        self.userScrolledToBottom++;
        
        //loading another page
        self.currentPage=self.currentPage+1;
        
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
        //NSLog(@"after loading %dth page, current page no is %d lowestPageNumInMemory=%d",self.currentPage,self.currentPage,self.lowestPageNumInMemory);
    }
    
    else if(self.userScrolledToTop==1 && self.lowestPageNumInMemory>1 && self.loadRowsAtTopCounterMain==2 && !self.operationStarted)
    {
        self.userScrolledToTop++;
        
        //load another page
        self.lowestPageNumInMemory=self.lowestPageNumInMemory-1;
        
        
        GetPreferenceCars *gpcars2=[[GetPreferenceCars alloc]init];
        gpcars2.makeIdReceived=self.makeIdToSend;
        gpcars2.modelIdReceived=self.modelIdToSend;
        gpcars2.mileageReceived=self.mileageToSend;
        gpcars2.priceReceived=self.priceToSend;
        gpcars2.yearReceived=self.yearToSend;
        gpcars2.zipReceived=self.zipToSend;
        gpcars2.pageSizeReceived=self.pageSizeToSend;
        
        gpcars2.pageNoReceived=self.lowestPageNumInMemory;
        [self.preferenceResultsTableNSOperationQueue addOperation:gpcars2];
        self.operationStarted=YES;
        gpcars2=nil;
        //NSLog(@"after loading %dth page, lowestPageNumInMemory is %d",self.lowestPageNumInMemory,self.lowestPageNumInMemory);
        //NSLog(@"after loading %dth page, current page no is %d lowestPageNumInMemory=%d",self.lowestPageNumInMemory,self.currentPage,self.lowestPageNumInMemory);
        
    }
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
}


-(void)loadRowsAtTop:(NSNumber *)receivedLowestPageNumInMemory //this parameter is not required as we are maintaining a ivar for lowestPageNumInMemory and updating it in this method
{
    if (!self.operationStarted)
    {
    self.loadRowsAtTopCounterMain++;
    self.loadingAtTop=YES;
    self.loadingAtBottom=NO;
    
    //background thread to download xml
    //NSLog(@"page number to load when adding previous pages is %d",self.lowestPageNumInMemory-1);
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
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //for background image;
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 122)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    self.tableView.backgroundView = av;
    av=nil;
    
    
    //NSLog(@"prefNameReceived is %@",self.prefNameReceived);
    
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
    
    
    [self setupTableViewFooter];
    self.loadingAtBottom=YES;
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    //get details from dic to send to GetPreferenceCars nsoperation class
    NSDictionary *prefDict=[self getPlistForPreference:self.prefNameReceived];
    //NSLog(@"prefDict in pref results is %@",prefDict);
    self.makeIdToSend=[prefDict objectForKey:@"makeIdSelected"];
    self.modelIdToSend=[prefDict objectForKey:@"modelIdSelected"];
    self.mileageToSend=[prefDict objectForKey:@"mileageSelected"];
    self.priceToSend=[prefDict objectForKey:@"priceIdSelected"];
    self.yearToSend=[prefDict objectForKey:@"yearSelected"];
    self.zipToSend=[prefDict objectForKey:@"zipSelected"];
    
    self.pageSizeToSend=9;
    
    //also to show make,model as title
    NSString *makeName=[prefDict objectForKey:@"makeNameSelected"];
    NSString *modelName=[prefDict objectForKey:@"modelNameSelected"];
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
                        [UIFont boldSystemFontOfSize:14.0f],UITextAttributeFont
                        ,[UIColor whiteColor],UITextAttributeTextColor
                        ,[UIColor blackColor],UITextAttributeTextShadowColor
                        ,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)],UITextAttributeTextShadowOffset
                        , nil];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    self.title= [NSString stringWithFormat:@"%@, %@",makeName,modelName];
    
    self.operationStarted=NO;
    
    if (!self.operationStarted)
    {
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
    //NSLog(@"after loading 1st page, current page no is %d",self.currentPage);
    }
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
    
    [self loadImagesForOnscreenCells];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PreferenceResultsForPreferenceResultsTable" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetPreferenceCarsOperationFailedNotif" object:nil];
    
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
    
    return YES;
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
    if(self.arrayOfPreferenceTableCells && self.arrayOfPreferenceTableCells.count)
    {
        return [self.arrayOfPreferenceTableCells count];
    }
    else
    {
        return 0;
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
        
        __weak PreferenceResultsTable *weakSelf=self;
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            //NSLog(@"download succeeded for car %d",num);
            NSData *data=(NSData *)responseObject;
            
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                record.thumbnailUIImage=image;
                [weakSelf downloadDidFinishDownloading:record forImage:image forCar:num];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            //NSLog(@"download failed for car %d",num);
            record.failedToDownload=YES;
            [weakSelf download:record forCar:num didFailWithError:error];
        }];
        
        
        NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]]; //gives all carids
        
        if (![pendingCarids containsObject:[NSString stringWithFormat:@"%d",record.carid]]) {
            
            [self.downloadsInProgress setObject:operation forKey:[NSString stringWithFormat:@"%d",record.carid]];
            
            [self.preferenceResultsThumbnailQueue addOperation:operation];
            
            //            NSLog(@"carids in queue are %@",[self.downloadsInProgress allKeys]);
        }
        operation=nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PreferenceTableCellIdentifier";
    
    PreferenceResultsTableCell *cell = (PreferenceResultsTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PreferenceResultsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    PreferenceResultsTableCellInfo *cInfo=[self.arrayOfPreferenceTableCells objectAtIndex:indexPath.row];
    
    //code For Placing Dollar Symbol and Comma
    
    NSNumberFormatter *priceFormatter=[[NSNumberFormatter alloc]init];
    [priceFormatter setLocale:[NSLocale currentLocale]];
    [priceFormatter setMaximumFractionDigits:0];
    
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    if([[cInfo car1] carid])
    {
        cell.yearLabel1.text=[NSString stringWithFormat:@"%d",cInfo.car1.year];
        
        NSString *price1Val=[priceFormatter stringFromNumber:[NSNumber numberWithInt:[[cInfo car1] price]]];
        if(cInfo.car1.price==0)
        {
            price1Val=@"";
        }
        
        cell.price1.text=price1Val;
        
        cell.makeModel1.text=[self combinedStr:cInfo.car1.make model:cInfo.car1.model];
        
        //  code to add thumbnail - start
        
        if(cInfo.car1.hasImage)
        {
            [cell.spinner1 stopAnimating];
            cell.imageView1.image = cInfo.car1.thumbnailUIImage;
            [cell.imageView1 setNeedsDisplay];
        }
        else if(cInfo.car1.failedToDownload)
        {
            [cell.spinner1 stopAnimating];
            cell.imageView1.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"tileimage" ofType:@"png"]];
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
                [self startDownloadForCarRecord:cInfo.car1 forIndexPath:indexPath forCar:1];
            }
        }
        
        cell.imageView1.tag=[[cInfo car1] carid];
        
        //        NSLog(@"the tag is %d  %@",cell.imageView1.tag,[car1TempDictionary objectForKey:@"CarUniqueID"]);
        UITapGestureRecognizer *tempGestureRecognizer1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
        self.gestureRecognizer1 = tempGestureRecognizer1;
        tempGestureRecognizer1=nil;
        
        cell.imageView1.userInteractionEnabled = YES;
        [cell.imageView1 addGestureRecognizer:self.gestureRecognizer1];
        //  code to add thumbnail - end
    }
    else
    {
        cell.makeModel1.text=nil;
        cell.price1.text=nil;
        cell.yearLabel1.text=nil;
        cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
        [cell.spinner1 stopAnimating];
        
    }
    
    
    if([[cInfo car2] carid])
    {
        cell.yearLabel2.text=[NSString stringWithFormat:@"%d",cInfo.car2.year];
        
        NSString *price2Val=[priceFormatter stringFromNumber:[NSNumber numberWithInt:[[cInfo car2] price]]];
        if(cInfo.car2.price==0)
        {
            price2Val=@"";
        }
        cell.price2.text=price2Val;
        
        cell.makeModel2.text=[self combinedStr:cInfo.car2.make model:cInfo.car2.model];
        
        //  code to add thumbnail - start
        
        if(cInfo.car2.hasImage)
        {
            [cell.spinner2 stopAnimating];
            cell.imageView2.image = cInfo.car2.thumbnailUIImage;
            [cell.imageView2 setNeedsDisplay];
        }
        else if(cInfo.car2.failedToDownload)
        {
            [cell.spinner2 stopAnimating];
            cell.imageView2.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"tileimage" ofType:@"png"]];
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
                [self startDownloadForCarRecord:cInfo.car2 forIndexPath:indexPath forCar:2];
            }
        }
        
        //cell.imageView1.tag=1;
        cell.imageView2.tag=[[cInfo car2] carid];
        
        //        NSLog(@"the tag is %d  %@",cell.imageView1.tag,[car1TempDictionary objectForKey:@"CarUniqueID"]);
        UITapGestureRecognizer *tempGestureRecognizer2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
        self.gestureRecognizer2 = tempGestureRecognizer2;
        tempGestureRecognizer2=nil;
        
        cell.imageView2.userInteractionEnabled = YES;
        [cell.imageView2 addGestureRecognizer:self.gestureRecognizer2];
        //  code to add thumbnail - end
        
        
        
    }
    else
    {
        cell.makeModel2.text=nil;
        cell.price2.text=nil;
        cell.yearLabel2.text=nil;
        cell.imageView2.image = [[UIImage alloc] initWithCIImage:nil];
        [cell.spinner2 stopAnimating];
    }
    
    if([[cInfo car3] carid])
    {
        cell.yearLabel3.text=[NSString stringWithFormat:@"%d",cInfo.car3.year];
        
        NSString *price3Val=[priceFormatter stringFromNumber:[NSNumber numberWithInt:[[cInfo car3] price]]];
        if(cInfo.car3.price==0)
        {
            price3Val=@"";
        }
        cell.price3.text=price3Val;
        
        cell.makeModel3.text=[self combinedStr:cInfo.car3.make model:cInfo.car3.model];
        
        //  code to add thumbnail - start
        
        if(cInfo.car3.hasImage)
        {
            [cell.spinner3 stopAnimating];
            cell.imageView3.image = cInfo.car3.thumbnailUIImage;
            [cell.imageView3 setNeedsDisplay];
        }
        else if(cInfo.car3.failedToDownload)
        {
            [cell.spinner3 stopAnimating];
            cell.imageView3.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"tileimage" ofType:@"png"]];
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
                [self startDownloadForCarRecord:cInfo.car3 forIndexPath:indexPath forCar:3];
            }
        }
        
        //cell.imageView1.tag=1;
        cell.imageView3.tag=[[cInfo car3] carid];
        
        //        NSLog(@"the tag is %d  %@",cell.imageView1.tag,[car1TempDictionary objectForKey:@"CarUniqueID"]);
        UITapGestureRecognizer *tempGestureRecognizer3=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClicked:)];
        self.gestureRecognizer3 = tempGestureRecognizer3;
        tempGestureRecognizer3=nil;
        
        cell.imageView3.userInteractionEnabled = YES;
        [cell.imageView3 addGestureRecognizer:self.gestureRecognizer3];
        //  code to add thumbnail - end
    }
    else
    {
        cell.makeModel3.text=nil;
        cell.price3.text=nil;
        cell.yearLabel3.text=nil;
        cell.imageView3.image = [[UIImage alloc] initWithCIImage:nil];
        [cell.spinner3 stopAnimating];
    }
    
    priceFormatter=nil;   
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122.0;
}

#pragma mark -
#pragma mark UCE Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        PreferenceResultsTableCellInfo *prtci=[self.arrayOfPreferenceTableCells objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (prtci.car1.carid==record.carid) {
                
                PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=img;
                [cell.imageView1 setNeedsDisplay];
                
                //NSLog(@"image updated for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                break;
            }
        }
        else if (carNum==2) {
            if (prtci.car2.carid==record.carid) {
                
                PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner2 stopAnimating];
                cell.imageView2.image=img;
                [cell.imageView2 setNeedsDisplay];
                
                //NSLog(@"image updated for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                break;
            }
        }
        else if (carNum==3) {
            if (prtci.car3.carid==record.carid) {
                
                PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner3 stopAnimating];
                cell.imageView3.image=img;
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
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        PreferenceResultsTableCellInfo *prtci=[self.arrayOfPreferenceTableCells objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (prtci.car1.carid==record.carid) {
                
                PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                //cell.imageView1.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
                [cell.imageView1 setNeedsDisplay];
                
                //NSLog(@"image failed for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
        else if (carNum==2) {
            if (prtci.car2.carid==record.carid) {
                
                PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner2 stopAnimating];
                //cell.imageView2.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView2.image=[[UIImage alloc] initWithCIImage:nil];
                [cell.imageView2 setNeedsDisplay];
                
                //NSLog(@"image failed for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
        else if (carNum==3) {
            if (prtci.car3.carid==record.carid) {
                
                PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner3 stopAnimating];
                //cell.imageView3.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView3.image=[[UIImage alloc] initWithCIImage:nil];
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


#pragma mark -
#pragma mark ScrollView Methods

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


-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //ensure that the end of scroll is fired
    //    NSLog(@"scrollViewDidScroll called. cancelPreviousPerformRequestsWithTarget executed.");
    
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //scroll view has stopped scrolling
    //    NSLog(@"scrollViewDidEndDecelerating called.");
    
    //now check if we are at bottom
    
    
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
                //NSLog(@"calling first op from top");
                self.userScrolledToTop=1;
                NSInvocationOperation *tempOp2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadRowsAtTop:) object:[NSNumber numberWithInteger:self.lowestPageNumInMemory]];
                self.op2=tempOp2;
                tempOp2=nil;
                [self.preferenceResultsTableNSOperationQueue addOperation:self.op2];
            }
    }
    
    // Change 132.0 to adjust the distance from bottom
    else if (iPath.row>=12 && !self.operationStarted) {
        //NSLog(@"we are at the end");
            if(self.loadRowsAtEndCounterMain==1)
            {
                //            NSLog(@" inside this if loadRowsAtEndCounterMain");
                if(self.currentPage+1<=self.totalPages)
                {
                    //call loadRowsAtEnd. send it current (higgest) page no.
                    //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                    
                    //NSLog(@"calling first op");
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
    //    NSLog(@"scrollViewDidEndScrollingAnimation called.");
    
    //for controlling image downloading
    //    if (!self.tableView.dragging && !self.tableView.decelerating)
    
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:nil afterDelay:0.3];
    
    [self snapBottomCell];
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
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    NSArray* sortedIndexPaths = [visibleRows sortedArrayUsingSelector:@selector(compare:)];
    
    NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    
    for (NSIndexPath *ip in sortedIndexPaths)
    {
        //        NSLog(@"visibleRows are %d",ip.row);
        
        PreferenceResultsTableCellInfo *prtci=[self.arrayOfPreferenceTableCells objectAtIndex:ip.row];
        PreferenceResultsTableCell *cell=(PreferenceResultsTableCell *)[self.tableView cellForRowAtIndexPath:ip];
        
        
        
        if (!prtci.car1.hasImage && [[prtci car1] carid]) {
            
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",prtci.car1.carid]])
            {
                cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner1 startAnimating];
                [self startDownloadForCarRecord:prtci.car1 forIndexPath:ip forCar:1];
            }    
            
        } 
        //
        if (!prtci.car2.hasImage && [[prtci car2] carid]) {
            
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",prtci.car2.carid]])
            {
                cell.imageView2.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner2 startAnimating];
                [self startDownloadForCarRecord:prtci.car2 forIndexPath:ip forCar:2];
            }
            
        }  
        //
        if (!prtci.car3.hasImage && [[prtci car3] carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",prtci.car3.carid]])
            {
                cell.imageView3.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner3 startAnimating];
                [self startDownloadForCarRecord:prtci.car3 forIndexPath:ip forCar:3];
            }
            
        }
    }
}


-(void)imageViewClicked:(UITapGestureRecognizer*)gestRecognizer
{
    
    NSInteger tempTag=gestRecognizer.view.tag;
    //    NSLog(@"The tag to send is %d",gestRecognizer.view.tag);
    
    for (PreferenceResultsTableCellInfo *prtCellInfo in self.arrayOfPreferenceTableCells) {
        
        CarRecord *cr1=[prtCellInfo car1];
        CarRecord *cr2=[prtCellInfo car2];
        CarRecord *cr3=[prtCellInfo car3];
        
        
        if (cr1!=nil) {
            
            if (tempTag == [cr1 carid]) {
                
                self.carRecordToSendToDetailView=[prtCellInfo car1];
            }
        }
        
        if (cr2!=nil) {
            if (tempTag == [cr2 carid]) {
                self.carRecordToSendToDetailView=[prtCellInfo car2];
            }
        }
        
        if (cr3!=nil) {
            if (tempTag == [cr3 carid]) {
                self.carRecordToSendToDetailView=[prtCellInfo car3];
            }
        }
        
    }
    
    [self performSegueWithIdentifier:@"PreferenceResultsSegue" sender:nil];
}


#pragma mark -
#pragma mark Prepare For Segue


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PreferenceResultsSegue"])
    {
        
        DetailView *cardetailview=[segue destinationViewController];
        cardetailview.delegate=self;
        
        cardetailview.carRecordFromFirstView=self.carRecordToSendToDetailView;
        cardetailview.fromPreferenceResults=YES;
        cardetailview.prefNameFromPrefResultsTable=self.prefNameReceived;
        
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
    label=nil;
    [headerView addSubview:self.headerLabel];
    
    self.tableView.tableHeaderView = headerView;
    headerView=nil;
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
    label.textColor = [UIColor blackColor];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text=@"loading ...";
    
    self.footerLabel = label;
    label=nil;
    [footerView addSubview:self.footerLabel];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    activityIndicatorView=nil;
    
    self.tableView.tableFooterView = footerView;
    footerView=nil;
}

- (void)updateTableViewFooter 
{
    if ([self.arrayOfPreferenceTableCells count] > 9) 
    {
        self.footerLabel.text =@"loading...";
    } else if ([self.arrayOfPreferenceTableCells count] <= 9)
    {
        [self.footerLabel removeFromSuperview];
    }
    
    [self.footerLabel setNeedsDisplay];
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
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=self;
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
        //alert.message=[error description];
        alert.message=@"UCE cannot retreive data due to server error.";
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
    [self updateTableViewFooter];
    
    NSArray *mArray=[[notif userInfo]valueForKey:@"prefCarsArrayKey"];
    //NSLog(@"mArray count in side preferenceResultsNotifMethod =%d",[mArray count]);
    /*
     
     //    test whether proper data is received
     
     for (CustomCellInfo *cci in mArray) {
     
     NSLog(@"Carid is =%d price is =%d thumbnail url is = %@",cci.car1.carid,cci.car1.price,cci.car1.imagePath);
     
     NSLog(@"Carid is =%d price is =%d thumbnail url is = %@",cci.car2.carid,cci.car2.price,cci.car2.imagePath);
     
     NSLog(@"Carid is =%d price is =%d thumbnail url is = %@",cci.car3.carid,cci.car3.price,cci.car3.imagePath);
     }
     */
    
    PreferenceResultsTableCellInfo *pCellInfo=[mArray objectAtIndex:0];
    CarRecord *car1=[pCellInfo car1];
    //self.totalPages=[[car1 pageCount]integerValue];
    self.totalPages=ceil([[car1 totalRecords]integerValue]*1.0/9.0);
    
    
    if([mArray count]>0)
        if(self.loadingAtBottom)
        {
            [self updateTableViewHeader];           
            
            //        NSLog(@"loaing at bottom");
            [self updateTableViewFooter];
            [self.activityIndicator stopAnimating];
            
            NSInteger testCounter=0;
            testCounter=self.currentPage-5-self.lowestPageNumInMemory+1;
            //NSLog(@"self.currentPage=%d testCounter=%d",self.currentPage,testCounter);
            if(testCounter>0)
            {
                if (self.currentPage==self.totalPages) { //we have to set lastPageCellsCount when loading at bottom that too when 6th or higher page is retrieved. This is because currentpage will be equal to totalpages when adding first page in reverse order. ie., if total pages to 45, when loading 40th page.
                    self.lastPageCellsCount=[mArray count];
                }
                else
                {
                    self.lastPageCellsCount=3;
                }
                
                CGPoint tableviewOffset2=[self.tableView contentOffset];
                CGPoint tempOffset=tableviewOffset2;
                tempOffset.y-=122*3;
                tableviewOffset2=tempOffset;

                // if currentPage-lowestPageInMemory >0, we have to first delete the lowestPageInMemory, then add the received data
                
                NSIndexSet *indexSet1 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
                
                [self.arrayOfPreferenceTableCells removeObjectsAtIndexes:indexSet1];
                //
                
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
                
                //one page data deleted from top. so lowest page number increased by 1
                self.lowestPageNumInMemory++;               
                
                //
                [self.arrayOfPreferenceTableCells addObjectsFromArray:mArray];
                
                NSMutableArray *cellIndicesToAdd=[[NSMutableArray alloc] initWithCapacity:1];
                                //calculate the [self.arrayOfAllCustomCellInfoObjects count]. This gives us the number of rows to add in table.
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
            //NSLog(@"self.currentPage=%d testCounter=%d",self.currentPage,testCounter);
            if(testCounter>0)
            {
                NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] init];
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
                
                
                
                [self.arrayOfPreferenceTableCells removeObjectsAtIndexes:indexSet4];
                
                
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView deleteRowsAtIndexPaths:cellIndicesToBeDeleted withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                //    NSLog(@"no of rows after endupdates is %d",[self.tableView numberOfRowsInSection:0]);
                
                //change self.currentPage value appropriately
                self.currentPage--;
                
                ///////////////
                
                NSIndexSet *indexSet3 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
                //            NSLog(@"index set to add %@",indexSet3);
                
                NSMutableArray *cellIndicesToAdd=[[NSMutableArray alloc] initWithCapacity:1];
               
                
                NSInteger heightForNewRows=122*3;
                //go to first row and add there
                for (int i=0; i<3; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                }
                
                
                //we have add data at the beginning of array, so use insertObjects:atIndexes method
                [self.arrayOfPreferenceTableCells insertObjects:mArray atIndexes:indexSet3];
                
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


#pragma mark - Detailview Delegate Method

-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord
{
    //NSLog(@"thumbnailDidDownloadedInDetailView called");
    
    //get all visible indexpaths
    NSArray *visibleIPaths=[self.tableView indexPathsForVisibleRows];
    PreferenceResultsTableCellInfo *cInfo;
    
    for (NSIndexPath *ip in visibleIPaths) {
        cInfo=[self.arrayOfPreferenceTableCells objectAtIndex:ip.row];
        
        if ([[cInfo car1] carid]==[aRecord carid]||[[cInfo car2] carid]==[aRecord carid]||[[cInfo car3] carid]==[aRecord carid]) {
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationNone];
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
    _carRecordToSendToDetailView=nil;
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
