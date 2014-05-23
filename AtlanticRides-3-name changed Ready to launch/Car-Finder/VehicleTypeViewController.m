//
//  VehicleTypeViewController.m
//  CarDetails
//
//  Created by Mac on 23/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "VehicleTypeViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CommonMethods.h"

//makes and models
#import "DownloadMakesOperation.h"
#import "DownloadModelsOperation.h"
#import "Makes.h"
#import "Models.h"

//for coredata
#import "AppDelegate.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "AFNetworking.h"
#import "LoginViewController.h"
#import "TPKeyboardAvoidingScrollView.h"


@interface VehicleTypeViewController()

@property(strong,nonatomic) UIPickerView *makesPicker,*modelsPicker,*yearPicker,*stylePicker;

@property(copy,nonatomic) NSString *makeNameSelected,*modelNameSelected;
@property(copy,nonatomic) NSString *makeIdSelected,*modelIdSelected;
@property(copy,nonatomic) NSString *yearSelected, *yearIdSelected, *bodyStyleSelected, *bodyStyleIdSelected;

@property(strong,nonatomic)  NSMutableDictionary *makesDictionary,*modelsDictionary;
@property(strong,nonatomic)  NSMutableArray *sortedMakes,*sortedModels,*sortedYears;


@property (strong, nonatomic) NSArray *bodyTypeIds;
@property (strong, nonatomic) NSArray *sortedBodyTypeStyles;

@property(strong,nonatomic) NSOperationQueue *downloadMakesOperationQueue;



@property(assign,nonatomic) BOOL downloadOpStarted, loggedUserMakeDataLoadedIntoMakePicker;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(strong,nonatomic) UIBarButtonItem *leftBarButton,*rightBarButton;

//-----------------

@property(strong, nonatomic) UITextField *makeTextField;
@property(strong, nonatomic) UITextField *modelTextField;
@property(strong, nonatomic) UITextField *yearTextField,*bodyStyleTextField;

@property(strong,nonatomic) UILabel *noteLabel;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

@property(strong,nonatomic) UIActivityIndicatorView *indicator;


- (void)downloadMakesIfNotPresentElseLoadMakes;
- (void)loadModelsDataFromDiskForMake:(NSString *)aMakeId;
- (void) loadMakesDataFromDisk;

-(void)retrieveLoggedUserPreviousData;
- (void)callWebServiceToSaveData;

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;
- (BOOL)userMadeChanges;
- (void)enableDisableFields:(BOOL)enable;

@end

@implementation VehicleTypeViewController


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

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view setBackgroundColor:[UIColor yellowColor]];
    
    
    [CommonMethods putBackgroundImageOnView:self.view];
    
    
    //navigation bar title
    NSString *navTitle=nil;
    if(self.carReceived!=nil)
    {
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.carReceived year],[self.carReceived make],[self.carReceived model]];
    }
    UILabel *titleLabel=[[UILabel alloc]init];
    
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:navTitle];
    [titleLabel sizeToFit];
    [self.navigationItem setTitleView:titleLabel];
    titleLabel=nil;
    
    //
    self.rightBarButton=({
        UIBarButtonItem *button=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonTapped:)];
        self.navigationItem.rightBarButtonItem = button;
        button;
    });
    
    
    self.leftBarButton=({
        UIBarButtonItem *button=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonTapped:)];
        self.navigationItem.leftBarButtonItem=button;
        button;
        
    });
    
    //set up scrollview
    TPKeyboardAvoidingScrollView *vehicleTypeScrollView=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:vehicleTypeScrollView];
    
    
    UIView* contentView = [UIView new];
    //contentView.backgroundColor = [UIColor greenColor];
    [vehicleTypeScrollView addSubview:contentView];
    
    UILabel *makeLabel=[[UILabel alloc]init];
    makeLabel.frame=CGRectMake(10, 20, 60, 30);
    makeLabel.backgroundColor=[UIColor clearColor];
    makeLabel.text=@"Make :";
    makeLabel.textColor=[UIColor whiteColor];
    makeLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:makeLabel];
    
    
    
    self.makeTextField = [[UITextField alloc] init];//WithFrame:CGRectMake(95, 20, 200, 30)];
    self.makeTextField.text = [self.carReceived make];
    self.makeTextField.enabled = NO;
    //self.makePickerTextField.tag = 8;
    self.makeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.makeTextField.backgroundColor = [UIColor clearColor];
    self.makeTextField.textColor = [UIColor whiteColor];
    [contentView addSubview:self.makeTextField];
    
    
    
    
    UILabel *modelLabel=[[UILabel alloc]init];
    //modelLabel.frame=CGRectMake(10, 60, 60, 30);
    modelLabel.backgroundColor=[UIColor clearColor];
    modelLabel.text=@"Model :";
    modelLabel.textColor=[UIColor whiteColor];
    modelLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:modelLabel];
    
    
    
    self.modelTextField = [[UITextField alloc] init];//WithFrame:CGRectMake(95, 60, 200, 30)];
    self.modelTextField.text = [self.carReceived model];
    self.modelTextField.enabled = NO;
    //self.makePickerTextField.tag = 8;
    self.modelTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.modelTextField.backgroundColor = [UIColor clearColor];
    self.modelTextField.textColor = [UIColor whiteColor];
    [contentView addSubview:self.modelTextField];
    
    
    
    UILabel *yearLabel=[[UILabel alloc]init];
    //yearLabel.frame=CGRectMake(10, 100, 60, 30);
    yearLabel.backgroundColor=[UIColor clearColor];
    yearLabel.text=@"Year :";
    yearLabel.textColor=[UIColor whiteColor];
    yearLabel.font=[UIFont boldSystemFontOfSize:15];
    [contentView addSubview:yearLabel];
    
    
    self.yearTextField = [[UITextField alloc] init];//WithFrame:CGRectMake(95, 100, 200, 30)];
    
    self.yearTextField.text = [NSString stringWithFormat:@"%d",[self.carReceived year]];
    self.yearTextField.enabled = NO;
    //self.makePickerTextField.tag = 8;
    self.yearTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.yearTextField.backgroundColor = [UIColor clearColor];
    self.yearTextField.textColor = [UIColor whiteColor];
    [contentView addSubview:self.yearTextField];
    
    
    
    UILabel *bodyStyleLabel=[[UILabel alloc]init];
    //bodyStyleLabel.frame=CGRectMake(10, 206, 85, 30);
    bodyStyleLabel.backgroundColor=[UIColor clearColor];
    bodyStyleLabel.text=@"Body Style :";
    bodyStyleLabel.textColor=[UIColor whiteColor];
    bodyStyleLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:bodyStyleLabel];
    
    self.bodyStyleTextField=[[UITextField alloc] init];//WithFrame:CGRectMake(95, 208, 200, 30)];
    self.bodyStyleTextField.backgroundColor=[UIColor clearColor];
    self.bodyStyleTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [contentView addSubview:self.bodyStyleTextField];
    
    
    self.stylePicker=[[UIPickerView alloc]init];
//    self.stylePicker.frame=CGRectMake(150, 130, 220, 180);
    self.stylePicker.showsSelectionIndicator=YES;
    [self.stylePicker setDataSource:self];
	[self.stylePicker setDelegate:self];
    self.stylePicker.hidden=YES;
    [contentView addSubview:self.stylePicker];
    //disable this picker until data arrives
    self.stylePicker.userInteractionEnabled=YES;
    
    
    
    self.loggedUserMakeDataLoadedIntoMakePicker=NO;
    
    //
    self.sortedYears=[[NSMutableArray alloc] initWithCapacity:1];
    for (int i=2013; i>=1910; i--) {
        NSString *yearStr=[NSString stringWithFormat:@"%d",i];
        [self.sortedYears addObject:yearStr];
    }
        self.yearSelected=[NSString stringWithFormat:@"%d",[self.carReceived year]];
    self.yearIdSelected=[NSString stringWithFormat:@"%d",[self.carReceived year]];
    
    self.sortedBodyTypeStyles = [NSArray arrayWithObjects:@"Unspecified",@"4WD/SUVs",@"Boat",@"Car",@"Cargo Van",@"Commercial Vehicles",@"Convertible",@"Coupe",@"Crew Cab Pickup",@"Crossovers",@"Extended Cab Pickup",@"Extended Van",@"Green Cars",@"Hatchback",@"Hybrids",@"Luxury Cars",@"Minivan",@"Motorcycles",@"Other",@"Passenger Van",@"People Mover",@"Pickup Trucks",@"Regular Cab Pickup",@"RVs",@"Sedan",@"Sports Cars",@"SUV",@"Tractor",@"Truck",@"Ute/Pick-Up",@"Van",@"Wagon", nil];
    
    self.bodyTypeIds = [NSArray arrayWithObjects:@"0",@"1",@"29",@"2",@"19",@"26",@"3",@"4",@"22",@"5",@"23",@"30",@"6",@"7",@"8",@"9",@"10",@"27",@"21",@"11",@"12",@"13",@"24",@"28",@"14",@"16",@"15",@"31",@"17",@"18",@"25",@"20", nil];
    
    self.bodyStyleSelected=[self.carReceived bodytype];
    self.bodyStyleIdSelected=[self.carReceived bodytypeID];
    
    //
    self.downloadMakesOperationQueue=[[NSOperationQueue alloc]init];
    [self.downloadMakesOperationQueue setName:@"VehicleTypeViewControllerQueue"];
    [self.downloadMakesOperationQueue setMaxConcurrentOperationCount:1];
    
    [self downloadMakesIfNotPresentElseLoadMakes];
    
    //initially set user interaction to NO
    [self enableDisableFields:NO];
    
    self.noteLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 360, self.view.frame.size.width-20, 40)];
    self.noteLabel.textColor=[UIColor whiteColor];
    self.noteLabel.backgroundColor=[UIColor clearColor];
    self.noteLabel.adjustsFontSizeToFitWidth=YES;
    self.noteLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.noteLabel.numberOfLines=0;
    self.noteLabel.lineBreakMode=NSLineBreakByWordWrapping;
    self.noteLabel.text=@"Note: Please contact customer support to update Make, Model and Year.";
    [contentView addSubview:self.noteLabel];
    
    //autolayout
    [vehicleTypeScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [makeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.makeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [modelLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.modelTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [yearLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.yearTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bodyStyleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bodyStyleTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.stylePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.noteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UITextField *tempMakeTF=self.makeTextField;
    UITextField *tempModelTF=self.modelTextField;
    UITextField *tempYearTF=self.yearTextField;
    UITextField *tempBodyStyleTF=self.bodyStyleTextField;
    UILabel *tempNoteLabel=self.noteLabel;
    
    NSDictionary *viewsDict=NSDictionaryOfVariableBindings(vehicleTypeScrollView,contentView,makeLabel,tempMakeTF,modelLabel,tempModelTF,yearLabel,tempYearTF,bodyStyleLabel,tempBodyStyleTF,self.stylePicker,self.noteLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[vehicleTypeScrollView]|" options:0 metrics:0 views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vehicleTypeScrollView]|" options:0 metrics:0 views:viewsDict]];
    
    [vehicleTypeScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:0 views:viewsDict]];
    [vehicleTypeScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:viewsDict]];
    
    //give horizontal alignment for each textfields and its label. Also give same width for all labels equal to the width of bodystyle (because it is longest)
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[makeLabel(==bodyStyleLabel)]-4-[tempMakeTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[modelLabel(==bodyStyleLabel)]-4-[tempModelTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[yearLabel(==bodyStyleLabel)]-4-[tempYearTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bodyStyleLabel]-4-[tempBodyStyleTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    
    
    
    //give vertical alignment of labels
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[makeLabel]-20-[modelLabel]-20-[yearLabel]-60-[bodyStyleLabel]-130-|" options:NSLayoutFormatAlignAllLeading metrics:0 views:viewsDict]];
    
    
    //give width for makeTextField
    NSLayoutConstraint *c1=[NSLayoutConstraint constraintWithItem:tempMakeTF attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:170];
    [contentView addConstraint:c1];
    
    //give that same width for others also
    NSString *sameWidthFormat=@"[tempModelTF(==tempMakeTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempYearTF(==tempModelTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempBodyStyleTF(==tempYearTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    //notelabel
    c1=[NSLayoutConstraint constraintWithItem:self.noteLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:20];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.noteLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bodyStyleTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:90];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.noteLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20];
    [contentView addConstraint:c1];
    
    //for fixing the contentView with main view so that multiline label will be displayed according to screen width (including rotation. see willAnimateRotationToInterfaceOrientation:animation method also)
    UIView *mainView = self.view;
    
    NSDictionary* viewsDict2 = NSDictionaryOfVariableBindings(vehicleTypeScrollView, contentView, tempNoteLabel, mainView);
    
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:viewsDict2]];
    
    __weak VehicleTypeViewController *weakSelf=self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        tempNoteLabel.preferredMaxLayoutWidth = weakSelf.view.bounds.size.width;
    });
    
    
    
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
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadMakesNotifMethod:) name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadModelsNotifMethod:) name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(makesOperationDownloadErrorNotifMethod:) name:@"MakesOperationDownloadErrorNotif" object:nil];
    
   // self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.indicator stopAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadMakesNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadModelsNotif object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"MakesOperationDownloadErrorNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    }


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

#pragma mark - Rotation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration
{
    __weak VehicleTypeViewController *weakSelf=self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.noteLabel.preferredMaxLayoutWidth = weakSelf.view.bounds.size.width;
    });

}


#pragma mark - PickerView Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual: self.makesPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        
        [mask setFrame: CGRectMake(11.0f, 24.0f, 142.0f, 140.0f)]; //6, 36, 152, 162
        [mask setCornerRadius: 5.0f];
        [self.makesPicker.layer setMask: mask];
        
        mask=nil;
        
        
        return 1;
    }
    if ([pickerView isEqual:self.modelsPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        
        [mask setFrame: CGRectMake(11.0f, 24.0f, 142.0f, 140.0f)];//(162, 36, 162, 162
        [mask setCornerRadius: 5.0f];
        [self.modelsPicker.layer setMask: mask];
        
        mask=nil;
        
        return 1;
    }
    
    if ([pickerView isEqual: self.yearPicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        
        [mask setFrame: CGRectMake(11.0f, 20.0f, 142.0f, 136.0f)];//(2, 238, 164, 162);
        [mask setCornerRadius: 5.0f];
        [self.yearPicker.layer setMask: mask];
        
        mask=nil;
        
        return 1;
    }
    
    if ([pickerView isEqual:self.stylePicker]) {
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor blackColor].CGColor];
        
        [mask setFrame: CGRectMake(11.0f, 30.0f, 180.0f, 120.0f)];//(150, 238, 164, 162);
        [mask setCornerRadius: 5.0f];
        [self.stylePicker.layer setMask: mask];
        
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
    //
    if ([pickerView isEqual:self.yearPicker]) {
        if(self.sortedYears && self.sortedYears.count)
        {
            //self.yearSelected=[self.sortedYears objectAtIndex:0];
            self.yearSelected=[NSString stringWithFormat:@"%d",[self.carReceived year]];
            return [self.sortedYears count];
        }
        else
        {
            return 0;
        }
    }
    if ([pickerView isEqual:self.stylePicker]) {
        if(self.sortedBodyTypeStyles && self.sortedBodyTypeStyles.count)
        {
            self.bodyStyleSelected=[self.sortedBodyTypeStyles objectAtIndex:0];
            return [self.sortedBodyTypeStyles count];
        }
        else
        {
            return 0;
        }
    }
    return 0;
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
        [pickerLabel setTextAlignment:NSTextAlignmentLeft];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        //[pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        
        pickerLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if([pickerView isEqual:self.makesPicker] && row>=0)
    {
        [pickerLabel setText:[self.sortedMakes objectAtIndex:row]];
    }
    else if(pickerView==self.modelsPicker && row>=0)
    {
        [pickerLabel setText:[self.sortedModels objectAtIndex:row]];
    }
    else if(pickerView==self.yearPicker && row>=0)
    {
        [pickerLabel setText:[self.sortedYears objectAtIndex:row]];
    }
    else if(pickerView==self.stylePicker && row>=0)
    {
        [pickerLabel setText:[self.sortedBodyTypeStyles objectAtIndex:row]];
    }
    return pickerLabel;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.makesPicker]) {
        
        //when make component is selected, initialize modelid to nil
        self.modelNameSelected=nil;
        self.modelIdSelected=nil;
        
        //first find the id of corresponding make selected.
        __weak VehicleTypeViewController *weakSelf=self;
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
    else if ([pickerView isEqual:self.modelsPicker])
    {
        __weak VehicleTypeViewController *weakSelf=self;
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
    
    else if ([pickerView isEqual:self.yearPicker])
    {
        self.yearSelected =[self.sortedYears objectAtIndex:row];
        self.yearIdSelected=[self.sortedYears objectAtIndex:row];
        
    }
    else if ([pickerView isEqual:self.stylePicker])
    {
        self.bodyStyleSelected = [self.sortedBodyTypeStyles objectAtIndex:row];
        self.bodyStyleIdSelected = [self.bodyTypeIds objectAtIndex:row];
        //NSLog(@"self.bodyStyleSelected = %@",self.bodyStyleSelected);
    }
    
}


#pragma mark - Private Methods

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

- (void)loadModelsPickerWithLoggedUserData
{
    [self.modelsPicker reloadComponent:0];
    self.modelsPicker.userInteractionEnabled=YES;
    
    //the position of modelName in sortedModels is same as position in models picker
    NSUInteger indexOfModel;
    if (self.modelNameSelected==nil) {
        self.modelNameSelected=[self.sortedModels objectAtIndex:0];
        indexOfModel=[self.sortedModels indexOfObject:self.modelNameSelected];
    }
    else
    {
        indexOfModel=[self.sortedModels indexOfObject:self.modelNameSelected];
    }
    [self.modelsPicker selectRow:indexOfModel inComponent:0 animated:YES];
}

- (void)loadModelsPickerWithData
{
    [self.modelsPicker reloadComponent:0];
    self.modelsPicker.userInteractionEnabled=YES;
    [self.modelsPicker selectRow:0 inComponent:0 animated:YES];
    
    self.modelNameSelected=[self.sortedModels objectAtIndex:0];
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedModels objectAtIndex:0];
    
    __weak VehicleTypeViewController *weakSelf=self;
    
    [self.modelsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqualToString:firstValue])
        {
            //NSLog(@"selected model at default is %@. id is %@",firstValue,key);
            
            weakSelf.modelIdSelected=key;
            *stop=YES;
        }
    }];
    
    //NSLog(@"models count is %d",[self.sortedModels count]);
    //we need to set the make/model ONLY after downloading/reading makes/models
    if (!self.loggedUserMakeDataLoadedIntoMakePicker) {
        self.loggedUserMakeDataLoadedIntoMakePicker=YES;
        
        [self retrieveLoggedUserPreviousData];
    }
    
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
    __weak VehicleTypeViewController *weakSelf=self;
    [self.makesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([(NSMutableString *)obj isEqualToString:firstValue])
        {
            //NSLog(@"selected make at default is %@. id is %@",firstValue,key);
            
            weakSelf.makeIdSelected=(NSMutableString *)key;
            *stop=YES;
        }
    }];
    
    
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




-(void)updateMakesModelsButtonTapped
{
    self.downloadOpStarted=YES;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.makesPicker setUserInteractionEnabled:NO];
    [self.modelsPicker setUserInteractionEnabled:NO];
    
    [self startDownloadMakesOperation];
}


- (void)downloadMakesIfNotPresentElseLoadMakes
{
    //
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=[delegate managedObjectContext];
    
    //fetching makes
    NSEntityDescription *makesEntityDesc=[NSEntityDescription entityForName:@"Makes" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *makesRequest=[[NSFetchRequest alloc]init];
    [makesRequest setEntity:makesEntityDesc];
    NSError *makesError;
    NSArray *allMakes=[self.managedObjectContext executeFetchRequest:makesRequest error:&makesError];
    
    //fetching models
    NSEntityDescription *modelsEntityDesc=[NSEntityDescription entityForName:@"Models" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *modelsRequest=[[NSFetchRequest alloc] init];
    [modelsRequest setEntity:modelsEntityDesc];
    NSError *modelsError;
    NSArray *allModels=[self.managedObjectContext executeFetchRequest:modelsRequest error:&modelsError];
    //NSLog(@"allMakes=%@ makesError=%@ allModels=%@ modelsError=%@",allMakes,makesError,allModels,modelsError);
    
    
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(allMakes)||IsEmpty(allModels)) {
        //lets call updateMakesModelsButtonTapped, so it will take care of downloading makes and models
        [self updateMakesModelsButtonTapped];
    }
    else
    {
        [self loadMakesDataFromDisk];
    }
}



#pragma mark - Bar Button Methods
- (void)enableDisableFields:(BOOL)enable
{
    if (enable) {
        
        self.makesPicker.userInteractionEnabled=YES;
        self.modelsPicker.userInteractionEnabled=YES;
        self.yearPicker.userInteractionEnabled=YES;
        self.stylePicker.userInteractionEnabled=YES;
        
    }
    else
    {
        
        self.makesPicker.userInteractionEnabled=NO;
        self.modelsPicker.userInteractionEnabled=NO;
        self.yearPicker.userInteractionEnabled=NO;
        self.stylePicker.userInteractionEnabled=NO;
        
        self.bodyStyleTextField.enabled=NO;
        self.bodyStyleTextField.textColor = [UIColor whiteColor];
        self.bodyStyleTextField.backgroundColor = [UIColor clearColor];
    }
}


- (BOOL)userMadeChanges
{
    BOOL changesMade=NO;
    
    BOOL modelNotChanged=[self.modelIdSelected isEqualToString:[self.carReceived modelID]];
    
    BOOL yearNotChanged=[self.yearIdSelected integerValue]==[self.carReceived year];
    
    
    BOOL bodyTypeNotChanged=[self.bodyStyleIdSelected isEqualToString:[self.carReceived bodytypeID]];
    
    
    if (!(modelNotChanged && yearNotChanged && bodyTypeNotChanged)) {
        changesMade=YES;
    }
    NSLog(@"changesMade=%d",changesMade);
    
    return changesMade;
    
}

- (void)rightBarButtonTapped:(id) sender
{
    self.bodyStyleTextField.hidden = YES;
    self.stylePicker.hidden = NO;
    self.stylePicker.frame=CGRectMake(110, 130, 220, 180);
    
    if ([self.rightBarButton.title isEqualToString:@"Edit"]) {
        self.rightBarButton.title=@"Save";
        [self enableDisableFields:YES];
        
        //set leftbarbuttonitem
        self.leftBarButton.title=@"Cancel";
    }
    else
    {
        
        //if current data is different from initially loaded data, call service to save
        if ([self userMadeChanges]) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            self.rightBarButton.enabled=NO;
            
            
            [self callWebServiceToSaveData];
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Changes To Save" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
            
            
        }
        
    }
    
}

- (void)leftBarButtonTapped:(id)sender
{
    if ([self.leftBarButton.title isEqualToString:@"Back"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else { //if title is "Cancel"
        //cancelling the user changes. i.e., reload user data
        [self retrieveLoggedUserPreviousData];
        
        [self enableDisableFields:NO];
        
        //set rightbarbutton to 'Edit' and leftbarbutton to 'Back'
        self.leftBarButton.title=@"Back";
        self.rightBarButton.title=@"Edit";
        
        //show/hide picker
        self.bodyStyleTextField.hidden = NO;
        self.stylePicker.hidden = YES;
    }
}

- (void)callWebServiceToSaveData
{
    [self.indicator startAnimating];
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    /*
     UID=120&Year=2011&ExteriorColor=Beige&InteriorColor=Beige&Transmission=3 Speed Automatic&DriveTrain=2 wheel drive&NumberOfDoors=Five Door&MakeModelID=101&BodyTypeID=1&CarID=1902&Price=50000&Mileage=25000&VIN=123456&NumberOfCylinder=3 Cylinder&FueltypeID=1&zip=12345&City=city&Description=description&VehicleCondition=Excellent&Title=title&StateID=15&AuthenticationID=ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654&CustomerID=12345&SessionID=B2F6F696-D0E9-4CF2-B6F3-456D6F06D8A6
     
     
     */
    //make & model, year cannot be changed. so disable their selection
    //fields required here: self.bodyStyleIdSelected
    
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
    
    
    NSString *year=[NSString stringWithFormat:@"%d",[self.carReceived year]];
    NSString *carid=[NSString stringWithFormat:@"%d",[self.carReceived carid]];
    NSString *price=[NSString stringWithFormat:@"%d",[self.carReceived price]];
    NSString *mileage=[NSString stringWithFormat:@"%d",[self.carReceived mileage]];
    
    NSArray *keys=[NSArray arrayWithObjects:@"UID",@"Year",@"ExteriorColor",@"InteriorColor",@"Transmission",@"DriveTrain",@"NumberOfDoors",@"MakeModelID",@"BodyTypeID",@"CarID",@"Price",@"Mileage",@"VIN",@"NumberOfCylinder",@"FueltypeID",@"zip",@"City",@"Description",@"VehicleCondition",@"Title",@"StateID",@"AuthenticationID",@"CustomerID",@"SessionID", nil];
    NSArray *values=[NSArray arrayWithObjects:[self.carReceived uid],year,[self.carReceived exteriorColor],[self.carReceived interiorColor],[self.carReceived transmission],[self.carReceived driveTrain],[self.carReceived numberOfDoors],[self.carReceived modelID],self.bodyStyleIdSelected,carid,price,mileage,[self.carReceived vin],[self.carReceived engineCylinders],[self.carReceived fuelTypeId],[self.carReceived zipCode],[self.carReceived city],[self.carReceived extraDescription],[self.carReceived ConditionDescription],[self.carReceived title],[self.carReceived stateID],@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",retrieveduuid,sessionID, nil];
    
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSLog(@"parameters=%@",parameters);
    __weak VehicleTypeViewController *weakSelf=self;
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"MobileService/CarService.asmx/UpdateCarDetails" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        //NSLog(@"response string: %@ class of response string=%@", operation.responseString,NSStringFromClass([operation.responseString class]));
        
        
        
        [weakSelf webServiceCallToSaveDataSucceededWithResponse:operation.responseString];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSLog(@"error: %@", operation.responseString);
        NSLog(@"%d",operation.response.statusCode);
        [weakSelf webServiceCallToSaveDataFailedWithError:error];
        
    }];
    
    
}

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str
{
    self.rightBarButton.enabled=YES;
    
    if ([str isEqualToString:@"Success"]) {
        self.rightBarButton.title=@"Edit";
        [self enableDisableFields:NO];
        
        //save the modified bodystyle, bodystyleid to car record, because if the user goes back and comes to this screen again, he should see updated details.
        [self.carReceived setBodytypeID:self.bodyStyleIdSelected];
        [self.carReceived setBodytype:self.bodyStyleSelected];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Modifications saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([str isEqualToString:@"Session timed out"])
    {
        //session timed out. so take the user to login screen
       
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"Error Occurred. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
    
}

- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    self.rightBarButton.enabled=YES;
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==kCFURLErrorTimedOut)
        {
            alert.title=@"Error Occured";
            alert.message=@"The request timed out.";
        }
        else
        {
            alert.title=@"Server Error";
            alert.message=[error localizedDescription];
        }
        
    }
    else //just for safe side though error object would not be nil
    {
        alert.title=@"Server Error";
        alert.message=@"UCE Car Finder could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
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
    //NSLog(@"aMakeId inside loadModelsDataFromDiskForMake is %@, its class is %@",aMakeId, NSStringFromClass([aMakeId class]));
    
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
    if (self.loggedUserMakeDataLoadedIntoMakePicker) {
        [self loadModelsPickerWithLoggedUserData];
    }
    else
    {
        [self loadModelsPickerWithData];
    }
}


#pragma mark - Makes Models Download Notif methods
-(void)kDownloadMakesNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadMakesNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        NSLog(@"makes downloaded");
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
    NSLog(@"models downloaded");
    
    // select appropriate make in makesPicker
    NSUInteger indexOfMake=[self.sortedMakes indexOfObject:self.makeNameSelected];
    [self.makesPicker selectRow:indexOfMake inComponent:0 animated:YES];
    //
    [self.makesPicker setUserInteractionEnabled:YES];
    [self.modelsPicker setUserInteractionEnabled:YES];
    
    [self loadModelsDataFromDiskForMake:self.makeIdSelected]; //previous @"0"
    if (self.downloadOpStarted) {
        self.downloadOpStarted=NO;
    }
}

-(void)makesOperationDownloadErrorNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(makesOperationDownloadErrorNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        
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

-(void)loadPickersWithLoggedUserPreviousData
{
    //get make id and select appropriate row of make picker
    
    //NSLog(@"make id is %@ class of make id is %@",self.makeIdSelected, NSStringFromClass([self.makeIdSelected class]));
    
    NSString *makeIdSelected=self.makeIdSelected;
    NSString *makeNameSelected=self.makeNameSelected;
    
    //makes and makeIds are available in self.makesDictionary. self.sortedMakes contains sorted makes. self.modelsDictionary contains models for Acura (makeid=1) which might not be useful here.
    //the position of makeName in sortedMakes is same as position in makes picker
    NSUInteger indexOfMake=[self.sortedMakes indexOfObject:makeNameSelected];
    [self.makesPicker selectRow:indexOfMake inComponent:0 animated:YES];
    
    //get model id and select appropriate row of model picker
    [self loadModelsDataFromDiskForMake:makeIdSelected];
    
    
    
    //get year id and select appropriate row of year picker
    self.yearIdSelected=[NSString stringWithFormat:@"%d",[self.carReceived year]];
    //the position of yearName in yearArray is same as position in years picker
    NSUInteger indexOfYear=[self.sortedYears indexOfObject:self.yearIdSelected];
    [self.yearPicker selectRow:indexOfYear inComponent:0 animated:YES];
    
    //get style style id and select appropriate row of style picker
    self.bodyStyleIdSelected=[self.carReceived bodytypeID];
    self.bodyStyleSelected=[self.carReceived bodytype];
    NSUInteger indexOfBodyStyle=[self.sortedBodyTypeStyles indexOfObject:self.bodyStyleSelected];
    [self.stylePicker selectRow:indexOfBodyStyle inComponent:0 animated:YES];
    
    self.bodyStyleTextField.text=[self.carReceived bodytype];
}

-(void)retrieveLoggedUserPreviousData
{
    
    if (self.carReceived) {
               //reset ivars that might get saved again without touching pickers
        self.makeIdSelected=[self.carReceived makeID];
        self.makeNameSelected=[self.carReceived make];
        
        self.modelIdSelected=[self.carReceived modelID];
        self.modelNameSelected=[self.carReceived model];
        
        self.yearSelected=[NSString stringWithFormat:@"%d",[self.carReceived year]];
        self.yearIdSelected=[NSString stringWithFormat:@"%d",[self.carReceived year]];
        
        self.bodyStyleSelected=[self.carReceived bodytype];
        self.bodyStyleIdSelected=[self.carReceived bodytypeID];
        
        [self loadPickersWithLoggedUserPreviousData];
        
    }
    else
    {
        NSLog(@"Car Dictionary not received. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
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
    _carReceived=nil;
    
    _bodyTypeIds=nil;
    _sortedBodyTypeStyles=nil;
    _managedObjectContext=nil;
    _makeNameSelected=nil;
    _modelNameSelected=nil;
    _sortedMakes=nil;
    _sortedModels=nil;
    _sortedYears=nil;
    _makesDictionary=nil;
    _modelsDictionary=nil;
    _downloadMakesOperationQueue=nil;
    _makeIdSelected=nil;
    _modelIdSelected=nil;
    _yearSelected=nil;
    _yearIdSelected=nil;
    _bodyStyleSelected=nil;
    _bodyStyleIdSelected=nil;
  
    _rightBarButton=nil;
   
    _makesPicker=nil;
    _modelsPicker=nil;
    _yearPicker=nil;
    _stylePicker=nil;
}

@end
