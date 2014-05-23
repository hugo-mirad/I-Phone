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
#import "CFNetwork/CFNetwork.h"
#import "Makes.h"
#import "Models.h"
#import "CommonMethods.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CheckZipCode.h"


#define kOFFSET_FOR_KEYBOARD 130.0

@interface EditPreference()

@property(strong,nonatomic) NSMutableDictionary *makesDictionary,*modelsDictionary;
@property(strong,nonatomic) NSArray *modelsInfoArray;
@property(strong,nonatomic) NSMutableArray *sortedMakes,*sortedModels;
@property(strong,nonatomic) UIPickerView *yearPicker,*makesPicker,*modelsPicker,*mileagePicker,*pricePicker;
@property(strong,nonatomic) NSArray *yearArray,*mileageArray,*priceArray;
@property(strong,nonatomic) CheckButton *saveButton,*cancelButton;

@property (strong, nonatomic) TPKeyboardAvoidingScrollView *editPrefScrollView;

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

@property(strong,nonatomic) UIImageView *backgroundImageView;


@property(strong, nonatomic) UITextField *makeTextField,*mileageTextField,*modelTextField,*yearTextField,*priceTextField,*zipTextField;

@property(strong,nonatomic) NSArray *allMakes;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

- (void) loadMakesDataFromDisk;
- (void)loadModelsDataFromDiskForMake:(NSString *)aMakeId;
- (void)loadModelsPickerWithData;
- (void)downloadMakesIfNotPresentElseLoadMakes;

- (BOOL)firstResponderFound;


@end



@implementation EditPreference


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

- (BOOL)duplicatePrefAlreadyExistsWithMakeId:(NSString *)someMakeID modelId:(NSString *)someModelId yearValue:(NSString *)someYear priceValue:(NSString *)somePriceId mileageValue:(NSString *)someMileage zipID:(NSString *)someZipRec
{
    //read all plist files
    BOOL success,matchingPrefFound=NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSRange rangeOfPrefNum=NSMakeRange(10,1);
    NSString *prefNameOfNewPref=[self.prefNameReceived substringWithRange:rangeOfPrefNum];
    NSInteger prefNumOfNewPref=[prefNameOfNewPref integerValue];
    
    //now read all plist files from 1 to prefNumOfNewPref
    
    for (int i=1; i<=prefNumOfNewPref; i++) {
        NSString *filename=[NSString stringWithFormat:@"Preference%d.plist",i];
        
        
        
        NSString *plistToCheck = [dbPath stringByAppendingPathComponent:filename];
        success = [fileManager fileExistsAtPath:plistToCheck];
        
        if (success)
        {
            
            NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:plistToCheck];
            if ([[dict objectForKey:@"makeIdSelected"] isEqualToString:someMakeID] && [[dict objectForKey:@"modelIdSelected"] isEqualToString:someModelId] && [[dict objectForKey:@"priceIdSelected"] isEqualToString:somePriceId] && [[dict objectForKey:@"yearSelected"] isEqualToString:someYear] && [[dict objectForKey:@"mileageSelected"] isEqualToString:someMileage] && [[dict objectForKey:@"zipSelected"] isEqualToString:someZipRec]) {
                matchingPrefFound=YES;
            }
        }
       
    }
    
    return matchingPrefFound;
    
}

-(void)savePreference
{
    //check if duplicate pref already exists
    
    BOOL duplicatePrefAlreadyExists=[self duplicatePrefAlreadyExistsWithMakeId:self.makeIdSelected modelId:self.modelIdSelected yearValue:self.yearSelected priceValue:self.priceIdSelected mileageValue:self.mileageSelected zipID:self.zipSelected];
    
    if (duplicatePrefAlreadyExists) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Duplicate Preference Found" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        return;
        
    }
    // save make, make id, model, model id, year, price, mileage to plist.
   
    
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",self.prefNameReceived];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    
    
    NSMutableDictionary *carDictionaryToSave=[[NSMutableDictionary alloc]init];
    if (IsEmpty(self.makeIdSelected)) {
        self.makeIdSelected=@"0";
        self.makeNameSelected=@"All Makes";
        self.modelIdSelected=@"0";
        self.modelNameSelected=@"All Models";
        self.mileageValueSelected=@"0-5000";
    }
    /*
     When there is no internet and when there are no makes, models, clicking the save button in preference is causing crash at savePreference > [carDictionaryToSave setObject:self.makeIdSelected forKey:@"makeIdSelected"];
     
     because self.makeIdSelected, makeNameSelected, modelIdSelected, modelNameSelected is nil, mileageValueSelected(No symbol "mileageValueSelected" in current context)
     */
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
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *preferenceZip=[defaults valueForKey:@"preferenceZip"];
//    
//    
//    if (preferenceZip==nil) {
//        [defaults setValue:@"0" forKey:@"preferenceZip"];
//        [defaults synchronize];
//        preferenceZip=@"0";
//    }
//    
//    ////
//    self.zipSelected=preferenceZip;
//    
//    
//    [self savePreference];
    
    if (self.zipTextField.text==nil || [self.zipTextField.text  isEqual: @""] || [self.zipTextField.text  isEqual: @"0"]) {
        
        self.zipSelected=@"0";
        [self savePreference];
    }
    else{
        
        self.zipSelected = self.zipTextField.text;
        [self validateZip:self.zipSelected];
    }
    
}
-(void)validateZip:(NSString *)zipStrRec
{
    [self.downloadOpQueue cancelAllOperations];
    
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipStrRec;
    [self.downloadOpQueue addOperation:checkZipCode];
    checkZipCode=nil;
    
}

#pragma mark - Notif Methods
-(void)checkZipCodeNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    
    //remove activityviewer which was show in validatezip method
    
    if([[[notif userInfo] valueForKey:@"CheckZipCodeNotifKey"] isKindOfClass:[NSError class]])
    {
        
        NSError *error=[[notif userInfo] valueForKey:@"CheckZipCodeNotifKey"];
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        
        UIAlertView *alert=[[UIAlertView alloc]init];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        
        
        if ([error code]==kCFURLErrorNotConnectedToInternet)
        {
            //self.footerLabel.text =@"Connection Failed ...";
            
            alert.title=@"No Internet Connection";
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==kCFURLErrorTimedOut)
        {
            //self.footerLabel.text =@"The request timed out.";
            
            alert.title=@"Error Occured";
            alert.message=@"The request timed out.";
        }
        else
        {
            //self.footerLabel.text =@"Server Error ...";
            
            alert.title=@"Server Error";
            //alert.message=[error description];
            alert.message=@"UCE Car Finder cannot retrieve data due to server error.";
        }
        
        //[self.footerLabel setNeedsDisplay];
        
        
        [alert show];
        alert=nil;
        
        ////
        
        return;
    }
    
    NSString *boolValStr=[[notif userInfo]valueForKey:@"CheckZipCodeNotifKey"];
    
    if(boolValStr==nil)
        return;
    
    if ([boolValStr isEqualToString:@"false"]) {
        NSLog(@"Zip is invalid");
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Zip" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        
        
    }
    else
    {
        //zip is valid
        NSLog(@"Zip is valid");
        //now send the service call.
        [self savePreference];
    }
}


-(void)cancelButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)startProcessingReceivedModels
{
    self.sortedModels = [[[self.modelsDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
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
    
    [self.modelsDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqualToString:firstValue])
        {
            
            weakSelf.modelIdSelected=key;
            *stop=YES;
        }
    }];
    
    
}

-(void)startProcessingReceivedMakes
{
    self.sortedMakes = [[[self.makesDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    
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
    
    [self.makesDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        if([(NSMutableString *)obj isEqualToString:firstValue])
        {
            
            weakSelf.makeIdSelected=(NSMutableString *)key;
            *stop=YES;
        }
    }];
    
    
    
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
    if (self.isShowingLandscapeView) {
        [CommonMethods showActivityViewerForLandscape:self.view];
    }
    else
    {
        [CommonMethods showActivityViewer:self.view];
    }
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
}

-(void)updateMakesModelsButtonTapped
{
    self.downloadOpStarted=YES;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
    [self.makesPicker reloadComponent:0];
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

-(void)loadTextFieldsWithPreviousPreferenceIfPresent
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
            
            
            
            self.makeTextField.text=[myPrefDict objectForKey:@"makeNameSelected"];
            self.modelTextField.text=[myPrefDict objectForKey:@"modelNameSelected"];
            self.mileageTextField.text=[myPrefDict objectForKey:@"mileageValueSelected"];
            self.yearTextField.text=[myPrefDict objectForKey:@"yearValueSelected"];
            self.priceTextField.text=[myPrefDict objectForKey:@"priceValueSelected"];
            
            [self loadPickersWithPreviousData:myPrefDict];
            
        }
        else
        {
            NSLog(@"There is no prev preference set. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        }
    }
    else
    {
        self.makeIdSelected=@"0";
        self.makeNameSelected=@"All Makes";
        self.modelIdSelected=@"0";
        self.modelNameSelected=@"All Models";
        self.mileageSelected=@"Mileage1";
        self.mileageValueSelected=@"0-5000";
        self.priceIdSelected=@"Price1";
        self.priceValueSelected=@"Below 20,000";
        self.yearSelected=@"Year1a";
        self.yearValueSelected=@"Current Year";
        
        self.makeTextField.text=@"All Makes";
        self.modelTextField.text=@"All Models";
        self.mileageTextField.text=@"0-5000";
        self.yearTextField.text=@"Current Year";
        self.priceTextField.text=@"Below 20,000";
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
    navtitle.text=[NSString stringWithFormat:@"%@",self.prefNameReceived]; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    UIView *superview = self.view;
    self.backgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"back.png"]];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [superview addSubview:self.backgroundImageView];
    
    
    //autolayout constraints
    
    
    [self.backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //left of av
    
    
    
    avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //right of av
    
    avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //bottom of av
    
    
    avAConstraint1 =
    [NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:0
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:avAConstraint1]; //top of av to top of self.view
    
    self.editPrefScrollView=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height)]; //150 49 for tab bar
    
    //
    self.editPrefScrollView.showsVerticalScrollIndicator=YES;
    self.editPrefScrollView.scrollEnabled=YES;
    self.editPrefScrollView.userInteractionEnabled=YES;
    
    //
    [self.backgroundImageView addSubview:self.editPrefScrollView];
    //autolayout
    [self.editPrefScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
//    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
//    [self.backgroundImageView addConstraint:scrollView1Constraint];
//    
//    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    
     if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.backgroundImageView addConstraint:scrollView1Constraint];
     
     }
     else
     {
         CGRect rect;
         
         rect = [[UIApplication sharedApplication] statusBarFrame];
         
         // from inside the view controller
         CGSize tabBarSize = [[[self tabBarController] tabBar] bounds].size;
         
         scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationController.navigationBar.frame.size.height+rect.size.height];
         [self.backgroundImageView addConstraint:scrollView1Constraint];
         
         scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.editPrefScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:-tabBarSize.height];
         [self.backgroundImageView addConstraint:scrollView1Constraint];
    
     }
    
    
    UILabel *makeLabel=[[UILabel alloc]init];
    makeLabel.frame=CGRectMake(12, 6, 70, 30);
    makeLabel.backgroundColor=[UIColor clearColor];
    makeLabel.text=[NSString stringWithFormat:@"Make :"];
    makeLabel.textColor = [UIColor whiteColor];
    [self.editPrefScrollView addSubview:makeLabel];
    makeLabel=nil;
    
    
    
    self.makeTextField = [[UITextField alloc] initWithFrame:CGRectMake(85, 10, 220, 30)];
    self.makeTextField.backgroundColor = [UIColor clearColor];
    self.makeTextField.placeholder = @"Make";
    self.makeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.makeTextField.textColor = [UIColor whiteColor];
    self.makeTextField.tag = 1;
    [self.editPrefScrollView addSubview:self.makeTextField];
    self.makeTextField.delegate = self;
    
    
    
    
    self.makesPicker =[[UIPickerView alloc]init];
    // self.makesPicker.frame=CGRectMake(2, 22, 120, 162);
    //self.makesPicker.showsSelectionIndicator=YES;
    [self.makesPicker setDelegate:self];
    [self.makesPicker setDataSource:self];
    // self.makesPicker.hidden = YES;////////////////////////////////******picker hidden
    // [self.view addSubview:self.makesPicker];
    
    
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    
    myToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(makeDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButton =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButton =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [myToolbar setItems:[NSArray arrayWithObjects:previousButton,nextButton,spaceButton,doneButton,nil] animated:NO];
    
    
    self.makeTextField.inputAccessoryView = myToolbar;
    
    
    
    
    
    UILabel *modelLabel=[[UILabel alloc]init];
    modelLabel.frame=CGRectMake(12, 52, 70, 30);
    modelLabel.backgroundColor=[UIColor clearColor];
    modelLabel.text=[NSString stringWithFormat:@"Model :"];
    modelLabel.textColor = [UIColor whiteColor];
    [self.editPrefScrollView addSubview:modelLabel];
    modelLabel=nil;
    
    
    self.modelTextField = [[UITextField alloc] initWithFrame:CGRectMake(85, 56, 220, 30)];
    self.modelTextField.backgroundColor = [UIColor clearColor];
    self.modelTextField.placeholder = @"Model";
    self.modelTextField.textColor = [UIColor whiteColor];
    self.modelTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.modelTextField.tag = 2;
    [self.editPrefScrollView addSubview:self.modelTextField];
    
    self.modelTextField.delegate = self;
    
    
    
    self.modelsPicker=[[UIPickerView alloc]init];
    //self.modelsPicker.frame=CGRectMake(104, 22, 134, 162);
    // self.modelsPicker.showsSelectionIndicator=YES;
    [self.modelsPicker setDelegate:self];
    [self.modelsPicker setDataSource:self];
    // self.modelsPicker.hidden = YES;////////////////////////////////******picker hidden
    // [self.view addSubview:self.modelsPicker];
    
    
    
    
    UIToolbar *modelToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    
    modelToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButtonmodelToolbar =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(modelDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButtonmodelToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonmodelToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButtonmodelToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [modelToolbar setItems:[NSArray arrayWithObjects:previousButtonmodelToolbar,nextButtonmodelToolbar,spaceButtonmodelToolbar,doneButtonmodelToolbar,nil] animated:NO];
    
    
    self.modelTextField.inputAccessoryView = modelToolbar;
    
    
    
    UILabel *mileageLabel=[[UILabel alloc]init];
    mileageLabel.frame=CGRectMake(12, 102, 70, 40);
    mileageLabel.backgroundColor=[UIColor clearColor];
    mileageLabel.text=[NSString stringWithFormat:@"Mileage :"];
    mileageLabel.textColor = [UIColor whiteColor];
    [self.editPrefScrollView addSubview:mileageLabel];
    mileageLabel=nil;
    
    
    
    self.mileageTextField = [[UITextField alloc] initWithFrame:CGRectMake(85, 106, 220, 30)];
    self.mileageTextField.backgroundColor = [UIColor clearColor];
    self.mileageTextField.placeholder = @"mileage";
    self.mileageTextField.textColor = [UIColor whiteColor];
    self.mileageTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.mileageTextField.tag = 3;
    [self.editPrefScrollView addSubview:self.mileageTextField];
    
    self.mileageTextField.delegate = self;
    
    
    
    self.mileagePicker=[[UIPickerView alloc]init];
    // self.mileagePicker.frame=CGRectMake(220, 22, 102, 162);
    // self.mileagePicker.showsSelectionIndicator=YES;
    [self.mileagePicker setDelegate:self];
    [self.mileagePicker setDataSource:self];
    // self.mileagePicker.hidden = YES;////////////////////////////////******picker hidden
    // [self.view addSubview:self.mileagePicker];
    
    self.mileageArray=[NSArray arrayWithObjects:@"0-5000",@"5000-10000",@"10000-25000",@"25000-50000",@"50000-75000",@"75000-100000",@"100000+", nil];
    
    
    self.mileageSelected=@"Mileage1";
    self.mileageValueSelected=@"0-5000";
    
    
    
    
    
    UIToolbar *mileageToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    
    mileageToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButtonmoileageToolbar =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(mileageToolBarDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButtonmoileageToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonmoileageToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButtonmoileageToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [mileageToolbar setItems:[NSArray arrayWithObjects:previousButtonmoileageToolbar,nextButtonmoileageToolbar,spaceButtonmoileageToolbar,doneButtonmoileageToolbar,nil] animated:NO];
    
    
    self.mileageTextField.inputAccessoryView = mileageToolbar;
    
    
    
    ///
    
    UILabel *yearLabel=[[UILabel alloc]init];
    yearLabel.frame=CGRectMake(12, 152, 70, 40);
    yearLabel.backgroundColor=[UIColor clearColor];
    yearLabel.text=[NSString stringWithFormat:@"Year :"];
    yearLabel.textColor = [UIColor whiteColor];
    [self.editPrefScrollView addSubview:yearLabel];
    yearLabel=nil;
    
    self.yearTextField = [[UITextField alloc] initWithFrame:CGRectMake(85, 156, 220, 30)];
    self.yearTextField.backgroundColor = [UIColor clearColor];
    self.yearTextField.placeholder = @"year";
    self.yearTextField.textColor = [UIColor whiteColor];
    self.yearTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.yearTextField.tag = 4;
    [self.editPrefScrollView addSubview:self.yearTextField];
    
    self.yearTextField.delegate = self;
    
    
    
    self.yearPicker=[[UIPickerView alloc]init];
    ///  self.yearPicker.frame=CGRectMake(3, 172, 154, 162); //previous width 115
    // self.yearPicker.showsSelectionIndicator=YES;
    [self.yearPicker setDataSource:self];
    [self.yearPicker setDelegate:self];
    //self.yearPicker.hidden = YES;////////////////////////////////******picker hidden
    // [self.view addSubview:self.yearPicker];
    
    //self.yearArray=[NSArray arrayWithObjects:@"2013",@"2012",@"2011",@"2010",@"2009",@"2008",@"2007",@"2002-2006",@"Older than 2002", nil];
    self.yearArray=[NSArray arrayWithObjects:@"Current Year",@"One Year Old",@"Upto 3 Years Old",@"Upto 5 Years Old",@"Upto 10 Years Old",@"Any", nil];
    self.yearSelected=@"Year1a";
    self.yearValueSelected=@"Current Year";
    
    
    
    
    UIToolbar *yearToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    
    yearToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButtonyearToolbar =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(yearDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButtonyearToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonyearToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButtonyearToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [yearToolbar setItems:[NSArray arrayWithObjects:previousButtonyearToolbar,nextButtonyearToolbar,spaceButtonyearToolbar,doneButtonyearToolbar,nil] animated:NO];
    
    
    self.yearTextField.inputAccessoryView = yearToolbar;
    
    
    
    
    
    UILabel *priceLabel=[[UILabel alloc]init];
    priceLabel.frame=CGRectMake(12, 202, 70, 40);
    priceLabel.backgroundColor=[UIColor clearColor];
    priceLabel.text=[NSString stringWithFormat:@"Price($) :"];
    priceLabel.textColor = [UIColor whiteColor];
    [self.editPrefScrollView addSubview:priceLabel];
    priceLabel=nil;
    
    
    self.priceTextField = [[UITextField alloc] initWithFrame:CGRectMake(85, 206, 220, 30)];
    self.priceTextField.backgroundColor = [UIColor clearColor];
    self.priceTextField.placeholder = @"Price";
    self.priceTextField.textColor = [UIColor whiteColor];
    self.priceTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.priceTextField.tag = 5;
    [self.editPrefScrollView addSubview:self.priceTextField];
    
    self.priceTextField.delegate = self;
    
    
    
    
    self.pricePicker=[[UIPickerView alloc]init];
    // self.pricePicker.frame=CGRectMake(142, 172, 144, 162);
    // self.pricePicker.showsSelectionIndicator=YES;
    [self.pricePicker setDelegate:self];
    [self.pricePicker setDataSource:self];
    // [self.view addSubview:self.pricePicker];
    
    self.priceArray=[NSArray arrayWithObjects:@"Below 20,000",@"20,000 to 50,000",@"50,000 to 75,000",@"75,000 to 100,000",@"Above 100,000", nil];
    
    self.priceIdSelected=@"Price1";
    self.priceValueSelected=@"Below 20,000";
    
    
    
    UIToolbar *priceToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    
    priceToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButtonpriceToolbar =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(priceDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButtonpriceToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonpriceToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButtonpriceToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [priceToolbar setItems:[NSArray arrayWithObjects:previousButtonpriceToolbar,nextButtonpriceToolbar,spaceButtonpriceToolbar,doneButtonpriceToolbar,nil] animated:NO];
    
    
    self.priceTextField.inputAccessoryView = priceToolbar;
    
    
    
    //  zipTextField
    
    
    
    UILabel *zipLabel=[[UILabel alloc]init];
    zipLabel.frame=CGRectMake(12, 250, 70, 40);
    zipLabel.backgroundColor=[UIColor clearColor];
    zipLabel.text=[NSString stringWithFormat:@"zip :"];
    zipLabel.textColor = [UIColor whiteColor];
    [self.editPrefScrollView addSubview:zipLabel];
    zipLabel=nil;
    
    
    self.zipTextField = [[UITextField alloc] initWithFrame:CGRectMake(85, 256, 220, 30)];
    self.zipTextField.backgroundColor = [UIColor clearColor];
    self.zipTextField.placeholder = @"Enter zip";
    self.zipTextField.textColor = [UIColor whiteColor];
    self.zipTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.zipTextField.keyboardType = UIKeyboardTypePhonePad;
    self.zipTextField.tag = 6;
    [self.editPrefScrollView addSubview:self.zipTextField];
    
    self.zipTextField.delegate = self;
    
    
    
    UIToolbar *zipToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    
    zipToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButtonZipToolbar =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(zipDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButtonZipToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonZipToolbar =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButtonZipToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [zipToolbar setItems:[NSArray arrayWithObjects:previousButtonZipToolbar,nextButtonZipToolbar,spaceButtonZipToolbar,doneButtonZipToolbar,nil] animated:NO];
    
    
    self.zipTextField.inputAccessoryView = zipToolbar;
    
    
        //    UIWebView *updateMakesAndModels=[[UIWebView alloc]initWithFrame:CGRectMake(10, 325, [CommonMethods findLabelWidth:@"Update Makes, Models"]+8, 25)]; //when using as button give y as 8
    //    updateMakesAndModels.scrollView.scrollEnabled=NO;
    //    updateMakesAndModels.opaque=NO;
    //    [updateMakesAndModels setBackgroundColor:[UIColor clearColor]];
    //    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    //    //if the email field is not Emp, show the webview, other wise hide it
    //    NSString *testString = @"<a href = \"obj://updateMakesModelsButtonTapped\">Update Makes, Models</a>";
    //    [updateMakesAndModels loadHTMLString:testString baseURL:nil];
    //    updateMakesAndModels.delegate=self;
    
    
    
    // [self.view addSubview:updateMakesAndModels];
    //
    
    self.saveButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.frame=CGRectMake(180, 320, 80, 30);
    
    self.saveButton.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:2.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    [self.saveButton setTitle:@"SAVE" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
    self.saveButton.layer.shadowRadius = 2.0f;
    self.saveButton.layer.shadowOpacity = 0.5f;
    self.saveButton.layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
   
    [self.saveButton addTarget:self action:@selector(dismissKeyboardAndSave) forControlEvents:UIControlEventTouchUpInside];
    
    [self.editPrefScrollView addSubview:self.saveButton];
    
    
    self.cancelButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame=CGRectMake(80, 320, 80, 30);
    
    self.cancelButton.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self.cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:105.0f/255.0f green:90.0f/255.0f blue:85.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.cancelButton.layer.shadowRadius = 2.0f;
    self.cancelButton.layer.shadowOpacity = 0.5f;
    self.cancelButton.layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];

    
  
    [self.cancelButton addTarget:self action:@selector(dismissKeyboardAndCancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self.editPrefScrollView addSubview:self.cancelButton];
    
    
    self.makesDictionary=[[NSMutableDictionary alloc]init];
    
    
    self.downloadOpQueue=[[NSOperationQueue alloc]init];
    [self.downloadOpQueue setName:@"EditPreferenceQueue"];
    [self.downloadOpQueue setMaxConcurrentOperationCount:1];
    
    
    self.editPrefScrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-100);
    
    
    
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadMakesNotifMethod:) name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadModelsNotifMethod:) name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(makesOperationDownloadErrorNotifMethod:) name:@"MakesOperationDownloadErrorNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self downloadMakesIfNotPresentElseLoadMakes];
    [self loadTextFieldsWithPreviousPreferenceIfPresent];
    //[self readPreviousPreference];
}

/*
 - (void)loadPickersWithUserData
 {
 BOOL success;
 //      NSError *error;
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
 
 NSString *filename=[NSString stringWithFormat:@"%@.plist",self.prefNameReceived];
 
 NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
 success = [fileManager fileExistsAtPath:writablePath];
 
 BOOL previousDataOfUserFound=NO;
 
 if(success)
 {
 NSDictionary *myPrefDict=[[NSDictionary alloc]initWithContentsOfFile:writablePath];
 if ([myPrefDict objectForKey:@"makeIdSelected"]) {
 
 previousDataOfUserFound=YES;
 }
 }
 
 
 
 
 
 if (previousDataOfUserFound) {
 
 NSInteger indexOfMakeName=[self.sortedMakes indexOfObject:self.makeNameSelected];
 
 [self.makesPicker selectRow:indexOfMakeName inComponent:0 animated:YES];
 }
 
 
 
 
 
 }
 */
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self loadPickersWithUserData];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MakesOperationDownloadErrorNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
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
    if (interfaceOrientation!=UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}



#pragma mark - Toolbar Button Methods

-(void)makeDoneButtonTapped
{
    [self.makeTextField resignFirstResponder];
    
}

-(void)modelDoneButtonTapped
{
    [self.modelTextField resignFirstResponder];
}

-(void)mileageToolBarDoneButtonTapped
{
    [self.mileageTextField resignFirstResponder];
    
    CGPoint offsetPoint=CGPointMake(0, 0);
    
    self.editPrefScrollView.contentOffset = offsetPoint;
}

-(void)yearDoneButtonTapped
{
    [self.yearTextField resignFirstResponder];
    
    CGPoint offsetPoint=CGPointMake(0, 0);
    
    self.editPrefScrollView.contentOffset = offsetPoint;
    
}

-(void)priceDoneButtonTapped
{
    [self.priceTextField resignFirstResponder];
    
    
    
    CGPoint offsetPoint=CGPointMake(0, 0);
    
    self.editPrefScrollView.contentOffset = offsetPoint;
    
    
}

-(void)zipDoneButtonTapped
{
    [self.zipTextField resignFirstResponder];
    
    
    
    CGPoint offsetPoint=CGPointMake(0, 0);
    
    self.editPrefScrollView.contentOffset = offsetPoint;
    
    
}

////Previous and Next Button Tapped

-(void)previousButtonTapped
{
    UITextField *tempTxF = nil;
    
    
    tempTxF = nil;
    
    for (int i = 1; i<=6; i++)
    {
        tempTxF = (UITextField *)[self.view viewWithTag:i];
        
        if ([tempTxF isFirstResponder])
        {
            i--;
            
            if (i==0) {
                break;
            }
            tempTxF = (UITextField *)[self.view viewWithTag:i];
            
            [tempTxF becomeFirstResponder];
            
            break;
        }
    }
    
    
}


-(void)NextButtonTapped

{
    
    UITextField *tempTxF = nil;
    
    tempTxF = nil;
    
    for (int i = 1; i<=6; i++)
    {
        tempTxF = (UITextField *)[self.view viewWithTag:i];
        
        if ([tempTxF isFirstResponder])
        {
            i++;
            
            if (i==13) {
                break;
            }
            tempTxF = (UITextField *)[self.view viewWithTag:i];
            
            [tempTxF becomeFirstResponder];
            break;
        }
    }
    
    //if there is only 1 model for a make, then we have to display that particular model instead of "All Model" for models text field. This logic is not required for previousButtonTapped
    if ([self.modelTextField isFirstResponder]) {
        if ([self.sortedModels count]==1) {
            self.modelTextField.text=[self.sortedModels objectAtIndex:0];
            
            self.modelIdSelected=[[self.modelsDictionary allKeys] objectAtIndex:0];
            self.modelNameSelected=[self.sortedModels objectAtIndex:0];
            
        }
        else {
            self.modelIdSelected=@"0";
            self.modelNameSelected=@"All Models";
            
            self.modelTextField.text=@"All Models";
        }
    }
    
}




//************************Text field Delegate Methods

#pragma mark - Text Field Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField

{
    
    if ([textField isEqual:self.makeTextField]) {
        
        // exteriorColorPicker
        
        self.makesPicker.showsSelectionIndicator = YES;
        //myPickerView configuration here...
        self.makeTextField.inputView = self.makesPicker;
        
        
        return YES;
    }
    else if ([textField isEqual:self.modelTextField]) {
        
        // exteriorColorPicker
        
        self.modelsPicker.showsSelectionIndicator = YES;
        //myPickerView configuration here...
        self.modelTextField.inputView = self.modelsPicker;
        
        
        return YES;
    }
    else if ([textField isEqual:self.mileageTextField]) {
        
        // exteriorColorPicker
        
        self.mileagePicker.showsSelectionIndicator = YES;
        //myPickerView configuration here...
        self.mileageTextField.inputView = self.mileagePicker;
        
        
        return YES;
    }
    else if ([textField isEqual:self.yearTextField]) {
        
        // exteriorColorPicker
        
        self.yearPicker.showsSelectionIndicator = YES;
        //myPickerView configuration here...
        self.yearTextField.inputView = self.yearPicker;
        
        
        return YES;
    }
    
    else if ([textField isEqual:self.priceTextField]) {
        
        // exteriorColorPicker
        
        self.pricePicker.showsSelectionIndicator = YES;
        //myPickerView configuration here...
        self.priceTextField.inputView = self.pricePicker;
        
        
        return YES;
    }
    
    
    
    
    return YES;
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([textField isEqual:self.zipTextField]) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 5) ? NO : YES;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
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



- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //self.makesPicker.frame=CGRectMake(1, 30, 122, 162);
    
    
    if ([pickerView isEqual:self.makesPicker]) {
        
        
        if(self.sortedMakes && self.sortedMakes.count)
        {
            return [self.sortedMakes count];
        }
        
    }
    else if([pickerView isEqual:self.modelsPicker])
    {
        if(self.sortedModels && self.sortedModels.count)
        {
            return [self.sortedModels count];
        }
    }
    else if([pickerView isEqual:self.mileagePicker])
    {
        if(self.mileageArray && self.mileageArray.count)
        {
            return [self.mileageArray count];
        }
    }
    
    
    else if([pickerView isEqual:self.yearPicker])
    {
        if(self.yearArray && self.yearArray.count)
        {
            return [self.yearArray count];
        }
    }
    else if([pickerView isEqual:self.pricePicker])
    {
        if(self.priceArray && self.priceArray.count)
        {
            return [self.priceArray count];
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
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor whiteColor]];
        [pickerLabel setText:@"hello"];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        
        
        pickerLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if([pickerView isEqual:self.makesPicker])
    {
        [pickerLabel setText:[self.sortedMakes objectAtIndex:row]];
    }
    else if([pickerView isEqual:self.modelsPicker])
    {
        [pickerLabel setText:[self.sortedModels objectAtIndex:row]];
    }
    
    else if([pickerView isEqual:self.mileagePicker])
    {
        [pickerLabel setText:[self.mileageArray objectAtIndex:row]];
    }
    
    
    else if([pickerView isEqual:self.yearPicker])
    {
        [pickerLabel setText:[self.yearArray objectAtIndex:row]];
    }
    
    else if([pickerView isEqual:self.pricePicker])
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
        
        [self.makesDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if([(NSMutableString *)obj isEqualToString:[weakSelf.sortedMakes objectAtIndex:row]])
            {
                
                weakSelf.makeIdSelected=(NSMutableString *)key;
                *stop=YES;
            }
        }];
        //start downloading models logic - begin
        //            [self startDownloadModelsOperation];
        [self loadModelsDataFromDiskForMake:self.makeIdSelected];
        
        //start downloading makes logic -end
        
        self.makeNameSelected=[self.sortedMakes objectAtIndex:row];
        self.makeTextField.text=[self.sortedMakes objectAtIndex:row];
        
    }
    
    if ([pickerView isEqual:self.modelsPicker])
    {
        __weak EditPreference *weakSelf=self;
        
        [self.modelsDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if([obj isEqualToString:[weakSelf.sortedModels objectAtIndex:row]])
            {
                
                weakSelf.modelIdSelected=key;
                *stop=YES;
            }
        }];
        
        self.modelNameSelected=[self.sortedModels objectAtIndex:row];
        self.modelTextField.text = [self.sortedModels objectAtIndex:row];
    }
    
    
    if ([pickerView isEqual:self.mileagePicker]) {
        self.mileageValueSelected=[self.mileageArray objectAtIndex:row];
        self.mileageSelected=[NSString stringWithFormat:@"Mileage%d",row+1];
        
        self.mileageTextField.text = [self.mileageArray objectAtIndex:row];
    }
    
    if ([pickerView isEqual:self.yearPicker]) {
        self.yearValueSelected=[self.yearArray objectAtIndex:row];
        self.yearTextField.text = [self.yearArray objectAtIndex:row];
        
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
        
        self.priceTextField.text = [self.priceArray objectAtIndex:row];
        
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
        
        [[self makesPicker] selectRow:0 inComponent:0 animated:YES];
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
            alert.message=@"UCE Car Finder cannot retrieve data because of server error.";
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
    //  NSArray *allMakes=[self.managedObjectContext executeFetchRequest:request error:&error];
    
    self.allMakes=[self.managedObjectContext executeFetchRequest:request error:&error];
    if (self.makesDictionary==nil) {
        self.makesDictionary=[[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    
    for (Makes *aMake in self.allMakes) {
        if ([[aMake valueForKey:@"carsCount"] integerValue]>0) { //condition to take makes where there is atleast one car
            [self.makesDictionary setObject:[aMake valueForKey:@"makeName"] forKey:[aMake valueForKey:@"makeID"]];
        }
        
        //[self.makesDictionary setObject:@"All Makes" forKey:@"0"];
        
    }
    
    //NSLog(@"Loaded makesDictionary %@ allMakes=%@", self.makesDictionary,allMakes);
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(self.allMakes)) {
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
        
    }
    
    
    if (IsEmpty(allmodels)) {
        self.modelsDictionary=[[NSDictionary dictionaryWithObject:@"All Models" forKey:@"0"] mutableCopy];
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
    
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(allMakes)) {
        //lets call updateMakesModelsButtonTapped, so it will take care of downloading makes and models
        [self updateMakesModelsButtonTapped];
    }
    else
    {
        [self loadMakesDataFromDisk];
        //[self readPreviousPreference];
    }
    
}

#pragma mark - Keyboard Notifs
- (void)keyboardDidHide:(id)sender
{
    if (![self firstResponderFound]) {
        //self.vehicleInfoScrollView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        //[self.editPrefScrollView setContentInset:UIEdgeInsetsZero];
    }
}

- (BOOL)firstResponderFound
{
    
    BOOL firstResponderPresent=NO;
    
    for (UIView *subView in self.view.subviews) {
        
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *tField = (UITextField *)subView;
            
            if ([tField isFirstResponder]) {
                firstResponderPresent=YES;
                break;
            }
        }
    }
    
    return firstResponderPresent;
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
