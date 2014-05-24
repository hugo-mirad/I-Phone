//
//  MyCarsList.m
//  Car-Finder
//
//  Created by Mac on 04/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MyCarsList.h"

#import "CarRecord.h"
#import "MyCarsListCustomCell.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

#import "AFNetworking.h"
#import "LoggedUserMainTable.h"
#import "DetailViewForSeller.h"

#define CARID_KEY @"CarID"
#import "CommonMethods.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

@interface MyCarsList()

@property(strong,nonatomic) NSMutableArray *myCarsTitles;
@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;
@property(strong,nonatomic) NSOperationQueue *myCarsListThumbnailQueue, *opQueue;


-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num;
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;
- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

- (void)callLogoutFailedMethod:(NSError *)error;
- (void)handleOperationError:(NSError *)error;
- (void)handleJSONError:(NSError *)error;

@end

@implementation MyCarsList

@synthesize arrayOfAllCarRecordObjects=_arrayOfAllCarRecordObjects;

@synthesize myCarsTitles=_myCarsTitles,downloadsInProgress=_downloadsInProgress,myCarsListThumbnailQueue=_myCarsListThumbnailQueue,opQueue=_opQueue;


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
    if ([firstText isEqualToString:@"Price:"]) {
         cgColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f].CGColor;
    }else{
    cgColor = [UIColor blackColor].CGColor;
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    
    
    // customizing second string
    UIFont *font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor;
    if ([firstText isEqualToString:@"Price:"]) {
        cgSubColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f].CGColor;
    }else{
        cgSubColor = [UIColor blackColor].CGColor;
    }
   // CGColorRef cgSubColor = [UIColor blackColor].CGColor;
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
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=@"My Listed Cars"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    //for background image;
    self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] init];
    logoutButton.target = self;
    logoutButton.action = @selector(logoutButtonTapped:);
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [logoutButton setTitleTextAttributes:dic forState:UIControlStateNormal];
    [logoutButton setTitle:[NSString stringWithFormat:@"Logout"]];
     logoutButton.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem=logoutButton;
    

    
    
    UIBarButtonItem *moreButton=[[UIBarButtonItem alloc] init];
    moreButton.target = self;
    moreButton.action = @selector(moreButtonTapped:);
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [moreButton setTitleTextAttributes:dic1 forState:UIControlStateNormal];
    [moreButton setTitle:[NSString stringWithFormat:@"More"]];
    moreButton.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
     self.navigationItem.leftBarButtonItem=moreButton;
    
    
   
    
    self.myCarsListThumbnailQueue=[[NSOperationQueue alloc]init];
    [self.myCarsListThumbnailQueue setName:@"myCarsListThumbnailQueue"];
    [self.myCarsListThumbnailQueue setMaxConcurrentOperationCount:3];
    
    
    self.downloadsInProgress=[[NSMutableDictionary alloc]init];
    
    
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
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(self.arrayOfAllCarRecordObjects && self.arrayOfAllCarRecordObjects.count)
    {
        return [self.arrayOfAllCarRecordObjects count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyCarsListCell";
    
    MyCarsListCustomCell *cell = (MyCarsListCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[MyCarsListCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    CarRecord *cr=[self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
    
    NSString *str=[NSString stringWithFormat:@"%d %@ %@",[cr year],[cr make],[cr model]];
    
    [cell.yearMakeModelLabel setLineBreakMode:NSLineBreakByCharWrapping];
    cell.yearMakeModelLabel.text=str;
    
    //price formatter
    NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
    
    NSString *priceAsString = [priceFormatter stringFromNumber:[NSNumber numberWithInteger:[cr price]]];
    
    if([cr price] ==0)
    {
        priceAsString=@"";
    }
    //cell.priceLabel.text=priceAsString;
    [cell.priceLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self createTwoTextLabel:cell.priceLabel firstText:@"Price:" secondText:priceAsString];
    cell.priceLabel.textColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    
    
    //mileage formatter
    NSNumberFormatter *mileageFormatter=[CommonMethods sharedMileageFormatter];
    
    NSString *mileageString = [mileageFormatter stringFromNumber:[NSNumber numberWithInteger:[cr mileage]]];
    
    
    NSString *mileageStringFormatted=[NSString stringWithFormat:@"%@ mi",mileageString];
    if([cr mileage]==0)
    {
        mileageStringFormatted=@"";
    }
    //cell.mileageLabel.text=mileageStringFormatted;
    [cell.mileageLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self createTwoTextLabel:cell.mileageLabel firstText:@"Mileage:" secondText:mileageStringFormatted];
    
    if(cr.hasImage)
    {
        [cell.spinner1 stopAnimating];
        cell.imageView1.image = cr.thumbnailUIImage;
        [cell.imageView1 setNeedsDisplay];
    }
    else if(cr.failedToDownload)
    {
        [cell.spinner1 stopAnimating];
        
        cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
        [cell.imageView1 setNeedsDisplay];
        
    }
    else
    {
        [cell.spinner1 startAnimating];
        cell.imageView1.image = [[UIImage alloc] initWithCIImage:nil];
        if (!self.tableView.dragging && !self.tableView.decelerating)
        {
            [self startDownloadForCarRecord:cr forIndexPath:indexPath forCar:1];
        }
    }
    cell.spinner1.color = [UIColor grayColor];
    cell.backgroundColor = [UIColor clearColor];
    //accessibility
    cell.contentView.isAccessibilityElement=YES;
    NSString *priceAccessibilityStr=(([cr price]>0)?[NSString stringWithFormat:@"%d",[cr price]]:nil);
    NSString *finalAccessibilityStr=(priceAccessibilityStr!=nil?[NSString stringWithFormat:@"%@ %@",str,priceAccessibilityStr]:str);
    NSString *mileageAccessibilityStr=([cr mileage]>0?[NSString stringWithFormat:@"%d miles",[cr mileage]]:nil);
    finalAccessibilityStr=(mileageAccessibilityStr!=nil?[NSString stringWithFormat:@"%@ %@",finalAccessibilityStr,mileageAccessibilityStr]:finalAccessibilityStr);
    cell.contentView.accessibilityLabel=finalAccessibilityStr;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor lightGrayColor];
    bgColorView.layer.cornerRadius = 7;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    
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

#pragma mark - Private Methods
-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num
{
    if (!record.hasImage) {
        NSURL *URL = [NSURL URLWithString:record.imagePath];
        NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
        
        
        AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
        
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }];
        
        __weak MyCarsList *weakSelf=self;
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSData *data=(NSData *)responseObject;
            
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                record.thumbnailUIImage=image;
                [weakSelf downloadDidFinishDownloading:record forImage:image forCar:num];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            record.failedToDownload=YES;
            [weakSelf download:record forCar:num didFailWithError:error];
        }];
        
        
        NSSet *pendingCarids = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]]; //gives all carids
        
        if (![pendingCarids containsObject:[NSString stringWithFormat:@"%d",record.carid]]) {
            
            [self.downloadsInProgress setObject:operation forKey:[NSString stringWithFormat:@"%d",record.carid]];
            
            [self.myCarsListThumbnailQueue addOperation:operation];
            
        }
        
    }
}

- (void)logoutButtonTapped:(id)sender
{
    UIBarButtonItem *leftBarButton=self.navigationItem.leftBarButtonItem;
    leftBarButton.enabled=NO;
    
    /*
     http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLogoutMobile/{UserID}/{SessionID}/{AuthenticationID}/{CustomerID}/
     */
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    NSString *uid=[defaults valueForKey:UID_KEY];
    
    
    NSString *logoutServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLogoutMobile/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/", uid,sessionID,retrieveduuid] ; //]@"din9030231534",@"dinesh"];
    
    //calling service
    NSURL *URL = [NSURL URLWithString:logoutServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak MyCarsList *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[weakSelf hideActivityViewer];
        leftBarButton.enabled=YES;
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        if(error2==nil)
        {
            
            NSString *logoutResult=[wholeResult objectForKey:@"PerformLogoutMobileResult"];
            
            
            //check status
            
            if ([logoutResult isEqualToString:@"Success"])
            {
                //perform segue here
                //go to login screen
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [weakSelf callLogoutFailedMethod:nil];
                
            }
            
        }
        else
        {
            //handle JSON error here
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
            [weakSelf handleJSONError:error2];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[weakSelf hideActivityViewer];
        leftBarButton.enabled=YES;
        
        //call service failed
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error);
        [weakSelf handleOperationError:error];
    }];
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"Logout Queue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    else
    {
        [self.opQueue cancelAllOperations];
    }
    
    [self.opQueue addOperation:operation];
}

- (void)callLogoutFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    //display alert
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

- (void)handleOperationError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in MyCarsList" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self callLogoutFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in MyCarsList" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self callLogoutFailedMethod:error2];
    
}

#pragma mark - MobiCarz Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    
    
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CarRecord *cr = [self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cr.carid==record.carid) {
                
                MyCarsListCustomCell *cell=(MyCarsListCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=img;
                [cell.imageView1 setNeedsDisplay];
                
                break;
            }
        }
    }
    
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
    
}


- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error
{
    
    
    NSInteger nRows = [self.tableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CarRecord *cr = [self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cr.carid==record.carid) {
                
                MyCarsListCustomCell *cell=(MyCarsListCustomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
                [cell.imageView1 setNeedsDisplay];
                
                break;
            }
        }
    }
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
}

- (void)moreButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"LoggedUserMainTableSegue" sender:nil];
    
}

#pragma mark - Prepare For Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DetailViewForSellerSegue"]) {
        DetailViewForSeller *detailViewForSeller=[segue destinationViewController];
        
        NSIndexPath *indexPath=[self.tableView indexPathForSelectedRow];
        
        CarRecord *carRecord=[self.arrayOfAllCarRecordObjects objectAtIndex:indexPath.row];
        detailViewForSeller.carRecordFromFirstView=carRecord;
        
        NSString *navTitle=nil;
        
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[carRecord year],[carRecord make],[carRecord model]];
        NSUserDefaults *defaults12=[NSUserDefaults standardUserDefaults];
        [defaults12 setValue:navTitle forKey:@"navTitle"];
        [defaults12 setValue:[NSString stringWithFormat:@"%d",[carRecord carid]] forKey:CARID_KEY];
        [defaults12 synchronize];
        
    }
    else if ([segue.identifier isEqualToString:@"LoggedUserMainTableSegue"])
    {
        LoggedUserMainTable *loggedUserMainTable=[segue destinationViewController];
        loggedUserMainTable.arrayOfAllCarRecordObjects=self.arrayOfAllCarRecordObjects;
    }
}

-(void)dealloc
{
    _arrayOfAllCarRecordObjects=nil;
    _myCarsTitles=nil;
    _downloadsInProgress=nil;
    _myCarsListThumbnailQueue=nil;
    _opQueue=nil;
    
   
    
}

@end
