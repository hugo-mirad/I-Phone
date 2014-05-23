//
//  AddNewCar.m
//  Car-Finder
//
//  Created by Venkata Chinni on 10/11/13.
//
//

#import "AddNewCar.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CommonMethods.h"
//for coredata
#import "AppDelegate.h"
#import "Makes.h"
#import "Models.h"

#import "SelectedCarDetails.h"


#import "AFNetworking.h"

//for glossy button
#import "CheckButton.h"
#import "UIButton+Glossy.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"


#import "MyCarsList.h"
#import "CarRecord.h"

@interface AddNewCar ()

@property (strong, nonatomic) TPKeyboardAvoidingScrollView *addNewCarScrollView;

@property(strong,nonatomic) UITextField *makeTextField,*modelTextField,*yearTextField,*priceTextField,*mileageTextField;

@property(strong,nonatomic) UIPickerView *makesPicker,*modelsPicker,*yearPicker;

@property(copy,nonatomic) NSString *makeNameSelected,*makeIdSelected,*modelNameSelected,*modelIdSelected,*yearSelected, *yearIdSelected;


@property(strong,nonatomic)  NSMutableDictionary *makesDictionary,*modelsDictionary;
@property(strong,nonatomic)  NSMutableArray *sortedMakes,*sortedModels,*sortedYears;

//for coredata
@property(strong,nonatomic) NSManagedObjectContext *managedObjectContext;


@property(strong,nonatomic) AFHTTPClient *Client;

//for xml parsing
@property(strong,nonatomic) NSXMLParser *xmlParser;
@property(copy,nonatomic) NSString *currentelement,*currentElementChars,*generatedCarId;

@property(strong,nonatomic) CheckButton *addNewCarButton;

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;


//@property(strong,nonatomic) CheckButton *saveButton;

@end

@implementation AddNewCar

@synthesize packageDetailsDict=_packageDetailsDict,addNewCarScrollView=_addNewCarScrollView;

@synthesize makeTextField=_makeTextField,modelTextField=_modelTextField,yearTextField=_yearTextField,priceTextField=_priceTextField,mileageTextField=_mileageTextField;

@synthesize makesPicker=_makesPicker,modelsPicker=_modelsPicker,yearPicker=_yearPicker;

@synthesize makeNameSelected=_makeNameSelected,makeIdSelected=_makeIdSelected,modelNameSelected=_modelNameSelected,modelIdSelected=_modelIdSelected,yearSelected=_yearSelected, yearIdSelected=_yearIdSelected;

@synthesize makesDictionary=_makesDictionary,modelsDictionary=_modelsDictionary,sortedMakes=_sortedMakes,sortedModels=_sortedModels,sortedYears=_sortedYears;

@synthesize managedObjectContext=_managedObjectContext;


@synthesize Client = _Client,generatedCarId=_generatedCarId,addNewCarButton=_addNewCarButton;


//@synthesize saveButton=_saveButton;


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

#pragma mark - View Life Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
     navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=@"Add A New Car"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    
        [CommonMethods putBackgroundImageOnView:self.view];
    
    self.addNewCarScrollView=[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.addNewCarScrollView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:self.addNewCarScrollView];

    UILabel *makePickerLabel=[[UILabel alloc]init];
    makePickerLabel.frame=CGRectMake(10, 20, 60, 30);
    makePickerLabel.backgroundColor=[UIColor clearColor];
    makePickerLabel.text=@"Make:*";
    makePickerLabel.textColor=[UIColor blackColor];
    makePickerLabel.font=[UIFont boldSystemFontOfSize:14];
    [self.addNewCarScrollView addSubview:makePickerLabel];
    makePickerLabel=nil;
    
    
    self.makeTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 20, 200, 30)];
    self.makeTextField.tag = 1;
    self.makeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.makeTextField.backgroundColor = [UIColor clearColor];
    self.makeTextField.textColor = [UIColor blackColor];
    self.makeTextField.delegate=self;
    [self.addNewCarScrollView addSubview:self.makeTextField];
    
    //
    
    UIToolbar *toolbarForPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 36)]; //should code with variables to support view resizing
    toolbarForPicker.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonTapped)];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextButtonTapped)];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //using default text field delegate method here, here you could call
    
    //myTextField.resignFirstResponder to dismiss the views
    [toolbarForPicker setItems:[NSArray arrayWithObjects:previousButton,nextButton,spaceButton,doneButton,nil] animated:NO];
    self.makeTextField.inputAccessoryView = toolbarForPicker;
    
    //toolbarForPicker=nil;
    doneButton=nil;
    previousButton=nil;
    nextButton=nil;
    spaceButton=nil;
    
    
    
    UILabel *modelLabel=[[UILabel alloc]init];
    modelLabel.frame=CGRectMake(10, 60, 60, 30);
    modelLabel.backgroundColor=[UIColor clearColor];
    modelLabel.text=@"Model:*";
    modelLabel.textColor=[UIColor blackColor];
    modelLabel.font=[UIFont boldSystemFontOfSize:14];
    [self.addNewCarScrollView addSubview:modelLabel];
    modelLabel=nil;
    
    
    
    self.modelTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 60, 200, 30)];
    
    self.modelTextField.tag = 2;
    self.modelTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.modelTextField.backgroundColor = [UIColor clearColor];
    self.modelTextField.textColor = [UIColor blackColor];
    self.modelTextField.delegate=self;
    [self.addNewCarScrollView addSubview:self.modelTextField];
    //
    
    self.modelTextField.inputAccessoryView = toolbarForPicker;
    
    
    UILabel *yearLabel=[[UILabel alloc]init];
    yearLabel.frame=CGRectMake(10, 100, 60, 30);
    yearLabel.backgroundColor=[UIColor clearColor];
    yearLabel.text=@"Year:*";
    yearLabel.textColor=[UIColor blackColor];
    yearLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.addNewCarScrollView addSubview:yearLabel];
    yearLabel=nil;
    
    
    self.yearTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 100, 200, 30)];
    
    self.yearTextField.tag = 3;
    self.yearTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.yearTextField.backgroundColor = [UIColor clearColor];
    self.yearTextField.textColor = [UIColor blackColor];
    self.yearTextField.delegate=self;
    [self.addNewCarScrollView addSubview:self.yearTextField];
    
    self.yearTextField.inputAccessoryView = toolbarForPicker;
    
    
    
    //alloc pickers
    self.makesPicker = [[UIPickerView alloc] init];
    self.makesPicker.dataSource = self;
    self.makesPicker.delegate = self;
    
    self.modelsPicker = [[UIPickerView alloc] init];
    self.modelsPicker.dataSource = self;
    self.modelsPicker.delegate = self;
    
    self.yearPicker = [[UIPickerView alloc] init];
    self.yearPicker.dataSource = self;
    self.yearPicker.delegate = self;
    
    
    
    [self loadMakesDataFromDisk];
    
    //initialize text fields as data is now loaded into model objects
    self.makeTextField.text=[self.sortedMakes objectAtIndex:0];
    self.makeNameSelected=@"Unspecified";
    self.makeIdSelected=@"0";
    
    [self loadModelsDataFromDiskForMake:@"0"];
    self.modelTextField.text=@"Unspecified"; //[self.sortedModels objectAtIndex:0];
    self.modelNameSelected=@"Unspecified";
    self.modelIdSelected=@"0";
    
    self.sortedYears=[[NSMutableArray alloc] initWithCapacity:1];
    
    for (NSInteger i=2013; i>=1910; i--) {
        NSString *yrStr=[NSString stringWithFormat:@"%d",i];
        [self.sortedYears addObject:yrStr];
    }
    [self.sortedYears insertObject:@"Unspecified" atIndex:0];
    self.yearTextField.text=@"Unspecified";
    
    
    
    
    UILabel *priceLabel=[[UILabel alloc]init];
    priceLabel.frame=CGRectMake(10, 140, 70, 30);
    priceLabel.backgroundColor=[UIColor clearColor];
    priceLabel.text=@"Price($):";
    priceLabel.textColor=[UIColor blackColor];
    priceLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.addNewCarScrollView addSubview:priceLabel];
    priceLabel=nil;
    
    
    self.priceTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 140, 200, 30)];
    self.priceTextField.tag = 4;
    self.priceTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.priceTextField.backgroundColor = [UIColor clearColor];
    self.priceTextField.textColor = [UIColor blackColor];
    self.priceTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.priceTextField.delegate=self;
    [self.addNewCarScrollView addSubview:self.priceTextField];
    self.priceTextField.inputAccessoryView = toolbarForPicker;
    
    
    ////
    UILabel *mileageLabel=[[UILabel alloc]init];
    mileageLabel.frame=CGRectMake(10, 180, 70, 30);
    mileageLabel.backgroundColor=[UIColor clearColor];
    mileageLabel.text=@"Millage:";
    mileageLabel.textColor=[UIColor blackColor];
    mileageLabel.font=[UIFont boldSystemFontOfSize:15];
    [self.addNewCarScrollView addSubview:mileageLabel];
    mileageLabel=nil;

    self.mileageTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 180, 200, 30)];
    self.mileageTextField.tag = 5;
    self.mileageTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.mileageTextField.backgroundColor = [UIColor clearColor];
    self.mileageTextField.textColor = [UIColor blackColor];
    self.mileageTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.mileageTextField.delegate=self;
    [self.addNewCarScrollView addSubview:self.mileageTextField];
   // self.mileageTextField.inputAccessoryView = toolbarForPicker;
      
    self.addNewCarButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.addNewCarButton.frame=CGRectMake(self.view.frame.size.width/2-61, 230, 122, 30); //20, 340, 82, 37
    [self.addNewCarButton addTarget:self action:@selector(addNewCarButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addNewCarButton setTitle:@"Add New Car" forState:UIControlStateNormal];
    [self.addNewCarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addNewCarButton setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
    self.addNewCarButton.backgroundColor=[UIColor colorWithRed:105.0f/255.0f green:90.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    [self.addNewCarButton makeGlossy];
    [self.addNewCarScrollView addSubview:self.addNewCarButton];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textfield Delegate Methods


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField

{
    
    if ([textField isEqual:self.makeTextField]) {
        //makesPicker configuration here...
        self.makesPicker.showsSelectionIndicator = YES;
        self.makeTextField.inputView = self.makesPicker;
        return YES;
    }
    else if ([textField isEqual:self.modelTextField]) {
        //modelPicker configuration here...
        self.modelsPicker.showsSelectionIndicator = YES;
        self.modelTextField.inputView = self.modelsPicker;
        return YES;
    }
    else if ([textField isEqual:self.yearTextField]) {
        //year configuration here...
        self.yearPicker.showsSelectionIndicator = YES;
        self.yearTextField.inputView = self.yearPicker;
        return YES;
    }
    
    else if ([textField isEqual:self.priceTextField]) {
        //price configuration here...
        
        self.priceTextField.keyboardType = UIKeyboardTypeNumberPad;

        return YES;
    }
    else if ([textField isEqual:self.mileageTextField]) {
        //mileage configuration here...
        
        self.mileageTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        return YES;
    }
    

    
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - PickerView Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual: self.makesPicker]) {
        
        return 1;
    }
    else if ([pickerView isEqual:self.modelsPicker]) {
        return 1;
    }
    else if ([pickerView isEqual:self.yearPicker]) {
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
    else if ([pickerView isEqual:self.modelsPicker]) {
        if(self.sortedModels && self.sortedModels.count)
        {
            return [self.sortedModels count];
        }
        else
        {
            return 0;
        }
    }
    else if ([pickerView isEqual:self.yearPicker]) {
        if(self.sortedYears && self.sortedYears.count)
        {
            return [self.sortedYears count];
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
    return pickerLabel;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.makesPicker]) {
        
        self.makeTextField.text=[self.sortedMakes objectAtIndex:row];
        
        //when make component is selected, initialize modelid to nil
        self.modelNameSelected=@"Unspecified";
        self.modelIdSelected=@"0";
        self.modelTextField.text=@"Unspecified";
        
        //first find the id of corresponding make selected.
        __weak AddNewCar *weakSelf=self;
        [self.makesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([(NSMutableString *)obj isEqualToString:[weakSelf.sortedMakes objectAtIndex:row]])
            {
                
                weakSelf.makeIdSelected=(NSMutableString *)key;
                *stop=YES;
            }
        }];
        
        //start downloading models logic - begin
        [self loadModelsDataFromDiskForMake:self.makeIdSelected];
        //start downloading models logic -end
        
        self.makeNameSelected=[self.sortedMakes objectAtIndex:row];
        
    }
    else if ([pickerView isEqual:self.modelsPicker])
    {
        self.modelTextField.text=[self.sortedModels objectAtIndex:row];
        
        __weak AddNewCar *weakSelf=self;
        [self.modelsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([obj isEqualToString:[weakSelf.sortedModels objectAtIndex:row]])
            {
                weakSelf.modelIdSelected=key;
                *stop=YES;
            }
        }];
        
        self.modelNameSelected=[self.sortedModels objectAtIndex:row];
    }
    
    else if ([pickerView isEqual:self.yearPicker])
    {
        self.yearTextField.text=[self.sortedYears objectAtIndex:row];

        self.yearSelected =[self.sortedYears objectAtIndex:row];
        self.yearIdSelected=[self.sortedYears objectAtIndex:row];
    }
    
    
}

#pragma mark - Data Required For Pickers
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
   }
    
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    if (IsEmpty(allMakes)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Initial Run: No Makes Data Found" message:@"Tap \"Update Makes Data\" button to get latest Makes And Models." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        self.makesDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
        [self.makesDictionary setObject:@"Unspecified" forKey:@"0"];
        
    }
    [self startProcessingReceivedMakes];
}

-(void)startProcessingReceivedMakes
{
    self.sortedMakes = [[[self.makesDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    if ([[self.makesDictionary allKeys] count]>1) {
        if ([self.sortedMakes containsObject:@"Unspecified"]) {
            [self.sortedMakes removeObject:@"Unspecified"];
        }
        
        [self.sortedMakes insertObject:@"Unspecified" atIndex:0];
        [self.makesDictionary setObject:@"Unspecified" forKey:@"0"];
    }
    
    [self.makesPicker reloadComponent:0];
    self.makesPicker.userInteractionEnabled=YES; //enable picker as data has arrived
    self.makeNameSelected=[self.sortedMakes objectAtIndex:0];
    //    [makeModelPicker setNeedsDisplay];
    
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedMakes objectAtIndex:0];
    __weak AddNewCar *weakSelf=self;
    [self.makesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([(NSMutableString *)obj isEqualToString:firstValue])
        {
            weakSelf.makeIdSelected=(NSMutableString *)key;
            *stop=YES;
        }
    }];
    
    
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
        
    }
    
    if (IsEmpty(allmodels)) {
        self.modelsDictionary=[[NSDictionary dictionaryWithObject:@"Unspecified" forKey:@"0"] mutableCopy];
    }
    
    [self startProcessingReceivedModels];
       [self loadModelsPickerWithData];
}

-(void)startProcessingReceivedModels
{
    self.sortedModels = [[[self.modelsDictionary allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    
    
    //if ([[self.modelsDictionary allKeys] count]>1) {
        if ([self.sortedModels containsObject:@"Unspecified"]) {
            [self.sortedModels removeObject:@"Unspecified"];
        }
        
        [self.sortedModels insertObject:@"Unspecified" atIndex:0];
        
        [self.modelsDictionary setObject:@"Unspecified" forKey:@"0"];
    //}
}

- (void)loadModelsPickerWithData
{
    [self.modelsPicker reloadComponent:0];
    self.modelsPicker.userInteractionEnabled=YES;
    [self.modelsPicker selectRow:0 inComponent:0 animated:YES];
    
    self.modelNameSelected=[self.sortedModels objectAtIndex:0];
    
    //set default value for make id. It is the first displayed make's id
    NSMutableString *firstValue=[self.sortedModels objectAtIndex:0];
    
    __weak AddNewCar *weakSelf=self;
    
    [self.modelsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isEqualToString:firstValue])
        {
            weakSelf.modelIdSelected=key;
            *stop=YES;
        }
    }];
    }

#pragma mark - Done Button Methods

-(void)doneButtonTapped:(id)sender
{
    [self findAndresignFirstResponderIfAny];
    
}

- (void)findAndresignFirstResponderIfAny
{
    
    //BOOL firstResponderPresent=NO;
    
    for (UIView *subView in self.addNewCarScrollView.subviews) {
        
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *tField = (UITextField *)subView;
            
            if ([tField isFirstResponder]) {
                //firstResponderPresent=YES;
                [tField resignFirstResponder];
                break;
            }
        }
    }
    
    
}



////Previous and Next Button Tapped

-(void)previousButtonTapped
{
    UITextField *tempTxF = nil;
    
    
    tempTxF = nil;
    
    for (int i = 1; i<=5; i++)
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
    
    for (int i = 1; i<=5; i++)
    {
        tempTxF = (UITextField *)[self.view viewWithTag:i];
        
        if ([tempTxF isFirstResponder])
        {
            i++;
            
            if (i==6) {
                break;
            }
            tempTxF = (UITextField *)[self.view viewWithTag:i];
            
            [tempTxF becomeFirstResponder];
            break;
        }
    }
    
}

#pragma mark - Private Methods

- (void)addNewCarButtonTapped
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //disable addNewCarButton and enable again after web service result is retrieved
    self.addNewCarButton.enabled=NO;
    
    NSString *make = self.makeTextField.text;
    
    if ([make isEqualToString:@"Unspecified"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Make" message:@"Please choose car's make." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.makeTextField becomeFirstResponder];
        return;

    }
    
    NSString *model = self.modelTextField.text;
    if ([model isEqualToString:@"Unspecified"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Model" message:@"Please choose car's model." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.modelTextField becomeFirstResponder];
        return;
    }
    NSString *price = self.priceTextField.text;
    if (IsEmpty(price)) {
        price=@"Emp";
    }
    else if ([self.priceTextField.text integerValue]<=0) {
        price=@"Emp";
    }
    
    NSString *mileage = self.mileageTextField.text;
    if (IsEmpty(mileage)) {
        mileage=@"Emp";
    }
    else if ([self.mileageTextField.text integerValue]<=0) {
        mileage=@"Emp";
    }
    
    
    
    NSString *year=[NSString stringWithFormat:@"%@",self.yearTextField.text];
    if ([year isEqualToString:@"Unspecified"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Year" message:@"Please choose car's year of manufacturing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.yearTextField becomeFirstResponder];
        return;
    }
    NSString *autID = @"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654";
    NSString *uid = [self.packageDetailsDict objectForKey:@"_UID"];
    NSString *packageID = [self.packageDetailsDict objectForKey:@"_PackageID"];
    NSString *userPackID = [self.packageDetailsDict objectForKey:@"_UserPackID"];
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    self.Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
    
    NSDictionary * parameters = nil;
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:make,@"make",model,@"model",price,@"price",year,@"year",mileage,@"mileage", uid,@"UID",userPackID,@"userPackID",packageID,@"packageID",autID,@"AuthenticationID",retrieveduuid,@"CustomerID",sessionID,@"SessionID",nil];
  
    __weak AddNewCar *weakSelf=self;
    
   [self.Client setParameterEncoding:AFJSONParameterEncoding];
    [self.Client postPath:@"MobileService/CarService.asmx/AddCarDetails" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.addNewCarButton.enabled=YES;
        
        
        [weakSelf webServiceCallToSaveDataSucceededWithResponse:operation.responseString];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.addNewCarButton.enabled=YES;
         [weakSelf webServiceCallToSaveDataFailedWithError:error];
        
    }];
    
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
    else if ([elementName isEqualToString:@"CarID"]) {
        self.generatedCarId=[[NSString alloc]init];
    }
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

{
    if([self.currentelement isEqualToString:@"AASuccess"])
    {
        self.currentElementChars=[[self.currentElementChars stringByAppendingString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
    }
    else if ([self.currentelement isEqualToString:@"CarID"]) {
        self.generatedCarId=[[self.generatedCarId stringByAppendingString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
       
       
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"New Car Added Successfully" message:@"Please enter more details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        //segue only if success and send car id as string
        [self performSegueWithIdentifier:@"AddNewCartoSelectedCarDetailsSegue" sender:self.generatedCarId];
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
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"An error occurred while saving information." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        
    }
    else
    {
        NSLog(@"Error Occurred. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
    
    
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddNewCartoSelectedCarDetailsSegue"]) {
        
        NSString *carId=(NSString *)sender;
        
        CarRecord *car=[[CarRecord alloc] init];
        car.carid=[carId integerValue];
        car.make=self.makeTextField.text;
        car.makeID=self.makeIdSelected;
        car.model=self.modelTextField.text;
        car.modelID=self.modelIdSelected;
        car.year=[self.yearSelected integerValue];
        car.price=[self.priceTextField.text integerValue];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        car.uid=[defaults valueForKey:UID_KEY];

        car.adStatus=@"Active";
        
                        //set packageID from packageDetailsDict
        car.packageID=[self.packageDetailsDict objectForKey:@"_PackageID"];
        
        //set seller related fields using registrationDict from LoginViewController
        NSDictionary *registrationDict=[defaults valueForKey:@"RegistrationDictKey"];
        
        car.address1=[registrationDict objectForKey:@"Address"];
        car.address2=@"Emp";
        
        
        car.zipCode=[registrationDict objectForKey:@"Zip"];
        car.city=[registrationDict objectForKey:@"City"];
        car.state=[registrationDict objectForKey:@"StateCode"];
        car.stateID=[registrationDict objectForKey:@"StateID"];
        car.phone=[registrationDict objectForKey:@"PhoneNumber"];
        car.sellerName=[registrationDict objectForKey:@"Name"];
        //for other fields, give default values
        car.sellerType=@"Emp"; //cross check this
        car.sellerID=@"Emp"; //cross check this
        //below values taken from VehicleInformationViewController
        car.exteriorColor=@"Unspecified";
        car.transmission=@"Unspecified";
        car.driveTrain=@"Unspecified";
        car.interiorColor=@"Unspecified";
        car.ConditionDescription=@"Unspecified";
        car.engineCylinders=@"Unspecified";
        car.numberOfDoors=@"Unspecified";
        car.fueltype=@"Unspecified";
        car.fuelTypeId=@"0";
        car.vin=@"Emp";
        //car.email
        //car.sellerEmail
        car.extraDescription=@"Emp";
        
        car.bodytype=@"Unspecified";
        car.bodytypeID=@"0";
        
        car.title=@"Emp";
        
        
        SelectedCarDetails *selectedCarDetails=[segue destinationViewController];
        selectedCarDetails.carReceived=car;
        
        //update MyCarsList.arryaofallcarrecordobjects and the tableview
        NSMutableArray *cars=[[NSMutableArray alloc] initWithCapacity:1];
        MyCarsList *myCarsList=[self.navigationController.viewControllers objectAtIndex:1];
        [cars addObjectsFromArray:myCarsList.arrayOfAllCarRecordObjects];
        [cars addObject:car];
        
        myCarsList.arrayOfAllCarRecordObjects=[NSArray arrayWithArray:cars];
        [myCarsList.tableView reloadData];
    }
}

- (void)dealloc
{
    self.Client = nil;
    self.currentElementChars = nil;
    self.packageDetailsDict = nil;
    self.addNewCarScrollView= nil;
    
    self.makeTextField = nil;
    self.modelTextField = nil;
    self.yearTextField = nil;
    self.priceTextField = nil;
    
    self.makesPicker = nil;
    self.modelsPicker = nil;
    self.yearPicker = nil;
    
    self.makeNameSelected = nil;
    self.makeIdSelected = nil;
    self.modelNameSelected = nil;
    self.modelIdSelected = nil;
    self.yearSelected = nil;
    self.yearIdSelected = nil;
    
    self.makesDictionary = nil;
    self.modelsDictionary = nil;
    self.sortedMakes = nil;
    self.sortedModels = nil;
    self.sortedYears = nil;
    
    self.managedObjectContext = nil;
}

@end
