//
//  SearchViewCustomTable.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsCustomTable.h"
#import "SearchViewCustomCell.h"
#import "CarRecord.h"
#import "DetailView.h"
#import "SearchOperation.h"
#import "CheckButton.h"
#import "AFNetworking.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"


@interface SearchResultsCustomTable()

@property(strong,nonatomic) NSMutableArray *arrayOfAllCarRecordObjects;
@property(strong,nonatomic) NSOperationQueue *searchViewCustomTableQueue,*searchResultsThumbnailQueue;

//footer label
@property(strong,nonatomic) UILabel *footerLabel,*headerLabel;
@property(strong,nonatomic) UIImageView *activityImageView;
@property(strong,nonatomic) UIActivityIndicatorView *activityIndicator;


//for pre and post fetching
@property(assign,nonatomic) NSInteger currentPage,totalPages,lowestPageNumInMemory,userScrolledToBottom,userScrolledToTop,loadRowsAtEndCounterMain,loadRowsAtTopCounterMain,lastPageCellsCount;

@property(assign,nonatomic) BOOL loadingAtBottom,loadingAtTop;

@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;
@property(assign,nonatomic) BOOL tableviewStopped,viewAppeared;

@property(strong,nonatomic) NSInvocationOperation *op1,*op2;

@property(assign,nonatomic) CGPoint tableviewOffset2;

@property(assign,nonatomic) NSInteger searchResultsCountReceived;
@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(assign,nonatomic) BOOL operationStarted;


- (void)setupTableViewHeader;
- (void)updateTableViewFooter;
- (void)updateTableViewHeader;

- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;
- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

- (void)cancelAllOperations;
- (void)loadImagesForOnscreenCells;
- (void)popViewControllerBack;
- (void)snapBottomCell;

@end

@implementation SearchResultsCustomTable

@synthesize arrayOfAllCarRecordObjects=_arrayOfAllCarRecordObjects,searchViewCustomTableQueue=_searchViewCustomTableQueue,currentPage=_currentPage,lowestPageNumInMemory=_lowestPageNumInMemory,loadingAtBottom=_loadingAtBottom,loadingAtTop=_loadingAtTop,footerLabel=_footerLabel,activityIndicator=_activityIndicator,lastPageCellsCount=_lastPageCellsCount;

@synthesize tableviewStopped=_tableviewStopped,loadRowsAtEndCounterMain=_loadRowsAtEndCounterMain,loadRowsAtTopCounterMain=_loadRowsAtTopCounterMain,userScrolledToTop=_userScrolledToTop,userScrolledToBottom=_userScrolledToBottom,op1=_op1,op2=_op2,totalPages=_totalPages,activityImageView=_activityImageView,tableviewOffset2=_tableviewOffset2,headerLabel=_headerLabel,downloadsInProgress=_downloadsInProgress;

@synthesize searchResultsCountReceived=_searchResultsCountReceived,searchResultsThumbnailQueue=_searchResultsThumbnailQueue;

@synthesize allMilesSelected=_allMilesSelected,zipReceived=_zipReceived,showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel,viewAppeared=_viewAppeared;

@synthesize makeIdReceived=_makeIdReceived, makeNameReceived=_makeNameReceived, modelIdReceived=_modelIdReceived, modelNameReceived=_modelNameReceived, milesReceived=_milesReceived;

@synthesize operationStarted=_operationStarted;


static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

- (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText
{
    
    float lengthOfSecondString = secondText.length+1; // length of second string including blank space inbetween text, space in front , space after text.. Be careful, your  app may crash here if length is beyond the second text length (lengthOfSecondString = text length + blank spaces)
    
    NSString *finalText;
    if (secondText!=nil) {
        finalText = [NSString stringWithFormat:@"%@ %@",firstText,secondText];
    }
    else
    {
        finalText = firstText;
    }
    
    CATextLayer *myLabelTextLayer;
    /* Create the text layer on demand */
    if (!myLabelTextLayer) {
        myLabelTextLayer = [[CATextLayer alloc] init];
        myLabelTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        myLabelTextLayer.wrapped = YES;
        CALayer *layer = myLabel.layer; //assign layer to your UILabel
        myLabelTextLayer.frame = CGRectMake(0, (layer.bounds.size.height-30)/2 + 10, 300, 30);
        myLabelTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        myLabelTextLayer.alignmentMode = kCAAlignmentLeft;
        layer.sublayers=nil; //remove previous layers, otherwise the contents are getting overlapped
        [layer addSublayer:myLabelTextLayer];
    }
    /* Create the attributes (for the attributed string) */
    // customizing first string
    CGFloat fontSize = [UIFont systemFontSize]; //16
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    CTFontRef ctBoldFont = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    CGColorRef cgColor = [UIColor blackColor].CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    
    
    // customizing second string
    UIFont *font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor = [UIColor blackColor].CGColor;
    NSDictionary *subAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)ctFont, (id)kCTFontAttributeName,cgSubColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctFont);
    /* Create the attributed string (text + attributes) */
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:finalText attributes:attributes];
    
    
    if (secondText!=nil) {
        [attrStr addAttributes:subAttributes range:NSMakeRange(firstText.length, lengthOfSecondString)];
    }
    
    // you can add another subattribute in the similar way as above , if you want change the third textstring style
    /* Set the attributes string in the text layer :) */
    
    myLabelTextLayer.string = attrStr;
    myLabelTextLayer.opacity = 1.0; //to remove blurr effect
    
}


-(void)showActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    
    UIImage *tempImage=[UIImage imageWithData:imageData];
    
    self.showActivityViewerImage=tempImage;
    
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
    self.activityImageView.image=nil;
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
        
        
        SearchOperation *so2=[[SearchOperation alloc]init];
        so2.pageNoReceived=self.currentPage;
        
        so2.makeIdReceived=self.makeIdReceived;
        so2.makeNameReceived=self.makeNameReceived;
        so2.modelIdReceived=self.modelIdReceived;
        so2.modelNameReceived=self.modelNameReceived;
        so2.zipReceived=self.zipReceived;
        so2.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so2];
        self.operationStarted=YES;
        //NSLog(@"after loading 2nd page, current page no is %d",self.currentPage);
        
    }
    else if(self.currentPage==2 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        self.currentPage=self.currentPage+1;
        //loading page3
        
        
        SearchOperation *so3=[[SearchOperation alloc]init];
        so3.pageNoReceived=self.currentPage;
        
        so3.makeIdReceived=self.makeIdReceived;
        so3.makeNameReceived=self.makeNameReceived;
        so3.modelIdReceived=self.modelIdReceived;
        so3.modelNameReceived=self.modelNameReceived;
        so3.zipReceived=self.zipReceived;
        so3.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so3];
        self.operationStarted=YES;
        //NSLog(@"after loading 3rd page, current page no is %d",self.currentPage);
    }
    else if(self.currentPage==3 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        self.currentPage=self.currentPage+1;
        //loading page4
        
        
        SearchOperation *so4=[[SearchOperation alloc]init];
        so4.pageNoReceived=self.currentPage;
        
        so4.makeIdReceived=self.makeIdReceived;
        so4.makeNameReceived=self.makeNameReceived;
        so4.modelIdReceived=self.modelIdReceived;
        so4.modelNameReceived=self.modelNameReceived;
        so4.zipReceived=self.zipReceived;
        so4.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so4];
        self.operationStarted=YES;
        //NSLog(@"after loading 4th page, current page no is %d",self.currentPage);
    }
    else if(self.currentPage==4 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        
        SearchOperation *so5=[[SearchOperation alloc]init];
        so5.pageNoReceived=self.currentPage;
        
        so5.makeIdReceived=self.makeIdReceived;
        so5.makeNameReceived=self.makeNameReceived;
        so5.modelIdReceived=self.modelIdReceived;
        so5.modelNameReceived=self.modelNameReceived;
        so5.zipReceived=self.zipReceived;
        so5.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so5];
        self.operationStarted=YES;
        //NSLog(@"after loading 5th page, current page no is %d",self.currentPage);
        
    }
    else if(self.userScrolledToBottom==1 && self.currentPage+1<=self.totalPages && self.loadRowsAtEndCounterMain==2 && !self.operationStarted)
    {
        self.userScrolledToBottom++;
        
        //loading another page
        //background thread to download xml
        self.currentPage=self.currentPage+1;
        
        
        SearchOperation *so2=[[SearchOperation alloc]init];
        so2.pageNoReceived=self.currentPage;
        
        so2.makeIdReceived=self.makeIdReceived;
        so2.makeNameReceived=self.makeNameReceived;
        so2.modelIdReceived=self.modelIdReceived;
        so2.modelNameReceived=self.modelNameReceived;
        so2.zipReceived=self.zipReceived;
        so2.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so2];
        self.operationStarted=YES;
        //NSLog(@"after loading %dth page, current page no is %d lowestPageNumInMemory=%d",self.currentPage,self.currentPage,self.lowestPageNumInMemory);
    }
    
    else if(self.userScrolledToTop==1 && self.lowestPageNumInMemory>1 && self.loadRowsAtTopCounterMain==2 && !self.operationStarted)
    {
        self.userScrolledToTop++;
        
        //load another page
        self.lowestPageNumInMemory=self.lowestPageNumInMemory-1;
        
        SearchOperation *so2=[[SearchOperation alloc]init];
        so2.pageNoReceived=self.lowestPageNumInMemory;
        
        so2.makeIdReceived=self.makeIdReceived;
        so2.makeNameReceived=self.makeNameReceived;
        so2.modelIdReceived=self.modelIdReceived;
        so2.modelNameReceived=self.modelNameReceived;
        so2.zipReceived=self.zipReceived;
        so2.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so2];
        self.operationStarted=YES;
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
    
    
    SearchOperation *so1=[[SearchOperation alloc]init];
    so1.pageNoReceived=self.lowestPageNumInMemory;
    
    so1.makeIdReceived=self.makeIdReceived;
    so1.makeNameReceived=self.makeNameReceived;
    so1.modelIdReceived=self.modelIdReceived;
    so1.modelNameReceived=self.modelNameReceived;
    so1.zipReceived=self.zipReceived;
    so1.milesReceived=self.milesReceived;
    
    [self.searchViewCustomTableQueue addOperation:so1];
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
    
    
    SearchOperation *so1=[[SearchOperation alloc]init];
    so1.pageNoReceived=self.currentPage;
    
    so1.makeIdReceived=self.makeIdReceived;
    so1.makeNameReceived=self.makeNameReceived;
    so1.modelIdReceived=self.modelIdReceived;
    so1.modelNameReceived=self.modelNameReceived;
    so1.zipReceived=self.zipReceived;
    so1.milesReceived=self.milesReceived;
    
    [self.searchViewCustomTableQueue addOperation:so1];
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
    
    for (CarRecord *cr in self.arrayOfAllCarRecordObjects) {
        if (cr!=nil) {
            if(cr.hasImage)
            {
                cr.thumbnailUIImage=nil;
            }
        }
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    NSLog(@"viewdidload is called");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //for background image;
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 122)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    self.tableView.backgroundView = av;
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
    navtitle.text=@"Search Results";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationItem setTitleView:navtitle];
    navtitle=nil;
    
    
    NSString *zipCodeToDisplay=nil;
    
    if (self.allMilesSelected) {
        zipCodeToDisplay=@"";
    }
    else
    {
        if(IsEmpty(self.zipReceived))
        {
            zipCodeToDisplay=@"";
        }
        else
        {
            zipCodeToDisplay=[NSString stringWithFormat:@"Zip:%@",self.zipReceived];
        }
        
    }
    
    UILabel *rightBarLabel=[[UILabel alloc]init];
    [rightBarLabel setFrame:CGRectMake(0, 0, 80, 40)];
    rightBarLabel.lineBreakMode=UILineBreakModeClip;
    rightBarLabel.text=zipCodeToDisplay;
    [rightBarLabel setTextColor:[UIColor whiteColor]];
    [rightBarLabel setBackgroundColor:[UIColor  clearColor]];
    [rightBarLabel setTextAlignment:UITextAlignmentRight];
    
    UIBarButtonItem *rightBarbutton=[[UIBarButtonItem alloc]initWithCustomView:rightBarLabel];
    
    self.navigationItem.rightBarButtonItem=rightBarbutton;
    
    
    self.arrayOfAllCarRecordObjects=[[NSMutableArray alloc]init];
    
    
    self.searchViewCustomTableQueue=[[NSOperationQueue alloc]init];
    [self.searchViewCustomTableQueue setName:@"SearchResultsCustomTableQueue"];
    [self.searchViewCustomTableQueue setMaxConcurrentOperationCount:1];
    
    self.searchResultsThumbnailQueue=[[NSOperationQueue alloc]init];
    [self.searchResultsThumbnailQueue setName:@"SearchResultsThumbnailQueue"];
    [self.searchResultsThumbnailQueue setMaxConcurrentOperationCount:3];
    
    
    self.downloadsInProgress=[[NSMutableDictionary alloc]init];
    
    self.loadingAtBottom=YES;
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
    self.operationStarted=NO;
        
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(workingArrayFromSearchOperationMethod:) name:@"WorkingArrayFromSearchOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countOfSearchResultsNotifMethod:) name:@"CountOfSearchResultsNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchOperationFailedNotifMethod:) name:@"SearchOperationFailedNotif" object:nil];
    
    [self loadImagesForOnscreenCells];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.viewAppeared=YES;
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WorkingArrayFromSearchOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CountOfSearchResultsNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SearchOperationFailedNotif" object:nil];
    
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
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
    if(self.arrayOfAllCarRecordObjects && self.arrayOfAllCarRecordObjects.count)
    {
        return [self.arrayOfAllCarRecordObjects count];
    }
    else
    {
        return 0;
    }
}


-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num
{
    if (!record.hasImage) {
        NSURL *URL = [NSURL URLWithString:record.imagePath];
        NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
        
        
        AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
        
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            //NSLog(@"downloading");
            if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }];
        
        __weak SearchResultsCustomTable *weakSelf=self;
        
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
            
            [self.searchResultsThumbnailQueue addOperation:operation];
            
            //            NSLog(@"carids in queue are %@",[self.downloadsInProgress allKeys]);
        }
        //operation=nil;
        
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchViewCustomCellIdentifier";
    
    SearchViewCustomCell *cell = (SearchViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[SearchViewCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    CarRecord *cr=[self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
    
    NSString *str=[NSString stringWithFormat:@"%d %@ %@",[cr year],[cr make],[cr model]];
    
    [cell.yearMakeModelLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    cell.yearMakeModelLabel.text=str;
    
    //price formatter
    NSNumberFormatter *priceFormatter=[[NSNumberFormatter alloc]init];
    [priceFormatter setLocale:[NSLocale currentLocale]];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter setCurrencySymbol:@"$"];
    [priceFormatter setMaximumFractionDigits:0];
    
    NSString *priceAsString = [priceFormatter stringFromNumber:[NSNumber numberWithInteger:[cr price]]];
    
    if([cr price] ==0)
    {
        priceAsString=@"";
    }
    //cell.priceLabel.text=priceAsString;
    [cell.priceLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    [self createTwoTextLabel:cell.priceLabel firstText:@"Price:" secondText:priceAsString];
    
    
    
    //mileage formatter
    NSNumberFormatter *mileageFormatter=[[NSNumberFormatter alloc]init];
    [mileageFormatter setLocale:[NSLocale currentLocale]];
    [mileageFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [mileageFormatter setMaximumFractionDigits:0];
    //NSInteger mileageAsInt=[mlcci mileage];
    
    NSString *mileageString = [mileageFormatter stringFromNumber:[NSNumber numberWithInteger:[cr mileage]]];
    
    
    NSString *mileageStringFormatted=[NSString stringWithFormat:@"%@ mi",mileageString];
    if([cr mileage]==0)
    {
        mileageStringFormatted=@"";
    }
    //cell.mileageLabel.text=mileageStringFormatted;
    [cell.mileageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    [self createTwoTextLabel:cell.mileageLabel firstText:@"Mileage:" secondText:mileageStringFormatted];
    
    if(cr.hasImage)
    {
        [cell.spinner1 stopAnimating];
        cell.imageView1.image = cr.thumbnailUIImage;
        [cell.imageView1 setNeedsDisplay];
    }
    else if(cr.failedToDownload)
    {
        [cell.spinner1 stopAnimating];
        
        cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
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
            [self startDownloadForCarRecord:cr forIndexPath:indexPath forCar:1];
        }
    }
    
    priceFormatter=nil;
    mileageFormatter=nil;
    
    return cell;
    
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

#pragma mark -
#pragma mark UCE Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    
    
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CarRecord *cr = [self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cr.carid==record.carid) {
                
                SearchViewCustomCell *cell=(SearchViewCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=img;
                [cell.imageView1 setNeedsDisplay];
                
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
        
        CarRecord *cr = [self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cr.carid==record.carid) {
                
                SearchViewCustomCell *cell=(SearchViewCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                //cell.imageView1.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"titleimage" ofType:@"png"]];
                cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
                [cell.imageView1 setNeedsDisplay];
                
                //NSLog(@"image failed for %@ - %@ - %d carid=%d",record.make,record.model,record.price,record.carid);
                
                break;
            }
        }
    }
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
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

#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)cancelAllOperations {
    [self.searchResultsThumbnailQueue cancelAllOperations];
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenCells
{
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    NSArray* sortedIndexPaths = [visibleRows sortedArrayUsingSelector:@selector(compare:)];
    
    NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    
    for (NSIndexPath *ip in sortedIndexPaths)
    {
        //        NSLog(@"visibleRows are %d",ip.row);
        CarRecord *cr = [self.arrayOfAllCarRecordObjects objectAtIndex:ip.row];
        
        SearchViewCustomCell *cell=(SearchViewCustomCell *)[self.tableView cellForRowAtIndexPath:ip];
        
        if (!cr.hasImage && [cr carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",cr.carid]])
            {
                cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner1 startAnimating];
                [self startDownloadForCarRecord:cr forIndexPath:ip forCar:1];
            }    
        } 
    }
    //    pendingCarids=nil;
    //    visibleRows=nil;
    //    sortedIndexPaths=nil;
}


#pragma mark Scrollview Methods
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
    
    //now check if we are at bottom or top
    
    
	[self snapBottomCell];
    
    
    if (!self.tableviewStopped) {
        [self loadImagesForOnscreenCells];
        self.tableviewStopped=YES;
    }
    
    if ([self.tableView isEditing]) {
        NSLog(@"tableview is in editing mode");
    }
    else
    {
        NSLog(@"tableview is NOT in editing mode");
    }
    
    NSArray *visibleRowsIndexPaths=[self.tableView indexPathsForVisibleRows];
    NSIndexPath *iPath=[visibleRowsIndexPaths objectAtIndex:0];
    
    if (iPath.row<=9 && !self.operationStarted) { //currentOffset<=3*122
        //NSLog(@"we are at the top");
        //call loadRowsAtTop. send it self.lowestPageNumInMemory
        //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
        if(self.loadRowsAtTopCounterMain==1)
            if(self.lowestPageNumInMemory>1)
            {
                //NSLog(@"calling first op at top");
                
                self.userScrolledToTop=1;
                
                self.op2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadRowsAtTop:) object:[NSNumber numberWithInteger:self.lowestPageNumInMemory]];
                
                [self.searchViewCustomTableQueue addOperation:self.op2];
            }
    }
    else if (iPath.row>=36 && !self.operationStarted) {
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
                
                [self.searchViewCustomTableQueue addOperation:self.op1];
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
    //    [self suspendAllOperations];
    [self cancelAllOperations];
    self.tableviewStopped=NO;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2
    if (!decelerate) {
        [self loadImagesForOnscreenCells]; //this line is not getting executed. check on device
        //        [self resumeAllOperations];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchDetailsSegue"]) {
        DetailView *detailView=[segue destinationViewController];
        
        
        NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
        detailView.carRecordFromFirstView=[self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];        
        
        detailView.delegate=self;
        
    }
}
#pragma mark - Notif Methods

- (void)searchOperationFailedNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(searchOperationFailedNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    NSError *error=[[notif userInfo] valueForKey:@"SearchOperationFailedNotifKey"];
    
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
    
}

-(void)workingArrayFromSearchOperationMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(workingArrayFromSearchOperationMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    //    NSLog(@"value received in CustomTable viewcontroller");
    [self hideActivityViewer];
    [self updateTableViewFooter];
    
    NSArray *mArray=[[notif userInfo] valueForKey:@"SearchOperationResults"];
    //NSLog(@"workingArrayFromSearchOperationMethod: %@",[[notif userInfo] valueForKey:@"SearchOperationResults"]);
    /*
    if([[[notif userInfo] valueForKey:@"SearchOperationResults"] isKindOfClass:[NSError class]])
    {
        NSError *error=[[notif userInfo] valueForKey:@"SearchOperationResults"];
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        
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
            //alert.message=[error description];
            alert.message=@"UCE cannot retreive data due to server error.";
        }
        [alert show];
        alert=nil;
        
        [self popViewControllerBack];
        
        return;
    }
*/
    //
    CarRecord *cr=[mArray objectAtIndex:0];
    //self.totalPages=[[car1 pageCount]integerValue]; //_pageCount field val is getting wrong from service
    self.totalPages=ceil([[cr totalRecords]integerValue]*1.0/9.0);
    //NSLog(@"self.totalPages=%d",self.totalPages);
    
    
    
    
    if([mArray count]>0)
        if(self.loadingAtBottom)
        {
            
            CarRecord *car1=[mArray objectAtIndex:0];
            //self.totalPages=[[car1 pageCount]integerValue];
            self.totalPages=ceil([[car1 totalRecords]integerValue]*1.0/9.0);
            
            
            [self updateTableViewHeader];           
            
            //NSLog(@"loaing at bottom");
            [self updateTableViewFooter];
            [self.activityIndicator stopAnimating];
            
            /*
             
             //    test whether proper data is received
             
             for (CustomCellInfo *cci in mArray) {
             
             NSLog(@"Carid is =%d price is =%d thumbnail url is = %@",cci.car1.carid,cci.car1.price,cci.car1.imagePath);
             
             NSLog(@"Carid is =%d price is =%d thumbnail url is = %@",cci.car2.carid,cci.car2.price,cci.car2.imagePath);
             
             NSLog(@"Carid is =%d price is =%d thumbnail url is = %@",cci.car3.carid,cci.car3.price,cci.car3.imagePath);
             }
             */
            //    NSInteger i_receivedCurrentPage=[receivedCurrentPage integerValue];
            //receivedCurrentPage : this parameter is no longer required when calculating indexSet and indexpaths as there will be always 5 pages of data.ie total rows in table will always be 15 and total count of self.table is also 15. However this parameter is required to find the required pages no's data.
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
                    self.lastPageCellsCount=9;
                }
                
                ////////////
                // if currentPage-lowestPageInMemory >0, we have to first delete the lowestPageInMemory, then add the received data
                self.tableviewOffset2=[self.tableView contentOffset];
                CGPoint tempOffset=self.tableviewOffset2;
                tempOffset.y-=122*9;
                self.tableviewOffset2=tempOffset;
                
                
                NSIndexSet *indexSet1 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 9)];
                
                [self.arrayOfAllCarRecordObjects removeObjectsAtIndexes:indexSet1];
                
                NSMutableArray *cellIndicesToBeDeleted = [[NSMutableArray alloc] init];
                
                for (int i=0; i<9; i++) {
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
                [self.tableView setContentOffset:self.tableviewOffset2 animated:NO];
                
                //////////////////
                
                
                //
                //calculate the [self.arrayOfAllCustomCellInfoObjects count]. This gives us the number of rows to add in table.
                NSInteger count1=[self.tableView numberOfRowsInSection:0];
                
                
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
                
                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                    
                }
                
                [self.arrayOfAllCarRecordObjects addObjectsFromArray:mArray];
                
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView setEditing:YES];
                [self.tableView insertRowsAtIndexPaths:cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
                
                [self.tableView endUpdates];
                [self.tableView setEditing:NO];
                [UIView setAnimationsEnabled:YES];
                [self.tableView setContentOffset:self.tableviewOffset2 animated:NO];
                
                
                //one page data deleted from top. so lowest page number increased by 1
                self.lowestPageNumInMemory=self.currentPage-5+1;

                
                [self loadNextOrPreviousPage];
                
            }
            else
            {
                
                NSInteger count1=[self.arrayOfAllCarRecordObjects count];
                
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
                
                
                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                }
                
                [self.arrayOfAllCarRecordObjects addObjectsFromArray:mArray];
                

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
                //we have to delete last 9 rows
                NSMutableArray *cellIndicesToBeDeleted;
                NSIndexSet *indexSet4;
                
                if (self.currentPage==self.totalPages) {
                    NSLog(@"deleting from bottom. current page=totalpages");
                    
                    indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(36, self.lastPageCellsCount)];
                    
                    cellIndicesToBeDeleted = [[NSMutableArray alloc] initWithCapacity:1];
                    
                    for (int i=36; i<36+self.lastPageCellsCount; i++) {
                        NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                        [cellIndicesToBeDeleted addObject:ip2];
                    }
                }
                else
                {
                    NSLog(@"deleting from bottom. current page!=totalpages");
                    
                    indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(36, 9)];
                    
                    cellIndicesToBeDeleted = [[NSMutableArray alloc] init];
                    
                    for (int i=36; i<36+9; i++) {
                        NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                        [cellIndicesToBeDeleted addObject:ip2];
                    }
                }
                
                [self.arrayOfAllCarRecordObjects removeObjectsAtIndexes:indexSet4];
                
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                
                [self.tableView deleteRowsAtIndexPaths:cellIndicesToBeDeleted withRowAnimation:UITableViewRowAnimationNone];
                
                [self.tableView endUpdates];
                [UIView setAnimationsEnabled:YES];
                //    NSLog(@"no of rows after endupdates is %d",[self.tableView numberOfRowsInSection:0]);
                
                //change self.currentPage value appropriately
                self.currentPage--;
                
                ///////////////
                
                NSIndexSet *indexSet3 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 9)];
                //NSLog(@"index set to add %@",indexSet3);
                
                NSMutableArray *cellIndicesToAdd=[[NSMutableArray alloc] initWithCapacity:1];
                
                NSInteger heightForNewRows=122*9;
                //go to first row and add there
                for (int i=0; i<9; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                    //                NSLog(@"heightForNewRows is %d",heightForNewRows);
                }
                
                //we have add data at the beginning of array, so use insertObjects:atIndexes method
                [self.arrayOfAllCarRecordObjects insertObjects:mArray atIndexes:indexSet3];
                
                
                //save current offset
                CGPoint tableviewOffset=[self.tableView contentOffset];
                //            NSLog(@"self.tableView contentOffset y before adding rows=%.2f",tableviewOffset.y);
                
                [UIView setAnimationsEnabled:NO];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
                tableviewOffset.y += heightForNewRows;
                [self.tableView endUpdates];
                [UIView setAnimationsEnabled:YES];
                [self.tableView setContentOffset:tableviewOffset animated:NO];
                
                [self loadNextOrPreviousPage];
            } 
        }
}


-(void)countOfSearchResultsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(countOfSearchResultsNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    self.operationStarted=NO;
    
    [self.footerLabel removeFromSuperview];
    
    
    self.searchResultsCountReceived=[[[notif userInfo] valueForKey:@"CountOfSearchResults"]integerValue];
    
    if (self.searchResultsCountReceived==0 && self.currentPage==1) {
        
        [self setupTableViewHeader];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Cars Found" message:@"Please choose different Make/Model" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self popViewControllerBack];
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

- (void)popViewControllerBack
{
    if (self.viewAppeared) {
        //NSLog(@"popViewControllerBack if condition");
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //NSLog(@"popViewControllerBack if else condition. timer created");
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
        //NSLog(@"popViewControllerBackFromTimer if condition. view finally appeared and now popping back");
        
        [timer invalidate];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

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
    [headerView addSubview:self.headerLabel];
    
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
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text=@"loading...";
    
    self.footerLabel = label;
    [footerView addSubview:self.footerLabel];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    activityIndicatorView=nil;
    [footerView addSubview:self.activityIndicator];
    
    self.tableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter 
{
    if ([self.arrayOfAllCarRecordObjects count] != 0) 
    {
        self.footerLabel.text =@"loading...";
    } else 
    {
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}

#pragma mark - DetailView Delegate Method

-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord
{
    //NSLog(@"thumbnailDidDownloadedInDetailView called");
    
    //get all visible indexpaths
    NSArray *visibleIPaths=[self.tableView indexPathsForVisibleRows];
    CarRecord *cr;
    
    for (NSIndexPath *ip in visibleIPaths) {
        cr=[self.arrayOfAllCarRecordObjects objectAtIndex:ip.row];
        
        if ([cr carid]==[aRecord carid]) {
            
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
    [self cancelAllOperations];
    
    _makeIdReceived=nil;
    _modelIdReceived=nil;
    _zipReceived=nil;
    _milesReceived=nil;
    _makeNameReceived=nil;
    _modelNameReceived=nil;
    _arrayOfAllCarRecordObjects=nil;
   _searchViewCustomTableQueue=nil;
    _searchResultsThumbnailQueue=nil;
    _footerLabel=nil;
    _headerLabel=nil;
    _activityImageView=nil;
    _activityIndicator=nil;
    _downloadsInProgress=nil;
    _op1=nil;
    _op2=nil;
    _showActivityViewerImage=nil;
   _activityWheel=nil;
    
}

@end
