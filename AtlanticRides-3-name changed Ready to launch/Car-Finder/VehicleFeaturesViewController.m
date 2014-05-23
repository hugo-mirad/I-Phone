//
//  VehicleDescriptionViewController.m
//  Car-Finder
//
//  Created by Mac on 14/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "VehicleFeaturesViewController.h"
#import "AFNetworking.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define CARID_KEY @"CarID"
#define SESSIONID_KEY @"SessionID"

#import "LoginViewController.h"
#import "CommonMethods.h"


@interface VehicleFeaturesViewController()

@property (strong, nonatomic) NSArray *vehileDesComfortArray,*vehileDesComfortArrayId,*vehileDesSeatsArray,*vehileDesSeatsArrayId,*vehileDesSafetyArray,*vehileDesSafetyArrayId,*vehileDesSoundSystemArray,*vehileDesSoundSystemArrayId,*vehileDesNewArray,*vehileDesNewArrayId,*vehileDesWindowsArray,*vehileDesOtherArray,*vehileDesOtherArrayId,*vehileDesWindowsArrayId,*vehileDesSpecialsArray,*vehileDesSpecialsArrayId,*allArrayCount;

@property(strong,nonatomic) NSDictionary *featuresDict;
@property(strong,nonatomic) NSMutableDictionary *finalSavedFeaturesDict;
@property(strong,nonatomic) NSMutableArray *arForIPs;

@property(strong,nonatomic) UIBarButtonItem *leftBarButton,*rightBarButton;

- (void)enableDisableFields:(BOOL)enable;
- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;

@end

@implementation VehicleFeaturesViewController


@synthesize vehileDesComfortArray = _vehileDesComfortArray,vehileDesComfortArrayId = _vehileDesComfortArrayId,vehileDesSeatsArray = _vehileDesSeatsArray,vehileDesSeatsArrayId = _vehileDesSeatsArrayId,vehileDesSafetyArray = _vehileDesSafetyArray,vehileDesSafetyArrayId = _vehileDesSafetyArrayId,vehileDesSoundSystemArray = _vehileDesSoundSystemArray,vehileDesSoundSystemArrayId = _vehileDesSoundSystemArrayId,vehileDesNewArray = _vehileDesNewArray,vehileDesNewArrayId = _vehileDesNewArrayId,vehileDesWindowsArray = _vehileDesWindowsArray,vehileDesWindowsArrayId = _vehileDesWindowsArrayId,vehileDesOtherArray = _vehileDesOtherArray,vehileDesOtherArrayId = _vehileDesOtherArrayId,vehileDesSpecialsArray = _vehileDesSpecialsArray,vehileDesSpecialsArrayId = _vehileDesSpecialsArrayId,allArrayCount = _allArrayCount;

@synthesize featuresArray=_featuresArray, featuresDict=_featuresDict,finalSavedFeaturesDict=_finalSavedFeaturesDict,arForIPs=_arForIPs;

@synthesize rightBarButton=_rightBarButton,leftBarButton=_leftBarButton;

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

- (void)selectReceivedFeatures:(NSArray *)allfeaturesArray
{
    NSMutableString *fName=nil;
    NSMutableString *fValue=nil;
    
    NSMutableDictionary *mainDict=[[NSMutableDictionary alloc]initWithCapacity:1];
    
    
    for (int line=0; line<[allfeaturesArray count]; line++) {
        
        NSString *currObj=[allfeaturesArray objectAtIndex:line];
        
        //find feature name and feature value
        NSRange objRange=[currObj rangeOfString:@","];
        NSRange fNameRange=NSMakeRange(0, objRange.location);
        fName=[[currObj substringWithRange:fNameRange]mutableCopy];
        

        NSRange fValueRange=NSMakeRange(objRange.location+1, [currObj length]-objRange.location-1);
        fValue=[[currObj substringWithRange:fValueRange]mutableCopy];
        //NSLog(@"fName=%@ fValue=%@",fName,fValue);
        
        __block BOOL fNameFoundInMainDict=NO;
        
        [mainDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:fName]) {
                fNameFoundInMainDict=YES;
                *stop=YES;
            }
        }];
        
        if (fNameFoundInMainDict) {
            NSMutableString *thisFNameValue=[[mainDict objectForKey:fName]mutableCopy];
            
            [thisFNameValue appendString:[NSString stringWithFormat:@", %@",fValue]];
            
            [mainDict setObject:(NSString *)thisFNameValue forKey:fName];
            
        }
        else
        {
            [mainDict setObject:fValue forKey:fName];
        }
    }
    self.featuresDict= [NSDictionary dictionaryWithDictionary:mainDict];
    self.finalSavedFeaturesDict=[[NSMutableDictionary dictionaryWithDictionary:mainDict] mutableCopy];
    
    //NSLog(@"self.featuresDict=%@",self.featuresDict);

}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *navTitle=[defaults valueForKey:@"navTitle"];
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    navtitle.text=navTitle;
    
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationItem setTitleView:navtitle];
    
       //for background image;
    self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    
    
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
    
    
    ////////// Comfort Details..............
    self.vehileDesComfortArray = [NSArray arrayWithObjects:@"A/C",@"A/C: Front",@"A/C: Rear",@"Cruise Control",@"Navigation System",@"Power Locks",@"Power Steering",@"Remote Keyless Entry",@"TV/VCR",@"Remote Start",@"Tilt",@"Rearview Camera",@"Power Mirrors",nil];
    self.vehileDesComfortArrayId = [[NSMutableArray alloc]initWithObjects:@"51",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"31",@"33",@"35",@"36",nil];
    
    ////////// Seats Details..............
    self.vehileDesSeatsArray = [NSArray arrayWithObjects:@"Bucket Seats",@"Leather Interior",@"Memory Seats",@"Power Seats",@"Heated Seats",@"Vinyl Interior",@"Cloth Interior",nil];
    self.vehileDesSeatsArrayId = [[NSMutableArray alloc]initWithObjects:@"9",@"10",@"11",@"12",@"32",@"37",@"38",nil];
    
    
    
    ////////// Safety Details..............
    self.vehileDesSafetyArray = [NSArray arrayWithObjects:@"Airbag: Driver",@"Airbag: Passenger",@"Airbag: Side",@"Alarm",@"Anti-Lock Brakes",@"Fog Lights",@"Power Brakes",nil];
    self.vehileDesSafetyArrayId = [[NSMutableArray alloc]initWithObjects:@"13",@"14",@"15",@"16",@"17",@"18",@"39",nil];
    
    ////////// Sound System Details..............
    self.vehileDesSoundSystemArray = [NSArray arrayWithObjects:@"Cassette Radio",@"CD Changer",@"CD Player",@"Premium Sound",@"AM/FM",@"DVD",nil];
    self.vehileDesSoundSystemArrayId = [[NSMutableArray alloc]initWithObjects:@"19",@"20",@"21",@"22",@"34",@"40",nil];
    
    
    
    ////////// New Details..............
    self.vehileDesNewArray = [NSArray arrayWithObjects:@"Battery",@"Tires",nil];
    self.vehileDesNewArrayId = [NSMutableArray arrayWithObjects:@"44",@"45",nil];
    
    
    ////////// Windows Details..............
    self.vehileDesWindowsArray = [NSArray arrayWithObjects:@"Power Windows",@"Rear Window Defroster",@"Rear Window Wiper",@"Tinted Glass",nil];
    self.vehileDesWindowsArrayId = [[NSMutableArray alloc]initWithObjects:@"23",@"24",@"25",@"26",nil];
    
    
    ////////// Other Details..............
    self.vehileDesOtherArray = [NSArray arrayWithObjects:@"Alloy Wheels",@"Sunroof",@"Panoramic Roof",@"Moon Roof",@"Third Row Seats",@"Tow Package",@"Dashboard Wood frame",nil];
    self.vehileDesOtherArrayId = [[NSMutableArray alloc]initWithObjects:@"27",@"28",@"41",@"42",@"29",@"30",@"43",nil];
    
    ////////// Specials Details..............
    self.vehileDesSpecialsArray = [[NSMutableArray alloc]initWithObjects:@"Garage Kept",@"Non Smoking",@"Records/Receipts Kept",@"Well Maintained",@"Regular oil changes",nil];
    self.vehileDesSpecialsArrayId = [[NSMutableArray alloc]initWithObjects:@"46",@"47",@"48",@"49",@"50",nil];
    
    
    
    self.allArrayCount = [NSArray arrayWithObjects:self.vehileDesComfortArray,
                          self.vehileDesSeatsArray,
                          self.vehileDesSafetyArray,
                          self.vehileDesSoundSystemArray,
                          self.vehileDesNewArray,
                          self.vehileDesWindowsArray,
                          self.vehileDesSafetyArray,
                          self.vehileDesSpecialsArray, nil];
    NSLog(@"self.featuresArray=%@",self.featuresArray);
    
    //self.tableView.allowsMultipleSelection=YES;
    
    
    self.arForIPs=[[NSMutableArray alloc] initWithCapacity:1];
    
    [self selectReceivedFeatures:self.featuresArray];
    
    [self enableDisableFields:NO];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.allArrayCount count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 150.0, 30.0)]; //height same as in heightForHeaderInSection
    
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    //headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 30.0); //height same as in heightForHeaderInSection
    
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    [customView addSubview:headerLabel];
    
    switch(section)
    {
        case 0:
            headerLabel.text = @"Comfort";
            break;
        case 1:
            headerLabel.text = @"Seats";
            break;
        case 2:
            headerLabel.text = @"Safety";
            break;
        case 3:
            headerLabel.text = @"Sound System";
            break;
        case 4:
            headerLabel.text = @"New";
            break;
        case 5:
            headerLabel.text = @"Windows";
            break;
        case 6:
            headerLabel.text = @"Other";
            break;
        case 7:
            headerLabel.text = @"Specials";
            break;
            
        default:
            break;
    }
    
    return customView;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) 
    {
        return [self.vehileDesComfortArray count];
        
    }
    else if(section == 1)
    {
        return [self.vehileDesSeatsArray count];
    }
    else if(section == 2)
    {
        return [self.vehileDesSafetyArray count];
    }
    
    else if(section == 3)
    {
        return [self.vehileDesSoundSystemArray count];
    }
    
    else if(section == 4)
    {
        return [self.vehileDesNewArray count];
    }
    
    else if(section == 5)
    {
        return [self.vehileDesWindowsArray count];
    }
    
    else if(section == 6)
    {
        return [self.vehileDesOtherArray count];
    }
    
    else if(section == 7)
    {
        return [self.vehileDesSpecialsArray count];
    }
    
    return 0;    
    
}

- (void)putTickMarksForFeatureValues:(id)obj onCell:(UITableViewCell *)cell forSection:(NSUInteger)section forRow:(NSUInteger)row forIndexPath:(NSIndexPath *)indexPath
{
    NSString *allFValues=(NSString *)obj;
    
    NSArray *allValuesForThisFeature=[allFValues componentsSeparatedByString:@","];
    //NSLog(@"allValuesForThisFeature=%@",allValuesForThisFeature);
    
    NSString *valueAtThisCell;
    switch (section) {
        case 0:
            valueAtThisCell=[self.vehileDesComfortArray objectAtIndex:row];
            break;
            
        case 1:
            valueAtThisCell=[self.vehileDesSeatsArray objectAtIndex:row];
            break;
            
        case 2:
            valueAtThisCell=[self.vehileDesSafetyArray objectAtIndex:row];
            break;
            
        case 3:
            valueAtThisCell=[self.vehileDesSoundSystemArray objectAtIndex:row];
            break;
            
        case 4:
            valueAtThisCell=[self.vehileDesNewArray objectAtIndex:row];
            break;
            
        case 5:
            valueAtThisCell=[self.vehileDesWindowsArray objectAtIndex:row];
            break;
            
        case 6:
            valueAtThisCell=[self.vehileDesOtherArray objectAtIndex:row];
            break;
            
        case 7:
            valueAtThisCell=[self.vehileDesSpecialsArray objectAtIndex:row];
            break;
            
            
        default:
            break;
    }
    
    
    
    //check if this value is present in allValuesForThisFeature
    
    __block BOOL found=NO;
    [allValuesForThisFeature enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fValue=(NSString *)obj;
        fValue=[fValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if ([valueAtThisCell isEqualToString:fValue]) {
            found=YES;
            *stop=YES;
        }
        
    }];
    if (found) {
        
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        
        if(![self.arForIPs containsObject:indexPath]){
            [self.arForIPs addObject:indexPath];
        } 
        
        
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    
    if (indexPath.section == 0) 
    {
        cell.textLabel.text = [self.vehileDesComfortArray objectAtIndex:indexPath.row];
        
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Comfort"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    
    else if(indexPath.section == 1)
    {
        cell.textLabel.text = [self.vehileDesSeatsArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Seats"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
    }
    else if(indexPath.section == 2)
    {
        cell.textLabel.text = [self.vehileDesSafetyArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Safety"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if(indexPath.section == 3)
    {
        cell.textLabel.text = [self.vehileDesSoundSystemArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Sound System"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if(indexPath.section == 4)
    {
        cell.textLabel.text = [self.vehileDesNewArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"New"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if(indexPath.section == 5)
    {
        cell.textLabel.text = [self.vehileDesWindowsArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Windows"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if(indexPath.section == 6)
    {
        cell.textLabel.text = [self.vehileDesOtherArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
    
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Other"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    else if(indexPath.section == 7)
    {
        cell.textLabel.text = [self.vehileDesSpecialsArray objectAtIndex:indexPath.row];
        __block BOOL foundSectionInFeaturesDict=NO;
        
        [self.finalSavedFeaturesDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:@"Specials"]) {
                foundSectionInFeaturesDict=YES;
                
                [self putTickMarksForFeatureValues:obj onCell:cell forSection:indexPath.section forRow:indexPath.row forIndexPath:indexPath];
                *stop=YES;   
            }
        }];
        
        if (!foundSectionInFeaturesDict) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
    return cell;
    
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
    
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if (thisCell.accessoryType == UITableViewCellAccessoryNone) {
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //add this entry to finalSavedFeaturesDict
        NSString *fName=[self featureNameFromSection:indexPath.section];
        NSString *fValue=[self featureValueFromSection:indexPath.section andRow:indexPath.row];
        
        
        
        
        [self addFeature:fName withValue:fValue];
        NSLog(@"after adding feature, finalSavedFeaturesDict=%@ featuresDict=%@",self.finalSavedFeaturesDict,self.featuresDict);
        
    }else{
        thisCell.accessoryType = UITableViewCellAccessoryNone;
        //remove this entry from finalSavedFeaturesDict
        NSString *fName=[self featureNameFromSection:indexPath.section];
        NSString *fValue=[self featureValueFromSection:indexPath.section andRow:indexPath.row];
        
        [self removeFeature:fName withValue:fValue];
        NSLog(@"after removing feature, finalSavedFeaturesDict=%@ featuresDict=%@",self.finalSavedFeaturesDict,self.featuresDict);
        
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSString *)featureNameFromSection:(NSUInteger)section
{
    switch (section) {
        case 0:
            return @"Comfort";
            break;
         
        case 1:
            return @"Seats";
            break;
        
        case 2:
            return @"Safety";
            break;
            
        case 3:
            return @"Sound System";
            break;
            
        case 4:
            return @"New";
            break;
            
        case 5:
            return @"Windows";
            break;
            
        case 6:
            return @"Other";
            break;
            
        case 7:
            return @"Specials";
            break;
            
        
        default:
            break;
    }
    return nil;
}

- (NSString *)featureValueFromSection:(NSUInteger)section andRow:(NSUInteger)row
{
    switch (section) {
        case 0:
            return [self.vehileDesComfortArray objectAtIndex:row];
            break;
            
        case 1:
            return [self.vehileDesSeatsArray objectAtIndex:row];
            break;
            
        case 2:
            return [self.vehileDesSafetyArray objectAtIndex:row];
            break;
            
        case 3:
            return [self.vehileDesSoundSystemArray objectAtIndex:row];
            break;
            
        case 4:
            return [self.vehileDesNewArray objectAtIndex:row];
            break;
            
        case 5:
            return [self.vehileDesWindowsArray objectAtIndex:row];
            break;
            
        case 6:
            return [self.vehileDesOtherArray objectAtIndex:row];
            break;
            
        case 7:
            return [self.vehileDesSpecialsArray objectAtIndex:row];
            break;
            
            
        default:
            break;
    }
    
    return nil;

}

- (void)addFeature:(NSString *)fName withValue:(NSString *)fValue
{
    //first find if fName is present in finalSavedFeaturesDict. If present get its value and append comma and fValue
    //else add new key value pair
    NSArray *allKeys=[self.finalSavedFeaturesDict allKeys];
    if ([allKeys containsObject:fName]) {
        NSString *value=[self.finalSavedFeaturesDict objectForKey:fName];
        NSString *newValue=[NSString stringWithFormat:@"%@,%@",value,fValue];
        [self.finalSavedFeaturesDict setObject:newValue forKey:fName];
    }
    else
    {
        [self.finalSavedFeaturesDict setObject:fValue forKey:fName];
    }
    
}

- (void)removeFeature:(NSString *)fName withValue:(NSString *)fValue
{
    //first get value for fName. Then separate fValue from comma-separated list of value
    //if fValue was the only available value for this key, remove the key itself from dict
    //else truncation fValue from value and set new value for this key
    NSString *value=[self.finalSavedFeaturesDict objectForKey:fName];
    
    NSMutableArray *fValuesArray=[[value componentsSeparatedByString:@","] mutableCopy];
    //remove spaces
    NSMutableArray *fValuesArray2=[[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *str in fValuesArray) {
        [fValuesArray2 addObject:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    fValuesArray=[[NSMutableArray arrayWithArray:fValuesArray2] mutableCopy];
    
    if ([fValuesArray count]==1)
    {
        [self.finalSavedFeaturesDict removeObjectForKey:fName];
        
       
    }
    else
    {
        [fValuesArray removeObject:fValue];
        
        NSMutableString *modifiedValue;
        modifiedValue=[[fValuesArray objectAtIndex:0] mutableCopy];
        
        if ([fValuesArray count]>1)
        for (int i=1; i<[fValuesArray count]; i++) {
            [modifiedValue appendFormat:@",%@",[fValuesArray objectAtIndex:i]];
        }
        [self.finalSavedFeaturesDict setObject:modifiedValue forKey:fName];
        
    }
    
}





#pragma mark - Bar Button Methods
- (void)callWebServiceToSaveData
{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *uid=[defaults valueForKey:UID_KEY];
    NSString *carid=[defaults valueForKey:CARID_KEY];
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    //NSLog(@"[defaults valueForKey:CARID_KEY]=%@",[defaults valueForKey:CARID_KEY]);
    
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
    
    NSDictionary * parameters = nil;
    /*
     http://www.unitedcarexchange.com/MobileService/CarService.asmx/UpdateCarFeatures?CarID="id"&UID="id"&Features="array"&AuthenticationID="iD"&CustomerID="CID"
     

     */
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    //NSLog(@"self.finalSavedFeaturesDict=%@",self.finalSavedFeaturesDict);
    
    
    NSMutableArray *arrayToSendToService=[[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *allValuesArray=[[NSMutableArray alloc] initWithCapacity:1];
    
    //convert self.finalSavedFeaturesDict into array
    NSArray *allValues=[self.finalSavedFeaturesDict allValues];
    
    for (NSString *aValue in allValues) {
        NSArray *allFeatureValuesForThisFeature=[aValue componentsSeparatedByString:@","];
        
        for (NSString *singleFValue in allFeatureValuesForThisFeature) {
            [allValuesArray addObject:[singleFValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    for (int i=0; i<53; i++) {
        int j=i+1;
        NSString *jStr=[NSString stringWithFormat:@"%d",j];
        //check what does jth feature represents. for example j=1 ie A/C: Front. If that feature is present in self.finalSavedFeaturesDict, create a string 1,1 else create a string 1,0 and add it to array
        
        if ([self.vehileDesComfortArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesComfortArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesComfortArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesSeatsArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesSeatsArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesSeatsArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesSafetyArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesSafetyArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesSafetyArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesSoundSystemArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesSoundSystemArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesSoundSystemArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesNewArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesNewArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesNewArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesWindowsArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesWindowsArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesWindowsArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesOtherArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesOtherArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesOtherArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else if ([self.vehileDesSpecialsArrayId containsObject:jStr]) {
            NSUInteger indexOfJStr=[self.vehileDesSpecialsArrayId indexOfObject:jStr];
            
            NSString *fName=[self.vehileDesSpecialsArray objectAtIndex:indexOfJStr];
            
            //NSLog(@"fName is %@",fName);
            
            // and see if this fname is present in that array allValuesArray
            if ([allValuesArray containsObject:fName]) {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,1",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@1",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            else
            {
                //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
                //[arrayToSendToService addObject:valueToPass];
                NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
                NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
                [arrayToSendToService addObject:valueToPassNum];
            }
            
        }
        else
        {
            //NSString *valueToPass=[NSString stringWithFormat:@"%@,0",jStr];
            //[arrayToSendToService addObject:valueToPass];
            NSString *valueToPass=[NSString stringWithFormat:@"%@0",jStr];
            NSNumber *valueToPassNum=[NSNumber numberWithInteger:[valueToPass integerValue]];
            [arrayToSendToService addObject:valueToPassNum];
        }
    }
    
    NSLog(@"arrayToSendToService=%@",arrayToSendToService);
    
    
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:carid,@"CarID",uid, @"UID",arrayToSendToService, @"Features",@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",@"AuthenticationID",retrieveduuid,@"CustomerID",sessionID,@"SessionID",nil];
    
    NSLog(@"parameters=%@",parameters);
    /*
     http://www.unitedcarexchange.com/MobileService/CarService.asmx/UpdateCarFeatures?CarID="id"&UID="id"&Features="array"&AuthenticationID="iD"&CustomerID="CID"
     
     UpdateCarFeatures?CarID="ID"&UID="ID"&Features="Features arry"&AuthenticationID="ID"&CustomerID="ID"&SessionID="ID"
     */
    
    __weak VehicleFeaturesViewController *weakSelf=self;
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [Client postPath:@"MobileService/CarService.asmx/UpdateCarFeatures" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        NSLog(@"response string: %@ ", operation.responseString);
        [weakSelf webServiceCallToSaveDataSucceededWithResponse:operation.responseString]; 
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //NSLog(@"error: %@", operation.responseString);
        //NSLog(@"%d",operation.response.statusCode);
        [weakSelf webServiceCallToSaveDataFailedWithError:error];
        
    }];
    
}

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSString *)str
{
    self.rightBarButton.enabled=YES;
    
    NSLog(@"str--%@",str);
    
    if ([str isEqualToString:@"Success"]) {
        self.rightBarButton.title=@"Edit";
        [self enableDisableFields:NO];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Modifications saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        //we don't need to update carrecord in this case because service is called each time this view appears. So latest value will show.
        //However, we need to update features for SellerCarDetails -> Features
        
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([str isEqualToString:@"Session timed out"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        //session timed out. so take the user to login screen
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if ([str isEqualToString:@"Failed"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Failed" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        //session timed out. so take the user to login screen
        //[self.navigationController popToRootViewControllerAnimated:YES];
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

- (void)enableDisableFields:(BOOL)enable
{
    if (enable) {
        self.tableView.allowsSelection=YES;
        
    }
    else
    {
        self.tableView.allowsSelection=NO;
    }
}

- (BOOL)userMadeChanges
{
    BOOL changesMade=NO;
    
    //see if finalSavedFeaturesDict contains same values as in featuresDict. no less no more
    
    NSLog(@"self.finalSavedFeaturesDict=%@ self.featuresDict=%@",self.finalSavedFeaturesDict,self.featuresDict);
        //separate keys, values into individual arrays
    //take an array element from finalsavedfeaturesdict and see if it is present in featuresDict.
    //if present do action 1 else changesMade=YES, break
    //Action 1:convert values of corresponding keys as arrays in both dicts
    //see if 1st obj in array obtained from finalsavedfeaturesdict is present in array obtained from featuresDict
    //if present do action 2, else changesMade=YES, break
    
    NSArray *allKeysOfFinalSavedFeaturesDict=[self.finalSavedFeaturesDict allKeys];
    NSArray *allKeysOfFeaturesDict=[self.featuresDict allKeys];
    
    for (NSString *aSavedKey in allKeysOfFinalSavedFeaturesDict) {
        if (![allKeysOfFeaturesDict containsObject:aSavedKey]) {
            changesMade=YES;
            break;
        }
        //that means key is present in both dicts
        NSString *valueStr=[self.finalSavedFeaturesDict objectForKey:aSavedKey];
        NSArray *valuesArrayFromFinalSavedFeaturesDict=[valueStr componentsSeparatedByString:@","];
        //trim the above values because space is comming from JSON
        //NSMutableArray *valuesArrayFromFinalSavedFeaturesDict2=[[NSMutableArray alloc] initWithCapacity:1];
        NSMutableSet *valuesArrayFromFinalSavedFeaturesDict2=[[NSMutableSet alloc] initWithCapacity:1];
        for (NSString *str in valuesArrayFromFinalSavedFeaturesDict) {
            [valuesArrayFromFinalSavedFeaturesDict2 addObject:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            
        }
        //NSLog(@"valuesArrayFromFinalSavedFeaturesDict2=%@",valuesArrayFromFinalSavedFeaturesDict2);
        
        
        //
        NSString *valueStr2=[self.featuresDict objectForKey:aSavedKey];
        NSArray *valuesArrayFromFeaturesDict=[valueStr2 componentsSeparatedByString:@","];
        //trim the above to because space is comming from JSON
        //NSMutableArray *valuesArrayFromFeaturesDict2=[[NSMutableArray alloc] initWithCapacity:1];
        NSMutableSet *valuesArrayFromFeaturesDict2=[[NSMutableSet alloc] initWithCapacity:1];
        for (NSString *str in valuesArrayFromFeaturesDict) {
            [valuesArrayFromFeaturesDict2 addObject:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        //NSLog(@"valuesArrayFromFeaturesDict2=%@",valuesArrayFromFeaturesDict2);
        
        //
        if (![valuesArrayFromFinalSavedFeaturesDict2 isEqual:valuesArrayFromFeaturesDict2]) {
            changesMade=YES;
            break;
        }
        
        
    }
    
    if (!changesMade) {
        //above we are checking whether finalSavedFeaturesDict key is present in FeatuesDict. Now do the reverse
        for (NSString *aJSONKey in allKeysOfFeaturesDict) {
            if (![allKeysOfFinalSavedFeaturesDict containsObject:aJSONKey]) {
                changesMade=YES;
                break;
            }
            //that means key is present in both dicts
            NSString *valueStr3=[self.featuresDict objectForKey:aJSONKey];
            NSArray *valuesArrayFromFeaturesDict=[valueStr3 componentsSeparatedByString:@","];
            //trim the above values because space is comming from JSON
            NSMutableSet *valuesSetFromFeaturesDict=[[NSMutableSet alloc] initWithCapacity:1];
            for (NSString *str in valuesArrayFromFeaturesDict) {
                [valuesSetFromFeaturesDict addObject:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            
            NSString *valueStr4=[self.finalSavedFeaturesDict objectForKey:aJSONKey];
            NSArray *valuesArrayFromFinalSavedFeaturesDict=[valueStr4 componentsSeparatedByString:@","];
            
            NSMutableSet *valuesSetFromFinalSavedFeaturesDict=[[NSMutableSet alloc] initWithCapacity:1];
            for (NSString *str in valuesArrayFromFinalSavedFeaturesDict) {
                [valuesSetFromFinalSavedFeaturesDict addObject:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            
            if (![valuesSetFromFeaturesDict isEqual:valuesSetFromFinalSavedFeaturesDict]) {
                changesMade=YES;
                break;
            }
            
        }
    }
    
    
    NSLog(@"changesMade=%d",changesMade);
    
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
        [self selectReceivedFeatures:self.featuresArray];
        [self.tableView reloadData];
        [self enableDisableFields:NO];
        
        //set rightbarbutton to 'Edit' and leftbarbutton to 'Back'
        self.leftBarButton.title=@"Back";
        self.rightBarButton.title=@"Edit";
        
    }
}

-(void)dealloc
{
    _featuresArray=nil;
    
    _vehileDesComfortArray=nil;
    _vehileDesComfortArrayId=nil;
    _vehileDesSeatsArray=nil;
    _vehileDesSeatsArrayId=nil;
    _vehileDesSafetyArray=nil;
    _vehileDesSafetyArrayId=nil;
    _vehileDesSoundSystemArray=nil;
    _vehileDesSoundSystemArrayId=nil;
    _vehileDesNewArray=nil;
    _vehileDesNewArrayId=nil;
    _vehileDesWindowsArray=nil;
    _vehileDesOtherArray=nil;
    _vehileDesOtherArrayId=nil;
    _vehileDesWindowsArrayId=nil;
    _vehileDesSpecialsArray=nil;
    _vehileDesSpecialsArrayId=nil;
    _allArrayCount=nil;
    _featuresDict=nil;
    _arForIPs=nil;
    _finalSavedFeaturesDict=nil;
    _rightBarButton=nil;
}

@end
