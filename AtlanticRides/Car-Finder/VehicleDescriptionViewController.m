//
//  VehicleDescriptionViewController.m
//  Car-Finder
//
//  Created by Mac on 11/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "VehicleDescriptionViewController.h"
//#import "CommonMethods.h"
#import "TPKeyboardAvoidingScrollView.h"

#import "CommonMethods.h"

//for border for textView
#import "QuartzCore/QuartzCore.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "LoginViewController.h"
#import "AFNetworking.h"
#import "CarRecord.h"

@interface VehicleDescriptionViewController()

@property(strong,nonatomic) UITextField *titleTextField;
@property(strong,nonatomic) UITextView *descTextView;

@property(strong,nonatomic) UIBarButtonItem *leftBarButton,*rightBarButton;

@property(strong,nonatomic) NSOperationQueue *opQueue;


@property(assign,nonatomic) BOOL isShowingLandscapeView;

@property(strong,nonatomic) UIActivityIndicatorView *indicator;


- (void)callWebServiceToSaveData;

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;
- (BOOL)userMadeChanges;
- (void)enableDisableFields:(BOOL)enable;

-(void)retrieveLoggedUserPreviousData;
@end

@implementation VehicleDescriptionViewController

@synthesize titleTextField=_titleTextField,descTextView=_descTextView,rightBarButton=_rightBarButton,leftBarButton=_leftBarButton,opQueue=_opQueue;

@synthesize carReceived=_carReceived;


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
    
    //    [CommonMethods putBackgroundImageOnView:self.view];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    //navigation bar title
    NSString *navTitle=[defaults valueForKey:@"navTitle"];
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
    
    [CommonMethods putBackgroundImageOnView:self.view];
    
    TPKeyboardAvoidingScrollView *descScrollView =[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //descScrollView.bounces=NO;
    [self.view addSubview:descScrollView];
    
    
    
    
    
    UIView* contentView = [UIView new];
    //contentView.backgroundColor = [UIColor greenColor];
    [descScrollView addSubview:contentView];
    
    
    //
    UILabel *titleLbl=[[UILabel alloc]init];
    //titleLbl.frame=CGRectMake(20, 20, 100, 30);
    titleLbl.backgroundColor=[UIColor clearColor];
    titleLbl.text=[NSString stringWithFormat:@"Title: "];
    titleLbl.textColor=[UIColor whiteColor];
    titleLbl.font=[UIFont boldSystemFontOfSize:15];
    [contentView addSubview:titleLbl];
    
    
    self.titleTextField = [[UITextField alloc] init]; //WithFrame:CGRectMake(58, 22, 246, 30)];
    self.titleTextField.placeholder = @"Enter Title";
    self.titleTextField.backgroundColor=[UIColor clearColor];
    self.titleTextField.borderStyle=UITextBorderStyleRoundedRect;
    self.titleTextField.font=[UIFont systemFontOfSize:14];
    self.titleTextField.textAlignment=NSTextAlignmentLeft;
    self.titleTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.titleTextField.keyboardType=UIKeyboardTypeAlphabet;
    self.titleTextField.returnKeyType=UIReturnKeyDone;
    self.titleTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    //self.cityTextField.tag=1;
    self.titleTextField.delegate=self;
    [contentView addSubview:self.titleTextField];
    
    //
    UILabel *descriptionLabel=[[UILabel alloc]init];
    //descriptionLabel.frame=CGRectMake(20, 70, 100, 30);
    descriptionLabel.backgroundColor=[UIColor clearColor];
    descriptionLabel.text=[NSString stringWithFormat:@"Description: "];
    descriptionLabel.textColor=[UIColor whiteColor];
    descriptionLabel.font=[UIFont boldSystemFontOfSize:15];
    [contentView addSubview:descriptionLabel];
    
    
    
    self.descTextView = [[UITextView alloc] init];//WithFrame:CGRectMake(20, 110, 280, 200)];
    //self.descTextView.placeholder=@"Car Selling Points";
    self.descTextView.backgroundColor=[UIColor clearColor];
    self.descTextView.font=[UIFont systemFontOfSize:14];
    //for border
    self.descTextView.layer.cornerRadius = 5.0;
    self.descTextView.clipsToBounds = YES;
    [self.descTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.descTextView.layer setBorderWidth:2.0];
    
    //for placeholder text
    self.descTextView.text = @"Enter car's selling points";
    self.descTextView.textColor = [UIColor lightGrayColor];
    
    self.descTextView.delegate=self;
    [contentView addSubview:self.descTextView];
    
    
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

    
    
    //autolayout
    [descScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLbl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.descTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //
    UITextField *tempTitleTF=self.titleTextField;
    UITextView *tempDescView=self.descTextView;
    
    NSDictionary *viewsDict=NSDictionaryOfVariableBindings(descScrollView,contentView,titleLbl,tempTitleTF,descriptionLabel,tempDescView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[descScrollView]|" options:0 metrics:0 views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[descScrollView]|" options:0 metrics:0 views:viewsDict]];
    
    [descScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:0 views:viewsDict]];
    [descScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:viewsDict]];
    
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLbl]-[tempTitleTF(>=60)]" options:NSLayoutFormatAlignAllBaseline metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionLabel]-|" options:0 metrics:0 views:viewsDict]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tempDescView(>=20)]-|" options:0 metrics:0 views:viewsDict]];
    
    //now give vertical positions
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLbl]-20-[descriptionLabel]-[tempDescView(>=80)]-|" options:0 metrics:0 views:viewsDict]];
    
    NSLayoutConstraint *c1=[NSLayoutConstraint constraintWithItem:tempDescView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-20];
    [contentView addConstraint:c1];
    
    
    //for fixing the contentView with main view so that multiline label will be displayed according to screen width (including rotation. see willAnimateRotationToInterfaceOrientation:animation method also)
    UIView *mainView = self.view;
    
    NSDictionary* viewsDict2 = NSDictionaryOfVariableBindings(descScrollView, contentView, mainView);
    
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:viewsDict2]];
    
    
    //initially set user interaction to NO
    [self enableDisableFields:NO];
    
    self.opQueue=[[NSOperationQueue alloc] init];
    [self.opQueue setName:@"VehicleDescriptionViewController Queue"];
    [self.opQueue setMaxConcurrentOperationCount:1];
    
    [self retrieveLoggedUserPreviousData];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.indicator stopAnimating];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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

#pragma mark - TextField Delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

#pragma mark - TextView Delegates
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.descTextView.textColor isEqual:[UIColor lightGrayColor]]) {
        self.descTextView.text = @"";
    }
    
    self.descTextView.textColor = [UIColor blackColor];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.descTextView.text.length == 0){
        self.descTextView.textColor = [UIColor lightGrayColor];
        self.descTextView.text = @"Enter car's selling points";
        [self.descTextView resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.descTextView resignFirstResponder];
}


#pragma mark - Bar Button Methods
- (void)enableDisableFields:(BOOL)enable
{
    if (enable) {
        
        self.titleTextField.enabled=YES;
        self.titleTextField.textColor = [UIColor blackColor];
        self.titleTextField.backgroundColor=[UIColor whiteColor];
        self.descTextView.editable=YES;
        self.descTextView.textColor = [UIColor blackColor];
        self.descTextView.backgroundColor=[UIColor whiteColor];
        
        
    }
    else
    {
        
        self.titleTextField.enabled=NO;
        self.titleTextField.textColor = [UIColor whiteColor];
        self.titleTextField.backgroundColor=[UIColor clearColor];
        self.descTextView.editable=NO;
        self.descTextView.textColor = [UIColor whiteColor];
        self.descTextView.backgroundColor=[UIColor clearColor];
    }
}


- (BOOL)userMadeChanges
{
    BOOL changesMade=NO;
    
    BOOL titleNoChanged=(IsEmpty(self.titleTextField.text) && [[self.carReceived title] isEqualToString:@"Emp"]) || [self.titleTextField.text isEqualToString:[self.carReceived title]];
    
    BOOL descNotChanged=(IsEmpty(self.descTextView.text) && [[self.carReceived extraDescription] isEqualToString:@"Emp"]) || [self.descTextView.text isEqualToString:[self.carReceived extraDescription]];
    
    
    if (!(titleNoChanged && descNotChanged)) {
        changesMade=YES;
    }
    //NSLog(@"changesMade=%d",changesMade);
    
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
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            self.rightBarButton.enabled=NO;
            [self.indicator startAnimating];
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
    NSString *price=[NSString stringWithFormat:@"%d",[self.carReceived price]];
    NSString *mileage=[NSString stringWithFormat:@"%d",[self.carReceived mileage]];
    
    //title
    NSString *titleToSend;
    if (IsEmpty(self.titleTextField.text)) {
        titleToSend=@"Emp";
    }
    else
    {
        titleToSend=self.titleTextField.text;
    }
    
    //description
    NSString *descriptionToSend;
    if (IsEmpty(self.descTextView.text)) {
        descriptionToSend=@"Emp";
    }
    else
    {
        descriptionToSend=self.descTextView.text;
    }
    
    NSArray *keys=[NSArray arrayWithObjects:@"UID",@"Year",@"ExteriorColor",@"InteriorColor",@"Transmission",@"DriveTrain",@"NumberOfDoors",@"MakeModelID",@"BodyTypeID",@"CarID",@"Price",@"Mileage",@"VIN",@"NumberOfCylinder",@"FueltypeID",@"zip",@"City",@"Description",@"VehicleCondition",@"Title",@"StateID",@"AuthenticationID",@"CustomerID",@"SessionID", nil];
    NSArray *values=[NSArray arrayWithObjects:[self.carReceived uid],year,[self.carReceived exteriorColor],[self.carReceived interiorColor],[self.carReceived transmission],[self.carReceived driveTrain],[self.carReceived numberOfDoors],[self.carReceived modelID],[self.carReceived bodytypeID],carid,price,mileage,[self.carReceived vin],[self.carReceived engineCylinders],[self.carReceived fuelTypeId],[self.carReceived zipCode],[self.carReceived city],descriptionToSend,[self.carReceived ConditionDescription],titleToSend,[self.carReceived stateID],@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",retrieveduuid,sessionID, nil];
    
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    //NSLog(@"parameters=%@",parameters);
    __weak VehicleDescriptionViewController *weakSelf=self;
    
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
    [self.indicator stopAnimating];
    if ([str isEqualToString:@"Success"]) {
        self.rightBarButton.title=@"Edit";
        [self enableDisableFields:NO];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Modifications saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        //save the modified data to car record, because if the user goes back and comes to this screen again, he should see updated details.
        NSString *title=self.titleTextField.text;
        if (IsEmpty(title)) {
            title=@"Emp";
        }
        NSString *extraDescription=self.descTextView.text;
        if (IsEmpty(extraDescription)) {
            extraDescription=@"Emp";
        }
        [self.carReceived setTitle:title];
        [self.carReceived setExtraDescription:extraDescription];
        
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
    [self.indicator stopAnimating];
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    //display alert
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

-(void)retrieveLoggedUserPreviousData
{
    
    if (IsEmpty([self.carReceived title])||[[self.carReceived title] isEqualToString:@"Emp"]) {
        self.titleTextField.text =@"";
    }
    else
    {
        self.titleTextField.text = [self.carReceived title];
    }
    
    if (IsEmpty([self.carReceived extraDescription])||[[self.carReceived extraDescription] isEqualToString:@"Emp"]) {
        self.descTextView.text =@"";
    }
    else
    {
        self.descTextView.text = [self.carReceived extraDescription];
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
    
    _opQueue=nil;
    _rightBarButton=nil;
   
    _titleTextField=nil;
    _descTextView=nil;
}

@end
