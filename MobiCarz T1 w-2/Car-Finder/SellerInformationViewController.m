 //
//  SellerInformationViewController.m
//  CarDetails
//
//  Created by Mac on 23/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SellerInformationViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "CommonMethods.h"
#import "CheckZipCode.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "AFNetworking.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "LoginViewController.h"


@interface SellerInformationViewController()

@property(strong,nonatomic) UIPickerView *statePicker;
@property(strong,nonatomic) UITextField *cityTextField,*zipTextField,*phoneNumberTextField,*stateTextField;
@property(strong,nonatomic) NSArray *stateIds,*statesSortedByName;
@property(strong,nonatomic) NSDictionary *statesDictionary;
@property(copy,nonatomic) NSString *citySelected,*stateIdSelected,*stateSelected,*zipSelected,*phoneNumberSelected,*st;


@property(strong,nonatomic) NSOperationQueue *opQueue;



@property(strong,nonatomic) UIBarButtonItem *leftBarButton, *rightBarButton;

@property(strong,nonatomic) UILabel *topNoteLabel;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

@property(strong,nonatomic) UIActivityIndicatorView *indicator;


-(void)retrieveLoggedUserPreviousData;
-(void)dismissKeyboard;

//-(void)webServiceCall;


-(void)callUpdateSellerInfoServiceWithSellerID:(NSString *)sellerId sellerName:(NSString *)sellerName city:(NSString *)city state:(NSString *)stateCode zip:(NSString *)zip phone:(NSString *)phone email:(NSString *)email carId:(NSString *)carId;

- (void)enableDisableFields:(BOOL)enable;
- (BOOL)userMadeChanges;
- (void)save:(id) sender;
- (void)prepareForCallingService;
- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)aDict;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;

@end


@implementation SellerInformationViewController


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

static inline BOOL IsEmpty(id thing)

{
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
    
    [CommonMethods putBackgroundImageOnView:self.view];
    
    //navigation bar title
    NSString *navTitle=nil;
    if(self.carReceived!=nil)
    {
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.carReceived year],[self.carReceived make],[self.carReceived model]];
    }

    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=navTitle; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    
    self.navigationItem.titleView=navtitle;
    navtitle=nil;

    
    self.rightBarButton=({
        
        
        UIBarButtonItem *button=[[UIBarButtonItem alloc] init];
        button.target = self;
        button.action = @selector(rightBarButtonTapped:);
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
        [button setTitleTextAttributes:dic forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"Edit"]];
        button.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
        self.navigationItem.rightBarButtonItem=button;
        
        
        
//        UIBarButtonItem *button=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonTapped:)];
//        self.navigationItem.rightBarButtonItem = button;
        button;
    });
    
    self.leftBarButton=({
        
        
        UIBarButtonItem *button=[[UIBarButtonItem alloc] init];
        button.target = self;
        button.action = @selector(leftBarButtonTapped:);
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
        [button setTitleTextAttributes:dic forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"Back"]];
        button.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
        self.navigationItem.leftBarButtonItem=button;
        
        
//        UIBarButtonItem *button=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonTapped:)];
//        self.navigationItem.leftBarButtonItem=button;
        button;
        
    });
    
    
    //set up scrollview
    TPKeyboardAvoidingScrollView *sellerInfoScrollView=[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:sellerInfoScrollView];
    
    UIView* contentView = [UIView new];
    //contentView.backgroundColor = [UIColor greenColor];
    [sellerInfoScrollView addSubview:contentView];
    
    self.topNoteLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 40)];
    self.topNoteLabel.textColor=[UIColor blackColor];
    self.topNoteLabel.backgroundColor=[UIColor clearColor];
    self.topNoteLabel.adjustsFontSizeToFitWidth=YES;
    self.topNoteLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.topNoteLabel.numberOfLines=0;
    self.topNoteLabel.lineBreakMode=NSLineBreakByWordWrapping;
    self.topNoteLabel.text=@"This is the contact information that will be displayed with this specific car advertisement.";
    [contentView addSubview:self.topNoteLabel];
    
    //////Phone Lable and TextField
    
    UILabel *sellerInfoPhoneNumLabel=[[UILabel alloc]init];
    sellerInfoPhoneNumLabel.frame=CGRectMake(6,60, 120, 30); //6,230, 120, 30
    sellerInfoPhoneNumLabel.backgroundColor=[UIColor clearColor];
    sellerInfoPhoneNumLabel.text=@"Phone:*";
    sellerInfoPhoneNumLabel.textColor=[UIColor blackColor];
    sellerInfoPhoneNumLabel.font=[UIFont boldSystemFontOfSize:15];
    [sellerInfoPhoneNumLabel setLineBreakMode:NSLineBreakByClipping];
    [contentView addSubview:sellerInfoPhoneNumLabel];
    
    
    self.phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 60, 220, 30)]; //80, 230, 220, 30
    self.phoneNumberTextField.placeholder = @"Phone Number";
    self.phoneNumberTextField.backgroundColor=[UIColor clearColor];
    self.phoneNumberTextField.borderStyle=UITextBorderStyleRoundedRect;
    self.phoneNumberTextField.font=[UIFont systemFontOfSize:13];
    self.phoneNumberTextField.textColor = [UIColor blackColor];
    self.phoneNumberTextField.textAlignment=NSTextAlignmentLeft;
    self.phoneNumberTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.phoneNumberTextField.keyboardType=UIKeyboardTypePhonePad;
    self.phoneNumberTextField.returnKeyType=UIReturnKeyDone;
    self.phoneNumberTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.phoneNumberTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneNumberTextField.tag=3;
    self.phoneNumberTextField.delegate=self;
    //self.phoneNumberTextField.userInteractionEnabled = NO;
    [contentView addSubview:self.phoneNumberTextField];
    
    
    
    //////City Lable and TextField
    UILabel *sellerInfoCityLabel=[[UILabel alloc]init];
    sellerInfoCityLabel.frame=CGRectMake(6, 110, 100, 30); //6, 20, 100, 30
    sellerInfoCityLabel.backgroundColor=[UIColor clearColor];
    sellerInfoCityLabel.text=[NSString stringWithFormat:@"City: "];
    sellerInfoCityLabel.textColor=[UIColor blackColor];
    sellerInfoCityLabel.font=[UIFont boldSystemFontOfSize:15];
    [contentView addSubview:sellerInfoCityLabel];
    
    
    self.cityTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 110, 220, 30)]; //80, 22, 220, 30
    self.cityTextField.placeholder = @"City";
    self.cityTextField.backgroundColor=[UIColor clearColor];
    self.cityTextField.borderStyle=UITextBorderStyleRoundedRect;
    self.cityTextField.font=[UIFont systemFontOfSize:13];
    self.cityTextField.textColor = [UIColor blackColor];
    self.cityTextField.textAlignment=NSTextAlignmentLeft;
    self.cityTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.cityTextField.keyboardType=UIKeyboardTypeAlphabet;
    self.cityTextField.returnKeyType=UIReturnKeyDone;
    self.cityTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.cityTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.cityTextField.tag=1;
    self.cityTextField.delegate=self;
    [contentView addSubview:self.cityTextField];
    
    
    //Zip Code Lable and Text Field
    
    UILabel *sellerInfoZipCodeLabel=[[UILabel alloc]init];
    sellerInfoZipCodeLabel.frame=CGRectMake(6,150, 40, 30); //6,190, 40, 30
    sellerInfoZipCodeLabel.backgroundColor=[UIColor clearColor];
    sellerInfoZipCodeLabel.text=@"Zip:";
    sellerInfoZipCodeLabel.textColor=[UIColor blackColor];
    sellerInfoZipCodeLabel.font=[UIFont boldSystemFontOfSize:15];
    [contentView addSubview:sellerInfoZipCodeLabel];
    
    self.zipTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 150, 220, 30)]; //80, 190, 220, 30
    self.zipTextField.placeholder = @"Zip";
    self.zipTextField.backgroundColor=[UIColor clearColor];
    self.zipTextField.borderStyle=UITextBorderStyleRoundedRect;
    self.zipTextField.font=[UIFont systemFontOfSize:13];
    self.zipTextField.textAlignment=NSTextAlignmentLeft;
    self.zipTextField.textColor = [UIColor blackColor];
    self.zipTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.zipTextField.keyboardType=UIKeyboardTypeNumberPad;
    self.zipTextField.returnKeyType=UIReturnKeyDone;
    self.zipTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    self.zipTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.zipTextField.tag=2;
    self.zipTextField.delegate=self;
    [contentView addSubview:self.zipTextField];
    
    
    //State Lable and PickerView
    
    UILabel *sellerInfoStateLabel=[[UILabel alloc]init];
    sellerInfoStateLabel.frame=CGRectMake(6, 230, 60, 30); //6,70, 120, 30
    sellerInfoStateLabel.backgroundColor=[UIColor clearColor];
    sellerInfoStateLabel.text=@"State: ";
    sellerInfoStateLabel.textColor=[UIColor blackColor];
    sellerInfoStateLabel.font=[UIFont boldSystemFontOfSize:15];
    [contentView addSubview:sellerInfoStateLabel];
    
    
    self.stateTextField=[[UITextField alloc] initWithFrame:CGRectMake(80, 230, 220, 30)]; //80, 100, 220, 30
    self.stateTextField.backgroundColor=[UIColor clearColor];
    self.stateTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.stateTextField.font = [UIFont systemFontOfSize:13];
    self.stateTextField.placeholder = @"State";
    
    self.stateTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [contentView addSubview:self.stateTextField];
    
    self.statePicker=[[UIPickerView alloc]init];
    self.statePicker.frame=CGRectMake(70, 174, 120, 162); //old height 164
    self.statePicker.showsSelectionIndicator=YES;
    [self.statePicker setDataSource:self];
    [self.statePicker setDelegate:self];
    self.statePicker.hidden=YES;
    [contentView addSubview:self.statePicker];
    //disable this picker until data arrives
    self.statePicker.userInteractionEnabled=YES;
    
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor blackColor].CGColor];
    [mask setFrame: CGRectMake(11.0f, 20.0f, 97.0f, 120.0f)];
    [mask setCornerRadius: 5.0f];
    [self.statePicker.layer setMask: mask];
    mask=nil;
    
    
    //finding states array
    
    self.statesSortedByName=[[NSArray alloc] initWithObjects:@"UN",@"AK",@"AL",@"AR",@"AS",@"AZ",@"CA",@"CO",@"CT",@"DC",@"DE",@"FL",@"FM",@"GA",@"GU",@"HI",@"IA",@"ID",@"IL",@"IN",@"KS",@"KY",@"LA",@"MA",@"MD",@"ME",@"MH",@"MI",@"MN",@"MO",@"MP",@"MS",@"MT",@"NC",@"ND",@"NE",@"NH",@"NJ",@"NM",@"NV",@"NY",@"OH",@"OK",@"ON",@"OR",@"PA",@"PR",@"PW",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VA",@"VI",@"VT",@"WA",@"WI",@"WV",@"WY",nil];
    self.stateIds=[[NSArray alloc] initWithObjects:@"0",@"2",@"1",@"5",@"3",@"4",@"6",@"7",@"8",@"10",@"9",@"12",@"11",@"13",@"14",@"15",@"18",@"59",@"16",@"17",@"19",@"20",@"21",@"25",@"24",@"22",@"23",@"26",@"27",@"29",@"39",@"28",@"30",@"37",@"38",@"31",@"33",@"34",@"35",@"32",@"36",@"40",@"41",@"60",@"42",@"44",@"45",@"43",@"46",@"47",@"48",@"49",@"50",@"51",@"54",@"53",@"52",@"55",@"57",@"56",@"58",nil];
    
    //
   
    
    
    [self retrieveLoggedUserPreviousData];
    
    [self enableDisableFields:NO];
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"SellerInformationViewController OpQueue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    
    UILabel *bottomNoteLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 340, self.view.frame.size.width-20, 60)];
    bottomNoteLabel.textColor=[UIColor blackColor];
    bottomNoteLabel.backgroundColor=[UIColor clearColor];
    bottomNoteLabel.adjustsFontSizeToFitWidth=YES;
    bottomNoteLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    bottomNoteLabel.numberOfLines=0;
    bottomNoteLabel.lineBreakMode=NSLineBreakByWordWrapping;
    bottomNoteLabel.text=@"No other personal information will be shared. All customer enquiries will be sent to buyer registrant email id.";
    [contentView addSubview:bottomNoteLabel];
    
    //autolayout code
    [sellerInfoScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.topNoteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sellerInfoPhoneNumLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.phoneNumberTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sellerInfoCityLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cityTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sellerInfoZipCodeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.zipTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sellerInfoStateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.stateTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[self.statePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bottomNoteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    UITextField *tempPhoneTF=self.phoneNumberTextField;
    UITextField *tempCityTF=self.cityTextField;
    UITextField *tempZipTF=self.zipTextField;
    UITextField *tempStateTF=self.stateTextField;
    UILabel *tempTopNoteLabel=self.topNoteLabel;
    
    NSDictionary *viewsDict=NSDictionaryOfVariableBindings(sellerInfoScrollView,contentView,tempTopNoteLabel,sellerInfoPhoneNumLabel,tempPhoneTF,sellerInfoCityLabel,tempCityTF,sellerInfoZipCodeLabel,tempZipTF,sellerInfoStateLabel,tempStateTF,bottomNoteLabel);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[sellerInfoScrollView]|" options:0 metrics:0 views:viewsDict]];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sellerInfoScrollView]|" options:0 metrics:0 views:viewsDict]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[sellerInfoScrollView]|" options:0 metrics:0 views:viewsDict]];
    }
    
    
    [sellerInfoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:0 views:viewsDict]];
    [sellerInfoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:viewsDict]];
    
    //give horizontal alignment for each textfields and its label. Also give same width for all labels equal to the width of phone (because it is longest)
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sellerInfoPhoneNumLabel]-4-[tempPhoneTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sellerInfoCityLabel(==sellerInfoPhoneNumLabel)]-4-[tempCityTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sellerInfoZipCodeLabel(==sellerInfoPhoneNumLabel)]-4-[tempZipTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sellerInfoStateLabel(==sellerInfoPhoneNumLabel)]-4-[tempStateTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    //give vertical alignment of labels
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tempTopNoteLabel]-20-[sellerInfoPhoneNumLabel]-20-[sellerInfoCityLabel]-20-[sellerInfoZipCodeLabel]-70-[sellerInfoStateLabel]-150-|" options:NSLayoutFormatAlignAllLeading metrics:0 views:viewsDict]];
    
    
    //give width for phoneTextField
    NSLayoutConstraint *c1=[NSLayoutConstraint constraintWithItem:tempPhoneTF attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:170];
    [contentView addConstraint:c1];
    
    //give that same width for others also
    NSString *sameWidthFormat=@"[tempCityTF(==tempPhoneTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];

    sameWidthFormat=@"[tempZipTF(==tempCityTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempStateTF(==tempZipTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    //topNoteLabel
    c1=[NSLayoutConstraint constraintWithItem:self.topNoteLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:20];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.topNoteLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.topNoteLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:40];
    [contentView addConstraint:c1];
    
    
    
    //bottomNoteLabel
    c1=[NSLayoutConstraint constraintWithItem:bottomNoteLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:20];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:bottomNoteLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:bottomNoteLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.stateTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:80];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:bottomNoteLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:60];
    [contentView addConstraint:c1];
    
    
    //for fixing the contentView with main view so that multiline label will be displayed according to screen width (including rotation. see willAnimateRotationToInterfaceOrientation:animation method also)
    UIView *mainView = self.view;
    
    NSDictionary* viewsDict2 = NSDictionaryOfVariableBindings(sellerInfoScrollView, contentView, tempTopNoteLabel, bottomNoteLabel, mainView);
    
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:viewsDict2]];
    
    __weak SellerInformationViewController *weakSelf=self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        bottomNoteLabel.preferredMaxLayoutWidth = weakSelf.view.bounds.size.width;
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
      
    //[self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    

   // self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.indicator stopAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[self unRegisterForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
    
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



#pragma mark - Picker view Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.statePicker]) {
        if(self.statesSortedByName && self.statesSortedByName.count)
        {
           // self.stateIdSelected=@"0";
            return [self.statesSortedByName count];
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
    if ([pickerView isEqual:self.statePicker]) {
        
        


        //get state name, check its index in unsorted states array, then get value at that same index from self.stateIds
        
        self.stateSelected=[self.statesSortedByName objectAtIndex:row];
        
        NSInteger index=[self.statesSortedByName indexOfObject:self.stateSelected];
        
        self.stateIdSelected=[self.stateIds objectAtIndex:index];
        
        self.stateTextField.text =self.stateSelected;
        
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
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        //[pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        
        
        pickerLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if(row>=0)
        if([pickerView isEqual:self.statePicker])
        {
            [pickerLabel setText:[self.statesSortedByName objectAtIndex:row]];
        }
    
    return pickerLabel;
}


#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
       return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==3) { //phone number
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 10) ? NO : YES;
    }
    else if (textField.tag==2) { //zip
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 5) ? NO : YES;
    }
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
}
#pragma mark - Private Methods

-(void)validateZip:(NSString *)zipToValidate
{
    //disable screen as user may click on any visible car(if present)
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //self.view.userInteractionEnabled=NO;
    
    
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.opQueue addOperation:checkZipCode];
    checkZipCode=nil;
    
}


#pragma mark - Bar Button Methods
- (void)enableDisableFields:(BOOL)enable
{
    if (enable) {
        self.cityTextField.enabled=YES;
        self.cityTextField.textColor = [UIColor blackColor];
        self.cityTextField.backgroundColor=[UIColor whiteColor];
        
        self.zipTextField.enabled=YES;
        self.zipTextField.textColor = [UIColor blackColor];
        self.zipTextField.backgroundColor=[UIColor whiteColor];
        
        self.phoneNumberTextField.enabled=YES;
        self.phoneNumberTextField.textColor= [UIColor blackColor];
        self.phoneNumberTextField.backgroundColor=[UIColor whiteColor];
        
        self.statePicker.userInteractionEnabled=YES;
        self.statePicker.backgroundColor=[UIColor whiteColor];
        
    }
    else
    {
        self.cityTextField.enabled=NO;
        self.cityTextField.textColor = [UIColor blackColor];
        self.cityTextField.backgroundColor=[UIColor clearColor];
        
        self.zipTextField.enabled=NO;
        self.zipTextField.textColor = [UIColor blackColor];
        self.zipTextField.backgroundColor=[UIColor clearColor];
        
        self.phoneNumberTextField.enabled=NO;
        self.phoneNumberTextField.textColor= [UIColor blackColor];
        self.phoneNumberTextField.backgroundColor=[UIColor clearColor];
       
        self.statePicker.userInteractionEnabled=NO;
        self.statePicker.backgroundColor=[UIColor clearColor];
        
        self.stateTextField.enabled=NO;
        self.stateTextField.textColor = [UIColor blackColor];
        self.stateTextField.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)userMadeChanges
{
    BOOL changesMade=NO;
    
    BOOL phoneNotChanged=[self.phoneNumberTextField.text isEqualToString:[self.carReceived phone]];
    
    BOOL cityNotChanged=(IsEmpty(self.cityTextField.text) && [[self.carReceived city] isEqualToString:@"Emp"]) || [self.cityTextField.text isEqualToString:[self.carReceived city]];
    
    
    //BOOL emailNotChanged=[self.emailIdTextField.text isEqualToString:[self.carReceived email]];
    
    BOOL stateCodeNotChanged=[self.stateSelected isEqualToString:[self.carReceived state]];
    
    BOOL zipNotChanged=(IsEmpty(self.zipTextField.text) && [[self.carReceived zipCode] isEqualToString:@"Emp"]) || [self.zipTextField.text isEqualToString:[self.carReceived zipCode]];
    
    
   
    
    
    if (!(phoneNotChanged &&  cityNotChanged && stateCodeNotChanged && zipNotChanged)) {
        changesMade=YES;
    }
    
    return changesMade;
    
}

- (void)rightBarButtonTapped:(id) sender
{
    self.stateTextField.hidden = YES;
    self.statePicker.hidden = NO;
    
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
            self.rightBarButton.enabled=NO;
            [self save:nil];
            
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
        self.stateTextField.hidden = NO;
        self.statePicker.hidden = YES;
        
    }
}

- (void)save:(id) sender
{
    [self dismissKeyboard];
    
    
    if (IsEmpty(self.phoneNumberTextField.text)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Add your phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.phoneNumberTextField becomeFirstResponder];
        
        self.rightBarButton.enabled=YES;
        return;
    }
    else if ([self.phoneNumberTextField.text length]>0 && [self.phoneNumberTextField.text length]<10)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Provide a valid phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.phoneNumberTextField becomeFirstResponder];
        
        self.rightBarButton.enabled=YES;
        return;
        
    }
    
    
    
    
    
    NSString *enteredZip=self.zipTextField.text;
    
    BOOL zipNotChanged=[self.zipTextField.text isEqualToString:[self.carReceived zipCode]];
    
    if (zipNotChanged || IsEmpty(self.zipTextField.text)) {
        [self prepareForCallingService];
    }
    else
    {
        [self validateZip:enteredZip];
    }
}

- (NSString *)checkForEmptyOrExtraSpaces:(NSString *)val
{
    NSString *newVal;
    if (IsEmpty([val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        newVal=@" ";
    }
    else
    {
        newVal=[CommonMethods removeContinousDotsAndSpaces:val];
    }
    
    return newVal;
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
            alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==-1001)
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
            alert.message=@"MobiCarz cannot retrieve data due to server error.";
        }
        
        //[self.footerLabel setNeedsDisplay];
        
        
        [alert show];
        alert=nil;
        
        ////
        
        self.rightBarButton.enabled=YES;
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
        
        self.rightBarButton.enabled=YES;
        
        
    }
    else
    {
        //zip is valid
        NSLog(@"Zip is valid");
        //now send the service call.
        [self prepareForCallingService];
        
    }
}

- (void)prepareForCallingService
{
    //get all the fields and send to service/
    NSString *city=[self checkForEmptyOrExtraSpaces:self.cityTextField.text];
    if (IsEmpty(city)) {
        city=@"Emp";
    }
    
    NSString *zip=[self checkForEmptyOrExtraSpaces:self.zipTextField.text];
    if (IsEmpty(zip)) {
        zip=@"Emp";
    }
  //  NSLog(@"calling the callUpdateSellerInfoServiceWithCity with values: ");
    
////    //get statename from stateid
    NSString *stateCode=self.stateTextField.text;
    NSString *sID = [NSString stringWithFormat:@"%@",[self.carReceived sellerID]];
    NSString *sName = [NSString stringWithFormat:@"%@",[self.carReceived sellerName]];
    NSString *emID = [NSString stringWithFormat:@"%@",[self.carReceived email]];
    NSString *cID = [NSString stringWithFormat:@"%d",[self.carReceived carid]];
    
    self.rightBarButton.enabled=NO;
      
   [self callUpdateSellerInfoServiceWithSellerID:sID sellerName:sName city:city state:stateCode zip:zip phone:self.phoneNumberTextField.text email:emID carId:cID];
    
}






-(void)callUpdateSellerInfoServiceWithSellerID:(NSString *)sellerId sellerName:(NSString *)sellerName city:(NSString *)city state:(NSString *)stateCode zip:(NSString *)zip phone:(NSString *)phone email:(NSString *)email carId:(NSString *)carId
{
    
    
    
    [self.indicator startAnimating];
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *sessionID1=[defaults valueForKey:SESSIONID_KEY];
    NSString *uID = [NSString stringWithFormat:@"%@",[self.carReceived uid]];

    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];

    NSDictionary * parameters = nil;// = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:sellerId,@"sellerID",sellerName,@"sellerName",city,@"city",stateCode,@"state",zip,@"zip",phone,@"phone",email,@"email",carId,@"carID",uID,@"UID",@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",@"AuthenticationID",retrieveduuid,@"CustomerID",sessionID1,@"SessionID",nil];
  
    __weak SellerInformationViewController *weakSelf=self;
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"MobileService/CarService.asmx/UpdateSellerInformation" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     self.rightBarButton.enabled=YES;
         
         self.rightBarButton.enabled=YES;
         [weakSelf webServiceCallToSaveDataSucceededWithResponse:operation.responseString];
         
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         self.rightBarButton.enabled=YES;
         [weakSelf webServiceCallToSaveDataFailedWithError:error];
         
     }];

}


- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)aDict
{
    self.rightBarButton.enabled=YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.rightBarButton.title=@"Edit";
    [self enableDisableFields:NO];
    
    //save the modified data to car record, because if the user goes back and comes to this screen again, he should see updated details.
    NSString *city=self.cityTextField.text;
    if (IsEmpty(city)) {
        city=@"Emp";
    }
    //
    NSString *zip=self.zipTextField.text;
    if (IsEmpty(zip)) {
        zip=@"Emp";
    }
  
    
    [self.carReceived setCity:city];
    [self.carReceived setState:self.stateTextField.text];
    [self.carReceived setStateID:self.stateIdSelected];
    [self.carReceived setZipCode:zip];
    [self.carReceived setPhone:self.phoneNumberTextField.text];
    //[self.carReceived setEmail:self.emailIdTextField.text];
    
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Car registration information was updated successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
    
    [self.navigationController popViewControllerAnimated:YES];
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
            alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
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
        alert.message=@"MobiCarz could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
}

#pragma mark - Keyboard Method

-(void)dismissKeyboard {
    for (int aTag=1; aTag<4; aTag++) {
        UITextField *aView=(UITextField *)[self.view viewWithTag:aTag];
        
        if ([aView isFirstResponder])
        {
            [aView resignFirstResponder];
        }
    }
}

-(void)retrieveLoggedUserPreviousData
{
    
    if (self.carReceived) {
     
        
        //if any fields contain Emp or null, we are not changing them in selectediVar
        self.citySelected=[self.carReceived city];
        
        if ([[self.carReceived city] isEqualToString:@"Emp"]||[self.carReceived city]==nil||[[self.carReceived city] isKindOfClass:[NSNull class]]) {
            self.cityTextField.text=@"";
        }
        else
        {
            self.cityTextField.text=[self.carReceived city];
        }
        
        //
        self.zipSelected=[self.carReceived zipCode];
        if ([[self.carReceived zipCode] isEqualToString:@"Emp"]||[self.carReceived zipCode]==nil||[[self.carReceived zipCode] isKindOfClass:[NSNull class]]) {
            self.zipTextField.text=@"";
        }
        else
        {
            self.zipTextField.text=[self.carReceived zipCode];
        }
        
        //
        self.phoneNumberSelected=[self.carReceived phone];
        
        self.phoneNumberTextField.text=[self.carReceived phone];
        
        NSString *stateStr = [self.carReceived state];
        
        if (stateStr == nil) {
            stateStr =self.stateTextField.text;
        }
        
        stateStr = [stateStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        self.stateTextField.text = stateStr;
        NSUInteger indexOfState = [self.statesSortedByName indexOfObject:stateStr];
        
        
        [self.statePicker selectRow:indexOfState inComponent:0 animated:YES];
        
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
    
   _citySelected=nil;
    _stateIdSelected=nil;
    _stateSelected=nil;
    _zipSelected=nil;
    _phoneNumberSelected=nil;
    //_emailSelected=nil;
    _stateIds=nil;
    _statesSortedByName=nil;
    _statesDictionary=nil;
    _opQueue=nil;
    _rightBarButton=nil;
    _statePicker=nil;
    _cityTextField=nil;
    _zipTextField=nil;
    _phoneNumberTextField=nil;
    //_emailIdTextField=nil;
}

@end
