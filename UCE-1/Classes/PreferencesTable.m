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
#import "PreferenceResultsTable.h"
#import "AFNetworking.h"
#import "UIButton+Glossy.h"
#import "CheckZipCode.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

#import "CommonMethods.h"
/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define COLOR_BACKGROUND  [UIColor whiteColor];

@interface PreferencesTable()
{
    CGPoint tableviewOffset2;
    
}

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


-(void)preferenceResultsMethod:(NSArray *)array forPreferenceDict:(NSDictionary *)prefDict;
- (void)cancelAllOperations;
- (void)handleErrorWithPrefDict:(NSDictionary *)prefDict;
- (NSMutableDictionary *)constructDetailCellDict;

@end


@implementation PreferencesTable
@synthesize preferenceNamesArray=_preferenceNamesArray,prefCarsArray=_prefCarsArray,activityIndicator=_activityIndicator,addAfterDelete=_addAfterDelete,starting=_starting,mainCellNo=_mainCellNo,prefName=_prefName,HTTPErroCodeNum=_HTTPErroCodeNum;

@synthesize preferenceTableQueue=_preferenceTableQueue,prefOpen=_prefOpen,latestClickedIPRow=_latestClickedIPRow,updateZipAlert=_updateZipAlert,zipStr=_zipStr,rightBarbutton=_rightBarbutton;



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
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
            //NSDictionary *myPrefDict=[NSDictionary dictionaryWithContentsOfFile:writablePath];
            //NSLog(@"myPrefDict is %@",myPrefDict);
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
                //NSLog(@"myPrefDict is %@",myPrefDict);
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
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            
            // now add 1 to the table data structure and to the table view
            NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]init];
            [dictionary setObject:cell forKey:@"cell"];
            [dictionary setObject:@"Preference0" forKey:@"name"];
            [self.preferenceNamesArray addObject:dictionary];
        }
        
    }
    
    //NSLog(@"self.preferenceNamesArray=%@",self.preferenceNamesArray);
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
    //    NSLog(@"writable path is %@",writablePath);
    success = [fileManager fileExistsAtPath:writablePath];
    
    NSMutableDictionary *carDictionaryToRead=nil;
    
    
    if (success) 
    {
        //        NSLog(@"file already exists at path %@",writablePath);
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
        
        rightBarbuttonText=[NSString stringWithFormat:@"Zip:%@",preferenceZip];
        rightBarbuttonAccessibilityLabel=[NSString stringWithFormat:@"Zip %@",preferenceZip];
        
        self.zipStr=preferenceZip; //for use in updatezip method, alertview delegate
        
    }
    else
    {
        rightBarbuttonText=@"Zip:?";
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
            //NSLog(@"carIdsArray is %@",carIdsArray);
            
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
            
            
            //NSLog(@"prefDict is %@",prefDict);
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];    
    self.starting=YES;
    
    //self.navigationItem.title=@"My Preferences";
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
    navtitle.text=@"My Preferences";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationItem setTitleView:navtitle];
    navtitle=nil;
    
    self.preferenceNamesArray=[[NSMutableArray alloc]init];
    
    
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.showsVerticalScrollIndicator=NO;
    
    
    self.preferenceTableQueue=[[NSOperationQueue alloc]init];
    [self.preferenceTableQueue setName:@"PreferenceTableQueue"];
    [self.preferenceTableQueue setMaxConcurrentOperationCount:1];
    
    
    //for background image;
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 122)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    self.tableView.backgroundView = av;
    av=nil;
    
    
    [self loadRightBarButton];
    
    [self loadAvailablePreferences];  
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(carNotSeenValChangedNotifMethod:) name:@"CarNotSeenValChangedNotif" object:nil];
    
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
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkZipCodeNotifMethod:) name:@"CheckZipCodeNotif" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheckZipCodeNotif" object:nil];
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


- (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText
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
    CGColorRef cgColor = [UIColor blackColor].CGColor;
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
    //NSLog(@"now at indexpath.row=%d",indexPath.row);
    
    NSDictionary *prefDict=[self.preferenceNamesArray objectAtIndex:indexPath.row];
    
    if ([[prefDict objectForKey:@"name"] isEqualToString:@"Preference0"])
    {
        //NSLog(@"insidecell=PreferencesTableDetailCell");            
        static NSString *CellIdentifier2 = @"PreferenceTableDetailCellIdentifier";
        
        PreferencesTableDetailCell *cell = (PreferencesTableDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        
        
        if (cell == nil) {
            
            cell = (PreferencesTableDetailCell *)[[PreferencesTableDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        
        
        // Configure the cell...
        // Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
        cell.useColorBackground = (indexPath.row % 2 == 0);
        
        //custom add pref button code
        CheckButton   *addPreferenceBtn;
        addPreferenceBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
        addPreferenceBtn.tag=21;
        
        
        addPreferenceBtn.frame=CGRectMake(cell.frame.size.width/2-80,cell.frame.size.height/2-15, 160, 30);
        [addPreferenceBtn addTarget:self action:@selector(addPrefBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
        
        [addPreferenceBtn setRowTag:indexPath.row];
        //[addPreferenceBtn setImage:[UIImage imageNamed:@"addButton.png"] forState:UIControlStateNormal];
        [addPreferenceBtn setTitle:@"Add Preference" forState:UIControlStateNormal];
        [addPreferenceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addPreferenceBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        addPreferenceBtn.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
        [addPreferenceBtn makeGlossy];
        [cell.contentView addSubview:addPreferenceBtn]; 
        
        
        //NSLog(@"indexPath.row=%d indexPath.rowMOD2=%d",indexPath.row,indexPath.row%2);
        return cell;
        
    } 
    else
    {
        static NSString *CellIdentifier = @"PreferenceTableMainCellIdentifier";
        
        PreferencesTableMainCell *cell = (PreferencesTableMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (PreferencesTableMainCell *)[[PreferencesTableMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // Configure the cell...
        // Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
        cell.useColorBackground = (indexPath.row % 2 == 0);
        
        // Configure the cell...
        
        cell.makeModelLabel.text=[NSString stringWithFormat:@"%@, %@",[prefDict objectForKey:@"makeNameSelected"],[prefDict objectForKey:@"modelNameSelected"]];
        cell.yearMileageLabel.text=[NSString stringWithFormat:@"%@, %@ miles",[prefDict objectForKey:@"yearValueSelected"],[prefDict objectForKey:@"mileageValueSelected"]];
        
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
        editPreferenceBtn.frame=CGRectMake(270,10, 32, 32);
        
        [editPreferenceBtn addTarget:self action:@selector(editPrefBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
        [editPreferenceBtn setRowTag:indexPath.row];
        [editPreferenceBtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        
        
        //accessibility
        editPreferenceBtn.isAccessibilityElement=YES;
        editPreferenceBtn.accessibilityLabel=@"Edit preference";
        [cell.contentView addSubview:editPreferenceBtn];
        
        
        //NSLog(@"prefDict=%@",prefDict);
        
        if (![[prefDict objectForKey:@"resultReceived"] boolValue]) {
            //NSLog(@"inside if (!resultReceived)");
            self.activityIndicator =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.activityIndicator setFrame:CGRectMake(124, 42, 40, 40)];
            
            self.activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                       UIViewAutoresizingFlexibleRightMargin |
                                                       UIViewAutoresizingFlexibleTopMargin |
                                                       UIViewAutoresizingFlexibleBottomMargin);
            [self.activityIndicator setHidesWhenStopped:YES];
            [self.activityIndicator startAnimating];
            //[cell.contentView addSubview:self.activityIndicator];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            cell.totalCarsFoundLabel.layer.sublayers=nil; //nil previous data that might be present on layer
            cell.totalCarsFoundLabel.text=@"loading ...";
            //cell.unseenNoOfCarsLabel.text=@"";
            
            //if you want to hide view cars button when 0 cars are found or error, use the below line.
            //if you want to show a button which looks like disable(blackish gray), then use above line
            [cell.viewCarsBtn setHidden:NO];  //yes previously
            
        }
        else 
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            //NSLog(@"inside else of if (!resultReceived)");
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
                [cell.viewCarsBtn setHidden:NO]; //yes previously
                
                return cell;
            }
            //nil the previous value of cell.totalCarsFoundLabel.text (if any). we also remove previous sublayers in createTwoTextLabel method
            cell.totalCarsFoundLabel.text=@"";
            
            NSString *firstVal,*secondVal;
            
            if([[prefDict objectForKey:@"totalCars"] integerValue]==1)
            {
                
                //cell.totalCarsFoundLabel.text=[NSString stringWithString:@"1 found,"];
                firstVal=@"1 found,";
            }
            else
            {
                //cell.totalCarsFoundLabel.text=[NSString stringWithFormat:@"%d found,",[[prefDict objectForKey:@"totalCars"] integerValue]];
                firstVal=[[NSString alloc] initWithFormat:@"%d found,",[[prefDict objectForKey:@"totalCars"] integerValue]];
                
            }
            //cell.unseenNoOfCarsLabel.text=[NSString stringWithFormat:@"%d unseen",[[prefDict objectForKey:@"totalCars"] integerValue]];
            secondVal=[[NSString alloc] initWithFormat:@"%d unseen",[[prefDict objectForKey:@"carsNotSeen"] integerValue]];
            
            //NSString *labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",firstVal,secondVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
            //CGFloat lWidth=[self findLabelWidth:labelStringForFindingWidth];
            
            //NSLog(@"lWidth=%.1f",lWidth);
            
            cell.totalCarsFoundLabel.textAlignment=UITextAlignmentRight;
            [self createTwoTextLabel:cell.totalCarsFoundLabel firstText:firstVal secondText:secondVal];
            //cell.totalCarsFoundLabel.backgroundColor=[UIColor colorWithRed:0.792 green:0.788 blue:0.792 alpha:1.000];
            //cell.totalCarsFoundLabel.backgroundColor=[UIColor redColor];
            
            
            
            
            if ([[prefDict objectForKey:@"totalCars"] integerValue]<=0)
            {    
                [cell.viewCarsBtn setHidden:NO];  //yes previously
            }
            else
            {
                //NSLog(@"make=%@ model=%@,totalcars=%d",[prefDict objectForKey:@"makeNameSelected"],[prefDict objectForKey:@"modelNameSelected"],[[prefDict objectForKey:@"totalCars"] integerValue]);
                
                self.prefName=[prefDict objectForKey:@"name"];
                [cell.viewCarsBtn setHidden:NO];
                
            }
            [cell.viewCarsBtn setRowTag:indexPath.row];
            //[cell.viewCarsBtn addTarget:self action:@selector(viewCarsBtnTapped: event:) forControlEvents:UIControlEventTouchUpInside];
            [cell.viewCarsBtn addTarget:self action:@selector(deleteCell: event:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.viewCarsBtn setHidden:NO];  //yes previously
            
        }
        
        return cell;
        
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[PreferencesTableMainCell class]]) {
        if (((PreferencesTableMainCell *)cell).useColorBackground) {
            cell.backgroundColor=COLOR_BACKGROUND;
        }
        
    }
    else if ([cell isKindOfClass:[PreferencesTableDetailCell class]]) {
        if (((PreferencesTableDetailCell *)cell).useColorBackground) {
            cell.backgroundColor=COLOR_BACKGROUND;
        }
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
    if ([[prefDict objectForKey:@"totalCars"] integerValue]>0)
    {
        self.prefName=[prefDict objectForKey:@"name"];
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
    //NSLog(@"The self.preferenceNamesArray defore deleting cell is %@",self.preferenceNamesArray);
    
    //delete the plist file corresponding to the pref.
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",prefNameToDelete];
    
    NSString *plistToDelete = [dbPath stringByAppendingPathComponent:filename];
    //NSLog(@"readablePath  is %@",plistToDelete);
    success = [fileManager fileExistsAtPath:plistToDelete];
    
    
    if ([fileManager fileExistsAtPath:plistToDelete]) 
    {
        
        BOOL removeSuccess = [fileManager removeItemAtPath:plistToDelete error:&error];
        //NSLog(@"file deleted from path %@",plistToDelete);
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
    
    
    
    
    
    
    ////
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
        [modifiedArray replaceObjectAtIndex:i withObject:dict];
    }
    //self.preferenceNamesArray=modifiedArray;
    
    if (totalNumberOfPrefDictsInArray==5) {
        
        NSDictionary *dictionary=[self constructDetailCellDict];
        [modifiedArray addObject:dictionary];
        
    }
    
    self.preferenceNamesArray=modifiedArray;
    
    //NSLog(@"After deleting the cell from array, the array is %@",self.preferenceNamesArray);
    //NSLog(@"totalNumberOfPrefCells=%d",totalNumberOfPrefDictsInArray);
    
    //now rearrange the name key in plist files down the deleted preference
    for (int i=prefNumber-1; i<totalNumberOfPrefDictsInArray; i++) {
        
        NSString *filename=[NSString stringWithFormat:@"Preference%d.plist",i+1+1];
        
        
        
        NSString *plistToModify = [dbPath stringByAppendingPathComponent:filename];
        //NSLog(@"plistToModify  is %@",plistToModify);
        success = [fileManager fileExistsAtPath:plistToModify];
        
        
        if ([fileManager fileExistsAtPath:plistToModify]) 
        {
            
            //NSLog(@"filename to modify is %@",filename);
            
            NSMutableDictionary *mutableDict=[NSMutableDictionary dictionaryWithContentsOfFile:plistToModify];
            //NSLog(@"mutableDict to modify is %@",mutableDict);
            
            //first delete plist file
            
            //NSLog(@"plistToModify(duplicate file)  is %@",plistToModify);
            
            BOOL removeSuccess = [fileManager removeItemAtPath:plistToModify error:&error];
            //NSLog(@"file deleted from path %@",plistToDelete);
            if (!removeSuccess) {
                NSLog(@"Error removing file: %@ in %@:%@", error,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
                
            }
            else
            {
                NSLog(@"pref plist deleted");
            }
            
            
            //
            [mutableDict setObject:[NSString stringWithFormat:@"Preference%d",i+1] forKey:@"name"];
            //NSLog(@"mutableDict to modify after modificattion %@",mutableDict);
            NSString *newFileName=[NSString stringWithFormat:@"Preference%d.plist",i+1];
            //NSLog(@"newFileName=%@",newFileName);
            
            NSString *newFileNameIncludingPath = [dbPath stringByAppendingPathComponent:newFileName];
            [mutableDict writeToFile:newFileNameIncludingPath atomically:YES];
            
            
        }
        else
        {
            NSLog(@"pref plist file does not exist.");
        }
        
    }
    
    
    //NSLog(@"The self.preferenceNamesArray after deleting plistfile is %@",self.preferenceNamesArray);
    
    [self.tableView reloadData];
}

-(void)deleteCell:(id)sender event:(id)event
{
    // delete cell
    //find pref name to delete
    CheckButton *tempButton=(CheckButton *)sender;
    self.prefName=[NSString stringWithFormat:@"Preference%d",tempButton.rowTag+1];
    
    //delete the entry from plist. Then delete from array. Then delete the cell from tableview. Then rearrange pref numbers
    
    [self deleteCellWithPrefName:self.prefName];
}


-(void)startPreferenceDownloadOp:(NSMutableDictionary *)prefDict
{
    
    NSString *makeIdReceived=[prefDict objectForKey:@"makeIdSelected"];
    NSString *modelIdReceived=[prefDict objectForKey:@"modelIdSelected"];
    NSString *mileageReceived=[prefDict objectForKey:@"mileageSelected"];
    NSString *priceReceived=[prefDict objectForKey:@"priceIdSelected"];
    NSString *yearReceived=[prefDict objectForKey:@"yearSelected"];
    NSString *zipReceived=[prefDict objectForKey:@"zipSelected"];
    
    
    NSInteger pageNoReceived=1;
    NSInteger pageSizeReceived=1;
    
    NSString *callServiceStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/GetCarsFilterMobile/%@/%@/%@/%@/%@/asc/price/%d/%d/%@",makeIdReceived,modelIdReceived,mileageReceived,yearReceived,priceReceived,pageSizeReceived,pageNoReceived,zipReceived];
    
    //NSLog(@"callServiceStr=%@",callServiceStr);
    
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
        
        //NSLog(@"download succeeded for car %d",num);
        //NSLog(@"response string is %@ response object is %@",[operation responseString],responseObject);
        
        //NSData *data=(NSData *)responseObject;
        NSData *data=[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        
        //call service executed succesfully
        //NSLog(@"call service executed %@",callServiceStr);
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
        if(error2==nil)
        {
            
            NSArray *prefCarsArray=[wholeResult objectForKey:@"GetCarsFilterMobileResult"];
            
            if([prefCarsArray respondsToSelector:@selector(objectAtIndex:)])
            {
                //NSLog(@"prefCarsArray count when sending notif =%d",[prefCarsArray count]);
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
        //NSLog(@"call service failed %@ error:%@ status code:%d userinfo dict=%@",callServiceStr,[error localizedDescription],[error code],[error userInfo]);
        
        [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"resultReceived"];
        [prefDict setObject:[NSNumber numberWithInteger:-1] forKey:@"totalCars"];
        [prefDict setObject:[NSNumber numberWithInteger:[error code]] forKey:@"HTTPErroCodeNum"];
        
        
        weakSelf.HTTPErroCodeNum=[error code];
        //[weakSelf.tableView reloadData];
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
        //NSLog(@"self.prefName in prepareforsegue is %@",self.prefName);
        editPreference.delegate=self;
    }
    else if([segue.identifier isEqualToString:@"PreferenceResultsSegueFromCell"])
    {
        
        //pass prefCarsArray to preferenceresults table
        PreferenceResultsTable *preferenceResultsTable=[segue destinationViewController];
        //we will find results array again in pre and post fetching in preferenceResultsTable.
        // so dont send from here.
        //        preferenceResultsTable.prefCarsArrayReceived=self.prefCarsArray;
        preferenceResultsTable.prefNameReceived=self.prefName; 
    }
}


#pragma mark - Cancelling, suspending, resuming queues / operations
- (void)cancelAllOperations {
    
    
    //NSLog(@"all current operations are %@",[self.thumbnailQueue operations]);
    [self.preferenceTableQueue cancelAllOperations];
    
    //NSLog(@"after cancelling pending ops are %d",[[self.downloadsInProgress allKeys]count]);
}

-(void)preferenceResultsMethod:(NSArray *)array forPreferenceDict:(NSMutableDictionary *)prefDict
{
    //NSLog(@"prefDict in preferenceResultsMethod =%@",prefDict);
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
        //NSLog(@"file already exists at path");
        //NSMutableDictionary *carDictionaryToRead=[[NSMutableDictionary alloc]initWithContentsOfFile:writablePath];
        //NSLog(@"The dictionary read is %@",carDictionaryToRead);
        
        //see if there is an array that represents the carids
        //key for that in dictionary is carIdsArray
        
        
        
        NSArray *carIdsArray=[prefDict objectForKey:@"carIdsArray"];
        //NSLog(@"carIdsArray is %@",carIdsArray);
        
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
        //NSLog(@"prefDict before writing=%@",prefDict);
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
    
    //NSLog(@"prefDict in handleErrorWithPrefDict is %@",prefDict);
    
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
        //        NSLog(@"adddetailcell: file already exists at path %@",writablePath);
        carDictionaryToRead=[[NSMutableDictionary  alloc] initWithContentsOfFile:writablePath];
        //NSLog(@"carDictionaryToRead=%@",carDictionaryToRead);
        
        
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
        //        NSLog(@"adddetailcell: file already exists at path %@",writablePath);
        carDictionaryToRead=[[NSMutableDictionary  alloc] initWithContentsOfFile:writablePath];
        //NSLog(@"carDictionaryToRead=%@",carDictionaryToRead);
        
        
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
    //NSLog(@"adding pref %d",prefNumJustSaved);
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[[NSString alloc]initWithFormat:@"Preference%d.plist",prefNumJustSaved];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    NSMutableDictionary *carDictionaryToRead;
    
    
    if (success) 
    {
        //        NSLog(@"adddetailcell: file already exists at path %@",writablePath);
        carDictionaryToRead=[[NSMutableDictionary  alloc] initWithContentsOfFile:writablePath];
        //NSLog(@"carDictionaryToRead=%@",carDictionaryToRead);
        
        
        
        NSInteger requiredIndexPos=[self.preferenceNamesArray count]-1;
        [self.preferenceNamesArray insertObject:carDictionaryToRead atIndex:requiredIndexPos]; //since we want the new preference to be added at last but one position
        
        
        NSMutableArray *cellIndicesToAdd = [[NSMutableArray alloc] init];
        
        //go to last row and add before it
        NSIndexPath *ip2=[NSIndexPath indexPathForRow:requiredIndexPos inSection:0];
        [cellIndicesToAdd addObject:ip2];
        
        
        //NSLog(@"self.preferenceNamesArray=%@ self.preferenceNamesArray count=%d rows count=%d",self.preferenceNamesArray,[self.preferenceNamesArray count],[self.tableView numberOfRowsInSection:0]); 
        
        [UIView setAnimationsEnabled:NO];
        
        //        NSLog(@"cellIndicesToAdd is %@",cellIndicesToAdd);
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
    
    //NSLog(@"self.preferenceNamesArray count=%d rows count=%d",[self.preferenceNamesArray count],[self.tableView numberOfRowsInSection:0]);        
    [UIView setAnimationsEnabled:NO];
    
    //        NSLog(@"cellIndicesToAdd is %@",cellIndicesToAdd);
    [self.tableView beginUpdates];
    //[self.tableView insertRowsAtIndexPaths:self.cellIndicesToAdd withRowAnimation:UITableViewRowAnimationNone];
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
    //check if this zip is valid
    CheckZipCode *checkZipCode=[[CheckZipCode alloc]init];
    checkZipCode.zipValReceived=zipToValidate;
    [self.preferenceTableQueue addOperation:checkZipCode];
    checkZipCode=nil;
    
}

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
    //[self hideActivityViewer];
    
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
            alert.message=@"UCE cannot retreive data as it is not connected to the Internet.";
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
            alert.message=@"UCE cannot retreive data due to server error.";
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
        
        [self.rightBarbutton setTitle:[NSString stringWithFormat:@"Zip:%@",self.zipStr]];
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
                
                
                
                //NSLog(@"prefDict is %@",prefDict);
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
    //NSLog(@"detail car seen for pref=%@",prefReceived);
    //NSLog(@"self.preferenceNamesArray=%@",self.preferenceNamesArray);
    
    NSRange range=NSMakeRange(10, 1);
    NSString *pNum=[prefReceived substringWithRange:range];
    NSInteger pInt=[pNum integerValue];
    
    [self modifyMainCell2:self.tableView forPreference:pInt];
    //[self updateCarsNotSeenValues];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CarNotSeenValChangedNotif" object:nil];
    [self cancelAllOperations];
}

@end
