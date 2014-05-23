//
//  MyListCustomTable.m
//  XMLTable2
//
//  Created by Mac on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyListCustomTable.h"
#import "MyListCustomCellInfo.h"
#import "MyListCutomCell.h"
#import "MyListDetailView.h"
#import "DownloadCarRecordOperation.h"
#import "CarRecord.h"
#import "CheckButton.h"
#import "CommonMethods.h"
#import "AppDelegate.h"


@interface MyListCustomTable()

@property(strong,nonatomic) NSMutableArray *arrayOfAllMyListCustomCellInfoObjects;
@property(strong,nonatomic) UILabel *headerLabel;

@property(strong,nonatomic) NSArray *mArrayForPlist;
@property(strong,nonatomic) UIAlertView *confirmDeleteAlert;
@property(strong,nonatomic) UIButton *button;
@property(assign,nonatomic) NSUInteger indexOfObjToDelete;
@property(strong,nonatomic) NSIndexPath *indexPathOfObjToDelete;
- (void)setupTableViewHeader;
-(void)myListBtnTapped:(id)sender event:(id)event;

@end

@implementation MyListCustomTable
@synthesize arrayOfAllMyListCustomCellInfoObjects=_arrayOfAllMyListCustomCellInfoObjects,headerLabel=_headerLabel,mArrayForPlist=_mArrayForPlist,confirmDeleteAlert=_confirmDeleteAlert;

@synthesize button=_button,indexOfObjToDelete=_indexOfObjToDelete,indexPathOfObjToDelete=_indexPathOfObjToDelete;

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
    [self.arrayOfAllMyListCustomCellInfoObjects removeAllObjects];
    
    NSMutableArray *alllIndexPaths=[NSMutableArray array];
    
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    for (int i=0; i<nRows; i++) {
        @autoreleasepool {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [alllIndexPaths addObject:indexPath];
        }
    }
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:alllIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    
}

- (void)setupTableViewHeader 
{
    // set up label
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    label.font = [UIFont boldSystemFontOfSize:25];
    label.textColor = [UIColor blackColor];
    label.backgroundColor=[UIColor clearColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text=@"(empty)";
    
    self.headerLabel=label;
    //label.center=headerView.center;
    [headerView addSubview:label];
    
    
    self.tableView.tableHeaderView = headerView;
    //auto layout code for headerView
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSString *c1=@"|[label]|";
    NSString *c2=@"V:|[label]|";
    NSDictionary *viewsDict=NSDictionaryOfVariableBindings(label,headerView);
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:c1 options:0 metrics:nil views:viewsDict]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:c2 options:0 metrics:nil views:viewsDict]];
    
    label=nil;
    headerView=nil;
}

- (void)updateTableViewHeader
{
    [self.headerLabel removeFromSuperview];
    self.headerLabel=nil;
    
    [self.headerLabel setNeedsDisplay];
    self.tableView.tableHeaderView=nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *LeftBarButtonHome=[[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(HomeButtonTapped)];
    
    
    self.navigationItem.leftBarButtonItem=LeftBarButtonHome;
    

    
    
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    //for background image;
    self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 45)];
    navtitle.text=@"My List";
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    self.navigationItem.titleView=navtitle;
    navtitle=nil;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteCarFromMyListRemovedFromDatabaseNotifMethod:) name:@"DeleteCarFromMyListRemovedFromDatabaseNotif" object:nil];
    
    
    
    self.arrayOfAllMyListCustomCellInfoObjects=[NSMutableArray array];
    self.mArrayForPlist=nil;
    
    //plist code
    
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename=[NSString stringWithFormat:@"favoritecars.plist"];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    if (success) 
    {
        //NSLog(@"file already exists at path");
        self.mArrayForPlist=[NSMutableArray arrayWithContentsOfFile:writablePath];
        
    }
        /////
    // read the plist array of dictionaries and save in MyListCustomCellInfo objects
    MyListCustomCellInfo *mylistcustomcellinfo;
    NSString *dbPathForThumbnail = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachesDir=[dbPathForThumbnail stringByAppendingPathComponent:@"Caches"];
    
    
    for (NSDictionary *tempDictionary in self.mArrayForPlist) {
        @autoreleasepool {
            
            NSInteger carid=[[tempDictionary objectForKey:@"Carid"]integerValue];
            NSInteger yearOfMake=[[tempDictionary objectForKey:@"YearOfMake"]integerValue];
            
            NSString *make=[tempDictionary objectForKey:@"Make"];
            NSString *Model=[tempDictionary objectForKey:@"Model"];
            NSString *Price=[tempDictionary objectForKey:@"Price"];
            NSInteger mileage=[[tempDictionary objectForKey:@"Mileage"]integerValue];
            
            NSString *imagePath=[cachesDir stringByAppendingFormat:@"/MyListThumbnails/%@",[tempDictionary objectForKey:@"fileName"]];
            //        NSLog(@"image path when retreiving image path is %@",imagePath);
            
            
            mylistcustomcellinfo=[[MyListCustomCellInfo alloc]initWithimagePath:imagePath make:make model:Model price:Price carid:carid year:yearOfMake mileage:mileage];
            
            [self.arrayOfAllMyListCustomCellInfoObjects addObject:mylistcustomcellinfo];
            //mylistcustomcellinfo=nil;
        }
    }
    
    if([self.arrayOfAllMyListCustomCellInfoObjects count]==0)
    {
        [self setupTableViewHeader];
        
        UIAlertView *myListAlert=[[UIAlertView alloc]initWithTitle:@"Empty MyList" message:@"You can add cars to \"My List\" from Popular Cars, Search or Preference screens." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
        
        [myListAlert show];
        myListAlert=nil;
    }
    else
    {
        if(self.headerLabel!=nil)
        {
            [self updateTableViewHeader];
            
        }
        
        [self.tableView reloadData];  
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DeleteCarFromMyListRemovedFromDatabaseNotif" object:nil];
    
    [super viewWillDisappear:animated];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if(self.arrayOfAllMyListCustomCellInfoObjects && self.arrayOfAllMyListCustomCellInfoObjects.count)
    {
        return [self.arrayOfAllMyListCustomCellInfoObjects count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyListCustomCellIdentifier";
    
    MyListCutomCell *cell = (MyListCutomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyListCutomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    MyListCustomCellInfo *mlcci=[self.arrayOfAllMyListCustomCellInfoObjects objectAtIndex:indexPath.row];
    NSString *str=[NSString stringWithFormat:@"%d %@ %@",[mlcci year],[mlcci make],[mlcci model]];
    
    
    cell.yearMakeModelLabel.text=str;
    
    //price formatter
    NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
    
    NSString *priceAsString = [priceFormatter stringFromNumber:[NSNumber numberWithInteger:[[mlcci price]integerValue]]];
    
    
    if([[mlcci price]integerValue]==0)
    {
        priceAsString=@"";
    }
    
    cell.priceLabel.text=priceAsString;
    
    //mileage formatter
    NSNumberFormatter *mileageFormatter=[CommonMethods sharedMileageFormatter];
    
    NSString *mileageString = [mileageFormatter stringFromNumber:[NSNumber numberWithInteger:[mlcci mileage]]];
    
    
    NSString *mileageStr2=[NSString stringWithFormat:@"%@ mi",mileageString];
    if([mlcci mileage]==0)
    {
        mileageStr2=@"";
    }
    cell.mileageLabel.text=mileageStr2;
    
    //set thumbnail image
    [cell.imageView1 setImage:[UIImage imageWithContentsOfFile:[mlcci imagePath]]];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"delete" ofType:@"png"]];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 32, 32);
    self.button.frame = frame;
    [self.button setBackgroundImage:image forState:UIControlStateNormal];
    
    [self.button addTarget:self action:@selector(myListBtnTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    self.button.backgroundColor = [UIColor clearColor];
    
    
    //accessibility
    cell.contentView.isAccessibilityElement=YES;
    NSString *priceAccessibilityStr=(([[mlcci price] integerValue]>0)?[NSString stringWithFormat:@"%@",[mlcci price]]:nil);
    NSString *finalAccessibilityStr=(priceAccessibilityStr!=nil?[NSString stringWithFormat:@"%@ %@",str,priceAccessibilityStr]:str);
    NSString *mileageAccessibilityStr=([mlcci mileage]>0?[NSString stringWithFormat:@"%d miles",[mlcci mileage]]:nil);
    finalAccessibilityStr=(mileageAccessibilityStr!=nil?[NSString stringWithFormat:@"%@ %@",finalAccessibilityStr,mileageAccessibilityStr]:finalAccessibilityStr);
    cell.contentView.accessibilityLabel=finalAccessibilityStr;
    
    self.button.isAccessibilityElement=YES;
    self.button.accessibilityLabel=@"Delete from my list";
    cell.accessoryView = self.button;
    
        
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"MyListDetailViewSegue"])
    {
        NSIndexPath *myIndexPath=[self.tableView indexPathForSelectedRow];
        
        MyListCustomCellInfo *mlcci=[self.arrayOfAllMyListCustomCellInfoObjects objectAtIndex:myIndexPath.row];
        
        
        //convert this mlcci object into dictionary and send to MyListDetailView
        NSInteger carid=[mlcci carid];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        //send this car id to DownloadCarRecordOperation. Start the operation.
        DownloadCarRecordOperation *downloadCarRecordOperation=[[DownloadCarRecordOperation alloc]init];
        downloadCarRecordOperation.caridReceived=carid;
        [[NSOperationQueue mainQueue]addOperation:downloadCarRecordOperation];
        //downloadCarRecordOperation=nil;
    }
    
}

-(void)deleteCarFromMyList:(NSInteger)caridToDelete indexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath==nil)
    {
        // if indexPath is nil, that means this method is called from notification method.
        // so find the index path corresponding to the car id
        
        
        // find all indexpath.rows
        // find the car id corresponding to each indexpath.row
        // if the car id matches caridToDelete, set indexPath to new found index path
        
        NSArray *arr=[self.tableView indexPathsForRowsInRect:[self.tableView frame]];
        
        for (NSIndexPath *ip2 in arr) {
            MyListCustomCellInfo *mlcci=[self.arrayOfAllMyListCustomCellInfoObjects objectAtIndex:indexPath.row];
            if([mlcci carid]==caridToDelete)
            {
                indexPath=ip2;
                //NSLog(@"index path for the car to delete in deleteCarFromMyList is %@",indexPath);
                break;
            }
            
        }
    }
    
    if (indexPath!=nil) {
        //delete from plist
        NSMutableArray *tempCarsArray=[[NSMutableArray alloc]init];
        
        
        BOOL success;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        
        NSString *filename=[NSString stringWithFormat:@"favoritecars.plist"];
        
        NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
        success = [fileManager fileExistsAtPath:writablePath];
        
        if (success)
        {
            //        NSLog(@"file already exists at path");
            self.mArrayForPlist=[NSMutableArray arrayWithContentsOfFile:writablePath];
            
        }
        else
        {
            NSLog(@"file does not exists at path, %@ in %@:%@",writablePath,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        }
        
        
        [self.mArrayForPlist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dictionary=(NSDictionary *)obj;
            NSInteger carid=[[dictionary objectForKey:@"Carid"]integerValue];
            if (carid!=caridToDelete) {
                [tempCarsArray addObject:dictionary];
            }
            
            
        }];
        //
        if (success)
        {
            [tempCarsArray writeToFile:writablePath atomically:YES];
            
        }
        else
        {
            NSLog(@"Error: plist could not be modified in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        }
        
        // now delete the stored thumbnail image from Caches directory
        NSString *dbPathForThumbnail = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cachesDir=[dbPathForThumbnail stringByAppendingPathComponent:@"Caches"];
        
        NSString *thumbnailDir = [NSString stringWithFormat:@"%@/MyListThumbnails",cachesDir];
        NSError *error = nil;
        BOOL isDir=YES;
        if([fileManager fileExistsAtPath:thumbnailDir isDirectory:&isDir] && isDir)
        {
            //get file path
            NSString  *jpgPath1=[NSString stringWithFormat:@"%@/%d.jpg",thumbnailDir,caridToDelete];
            //NSLog(@"jpg file path is %@",jpgPath1);
            
            if ([fileManager fileExistsAtPath:jpgPath1])
            {
                //NSLog(@"file deleted from path %@",jpgPath1);
                BOOL removeSuccess = [fileManager removeItemAtPath:jpgPath1 error:&error];
                if (!removeSuccess) {
                    NSLog(@"Error removing file: %@ in %@:%@", error,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
                    
                }
                /*
                 else
                 {
                 NSLog(@"Error: There is no thumbnail image for this car. %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
                 }
                 */
            }
        }
        
        // now delete the custom cell info object from arrayOfAllMyListCustomCellInfoObjects array
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, 1)];
        
        //    NSLog(@"count of self.arrayOfAllMyListCustomCellInfoObjects before deleting from top is %d",[self.arrayOfAllMyListCustomCellInfoObjects count]);
        
        [self.arrayOfAllMyListCustomCellInfoObjects removeObjectsAtIndexes:indexSet];
        
        
        
        //    NSLog(@"no of rows before beginupdates is %d",[self.tableView numberOfRowsInSection:0]);
        //    NSLog(@"no of rows to be actually deleted = %d",[cellIndicesToBeDeleted count]);
        //    NSLog(@"heightForNewRows2 is %d",heightForNewRows2);
        
        
        
        NSMutableArray *cellIndicesToBeDeleted = [NSMutableArray array];
        [cellIndicesToBeDeleted addObject:indexPath];
        
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:cellIndicesToBeDeleted withRowAnimation:UITableViewRowAnimationBottom];
        
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        
        if([self.arrayOfAllMyListCustomCellInfoObjects count]==0)
        {
            [self setupTableViewHeader];
            
            UIAlertView *myListAlert=[[UIAlertView alloc]initWithTitle:@"Empty MyList" message:@"You can add cars to \"My List\" from Home, Search or Preference screens." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];  
            
            [myListAlert show];
            myListAlert=nil;
        }
        
        [tempCarsArray removeAllObjects];

    }
    
}


-(void)myListBtnTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *ip = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    
    self.indexOfObjToDelete=ip.row;
    self.indexPathOfObjToDelete=ip;
    
    
    self.confirmDeleteAlert=[[UIAlertView alloc]initWithTitle:@"Confirm Delete" message:@"Are you sure you want to remove this car from My List?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [self.confirmDeleteAlert show];
    
    
}

-(void)deleteCarFromMyListRemovedFromDatabaseNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(deleteCarFromMyListRemovedFromDatabaseNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    NSInteger idToDelete=[[[notif userInfo] valueForKey:@"carIdResultKey"]integerValue];
    [self deleteCarFromMyList:idToDelete indexPath:nil];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView isEqual:self.confirmDeleteAlert])
    {
        //NSLog(@"buttonIndex = %d",buttonIndex); //YES=1, NO=0
        
        if(buttonIndex==1)
        {
            //delete this car from plist
            //delete the related cache file
            
            //update the data structure for table
            //update the tableview
            
            //get car id for selected button
            
            MyListCustomCellInfo *mlcci;
            NSInteger caridToDelete;
            //if (indexPath.row >=0)
            mlcci=[self.arrayOfAllMyListCustomCellInfoObjects objectAtIndex:self.indexOfObjToDelete];
            //NSInteger carid=[mlcci carid];
            //NSLog(@"Car to delete: id=%d price=%@ model=%@",[mlcci carid],[mlcci price],[mlcci model]);
            caridToDelete=[mlcci carid];
            [self deleteCarFromMyList:caridToDelete indexPath:self.indexPathOfObjToDelete];
        }
    }
}

-(void)dealloc
{
    _arrayOfAllMyListCustomCellInfoObjects=nil;
    _headerLabel=nil;
    _mArrayForPlist=nil;
    _confirmDeleteAlert=nil;
    _button=nil;
    _indexPathOfObjToDelete=nil;
}

@end
