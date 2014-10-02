//
//  MainTable.m
//  Preferences2
//
//  Created by Mac on 04/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesTable.h"
#import "PreferencesTableMainCell.h"
#import "PreferencesTableDetailCell.h"
#import "CheckButton.h"
#import "EditPreference.h"
#import "GetPreferenceCars.h"
#import "PreferenceResultsViewController.h"
#import "AFNetworking.h"
#import "UIButton+Glossy.h"
#import "CheckZipCode.h"

#import "AppDelegate.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

#import "CommonMethods.h"
#import "AppDelegate.h"

#import "SSKeychain.h"
#define UID_KEY @"UId" 


#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define COLOR_BACKGROUND  [UIColor whiteColor];

@interface PreferencesTable()
{
    CGPoint tableviewOffset2;
    
}
@property(strong, nonatomic) NSURLConnection *connection;

@property(strong, nonatomic) NSMutableData *data,*carsCountData;
@property(strong, nonatomic) NSXMLParser *xmlParser;

@property(copy,nonatomic) NSString *currentelement,*currentElementChars;

@property(strong,nonatomic) NSArray *prefCarsArray;

@property(strong,nonatomic) UIActivityIndicatorView *activityIndicator;


@property(strong,nonatomic) NSMutableArray *preferenceNamesArray;

@property(assign,nonatomic) BOOL addAfterDelete,starting;
@property(assign,nonatomic) NSInteger mainCellNo,prefOpen,latestClickedIPRow;


@property(copy,nonatomic) NSString *prefName,*zipStr;

@property(assign,nonatomic) NSInteger HTTPErroCodeNum;



@property(strong,nonatomic) NSOperationQueue *preferenceTableQueue;
@property(strong,nonatomic) UIAlertView *updateZipAlert;
@property(strong,nonatomic) UIBarButtonItem *rightBarbutton;

@property(strong,nonatomic) UIImageView *activityImageView;
@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(assign,nonatomic) BOOL isShowingLandscapeView;

-(void)preferenceResultsMethod:(NSArray *)array forPreferenceDict:(NSDictionary *)prefDict;
- (void)cancelAllOperations;
- (void)handleErrorWithPrefDict:(NSDictionary *)prefDict;
- (NSMutableDictionary *)constructDetailCellDict;

-(void)showActivityViewer;
-(void)hideActivityViewer;

@end


@implementation PreferencesTable


AppDelegate *appDelegate;


@synthesize preferenceNamesArray=_preferenceNamesArray,prefCarsArray=_prefCarsArray,activityIndicator=_activityIndicator,addAfterDelete=_addAfterDelete,starting=_starting,mainCellNo=_mainCellNo,prefName=_prefName,HTTPErroCodeNum=_HTTPErroCodeNum;

@synthesize preferenceTableQueue=_preferenceTableQueue,prefOpen=_prefOpen,latestClickedIPRow=_latestClickedIPRow,updateZipAlert=_updateZipAlert,zipStr=_zipStr,rightBarbutton=_rightBarbutton;

@synthesize showActivityViewerImage=_showActivityViewerImage,activityWheel=_activityWheel,activityImageView=_activityImageView;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
//#warning add here activity indicater
-(void)showActivityViewer
{

}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
}

- (NSString *)addOneDollarSign:(NSString *)orgStr
{
    NSMutableString *mutableStr=[orgStr mutableCopy];
    
    NSRange wantedRange=NSMakeRange(0, 6);
    
    NSString *subStr=[mutableStr substringWithRange:wantedRange];
    
    if ([subStr isEqualToString:@"Below "]) {
        [mutableStr replaceCharactersInRange:wantedRange withString:@"Below $"];
    }
    else if ([subStr isEqualToString:@"Above "]) {
        [mutableStr replaceCharactersInRange:wantedRange withString:@"Above $"];
    }
    
    return mutableStr;
}

- (NSString *)addTwoDollarSigns:(NSString *)orgStr
{
    NSMutableString *mutableStr=[orgStr mutableCopy];
    
    NSRange wantedRange=NSMakeRange(0, 6);
    
    NSString *firstSubStr=[mutableStr substringWithRange:wantedRange];
    
    
    [mutableStr replaceCharactersInRange:wantedRange withString:[NSString stringWithFormat:@"$%@",firstSubStr]];
    //
    wantedRange=NSMakeRange(11, [mutableStr length]-12);
    NSString *secondSubStr=[mutableStr substringWithRange:wantedRange];
    
    
    [mutableStr replaceCharactersInRange:wantedRange withString:[NSString stringWithFormat:@"$%@",secondSubStr]];
    
    return mutableStr;
}

- (NSMutableDictionary *)constructDetailCellDict
{
    static NSString *CellIdentifier2 = @"PreferenceTableDetailCellIdentifier";
    
    PreferencesTableDetailCell *cell = (PreferencesTableDetailCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if (cell == nil) {
        cell = (PreferencesTableDetailCell *)[[PreferencesTableDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
       // cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor lightGrayColor];
        bgColorView.layer.cornerRadius = 7;
        bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    // now add 1 to the table data structure and to the table view
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
    [dictionary setObject:cell forKey:@"cell"];
    [dictionary setObject:@"Preference0" forKey:@"name"];
    
    return dictionary;
}



- (void)loadAvailablePreferences
{
    //
    BOOL success;
    //      NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename;
    NSString *writablePath;
    NSInteger count=0;
    
    for (int i=1;i<6;i++)
    {
        filename=[[NSString alloc]initWithFormat:@"Preference%d.plist",i];
        
        writablePath = [dbPath stringByAppendingPathComponent:filename];
        success = [fileManager fileExistsAtPath:writablePath];
        
        if(success)
        {
            count++;
            
        }
        else
        {
            break;
        }
    }
    
    
    
    if (count==0) {
        //
        NSDictionary *dictionary=[self constructDetailCellDict];
        
        [self.preferenceNamesArray addObject:dictionary];
        
    }
    else //count >0
    {
        //read all plist files and set their preference names into preferenceNamesArray
        for (int i=1; i<=count; i++) {
            filename=[[NSString alloc]initWithFormat:@"Preference%d.plist",i];
            
            writablePath = [dbPath stringByAppendingPathComponent:filename];
            success = [fileManager fileExistsAtPath:writablePath];
            
            if(success)
            {
                NSDictionary *myPrefDict=[NSDictionary dictionaryWithContentsOfFile:writablePath];
                [self.preferenceNamesArray addObject:myPrefDict];
                
            }
            
        }
        
        //
        if ([self.preferenceNamesArray count]<5) {
            
            static NSString *CellIdentifier2 = @"PreferenceTableDetailCellIdentifier";
            
            PreferencesTableDetailCell *cell = (PreferencesTableDetailCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if (cell == nil) {
                cell = (PreferencesTableDetailCell *)[[PreferencesTableDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                //cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            // now add 1 to the table data structure and to the table view
            NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
            [dictionary setObject:cell forKey:@"cell"];
            [dictionary setObject:@"Preference0" forKey:@"name"];
            [self.preferenceNamesArray addObject:dictionary];
        }
        
    }
    
}

-(NSDictionary *)getPlistForPreference:(NSString *)preferenceName
{
    //get pref from cache dir
    BOOL success;
    //      NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"%@.plist",preferenceName];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    NSMutableDictionary *carDictionaryToRead=nil;
    
    
    if (success)
    {
        carDictionaryToRead=[[NSMutableDictionary alloc] initWithContentsOfFile:writablePath];
    }
    
    //filename=nil;
    return carDictionaryToRead;
    
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


//#warning putting invisable right bar button because zip conditions AND "added zip field and zip validations"

- (void)loadRightBarButton
{
    //load zip from userdefaults if present
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preferenceZip=[defaults valueForKey:@"preferenceZip"];
    
    
    if (preferenceZip==nil) {
        [defaults setValue:@"0" forKey:@"preferenceZip"];
        [defaults synchronize];
        preferenceZip=@"0";
    }
    
    NSString *rightBarbuttonText=nil;
    NSString *rightBarbuttonAccessibilityLabel=nil;
    if(![preferenceZip isEqualToString:@"0"])
    {
        
        rightBarbuttonText=[NSString stringWithFormat:@" %@",preferenceZip];
        rightBarbuttonAccessibilityLabel=[NSString stringWithFormat:@" %@",preferenceZip];
        
        self.zipStr=preferenceZip; //for use in updatezip method, alertview delegate
        
    }
    else
    {
        rightBarbuttonText=@" N/A";
        rightBarbuttonAccessibilityLabel=@"Zip";
        
        //self.zipStr=preferenceZip; //for use in updatezip method, alertview delegate
    }
    self.rightBarbutton=[[UIBarButtonItem alloc]initWithTitle:rightBarbuttonText style:UIBarButtonItemStyleBordered target:self action:@selector(updateZip)];
    
    //accessibility
    self.rightBarbutton.isAccessibilityElement=YES;
    self.rightBarbutton.accessibilityLabel=rightBarbuttonAccessibilityLabel;
    
    self.navigationItem.rightBarButtonItem=self.rightBarbutton;
    
}

- (void)updateCarsNotSeenValues
{
    //set carsNotSeen for all available preference plist files
    //so that correct data is reflected when loading this PreferenceTable screen
    
    
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename;
    
    NSString *writablePath;
    
    NSMutableArray *tempPrefNamesArray=[[NSMutableArray alloc] initWithCapacity:1];
    
    for (NSDictionary *dict in self.preferenceNamesArray) {
        
        
        NSMutableDictionary *prefDict;
        
        if (![[dict objectForKey:@"name"] isEqualToString:@"Preference0"]) {
            prefDict=[[self getPlistForPreference:[dict objectForKey:@"name"]] mutableCopy];
        }
        else
        {
            prefDict=[dict mutableCopy];
        }
        
        
        if (![[dict objectForKey:@"name"] isEqualToString:@"Preference0"]) {
            
            
            NSArray *carIdsArray=[dict objectForKey:@"carIdsArray"];
            
            NSInteger totalCarsVal=[[dict objectForKey:@"totalCars"] integerValue];
            NSInteger carsNotSeenVal;
            if (IsEmpty(carIdsArray)) {
                //all cars are new
                carsNotSeenVal=totalCarsVal;
                
                
            }
            else //that is the array is present
            {
                carsNotSeenVal=totalCarsVal-[carIdsArray count];
            }
            
            //change zip
            [prefDict setObject:[NSNumber numberWithInteger:carsNotSeenVal] forKey:@"carsNotSeen"];
            
            filename=[[NSString alloc]initWithFormat:@"%@.plist",[prefDict objectForKey:@"name"]];
            writablePath = [dbPath stringByAppendingPathComponent:filename];
            
            [prefDict writeToFile:writablePath atomically:YES];
            
        }
        //the startPreferenceDownloadOp method will call reloadrowsatindexpaths method some where down the line which takes its values from self.prefNamesArray. Hence we have to update that first. Just updating the zipSelected field in each of the dicts is enough
        [tempPrefNamesArray addObject:prefDict];
        
    }
    
    self.preferenceNamesArray=tempPrefNamesArray;
    
    [self.tableView reloadData];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // make it disappear again

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
//    NSMutableArray *arr = [[NSUserDefaults standardUserDefaults] valueForKey:@"findCarIDResultArray"];
//
//    if (arr.count != 0) {
//        
//    
//  NSLog(@"arr--%@",arr);
//        
//    
//    PreferenceCountArray = [[NSMutableArray alloc] init];
//    PreferenceNumArray = [[NSMutableArray alloc] init];
//    PreferenceDeviceIDmStrArray = [[NSMutableArray alloc] init];
//    
//    
//    for (int i = 0; i<[arr count]; i++)
//    {
//        
//        NSMutableDictionary * location = [arr objectAtIndex:i];
//        
//        NSString *PreferenceDeviceIDmStr = [location objectForKey:@"DeviceID"];
//        NSString *PreferenceCountStr = [location objectForKey:@"PreferenceCount"];
//        NSString *PreferenceNumStr = [location objectForKey:@"PreferenceNum"];
//       
//        
//        
//        [PreferenceDeviceIDmStrArray addObject:PreferenceDeviceIDmStr];
//        [PreferenceCountArray addObject:PreferenceCountStr];
//        [PreferenceNumArray addObject:PreferenceNumStr];
//        
//        
//        
//        
//    }
//    
//    NSLog(@"PreferenceCountArray--%@,PreferenceNumArray--%@,PreferenceDeviceIDmStrArray--%@",PreferenceCountArray,PreferenceNumArray,PreferenceDeviceIDmStrArray);
//    }
    
    
    UIImage *faceImage = [UIImage imageNamed:@"Home1.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 40, 20, 30, 30);
    [face addTarget:self action:@selector(HomeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
  
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
    

    

    self.starting=YES;
  
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=@"My Preferences"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    
    self.navigationItem.titleView=navtitle;
    navtitle=nil;
    
    self.preferenceNamesArray=[[NSMutableArray alloc]init];
    
    
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.preferenceTableQueue=[[NSOperationQueue alloc]init];
    [self.preferenceTableQueue setName:@"PreferenceTableQueue"];
    [self.preferenceTableQueue setMaxConcurrentOperationCount:1];
    
    
    //for background image;
  //  self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    
//#warning putting invisable right bar button because zip conditions AND "added zip field and zip validations" after cofirmation  remove this warning
   // [self loadRightBarButton];
    //[self ByGettingRegisterDeviceIdParseString];
    
    [self loadAvailablePreferences];
    
    
  deviceID =  [[NSUserDefaults standardUserDefaults] objectForKey:@"SaveDeviceResultKey"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(carNotSeenValChangedNotifMethod:) name:@"CarNotSeenValChangedNotif" object:nil];
    
}



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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self cancelAllOperations];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CarNotSeenValChangedNotif" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
    self.isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText rowMod:(NSInteger)rowMod
{
    
    float lengthOfSecondString = secondText.length+1; // length of second string including blank space inbetween text, space in front , space after text.. Be careful, your  app may crash here if length is beyond the second text length (lengthOfSecondString = text length + blank spaces)
    
    NSString *finalText;
    if (secondText!=nil) {
        finalText = [NSString stringWithFormat:@"%@ %@",firstText,secondText];
    }
    else
    {
        finalText = firstText;
    }
    CATextLayer *myLabelTextLayer;
    /* Create the text layer on demand */
    if (!myLabelTextLayer) {
        myLabelTextLayer = [[CATextLayer alloc] init];
        myLabelTextLayer.backgroundColor = [UIColor clearColor].CGColor;
        myLabelTextLayer.wrapped = YES;
        CALayer *layer = myLabel.layer; //assign layer to your UILabel
        //myLabelTextLayer.frame = CGRectMake((layer.bounds.size.width-180)/2 + 10, (layer.bounds.size.height-30)/2 + 10, 180, 30);
        myLabelTextLayer.frame = CGRectMake(0, (layer.bounds.size.height-30)/2 + 10, 300, 30);
        myLabelTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        myLabelTextLayer.alignmentMode = kCAAlignmentLeft;
        layer.sublayers=nil; //remove previous layers, otherwise the contents are getting overlapped
        [layer addSublayer:myLabelTextLayer];
    }
    /* Create the attributes (for the attributed string) */
    // customizing first string
    CGFloat fontSize = [UIFont systemFontSize]; //16
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    CTFontRef ctBoldFont = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    CGColorRef cgColor;
    if (rowMod==1) {
        cgColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f].CGColor;
    }
    else
    {
        cgColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f].CGColor;
    }
    
   
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    
    
    // customizing second string
    UIFont *font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor = [UIColor orangeColor].CGColor;
    NSDictionary *subAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)ctFont, (id)kCTFontAttributeName,cgSubColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctFont);
    /* Create the attributed string (text + attributes) */
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:finalText attributes:attributes];
    
    
    if (secondText!=nil) {
        [attrStr addAttributes:subAttributes range:NSMakeRange(firstText.length, lengthOfSecondString)];
    }
    
    // you can add another subattribute in the similar way as above , if you want change the third textstring style
    /* Set the attributes string in the text layer :) */
    
    myLabelTextLayer.string = attrStr;
    myLabelTextLayer.opacity = 1.0; //to remove blurr effect
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if(self.preferenceNamesArray && self.preferenceNamesArray.count)
    {
        
        return [self.preferenceNamesArray count];
    }
    else
    {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *prefDict=[self.preferenceNamesArray objectAtIndex:indexPath.row];

    if ([[prefDict objectForKey:@"name"] isEqualToString:@"Preference0"])
    {
        static NSString *CellIdentifier2 = @"PreferenceTableDetailCellIdentifier";
        
        PreferencesTableDetailCell *cell = (PreferencesTableDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        
        
        if (cell == nil) {
            
            cell = (PreferencesTableDetailCell *)[[PreferencesTableDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            
          //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        [tableView setSeparatorColor:[UIColor grayColor]];
        
        // Configure the cell...
        // Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.

           // cell.useColorBackground = (indexPath.row % 2 == 0);

        //custom add pref button code
        CheckButton   *addPreferenceBtn;
        addPreferenceBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
        addPreferenceBtn.tag=21;
        addPreferenceBtn.frame=CGRectMake(cell.contentView.frame.size.width/2-80,cell.contentView.frame.size.height/2-15, 160, 30);
        [addPreferenceBtn addTarget:self action:@selector(addPrefBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
        
        [addPreferenceBtn setRowTag:indexPath.row];
        //[addPreferenceBtn setBackgroundImage:[UIImage imageNamed:@"Add-Preference.png"] forState:UIControlStateNormal];
        
        addPreferenceBtn.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];//[UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]
        [addPreferenceBtn setTitle:@"ADD PREFERENCE" forState:UIControlStateNormal];
        [addPreferenceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//[UIColor colorWithRed:105.0f/255.0f green:90.0f/255.0f blue:85.0f/255.0f alpha:1.0f]
        //Button with 0 border so it's shape like image shape
        addPreferenceBtn.layer.shadowRadius = 1.0f;
        addPreferenceBtn.layer.shadowOpacity = 0.5f;
        addPreferenceBtn.layer.shadowOffset = CGSizeZero;
        //Font size of title
        addPreferenceBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];

        [cell.contentView addSubview:addPreferenceBtn];
        
        //auto layout code
        [addPreferenceBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSLayoutConstraint *addPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:addPreferenceBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [cell.contentView addConstraint:addPreferenceBtnConstraint];
        
        addPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:addPreferenceBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [cell.contentView addConstraint:addPreferenceBtnConstraint];
        
        addPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:addPreferenceBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:160];
        [cell.contentView addConstraint:addPreferenceBtnConstraint];
        
        addPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:addPreferenceBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [cell.contentView addConstraint:addPreferenceBtnConstraint];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor lightGrayColor];
        bgColorView.layer.cornerRadius = 7;
        bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];
        
        return cell;
        
    }
    else
    {
        
        static NSString *CellIdentifier = @"PreferenceTableMainCellIdentifier";
        
        PreferencesTableMainCell *cell = (PreferencesTableMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (PreferencesTableMainCell *)[[PreferencesTableMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [tableView setSeparatorColor:[UIColor redColor]];
        
#warning after completion put != nil in condition
        
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
        
        if (appDelegate.launchDic == nil) {
           
            NSString *prefNumber = [prefDict objectForKey:@"name"];
            
            
            
            if ([prefNumber isEqualToString:@"Preference1"])
                {
                    if ([prefNumber isEqualToString:didSelectedStr]) {
                        cell.CarsCountLabel.hidden = YES;
                    }else{
                        cell.CarsCountLabel.text = [NSString stringWithFormat:@"New cars %@",[PreferenceCountArray objectAtIndex:0] ];
                    }
                    
             
            
                }
            else if ([prefNumber isEqualToString:@"Preference2"])
                {
                    if ([prefNumber isEqualToString:didSelectedStr]) {
                        cell.CarsCountLabel.hidden = YES;
                    }else{
                        cell.CarsCountLabel.text = [NSString stringWithFormat:@"New cars %@",[PreferenceCountArray objectAtIndex:1]];
                    }
                }
            else if ([prefNumber isEqualToString:@"Preference3"])
                {
                    if ([prefNumber isEqualToString:didSelectedStr]) {
                        cell.CarsCountLabel.hidden = YES;
                    }else{

                        cell.CarsCountLabel.text = [NSString stringWithFormat:@"New cars %@",[PreferenceCountArray objectAtIndex:2]];
                    }
                }
            else if ([prefNumber isEqualToString:@"Preference4"])
                {
                    if ([prefNumber isEqualToString:didSelectedStr]) {
                        cell.CarsCountLabel.hidden = YES;
                    }else{

                        cell.CarsCountLabel.text = [NSString stringWithFormat:@"New cars %@",[PreferenceCountArray objectAtIndex:3]];
                    }
                }
            else if ([prefNumber isEqualToString:@"Preference5"])
                {
                    if ([prefNumber isEqualToString:didSelectedStr]) {
                        cell.CarsCountLabel.hidden = YES;
                    }else{
                        

                        cell.CarsCountLabel.text =  [NSString stringWithFormat:@"New cars %@",[PreferenceCountArray objectAtIndex:4]];
                    }
                }
            
        }
        
        // Configure the cell...
        // Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
      
        
              //cell.useColorBackground = (indexPath.row % 2 == 0);
  
        
        // Configure the cell...
        
        cell.makeModelLabel.text=[NSString stringWithFormat:@"%@, %@",[prefDict objectForKey:@"makeNameSelected"],[prefDict objectForKey:@"modelNameSelected"]];
        cell.yearMileageLabel.text=[NSString stringWithFormat:@"%@, %@ mi",[prefDict objectForKey:@"yearValueSelected"],[prefDict objectForKey:@"mileageValueSelected"]];
        
        //adding $ to price values
        NSString *priceStr=[prefDict objectForKey:@"priceValueSelected"];
        NSRange range=NSMakeRange(0, 5);
        NSString *subStr=[priceStr substringWithRange:range];
        if ([subStr isEqualToString:@"Below"]||[subStr isEqualToString:@"Above"]) {
            cell.priceLabel.text=[self addOneDollarSign:priceStr];
        }
        else
        {
            cell.priceLabel.text=[self addTwoDollarSigns:priceStr];
        }
        
    //
        //custom edit pref button code
        CheckButton   *editPreferenceBtn;
        editPreferenceBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
        editPreferenceBtn.tag=22;
        //editPreferenceBtn.frame=CGRectMake(270,20, 32, 32);
        
        [editPreferenceBtn addTarget:self action:@selector(editPrefBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
        [editPreferenceBtn setRowTag:indexPath.row];
        [editPreferenceBtn setImage:[UIImage imageNamed:@"Edit.png"] forState:UIControlStateNormal];
        
        
        //accessibility
        editPreferenceBtn.isAccessibilityElement=YES;
        editPreferenceBtn.accessibilityLabel=@"Edit preference";
        [cell.contentView addSubview:editPreferenceBtn];
        
        //auto layout code for editPreferenceBtn
        [editPreferenceBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *editPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:editPreferenceBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10];
        [cell.contentView addConstraint:editPreferenceBtnConstraint];
        
        editPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:editPreferenceBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [cell.contentView addConstraint:editPreferenceBtnConstraint];
        
        editPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:editPreferenceBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:28];
        [cell.contentView addConstraint:editPreferenceBtnConstraint];
        
        editPreferenceBtnConstraint=[NSLayoutConstraint constraintWithItem:editPreferenceBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:28];
        [cell.contentView addConstraint:editPreferenceBtnConstraint];

        
        if (![[prefDict objectForKey:@"resultReceived"] boolValue]) {
            self.activityIndicator =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.activityIndicator setFrame:CGRectMake(124, 42, 40, 40)];
            
            self.activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                       UIViewAutoresizingFlexibleRightMargin |
                                                       UIViewAutoresizingFlexibleTopMargin |
                                                       UIViewAutoresizingFlexibleBottomMargin);
            [self.activityIndicator setHidesWhenStopped:YES];
            [self.activityIndicator startAnimating];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            cell.totalCarsFoundLabel.layer.sublayers=nil; //nil previous data that might be present on layer
            cell.totalCarsFoundLabel.text=@"loading ...";
            
            //if you want to hide view cars button when 0 cars are found or error, use the below line.
            //if you want to show a button which looks like disable(blackish gray), then use above line
           // [cell.viewCarsBtn setHidden:NO];  //yes previously
           
        }
        else
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.activityIndicator stopAnimating];
            
            if([[prefDict objectForKey:@"totalCars"] integerValue]==-1)
            {
                NSLog(@"Server error %d occured. %@:%@",self.HTTPErroCodeNum,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
                
                if (self.HTTPErroCodeNum==kCFURLErrorNotConnectedToInternet)
                {
                    cell.totalCarsFoundLabel.layer.sublayers=nil; //nil previous data that might be present on layer
                    cell.totalCarsFoundLabel.text=[NSString stringWithFormat:@"No internet connection."];
                }
                else if (self.HTTPErroCodeNum==-1001) {
                    cell.totalCarsFoundLabel.layer.sublayers=nil; //nil previous data that might be present on layer
                    cell.totalCarsFoundLabel.text=[NSString stringWithFormat:@"Request timed out."];
                }
                else
                {
                    cell.totalCarsFoundLabel.layer.sublayers=nil; //nil previous data that might be present on layer
                    cell.totalCarsFoundLabel.text=[NSString stringWithFormat:@"Server error occured."];
                }
                
                //self.HTTPErroCodeNum=0;
                //cell.unseenNoOfCarsLabel.text=@"";
                
                //if you want to hide view cars button when 0 cars are found or error, use the below line.
                //if you want to show a button which looks like disable(blackish gray), then use above line
                //[cell.viewCarsBtn setHidden:NO]; //yes previously
                
                UIView *bgColorView = [[UIView alloc] init];
                bgColorView.backgroundColor = [UIColor lightGrayColor];
                bgColorView.layer.cornerRadius = 7;
                bgColorView.layer.masksToBounds = YES;
                [cell setSelectedBackgroundView:bgColorView];
               
                
                
                return cell;
            }
            //nil the previous value of cell.totalCarsFoundLabel.text (if any). we also remove previous sublayers in createTwoTextLabel method
            cell.totalCarsFoundLabel.text=@"";
            
            NSString *firstVal;//,*secondVal;
            
            
            
            if([[prefDict objectForKey:@"totalCars"] integerValue]==1)
            {
                
                //cell.totalCarsFoundLabel.text=[NSString stringWithString:@"1 found,"];
                firstVal=@"1 found,";
            }
            else
            {
              
                //cell.totalCarsFoundLabel.text=[NSString stringWithFormat:@"%d found,",[[prefDict objectForKey:@"totalCars"] integerValue]];
                firstVal=[[NSString alloc] initWithFormat:@"%d found",[[prefDict objectForKey:@"totalCars"] integerValue]];
                
            }
            
           
            
            cell.totalCarsFoundLabel.textAlignment=NSTextAlignmentRight;
            [self createTwoTextLabel:cell.totalCarsFoundLabel firstText:firstVal secondText:nil rowMod:indexPath.row%2];
         
            if ([[prefDict objectForKey:@"totalCars"] integerValue]<=0)
            {
                [cell.viewCarsBtn setHidden:NO];  //yes previously
            }
            else
            {
                
                self.prefName=[prefDict objectForKey:@"name"];
                [cell.viewCarsBtn setHidden:NO];
                
            }
            [cell.viewCarsBtn setRowTag:indexPath.row];
            //[cell.viewCarsBtn addTarget:self action:@selector(viewCarsBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.viewCarsBtn addTarget:self action:@selector(deleteCell: event:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.viewCarsBtn setHidden:NO];  //yes previously
            
        }
        
       
//        if (indexPath.row%2==1) {
//            cell.makeModelLabel.textColor=[UIColor blackColor];
//            cell.yearMileageLabel.textColor=[UIColor blackColor];
//            cell.priceLabel.textColor=[UIColor blackColor];
//            cell.totalCarsFoundLabel.textColor=[UIColor blackColor];
//            //cell.backgroundColor = [UIColor clearColor];
//        }
//        else
//        {
        
        
//        
//        cell.CarsCountLabel.hidden = YES;
//        if (CarCountBool == YES) {
//             cell.CarsCountLabel.hidden = NO;
//            cell.CarsCountLabel.text = [NSString stringWithFormat:@"%@",[wholeResultForCarsCountDic objectForKey:@"PreferenceCount"]];
//        }
        
        
        
            cell.makeModelLabel.textColor=[UIColor blackColor];
            cell.yearMileageLabel.textColor=[UIColor blackColor];
            cell.priceLabel.textColor=[UIColor blackColor];
            cell.totalCarsFoundLabel.textColor=[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
      //  }
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor lightGrayColor];
        bgColorView.layer.cornerRadius = 7;
        bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];
        
        
        return cell;
        
    }
    
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //wholeResultForCarsCountDic
    
    
    
    
            
    
//    
//    if (preFreNum != nil)
//    {
//        if (indexPath.row == [[preFreNum objectAtIndex:indexPath.row] integerValue])
//        {
//            //cell.backgroundColor = [UIColor grayColor];
//            
//            CarCountBool = YES;
//            
//            //                if (indexPath.row == 0) {
//            //                    cell.backgroundColor = [UIColor greenColor];
//            //                }
//        }
//
//    }
    
        
//    NSMutableArray *ar = [[NSMutableArray alloc] initWithObjects:@"1", nil];
//    if (ar.count)
//    {
//        if (indexPath.row == 0) {
//            cell.backgroundColor = [UIColor greenColor];
//        }
//    }
    
    
//    if ([cell isKindOfClass:[PreferencesTableMainCell class]]) {
//        if (((PreferencesTableMainCell *)cell).useColorBackground) {
//            
////            if (indexPath.row == 1) {
////                cell.backgroundColor=COLOR_BACKGROUND;
////            }
//            cell.backgroundColor=COLOR_BACKGROUND;
//        }
//        
//    }
//    else if ([cell isKindOfClass:[PreferencesTableDetailCell class]]) {
//        if (((PreferencesTableDetailCell *)cell).useColorBackground) {
////            if (indexPath.row == 0) {
////                cell.backgroundColor=COLOR_BACKGROUND;
////            }
//            cell.backgroundColor=COLOR_BACKGROUND;
//        }
//    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
   
    
    
    
    NSDictionary *prefDict=[self.preferenceNamesArray objectAtIndex:indexPath.row];
    
    didSelectedStr = nil;
    if ([[prefDict objectForKey:@"totalCars"] integerValue]>0)
    {
        self.prefName=[prefDict objectForKey:@"name"];
        NSLog(@"self.prefName--%@",self.prefName);
        didSelectedStr =self.prefName;
       
        [self performSegueWithIdentifier:@"PreferenceResultsSegueFromCell" sender:nil];
        
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74.0;
}

#pragma mark - Buttons Handling


- (void)addPrefBtnTapped:(id)sender event:(id)event
{
    //find pref name to send
    //find the total number of dicts in preferenceNamesArray. Depending on that send the preference name.
    NSInteger count=[self.preferenceNamesArray count];
    
    self.prefName=[NSString stringWithFormat:@"Preference%d",count];
    
    
    [self performSegueWithIdentifier:@"AddEditPreferenceSegue" sender:nil];
    
    
    
}

- (void)editPrefBtnTapped:(id)sender event:(id)event
{
    //find pref name to send
    CheckButton *tempButton=(CheckButton *)sender;
    self.prefName=[NSString stringWithFormat:@"Preference%d",tempButton.rowTag+1];
    [self performSegueWithIdentifier:@"AddEditPreferenceSegue" sender:nil];
    
}

- (void)deleteCellWithPrefName:(NSString *)prefNameToDelete
{
    
    //delete the plist file corresponding to the pref.
    //BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",prefNameToDelete];
    
    NSString *plistToDelete = [dbPath stringByAppendingPathComponent:filename];
    
    
    if ([fileManager fileExistsAtPath:plistToDelete])
    {
        BOOL removeSuccess = [fileManager removeItemAtPath:plistToDelete error:&error];
        if (!removeSuccess) {
            NSLog(@"Error removing file: %@ in %@:%@", error,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
            
        }
        else
        {
            NSLog(@"pref plist deleted");
        }
    }
    
    
    ///////
    NSInteger totalNumberOfPrefDictsInArray=0;
    for (NSDictionary *dict3 in self.preferenceNamesArray) {
        NSString *prefValueStored=[dict3 objectForKey:@"name"];
        if ([prefValueStored isEqualToString:@"Preference1"]||[prefValueStored isEqualToString:@"Preference2"]||[prefValueStored isEqualToString:@"Preference3"]||[prefValueStored isEqualToString:@"Preference4"]||[prefValueStored isEqualToString:@"Preference5"]) {
            totalNumberOfPrefDictsInArray++;
        }
    }
    
    
    totalNumberOfPrefDictsInArray=totalNumberOfPrefDictsInArray;
    
   
    // now delete the cell object from preferenceNamesArray array
    NSRange prefNumberRange=NSMakeRange(10,1);
    NSString *prefNumberStr=[prefNameToDelete substringWithRange:prefNumberRange];
    
    NSInteger prefNumber=[prefNumberStr integerValue];
    
    [self.preferenceNamesArray removeObjectAtIndex:prefNumber-1];
    
    
   
    //reload the table view
    
    
    //now rearrange name key in preferenceNamesArray as well as in all preference plist files down the deleted preference
    
    
    
    NSMutableArray *modifiedArray=self.preferenceNamesArray;
    for (int i=prefNumber-1; i<totalNumberOfPrefDictsInArray-1; i++) {
        NSMutableDictionary *dict=[modifiedArray objectAtIndex:i];
        [dict setObject:[NSString stringWithFormat:@"Preference%d",i+1] forKey:@"name"];
        
        NSLog(@"-----%@",[NSString stringWithFormat:@"Preference%d",i+1]);
        [modifiedArray replaceObjectAtIndex:i withObject:dict];
    }
    //self.preferenceNamesArray=modifiedArray;
    
    if (totalNumberOfPrefDictsInArray==5) {
        
        NSDictionary *dictionary=[self constructDetailCellDict];
        [modifiedArray addObject:dictionary];
        
    }
    
    self.preferenceNamesArray=modifiedArray;
    
       //now rearrange the name key in plist files down the deleted preference
    for (int i=prefNumber-1; i<totalNumberOfPrefDictsInArray; i++) {
        
        NSString *filename=[NSString stringWithFormat:@"Preference%d.plist",i+1+1];
        
        
        
        NSString *plistToModify = [dbPath stringByAppendingPathComponent:filename];
        
        if ([fileManager fileExistsAtPath:plistToModify])
        {
            
            
            NSMutableDictionary *mutableDict=[NSMutableDictionary dictionaryWithContentsOfFile:plistToModify];
            
            //first delete plist file
            
            
            BOOL removeSuccess = [fileManager removeItemAtPath:plistToModify error:&error];
            if (!removeSuccess) {
                NSLog(@"Error removing file: %@ in %@:%@", error,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
                
            }
            else
            {
                NSLog(@"pref plist deleted");
            }
            
            
            //
            [mutableDict setObject:[NSString stringWithFormat:@"Preference%d",i+1] forKey:@"name"];
            NSString *newFileName=[NSString stringWithFormat:@"Preference%d.plist",i+1];
            
            NSString *newFileNameIncludingPath = [dbPath stringByAppendingPathComponent:newFileName];
            [mutableDict writeToFile:newFileNameIncludingPath atomically:YES];
            
            
        }
        else
        {
            NSLog(@"pref plist file does not exist.");
        }
        
    }
    
    
    
    [self.tableView reloadData];
}

-(void)deleteCell:(id)sender event:(id)event
{
    // delete cell
//    //find pref name to delete
    
   


    
    CheckButton *tempButton=(CheckButton *)sender;
    self.prefName=[NSString stringWithFormat:@"Preference%d",tempButton.rowTag+1];
    
    
    //delete the entry from plist. Then delete from array. Then delete the cell from tableview. Then rearrange pref numbers
    
//    [self deleteCellWithPrefName:self.prefName];
    
    // create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
    dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
    
    // execute a task on that queue asynchronously
    dispatch_async(jsonParsingQueue, ^{
        
        
        // once this is done, if you need to you can call
        // some code on a main thread (delegates, notifications, UI updates...)
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self deleteCellWithPrefName:self.prefName];
            [self.tableView reloadData];
        });
    });
}


-(void)startPreferenceDownloadOp:(NSMutableDictionary *)prefDict
{
    
//    NSString *makeIdReceived=[prefDict objectForKey:@"makeIdSelected"];
    NSString *makeNameReceived=[prefDict objectForKey:@"makeNameSelected"];
    
    if ([makeNameReceived isEqualToString:@"All Makes"] ) {
        makeNameReceived = @"ALL";
    }
    
   // NSString *modelIdReceived=[prefDict objectForKey:@"modelIdSelected"];
    NSString *modelNameReceived=[prefDict objectForKey:@"modelNameSelected"];
    
    if ([modelNameReceived isEqualToString:@"All Models"] ) {
        modelNameReceived = @"ALL";
        }

        
    NSString *mileageReceived=[prefDict objectForKey:@"mileageSelected"];
    NSString *priceReceived=[prefDict objectForKey:@"priceIdSelected"];
    NSString *yearReceived=[prefDict objectForKey:@"yearSelected"];
    NSString *zipReceived=[prefDict objectForKey:@"zipSelected"];
    
    NSLog(@"prefDict--%@",prefDict);
    NSInteger pageNoReceived=1;
    NSInteger pageSizeReceived=1;
    
    
    
    
    NSString *prefNamewithNum = [prefDict objectForKey:@"name"];
    NSLog(@"*****prefNamewithNum--%@",prefNamewithNum);
    
    if ([prefNamewithNum isEqualToString:@"Preference1"]) {
        prefNamewithNum = [NSString stringWithFormat:@"%d",1 ];
    }else if([prefNamewithNum isEqualToString:@"Preference2"]){
        prefNamewithNum = [NSString stringWithFormat:@"%d",2 ];
    }else if([prefNamewithNum isEqualToString:@"Preference3"]){
        prefNamewithNum = [NSString stringWithFormat:@"%d",3 ];
    }else if([prefNamewithNum isEqualToString:@"Preference4"]){
        prefNamewithNum = [NSString stringWithFormat:@"%d",4 ];
    }else if([prefNamewithNum isEqualToString:@"Preference5"]){
         prefNamewithNum = [NSString stringWithFormat:@"%d",5 ];
    }
     NSLog(@"---prefNamewithNum--%@",prefNamewithNum);
  
    
    //BrandID = 2 for MobiCarz
    //BrandID = 1 for UCE
    
#warning here implement get get cars

    
    NSString *callServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/NotificationService/Service.svc/SaveCarsPreferencesMobile/%@/%@/%@/%@/%@/%d/%d/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@/2",makeNameReceived,modelNameReceived,mileageReceived,yearReceived,priceReceived,pageSizeReceived,pageNoReceived,zipReceived,deviceID,prefNamewithNum];
    NSLog(@"callServiceStr--%@",callServiceStr);
   
    
    NSLog(@"makeNameReceived--%@,modelNameReceived--%@,mileageReceived--%@,yearReceived--%@,priceReceived--%@,pageSizeReceived--%d,pageNoReceived--%d,zipReceived--%@,deviceID--%@,prefNumber--%@,",makeNameReceived,modelNameReceived,mileageReceived,yearReceived,priceReceived,pageSizeReceived,pageNoReceived,zipReceived,deviceID,prefNamewithNum);
    
    //ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654 = authentication id
  
    
    
    //calling service
    NSURL *URL = [NSURL URLWithString:callServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    
    [prefDict setObject:[NSNumber numberWithBool:NO] forKey:@"resultReceived"];
    
    //create operation
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak PreferencesTable *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
             //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        if(error2==nil)
        {
            
            NSArray *prefCarsArray=[wholeResult objectForKey:@"SaveCarsPreferencesMobileResult"];
            
            if([prefCarsArray respondsToSelector:@selector(objectAtIndex:)])
            {
                [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"resultReceived"];
                [weakSelf preferenceResultsMethod:prefCarsArray forPreferenceDict:prefDict];
            }
            else
            {
                [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"resultReceived"];
                [prefDict setObject:[NSNumber numberWithInteger:-1] forKey:@"totalCars"];
                [prefDict setObject:[NSNumber numberWithInteger:[error2 code]] forKey:@"HTTPErroCodeNum"];
                
                weakSelf.HTTPErroCodeNum=[error2 code];
                
                NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error2);
                
                [self handleErrorWithPrefDict:prefDict];
            }
        }
        else
        {
            [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"resultReceived"];
            [prefDict setObject:[NSNumber numberWithInteger:-1] forKey:@"totalCars"];
            [prefDict setObject:[NSNumber numberWithInteger:[error2 code]] forKey:@"HTTPErroCodeNum"];
            
            
            NSLog(@"There was error parsing json result in: %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error2);
            [self handleErrorWithPrefDict:prefDict];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        
        [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"resultReceived"];
        [prefDict setObject:[NSNumber numberWithInteger:-1] forKey:@"totalCars"];
        [prefDict setObject:[NSNumber numberWithInteger:[error code]] forKey:@"HTTPErroCodeNum"];
        
        
        weakSelf.HTTPErroCodeNum=[error code];
        NSLog(@"Operation failed in: %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        [self handleErrorWithPrefDict:prefDict];
        
        
    }];
    
    [self.preferenceTableQueue addOperation:operation];
    //operation=nil;
    
}






#pragma mark -
#pragma mark Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"AddEditPreferenceSegue"])
    {
        // we have to send the preference name to the EditPreferences screen
        
        
        
        EditPreference *editPreference=[segue destinationViewController];
        editPreference.prefNameReceived=self.prefName;
        editPreference.delegate=self;
    }
    else if([segue.identifier isEqualToString:@"PreferenceResultsSegueFromCell"])
    {
        
        //pass prefCarsArray to preferenceresults table
        PreferenceResultsViewController *preferenceResultsViewController=[segue destinationViewController];
        //we will find results array again in pre and post fetching in preferenceResultsTable.
        // so dont send from here.
        //        preferenceResultsTable.prefCarsArrayReceived=self.prefCarsArray;
        preferenceResultsViewController.prefNameReceived=self.prefName;
        
    
    }
}


#pragma mark - Cancelling, suspending, resuming queues / operations
- (void)cancelAllOperations {
    
    
    [self.preferenceTableQueue cancelAllOperations];
    
}

-(void)preferenceResultsMethod:(NSArray *)array forPreferenceDict:(NSMutableDictionary *)prefDict
{
    [self.activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //self.resultReceived=YES;
    //code to find number of unseen cars in this preference.
    //answer = prefCarsArray count minus carIdsArray count
    
    
    
    BOOL success;
    //      NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"%@.plist",[prefDict objectForKey:@"name"]];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    NSInteger totalCars, carsNotSeen;
    
    if (success)
    {
        
        //see if there is an array that represents the carids
        //key for that in dictionary is carIdsArray
        
        
        
        NSArray *carIdsArray=[prefDict objectForKey:@"carIdsArray"];
        
        if ([array count]>0) {
            NSDictionary *carDic=[array objectAtIndex:0];
            totalCars=[[carDic objectForKey:@"_TotalRecords"]intValue];
        }
        else
            totalCars=0;
        
        if (IsEmpty(carIdsArray)) {
            //all cars are new
            carsNotSeen=totalCars;
            
            
        }
        else //that is the array is present
        {
            carsNotSeen=totalCars-[carIdsArray count];
        }
        
        
        [prefDict setObject:[NSNumber numberWithInteger:totalCars] forKey:@"totalCars"];
        [prefDict setObject:[NSNumber numberWithInteger:carsNotSeen] forKey:@"carsNotSeen"];
        [prefDict writeToFile:writablePath atomically:YES];
    }
    
    
    NSRange range=NSMakeRange(10, 1);
    NSString *pNum=[[prefDict objectForKey:@"name"] substringWithRange:range];
    NSInteger pInt=[pNum integerValue];
    
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pInt-1 inSection:0];
    NSArray *reloadRowsArray=[NSArray arrayWithObject:indexPath];
    [UIView setAnimationsEnabled:NO];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:reloadRowsArray withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)handleErrorWithPrefDict:(NSDictionary *)prefDict
{
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //code to find number of unseen cars in this preference.
    //answer = prefCarsArray count minus carIdsArray count
    
    
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"%@.plist",[prefDict objectForKey:@"name"]];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    
    
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    if (success) {
        [prefDict writeToFile:writablePath atomically:YES];
    }
    
    
    NSRange range=NSMakeRange(10, 1);
    NSString *pNum=[[prefDict objectForKey:@"name"] substringWithRange:range];
    NSInteger pInt=[pNum integerValue];
    
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:pInt-1 inSection:0];
    NSArray *reloadRowsArray=[NSArray arrayWithObject:indexPath];
    [UIView setAnimationsEnabled:NO];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:reloadRowsArray withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    [UIView setAnimationsEnabled:YES];
    
    
}

-(void)modifyMainCell:(UITableView *)tableView forPreference:(NSInteger)prefNumJustSaved
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"Preference%d.plist",prefNumJustSaved];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    NSMutableDictionary *carDictionaryToRead;
    
    
    
    if (success)
    {
        carDictionaryToRead=[[NSMutableDictionary  alloc] initWithContentsOfFile:writablePath];
        
        
        [self.preferenceNamesArray replaceObjectAtIndex:prefNumJustSaved-1 withObject:carDictionaryToRead];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:prefNumJustSaved-1 inSection:0];
        NSArray *reloadRowsArray=[NSArray arrayWithObject:indexPath];
        [UIView setAnimationsEnabled:NO];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:reloadRowsArray withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView endUpdates];
        
        [UIView setAnimationsEnabled:YES];
        
        //now call the service so that we can display its total cars and unseen cars
        [NSThread detachNewThreadSelector:@selector(startPreferenceDownloadOp:) toTarget:self withObject:carDictionaryToRead];
    }
}

-(void)modifyMainCell2:(UITableView *)tableView forPreference:(NSInteger)prefNumJustSaved
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"Preference%d.plist",prefNumJustSaved];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    NSMutableDictionary *carDictionaryToRead;
    
    
    if (success)
    {
        carDictionaryToRead=[[NSMutableDictionary  alloc] initWithContentsOfFile:writablePath];
        
        
        [self.preferenceNamesArray replaceObjectAtIndex:prefNumJustSaved-1 withObject:carDictionaryToRead];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:prefNumJustSaved-1 inSection:0];
        NSArray *reloadRowsArray=[NSArray arrayWithObject:indexPath];
        [UIView setAnimationsEnabled:NO];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:reloadRowsArray withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView endUpdates];
        
        [UIView setAnimationsEnabled:YES];
        
        
    }
}

-(void)addMainCell:(UITableView *)tableView forPreference:(NSInteger)prefNumJustSaved
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"Preference%d.plist",prefNumJustSaved];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    NSMutableDictionary *carDictionaryToRead;
    
    
    if (success)
    {
        carDictionaryToRead=[[NSMutableDictionary  alloc] initWithContentsOfFile:writablePath];
        
        
        
        NSInteger requiredIndexPos=[self.preferenceNamesArray count]-1;
        [self.preferenceNamesArray insertObject:carDictionaryToRead atIndex:requiredIndexPos]; //since we want the new preference to be added at last but one position
        
        
        NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] init];
        
        //go to last row and add before it
        NSIndexPath *ip2=[NSIndexPath indexPathForRow:requiredIndexPos inSection:0];
        [cellIndicesToAdd addObject:ip2];
        
        
        
        [UIView setAnimationsEnabled:NO];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView endUpdates];
        
        [UIView setAnimationsEnabled:YES];
        
        
        
        //now call the service so that we can display its total cars and unseen cars
        [NSThread detachNewThreadSelector:@selector(startPreferenceDownloadOp:) toTarget:self withObject:carDictionaryToRead];
        
        
        
        //lets reload last row, so that its background color remains as we require (alternate colors)
        NSMutableArray *cellIndicesToReload = [[NSMutableArray alloc] init];
        NSIndexPath *ip=[NSIndexPath indexPathForRow:[self.preferenceNamesArray count]-1 inSection:0];
        [cellIndicesToReload addObject:ip];
        
        
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:cellIndicesToReload withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
    }
}

- (void)deleteDetailCell
{
    
    NSInteger indexPosToDelete=5;
    [self.preferenceNamesArray removeObjectAtIndex:indexPosToDelete]; //since we want the new preference to be added at last but one position
    
    
    NSMutableArray *cellIndicesToDelete = [[NSMutableArray alloc] init];
    
    //go to last row and add before it
    NSIndexPath *ip2=[NSIndexPath indexPathForRow:indexPosToDelete inSection:0];
    [cellIndicesToDelete addObject:ip2];
    
    [UIView setAnimationsEnabled:NO];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:cellIndicesToDelete withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    [UIView setAnimationsEnabled:YES];
    
    
}

-(void)saveButtonTapped:(EditPreference *)editPreference forPreference:(NSDictionary *)carDictionarySaved
{
    NSRange range=NSMakeRange(10, 1);
    NSString *pNum=[[carDictionarySaved objectForKey:@"name"] substringWithRange:range];
    NSInteger pInt=[pNum integerValue];
    
    //for saving existing preference. i.e., user clicked edit preference and saved it
    //find all preference names from self.preferenceNamesArray
    //if preference name matches, read the new plist file into correct position of array and reload tableview
    NSMutableArray *allCurrentPrefNames=[[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *dict in self.preferenceNamesArray) {
        if (![[dict objectForKey:@"name"] isEqualToString:@"Preference0"]) {
            [allCurrentPrefNames addObject:[dict objectForKey:@"name"]];
        }
    }
    
    if ([allCurrentPrefNames containsObject:[carDictionarySaved objectForKey:@"name"]]) {
        //
        [self modifyMainCell:self.tableView forPreference:pInt];
        
    }
    else //for adding new preference
    {
        [self addMainCell:self.tableView forPreference:pInt];
        
        //if the total number of pref become 5, delete detail cell
        if ([self.preferenceNamesArray count]>5) {
            
            [self deleteDetailCell];
        }
    }
    
    //no preference will be selected after adding/deleting  cell. so,
    editPreference.delegate=nil;
    
}

-(void)validateZip:(NSString *)zipToValidate
{
    //cancel if any previous validation is still running
    [self.preferenceTableQueue cancelAllOperations];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    self.tableView.userInteractionEnabled=NO;
    
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.preferenceTableQueue addOperation:checkZipCode];
    checkZipCode=nil;
    
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

-(void)checkZipCodeNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    //remove activityviewer which was shown in validatezip method
    [self hideActivityViewer];
    self.tableView.userInteractionEnabled=YES;
    
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
        //invalid zip entered
        //initialize zip value
        //self.zipStr=@"0";
        
        
        UIAlertView *invalidZipAlert=[[UIAlertView alloc]initWithTitle:@"Invalid Zip" message:@"Enter a valid Zip code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [invalidZipAlert show];
        return;
        
    }
    else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.zipStr forKey:@"preferenceZip"];
        [defaults synchronize];
        
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip %@",self.zipStr]];
        NSString *rightBarbuttonAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",self.zipStr];
        self.rightBarbutton.accessibilityLabel=rightBarbuttonAccessibilityLabel;
        
        //set this zip for all available preference plist files
        //so that correct data is reflected when loading this PreferenceTable screen
        
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filename;//=[[NSString alloc]initWithFormat:@"%@.plist",[prefDict objectForKey:@"name"]];
        
        NSString *writablePath;// = [dbPath stringByAppendingPathComponent:filename];
        //success = [fileManager fileExistsAtPath:writablePath];
        
        NSMutableArray *tempPrefNamesArray=[[NSMutableArray alloc] initWithCapacity:1];
        
        for (NSDictionary *dict in self.preferenceNamesArray) {
            
            NSMutableDictionary *prefDict=[dict mutableCopy];
            
            if (![[dict objectForKey:@"name"] isEqualToString:@"Preference0"]) {
                
                
                
                //change zip
                [prefDict setObject:self.zipStr forKey:@"zipSelected"];
                //since the zip is changed, totalCars, carsNotSeen, carIdsArray must be reset to 0
                [prefDict setObject:[NSNumber numberWithInteger:0] forKey:@"totalCars"];
                [prefDict setObject:[NSNumber numberWithInteger:0] forKey:@"carsNotSeen"];
                if ([prefDict objectForKey:@"carIdsArray"]) {
                    [prefDict removeObjectForKey:@"carIdsArray"];
                }
                
                
                filename=[[NSString alloc]initWithFormat:@"%@.plist",[prefDict objectForKey:@"name"]];
                writablePath = [dbPath stringByAppendingPathComponent:filename];
                
                [prefDict writeToFile:writablePath atomically:YES];
                
            }
            //the startPreferenceDownloadOp method will call reloadrowsatindexpaths method some where down the line which takes its values from self.prefNamesArray. Hence we have to update that first. Just updating the zipSelected field in each of the dicts is enough
            [tempPrefNamesArray addObject:prefDict];
            
        }
        
        self.preferenceNamesArray=tempPrefNamesArray;
        
        [self.tableView reloadData];
        //
        //now call the service so that we can display its total cars and unseen cars
        //with updated zip. First cancell any previous running operations
        
        [self cancelAllOperations];
        
        for (NSDictionary *dict in self.preferenceNamesArray) {
            if (![[dict objectForKey:@"name"] isEqualToString:@"Preference0"]) {
                [NSThread detachNewThreadSelector:@selector(startPreferenceDownloadOp:) toTarget:self withObject:dict];
            }
        }
    }
}

#pragma mark - TextField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //this is for text field from didSendZip and checkZipCodeNotifMethod methods. If other text fields use this method, then use checking
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return (newLength > 5) ? NO : YES;
}

- (void)carNotSeenValChangedNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkZipCodeNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    NSString *prefReceived=[[notif userInfo] valueForKey:@"PreferenceChangedKey"];
    
    NSRange range=NSMakeRange(10, 1);
    NSString *pNum=[prefReceived substringWithRange:range];
    NSInteger pInt=[pNum integerValue];
    
    [self modifyMainCell2:self.tableView forPreference:pInt];
    
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CarNotSeenValChangedNotif" object:nil];
    [self cancelAllOperations];
        
    _prefCarsArray=nil;
    _activityIndicator=nil;
    _preferenceNamesArray=nil;
    _prefName=nil;
    _zipStr=nil;
    _preferenceTableQueue=nil;
    _updateZipAlert=nil;
    _rightBarbutton=nil;
    _activityImageView=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
    
    
    
}

@end
