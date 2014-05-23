
//
//  RegistrationInfoViewController.m
//  Car-Finder
//
//  Created by Mac on 22/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RegistrationInfoViewController.h"
#import "CommonMethods.h"

//for glossy button
#import "CheckButton.h"
#import "UIButton+Glossy.h"

#import "QuartzCore/QuartzCore.h"

#import "AFNetworking.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"


#import "CheckZipCode.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "LoginViewController.h"

@interface RegistrationInfoViewController()

@property(strong,nonatomic) UITextField *nameTextField,*comapanyNameTextField,*phoneNoTextField,*altPhoneNoTextField,*cityTextField,*emailTextField,*altEmailTextField,*addressTextField,*zipTextField,*stateTextField;

@property(strong,nonatomic) UILabel *noteLabel;

@property(strong,nonatomic) UIPickerView *statePicker;
@property(strong,nonatomic) NSArray *stateIds,*statesSortedByName;
@property(copy,nonatomic) NSString *stateIdSelected;


@property(strong,nonatomic) NSOperationQueue *opQueue;


@property(strong,nonatomic) UIBarButtonItem *leftBarButton,*rightBarButton;

@property(strong,nonatomic) AFHTTPClient *Client;

//for xml parsing
@property(strong,nonatomic) NSXMLParser *xmlParser;
@property(copy,nonatomic) NSString *currentelement,*currentElementChars;

@property(assign,nonatomic) BOOL isShowingLandscapeView;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;


- (void)retrieveDataFromDefaults;
- (void)callRegistrationServiceWithName:(NSString *)name address:(NSString *)address city:(NSString *)city state:(NSString *)stateID zip:(NSString *)zip phoneNumber:(NSString *)phoneNo uid:(NSString *)uid companyName:(NSString *)companyName altEmail:(NSString *)altEmail altPhoneNumber:(NSString *)altPhoneNo;

-(void)validateZip:(NSString *)zipToValidate;
- (BOOL)userMadeChanges;
//- (void)callWebServiceToSaveData;
- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;
- (void)enableDisableFields:(BOOL)enable;
- (void)prepareForCallingService;

@end

@implementation RegistrationInfoViewController



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
     UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=@"Registration Info"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    //
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
//        button;
        
    });

    
    // Create the underlying UIImageView
    [CommonMethods putBackgroundImageOnView:self.view];
    
    //set up scrollview
    TPKeyboardAvoidingScrollView *regScrollView=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:regScrollView];
    
    
    UIView* contentView = [UIView new];
    //contentView.backgroundColor = [UIColor greenColor];
    [regScrollView addSubview:contentView];
    
    
    
    UILabel *nameLabel=[[UILabel alloc]init];
    nameLabel.frame=CGRectMake(4, 14, 102, 21);
    nameLabel.backgroundColor=[UIColor clearColor];
    nameLabel.text=@"Name:";
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor=[UIColor blackColor];
    [contentView addSubview:nameLabel];
    
    //
    
    self.nameTextField=[[UITextField alloc] initWithFrame:CGRectMake(117,  14, 193, 31)];
    self.nameTextField.backgroundColor=[UIColor clearColor];
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.font = [UIFont systemFontOfSize:15];
    self.nameTextField.placeholder = @"Name";
    self.nameTextField.textAlignment=NSTextAlignmentLeft;
    self.nameTextField.textColor=[UIColor blackColor];
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nameTextField.tag=1;
    //self.nameTextField.delegate = self;
    self.nameTextField.enabled=NO;
    [contentView addSubview:self.nameTextField];
    //y+=59;
    
    
    /////company name label and text field
    
    
    UILabel *companyNameLabel=[[UILabel alloc]init];
    companyNameLabel.frame=CGRectMake(4, 50, 108, 21);
    companyNameLabel.backgroundColor=[UIColor clearColor];
    companyNameLabel.text=@"Company Name:";
    companyNameLabel.font = [UIFont systemFontOfSize:14];
    companyNameLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:companyNameLabel];
    
    
    self.comapanyNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 50, 193, 31)];
    self.comapanyNameTextField.backgroundColor=[UIColor clearColor];
    self.comapanyNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.comapanyNameTextField.font = [UIFont systemFontOfSize:15];
    self.comapanyNameTextField.placeholder = @"Company Name";
    self.comapanyNameTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.comapanyNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.comapanyNameTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.comapanyNameTextField.returnKeyType = UIReturnKeyDone;
    self.comapanyNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.comapanyNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.comapanyNameTextField.tag=2;
    self.comapanyNameTextField.delegate = self;
    [contentView addSubview:self.comapanyNameTextField];
    
    ///////phone label and text field
    
    UILabel *phoneLabel=[[UILabel alloc]init];
    phoneLabel.frame=CGRectMake(4, 85, 74, 21);
    phoneLabel.backgroundColor=[UIColor clearColor];
    phoneLabel.text=@"Phone:";
    phoneLabel.font = [UIFont systemFontOfSize:14];
    phoneLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:phoneLabel];
    
    
    self.phoneNoTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 85, 193, 31)];
    self.phoneNoTextField.backgroundColor=[UIColor clearColor];
    self.phoneNoTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneNoTextField.font = [UIFont systemFontOfSize:15];
    self.phoneNoTextField.placeholder = @"Phone";
    self.phoneNoTextField.textAlignment=NSTextAlignmentLeft;
    self.phoneNoTextField.textColor=[UIColor blackColor];
    self.phoneNoTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.phoneNoTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneNoTextField.returnKeyType = UIReturnKeyDone;
    self.phoneNoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.phoneNoTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneNoTextField.tag=3;
    //self.phoneNoTextField.delegate = self;
    self.phoneNoTextField.enabled=NO;
    [contentView addSubview:self.phoneNoTextField];
    
    /////Alt Phone label and text field
    
    UILabel *altphoneNoLabel=[[UILabel alloc]init];
    altphoneNoLabel.frame=CGRectMake(4, 122, 102, 21);
    altphoneNoLabel.backgroundColor=[UIColor clearColor];
    altphoneNoLabel.text=@"Alt Phone:";
    altphoneNoLabel.font = [UIFont systemFontOfSize:14];
    altphoneNoLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:altphoneNoLabel];
    
    self.altPhoneNoTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 122, 193, 31)];
    self.altPhoneNoTextField.backgroundColor=[UIColor clearColor];
    self.altPhoneNoTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.altPhoneNoTextField.font = [UIFont systemFontOfSize:15];
    self.altPhoneNoTextField.placeholder = @"Alternate Phone";
    self.altPhoneNoTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.altPhoneNoTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.altPhoneNoTextField.keyboardType = UIKeyboardTypePhonePad;
    self.altPhoneNoTextField.returnKeyType = UIReturnKeyDone;
    self.altPhoneNoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.altPhoneNoTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.altPhoneNoTextField.tag=4;
    self.altPhoneNoTextField.delegate = self;
    [contentView addSubview:self.altPhoneNoTextField];
    
    
    ///////Email label and text field
    
    UILabel *emailLabel=[[UILabel alloc]init];
    emailLabel.frame=CGRectMake(4, 159, 102, 21);//4, 159, 102, 21//4, 312, 102, 21
    emailLabel.backgroundColor=[UIColor clearColor];
    emailLabel.text=@"Email ID:";
    emailLabel.font = [UIFont systemFontOfSize:14];
    emailLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:emailLabel];
    
    
    self.emailTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 159, 193, 31)];//117, 159, 193, 31//117, 312, 193, 31
    self.emailTextField.backgroundColor=[UIColor clearColor];
    self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailTextField.font = [UIFont systemFontOfSize:15];
    self.emailTextField.placeholder = @"Email";
    self.emailTextField.textAlignment=NSTextAlignmentLeft;
    self.emailTextField.textColor=[UIColor blackColor];
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.emailTextField.tag=7;
    //self.emailTextField.delegate = self;
    self.emailTextField.enabled=NO;
    [contentView addSubview:self.emailTextField];
    
    /////Alt Email label and text field
    
    UILabel *altEmailLabel=[[UILabel alloc]init];
    altEmailLabel.frame=CGRectMake(4, 197, 102, 21);//4, 197, 102, 21//4, 350, 102, 21
    altEmailLabel.backgroundColor=[UIColor clearColor];
    altEmailLabel.text=@"Alt Email ID:";
    altEmailLabel.font = [UIFont systemFontOfSize:14];
    altEmailLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:altEmailLabel];
    
    self.altEmailTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 197, 193, 31)];//117, 350, 193, 31
    self.altEmailTextField.backgroundColor=[UIColor clearColor];
    
    self.altEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.altEmailTextField.font = [UIFont systemFontOfSize:15];
    self.altEmailTextField.placeholder = @"Alternate Email";
    self.altEmailTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.altEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.altEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.altEmailTextField.returnKeyType = UIReturnKeyDone;
    self.altEmailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.altEmailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.altEmailTextField.tag=8;
    self.altEmailTextField.delegate = self;
    [contentView addSubview:self.altEmailTextField];
    
    
    ///////Address label and text field
    
    UILabel *addressLabel=[[UILabel alloc]init];
    addressLabel.frame=CGRectMake(4, 236, 102, 21); //4, 274, 102, 21
    addressLabel.backgroundColor=[UIColor clearColor];
    addressLabel.text=@"Address:";
    addressLabel.font = [UIFont systemFontOfSize:14];
    addressLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:addressLabel];
    
    self.addressTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 236, 193, 31)]; //117, 274, 193, 31
    self.addressTextField.backgroundColor=[UIColor clearColor];
    self.addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressTextField.font = [UIFont systemFontOfSize:15];
    self.addressTextField.placeholder = @"Address";
    self.addressTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.addressTextField.returnKeyType = UIReturnKeyDone;
    self.addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.addressTextField.tag=9;
    self.addressTextField.delegate = self;
    [contentView addSubview:self.addressTextField];
    
    
    ///////city label and text field
    
    UILabel *cityLabel=[[UILabel alloc]init];
    cityLabel.frame=CGRectMake(4, 274, 102, 21); //4, 236, 102, 21
    cityLabel.backgroundColor=[UIColor clearColor];
    cityLabel.text=@"City:";
    cityLabel.font = [UIFont systemFontOfSize:14];
    cityLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:cityLabel];
    
    
    self.cityTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 274, 193, 31)]; //117, 236, 193, 31
    self.cityTextField.backgroundColor=[UIColor clearColor];
    self.cityTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.cityTextField.font = [UIFont systemFontOfSize:15];
    self.cityTextField.placeholder = @"City";
    self.cityTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.cityTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cityTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.cityTextField.returnKeyType = UIReturnKeyDone;
    self.cityTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.cityTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.cityTextField.tag=5;
    self.cityTextField.delegate = self;
    [contentView addSubview:self.cityTextField];
    
    
    
    /////Zipcode label and text field
    
    UILabel *zipLabel=[[UILabel alloc]init];
    zipLabel.frame=CGRectMake(4, 312, 102, 21);
    zipLabel.backgroundColor=[UIColor clearColor];
    zipLabel.text=@"Zip Code:";
    zipLabel.font = [UIFont systemFontOfSize:14];
    zipLabel.textColor=[UIColor blackColor];
    
    [contentView addSubview:zipLabel];
    
    self.zipTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 312, 90, 31)];
    self.zipTextField.backgroundColor=[UIColor clearColor];
    self.zipTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.zipTextField.font = [UIFont systemFontOfSize:15];
    self.zipTextField.placeholder = @"Zip Code";
    self.zipTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.zipTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.zipTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.zipTextField.returnKeyType = UIReturnKeyDone;
    self.zipTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.zipTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.zipTextField.tag=10;
    self.zipTextField.delegate = self;
    [contentView addSubview:self.zipTextField];
    
    /////State name label and text field
    
    UILabel *stateLabel=[[UILabel alloc]init];
    stateLabel.frame=CGRectMake(4, 360, 102, 21);
    stateLabel.backgroundColor=[UIColor clearColor];
    stateLabel.text=@"State:";
    stateLabel.font = [UIFont systemFontOfSize:14];
    stateLabel.textColor=[UIColor blackColor];
    [contentView addSubview:stateLabel];
    
    self.stateTextField=[[UITextField alloc] initWithFrame:CGRectMake(117, 360, 90, 31)];
    self.stateTextField.backgroundColor=[UIColor clearColor];
    self.stateTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.stateTextField.font = [UIFont systemFontOfSize:15];
    self.stateTextField.placeholder = @"State";
    self.stateTextField.textAlignment=NSTextAlignmentLeft;
    //fNameTextField.textColor=[UIColor blackColor];
    self.stateTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.stateTextField.tag=10;
    self.stateTextField.delegate = self;
    [contentView addSubview:self.stateTextField];
    
    
    
    //////////////////
    //self.statePicker=[[UIPickerView alloc] init];//WithFrame:CGRectMake(106, 340, 100, 20)];
    self.statePicker=[[UIPickerView alloc] initWithFrame:CGRectMake(106, 340, 100, 20)];
    self.statePicker.showsSelectionIndicator=YES;
    self.statePicker.dataSource=self;
    self.statePicker.delegate=self;
    self.statePicker.hidden = YES;
    [contentView addSubview:self.statePicker];
    
    
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor blackColor].CGColor];
    [mask setFrame: CGRectMake(11.0f, 26.0f, 78.0f, 106.0f)]; //117, 197, 100, 36
    [mask setCornerRadius: 5.0f];
    [self.statePicker.layer setMask: mask];
    mask=nil;
    
    
    
    //    //finding states array
    self.statesSortedByName=[[NSArray alloc] initWithObjects:@"UN",@"AK",@"AL",@"AR",@"AS",@"AZ",@"CA",@"CO",@"CT",@"DC",@"DE",@"FL",@"FM",@"GA",@"GU",@"HI",@"IA",@"ID",@"IL",@"IN",@"KS",@"KY",@"LA",@"MA",@"MD",@"ME",@"MH",@"MI",@"MN",@"MO",@"MP",@"MS",@"MT",@"NC",@"ND",@"NE",@"NH",@"NJ",@"NM",@"NV",@"NY",@"OH",@"OK",@"ON",@"OR",@"PA",@"PR",@"PW",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VA",@"VI",@"VT",@"WA",@"WI",@"WV",@"WY",nil];
    self.stateIds=[[NSArray alloc] initWithObjects:@"0",@"2",@"1",@"5",@"3",@"4",@"6",@"7",@"8",@"10",@"9",@"12",@"11",@"13",@"14",@"15",@"18",@"59",@"16",@"17",@"19",@"20",@"21",@"25",@"24",@"22",@"23",@"26",@"27",@"29",@"39",@"28",@"30",@"37",@"38",@"31",@"33",@"34",@"35",@"32",@"36",@"40",@"41",@"60",@"42",@"44",@"45",@"43",@"46",@"47",@"48",@"49",@"50",@"51",@"54",@"53",@"52",@"55",@"57",@"56",@"58",nil];
    //
    ////////////
    
        /////
    
    NSOperationQueue *tempOpQueue=[[NSOperationQueue alloc]init];
    self.opQueue=tempOpQueue;
    tempOpQueue=nil;
    [self.opQueue setName:@"RegistrationInfoViewControllerQueue"];
    [self.opQueue setMaxConcurrentOperationCount:1];
    
    [self retrieveDataFromDefaults];
    
    [self enableDisableFields:NO];
    
    self.noteLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 480, self.view.frame.size.width-20, 40)];
    self.noteLabel.textColor=[UIColor blackColor];
    self.noteLabel.backgroundColor=[UIColor clearColor];
    self.noteLabel.adjustsFontSizeToFitWidth=YES;
    self.noteLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.noteLabel.numberOfLines=0;
    self.noteLabel.lineBreakMode=NSLineBreakByWordWrapping;
    self.noteLabel.text=@"Note: Please contact customer support to update Name, Phone and Email.";
    [contentView addSubview:self.noteLabel];
    
    //autolayout
    regScrollView.translatesAutoresizingMaskIntoConstraints=NO;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nameTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [companyNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.comapanyNameTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [phoneLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.phoneNoTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [altphoneNoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.altPhoneNoTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [emailLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.emailTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [altEmailLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.altEmailTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addressLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.addressTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [cityLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cityTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [zipLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.zipTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [stateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.stateTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[self.statePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.noteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    
    UITextField *tempNameTF=self.nameTextField;
    UITextField *tempComapanyNameTF=self.comapanyNameTextField;
    UITextField *tempPhoneNoTF=self.phoneNoTextField;
    UITextField *tempAltPhoneNoTF=self.altPhoneNoTextField;
    UITextField *tempEmailTF=self.emailTextField;
    UITextField *tempAltEmailTF=self.altEmailTextField;
    UITextField *tempAddressTF=self.addressTextField;
    UITextField *tempCityTF=self.cityTextField;
    UITextField *tempZipTF=self.zipTextField;
    UITextField *tempStateTF=self.stateTextField;
    UIPickerView *tempStatePicker=self.statePicker;
    UILabel *tempNoteLabel=self.noteLabel;
    
    NSDictionary* viewsDict = NSDictionaryOfVariableBindings(regScrollView, contentView, nameLabel,tempNameTF,companyNameLabel,tempComapanyNameTF,phoneLabel,tempPhoneNoTF,altphoneNoLabel,tempAltPhoneNoTF,emailLabel,tempEmailTF,altEmailLabel,tempAltEmailTF,addressLabel,tempAddressTF,cityLabel,tempCityTF,zipLabel,tempZipTF,stateLabel,tempStateTF,tempStatePicker,tempNoteLabel);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[regScrollView]|" options:0 metrics:0 views:viewsDict]];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[regScrollView]|" options:0 metrics:0 views:viewsDict]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[regScrollView]|" options:0 metrics:0 views:viewsDict]];
    }
    
    
    [regScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:0 views:viewsDict]];
    [regScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:viewsDict]];
    
    
    //give horizontal alignment for each textfields and its label. Also give same width for all labels equal to the width of companyNameLabel (because it is longest)
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[nameLabel(==companyNameLabel)]-4-[tempNameTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[companyNameLabel]-4-[tempComapanyNameTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[phoneLabel(==companyNameLabel)]-4-[tempPhoneNoTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[altphoneNoLabel(==companyNameLabel)]-4-[tempAltPhoneNoTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailLabel(==companyNameLabel)]-4-[tempEmailTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[altEmailLabel(==companyNameLabel)]-4-[tempAltEmailTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[addressLabel(==companyNameLabel)]-4-[tempAddressTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cityLabel(==companyNameLabel)]-4-[tempCityTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[zipLabel(==companyNameLabel)]-4-[tempZipTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[stateLabel(==companyNameLabel)]-4-[tempStateTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    
    
    
    
    //give vertical alignment of labels
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nameLabel]-20-[companyNameLabel]-20-[phoneLabel]-20-[altphoneNoLabel]-20-[emailLabel]-20-[altEmailLabel]-20-[addressLabel]-20-[cityLabel]-20-[zipLabel]-60-[stateLabel]-100-|" options:NSLayoutFormatAlignAllLeading metrics:0 views:viewsDict]]; //100 to accommodate for height of statepicker and noteLabel
    
    
    //give widht for nameTextField
    NSLayoutConstraint *c1=[NSLayoutConstraint constraintWithItem:tempNameTF attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:170];
    [contentView addConstraint:c1];
    
    //give that same width for others also
    NSString *sameWidthFormat=@"[tempComapanyNameTF(==tempNameTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempPhoneNoTF(==tempComapanyNameTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    
    sameWidthFormat=@"[tempAltPhoneNoTF(==tempPhoneNoTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];

    sameWidthFormat=@"[tempEmailTF(==tempAltPhoneNoTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempAltEmailTF(==tempEmailTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempAddressTF(==tempAltEmailTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    //
    sameWidthFormat=@"[tempCityTF(==tempAddressTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempZipTF(==tempCityTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    sameWidthFormat=@"[tempStateTF(==tempZipTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    
    
    //notelabel
    c1=[NSLayoutConstraint constraintWithItem:self.noteLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:20];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.noteLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.zipTextField attribute:NSLayoutAttributeBottom multiplier:1 constant:140];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.noteLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20];
    [contentView addConstraint:c1];
    
    //for fixing the contentView with main view so that multiline label will be displayed according to screen width (including rotation. see willAnimateRotationToInterfaceOrientation:animation method also)
    UIView *mainView = self.view;
    
    NSDictionary* viewsDict2 = NSDictionaryOfVariableBindings(regScrollView, contentView, tempNoteLabel, mainView);
    
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:viewsDict2]];
    
    __weak RegistrationInfoViewController *weakSelf=self;
    
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


- (void)retrieveDataFromDefaults
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *registrationDict=[defaults valueForKey:@"RegistrationDictKey"];
    
    self.nameTextField.text = [registrationDict objectForKey:@"Name"];
    
    self.phoneNoTextField.text = [registrationDict objectForKey:@"PhoneNumber"];
    
    if ([[registrationDict objectForKey:@"AltPhone"] isEqualToString:@"Emp"]) {
        self.altPhoneNoTextField.text = @"";
    }
    else
    {
        self.altPhoneNoTextField.text = [registrationDict objectForKey:@"AltPhone"];
    }
    
    if ([[registrationDict objectForKey:@"City"] isEqualToString:@"Emp"]) {
        self.cityTextField.text = @"";
    }
    else
    {
        self.cityTextField.text = [registrationDict objectForKey:@"City"];
    }
    
    if ([[registrationDict objectForKey:@"BusinessName"] isEqualToString:@"Emp"])
    {
        self.comapanyNameTextField.text = @"";
    }
    else
    {
        self.comapanyNameTextField.text = [registrationDict objectForKey:@"BusinessName"];
    }
    
    self.stateTextField.text = [registrationDict objectForKey:@"StateCode"];
    
    
    
    NSString *stateStr = [registrationDict valueForKey:@"StateCode"];
    
    stateStr = [stateStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([stateStr isEqualToString:@"Emp"]||[stateStr isEqualToString:@"Unspecified"]) {
        stateStr=@"UN";
    }
    
    
    NSUInteger indexOfState = [self.statesSortedByName indexOfObject:stateStr];
    [self.statePicker selectRow:indexOfState inComponent:0 animated:YES];
    
    //get default stateId
    NSInteger index=[self.statesSortedByName indexOfObject:stateStr];
    self.stateIdSelected=[self.stateIds objectAtIndex:index];
    
    
    
    
    
    self.emailTextField.text = [registrationDict objectForKey:@"UserName"];
    
    
    if ([[registrationDict objectForKey:@"AltEmail"] isEqualToString:@"Emp"])
    {
        self.altEmailTextField.text = @"";
    }
    else
    {
        self.altEmailTextField.text = [registrationDict objectForKey:@"AltEmail"];
    }
    
    if ([[registrationDict objectForKey:@"Address"] isEqualToString:@"Emp"]) {
        self.addressTextField.text = @"";
    }
    else
    {
        self.addressTextField.text = [registrationDict objectForKey:@"Address"];
    }
    
    if ([[registrationDict objectForKey:@"Zip"] isEqualToString:@"Emp"]) {
        self.zipTextField.text = @"";
    }
    else
    {
        self.zipTextField.text = [registrationDict objectForKey:@"Zip"];
    }
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
    //self.isShowingLandscapeView = NO;
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
    __weak RegistrationInfoViewController *weakSelf=self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.noteLabel.preferredMaxLayoutWidth = weakSelf.view.bounds.size.width;
    });

}



#pragma mark - Picker view methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.statePicker]) {
        return 1;
    }
    return 0;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.statePicker]) {
        if(self.statesSortedByName && self.statesSortedByName.count)
        {
            self.stateIdSelected=@"0";
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
        NSString *stateName;
        
        
        stateName=[self.statesSortedByName objectAtIndex:row];
        
        NSInteger index=[self.statesSortedByName indexOfObject:stateName];
        
        self.stateIdSelected=[self.stateIds objectAtIndex:index];
        
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
    
    if (pickerLabel != nil)
        
    {
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

#pragma mark - Private Methods

-(void)dismissKeyboard {
    for (int aTag=1; aTag<=10; aTag++) {
        UITextField *aView=(UITextField *)[self.view viewWithTag:aTag];
        
        if ([aView isFirstResponder])
        {
            [aView resignFirstResponder];
        }
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
- (void)callRegistrationServiceWithName:(NSString *)name address:(NSString *)address city:(NSString *)city state:(NSString *)stateID zip:(NSString *)zip phoneNumber:(NSString *)phoneNo uid:(NSString *)uid companyName:(NSString *)companyName altEmail:(NSString *)altEmail altPhoneNumber:(NSString *)altPhoneNo
{
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    //  http://www.unitedcarexchange.com/MobileService/ServiceMobile.asmx/UpdateUserRegistration/arunn/asdsdf345345fsdffd/city/15/12345/1234567890/120/qwertyu/attgrtdfgfd@fmf.com/1223245667/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/4F0925F2-68B3-4D1E-9F42-B1B4E84866C2/583BAE00-8405-4689-BE6C-40799E9BB1
    
    
    
    self.Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
    
    NSDictionary * parameters = nil;
    
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",address,@"address",city,@"city",stateID,@"stateID",zip,@"zip",phoneNo,@"phone",uid,@"UID",companyName,@"businessName",altEmail,@"altEmail",altPhoneNo,@"altPhone",@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",@"AuthenticationID",retrieveduuid,@"CustomerID",sessionID,@"SessionID",nil];
    
    
    
    __weak RegistrationInfoViewController *weakSelf=self;
    
    [self.Client setParameterEncoding:AFJSONParameterEncoding];
    [self.Client postPath:@"MobileService/CarService.asmx/UpdateUserRegistration" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.rightBarButton.enabled=YES;
        
      
        [weakSelf webServiceCallToSaveDataSucceededWithResponse:operation.responseString];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.rightBarButton.enabled=YES;
        
        NSLog(@"error: %@", operation.responseString);
        NSLog(@"%d",operation.response.statusCode);
        [weakSelf webServiceCallToSaveDataFailedWithError:error];
        
    }];
    
}


#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.nameTextField] || [textField isEqual:self.comapanyNameTextField]) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 20) ? NO : YES;
    }
    else if ([textField isEqual:self.phoneNoTextField] || [textField isEqual:self.altPhoneNoTextField]) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 10) ? NO : YES;
    }
    else if ([textField isEqual:self.zipTextField]) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 5) ? NO : YES;
    }
    return YES;
}

-(void)validateZip:(NSString *)zipToValidate
{
    //disable screen as user may click on any visible car(if present)
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"RegistrationInfoViewController OpQueue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.opQueue addOperation:checkZipCode];
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
            alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
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
            alert.message=@"MobiCarz cannot retrieve data due to server error.";
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
        [self prepareForCallingService];
        
    }
}

- (void)prepareForCallingService
{
    [self.indicator startAnimating];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *uid=[defaults objectForKey:UID_KEY];
    
    //
    //get all the fields and send to service
    NSString *name=[self checkForEmptyOrExtraSpaces:self.nameTextField.text];
    if (IsEmpty(name)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Name Cannot Be Empty" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.nameTextField becomeFirstResponder];
        return;
    }
    
    NSString *companyName=[self checkForEmptyOrExtraSpaces:self.comapanyNameTextField.text];
    
    NSString *city=[self checkForEmptyOrExtraSpaces:self.cityTextField.text];
    
    NSString *address=[self checkForEmptyOrExtraSpaces:self.addressTextField.text];
    
    
    
    NSString *altPhoneNo;
    if (IsEmpty(self.altPhoneNoTextField.text)) {
        altPhoneNo=@"Emp";
    }
    else if ([self.altPhoneNoTextField.text length]>0 && [self.altPhoneNoTextField.text length]<10) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alternate Phone Number Is Invalid" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.altPhoneNoTextField becomeFirstResponder];
        return;
    }
    else
    {
        altPhoneNo=self.altPhoneNoTextField.text;
    }
    
    NSString *altEmail=[self checkForEmptyOrExtraSpaces:self.altEmailTextField.text];
    
    
    NSString *zip=[self checkForEmptyOrExtraSpaces:self.zipTextField.text];
    if (IsEmpty(zip)) {
        zip=@"Emp";
    }
    
    //disable save button and enable again after web service result is retrieved
    self.rightBarButton.enabled=NO;
    
    //
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self callRegistrationServiceWithName:name address:address city:city state:self.stateIdSelected zip:zip phoneNumber:self.phoneNoTextField.text uid:uid companyName:companyName altEmail:altEmail altPhoneNumber:altPhoneNo];
    
    
}

#pragma mark - Bar Button Methods

- (void)saveRegistrationInfoBtnTapped
{
    
    [self dismissKeyboard];
    
    
    if (([self.altEmailTextField.text length]>0) && ([self.altEmailTextField.text length]<10) && (![CommonMethods validateEmail:self.altEmailTextField.text])) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@" Alternate Email Is Invalid" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.altEmailTextField becomeFirstResponder];
        return;
    }
    
    
    
    NSString *enteredZip=self.zipTextField.text;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *registrationDict=[defaults valueForKey:@"RegistrationDictKey"];
    
    
    
    BOOL zipNotChanged=[self.zipTextField.text isEqualToString:[registrationDict objectForKey:@"Zip"]];
    
    if (zipNotChanged || IsEmpty(self.zipTextField.text)) {
        [self prepareForCallingService];
    }
    else
    {
        [self validateZip:enteredZip];
    }
    
    
}

- (void)enableDisableFields:(BOOL)enable
{
    if (enable) {
        
        
        self.comapanyNameTextField.enabled=YES;
        self.comapanyNameTextField.textColor = [UIColor blackColor];
        
        self.comapanyNameTextField.backgroundColor=[UIColor whiteColor];
        
        self.altPhoneNoTextField.enabled=YES;
        self.altPhoneNoTextField.textColor = [UIColor blackColor];
        self.altPhoneNoTextField.backgroundColor=[UIColor whiteColor];
        
        self.cityTextField.enabled=YES;
        self.cityTextField.textColor = [UIColor blackColor];
        self.cityTextField.backgroundColor=[UIColor whiteColor];
        
        
        
        self.altEmailTextField.enabled=YES;
        self.altEmailTextField.textColor = [UIColor blackColor];
        self.altEmailTextField.backgroundColor=[UIColor whiteColor];
        
        self.addressTextField.enabled=YES;
        self.addressTextField.textColor = [UIColor blackColor];
        self.addressTextField.backgroundColor=[UIColor whiteColor];
        
        self.zipTextField.enabled=YES;
        self.zipTextField.textColor = [UIColor blackColor];
        self.zipTextField.backgroundColor=[UIColor whiteColor];
        
        self.statePicker.userInteractionEnabled=YES;
        self.statePicker.backgroundColor=[UIColor whiteColor];
        
    }
    else
    {
        
        
        self.comapanyNameTextField.enabled=NO;
        self.comapanyNameTextField .textColor = [UIColor blackColor];
        self.comapanyNameTextField.backgroundColor=[UIColor clearColor];
        
        self.altPhoneNoTextField.enabled=NO;
        self.altPhoneNoTextField.textColor = [UIColor blackColor];
        self.altPhoneNoTextField.backgroundColor=[UIColor clearColor];
        
        self.cityTextField.enabled=NO;
        self.cityTextField.textColor = [UIColor blackColor];
        self.cityTextField.backgroundColor=[UIColor clearColor];
        
        
        
        self.altEmailTextField.enabled=NO;
        self.altEmailTextField.textColor = [UIColor blackColor];
        self.altEmailTextField.backgroundColor=[UIColor clearColor];
        
        self.addressTextField.enabled=NO;
        self.addressTextField.textColor = [UIColor blackColor];
        self.addressTextField.backgroundColor=[UIColor clearColor];
        
        self.zipTextField.enabled=NO;
        self.zipTextField.textColor = [UIColor blackColor];
        self.zipTextField.backgroundColor=[UIColor clearColor];
        
        self.stateTextField.enabled=NO;
        self.stateTextField.textColor = [UIColor blackColor];
        self.stateTextField.backgroundColor = [UIColor clearColor];
        
           }
}

- (BOOL)userMadeChanges
{
    BOOL changesMade=NO;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *registrationDict=[defaults valueForKey:@"RegistrationDictKey"];
    
    
    BOOL nameNotChanged=[self.nameTextField.text isEqualToString:[registrationDict objectForKey:@"Name"]];
    
    BOOL phoneNoNotChanged=[self.phoneNoTextField.text isEqualToString:[registrationDict objectForKey:@"PhoneNumber"]];
    
    BOOL altPhoneNotChanged=(IsEmpty(self.altPhoneNoTextField.text) && [[registrationDict objectForKey:@"AltPhone"] isEqualToString:@"Emp"])|| [self.altPhoneNoTextField.text isEqualToString:[registrationDict objectForKey:@"AltPhone"]];
    
    BOOL cityNotChanged=(IsEmpty(self.cityTextField.text) && [[registrationDict objectForKey:@"City"] isEqualToString:@"Emp"]) || [self.cityTextField.text isEqualToString:[registrationDict objectForKey:@"City"]];
    
    BOOL companyNameNotChanged=(IsEmpty(self.comapanyNameTextField.text) && [[registrationDict objectForKey:@"BusinessName"] isEqualToString:@"Emp"]) || [self.comapanyNameTextField.text isEqualToString:[registrationDict objectForKey:@"BusinessName"]];
    
    NSString *stateIDStr=[NSString stringWithFormat:@"%d",[[registrationDict objectForKey:@"StateID"] integerValue]];
    BOOL stateCodeNotChanged=[self.stateIdSelected isEqualToString:stateIDStr];
    
    BOOL emailNotChanged=[self.emailTextField.text isEqualToString:[registrationDict objectForKey:@"UserName"]];
    
    
    BOOL altEmailNotChanged=(IsEmpty(self.altEmailTextField.text) && [[registrationDict objectForKey:@"AltEmail"] isEqualToString:@"Emp"]) || [self.altEmailTextField.text isEqualToString:[registrationDict objectForKey:@"AltEmail"]];
    
    BOOL addressNotChanged=(IsEmpty(self.addressTextField.text) && [[registrationDict objectForKey:@"Address"] isEqualToString:@"Emp"]) || [self.addressTextField.text isEqualToString:[registrationDict objectForKey:@"Address"]];
    
    BOOL zipNotChanged=(IsEmpty(self.zipTextField.text) && [[registrationDict objectForKey:@"Zip"] isEqualToString:@"Emp"]) || [self.zipTextField.text isEqualToString:[registrationDict objectForKey:@"Zip"]];
    
    
    
    
    if (!(nameNotChanged && phoneNoNotChanged && altPhoneNotChanged && cityNotChanged && companyNameNotChanged && stateCodeNotChanged && emailNotChanged && altEmailNotChanged && addressNotChanged && zipNotChanged)) {
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
            
            if ([self.emailTextField.text isEqualToString:self.altEmailTextField.text]) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Email ID exists" message:@"Provide an alternate email ID which is different from existing email ID." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                
                return;
                
                
            }
            [self saveRegistrationInfoBtnTapped];
            
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
        [self retrieveDataFromDefaults];
        
        [self enableDisableFields:NO];
        
        //set rightbarbutton to 'Edit' and leftbarbutton to 'Back'
        self.leftBarButton.title=@"Back";
        self.rightBarButton.title=@"Edit";
        
        //show/hide state picker
        self.stateTextField.hidden = NO;
        self.statePicker.hidden = YES;
        
    }
}

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str
{
    //xml parsing
    self.xmlParser=[[NSXMLParser alloc]initWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.xmlParser.delegate=self;
    
    [self.xmlParser parse];
    self.xmlParser=nil;
    
    
    
}

- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
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

#pragma mark -
#pragma mark XML Parser Methods


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    
    
    self.currentelement=[NSString stringWithString:elementName];
    
    if([elementName isEqualToString:@"AASuccess"])
    {
        NSString *tempCurrentElementChars=[[NSString alloc]init];
        self.currentElementChars=tempCurrentElementChars;
        tempCurrentElementChars=nil;
        
        
    }
    
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

{
    if([self.currentelement isEqualToString:@"AASuccess"])
    {
        self.currentElementChars=[[self.currentElementChars stringByAppendingString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
    }
    
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([self.currentelement isEqualToString:@"AASuccess"]) {
        
        
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
   
    
    //raise notification and send true or false value.
    
    if ([self.currentElementChars isEqualToString:@"Success"]) {
        self.rightBarButton.title=@"Edit";
        [self enableDisableFields:NO];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Your modifications are saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        //save the modified data to car record, because if the user goes back and comes to this screen again, he should see updated details.
        
        NSString *name=self.nameTextField.text;
        if (IsEmpty(name)) {
            name=@"Emp";
        }
        //
        NSString *companyName=self.comapanyNameTextField.text;
        if (IsEmpty(companyName)) {
            companyName=@"Emp";
        }
        //
        NSString *altPhone=self.altPhoneNoTextField.text;
        if (IsEmpty(altPhone)) {
            altPhone=@"Emp";
        }
        //
        NSString *altEmail=self.altEmailTextField.text;
        if (IsEmpty(altEmail)) {
            altEmail=@"Emp";
        }
        //
        NSString *city=self.cityTextField.text;
        if (IsEmpty(city)) {
            city=@"Emp";
        }
        //
        NSString *address=self.addressTextField.text;
        if (IsEmpty(address)) {
            address=@"Emp";
        }
        //
        NSString *zip=self.zipTextField.text;
        if (IsEmpty(zip)) {
            zip=@"Emp";
        }
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSMutableDictionary *registrationDict=[[defaults valueForKey:@"RegistrationDictKey"] mutableCopy];
        
        [registrationDict setObject:name forKey:@"Name"];
        [registrationDict setObject:companyName forKey:@"BusinessName"];
        [registrationDict setObject:altPhone forKey:@"AltPhone"];
        [registrationDict setObject:self.emailTextField.text forKey:@"UserName"];
        [registrationDict setObject:altEmail forKey:@"AltEmail"];
        [registrationDict setObject:city forKey:@"City"];
        [registrationDict setObject:address forKey:@"Address"];
        [registrationDict setObject:zip forKey:@"Zip"];
        NSInteger indexOfState=[self.stateIds indexOfObject:self.stateIdSelected];
        NSString *stateCode=[self.statesSortedByName objectAtIndex:indexOfState];
        [registrationDict setObject:stateCode forKey:@"StateCode"];
        [registrationDict setObject:self.stateIdSelected forKey:@"StateID"];
        [registrationDict setObject:name forKey:@"Name"];
        [registrationDict setObject:name forKey:@"Name"];
        [registrationDict setObject:name forKey:@"Name"];
        [registrationDict setObject:name forKey:@"Name"];
        
        [defaults setValue:registrationDict forKey:@"RegistrationDictKey"];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if ([self.currentElementChars isEqualToString:@"Session timed out"])
    {
        //session timed out. so take the user to login screen
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if ([self.currentElementChars isEqualToString:@"Failed"])
    {
        NSLog(@"Error Occurred. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"An error occurred while saving information." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        
    }
    else
    {
        NSLog(@"Error Occurred. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
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

- (void)dealloc {
    _stateIds=nil;
    _statesSortedByName=nil;
    _opQueue=nil;
    _stateIdSelected=nil;
    _rightBarButton=nil;
    
    _statePicker=nil;
    _nameTextField=nil;
    _comapanyNameTextField=nil;
    _phoneNoTextField=nil;
    _altPhoneNoTextField=nil;
    _cityTextField=nil;
    _emailTextField=nil;
    _altEmailTextField=nil;
    _addressTextField=nil;
    _zipTextField=nil;
    _stateTextField=nil;
    _noteLabel=nil;
}



@end
