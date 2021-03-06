//
//  SearchMakesCollectionViewController.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/18/13.
//
//

#import "SearchMakesCollectionViewController.h"
#import "SearchMakesCollectionCell.h"

#import "CommonMethods.h"
#import "AppDelegate.h"
#import "Makes.h"
#import "Models.h"
#import "CheckZipCode.h"

#import "SearchModelsCollectionViewController.h"



@interface SearchMakesCollectionViewController ()

@property(strong,nonatomic) NSOperationQueue *downloadMakesOperationQueue;

@property(copy,nonatomic) NSString *makeIdSelected,*makeNameSelected;
@property(copy,nonatomic) NSString *zipSelected;

@property(strong,nonatomic)  NSMutableDictionary *makesDictionary,*modelsDictionary;
@property(strong,nonatomic)  NSMutableArray *sortedMakes,*sortedModels;

@property(copy,nonatomic) NSString *zipStr;
@property(strong,nonatomic) UIBarButtonItem *rightBarbutton;
@property(strong,nonatomic) UIAlertView *updateZipAlert;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(assign,nonatomic) BOOL isShowingLandscapeView;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;


@end

@implementation SearchMakesCollectionViewController

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



#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *LeftBarButtonHome=[[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(HomeButtonTapped)];
    self.navigationItem.leftBarButtonItem=LeftBarButtonHome;
    
    //
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //self.zipTextField.text=[defaults valueForKey:@"homeZipValue"];
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
    UIBarButtonItem *tempRightBarbutton=[[UIBarButtonItem alloc]initWithTitle:zipStrToDisply style:UIBarButtonItemStyleBordered target:self action:@selector(updateZip)];
    self.rightBarbutton=tempRightBarbutton;
    tempRightBarbutton=nil;
    //accessibility
    self.rightBarbutton.isAccessibilityElement=YES;
    self.rightBarbutton.accessibilityLabel=zipStrToDisplyAccessibilityLabel;
    
    self.navigationItem.rightBarButtonItem=self.rightBarbutton;
    
    
    
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 130, 44)];
    navtitle.text=@"Search Cars";
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    self.navigationItem.titleView=navtitle;
    navtitle=nil;
    
    self.collectionView.backgroundView = [CommonMethods backgroundImageOnCollectionView:self.collectionView];
    
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
    
    self.makeIdSelected=nil;
    //self.modelIdSelected=nil;
    self.zipStr=nil;
    //self.radiusSelected=nil;
    
    [self loadMakesDataFromDisk];
    
    self.downloadMakesOperationQueue=[[NSOperationQueue alloc]init];
    [self.downloadMakesOperationQueue setName:@"SearchViewQueue"];
    [self.downloadMakesOperationQueue setMaxConcurrentOperationCount:1];

    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.indicator stopAnimating];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
   // self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
	    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
       [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //[self cancelAllOperations];
    
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.sortedMakes && self.sortedMakes.count) {
        return self.sortedMakes.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchMakesCollectionCell *cell=(SearchMakesCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchMakesCollectionCellID" forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UILabel *newLbl=[[UILabel alloc] init];
    newLbl.text=self.sortedMakes[indexPath.item];
    CGSize newLblSize= [newLbl intrinsicContentSize];
    newLblSize.width+=2;
    newLblSize.height+=2;
    
    return newLblSize;
    
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)configureCell:(SearchMakesCollectionCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.makeLabel.text=self.sortedMakes[indexPath.item];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *btnTitle=self.sortedMakes[indexPath.item];
    NSLog(@"makeBtnTapped ... %@",btnTitle);
    
    
        //get models related to this make from coredata and pass zip, makename, makeid, all models with their ids to next view
        self.makeNameSelected=self.sortedMakes[indexPath.item];
        
        
        //
        __weak SearchMakesCollectionViewController *weakSelf=self;
        [self.makesDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if([(NSString *)obj isEqualToString:btnTitle])
            {
                //NSLog(@"selected make is %@. id is %@",[weakSelf.sortedMakes objectAtIndex:row],key);
                
                weakSelf.makeIdSelected=(NSString *)key;
                *stop=YES;
            }
        }];
        
        //
        
        //start downloading models logic - begin
        [self loadModelsDataFromDiskForMake:self.makeIdSelected];
        //start downloading models logic -end
        
        if (self.zipStr==nil) {
            self.zipStr=@"0";
        }
        NSDictionary *dictionary=@{@"zipCode":self.zipStr,@"makeName":self.makeNameSelected,@"makeID":self.makeIdSelected,@"modelsDictionary":self.modelsDictionary};
        
        [self performSegueWithIdentifier:@"SearchViewForModelsSegue" sender:dictionary];
        
        
    

}

#pragma mark - Private Methods
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

-(void)validateZip:(NSString *)zipToValidate
{
    //cancel if any previous validation is still running
    [self.downloadMakesOperationQueue cancelAllOperations];
    
    //disable screen as user may click on any visible car(if present)
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //self.view.userInteractionEnabled=NO;
    
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.downloadMakesOperationQueue addOperation:checkZipCode];
    //checkZipCode=nil;
    
}


#pragma mark - Load Makes and Models

- (void) loadMakesDataFromDisk {
    
    
    [self.indicator startAnimating];

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
        if ([[aMake valueForKey:@"carsCount"] integerValue]>0) { //condition to take makes where there is atleast one car
            [self.makesDictionary setObject:[aMake valueForKey:@"makeName"] forKey:[aMake valueForKey:@"makeID"]];
        }
        
        
        //NSLog(@"make id=%@ name=%@",[aMake valueForKey:@"makeID"],[aMake valueForKey:@"makeName"]);
    }
    
    //NSLog(@"Loaded makesDictionary %@ allMakes=%@", self.makesDictionary,allMakes);
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    
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
        self.modelsDictionary=[[NSDictionary dictionaryWithObject:@"All Models" forKey:@"0"] mutableCopy];
    }
    
    [self startProcessingReceivedModels];
    //[self loadModelsPickerWithData];
}

-(void)startProcessingReceivedMakes
{
    self.sortedMakes = [[[self.makesDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    //    NSLog(@"sortedMakes is  %@",sortedMakes);
    
    if ([[self.makesDictionary allKeys] count]>1) {
        if ([self.sortedMakes containsObject:@"All Makes"]) {
            [self.sortedMakes removeObject:@"All Makes"];
        }
        
        //[self.sortedMakes insertObject:@"All Makes" atIndex:0];
        //[self.makesDictionary setObject:@"All Makes" forKey:@"0"];
    }
    
    self.makeNameSelected=[self.sortedMakes objectAtIndex:0];
    
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedMakes objectAtIndex:0];
    __weak SearchMakesCollectionViewController *weakSelf=self;
    [self.makesDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
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
    //[self loadModelsDataFromDiskForMake:self.makeIdSelected];
    [self displayMakesButtons:NO]; //YES
    
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


- (void)displayMakesButtons:(BOOL)showPopularMakes
{
    [self.collectionView reloadData];
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
}

#pragma mark - Prepare For Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"SearchViewForModelsSegue"]) {
        NSDictionary *dictionary=(NSDictionary *)sender;
        /*
         @{@"zipCode":self.zipStr,@"makeName":self.makeNameSelected,@"makeID":self.makeIdSelected,@"modelsDictionary":self.modelsDictionary};*/
        
        SearchModelsCollectionViewController *searchModelsCollectionViewController=[segue destinationViewController];
        
        searchModelsCollectionViewController.zipReceived=[dictionary objectForKey:@"zipCode"];
        searchModelsCollectionViewController.makeNameReceived=[dictionary objectForKey:@"makeName"];
        searchModelsCollectionViewController.makeIDReceived=[dictionary objectForKey:@"makeID"];
        searchModelsCollectionViewController.modelsDictionary=[dictionary objectForKey:@"modelsDictionary"];
        
        //NSLog(@"models=%@",[dictionary objectForKey:@"modelsDictionary"]);
        
    }
}

-(void)checkZipCodeNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    //self.view.userInteractionEnabled=YES;
    [self displayMakesButtons:NO]; //calling this again because the content size of scrollview is getting to 0. otherwise no need to call here again.
    
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
        [defaults setValue:self.zipStr forKey:@"homeZipValue"];
        [defaults synchronize];
        
        self.rightBarbutton.title=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        
        //        pass search parameters including zip to service
        //[self startSearchOperation];
    }
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
