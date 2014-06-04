//
//  SearchViewCustomTable.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "SearchResultsCollectionCell.h"
#import "CarRecord.h"
#import "DetailView.h"
#import "SearchOperation.h"
#import "CheckButton.h"
#import "AFNetworking.h"
#import "CommonMethods.h"


//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"
#import "SearchResultsCollectionCellInfo.h"

#define IPHONECELLWIDTHFORRESULTS 100

#define IPHONECELLHEIGHTFORRESULTS 108

#define IPADCELLWIDTHFORRESULTS 108

#define IPADCELLHEIGHTFORRESULTS 124

#define IPHONECARS 18

@interface SearchResultsViewController()

@property(strong,nonatomic) NSMutableArray *arrayOfAllSearchResultsCustomCellInfoObjects;
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


@property(strong,nonatomic) UIActivityIndicatorView *indicator;

@property(assign,nonatomic) BOOL operationStarted;


@property(nonatomic,strong)UITapGestureRecognizer *gestureRecognizer1,*gestureRecognizer2,*gestureRecognizer3,*spinner1GestureRecognizer,*spinner2GestureRecognizer,*spinner3GestureRecognizer;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

@property(strong,nonatomic) NSBlockOperation *blockOperation1,*blockOperation2,*blockOperationLoadingAtTop1,*blockOperationLoadingAtTop2;



- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;
- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

- (void)cancelAllOperations;
- (void)loadImagesForOnscreenCells;
- (void)popViewControllerBack;
-(NSString *)combinedStr:(NSString *)make model:(NSString *)model;



@end

@implementation SearchResultsViewController

@synthesize arrayOfAllSearchResultsCustomCellInfoObjects=_arrayOfAllSearchResultsCustomCellInfoObjects,searchViewCustomTableQueue=_searchViewCustomTableQueue,currentPage=_currentPage,lowestPageNumInMemory=_lowestPageNumInMemory,loadingAtBottom=_loadingAtBottom,loadingAtTop=_loadingAtTop,footerLabel=_footerLabel,activityIndicator=_activityIndicator,lastPageCellsCount=_lastPageCellsCount;

@synthesize tableviewStopped=_tableviewStopped,loadRowsAtEndCounterMain=_loadRowsAtEndCounterMain,loadRowsAtTopCounterMain=_loadRowsAtTopCounterMain,userScrolledToTop=_userScrolledToTop,userScrolledToBottom=_userScrolledToBottom,op1=_op1,op2=_op2,totalPages=_totalPages,activityImageView=_activityImageView,tableviewOffset2=_tableviewOffset2,headerLabel=_headerLabel,downloadsInProgress=_downloadsInProgress;

@synthesize searchResultsCountReceived=_searchResultsCountReceived,searchResultsThumbnailQueue=_searchResultsThumbnailQueue;

@synthesize allMilesSelected=_allMilesSelected,zipReceived=_zipReceived,viewAppeared=_viewAppeared;

@synthesize makeIdReceived=_makeIdReceived, makeNameReceived=_makeNameReceived, modelIdReceived=_modelIdReceived, modelNameReceived=_modelNameReceived, milesReceived=_milesReceived;

@synthesize operationStarted=_operationStarted;

@synthesize gestureRecognizer1=_gestureRecognizer1,gestureRecognizer2=_gestureRecognizer2,gestureRecognizer3=_gestureRecognizer3,spinner1GestureRecognizer=_spinner1GestureRecognizer,spinner2GestureRecognizer=_spinner2GestureRecognizer,spinner3GestureRecognizer=_spinner3GestureRecognizer;


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


-(void)loadNextOrPreviousPage
{
   
    
   // [self.indicator startAnimating];
    if(self.currentPage==1 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //self.tableView.userInteractionEnabled=NO;
        
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
        
    }
    else if(self.currentPage==2 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
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
    }
    else if(self.currentPage==3 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
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
    }
    else if(self.currentPage==4 && (self.currentPage+1)<=self.totalPages && !self.operationStarted)
    {
    
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
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
        
    }
    else if(self.currentPage>=5 && self.currentPage<=14 && (self.currentPage+1)<=self.totalPages && !self.operationStarted && (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad))
    {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.currentPage=self.currentPage+1;
        //    loading page5
        // no need of initialLoadRowsAtEndCounter5 i think
        
        
        SearchOperation *so6=[[SearchOperation alloc]init];
        so6.pageNoReceived=self.currentPage;
        
        so6.makeIdReceived=self.makeIdReceived;
        so6.makeNameReceived=self.makeNameReceived;
        so6.modelIdReceived=self.modelIdReceived;
        so6.modelNameReceived=self.modelNameReceived;
        so6.zipReceived=self.zipReceived;
        so6.milesReceived=self.milesReceived;
        
        [self.searchViewCustomTableQueue addOperation:so6];
        self.operationStarted=YES;
       
    }
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
}


-(void)loadRowsAtTop:(NSNumber *)receivedLowestPageNumInMemory //this parameter is not required as we are maintaining a ivar for lowestPageNumInMemory and updating it in this method
{
    if (!self.operationStarted) {
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.loadRowsAtTopCounterMain++;
        self.loadingAtTop=YES;
        self.loadingAtBottom=NO;
        
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
        //self.tableView.userInteractionEnabled=NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
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


//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [self cancelAllOperations];
    
    
    
    
    for (SearchResultsCollectionCellInfo *cInfo in self.arrayOfAllSearchResultsCustomCellInfoObjects) {
        CarRecord *car=[cInfo car];
        if (car!=nil) {
            if(car.hasImage)
            {
                car.thumbnailUIImage=nil;
            }
        }
       
            }

    
    
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    
    //for background image;
    self.collectionView.backgroundView = [CommonMethods backgroundImageOnCollectionView:self.collectionView];
    
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-90), 0, 140, 45)];
    navtitle.text=[NSString stringWithFormat:@"%@ %@",self.makeNameReceived,self.modelNameReceived]; //
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        navtitle.textColor=[UIColor  whiteColor];
        
        
    } else {
        navtitle.textColor=[UIColor  colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        //load resources for iOS 7
        
    }
    
    navtitle.textAlignment=NSTextAlignmentRight;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    self.navigationItem.titleView=navtitle;
    navtitle=nil;
    
    
    
    
    
//    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
//    navtitle.text=[NSString stringWithFormat:@"%@ %@",self.makeNameReceived,self.modelNameReceived];
//    navtitle.textAlignment=NSTextAlignmentCenter;
//    navtitle.backgroundColor=[UIColor clearColor];
//    navtitle.textColor=[UIColor  whiteColor];
//    navtitle.font=[UIFont boldSystemFontOfSize:14];
//    [self.navigationItem setTitleView:navtitle];
//    navtitle=nil;
    
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
        else if ([self.zipReceived isEqualToString:@"0"])
        {
            zipCodeToDisplay=@"Zip N/A";
        }
        else
        {
            zipCodeToDisplay=[NSString stringWithFormat:@"Zip %@",self.zipReceived];
        }
        
    }
    
    UILabel *rightBarLabel=[[UILabel alloc]init];
    [rightBarLabel setFrame:CGRectMake(0, 0, 90, 40)];
    rightBarLabel.lineBreakMode=NSLineBreakByClipping;
    rightBarLabel.text=zipCodeToDisplay;
    [rightBarLabel setTextColor:[UIColor whiteColor]];
    [rightBarLabel setBackgroundColor:[UIColor  clearColor]];
    [rightBarLabel setTextAlignment:NSTextAlignmentRight];
    
    UIBarButtonItem *rightBarbutton=[[UIBarButtonItem alloc]initWithCustomView:rightBarLabel];
    
    self.navigationItem.rightBarButtonItem=rightBarbutton;
    
    
    self.arrayOfAllSearchResultsCustomCellInfoObjects=[[NSMutableArray alloc]init];
    
    
    self.searchViewCustomTableQueue=[[NSOperationQueue alloc]init];
    [self.searchViewCustomTableQueue setName:@"SearchResultsCustomTableQueue"];
    [self.searchViewCustomTableQueue setMaxConcurrentOperationCount:1];
    
    self.searchResultsThumbnailQueue=[[NSOperationQueue alloc]init];
    [self.searchResultsThumbnailQueue setName:@"SearchResultsThumbnailQueue"];
    [self.searchResultsThumbnailQueue setMaxConcurrentOperationCount:3];
    
    
    self.downloadsInProgress=[[NSMutableDictionary alloc]init];
    
    self.loadingAtBottom=YES;
    self.currentPage=1;
    self.lowestPageNumInMemory=1;
    
    self.loadRowsAtEndCounterMain=1;
    self.loadRowsAtTopCounterMain=1;
    
    self.operationStarted=NO;
    
    self.blockOperation1 = [NSBlockOperation new];
    self.blockOperation2 = [NSBlockOperation new];
    
    self.blockOperationLoadingAtTop1=[NSBlockOperation new];
    self.blockOperationLoadingAtTop2=[NSBlockOperation new];
    
    [self.indicator startAnimating];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
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
    
    
[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(workingArrayFromSearchOperationMethod:) name:@"WorkingArrayFromSearchOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(countOfSearchResultsNotifMethod:) name:@"CountOfSearchResultsNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(searchOperationFailedNotifMethod:) name:@"SearchOperationFailedNotif" object:nil];
    
    //self.isShowingLandscapeView = NO;
    //[self.indicator stopAnimating];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if(self.currentPage==1 && IsEmpty(self.arrayOfAllSearchResultsCustomCellInfoObjects) && !self.operationStarted) //i.e., user moved to other screen even before first page cars are displayed, and then came back to this screen again
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
    if (self.arrayOfAllSearchResultsCustomCellInfoObjects.count && ceilf(self.arrayOfAllSearchResultsCustomCellInfoObjects.count/IPHONECARS)<maxPagesToShowAtATime && ceilf(self.arrayOfAllSearchResultsCustomCellInfoObjects.count/IPHONECARS)+1<=self.totalPages && !self.operationStarted) //(!self.operationStarted) //if item is greater than 9 and less than 36. i.e., user moved to another screen even before first 5 pages are downloaded and came back to this screen again
    {
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                //NSLog(@"calling first op at bottom");
                
                self.userScrolledToBottom=1;
                self.op1=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadRowsAtEnd:) object:[NSNumber numberWithInteger:self.currentPage-1]];
                
                [self.searchViewCustomTableQueue addOperation:self.op1];
            }
        }
    }
    
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
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
    
    if(self.arrayOfAllSearchResultsCustomCellInfoObjects && self.arrayOfAllSearchResultsCustomCellInfoObjects.count)
    {
        return [self.arrayOfAllSearchResultsCustomCellInfoObjects count];
    }
    
    return 0;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SearchResultsCollectionCell *cell=(SearchResultsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultViewCellId" forIndexPath:indexPath];
    
    //get CustomCellInfo object and use it to design the custom cell
    
    SearchResultsCollectionCellInfo *srccInfo=[self.arrayOfAllSearchResultsCustomCellInfoObjects objectAtIndex:indexPath.item];
    if(srccInfo==nil)
        return nil;
    
    
    //code For Placing Dollar Symbol and Comma
    NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
    
    
    
    
    // get car record
    if([[srccInfo car] carid])
    {
        
        cell.yearLabel.text=[NSString stringWithFormat:@"%d",srccInfo.car.year];
        [cell.yearLabel setTextColor:[UIColor whiteColor]];
        
        NSString *priceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:srccInfo.car.price]];
        if(srccInfo.car.price==0)
        {
            priceVal=@"";
        }
        cell.price.text=priceVal;
        [cell.price setTextColor:[UIColor whiteColor]];
        
        cell.makeModel.text=[self combinedStr:srccInfo.car.make model:srccInfo.car.model];
        [cell.makeModel setTextColor:[UIColor whiteColor]];
        
        if(srccInfo.car.hasImage)
        {
            [cell.spinner stopAnimating];
            cell.imageView.image = srccInfo.car.thumbnailUIImage;
            cell.imageView.alpha=1.0f;
            [cell.imageView setNeedsDisplay];
        }
        else if(srccInfo.car.failedToDownload)
        {
            [cell.spinner stopAnimating];
            //cell.imageView1.image=[UIImage imageNamed:@"tileimage.png"];
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
                [self startDownloadForCarRecord:srccInfo.car forIndexPath:indexPath forCar:1];
                //
            }
        }
        
        ///
        cell.imageView.tag=srccInfo.car.carid;
        
              //accessibility
        cell.imageView.isAccessibilityElement=YES;
        if ([[srccInfo car] price]>0) {
            cell.imageView.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@ %d",[[srccInfo car] year],[[srccInfo car] make],[[srccInfo car] model],[[srccInfo car] price]];
        } else {
            cell.imageView.accessibilityLabel=[NSString stringWithFormat:@"%d %@ %@",[[srccInfo car] year],[[srccInfo car] make],[[srccInfo car] model]];
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


#pragma mark - CollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultsCollectionCellInfo *cInfo=self.arrayOfAllSearchResultsCustomCellInfoObjects[indexPath.item];
    CarRecord *record=[cInfo car];
    [self performSegueWithIdentifier:@"SearchDetailsSegue" sender:record];
}



#pragma mark - Thumbnail Downloading Methods


-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num
{
    if (!record.hasImage) {
        NSURL *URL = [NSURL URLWithString:record.imagePath];
        NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
        
        
        AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
        
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }];
        
        __weak SearchResultsViewController *weakSelf=self;
        
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
            
            [self.searchResultsThumbnailQueue addOperation:operation];
            
        }
        
    }
}


#pragma mark - UCE Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSInteger nRows = [self.collectionView numberOfItemsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForItem:i inSection:0];
        
        SearchResultsCollectionCellInfo *srccInfo=[self.arrayOfAllSearchResultsCustomCellInfoObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (srccInfo.car.carid==record.carid) {
                
                SearchResultsCollectionCell *cell=(SearchResultsCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
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
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        SearchResultsCollectionCellInfo *srccInfo=[self.arrayOfAllSearchResultsCustomCellInfoObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (srccInfo.car.carid==record.carid) {
                
                SearchResultsCollectionCell *cell=(SearchResultsCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.spinner stopAnimating];
                if ([error code]==-1011) { //Error Domain=AFNetworkingErrorDomain Code=-1011 "Expected status code in (200-299), got 404"
                    cell.imageView.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                }
                else
                {
                cell.imageView.image=[[UIImage alloc] initWithCGImage:nil]; //[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"dummycar" ofType:@"png"]];
                }
                cell.imageView.alpha=1.0f;
                cell.imageView.contentMode=UIViewContentModeScaleAspectFit;
                [cell.imageView setNeedsDisplay];
                
                
                break;
            }
        }
       
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
}


#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)cancelAllOperations {
    [self.searchResultsThumbnailQueue cancelAllOperations];
    
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenCells
{
   // [self.indicator startAnimating];
    
    NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
    NSArray* sortedIndexPaths = [visibleItems sortedArrayUsingSelector:@selector(compare:)];
    
    NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    
    for (NSIndexPath *ip in sortedIndexPaths)
    {
        SearchResultsCollectionCellInfo *svcCellInfo=[self.arrayOfAllSearchResultsCustomCellInfoObjects objectAtIndex:ip.row];
        SearchResultsCollectionCell *cell=(SearchResultsCollectionCell *)[self.collectionView cellForItemAtIndexPath:ip];
        
        if (!svcCellInfo.car.hasImage && [[svcCellInfo car] carid]) {
            if(![pendingCarids containsObject:[NSString stringWithFormat:@"%d",svcCellInfo.car.carid]])
            {
                cell.imageView.image = [[UIImage alloc] initWithCIImage:nil];
                [cell.spinner startAnimating];
                [self startDownloadForCarRecord:svcCellInfo.car forIndexPath:ip forCar:1];
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
    
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //scroll view has stopped scrolling
    
    //now check if we are at bottom or top
    
    NSArray *visibleItemsIndexPaths=[self.collectionView indexPathsForVisibleItems];
    if (!visibleItemsIndexPaths ||!visibleItemsIndexPaths.count) {
        return;
    }
    NSIndexPath *iPath=[visibleItemsIndexPaths objectAtIndex:0];
    
    
    
    
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
    if (iPath.item<=topReachLimit && !self.operationStarted) { //currentOffset<=3*122
        //call loadRowsAtTop. send it self.lowestPageNumInMemory
        //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
        if(self.loadRowsAtTopCounterMain==1)
            if(self.lowestPageNumInMemory>1)
            {
                
                self.userScrolledToTop=1;
                
                self.op2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadRowsAtTop:) object:[NSNumber numberWithInteger:self.lowestPageNumInMemory]];
                
                [self.searchViewCustomTableQueue addOperation:self.op2];
            }
    }
    else if (iPath.item>=bottomReachLimit && !self.operationStarted) {
        if(self.loadRowsAtEndCounterMain==1)
        {
            if(self.currentPage+1<=self.totalPages)
            {
                //call loadRowsAtEnd. send it current (higgest) page no.
                //do this operation as a single entity so that if the user starts scrolling again, we can interrrupt this. Use NSInvocatin Operation as we can set dependency if we want
                
                
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
    
    
    [self performSelector:@selector(scrollViewDidEndDecelerating:) withObject:nil afterDelay:0.3];
    
    
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


#pragma mark - Prepare For Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchDetailsSegue"]) {
        DetailView *cardetailview=[segue destinationViewController];
        cardetailview.delegate=self;
        
        //uncomment later
        
        CarRecord *record=(CarRecord *)sender;
        cardetailview.carRecordFromFirstView=record;
        
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

#pragma mark - Deleting and Adding Cars

- (void)deleteCarsWithResultArray:(NSArray *)mArray startingIndexPosition:(NSInteger)startingIndexPosition totalCarsToDelete:(NSInteger)carsTodelete
{
    NSIndexSet *indexSetOfCellsToDelete = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, IPHONECARS)];
    //if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
    [self.arrayOfAllSearchResultsCustomCellInfoObjects removeObjectsAtIndexes:indexSetOfCellsToDelete];
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
        __weak SearchResultsViewController *weakSelf=self;
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
    
    [self.arrayOfAllSearchResultsCustomCellInfoObjects addObjectsFromArray:mArray]; /////
    //
    
    [UIView setAnimationsEnabled:NO];
    @try {
        __weak SearchResultsViewController *weakSelf=self;
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
    
    
    
    [self.arrayOfAllSearchResultsCustomCellInfoObjects removeObjectsAtIndexes:indexSet4];
    
    
    @try {
        __weak SearchResultsViewController *weakSelf=self;
        [UIView setAnimationsEnabled:NO];
        [self.collectionView performBatchUpdates:^{
            [weakSelf.collectionView deleteItemsAtIndexPaths:cellIndicesToBeDeleted];
        } completion:^(BOOL finished) {
            //nil;
            
            
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
    [self.arrayOfAllSearchResultsCustomCellInfoObjects insertObjects:mArray atIndexes:indexSetForTopRows];
    
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
        __weak SearchResultsViewController *weakSelf=self;
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


#pragma mark - Notif Methods

- (void)searchOperationFailedNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(searchOperationFailedNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    [self.indicator stopAnimating];
    self.operationStarted=NO;
    
    NSError *error=[[notif userInfo] valueForKey:@"SearchOperationFailedNotifKey"];
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    //self.tableView.userInteractionEnabled=YES;
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=self;
    [alert addButtonWithTitle:@"OK"];
    
    
    if ([error code]==kCFURLErrorNotConnectedToInternet) {
        alert.title=@"No Internet Connection";
        alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
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
        alert.message=@"UCE Car Finder cannot retrieve data due to server error.";
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
    
    
    
    if (self.currentPage==1) {
        [self.indicator stopAnimating];
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    
    NSArray *mArray=[[notif userInfo] valueForKey:@"SearchOperationResults"];
    
    
    //
    SearchResultsCollectionCellInfo *cci=[mArray objectAtIndex:0];
    CarRecord *car1=[cci car];
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
                __weak SearchResultsViewController *weakSelf=self;
                
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
                NSInteger count1=[self.arrayOfAllSearchResultsCustomCellInfoObjects count];
                
                NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] initWithCapacity:1];
                
                //go to last row and add there
                for (int i=count1; i<count1+[mArray count]; i++) {
                    NSIndexPath *ip2=[NSIndexPath indexPathForRow:i inSection:0];
                    [cellIndicesToAdd addObject:ip2];
                    
                    
                }
                
                [self.arrayOfAllSearchResultsCustomCellInfoObjects addObjectsFromArray:mArray];
                
                
                @try
                {
                    __weak SearchResultsViewController *weakSelf=self;
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
                __weak SearchResultsViewController *weakSelf=self;
                
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


-(void)countOfSearchResultsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(countOfSearchResultsNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    if (self.currentPage==1) {
        [self.indicator stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    //[self hideActivityViewer];
    //self.tableView.userInteractionEnabled=YES;
    
    
    self.operationStarted=NO;
    
    [self.footerLabel removeFromSuperview];
    
    
    self.searchResultsCountReceived=[[[notif userInfo] valueForKey:@"CountOfSearchResults"]integerValue];
    
    if (self.searchResultsCountReceived==0 && self.currentPage==1) {
        
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


#pragma mark - DetailView Delegate Method

-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord
{
    
    //get all visible indexpaths
    NSArray *visibleIPaths=[self.collectionView indexPathsForVisibleItems];
    SearchResultsCollectionCellInfo *cci;
    
    for (NSIndexPath *ip in visibleIPaths) {
        cci=[self.arrayOfAllSearchResultsCustomCellInfoObjects objectAtIndex:ip.row];
        
        if ([[cci car] carid]==[aRecord carid]) {
            
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:ip]];
        }
    }
    detailView.delegate=nil;
}


#pragma mark - AlertView Delegate Method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.currentPage==1 || self.currentPage==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
    [self cancelAllOperations];
    [_searchViewCustomTableQueue cancelAllOperations];
    
    _makeIdReceived=nil;
    _modelIdReceived=nil;
    _zipReceived=nil;
    _milesReceived=nil;
    _makeNameReceived=nil;
    _modelNameReceived=nil;
    _arrayOfAllSearchResultsCustomCellInfoObjects=nil;
    _searchViewCustomTableQueue=nil;
    _searchResultsThumbnailQueue=nil;
    _footerLabel=nil;
    _headerLabel=nil;
    _activityIndicator=nil;
    _downloadsInProgress=nil;
    _op1=nil;
    _op2=nil;
    
}

@end
