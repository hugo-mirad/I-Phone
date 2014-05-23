//
//  EditPreference.m
//  Preferences
//
//  Created by Mac on 01/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditPreference.h"
#import "DownloadMakesOperation.h"
#import "DownloadModelsOperation.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CheckButton.h"
#import "CheckZipCode.h"
#import "CFNetwork/CFNetwork.h"
#import "UIButton+Glossy.h"
#import "Makes.h"
#import "Models.h"
#import "CommonMethods.h"



#define kOFFSET_FOR_KEYBOARD 130.0

@interface EditPreference()

@property(strong,nonatomic) NSMutableDictionary *makesDictionary,*modelsDictionary;
@property(strong,nonatomic) NSArray *modelsInfoArray;
@property(strong,nonatomic) NSMutableArray *sortedMakes,*sortedModels;
@property(strong,nonatomic) UIPickerView *yearPicker,*makesPicker,*modelsPicker,*mileagePicker,*pricePicker;
@property(strong,nonatomic) NSArray *yearArray,*mileageArray,*priceArray;
@property(strong,nonatomic) CheckButton *saveButton,*cancelButton;


@property(copy,nonatomic) NSString *makeIdSelected,*modelIdSelected,*priceIdSelected,*priceValueSelected,*mileageSelected,*mileageValueSelected;
@property(copy,nonatomic) NSString *makeNameSelected,*modelNameSelected,*yearSelected,*yearValueSelected,*zipSelected,*zipLoadedFromPref;
@property(assign,nonatomic) BOOL downloadOpStarted;

@property(strong,nonatomic) NSOperationQueue *downloadOpQueue;

@property(strong,nonatomic) UIImageView *activityImageView;


@property(strong,nonatomic) UIScrollView *scrollView2;

@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void) loadMakesDataFromDisk;
- (void)loadModelsDataFromDiskForMake:(NSString *)aMakeId;
- (void)loadModelsPickerWithData;
- (void)downloadMakesIfNotPresentElseLoadMakes;

@end



@implementation EditPreference
@synthesize prefNameReceived=_prefNameReceived;

@synthesize makesDictionary=_makesDictionary,modelsDictionary=_modelsDictionary,modelsInfoArray=_modelsInfoArray,sortedMakes=_sortedMakes,sortedModels=_sortedModels,yearPicker=_yearPicker,makesPicker=_makesPicker,modelsPicker=_modelsPicker,mileagePicker=_mileagePicker,pricePicker=_pricePicker,yearArray=_yearArray,mileageArray=_mileageArray,priceArray=_priceArray,saveButton=_saveButton,cancelButton=_cancelButton,makeIdSelected=_makeIdSelected,modelIdSelected=_modelIdSelected,priceIdSelected=_priceIdSelected,mileageSelected=_mileageSelected,makeNameSelected=_makeNameSelected,modelNameSelected=_modelNameSelected,yearSelected=_yearSelected,zipSelected=_zipSelected,downloadOpStarted=_downloadOpStarted,downloadOpQueue=_downloadOpQueue,activityImageView=_activityImageView,scrollView2=_scrollView2,priceValueSelected=_priceValueSelected,mileageValueSelected=_mileageValueSelected,yearValueSelected=_yearValueSelected;

@synthesize zipLoadedFromPref=_zipLoadedFromPref;

@synthesize delegate=_delegate,showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel;

@synthesize managedObjectContext=_managedObjectContext,persistentStoreCoordinator=_persistentStoreCoordinator;

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (BOOL)duplicatePrefAlreadyExistsWithMakeId:(NSString *)someMakeID modelId:(NSString *)someModelId yearValue:(NSString *)someYear priceValue:(NSString *)somePriceId mileageValue:(NSString *)someMileage
{
    //read all plist files
    BOOL success,matchingPrefFound=NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSRange rangeOfPrefNum=NSMakeRange(10,1);
    NSString *prefNameOfNewPref=[self.prefNameReceived substringWithRange:rangeOfPrefNum];
    NSInteger prefNumOfNewPref=[prefNameOfNewPref integerValue];
    
    NSLog(@"The pref number received is %d",prefNumOfNewPref);
    //now read all plist files from 1 to prefNumOfNewPref
    
    for (int i=1; i<=prefNumOfNewPref; i++) {
        NSString *filename=[NSString stringWithFormat:@"Preference%d.plist",i];
        
        
        
        NSString *plistToCheck = [dbPath stringByAppendingPathComponent:filename];
        success = [fileManager fileExistsAtPath:plistToCheck];
        
        if (success) 
        {
            
            NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:plistToCheck];
            if ([[dict objectForKey:@"makeIdSelected"] isEqualToString:someMakeID] && [[dict objectForKey:@"modelIdSelected"] isEqualToString:someModelId] && [[dict objectForKey:@"priceIdSelected"] isEqualToString:somePriceId] && [[dict objectForKey:@"yearSelected"] isEqualToString:someYear] && [[dict objectForKey:@"mileageSelected"] isEqualToString:someMileage]) {
                matchingPrefFound=YES;
            }
        }
        else
        {
            NSLog(@"pref plist not found");
        }
    }
    
    return matchingPrefFound;
    
}

-(void)savePreference
{
    //check if duplicate pref already exists
    
    BOOL duplicatePrefAlreadyExists=[self duplicatePrefAlreadyExistsWithMakeId:self.makeIdSelected modelId:self.modelIdSelected yearValue:self.yearSelected priceValue:self.priceIdSelected mileageValue:self.mileageSelected];
    
    if (duplicatePrefAlreadyExists) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Duplicate Preference Found" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        return;
        
    }
    // save make, make id, model, model id, year, price, mileage to plist.
    //NSLog(@"selected make = %@ make id = %@ model = %@ model id = %@ year = %@ price = %@ mileage = %@ zip = %@",self.makeNameSelected,self.makeIdSelected,self.modelNameSelected,self.modelIdSelected,self.yearSelected,self.priceIdSelected,self.mileageSelected,self.zipSelected);
    
    
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",self.prefNameReceived];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    
    NSMutableDictionary *carDictionaryToSave=[[NSMutableDictionary alloc]init];
    [carDictionaryToSave setObject:self.makeIdSelected forKey:@"makeIdSelected"];
    [carDictionaryToSave setObject:self.makeNameSelected forKey:@"makeNameSelected"];
    [carDictionaryToSave setObject:self.modelIdSelected forKey:@"modelIdSelected"];
    [carDictionaryToSave setObject:self.modelNameSelected forKey:@"modelNameSelected"];
    [carDictionaryToSave setObject:self.yearSelected forKey:@"yearSelected"];
    [carDictionaryToSave setObject:self.yearValueSelected forKey:@"yearValueSelected"];
    [carDictionaryToSave setObject:self.priceIdSelected forKey:@"priceIdSelected"];
    [carDictionaryToSave setObject:self.priceValueSelected forKey:@"priceValueSelected"];
    [carDictionaryToSave setObject:self.mileageSelected forKey:@"mileageSelected"];
    [carDictionaryToSave setObject:self.mileageValueSelected forKey:@"mileageValueSelected"];
    [carDictionaryToSave setObject:self.zipSelected forKey:@"zipSelected"];
    
    
    [carDictionaryToSave setObject:self.prefNameReceived forKey:@"name"];
    
    
    [carDictionaryToSave writeToFile:writablePath atomically:YES];
    
    
    //NSLog(@"The stored preferences is %@",carDictionaryToSave);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ Saved",self.prefNameReceived] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
    
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(saveButtonTapped:forPreference:)])
    {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate saveButtonTapped:self forPreference:carDictionaryToSave];
    }
    
    [carDictionaryToSave removeAllObjects];
    carDictionaryToSave=nil;
    
}

-(void)saveButtonTapped
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preferenceZip=[defaults valueForKey:@"preferenceZip"];
    
    
    if (preferenceZip==nil) {
        [defaults setValue:@"0" forKey:@"preferenceZip"];
        [defaults synchronize];
        preferenceZip=@"0";
    }
    
    ////
    self.zipSelected=preferenceZip;
    
    
    [self savePreference];
    
}

-(void)cancelButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
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
    //    [myPreferencePicker selectRow:0 inComponent:1 animated:YES];
    [self.modelsPicker reloadComponent:0];
    self.modelsPicker.userInteractionEnabled=YES;
    [self.modelsPicker selectRow:0 inComponent:0 animated:YES];
    
    self.modelNameSelected=[self.sortedModels objectAtIndex:0];
    
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedModels objectAtIndex:0];
    
    __weak EditPreference *weakSelf=self;
    
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
    __weak EditPreference *weakSelf=self;
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
    //    [self startDownloadModelsOperation];
    [self loadModelsDataFromDiskForMake:self.makeIdSelected];
    
    
}

-(void)startDownloadMakesOperation
{
    DownloadMakesOperation *downloadMakesOperation=[[DownloadMakesOperation alloc]init];
    
    [self.downloadOpQueue addOperation:downloadMakesOperation];
}

-(void)startDownloadModelsOperation
{
    DownloadModelsOperation *downloadModelsOperation=[[DownloadModelsOperation alloc]init];
    //    downloadModelsOperation.makeIdReceived=makeIdSelected;
    [self.downloadOpQueue addOperation:downloadModelsOperation];
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


-(void)updateMakesModelsButtonTapped
{
    self.downloadOpStarted=YES;
    
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil]; 
    
    [[self makesPicker] setUserInteractionEnabled:NO];
    [[self modelsPicker] setUserInteractionEnabled:NO];
    
    [self startDownloadMakesOperation];
    
}

-(void)loadPickersWithPreviousData:(NSDictionary *)prevPreference
{
    //get make id and select appropriate row of make picker
    
    
    NSString *makeIdSelected=[prevPreference objectForKey:@"makeIdSelected"];
    NSString *makeNameSelected=[prevPreference objectForKey:@"makeNameSelected"];
    
    //makes and makeIds are available in self.makesDictionary. self.sortedMakes contains sorted makes. self.modelsDictionary contains models for Acura (makeid=1) which might not be useful here.
    //the position of makeName in sortedMakes is same as position in makes picker
    NSUInteger indexOfMake=[self.sortedMakes indexOfObject:makeNameSelected];
    [self.makesPicker selectRow:indexOfMake inComponent:0 animated:YES];
    
    //get model id and select appropriate row of model picker
    NSString *modelNameSelected=[prevPreference objectForKey:@"modelNameSelected"];
    
    [self loadModelsDataFromDiskForMake:makeIdSelected];
    
    
    [self startProcessingReceivedModels];
    
    
    [self.modelsPicker reloadComponent:0];
    self.modelsPicker.userInteractionEnabled=YES;
    
    //the position of modelName in sortedModels is same as position in models picker
    NSUInteger indexOfModel=[self.sortedModels indexOfObject:modelNameSelected];
    [self.modelsPicker selectRow:indexOfModel inComponent:0 animated:YES];
    
    
    
    //get year id and select appropriate row of year picker
    NSString *yearValueSelected=[prevPreference objectForKey:@"yearValueSelected"];
    //the position of yearName in yearArray is same as position in years picker
    NSUInteger indexOfYear=[self.yearArray indexOfObject:yearValueSelected];
    [self.yearPicker selectRow:indexOfYear inComponent:0 animated:YES];
    
    //get milleage id and select appropriate row in mileage picker
    NSString *mileageValueSelected=[prevPreference objectForKey:@"mileageValueSelected"];
    //the position of mileage in mileageArray is same as position in mileage picker
    NSUInteger indexOfMileage=[self.mileageArray indexOfObject:mileageValueSelected];
    [self.mileagePicker selectRow:indexOfMileage inComponent:0 animated:YES];
    
    //get price id and select appropriate row in price picker
    NSString *priceValueSelected=[prevPreference objectForKey:@"priceValueSelected"];
    //the position of price in priceArray is same as position in price picker
    NSUInteger indexOfPrice=[self.priceArray indexOfObject:priceValueSelected];
    [self.pricePicker selectRow:indexOfPrice inComponent:0 animated:YES];
    
}

-(void)readPreviousPreference
{
    BOOL success;
    //      NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",self.prefNameReceived];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    if(success)
    {
        NSDictionary *myPrefDict=[[NSDictionary alloc]initWithContentsOfFile:writablePath];
        if ([myPrefDict objectForKey:@"makeIdSelected"]) {
            //NSLog(@"read dict here ");
            //reset ivars that might get saved again without touching pickers
            self.makeIdSelected=[myPrefDict objectForKey:@"makeIdSelected"];
            self.makeNameSelected=[myPrefDict objectForKey:@"makeNameSelected"];
            self.modelIdSelected=[myPrefDict objectForKey:@"modelIdSelected"];
            self.modelNameSelected=[myPrefDict objectForKey:@"modelNameSelected"];
            self.mileageSelected=[myPrefDict objectForKey:@"mileageSelected"];
            self.mileageValueSelected=[myPrefDict objectForKey:@"mileageValueSelected"];
            self.priceIdSelected=[myPrefDict objectForKey:@"priceIdSelected"];
            self.priceValueSelected=[myPrefDict objectForKey:@"priceValueSelected"];
            self.yearSelected=[myPrefDict objectForKey:@"yearSelected"];
            self.yearValueSelected=[myPrefDict objectForKey:@"yearValueSelected"];
            
            [self loadPickersWithPreviousData:myPrefDict];
            
        }
        else
        {
            NSLog(@"There is no prev preference set. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        }
    }
}



#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
    navtitle.text=[NSString stringWithFormat:@"%@",self.prefNameReceived];
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationItem setTitleView:navtitle];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle]; 
    navtitle=nil;
    
    
    //for background image;
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    [self.view addSubview:av];
    
    UILabel *makeLabel=[[UILabel alloc]init];
    makeLabel.frame=CGRectMake(12, 2, 100, 40);
    makeLabel.backgroundColor=[UIColor clearColor];
    makeLabel.text=[NSString stringWithFormat:@"Make"];
    [self.view addSubview:makeLabel];
    makeLabel=nil;
    
    
    self.makesPicker =[[UIPickerView alloc]init];
    self.makesPicker.frame=CGRectMake(2, 22, 120, 162);
    self.makesPicker.showsSelectionIndicator=YES;
    [self.makesPicker setDelegate:self];
    [self.makesPicker setDataSource:self];
    [self.view addSubview:self.makesPicker];
    
    
    UILabel *modelLabel=[[UILabel alloc]init];
    modelLabel.frame=CGRectMake(117, 2, 100, 40);
    modelLabel.backgroundColor=[UIColor clearColor];
    modelLabel.text=[NSString stringWithFormat:@"Model"];
    [self.view addSubview:modelLabel];
    modelLabel=nil;
    
    
    self.modelsPicker=[[UIPickerView alloc]init];
    self.modelsPicker.frame=CGRectMake(104, 22, 134, 162);
    self.modelsPicker.showsSelectionIndicator=YES;
    [self.modelsPicker setDelegate:self];
    [self.modelsPicker setDataSource:self];
    [self.view addSubview:self.modelsPicker];
    
    
    UILabel *mileageLabel=[[UILabel alloc]init];
    mileageLabel.frame=CGRectMake(236, 2, 100, 40);
    mileageLabel.backgroundColor=[UIColor clearColor];
    mileageLabel.text=[NSString stringWithFormat:@"Mileage"];
    [self.view addSubview:mileageLabel];
    mileageLabel=nil;
    
    
    self.mileagePicker=[[UIPickerView alloc]init];
    self.mileagePicker.frame=CGRectMake(220, 22, 102, 162);
    self.mileagePicker.showsSelectionIndicator=YES;
    [self.mileagePicker setDelegate:self];
    [self.mileagePicker setDataSource:self];
    [self.view addSubview:self.mileagePicker];
    
    self.mileageArray=[NSArray arrayWithObjects:@"0-5000",@"5000-10000",@"10000-25000",@"25000-50000",@"50000-75000",@"75000-100000",@"100000+", nil];
    
    
    self.mileageSelected=@"Mileage1";
    self.mileageValueSelected=@"0-5000";
    
    
    
    ///
    
    UILabel *yearLabel=[[UILabel alloc]init];
    yearLabel.frame=CGRectMake(12, 156, 100, 40);
    yearLabel.backgroundColor=[UIColor clearColor];
    yearLabel.text=[NSString stringWithFormat:@"Year"];
    [self.view addSubview:yearLabel];
    yearLabel=nil;
    
    
    self.yearPicker=[[UIPickerView alloc]init];
    self.yearPicker.frame=CGRectMake(3, 172, 154, 162); //previous width 115
    self.yearPicker.showsSelectionIndicator=YES;
    [self.yearPicker setDataSource:self];
    [self.yearPicker setDelegate:self];
    [self.view addSubview:self.yearPicker];
    
    //self.yearArray=[NSArray arrayWithObjects:@"2013",@"2012",@"2011",@"2010",@"2009",@"2008",@"2007",@"2002-2006",@"Older than 2002", nil];  
    self.yearArray=[NSArray arrayWithObjects:@"Current Year",@"One Year Old",@"Upto 3 Years Old",@"Upto 5 Years Old",@"Upto 10 Years Old",@"Any", nil];
    self.yearSelected=@"Year1a";
    self.yearValueSelected=@"Current Year";
    
    
    
    UILabel *priceLabel=[[UILabel alloc]init];
    priceLabel.frame=CGRectMake(152, 156, 100, 40);
    priceLabel.backgroundColor=[UIColor clearColor];
    priceLabel.text=[NSString stringWithFormat:@"Price($)"];
    [self.view addSubview:priceLabel];
    priceLabel=nil;
    
    
    self.pricePicker=[[UIPickerView alloc]init];
    self.pricePicker.frame=CGRectMake(142, 172, 144, 162);
    self.pricePicker.showsSelectionIndicator=YES;
    [self.pricePicker setDelegate:self];
    [self.pricePicker setDataSource:self];
    [self.view addSubview:self.pricePicker];
    
    self.priceArray=[NSArray arrayWithObjects:@"Below 20,000",@"20,000 to 50,000",@"50,000 to 75,000",@"75,000 to 100,000",@"Above 100,000", nil];
    self.priceIdSelected=@"Price1";
    self.priceValueSelected=@"Below 20,000";
    
    
    UIWebView *updateMakesAndModels=[[UIWebView alloc]initWithFrame:CGRectMake(10, 325, [CommonMethods findLabelWidth:@"Update Makes, Models"]+8, 25)]; //when using as button give y as 8
    updateMakesAndModels.scrollView.scrollEnabled=NO;
    updateMakesAndModels.opaque=NO;
    [updateMakesAndModels setBackgroundColor:[UIColor clearColor]];
    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    //if the email field is not Emp, show the webview, other wise hide it
    NSString *testString = @"<a href = \"obj://updateMakesModelsButtonTapped\">Update Makes, Models</a>";
    [updateMakesAndModels loadHTMLString:testString baseURL:nil];
    updateMakesAndModels.delegate=self;
    
    
    
    [self.view addSubview:updateMakesAndModels];
    //
    
    self.saveButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.frame=CGRectMake(180, 325, 60, 34);
    
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.saveButton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.saveButton makeGlossy];
    [self.view addSubview:self.saveButton];
    
    UITapGestureRecognizer *tapRecognizerForSaveButton = [[UITapGestureRecognizer alloc] 
                                                          initWithTarget:self
                                                          action:@selector(dismissKeyboardAndSave)];
    [tapRecognizerForSaveButton setCancelsTouchesInView:NO];
    [self.saveButton addGestureRecognizer:tapRecognizerForSaveButton];
    tapRecognizerForSaveButton=nil;
    
    self.cancelButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame=CGRectMake(250, 325, 60, 34);
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.cancelButton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.cancelButton makeGlossy];
    [self.view addSubview:self.cancelButton];
    
    UITapGestureRecognizer *tapRecognizerForCancelButton = [[UITapGestureRecognizer alloc] 
                                                            initWithTarget:self
                                                            action:@selector(dismissKeyboardAndCancel)];
    [tapRecognizerForCancelButton setCancelsTouchesInView:NO];
    [self.cancelButton addGestureRecognizer:tapRecognizerForCancelButton];
    tapRecognizerForCancelButton=nil;
    
    
    self.makesDictionary=[[NSMutableDictionary alloc]init];
    
    
    self.downloadOpQueue=[[NSOperationQueue alloc]init];
    [self.downloadOpQueue setName:@"EditPreferenceQueue"];
    [self.downloadOpQueue setMaxConcurrentOperationCount:1];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadMakesNotifMethod:) name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadModelsNotifMethod:) name:kDownloadModelsNotif object:nil];
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(makesOperationDownloadErrorNotifMethod:) name:@"MakesOperationDownloadErrorNotif" object:nil];
    
    [self downloadMakesIfNotPresentElseLoadMakes];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MakesOperationDownloadErrorNotif" object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark picker view data source methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.makesPicker]) {
        return 1;
    }
    else if ([pickerView isEqual:self.modelsPicker]) {
        return 1;
    } 
    else if ([pickerView isEqual:self.mileagePicker]) {
        return 1;
    }
    else if ([pickerView isEqual:self.yearPicker]) {
        return 1;
    }
    else if ([pickerView isEqual:self.pricePicker]) {
        return 1;
    }
    return 0;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //self.makesPicker.frame=CGRectMake(1, 30, 122, 162);
    if ([pickerView isEqual:self.makesPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        [mask setFrame: CGRectMake(9.0f, 20.0f, 100.0f, 120.0f)]; //2, 22, 120, 162
        [mask setCornerRadius: 5.0f];
        [self.makesPicker.layer setMask: mask];
        mask=nil;
        
        //makesPicker.frame=CGRectMake(3, 40, 120, 162);
        //[mask setFrame: CGRectMake(9.0f, 30.0f, 100.0f, 120.0f)];
        if(self.sortedMakes && self.sortedMakes.count)
        {
            return [self.sortedMakes count];
        }
        else
        {
            return 0;
        }
    } 
    else if ([pickerView isEqual:self.modelsPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        [mask setFrame: CGRectMake(9.0f, 20.0f, 114.0f, 120.0f)];
        [mask setCornerRadius: 5.0f];
        [self.modelsPicker.layer setMask: mask];
        mask=nil;
        
        //modelsPicker.frame=CGRectMake(125, 40, 100, 162);
        //[mask setFrame: CGRectMake(9.0f, 20.0f, 100.0f, 120.0f)];
        if(self.sortedModels && self.sortedModels.count)
        {
            return [self.sortedModels count];
        }
        else
        {
            return 0;
        }
    } 
    else if ([pickerView isEqual:self.mileagePicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        [mask setFrame: CGRectMake(9.0f, 20.0f, 82.0f, 120.0f)];
        [mask setCornerRadius: 5.0f];
        [self.mileagePicker.layer setMask: mask];
        mask=nil;
        
        if(self.mileageArray && self.mileageArray.count)
        {
            return [self.mileageArray count];
        }
        else
        {
            return 0;
        }
    }
    else if([pickerView isEqual:self.yearPicker])
    {
        CALayer *mask=[[CALayer alloc]init];
        [mask setBackgroundColor:[UIColor blackColor].CGColor];
        [mask setFrame:CGRectMake(8.0f, 20.0f, 135.0f, 120.0f)]; //previous width 96.0f
        [mask setCornerRadius:5.0f];
        [self.yearPicker.layer setMask:mask];
        mask=nil;
        
        if(self.yearArray && self.yearArray.count)
        {
            return [self.yearArray count];
        }
        else
        {
            return 0;
        }
    }
    else if ([pickerView isEqual:self.pricePicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        [mask setFrame: CGRectMake(8.0f, 20.0f, 125.0f, 120.0f)];
        [mask setCornerRadius: 5.0f];
        [self.pricePicker.layer setMask: mask];
        mask=nil;
        
        if(self.priceArray && self.priceArray.count)
        {
            return [self.priceArray count];
        }
        else
        {
            return 0;
        }
    }
    return 0;
}

#pragma mark -
#pragma mark picker view delegate methods

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGFloat width = [pickerView rowSizeForComponent:component].width;
    
    
    //    UILabel *pickerLabel = (view != nil)? (UILabel *)view : [[UILabel alloc] init];
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
            [pickerLabel setText:[self.sortedMakes objectAtIndex:row]];
    if(row>=0)    
        if(pickerView==self.modelsPicker)
        {
            [pickerLabel setText:[self.sortedModels objectAtIndex:row]];
        }
    if(row>=0)
        if(pickerView==self.mileagePicker)
        {
            [pickerLabel setText:[self.mileageArray objectAtIndex:row]];
        }
    if(row>=0)
        if([pickerView isEqual:self.yearPicker])    
        {
            [pickerLabel setText:[self.yearArray objectAtIndex:row]];
        }
    if(row>=0)
        if(pickerView==self.pricePicker)
        {
            [pickerLabel setText:[self.priceArray objectAtIndex:row]];
        }
    
    return pickerLabel; 
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.makesPicker]) {
        
        //when make component is selected, initialize modelid to nil
        self.modelIdSelected=nil;
        
        //depending on component 0 value selected, find the appropriate array if component 1
        
        //first find the id of corresponding make selected.
        
        __weak EditPreference *weakSelf=self;
        
        [self.makesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([(NSMutableString *)obj isEqualToString:[weakSelf.sortedMakes objectAtIndex:row]])
            {
                //NSLog(@"selected make is %@. id is %@",[weakSelf.sortedMakes objectAtIndex:row],key);
                
                weakSelf.makeIdSelected=(NSMutableString *)key;
                *stop=YES;
            }
        }];
        
        //start downloading models logic - begin
        //            [self startDownloadModelsOperation];
        [self loadModelsDataFromDiskForMake:self.makeIdSelected];
        
        //start downloading makes logic -end
        
        self.makeNameSelected=[self.sortedMakes objectAtIndex:row];
        //NSLog(@"makeNameSelected is %@",self.makeNameSelected);
    }
    
    if ([pickerView isEqual:self.modelsPicker])
    {
        __weak EditPreference *weakSelf=self;
        
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
    if ([pickerView isEqual:self.mileagePicker]) {
        self.mileageValueSelected=[self.mileageArray objectAtIndex:row];
        self.mileageSelected=[NSString stringWithFormat:@"Mileage%d",row+1];
    }
    
    if ([pickerView isEqual:self.yearPicker]) {
        self.yearValueSelected=[self.yearArray objectAtIndex:row];
        switch (row) {
            case 0:
                self.yearSelected=@"Year1a";
                break;
            case 1:
                self.yearSelected=@"Year1b";
                break;
            case 2:
                self.yearSelected=@"Year1";
                break;
            case 3:
                self.yearSelected=@"Year2";
                break;
            case 4:
                self.yearSelected=@"Year3";
                break;
            case 5:
                self.yearSelected=@"Year4";
                break;
            default:
                break;
        }
    }
    if ([pickerView isEqual:self.pricePicker]) {
        self.priceValueSelected=[self.priceArray objectAtIndex:row];
        self.priceIdSelected=[NSString stringWithFormat:@"Price%d",row+1];  
    }
}

-(void)dismissKeyboardAndSave {
    [self saveButtonTapped];
}

-(void)dismissKeyboardAndCancel {
    [self cancelButtonTapped];
}

-(void)dismissKeyboardAndUpdate {
    [self updateMakesModelsButtonTapped];
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


#pragma mark - Download Notif Methods

-(void)kDownloadMakesNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadMakesNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        [self loadMakesDataFromDisk];
        //NSLog(@"kDownloadMakesNotifMethod: download op started is %d",self.downloadOpStarted);
        [self startDownloadModelsOperation];
    }
    
}

-(void)kDownloadModelsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadModelsNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        //    self.modelsDictionary=[[notif userInfo]valueForKey:kModelsDictNotifKey];
        
        [[self makesPicker] selectRow:0 inComponent:0 animated:YES];
        //NSLog(@"kDownloadModelsNotifMethod: download op started is %d",self.downloadOpStarted);
        [[self makesPicker] setUserInteractionEnabled:YES];
        [[self modelsPicker] setUserInteractionEnabled:YES];
        
        [self loadModelsDataFromDiskForMake:@"0"];
        if (self.downloadOpStarted) {
            self.downloadOpStarted=NO;
            [self hideActivityViewer];
        }
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
        
        //[self.makesDictionary setObject:@"All Makes" forKey:@"0"];
        
        //NSLog(@"make id=%@ name=%@",[aMake valueForKey:@"makeID"],[aMake valueForKey:@"makeName"]);
    }
    
    //NSLog(@"Loaded makesDictionary %@ allMakes=%@", self.makesDictionary,allMakes);
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(allMakes)) {
        //NSLog(@"Error loading makes from coredata makes file.");
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
    
    //
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
    
    //NSLog(@"self.modelsDictionary=%@",self.modelsDictionary);
    
    if (IsEmpty(allmodels)) {
        //NSLog(@"Error loading models from coredata models file.");
        self.modelsDictionary=[NSDictionary dictionaryWithObject:@"All Models" forKey:@"0"];
    }
    
    [self startProcessingReceivedModels];
    [self loadModelsPickerWithData];
    
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
        [self readPreviousPreference];
    }
    
}


-(void)dealloc
{
    _prefNameReceived=nil;
    _delegate=nil;
    _makesDictionary=nil;
    _modelsDictionary=nil;
    _modelsInfoArray=nil;
    _sortedMakes=nil;
    _sortedModels=nil;
    _yearPicker=nil;
    _makesPicker=nil;
    _modelsPicker=nil;
    _mileagePicker=nil;
    _pricePicker=nil;
    _yearArray=nil;
    _mileageArray=nil;
    _priceArray=nil;
    _saveButton=nil;
    _cancelButton=nil;
    _makeIdSelected=nil;
    _modelIdSelected=nil;
    _priceIdSelected=nil;
    _priceValueSelected=nil;
    _mileageSelected=nil;
    _mileageValueSelected=nil;
    _makeNameSelected=nil;
    _modelNameSelected=nil;
    _yearSelected=nil;
    _yearValueSelected=nil;
    _zipSelected=nil;
    _zipLoadedFromPref=nil;
    [_downloadOpQueue cancelAllOperations];
    _downloadOpQueue=nil;
    _activityImageView=nil;
    _scrollView2=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
}

@end
