//
//  SearchView.m
//  XMLTable2
//
//  Created by Mac on 12/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchView.h"

#import "DownloadMakesOperation.h"
#import "DownloadModelsOperation.h"
#import "SearchOperation.h"
#import "SearchResultsCustomTable.h"
#import "AppDelegate.h"
#import "CheckButton.h"
#import "CheckZipCode.h"
#import "CFNetwork/CFNetwork.h"
#import "QuartzCore/QuartzCore.h"
#import "UIButton+Glossy.h"
#import "Makes.h"
#import "Models.h"
#import "CommonMethods.h"


#define kOFFSET_FOR_KEYBOARD 120.0

@interface SearchView ()
{
    UIButton *_doneButton;
    
}

@property(strong,nonatomic) NSOperationQueue *downloadMakesOperationQueue;

@property(copy,nonatomic) NSMutableString *makeNameSelected,*modelNameSelected;
@property(copy,nonatomic) NSString *zipSelected;
@property(copy,nonatomic) NSMutableString *makeIdSelected,*modelIdSelected,*radiusSelected;
@property(strong,nonatomic) CheckButton *searchButton;
@property(assign,nonatomic) BOOL downloadOpStarted;

@property(strong,nonatomic) UIImageView *activityImageView;
@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(strong,nonatomic) UIScrollView *scrollView2;
@property(strong,nonatomic) UITextField *zipTextField;
@property(strong,nonatomic)  NSMutableDictionary *makesDictionary,*modelsDictionary;
@property(strong,nonatomic)  NSMutableArray *sortedMakes,*sortedModels;
@property(strong,nonatomic) UIPickerView *makesPicker,*modelsPicker;
@property(strong,nonatomic) NSMutableArray *radiusArray;



@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)doneButton:(id)sender;  // this is the button handler when the done button is pressed
- (void)createDoneButton;  // convenience method
- (void)hideDoneButton;  // this will hide the done button when it's time
- (void)unhideDoneButton;  // etc.
- (void)cancelAllOperations;

- (void) loadMakesDataFromDisk;

- (void)loadModelsDataFromDiskForMake:(NSString *)aMakeId;

- (void)registerForKeyboardNotifications;
- (void)unRegisterForKeyboardNotifications;


-(void)startSearchOperation;
- (void)loadModelsPickerWithData;
- (void)downloadMakesIfNotPresentElseLoadMakes;

@end


@implementation SearchView
@synthesize downloadMakesOperationQueue=_downloadMakesOperationQueue,makeNameSelected=_makeNameSelected,modelNameSelected=_modelNameSelected,zipSelected=_zipSelected,makeIdSelected=_makeIdSelected,modelIdSelected=_modelIdSelected,radiusSelected=_radiusSelected,searchButton=_searchButton,downloadOpStarted=_downloadOpStarted,activityImageView=_activityImageView,scrollView2=_scrollView2,zipTextField=_zipTextField,makesDictionary=_makesDictionary,modelsDictionary=_modelsDictionary,sortedMakes=_sortedMakes,sortedModels=_sortedModels;

@synthesize makesPicker=_makesPicker,modelsPicker=_modelsPicker,radiusArray=_radiusArray;

@synthesize showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel;

@synthesize managedObjectContext=_managedObjectContext,persistentStoreCoordinator=_persistentStoreCoordinator;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
    [self cancelAllOperations];
}

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


#pragma mark - Button Processing
-(void)searchButtonTapped
{
    //    NSLog(@"Search results are being retreived wil makeid=%@ model id=%@ zip=%@ miles=%@",makeIdSelected,modelIdSelected,zipSelected,radiusSelected);
    
    self.zipSelected=self.zipTextField.text;
    
    if ([self.radiusSelected isEqualToString:@"5"]) {
        self.zipSelected=@"0";
        [self startSearchOperation];
    }
    else
    {
        if(IsEmpty(self.zipTextField.text))
        {
            self.zipSelected=@"0";
            [self startSearchOperation];
        }
        else
        {
            //check if this zip is already present in NSUserDefaults
            //if not present, check if it is correct or not
            //if it is already present, no need to check
            
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            NSString *storedZipVal=[defaults valueForKey:@"homeZipValue"];
            
            if(![storedZipVal isEqualToString:self.zipTextField.text])
            {
                //check if this zip is valid
                CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
                checkZipCode.zipValReceived=self.zipTextField.text;
                [self.downloadMakesOperationQueue addOperation:checkZipCode];
            }
            else
            {
                [self startSearchOperation];
            }
        }
    }
}

-(void)startProcessingReceivedModels
{
    self.sortedModels = [[[self.modelsDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    //    NSLog(@"sortedModels is %@",self.sortedModels);
    
    if ([[self.modelsDictionary allKeys] count]>1) {
        if ([self.sortedModels containsObject:@"All Models"]) {
            [self.sortedModels removeObject:@"All Models"];
        }
        
        [self.sortedModels insertObject:@"All Models" atIndex:0];
        
        [self.modelsDictionary setObject:@"All Models" forKey:@"0"];
    }
}

- (void)loadModelsPickerWithData
{
    [self.modelsPicker reloadComponent:0];
    self.modelsPicker.userInteractionEnabled=YES;
    [self.modelsPicker selectRow:0 inComponent:0 animated:YES];
    
    self.modelNameSelected=[self.sortedModels objectAtIndex:0];
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedModels objectAtIndex:0];
    
    __weak SearchView *weakSelf=self;
    
    [self.modelsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqualToString:firstValue])
        {
            //NSLog(@"selected model at default is %@. id is %@",firstValue,key);
            
            weakSelf.modelIdSelected=key;
            *stop=YES;
        }
    }];
    //NSLog(@"models count is %d",[self.sortedModels count]);
}


-(void)startProcessingReceivedMakes
{
    self.sortedMakes = [[[self.makesDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    //    NSLog(@"sortedMakes is  %@",sortedMakes);
    
    if ([[self.makesDictionary allKeys] count]>1) {
        if ([self.sortedMakes containsObject:@"All Makes"]) {
            [self.sortedMakes removeObject:@"All Makes"];
        }
        
        [self.sortedMakes insertObject:@"All Makes" atIndex:0];
        [self.makesDictionary setObject:@"All Makes" forKey:@"0"];
    }
    
    [self.makesPicker reloadComponent:0];
    self.makesPicker.userInteractionEnabled=YES; //enable picker as data has arrived
    self.makeNameSelected=[self.sortedMakes objectAtIndex:0];
    //    [makeModelPicker setNeedsDisplay];
    
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedMakes objectAtIndex:0];
    __weak SearchView *weakSelf=self;
    [self.makesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([(NSMutableString *)obj isEqualToString:firstValue])
        {
            //NSLog(@"selected make at default is %@. id is %@",firstValue,key);
            
            weakSelf.makeIdSelected=(NSMutableString *)key;
            *stop=YES;
        }
    }];
    
    
    //NSLog(@"makeid selected initially is %@",self.makeIdSelected);
    //NSLog(@"makes count is %d", [self.sortedMakes count]);
    
    // start downloading models based on the initial make id.
    [self loadModelsDataFromDiskForMake:self.makeIdSelected];
    
}


-(void)startDownloadMakesOperation
{
    DownloadMakesOperation *downloadMakesOperation=[[DownloadMakesOperation alloc]init];
    [self.downloadMakesOperationQueue addOperation:downloadMakesOperation];
}

-(void)startDownloadModelsOperation
{
    DownloadModelsOperation *downloadModelsOperation=[[DownloadModelsOperation alloc]init];
    [self.downloadMakesOperationQueue addOperation:downloadModelsOperation];
    
}

-(void)showActivityViewer
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //NSString *str= [[NSBundle mainBundle]resourcePath];
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
    
    /*
    UILoadingView *loadingView=[[UILoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:loadingView];
    loadingView=nil;
     */
}

-(void)hideActivityViewer
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[self.activityImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.activityImageView removeFromSuperview];
     
    //[[self.view.subviews lastObject] removeFromSuperview];
}


-(void)setupMyScrollView
{
    self.scrollView2 = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
    // 1. setup the scrollview for multiple images and add it to the view controller
    
    //
    
    // note: the following can be done in Interface Builder, but we show this in code for clarity
    
    [self.scrollView2 setBackgroundColor:[UIColor clearColor]];
    
    [self.scrollView2 setCanCancelContentTouches:NO];
    
    self.scrollView2.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.scrollView2.clipsToBounds = YES;        // default is NO, we want to restrict drawing within our scrollview
    
    self.scrollView2.scrollEnabled = YES;
    
    
    self.scrollView2.contentMode = UIViewContentModeCenter;
    
    //    scrollview2.contentSize = content.frame.size; // or bounds, try both
    
    //used in rotation
    self.scrollView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.scrollView2.pagingEnabled = YES;
    
    self.scrollView2.showsVerticalScrollIndicator = NO;
    self.scrollView2.showsHorizontalScrollIndicator = NO;
    
    
    UIImageView *imageview=[[UIImageView alloc]initWithFrame:self.scrollView2.frame];
    [imageview setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]]];
    
    [self.scrollView2 addSubview:imageview];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 130, 44)];
    navtitle.text=@"Search Cars";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationController.navigationBar.topItem setTitleView:navtitle];  
    navtitle=nil;
    
    
    [self setupMyScrollView];
    self.view=self.scrollView2;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO]; // does not seem to work. The search button is not working when the keypad is up. However tapping the search button is hding the keypad. Then the user should tap the search button.
    // it is better to deactivate search button untill all the details are selected and keypad is hidden
    [self.view addGestureRecognizer:tap];
    //tap=nil;
    
    
    //for background image;
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    av.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:av];
    //av=nil;
    
    
    self.makeIdSelected=nil;
    self.modelIdSelected=nil;
    self.zipSelected=nil;
    self.radiusSelected=nil;
    
    
    UILabel *makeModelPickerLabel=[[UILabel alloc]init];
    makeModelPickerLabel.frame=CGRectMake(10, 30, 100, 40);
    makeModelPickerLabel.backgroundColor=[UIColor clearColor];
    makeModelPickerLabel.text=[NSString stringWithFormat:@"Make"];
    makeModelPickerLabel.textColor=[UIColor blackColor];
    //makeModelPickerLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.view addSubview:makeModelPickerLabel];
    makeModelPickerLabel=nil;
    
    
    UILabel *modelLabel=[[UILabel alloc]init];
    modelLabel.frame=CGRectMake(145, 30, 100, 40);
    modelLabel.backgroundColor=[UIColor clearColor];
    modelLabel.text=[NSString stringWithFormat:@"Model"];
    [self.view addSubview:modelLabel];
    modelLabel=nil;
    
    UIPickerView *tempMakesPicker=[[UIPickerView alloc]init];
    self.makesPicker=tempMakesPicker;
    tempMakesPicker=nil;
    self.makesPicker.frame=CGRectMake(1, 50, 152, 162); //new size
    self.makesPicker.showsSelectionIndicator=YES;
    [self.makesPicker setDataSource:self];
	
	[self.makesPicker setDelegate:self];
    
    [self.view addSubview:self.makesPicker];
    //disable this picker until data arrives
    self.makesPicker.userInteractionEnabled=NO;
    
    //////
    UIPickerView *tempModelsPicker=[[UIPickerView alloc]init];
    self.modelsPicker=tempModelsPicker;
    tempModelsPicker=nil;
    self.modelsPicker.frame=CGRectMake(136, 50, 164, 162);
    self.modelsPicker.showsSelectionIndicator=YES;
    [self.modelsPicker setDataSource:self];
	
	[self.modelsPicker setDelegate:self];
    
    [self.view addSubview:self.modelsPicker];
    //disable this picker until data arrives
    self.modelsPicker.userInteractionEnabled=NO;
    
    UIWebView *updateMakesAndModels=[[UIWebView alloc]initWithFrame:CGRectMake(12, 300, [CommonMethods findLabelWidth:@"Update Makes, Models"]+8, 25)]; //when using as button give y as 8
    updateMakesAndModels.scrollView.scrollEnabled=NO;
    updateMakesAndModels.opaque=NO;
    [updateMakesAndModels setBackgroundColor:[UIColor clearColor]];
    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    //if the email field is not Emp, show the webview, other wise hide it
    NSString *testString = @"<a href = \"obj://updateMakesModelsButtonTapped\">Update Makes, Models</a>";
    [updateMakesAndModels loadHTMLString:testString baseURL:nil];
    updateMakesAndModels.delegate=self;
    
    //accessibility
    updateMakesAndModels.isAccessibilityElement=YES;
    updateMakesAndModels.accessibilityLabel=@"Update makes and models";
    
    [self.view addSubview:updateMakesAndModels];
    //
    self.radiusSelected=[@"4" mutableCopy]; //1=10 miles, 2=25 miles, 3=50 miles, 4=100 miles, 5=Anywhere
    
    UILabel *zipLabel=[[UILabel alloc]init];
    zipLabel.frame=CGRectMake(70, 240, 80, 30);
    zipLabel.backgroundColor=[UIColor clearColor];
    zipLabel.text=[NSString stringWithFormat:@"Enter Zip:"];
    zipLabel.textColor=[UIColor blackColor];
    zipLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.view addSubview:zipLabel];
    zipLabel=nil;
    
    UITextField *tempZipTextField=[[UITextField alloc]init];
    self.zipTextField=tempZipTextField;
    tempZipTextField=nil;
    self.zipTextField.frame=CGRectMake(145, 240, 90, 30);
    self.zipTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.zipTextField.font = [UIFont systemFontOfSize:15];
    self.zipTextField.placeholder = @"Zip";
    self.zipTextField.textAlignment=UITextAlignmentCenter;
    self.zipTextField.textColor=[UIColor blackColor];
    self.zipTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.zipTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.zipTextField.returnKeyType = UIReturnKeyDone;
    self.zipTextField.clearButtonMode = UITextFieldViewModeNever;
    self.zipTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    self.zipTextField.delegate = self;
    
    //    zipTextField.text=nil;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.zipTextField.text=[defaults valueForKey:@"homeZipValue"];
    
    //accessibility
    self.zipTextField.isAccessibilityElement=YES;
    self.zipTextField.accessibilityLabel=@"Zip code";
    [self.view addSubview:self.zipTextField];
    
    //    zipSelected=@"92404";
    [self createDoneButton];
    
    
    //self.searchButton needs no action, because there is a segue from search button
    self.searchButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.frame=CGRectMake(210, 300, 90, 34);
    [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.searchButton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.searchButton makeGlossy];
    
    
    //accessibility
    self.searchButton.isAccessibilityElement=YES;
    self.searchButton.accessibilityLabel=@"Search";
    [self.view addSubview:self.searchButton];
    
    
    UITapGestureRecognizer *tapRecognizerForSearchButton = [[UITapGestureRecognizer alloc] 
                                                            initWithTarget:self
                                                            action:@selector(dismissKeyboardAndStartSearch)];
    [tapRecognizerForSearchButton setCancelsTouchesInView:NO]; // does not seem to work. The search button is not working when the keypad is up. However tapping the search button is hding the keypad. Then the user should tap the search button.
    // it is better to deactivate search button untill all the details are selected and keypad is hidden
    [self.searchButton addGestureRecognizer:tapRecognizerForSearchButton];
    //tapRecognizerForSearchButton=nil;
    
    
    self.downloadMakesOperationQueue=[[NSOperationQueue alloc]init];
    [self.downloadMakesOperationQueue setName:@"SearchViewQueue"];
    [self.downloadMakesOperationQueue setMaxConcurrentOperationCount:1];
    
    [self downloadMakesIfNotPresentElseLoadMakes];
}

-(void)updateMakesModelsButtonTapped
{
    self.downloadOpStarted=YES;
    
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil]; 
    
    [[self makesPicker] setUserInteractionEnabled:NO];
    [[self modelsPicker] setUserInteractionEnabled:NO];
    
    [self startDownloadMakesOperation];
}

- (void)downloadMakesIfNotPresentElseLoadMakes
{
    //
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=[delegate managedObjectContext];
    
    //fetching
    NSEntityDescription *makesEntityDesc=[NSEntityDescription entityForName:@"Makes" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    
    
    //fetching makes
    [request setEntity:makesEntityDesc];
    NSError *error;
    NSArray *allMakes=[self.managedObjectContext executeFetchRequest:request error:&error];
    
    //NSLog(@"Loaded makesDictionary %@ allMakes=%@", self.makesDictionary,allMakes);
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(allMakes)) {
        //NSLog(@"Error loading makes from coredata makes file.");
        //lets call updateMakesModelsButtonTapped, so it will take care of downloading makes and models
        [self updateMakesModelsButtonTapped];
    }
    else
    {
        [self loadMakesDataFromDisk];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    _doneButton = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadMakesNotifMethod:) name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadModelsNotifMethod:) name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(makesOperationDownloadErrorNotifMethod:) name:@"MakesOperationDownloadErrorNotif" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
	[self unRegisterForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MakesOperationDownloadErrorNotif" object:nil];
    
    //[self cancelAllOperations];
    [self hideActivityViewer];
    
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

#pragma mark -
#pragma mark Picker view methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.makesPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        //[mask setFrame: CGRectMake(9.0f, 20.0f, 140.0f, 120.0f)]; //old
        [mask setFrame: CGRectMake(9.0f, 20.0f, 132.0f, 120.0f)];
        [mask setCornerRadius: 5.0f];
        [self.makesPicker.layer setMask: mask];
        
        mask=nil;
        
        return 1;
    } 
    if ([pickerView isEqual:self.modelsPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        //[mask setFrame: CGRectMake(9.0f, 20.0f, 155.0f, 120.0f)]; //old
        [mask setFrame: CGRectMake(9.0f, 20.0f, 144.0f, 120.0f)];
        [mask setCornerRadius: 5.0f];
        [self.modelsPicker.layer setMask: mask];
        
        mask=nil;
        
        return 1;
    } 
    return 0;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.makesPicker]) {
        if(self.sortedMakes && self.sortedMakes.count)
        {
            return [self.sortedMakes count];
        }
        else
        {
            return 0;
        }
    } 
    if ([pickerView isEqual:self.modelsPicker]) {
        if(self.sortedModels && self.sortedModels.count)
        {
            return [self.sortedModels count];
        }
        else
        {
            return 0;
        }
    } 
    return 0; 
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.makesPicker]) {
        
        //when make component is selected, initialize modelid to nil
        self.modelIdSelected=nil;
        
        //depending on component 0 value selected, find the appropriate array if component 1
        
        //first find the id of corresponding make selected.
        __weak SearchView *weakSelf=self;
        [self.makesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([(NSMutableString *)obj isEqualToString:[weakSelf.sortedMakes objectAtIndex:row]])
            {
                //NSLog(@"selected make is %@. id is %@",[weakSelf.sortedMakes objectAtIndex:row],key);
                
                weakSelf.makeIdSelected=(NSMutableString *)key;
                *stop=YES;
            }
        }];
        
        //start downloading models logic - begin
        [self loadModelsDataFromDiskForMake:self.makeIdSelected];
        //start downloading models logic -end
        
        self.makeNameSelected=[self.sortedMakes objectAtIndex:row];
        //NSLog(@"makeNameSelected is %@",self.makeNameSelected);
    }
    
    if ([pickerView isEqual:self.modelsPicker])
    {
        __weak SearchView *weakSelf=self;
        [self.modelsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            //            NSLog(@"obj = %@ [self.modelArrayForPicker objectAtIndex:row]=%@",obj,[self.modelArrayForPicker objectAtIndex:row]);
            if([obj isEqualToString:[weakSelf.sortedModels objectAtIndex:row]])
            {
                //NSLog(@"selected model is %@. id is %@",[weakSelf.sortedModels objectAtIndex:row],key);
                
                weakSelf.modelIdSelected=key;
                *stop=YES;
            }
        }];
        
        self.modelNameSelected=[self.sortedModels objectAtIndex:row];
        //NSLog(@"modelNameSelected is %@",self.modelNameSelected);
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    
    
    CGFloat width = [pickerView rowSizeForComponent:component].width;
    
    UILabel *pickerLabel=(UILabel *)[view viewWithTag:25];
    if (pickerLabel==nil) {
        pickerLabel=[[UILabel alloc] init];
        pickerLabel.tag=25;
    }
    
    if (pickerLabel != nil) {
        CGRect frame = CGRectMake(0.0, 0.0, width, 32);
        [pickerLabel setFrame:frame];
        [pickerLabel setTextAlignment:UITextAlignmentLeft];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setText:@"hello"];
        //[pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        
        
        pickerLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if(row>=0)
        if([pickerView isEqual:self.makesPicker])
        {
            [pickerLabel setText:[self.sortedMakes objectAtIndex:row]];
        }
    
    
    if(row>=0)    
        if(pickerView==self.modelsPicker)
        {
            [pickerLabel setText:[self.sortedModels objectAtIndex:row]];
            
        }
    return pickerLabel;
}


#pragma mark -
#pragma mark delegate method
-(void)kDownloadMakesNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadMakesNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        [self loadMakesDataFromDisk];
        [self startDownloadModelsOperation];
    }
    
}

-(void)kDownloadModelsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadModelsNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    [[self makesPicker] selectRow:0 inComponent:0 animated:YES];
    [[self makesPicker] setUserInteractionEnabled:YES];
    [[self modelsPicker] setUserInteractionEnabled:YES];
    
    [self loadModelsDataFromDiskForMake:@"0"];
    if (self.downloadOpStarted) {
        self.downloadOpStarted=NO;
        [self hideActivityViewer];
    }
}

-(void)makesOperationDownloadErrorNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(makesOperationDownloadErrorNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        [self hideActivityViewer];
        
        NSError *error=[[notif userInfo]valueForKey:@"MakesOperationDownloadErrorKey"];
        
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
            alert.message=@"UCE cannot retreive data because of server error."; 
        }
        [alert show];
        alert=nil;
    }
    
}

-(void)startSearchOperation
{
    
    [self.zipTextField resignFirstResponder];
    
    SearchOperation *searchOperation=[[SearchOperation alloc]init];
    
    searchOperation.makeIdReceived=self.makeIdSelected;
    searchOperation.modelIdReceived=self.modelIdSelected;
    if ([self.makeIdSelected isEqualToString:@"0"]) {
        searchOperation.makeNameReceived=@"All Makes";
    }
    else
    {
        searchOperation.makeNameReceived=self.makeNameSelected;
    }
    
    if ([self.modelIdSelected isEqualToString:@"0"]) {
        searchOperation.modelNameReceived=@"All Models";
    }
    else
    {
        searchOperation.modelNameReceived=self.modelNameSelected;
    }
    searchOperation.zipReceived=self.zipSelected;
    searchOperation.milesReceived=self.radiusSelected;
    searchOperation.pageNoReceived=1;
    
    [self.downloadMakesOperationQueue addOperation:searchOperation];
    //searchOperation=nil;
    
    //NSLog(@"SearchView: Search results are being retreived makeName=%@ model Name=%@ zip=%@ miles=%@ self.downloadMakesOperationQueue=%@ searchOperation = %@",self.makeNameSelected,self.modelNameSelected,self.zipSelected,self.radiusSelected,self.downloadMakesOperationQueue,searchOperation);
    
    [self performSegueWithIdentifier:@"Searchviewsegue" sender:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Searchviewsegue"]) {
        SearchResultsCustomTable *searchResultsCustomTable=[segue destinationViewController];
        
        if([self.radiusSelected isEqualToString:@"5"])
        {
            searchResultsCustomTable.allMilesSelected=YES;
        }
        
        
        searchResultsCustomTable.makeIdReceived=self.makeIdSelected;
        searchResultsCustomTable.modelIdReceived=self.modelIdSelected;
        searchResultsCustomTable.makeNameReceived=self.makeNameSelected;
        searchResultsCustomTable.modelNameReceived=self.modelNameSelected;
        searchResultsCustomTable.milesReceived=self.radiusSelected;
        
        searchResultsCustomTable.zipReceived=self.zipSelected;
        
        //NSLog(@"SearchView-prepareForSegue: Search results are being retreived makeName=%@ model Name=%@ zip=%@ miles=%@",self.makeNameSelected,self.modelNameSelected,self.zipSelected,self.radiusSelected);
        
    }
}

-(void)checkZipCodeNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    //
    if([[[notif userInfo] valueForKey:@"CheckZipCodeNotifKey"] isKindOfClass:[NSError class]])
    {
        NSError *error=[[notif userInfo] valueForKey:@"CheckZipCodeNotifKey"];
        
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
        
        
        return;
    }
    
    NSString *boolValStr=[[notif userInfo]valueForKey:@"CheckZipCodeNotifKey"];
    if ([boolValStr isEqualToString:@"false"]) {
        //invalid zip entered
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Zip" message:@"Enter a valid Zip code." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
    else
    {
        //NSLog(@"zip is fine in search view");
        //        save the zip to nsuuserdefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.zipSelected forKey:@"homeZipValue"];
        [defaults synchronize];
        
        //        pass search parameters including zip to service
        [self startSearchOperation];
    }
}


//method to move the view up/down whenever the keyboard is shown/dismissed

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.zipTextField) {
        [self unhideDoneButton];
    }
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.zipTextField) {
        [self hideDoneButton];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.zipSelected=textField.text;
    [textField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.zipSelected=textField.text;
    [textField resignFirstResponder]; 
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return (newLength > 5) ? NO : YES;
}

#pragma mark - Webview Delegate Methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //check if a html link is clicked
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        
        //get url from request
        NSURL *url=[request URL];
        
        //get the url scheme i.e., http or https or ftp or objc (in our case)
        
        if ([[url scheme] isEqualToString:@"obj"]) {
            //get a hold of webview so that we can use it later
            //            self.myWebView=webView;
            
            //we get the host part of url and use it as our method that we execute
            SEL method=NSSelectorFromString([url host]);
            //NSLog(@"[url host]=%@",[url host]);
            //now execute that method
            if ([self respondsToSelector:method]) {
                [self performSelector:method withObject:nil afterDelay:0.1f];
            }
            return NO;
        }
    }
    return YES;
}


#pragma mark - Load Makes and Models

- (void) loadMakesDataFromDisk {
    
    //
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=[delegate managedObjectContext];
    
    //fetching
    NSEntityDescription *makesEntityDesc=[NSEntityDescription entityForName:@"Makes" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    //fetching makes
    [request setEntity:makesEntityDesc];
    NSError *error;
    NSArray *allMakes=[self.managedObjectContext executeFetchRequest:request error:&error];
    if (self.makesDictionary==nil) {
        self.makesDictionary=[[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    for (Makes *aMake in allMakes) {
        [self.makesDictionary setObject:[aMake valueForKey:@"makeName"] forKey:[aMake valueForKey:@"makeID"]];
        
        //NSLog(@"make id=%@ name=%@",[aMake valueForKey:@"makeID"],[aMake valueForKey:@"makeName"]);
    }
    
    //NSLog(@"Loaded makesDictionary %@ allMakes=%@", self.makesDictionary,allMakes);
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(allMakes)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Initial Run: No Makes Data Found" message:@"Tap \"Update Makes Data\" button to get latest Makes And Models." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        self.makesDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
        [self.makesDictionary setObject:@"All Makes" forKey:@"0"];
        
    }
    [self startProcessingReceivedMakes];
}


- (void)loadModelsDataFromDiskForMake:(NSString *)aMakeId
{
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=[delegate managedObjectContext];
    
    //fetching models
    //fetching
    NSEntityDescription *modelsEntityDesc=[NSEntityDescription entityForName:@"Models" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    [request setEntity:modelsEntityDesc];
    
    NSPredicate *filter=[NSPredicate predicateWithFormat:@"makeID like[c] %@",[NSString stringWithString:aMakeId]];
    [request setPredicate:filter];
    
    NSError *error;
    NSArray *allmodels=[self.managedObjectContext executeFetchRequest:request error:&error];
    
    self.modelsDictionary=[[NSMutableDictionary alloc]initWithCapacity:1];
    
    for (Models *aModel in allmodels) {
        [self.modelsDictionary setObject:[aModel valueForKey:@"modelName"] forKey:[aModel valueForKey:@"modelID"]];
        
        //NSLog(@"model id=%@ name=%@",[aModel valueForKey:@"modelID"],[aModel valueForKey:@"modelName"]);
    }
    
    if (IsEmpty(allmodels)) {
        //NSLog(@"Error loading models from coredata models file.");
        self.modelsDictionary=[NSDictionary dictionaryWithObject:@"All Models" forKey:@"0"];
    }
    
    [self startProcessingReceivedModels];
    [self loadModelsPickerWithData];
}

// Call this method somewhere in your view controller setup code.

- (void)registerForKeyboardNotifications

{
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unRegisterForKeyboardNotifications

{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.

- (void)keyboardWasShown:(NSNotification*)aNotification

{
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //NSLog(@"kbSize.height is %.1f",kbSize.height);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    self.scrollView2.contentInset = contentInsets;
    
    self.scrollView2.scrollIndicatorInsets = contentInsets;
    
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your application might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    
    //NSLog(@"aRect height before = %.1f",aRect.size.height);
    
    aRect.size.height -= kbSize.height;
    
    //NSLog(@"aRect height after = %.1f",aRect.size.height);
    
    if (!CGRectContainsPoint(aRect, self.searchButton.frame.origin) ) {
        
        //NSLog(@"visible rect does not contain button");
        //NSLog(@"searchButton.frame.origin.y-kbSize.height is %.1f",self.searchButton.frame.origin.y-kbSize.height);
        
        CGPoint scrollPoint = CGPointMake(0.0, self.searchButton.frame.origin.y-kbSize.height+60.0);
        
        [self.scrollView2 setContentOffset:scrollPoint animated:YES];
        
    }
    
    //code for Done button on keyboard
    if (self.zipTextField.isFirstResponder) {
        
        [self unhideDoneButton];  // self.numField is firstResponder and the one that caused the keyboard to pop up
    }
    else 
    {
        [self hideDoneButton];
    }
}


// Called when the UIKeyboardWillHideNotification is sent

- (void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    //NSLog(@"keyboardWillBeHidden called");
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    self.scrollView2.contentInset = contentInsets;
    
    self.scrollView2.scrollIndicatorInsets = contentInsets;
    
    [self.zipTextField resignFirstResponder]; 
    
}

-(void)dismissKeyboardAndStartSearch {
    [self.zipTextField resignFirstResponder];
    [self searchButtonTapped];
}

-(void)dismissKeyboard {
    [self.zipTextField resignFirstResponder];
    
}

#pragma mark -
#pragma mark Done Button For NumberPad
- (void)doneButton:(id)sender {
    
    [self.zipTextField resignFirstResponder];
}

- (void)createDoneButton {
	// create custom button
    
    if (_doneButton == nil) {
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(0, 163, 106, 53);
        _doneButton.adjustsImageWhenHighlighted = NO;
        [_doneButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"doneup" ofType:@"png"]] forState:UIControlStateNormal];
        [_doneButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"donedown" ofType:@"png"]] forState:UIControlStateHighlighted];
        
        [_doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
        
        _doneButton.hidden = YES;  // we hide/unhide him from here on in with the appropriate method
    }
}

- (void)hideDoneButton
{
    [_doneButton removeFromSuperview];
    _doneButton.hidden = YES;
}

- (void)unhideDoneButton
{
    // this here is a check that prevents NSRangeException crashes that were happening on retina devices  
    int windowCount = [[[UIApplication sharedApplication] windows] count];
    if (windowCount < 2) {
        return;
    }   
    
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex: 1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        // keyboard found, add the button
        
        // so the first time you unhide, it gets put on one subview, but in subsequent tries, it gets put on another.  this is why we have to keep adding and removing him from its superview.
        
        // THIS IS THE HACK BELOW.  I MEAN, PROPERLY HACKY!
        if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
        {
            [keyboard addSubview: _doneButton];
        }
        else if([[keyboard description] hasPrefix:@"<UIKeyboardA"] == YES)
        {
            
            [keyboard addSubview: _doneButton];
        }
    }
    _doneButton.hidden = NO;
}


- (void)cancelAllOperations {
    [self.downloadMakesOperationQueue cancelAllOperations];
}

-(void)dealloc
{
    _downloadMakesOperationQueue=nil;
    _makeNameSelected=nil;
    _modelNameSelected=nil;
    _zipSelected=nil;
    _makeIdSelected=nil;
    _modelIdSelected=nil;
    _radiusSelected=nil;
    _searchButton=nil;
    _activityImageView=nil;
    _scrollView2=nil;
    _zipTextField.delegate=nil;
    _zipTextField=nil;
    _makesDictionary=nil;
    _modelsDictionary=nil;
    _sortedMakes=nil;
    _sortedModels=nil;
    _makesPicker=nil;
    _modelsPicker=nil;
    _radiusArray=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
    
}

@end
