//
//  rmationViewController.m
//  CarDetails
//
//  Created by Mac on 23/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "VehicleInformationViewController.h"
#import "CommonMethods.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AFNetworking.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define SESSIONID_KEY @"SessionID"

#import "LoginViewController.h"

@interface VehicleInformationViewController ()

@property(strong,nonatomic) NSOperationQueue *opQueue;


///////Text Fields

@property(strong, nonatomic) UITextField *titleTextField,*askPriceTextField,*mileageTextField,*vinTextField;


///////////Start Picker Concept
@property (strong, nonatomic) UIPickerView *exteriorColorPicker,*interiorColorPicker,*transmissionPicker,*conditionPicker,*driveTrainPicker,*engineCylindersPicker,*doorsPicker,*fuelTypePicker;
@property (strong, nonatomic) UITextField *exteriorColorTextField,*interiorColorTextField,*transmissionTextField,*conditionTextField,*driveTrainTextField,*engineCylindersTextField,*doorsTextField,*fuelTypeTextField;

@property(strong, nonatomic) NSMutableArray *exteriorColorArray,*interiorColorArray,*transmissionArray,*coditionArray,*driveTrainArray,*engineCylindersArray,*doorsArray,*fuelTypeArray;
@property(strong, nonatomic)NSArray *exteriorColorId,*interiorColorId,*transmissionIdsArray,*conditionIdsArray,*driveTrainIdsArray,*engineCylindersIdsArray,*doorsIdsArray,*fuelTypeIdsArray;
@property(strong,nonatomic) UIBarButtonItem *leftBarButton,*rightBarButton;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;


////rmation Retraived from selected Car Detsils

-(void)retrieveLoggedUserPreviousData;
- (void)enableDisableFields:(BOOL)enable;
- (BOOL)userMadeChanges;
- (void)callWebServiceToSaveData;
- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;


@end

@implementation VehicleInformationViewController



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


-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
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
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
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

        
        
        
//        
//        UIBarButtonItem *button=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonTapped:)];
//        self.navigationItem.leftBarButtonItem=button;
        button;
        
    });
    
    //set up scrollview
    TPKeyboardAvoidingScrollView *vehicleInfoScrollView=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    vehicleInfoScrollView.showsHorizontalScrollIndicator=NO;
    vehicleInfoScrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:vehicleInfoScrollView];
    
    UIView* contentView = [UIView new];
    //contentView.backgroundColor = [UIColor greenColor];
    [vehicleInfoScrollView addSubview:contentView];
    
    
    //////City Lable and TextField
    
    UILabel *titleLabel2=[[UILabel alloc]init];
    titleLabel2.frame=CGRectMake(10, 8, 80, 30);
    titleLabel2.backgroundColor=[UIColor clearColor];
    titleLabel2.text=[NSString stringWithFormat:@"Title :"];
    titleLabel2.textColor=[UIColor blackColor];
    titleLabel2.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:titleLabel2];
    
    
    self.titleTextField = [[UITextField alloc] init];//WithFrame:CGRectMake(120, 10, 190, 30)];
    self.titleTextField.frame = CGRectMake(120, 10, 190, 30);
    self.titleTextField.placeholder = @"Enter Title";
    self.titleTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleTextField.backgroundColor = [UIColor clearColor];
    self.titleTextField.returnKeyType=UIReturnKeyDone;
    self.titleTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.titleTextField.tag=1;
    self.titleTextField.delegate = self;
    [contentView addSubview:self.titleTextField];
    
    
    
    //////Phone Lable and TextField
    
    UILabel *askPriceLabel=[[UILabel alloc]init];
    askPriceLabel.frame=CGRectMake(10,44, 120, 30);
    askPriceLabel.backgroundColor=[UIColor clearColor];
    askPriceLabel.text=[NSString stringWithFormat:@"Asking Price :"];
    askPriceLabel.textColor=[UIColor blackColor];
    askPriceLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:askPriceLabel];
    
    
    self.askPriceTextField = [[UITextField alloc] init];//WithFrame:CGRectMake(120, 46, 190, 30)];
    self.askPriceTextField.frame=CGRectMake(120, 46, 190, 30);
    self.askPriceTextField.placeholder = @"Enter Asking Pricer";
    self.askPriceTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.askPriceTextField.backgroundColor = [UIColor clearColor];
    self.askPriceTextField.keyboardType=UIKeyboardTypeNumberPad;
    self.askPriceTextField.tag=2;
    [contentView addSubview:self.askPriceTextField];
    
    //////Email Lable and TextField
    
    UILabel *mileageLabel=[[UILabel alloc]init];
    mileageLabel.frame=CGRectMake(10, 82, 100, 30);
    mileageLabel.backgroundColor=[UIColor clearColor];
    mileageLabel.text=[NSString stringWithFormat:@"Mileage :"];
    mileageLabel.textColor=[UIColor blackColor];
    mileageLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:mileageLabel];
    
    self.mileageTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 84, 190, 30)];
    self.mileageTextField.frame = CGRectMake(120, 84, 190, 30);
    self.mileageTextField.placeholder = @"Enter Mileage";
    self.mileageTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.mileageTextField.backgroundColor = [UIColor clearColor];
    self.mileageTextField.keyboardType=UIKeyboardTypeNumberPad;
    self.mileageTextField.tag=3;
    [contentView addSubview:self.mileageTextField];
    
    /////////////////Exterior Color Label,Text Field  and picker
    
    
    UILabel *exteriorColorLabel=[[UILabel alloc]init];
    exteriorColorLabel.frame=CGRectMake(10, 122, 120, 30);
    exteriorColorLabel.backgroundColor=[UIColor clearColor];
    exteriorColorLabel.text=[NSString stringWithFormat:@"Exterior Color :"];
    exteriorColorLabel.textColor=[UIColor blackColor];
    exteriorColorLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:exteriorColorLabel];
    
    
    
    self.exteriorColorTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 124, 190, 30)];
    self.exteriorColorTextField.frame = CGRectMake(120, 124, 190, 30);
    self.exteriorColorTextField.placeholder = @"Pick Exterior Color";
    self.exteriorColorTextField.tag = 4;
    self.exteriorColorTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.exteriorColorTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.exteriorColorTextField];
    
    
    self.exteriorColorTextField.delegate = self;
    
    
    self.exteriorColorArray = [NSMutableArray arrayWithObjects:@"Unspecified", @"Beige",@"Black",@"Blue",@"Blue Met",@"Brown",@"Burgundy",@"Champagne",@"Charcoal",@"Cyper Metallic Gray",@"Dark Blue",@"Dark Wood",@"Gold",@"Gold Mist",@"Gray",@"Gray Met",@"Green",@"Light Blue/Silver",@"Light gray",@"Light Pewter Metallic",@"Machine Silver Metallic",@"Maroon",@"Metallic",@"Mineral White Metallic",@"Offwhite",@"Orange",@"Other",@"Purple",@"Red",@"Red Jewel Tintcoat",@"Red Met",@"Ruby Red",@"Rust",@"Silver",@"Silver Met",@"Tan",@"Turquoise",@"Two-Tone",@"Victory Red",@"White",@"Yellow",nil];
    
    self.exteriorColorId = [NSArray arrayWithObjects:@"1",@"15",@"29",@"23",@"11",@"18",@"14",@"38",@"3",@"4",@"40",@"36",@"13",@"5",@"9",@"25",@"27",@"41",@"39",@"2",@"8",@"35",@"37",@"34",@"33",@"20",@"12",@"32",@"21",@"7",@"24",@"10",@"28",@"30",@"17",@"22",@"26",@"16",@"31",@"19",@"6", nil];
    
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    myToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(exteriorColorDoneButtonTapped)];
    
    
    UIBarButtonItem *previousButton =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    UIBarButtonItem *nextButton =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [myToolbar setItems:[NSArray arrayWithObjects:previousButton,nextButton,spaceButton,doneButton,nil] animated:NO];
    
    
    self.exteriorColorTextField.inputAccessoryView = myToolbar;
    
    
    /////////////////Interior Color Label,Text Field  and picker
    
    
    UILabel *interiorColorLabel=[[UILabel alloc]init];
    interiorColorLabel.frame=CGRectMake(10, 162, 120, 30);
    interiorColorLabel.backgroundColor=[UIColor clearColor];
    interiorColorLabel.text=[NSString stringWithFormat:@"Interior Color :"];
    interiorColorLabel.textColor=[UIColor blackColor];
    interiorColorLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:interiorColorLabel];
    
    self.interiorColorTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 164, 190, 30)];
    self.interiorColorTextField.frame = CGRectMake(120, 164, 190, 30);
    self.interiorColorTextField.placeholder = @"Pick Exterior Color";
    self.interiorColorTextField.tag = 5;
    self.interiorColorTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.interiorColorTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.interiorColorTextField];
    
    self.interiorColorTextField.delegate = self;
  
    self.interiorColorArray = [NSMutableArray arrayWithObjects:@"Unspecified", @"Beige",@"Beige/Tan",@"Black",@"Blue",@"Brown",@"Burgundy",@"Charcoal",@"Dark Blue",@"Dark Gray",@"Gold",@"Gray",@"Green",@"Imperial Blue",@"Light Blue",@"Light gray",@"Maroon",@"Metal Finish",@"Offwhite",@"Orange",@"Other",@"Red",@"Silver",@"Tan",@"Turquoise",@"White",nil];
    
    self.interiorColorId = [NSArray arrayWithObjects:@"1",@"8",@"17",@"3",@"15",@"10",@"7",@"2",@"24",@"9",@"6",@"4",@"20",@"23",@"25",@"16",@"26",@"22",@"21",@"12",@"5",@"13",@"18",@"14",@"19",@"11", nil];
 
    
    UIToolbar *interiorToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    interiorToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *interiorDoneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(interiorColorDoneButtonTapped)];
       UIBarButtonItem *previousButtonInt =
    [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonInt =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    
    UIBarButtonItem *interiorSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [interiorToolbar setItems:[NSArray arrayWithObjects:previousButtonInt,nextButtonInt,interiorSpaceButton,interiorDoneButton,nil] animated:NO];
    self.interiorColorTextField.inputAccessoryView = interiorToolbar;
    
    
    
    ////////////Transmission label, textfield and PickerView
    
    
    UILabel *transmissionLabel=[[UILabel alloc]init];
    transmissionLabel.frame=CGRectMake(10, 202, 120, 30);
    transmissionLabel.backgroundColor=[UIColor clearColor];
    transmissionLabel.text=[NSString stringWithFormat:@"Transmission :"];
    transmissionLabel.textColor=[UIColor blackColor];
    transmissionLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:transmissionLabel];
    
    
    
    self.transmissionTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 204, 190, 30)];
    self.transmissionTextField.frame = CGRectMake(120, 204, 190, 30);
    self.transmissionTextField.placeholder = @"Transmission";
    self.transmissionTextField.tag = 6;
    self.transmissionTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.transmissionTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.transmissionTextField];
    
    
    self.transmissionTextField.delegate = self;
    
    
    
    self.transmissionArray = [NSMutableArray arrayWithObjects:@"Unspecified", @"3 Speed Automatic",@"4 Speed Automatic",@"4 Speed Automatic with Electronic Overdrive",@"4 Speed Automatic with Overdrive",@"4 Speed Shiftable Automatic",@"5 Speed Automatic",@"5 Speed Manual",@"6 Speed Automatic",@"6 Speed Manual",@"6 Speed Shiftable Automatic",@"Automatic",@"Automatic with Overdrive",@"Manual",@"Other",@"Triptronic",nil];
    
    
    self.transmissionIdsArray = [NSArray arrayWithObjects:@"1",@"14",@"4",@"12",@"8",@"11",@"5",@"10",@"2",@"3",@"7",@"13",@"6",@"9",@"15",@"16", nil];
    
    
    UIToolbar *transmissionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    transmissionToolbar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *DoneButtonTransmission =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(transmissionDoneButtonTapped)];
    
    UIBarButtonItem *previousButtonTransmission =
    [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonTransmission =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    UIBarButtonItem *SpaceButtonTransmission = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [transmissionToolbar setItems:[NSArray arrayWithObjects:previousButtonTransmission,nextButtonTransmission,SpaceButtonTransmission,DoneButtonTransmission,nil] animated:NO];
    
    
    self.transmissionTextField.inputAccessoryView = transmissionToolbar;
    
    
    
    ////////////Condition label, textfield and PickerView
    
    
    UILabel *conditionLabel=[[UILabel alloc]init];
    conditionLabel.frame=CGRectMake(10, 242, 120, 30);
    conditionLabel.backgroundColor=[UIColor clearColor];
    conditionLabel.text=[NSString stringWithFormat:@"Condition :"];
    conditionLabel.textColor=[UIColor blackColor];
    conditionLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:conditionLabel];
    
    
    
    self.conditionTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 242, 190, 30)];
    self.conditionTextField.frame = CGRectMake(120, 242, 190, 30);
    self.conditionTextField.placeholder = @"Condition";
    self.conditionTextField.tag = 7;
    self.conditionTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.conditionTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.conditionTextField];
    
    
    self.conditionTextField.delegate = self;
    
    
    self.coditionArray = [NSMutableArray arrayWithObjects:@"Unspecified", @"Excellent",@"Fair",@"Good",@"Parts or Salvage",@"Poor",@"Very Good", nil];
    
    self.conditionIdsArray = [NSArray arrayWithObjects:@"0",@"1",@"4",@"3",@"6",@"5",@"2", nil];
    
    
    
    UIToolbar *ConditionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    ConditionToolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *DoneButtonCondition =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(conditionDoneButtonTapped)];
    
    UIBarButtonItem *previousButtonCondition =[[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonCondition =[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    UIBarButtonItem *SpaceButtonCondition = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [ConditionToolbar setItems:[NSArray arrayWithObjects:previousButtonCondition,nextButtonCondition,SpaceButtonCondition,DoneButtonCondition,nil] animated:NO];
    
    
    self.conditionTextField.inputAccessoryView = ConditionToolbar;
    
    
    
    
    ////////////Drive Train  label, textfield and PickerView
    
    
    UILabel *driveTrainLabel=[[UILabel alloc]init];
    driveTrainLabel.frame=CGRectMake(10, 278, 120, 30);
    driveTrainLabel.backgroundColor=[UIColor clearColor];
    driveTrainLabel.text=[NSString stringWithFormat:@"Drive Train :"];
    driveTrainLabel.textColor=[UIColor blackColor];
    driveTrainLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:driveTrainLabel];
    
    
    
    self.driveTrainTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 278, 190, 30)];
    self.driveTrainTextField.frame = CGRectMake(120, 278, 190, 30);
    self.driveTrainTextField.placeholder = @"DriveTrain";
    self.driveTrainTextField.tag = 8;
    self.driveTrainTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.driveTrainTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.driveTrainTextField];
    
    
    self.driveTrainTextField.delegate = self;
    
    
    
    self.driveTrainArray = [NSMutableArray arrayWithObjects:@"Unspecified",@"2 wheel drive",@"2 wheel drive - front",@"2 wheel drive - rear",@"4 wheel drive",@"4 wheel drive - rear",@"All wheel drive",@"Rear wheel drive", nil];
    
    
    self.driveTrainIdsArray = [NSArray arrayWithObjects:@"1",@"5",@"4",@"2",@"3",@"7",@"6",@"8", nil];
    
    UIToolbar *DriveTrainToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    DriveTrainToolbar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *DoneButtonDriveTrain =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(driveTrainDoneButtonTapped)];
    
    UIBarButtonItem *previousButtonDriveTrain =
    [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonDriveTrain =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    UIBarButtonItem *SpaceButtonDriveTrain = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [DriveTrainToolbar setItems:[NSArray arrayWithObjects:previousButtonDriveTrain,nextButtonDriveTrain,SpaceButtonDriveTrain,DoneButtonDriveTrain,nil] animated:NO];
    
    
    self.driveTrainTextField.inputAccessoryView = DriveTrainToolbar;
    
    
    
    
    //////////// Engine Cylinders  label, textfield and PickerView
    
    
    UILabel *engineCylindersLabel=[[UILabel alloc]init];
    engineCylindersLabel.frame=CGRectMake(10, 316, 124, 30);
    engineCylindersLabel.backgroundColor=[UIColor clearColor];
    engineCylindersLabel.text=[NSString stringWithFormat:@"Engine Cylinders :"];
    
    engineCylindersLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    engineCylindersLabel.textColor=[UIColor blackColor];
    engineCylindersLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:engineCylindersLabel];
    
    
    
    self.engineCylindersTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(136, 316, 174, 30)];
    self.engineCylindersTextField.frame = CGRectMake(136, 316, 174, 30);
    self.engineCylindersTextField.placeholder = @"Engine Cylinders";
    self.engineCylindersTextField.tag = 9;
    self.engineCylindersTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.engineCylindersTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.engineCylindersTextField];
    
    
    self.engineCylindersTextField.delegate = self;
    
    
    self.engineCylindersArray = [NSMutableArray arrayWithObjects:@"Unspecified",@"3 Cylinder",@"4 Cylinder",@"4 Cylinder Gasoline",@"4 Cylinder Supercharg",@"4 Cylinder Turbo",@"5 Cylinder",@"5 Cylinder Gasoline",@"6 Cylinder",@"6 Cylinder Gasoline",@"7 Cylinder",@"8 Cylinder",@"8 Cylinder Diesel",@"8 Cylinder Diesel Tur",@"8 Cylinder Gasoline",@"8 Cylinder Turbo",@"Hybrid", nil];
    
    self.engineCylindersIdsArray = [NSArray arrayWithObjects:@"1",@"16",@"13",@"2",@"4",@"8",@"5",@"11",@"14",@"9",@"17",@"3",@"10",@"7",@"15",@"6",@"12", nil];
    
    
    UIToolbar *engineCylindersToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    engineCylindersToolbar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *DoneButtonEngineCylinders =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(engineCylindersDoneButtonTapped)];
    
    UIBarButtonItem *previousButtonEngineCylinders =
    [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonEngineCylinders =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    UIBarButtonItem *SpaceButtonEngineCylindersToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [engineCylindersToolbar setItems:[NSArray arrayWithObjects:previousButtonEngineCylinders,nextButtonEngineCylinders,SpaceButtonEngineCylindersToolbar,DoneButtonEngineCylinders,nil] animated:NO];
    
    self.engineCylindersTextField.inputAccessoryView = engineCylindersToolbar;
    
 
    //////////// Doors  label, textfield and PickerView
    
    
    UILabel *doorsLabel=[[UILabel alloc]init];
    doorsLabel.frame=CGRectMake(10, 356, 124, 30);
    doorsLabel.backgroundColor=[UIColor clearColor];
    doorsLabel.text=[NSString stringWithFormat:@"Doors :"];
    
    doorsLabel.textColor=[UIColor blackColor];
    doorsLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:doorsLabel];
    
    
    
    self.doorsTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 354, 190, 30)];
    self.doorsTextField.frame = CGRectMake(120, 354, 190, 30);
    self.doorsTextField.placeholder = @"Doors";
    self.doorsTextField.tag = 10;
    self.doorsTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.doorsTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.doorsTextField];
    
    
    self.doorsTextField.delegate = self;
    
    
    self.doorsArray = [NSMutableArray arrayWithObjects:@"Unspecified",@"Five Door",@"Four Door",@"Three Door",@"Two Door", nil];
    
    self.doorsIdsArray = [NSArray arrayWithObjects:@"1",@"4",@"3",@"5",@"2", nil];
    
    
    UIToolbar *DoorsToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    DoorsToolbar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButtonDoors =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(DoorsDoneButtonTapped)];
    
    UIBarButtonItem *previousButtonDoors =
    [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonDoors =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    UIBarButtonItem *SpaceButtonDoorsToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [DoorsToolbar setItems:[NSArray arrayWithObjects:previousButtonDoors,nextButtonDoors,SpaceButtonDoorsToolbar,doneButtonDoors,nil] animated:NO];
    
    
    self.doorsTextField.inputAccessoryView = DoorsToolbar;
    
    
    
    //////////// Fuel Type  label, textfield and PickerView
    
    
    UILabel *fuelTypeLabel=[[UILabel alloc]init];
    fuelTypeLabel.frame=CGRectMake(10, 396, 124, 30);
    fuelTypeLabel.backgroundColor=[UIColor clearColor];
    fuelTypeLabel.text=[NSString stringWithFormat:@"Fuel Type :"];
    
    fuelTypeLabel.textColor=[UIColor blackColor];
    fuelTypeLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:fuelTypeLabel];
    
    
    
    self.fuelTypeTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 394, 190, 30)];
    self.fuelTypeTextField.frame = CGRectMake(120, 394, 190, 30);
    self.fuelTypeTextField.placeholder = @"Fuel Type";
    self.fuelTypeTextField.tag = 11;
    self.fuelTypeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.fuelTypeTextField.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.fuelTypeTextField];
    
    
    self.fuelTypeTextField.delegate = self;
    
    
    self.fuelTypeArray = [NSMutableArray arrayWithObjects:@"Unspecified",@"Diesel",@"E-85/Gasoline",@"Electric",@"Gasoline",@"Gasoline Hybrid",@"Hybrid",@"Other",@"Petrol", nil];
    
    
    self.fuelTypeIdsArray = [NSArray arrayWithObjects:@"0",@"1",@"6",@"4",@"5",@"7",@"3",@"8",@"2", nil];
    
    UIToolbar *FuelTypeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 36)]; //should code with variables to support view resizing
    
    FuelTypeToolbar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButtonFuelTypeToolbar =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(FuelTypeToolbarDoneButtonTapped)];
    
    UIBarButtonItem *previousButtonFuelTypeToolbar =
    [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    
    UIBarButtonItem *nextButtonFuelTypeToolbar =
    [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    
    UIBarButtonItem *SpaceButtonFuelTypeToolbarToolbar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [FuelTypeToolbar setItems:[NSArray arrayWithObjects:previousButtonFuelTypeToolbar,nextButtonFuelTypeToolbar,SpaceButtonFuelTypeToolbarToolbar,doneButtonFuelTypeToolbar,nil] animated:NO];
    
    
    self.fuelTypeTextField.inputAccessoryView = FuelTypeToolbar;
    
    
    
    ////// 	VIN (may add later) Lable and TextField
    
    
    UILabel *vinLabel=[[UILabel alloc]init];
    vinLabel.frame=CGRectMake(10, 434, 80, 30);
    vinLabel.backgroundColor=[UIColor clearColor];
    vinLabel.text=[NSString stringWithFormat:@"Vin :"];
    vinLabel.textColor=[UIColor blackColor];
    vinLabel.font=[UIFont boldSystemFontOfSize:14];
    [contentView addSubview:vinLabel];
    
    
    self.vinTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(120, 436, 190, 30)];
    self.vinTextField.frame = CGRectMake(120, 436, 190, 30);
    self.vinTextField.placeholder = @"Enter Vin";
    self.vinTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.vinTextField.backgroundColor = [UIColor clearColor];
    self.vinTextField.returnKeyType=UIReturnKeyDone;
    self.vinTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.vinTextField.delegate=self;
    self.vinTextField.tag=12;
    [contentView addSubview:self.vinTextField];
    

  
    //////////Car Details
    
    
    [self retrieveLoggedUserPreviousData];
    
    [self enableDisableFields:NO];
    
    //alloc pickers
    self.exteriorColorPicker = [[UIPickerView alloc] init];
    self.exteriorColorPicker.dataSource = self;
    self.exteriorColorPicker.delegate = self;
    
    self.interiorColorPicker = [[UIPickerView alloc] init];
    self.interiorColorPicker.dataSource = self;
    self.interiorColorPicker.delegate = self;
    
    self.transmissionPicker = [[UIPickerView alloc] init];
    self.transmissionPicker.dataSource = self;
    self.transmissionPicker.delegate = self;
    
    self.conditionPicker = [[UIPickerView alloc] init];
    self.conditionPicker.dataSource = self;
    self.conditionPicker.delegate = self;
    
    self.driveTrainPicker = [[UIPickerView alloc] init];
    self.driveTrainPicker.dataSource = self;
    self.driveTrainPicker.delegate = self;
    
    self.engineCylindersPicker = [[UIPickerView alloc] init];
    self.engineCylindersPicker.dataSource = self;
    self.engineCylindersPicker.delegate = self;
    
    self.doorsPicker = [[UIPickerView alloc] init];
    self.doorsPicker.dataSource = self;
    self.doorsPicker.delegate = self;
    
    self.fuelTypePicker = [[UIPickerView alloc] init];
    self.fuelTypePicker.dataSource = self;
    self.fuelTypePicker.delegate = self;
    
    //autolayout
    [vehicleInfoScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLabel2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [askPriceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.askPriceTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mileageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mileageTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [exteriorColorLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.exteriorColorTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [interiorColorLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.interiorColorTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [transmissionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.transmissionTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [conditionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.conditionTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [driveTrainLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.driveTrainTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [engineCylindersLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.engineCylindersTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [doorsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.doorsTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [fuelTypeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.fuelTypeTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [vinLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.vinTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UITextField *tempTitleTF=self.titleTextField;
    UITextField *tempAskPriceTF=self.askPriceTextField;
    UITextField *tempMileageTF=self.mileageTextField;
    UITextField *tempExteriorColorTF=self.exteriorColorTextField;
    UITextField *tempInteriorColorTF=self.interiorColorTextField;
    UITextField *tempTransmissionTF=self.transmissionTextField;
    UITextField *tempConditionTF=self.conditionTextField;
    UITextField *tempDriveTrainTF=self.driveTrainTextField;
    UITextField *tempEngineCylindersTF=self.engineCylindersTextField;
    UITextField *tempDoorsTF=self.doorsTextField;
    UITextField *tempFuelTypeTF=self.fuelTypeTextField;
    UITextField *tempVinTF=self.vinTextField;
    
    NSDictionary *viewsDict=NSDictionaryOfVariableBindings(vehicleInfoScrollView,contentView,titleLabel2,tempTitleTF,askPriceLabel,tempAskPriceTF,mileageLabel,tempMileageTF,exteriorColorLabel,tempExteriorColorTF,interiorColorLabel,tempInteriorColorTF,transmissionLabel,tempTransmissionTF,conditionLabel,tempConditionTF,driveTrainLabel,tempDriveTrainTF,engineCylindersLabel,tempEngineCylindersTF,doorsLabel,tempDoorsTF,fuelTypeLabel,tempFuelTypeTF,vinLabel,tempVinTF);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[vehicleInfoScrollView]|" options:0 metrics:0 views:viewsDict]];
    
 if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vehicleInfoScrollView]|" options:0 metrics:0 views:viewsDict]];
 }else{
     
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[vehicleInfoScrollView]|" options:0 metrics:0 views:viewsDict]];
 }
    
    [vehicleInfoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:0 views:viewsDict]];

    


    [vehicleInfoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:viewsDict]];

    //give horizontal alignment for each textfields and its label. Also give same width for all labels equal to the width of enginecylinders (because it is longest)
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel2(==engineCylindersLabel)]-4-[tempTitleTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];

    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[askPriceLabel(==engineCylindersLabel)]-4-[tempAskPriceTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];//
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[mileageLabel(==engineCylindersLabel)]-4-[tempMileageTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[exteriorColorLabel(==engineCylindersLabel)]-4-[tempExteriorColorTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[interiorColorLabel(==engineCylindersLabel)]-4-[tempInteriorColorTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];//
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[transmissionLabel(==engineCylindersLabel)]-4-[tempTransmissionTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[conditionLabel(==engineCylindersLabel)]-4-[tempConditionTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];//
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[driveTrainLabel(==engineCylindersLabel)]-4-[tempDriveTrainTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];//
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[engineCylindersLabel]-4-[tempEngineCylindersTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[doorsLabel(==engineCylindersLabel)]-4-[tempDoorsTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[fuelTypeLabel(==engineCylindersLabel)]-4-[tempFuelTypeTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[vinLabel(==engineCylindersLabel)]-4-[tempVinTF]-(>=20)-|" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    
    
    //give vertical alignment of labels
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel2]-20-[askPriceLabel]-20-[mileageLabel]-20-[exteriorColorLabel]-20-[interiorColorLabel]-20-[transmissionLabel]-20-[conditionLabel]-20-[driveTrainLabel]-20-[engineCylindersLabel]-20-[doorsLabel]-20-[fuelTypeLabel]-20-[vinLabel]-|" options:NSLayoutFormatAlignAllLeading metrics:0 views:viewsDict]];
    
    //give width for titleTextField
    NSLayoutConstraint *c1=[NSLayoutConstraint constraintWithItem:tempTitleTF attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:150];
    [contentView addConstraint:c1];
    
    //give that same width for others also
    NSString *sameWidthFormat=@"[tempAskPriceTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempMileageTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempExteriorColorTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempInteriorColorTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempTransmissionTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempConditionTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempDriveTrainTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempEngineCylindersTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempDoorsTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempFuelTypeTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];
    sameWidthFormat=@"[tempVinTF(==tempTitleTF)]";
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:sameWidthFormat options:0 metrics:0 views:viewsDict]];



}

- (void)loadPickersWithUserData
{
    NSString *exteriorColor=[self.carReceived exteriorColor];
    
    
    if ([exteriorColor isEqualToString:@"Emp"])
    {
        [self.exteriorColorPicker selectRow:0 inComponent:0 animated:YES];
    }
    else
    {
    NSInteger indexOfExteriorColor=[self.exteriorColorArray indexOfObject:exteriorColor];
  [self.exteriorColorPicker selectRow:indexOfExteriorColor inComponent:0 animated:YES];
    }
    
    //
    NSString *interiorColor=[self.carReceived interiorColor];
    
    if ([interiorColor isEqualToString:@"Emp"])
    {
        [self.interiorColorPicker selectRow:0 inComponent:0 animated:YES];
    }
    else
    {
    NSInteger indexOfInteriorColor=[self.interiorColorArray indexOfObject:interiorColor];
    [self.interiorColorPicker selectRow:indexOfInteriorColor inComponent:0 animated:YES];
    }
    //
    NSString *transmissionColor= [self.carReceived transmission];
                                  
    if ([transmissionColor isEqualToString:@"Emp"])
    {
        [self.transmissionPicker selectRow:0 inComponent:0 animated:YES];
    }
    else
    {

    NSInteger indexOfTransmission=[self.transmissionArray indexOfObject:transmissionColor];
    [self.transmissionPicker selectRow:indexOfTransmission inComponent:0 animated:YES];
    }
    //
    NSString *condition=[self.carReceived ConditionDescription];
    if ([condition isEqualToString:@"Emp"]) {
        [self.conditionPicker selectRow:0 inComponent:0 animated:YES];

    }
    else
    {
    NSInteger indexOfCondition=[self.coditionArray indexOfObject:condition];
    [self.conditionPicker selectRow:indexOfCondition inComponent:0 animated:YES];
    }
    //
    NSString *driveTrain=[self.carReceived driveTrain];
    if ([driveTrain isEqualToString:@"Emp"]) {
        [self.driveTrainPicker selectRow:0 inComponent:0 animated:YES];
    }
   else
   {
    NSInteger indexOfDriveTrain=[self.driveTrainArray indexOfObject:driveTrain];
    [self.driveTrainPicker selectRow:indexOfDriveTrain inComponent:0 animated:YES];
   }
    //
    NSString *engineCylinders=[self.carReceived engineCylinders];
    if ([engineCylinders isEqualToString:@"Emp"])
    {
     [self.engineCylindersPicker selectRow:0 inComponent:0 animated:YES];
    }
    else
    {
    NSInteger indexOfEngineCylinders=[self.engineCylindersArray indexOfObject:engineCylinders];
    [self.engineCylindersPicker selectRow:indexOfEngineCylinders inComponent:0 animated:YES];
    }
    //
    NSString *doors=[self.carReceived numberOfDoors];
    if ([doors isEqualToString:@"Emp"])
    {
        [self.doorsPicker selectRow:0 inComponent:0 animated:YES];
    }
    else{
    NSInteger indexOfdoors=[self.doorsArray indexOfObject:doors];
    [self.doorsPicker selectRow:indexOfdoors inComponent:0 animated:YES];
    }
    //
    NSString *fuelType=[self.carReceived fueltype];
    if ([fuelType isEqualToString:@"Emp"])
    {
        [self.fuelTypePicker selectRow:0 inComponent:0 animated:YES];
    }
    else{
    NSInteger indexOfFuelType=[self.fuelTypeArray indexOfObject:fuelType];
    [self.fuelTypePicker selectRow:indexOfFuelType inComponent:0 animated:YES];
    }
}

-(void)retrieveLoggedUserPreviousData
{
    
    if (IsEmpty([self.carReceived title])||[[self.carReceived title] isEqualToString:@"Emp"]) {
        self.titleTextField.text =@"";
    }
    else
    {
        self.titleTextField.text = [self.carReceived title];
    }
    
    self.askPriceTextField.text = [NSString stringWithFormat:@"%d",[self.carReceived price]];
    
    self.mileageTextField.text = [NSString stringWithFormat:@"%d",[self.carReceived mileage]];
    
    if ([[self.carReceived exteriorColor] isEqualToString:@"Emp"]) {
        self.exteriorColorTextField.text = [self.exteriorColorArray objectAtIndex:0];
    }
    else
    {
     self.exteriorColorTextField.text = [self.carReceived exteriorColor];
    }
    
    if ([[self.carReceived interiorColor] isEqualToString:@"Emp"])
    {
        
        self.interiorColorTextField.text = [self.interiorColorArray objectAtIndex:0];
    }
    else
    {
        self.interiorColorTextField.text = [self.carReceived interiorColor];
    }
    if ([[self.carReceived interiorColor] isEqualToString:@"Emp"])
    {
        
        self.interiorColorTextField.text = [self.interiorColorArray objectAtIndex:0];
    }
    else
    {
        self.interiorColorTextField.text = [self.carReceived interiorColor];
    }
    if ([[self.carReceived transmission] isEqualToString:@"Emp"])
    {
        
        self.transmissionTextField.text = [self.transmissionArray objectAtIndex:0];
    }
    else
    {
        self.transmissionTextField.text = [self.carReceived transmission];
    }
   
    if ([[self.carReceived ConditionDescription] isEqualToString:@"Emp"]) {
        self.conditionTextField.text = [self.coditionArray objectAtIndex:0];
    }
    else
    {
        self.conditionTextField.text = [self.carReceived ConditionDescription];
    }
    if ([[self.carReceived driveTrain] isEqualToString:@"Emp"])
    {
        self.driveTrainTextField.text = [self.driveTrainArray objectAtIndex:0];
    }
    else
    {
    self.driveTrainTextField.text = [self.carReceived driveTrain];
    }
    if ([[self.carReceived engineCylinders] isEqualToString:@"Emp"])
    {
      self.engineCylindersTextField.text = [self.engineCylindersArray objectAtIndex:0];
    }
    else
    {
    self.engineCylindersTextField.text = [self.carReceived engineCylinders];
    }
    if ([[self.carReceived numberOfDoors] isEqualToString:@"Emp"])
    {
        self.doorsTextField.text = [self.doorsArray objectAtIndex:0];
    }
    else
    {
        self.doorsTextField.text = [self.carReceived numberOfDoors];
    }
    if ([[self.carReceived fueltype] isEqualToString:@"Emp"])
    {
        self.fuelTypeTextField.text = [self.fuelTypeArray objectAtIndex:0];
    }
    else
    {
    self.fuelTypeTextField.text = [self.carReceived fueltype];
    }
    
    self.vinTextField.text = [self.carReceived vin];
    
    
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadPickersWithUserData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - PickerView Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if ([self.exteriorColorPicker isEqual:pickerView])
    {
        return [self.exteriorColorArray count];
    }
    else if([self.interiorColorPicker isEqual:pickerView])
    {
        return [self.interiorColorArray count];
    }
    else if([self.transmissionPicker isEqual:pickerView])
    {
        return [self.transmissionArray count];
    }
    else if([self.conditionPicker isEqual:pickerView])
    {
        return [self.coditionArray count];
    }
    else if([self.driveTrainPicker isEqual:pickerView])
    {
        return [self.driveTrainArray count];
    }
    else if([self.engineCylindersPicker isEqual:pickerView])
    {
        return [self.engineCylindersArray count];
    }
    
    else if([self.doorsPicker isEqual:pickerView])
    {
        return [self.doorsArray count];
    }
    else if([self.fuelTypePicker isEqual:pickerView])
    {
        return [self.fuelTypeArray count];
    }
    
    return 0;
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    
    
    CGFloat width = [pickerView rowSizeForComponent:component].width;
    
    UILabel *pickerLabel=(UILabel *)[view viewWithTag:1];
    if (pickerLabel==nil) {
        pickerLabel=[[UILabel alloc] init];
        pickerLabel.tag=1;
    }
    
    if (pickerLabel != nil) {
        CGRect frame = CGRectMake(0.0, 0.0, width, 32);
        [pickerLabel setFrame:frame];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:12]];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        
       // pickerLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if ([self.exteriorColorPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.exteriorColorArray objectAtIndex:row]];
    }
    else if([self.interiorColorPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.self.interiorColorArray objectAtIndex:row]];
        
    }
    else if([self.transmissionPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.transmissionArray objectAtIndex:row]];
        
    }
    else if([self.conditionPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.coditionArray objectAtIndex:row]];
        
    }
    else if([self.driveTrainPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.driveTrainArray objectAtIndex:row]];
        
    }
    else if([self.engineCylindersPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.engineCylindersArray objectAtIndex:row]];
        
    }
    else if([self.doorsPicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.doorsArray objectAtIndex:row]];
        
    }
    else if([self.fuelTypePicker isEqual:pickerView])
    {
        [pickerLabel setText:[self.fuelTypeArray objectAtIndex:row]];
        
    }
    
    return pickerLabel;
    
    
    
}



- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.exteriorColorPicker isEqual:pickerView])
    {
        self.exteriorColorTextField.text = [self.exteriorColorArray objectAtIndex:row];
        //
        
        
        
    }
    else if([self.interiorColorPicker isEqual:pickerView])
    {
        self.interiorColorTextField.text = (NSString *)[self.self.interiorColorArray objectAtIndex:row];
        
        
    }
    
    else if([self.transmissionPicker isEqual:pickerView])
    {
        self.transmissionTextField.text = (NSString *)[self.transmissionArray objectAtIndex:row];
        
    }
    
    else if([self.conditionPicker isEqual:pickerView])
    {
        self.conditionTextField.text = (NSString *)[self.coditionArray objectAtIndex:row];
        
        
    }
    else if([self.driveTrainPicker isEqual:pickerView])
    {
        self.driveTrainTextField.text = (NSString *)[self.driveTrainArray objectAtIndex:row];
        
        
    }
    else if([self.engineCylindersPicker isEqual:pickerView])
    {
        self.engineCylindersTextField.text = (NSString *)[self.engineCylindersArray objectAtIndex:row];
        
        
    }
    
    else if([self.doorsPicker isEqual:pickerView])
    {
        self.doorsTextField.text = (NSString *)[self.doorsArray objectAtIndex:row];
        
        
    }
    else if([self.fuelTypePicker isEqual:pickerView])
    {
        self.fuelTypeTextField.text = (NSString *)[self.fuelTypeArray objectAtIndex:row];
        
        
    }
    
}

#pragma mark - Done Button Methods

-(void)exteriorColorDoneButtonTapped
{
    [self.exteriorColorTextField resignFirstResponder];
    
}
-(void)interiorColorDoneButtonTapped
{
    [self.interiorColorTextField resignFirstResponder];
}
-(void)transmissionDoneButtonTapped
{
    [self.transmissionTextField resignFirstResponder];
}
-(void)conditionDoneButtonTapped
{
    [self.conditionTextField resignFirstResponder];
}
-(void)driveTrainDoneButtonTapped
{
    [self.driveTrainTextField resignFirstResponder];
}
-(void)engineCylindersDoneButtonTapped
{
    [self.engineCylindersTextField resignFirstResponder];
}
-(void)DoorsDoneButtonTapped
{
    [self.doorsTextField resignFirstResponder];
}

-(void)FuelTypeToolbarDoneButtonTapped
{
    [self.fuelTypeTextField resignFirstResponder];
}




////Previous and Next Button Tapped

-(void)previousButtonTapped
{
    UITextField *tempTxF = nil;
    
    
    tempTxF = nil;
    
    for (int i = 1; i<=12; i++)
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
    
    for (int i = 1; i<=12; i++)
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
    
}


#pragma mark - Bar Button Methods
- (void)enableDisableFields:(BOOL)enable
{
    
    /*
     /UpdateCarDetails/{UID}/{Year}/{ExteriorColor}/{InteriorColor}/{Transmission}/{DriveTrain}/{NumberOfDoors}/{MakeModelID}/{BodyTypeID}/{CarID}/{Price}/{Mileage}
     /{VIN}/{NumberOfCylinder}/{FueltypeID}/{zip}/{City}/{Description}/{VehicleCondition}/{Title}/{StateID}/{AuthenticationID}/{CustomerID}/
     
     */
    if (enable) {
        self.titleTextField.enabled=YES;
        self.titleTextField.textColor = [UIColor blackColor];
        self.titleTextField.backgroundColor=[UIColor whiteColor];
        
        self.askPriceTextField.enabled=YES;
        self.askPriceTextField.textColor = [UIColor blackColor];
        self.askPriceTextField.backgroundColor=[UIColor whiteColor];
        
        self.mileageTextField.enabled=YES;
        self.mileageTextField.textColor = [UIColor blackColor];
        self.mileageTextField.backgroundColor=[UIColor whiteColor];
        
        self.exteriorColorTextField.enabled=YES;
        self.exteriorColorTextField.textColor = [UIColor blackColor];
        self.exteriorColorTextField.backgroundColor=[UIColor whiteColor];
        
        self.interiorColorTextField.userInteractionEnabled=YES;
        self.interiorColorTextField.textColor = [UIColor blackColor];
        self.interiorColorTextField.backgroundColor=[UIColor whiteColor];
        
        self.transmissionTextField.enabled=YES;
        self.transmissionTextField.textColor = [UIColor blackColor];
        self.transmissionTextField.backgroundColor=[UIColor whiteColor];
        
        self.conditionTextField.enabled=YES;
        self.conditionTextField.textColor = [UIColor blackColor];
        self.conditionTextField.backgroundColor=[UIColor whiteColor];
        
        self.driveTrainTextField.enabled=YES;
        self.driveTrainTextField.textColor = [UIColor blackColor];
        self.driveTrainTextField.backgroundColor=[UIColor whiteColor];
        
        self.engineCylindersTextField.enabled=YES;
        self.engineCylindersTextField.textColor = [UIColor blackColor];
        self.engineCylindersTextField.backgroundColor=[UIColor whiteColor];
        
        self.doorsTextField.userInteractionEnabled=YES;
        self.doorsTextField.textColor = [UIColor blackColor];
        self.doorsTextField.backgroundColor=[UIColor whiteColor];
        
        self.fuelTypeTextField.enabled=YES;
        self.fuelTypeTextField.textColor = [UIColor blackColor];
        self.fuelTypeTextField.backgroundColor=[UIColor whiteColor];
        
        self.vinTextField.enabled=YES;
        self.vinTextField.textColor = [UIColor blackColor];
        self.vinTextField.backgroundColor=[UIColor whiteColor];
    }
    else
    {
        self.titleTextField.enabled=NO;
        self.titleTextField.textColor = [UIColor blackColor];
        self.titleTextField.backgroundColor=[UIColor clearColor];
        
        self.askPriceTextField.enabled=NO;
        self.askPriceTextField.textColor = [UIColor blackColor];
        self.askPriceTextField.backgroundColor=[UIColor clearColor];
        
        self.mileageTextField.enabled=NO;
        self.mileageTextField.textColor = [UIColor blackColor];
        self.mileageTextField.backgroundColor=[UIColor clearColor];
        
        self.exteriorColorTextField.enabled=NO;
        self.exteriorColorTextField.textColor = [UIColor blackColor];
        self.exteriorColorTextField.backgroundColor=[UIColor clearColor];
        
        self.interiorColorTextField.userInteractionEnabled=NO;
        self.interiorColorTextField.textColor = [UIColor blackColor];
        self.interiorColorTextField.backgroundColor=[UIColor clearColor];
        
        self.transmissionTextField.enabled=NO;
        self.transmissionTextField.textColor = [UIColor blackColor];
        self.transmissionTextField.backgroundColor=[UIColor clearColor];
        
        self.conditionTextField.enabled=NO;
        self.conditionTextField.textColor = [UIColor blackColor];
        self.conditionTextField.backgroundColor=[UIColor clearColor];
        
        self.driveTrainTextField.enabled=NO;
        self.driveTrainTextField.textColor = [UIColor blackColor];
        self.driveTrainTextField.backgroundColor=[UIColor clearColor];
        
        self.engineCylindersTextField.enabled=NO;
        self.engineCylindersTextField.textColor = [UIColor blackColor];
        self.engineCylindersTextField.backgroundColor=[UIColor clearColor];
        
        self.doorsTextField.userInteractionEnabled=NO;
        self.doorsTextField.textColor = [UIColor blackColor];
        self.doorsTextField.backgroundColor=[UIColor clearColor];
        
        self.fuelTypeTextField.enabled=NO;
        self.fuelTypeTextField.textColor = [UIColor blackColor];
        self.fuelTypeTextField.backgroundColor=[UIColor clearColor];
        
        self.vinTextField.enabled=NO;
        self.vinTextField.textColor = [UIColor blackColor];
        self.vinTextField.backgroundColor=[UIColor clearColor];
        
    }
}

- (BOOL)userMadeChanges
{
    BOOL changesMade=NO;
    
    
    BOOL titleNotChanged=(IsEmpty(self.titleTextField.text) && [[self.carReceived title] isEqualToString:@"Emp"]) || [self.titleTextField.text isEqualToString:[self.carReceived title]];
    
    BOOL priceNotChanged=[self.askPriceTextField.text integerValue] ==[self.carReceived price];
    
    
    BOOL mileageNotChanged=[self.mileageTextField.text integerValue]==[self.carReceived mileage];
    
    
    BOOL exteriorColorNotChanged=IsEmpty(self.exteriorColorTextField.text) || [self.exteriorColorTextField.text isEqualToString:[self.carReceived exteriorColor]];
    
    BOOL interiorColorNotChanged=IsEmpty(self.interiorColorTextField.text) || [self.interiorColorTextField.text isEqualToString:[self.carReceived interiorColor]];
    
    BOOL transmissionNotChanged=IsEmpty(self.transmissionTextField.text) || [self.transmissionTextField.text isEqualToString:[self.carReceived transmission]];
    
    BOOL conditionNotChanged=IsEmpty(self.conditionTextField.text) || [self.conditionTextField.text isEqualToString:[self.carReceived ConditionDescription]];
    
    BOOL driveTrainNotChanged=IsEmpty(self.driveTrainTextField.text) || [self.driveTrainTextField.text isEqualToString:[self.carReceived driveTrain]];
    
    BOOL engineCylindersNotChanged=IsEmpty(self.engineCylindersTextField.text) || [self.engineCylindersTextField.text isEqualToString:[self.carReceived engineCylinders]];
    
    BOOL numberOfDoorsNotChanged=IsEmpty(self.doorsTextField.text) || [self.doorsTextField.text isEqualToString:[self.carReceived numberOfDoors]];
    
    BOOL fueltypeNotChanged=IsEmpty(self.fuelTypeTextField.text) || [self.fuelTypeTextField.text isEqualToString:[self.carReceived fueltype]];
    
    BOOL vinNotChanged=(IsEmpty(self.vinTextField.text) && [[self.carReceived vin] isEqualToString:@"Emp"]) || [self.vinTextField.text isEqualToString:[self.carReceived vin]];
    
    
    
    
    if (!(titleNotChanged &&  priceNotChanged && mileageNotChanged && exteriorColorNotChanged && interiorColorNotChanged && transmissionNotChanged && conditionNotChanged && driveTrainNotChanged && engineCylindersNotChanged && numberOfDoorsNotChanged && fueltypeNotChanged && vinNotChanged)) {
        changesMade=YES;
    }
    
    return changesMade;
    
}

- (void)rightBarButtonTapped:(id) sender
{
    
    
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
        
        [self loadPickersWithUserData];
        
        [self enableDisableFields:NO];
        
        //set rightbarbutton to 'Edit' and leftbarbutton to 'Back'
        self.leftBarButton.title=@"Back";
        self.rightBarButton.title=@"Edit";
        
    }
}

- (void)callWebServiceToSaveData
{
    
    
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
    NSInteger priceInt=[self.askPriceTextField.text integerValue];
    if (priceInt<=0) {
        priceInt=0;
    }
    NSString *price=[NSString stringWithFormat:@"%d",priceInt];
    
    NSInteger mileageInt=[self.mileageTextField.text integerValue];
    if (mileageInt<=0) {
        mileageInt=0;
    }
    NSString *mileage=[NSString stringWithFormat:@"%d",mileageInt];
    
    NSString *vin;
    if (IsEmpty(self.vinTextField.text)) {
        vin=@"Emp";
    }
    else
    {
        vin=self.vinTextField.text;
    }
    
   
    NSUInteger indexOfFuel=[self.fuelTypeArray indexOfObject:self.fuelTypeTextField.text];
    NSString *fuelTypeId=[self.fuelTypeIdsArray objectAtIndex:indexOfFuel];
    
    
    //title
    NSString *titleToSend;
    if (IsEmpty(self.titleTextField.text)) {
        titleToSend=@"Emp";
    }
    else
    {
        titleToSend=self.titleTextField.text;
    }
    
    NSArray *keys=[NSArray arrayWithObjects:@"UID",@"Year",@"ExteriorColor",@"InteriorColor",@"Transmission",@"DriveTrain",@"NumberOfDoors",@"MakeModelID",@"BodyTypeID",@"CarID",@"Price",@"Mileage",@"VIN",@"NumberOfCylinder",@"FueltypeID",@"zip",@"City",@"Description",@"VehicleCondition",@"Title",@"StateID",@"AuthenticationID",@"CustomerID",@"SessionID", nil];
    
    NSArray *values=[NSArray arrayWithObjects:[self.carReceived uid],year,self.exteriorColorTextField.text,self.interiorColorTextField.text,self.transmissionTextField.text,self.driveTrainTextField.text,self.doorsTextField.text,[self.carReceived modelID],[self.carReceived bodytypeID],carid,price,mileage,vin,self.engineCylindersTextField.text,fuelTypeId,[self.carReceived zipCode],[self.carReceived city],[self.carReceived extraDescription],self.conditionTextField.text,titleToSend,[self.carReceived stateID],@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",retrieveduuid,sessionID, nil];
    
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    __weak VehicleInformationViewController *weakSelf=self;
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"MobileService/CarService.asmx/UpdateCarDetails" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        
        
        
        [weakSelf webServiceCallToSaveDataSucceededWithResponse:operation.responseString];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [weakSelf hideActivityViewer];
        
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
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Modifications saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        //save the modified bodystyle, bodystyleid to car record, because if the user goes back and comes to this screen again, he should see updated details.
        NSString *title=self.titleTextField.text;
        if (IsEmpty(title)) {
            title=@"Emp";
        }
        NSString *price=self.askPriceTextField.text;
        if (IsEmpty(price)) {
            price=@"0";
        }
        NSString *mileage=self.mileageTextField.text;
        if (IsEmpty(mileage)) {
            mileage=@"0";
        }
        NSString *vin=self.vinTextField.text;
        if (IsEmpty(vin)) {
            vin=@"Emp";
        }
        [self.carReceived setTitle:title];
        [self.carReceived setPrice:[price integerValue]];
        [self.carReceived setMileage:[mileage integerValue]];
        [self.carReceived setExteriorColor:self.exteriorColorTextField.text];
        [self.carReceived setInteriorColor:self.interiorColorTextField.text];
        [self.carReceived setTransmission:self.transmissionTextField.text];
        [self.carReceived setConditionDescription:self.conditionTextField.text];
        [self.carReceived setDriveTrain:self.driveTrainTextField.text];
        [self.carReceived setEngineCylinders:self.engineCylindersTextField.text];
        [self.carReceived setNumberOfDoors:self.doorsTextField.text];
        [self.carReceived setFueltype:self.fuelTypeTextField.text];
        [self.carReceived setVin:vin];
        
        
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



#pragma mark - Textfield Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField

{
    
    if ([textField isEqual:self.exteriorColorTextField]) {
        self.exteriorColorPicker.showsSelectionIndicator = YES;
        self.exteriorColorTextField.inputView = self.exteriorColorPicker;
        
        return YES;
    }
    
    else if ([textField isEqual:self.interiorColorTextField])
    {
        self.interiorColorPicker.showsSelectionIndicator = YES;
        self.interiorColorTextField.inputView = self.interiorColorPicker;
        
        return YES;
    }
    
    else if ([textField isEqual:self.transmissionTextField])
    {
        self.transmissionPicker.showsSelectionIndicator = YES;
        self.transmissionTextField.inputView = self.transmissionPicker;
        
        return YES;
    }
    
    else if ([textField isEqual:self.conditionTextField])
    {
        self.conditionPicker.showsSelectionIndicator = YES;
        self.conditionTextField.inputView = self.conditionPicker;
        
        return YES;
    }
    
    else if ([textField isEqual:self.driveTrainTextField])
    {
        self.driveTrainPicker.showsSelectionIndicator = YES;
        self.driveTrainTextField.inputView = self.driveTrainPicker;
        
        return YES;
    }
    else if ([textField isEqual:self.engineCylindersTextField])
    {
        self.engineCylindersPicker.showsSelectionIndicator = YES;
        self.engineCylindersTextField.inputView = self.engineCylindersPicker;
        
        return YES;
    }
    else if ([textField isEqual:self.doorsTextField])
    {
        self.doorsPicker.showsSelectionIndicator = YES;
        self.doorsTextField.inputView = self.doorsPicker;
        
        return YES;
    }
    
    else if ([textField isEqual:self.fuelTypeTextField])
    {
        self.fuelTypePicker.showsSelectionIndicator = YES;
        self.fuelTypeTextField.inputView = self.fuelTypePicker;
        
        return YES;
    }
    
    return YES;
    
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



- (void)keyboardDidHide:(id)sender
{
    
    if (![self firstResponderFound]) {
        TPKeyboardAvoidingScrollView *scrollView=[[self.view subviews] lastObject];
        
        [scrollView setContentInset:UIEdgeInsetsZero];
    }
    
}


-(void)dealloc
{
    _carReceived=nil;
    
    _exteriorColorPicker=nil;
    _interiorColorPicker=nil;
    _transmissionPicker=nil;
    _conditionPicker=nil;
    _driveTrainPicker=nil;
    _engineCylindersPicker=nil;
    _doorsPicker=nil;
    _fuelTypePicker=nil;
    _exteriorColorTextField=nil;
    _interiorColorTextField=nil;
    _transmissionTextField=nil;
    _conditionTextField=nil;
    _driveTrainTextField=nil;
    _engineCylindersTextField=nil;
    _doorsTextField=nil;
    _fuelTypeTextField=nil;
    _exteriorColorArray=nil;
    _interiorColorArray=nil;
    _transmissionArray=nil;
    _coditionArray=nil;
    _driveTrainArray=nil;
    _engineCylindersArray=nil;
    _doorsArray=nil;
    _fuelTypeArray=nil;
    _titleTextField=nil;
    _askPriceTextField=nil;
    _mileageTextField=nil;
    _vinTextField=nil;
    _exteriorColorId=nil;
    _interiorColorId=nil;
    _transmissionIdsArray=nil;
    _conditionIdsArray=nil;
    _driveTrainIdsArray=nil;
    _engineCylindersIdsArray=nil;
    _doorsIdsArray=nil;
    _fuelTypeIdsArray=nil;
    _opQueue=nil;
    _rightBarButton=nil;
   
    
}


@end
