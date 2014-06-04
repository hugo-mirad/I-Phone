//
//  PackageDetailsInfoViewController.m
//  Car-Finder
//
//  Created by Mac on 22/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PackageDetailsInfoViewController.h"

#import "CommonMethods.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

#import "AFNetworking.h"
#import "CarRecord.h"
#import "MyCarsListInPackageDetailsCustomCell.h"
#import "DetailViewForSeller.h"
#import "SelectedCarDetails.h"

#define CARID_KEY @"CarID"
#import "AddNewCar.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "CheckButton.h"


@interface PackageDetailsInfoViewController()

@property(strong,nonatomic) NSOperationQueue *myCarsListThumbnailQueue;


@property(strong,nonatomic) NSMutableDictionary *downloadsInProgress;

@property(strong,nonatomic) UITableView *carsListTableView;


-(void)startDownloadForCarRecord:(CarRecord *)record forIndexPath:(NSIndexPath *)indexPath forCar:(NSInteger)num;
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum;
- (void)download:(CarRecord *)record forCar:(NSInteger)carNum didFailWithError:(NSError *)error;

@end

@implementation PackageDetailsInfoViewController

@synthesize packageDetailsDict=_packageDetailsDict,carsListTableView=_carsListTableView,downloadsInProgress=_downloadsInProgress,myCarsListThumbnailQueue=_myCarsListThumbnailQueue;

@synthesize arrayOfCarRecordsForThisPackage=_arrayOfCarRecordsForThisPackage;

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
    CGColorRef cgColor = [UIColor whiteColor].CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    
    
    // customizing second string
    UIFont *font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor = [UIColor whiteColor].CGColor;
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


- (void)addACarButtonTapped
{
   [self performSegueWithIdentifier:@"AddNewCarSegue" sender:nil]; //pass package id and user id to new scene
}

#pragma mark - View lifecycle





// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title=@"Package Details";

    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        navtitle.textColor=[UIColor  whiteColor];
        
        
    } else {
        navtitle.textColor=[UIColor  colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
        
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        //load resources for iOS 7
        
    }
    navtitle.text=@"Package Details"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
   UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logoutButtonTapped:)];
    self.navigationItem.rightBarButtonItem=logoutButton;
    
    self.myCarsListThumbnailQueue=[[NSOperationQueue alloc]init];
    [self.myCarsListThumbnailQueue setName:@"myCarsListThumbnailQueue"];
    [self.myCarsListThumbnailQueue setMaxConcurrentOperationCount:3];
//    
//
    
    
    self.downloadsInProgress=[[NSMutableDictionary alloc]init];
    
    
    self.carsListTableView=[[UITableView alloc] init];//WithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    self.carsListTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.carsListTableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.carsListTableView];
    self.carsListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.carsListTableView.bounds.size.width, 0.01f)];
   // self.carsListTableView.backgroundColor=[UIColor clearColor];
    self.carsListTableView.dataSource=self;
    self.carsListTableView.delegate=self;
    [self.view addSubview:self.carsListTableView];
    
    //autolayout
    [self.carsListTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *carsListTableViewConstraint;
     if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
         
        carsListTableViewConstraint=[NSLayoutConstraint constraintWithItem:self.carsListTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
         [self.view addConstraint:carsListTableViewConstraint];
     }else{
         
         carsListTableViewConstraint=[NSLayoutConstraint constraintWithItem:self.carsListTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationController.navigationBar.bounds.size.height];
         [self.view addConstraint:carsListTableViewConstraint];
     }
    
   
    
    carsListTableViewConstraint=[NSLayoutConstraint constraintWithItem:self.carsListTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:carsListTableViewConstraint];
    
    carsListTableViewConstraint=[NSLayoutConstraint constraintWithItem:self.carsListTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:carsListTableViewConstraint];
    
    carsListTableViewConstraint=[NSLayoutConstraint constraintWithItem:self.carsListTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraint:carsListTableViewConstraint];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.carsListTableView deselectRowAtIndexPath:[self.carsListTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) {
        return 1;
    }
    else if(section==1) {
        if(self.arrayOfCarRecordsForThisPackage && self.arrayOfCarRecordsForThisPackage.count)
        {
            return [self.arrayOfCarRecordsForThisPackage count];
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyCarsListInPackageDetailsCustomCellID";
    
    MyCarsListInPackageDetailsCustomCell *cell = (MyCarsListInPackageDetailsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[MyCarsListInPackageDetailsCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section==0) {
        CGFloat y=0.0f,lWidth;
        NSString *fieldVal,*labelStringForFindingWidth;
        UILabel *label;
        
        y+=20;
        fieldVal=[self.packageDetailsDict objectForKey:@"_Description"];
        labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Package Name:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
        lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
        
        label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
        label.textAlignment=NSTextAlignmentLeft;
        [CommonMethods createTwoTextLabel:label firstText:@"Package Name:" secondText:fieldVal firstTextColor:[UIColor whiteColor] secondTextColor:[UIColor whiteColor]];
        label.backgroundColor=[UIColor clearColor];
        
        
        [cell.contentView addSubview:label];
        label=nil;
        
        //
        y+=20;
        fieldVal=[self.packageDetailsDict objectForKey:@"_PayDate"];
        labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Date of Purchase:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
        lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
        
        label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
        label.textAlignment=NSTextAlignmentLeft;
        [CommonMethods createTwoTextLabel:label firstText:@"Date of Purchase:" secondText:fieldVal firstTextColor:[UIColor whiteColor] secondTextColor:[UIColor whiteColor]];
        label.backgroundColor=[UIColor clearColor];
        
        [cell.contentView addSubview:label];
        label=nil;
        
        //
        //optional as of now
        
        //
        y+=20;
        
        fieldVal=[NSString stringWithFormat:@"%d days",[[self.packageDetailsDict objectForKey:@"_ValidityPeriod"] integerValue]];
        labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Validity:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
        lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
        
        label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
        label.textAlignment=NSTextAlignmentLeft;
        [CommonMethods createTwoTextLabel:label firstText:@"Validity:" secondText:fieldVal firstTextColor:[UIColor whiteColor] secondTextColor:[UIColor whiteColor]];
        label.backgroundColor=[UIColor clearColor];
        
        [cell.contentView addSubview:label];
        label=nil;
        
        //
        y+=20;
        fieldVal=[self.packageDetailsDict objectForKey:@"_CarsCount"];
        labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"# of Posted Cars:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
        lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
        
        label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
        label.textAlignment=NSTextAlignmentLeft;
        [CommonMethods createTwoTextLabel:label firstText:@"# of Posted Cars:" secondText:fieldVal firstTextColor:[UIColor whiteColor] secondTextColor:[UIColor whiteColor]];
        label.backgroundColor=[UIColor clearColor];
        
        [cell.contentView addSubview:label];
        label=nil;
        
        if ([[self.packageDetailsDict objectForKey:@"_CarsCount"] integerValue] < [[self.packageDetailsDict objectForKey:@"_MaxCars"] integerValue]) {
            
            //custom add a car button code
            CheckButton   *addACar;
            addACar=[CheckButton buttonWithType:UIButtonTypeCustom];
            addACar.tag=21;
            
            
            addACar.frame=CGRectMake(144,y-2, 100, 30);
            [addACar addTarget:self action:@selector(addACarButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            //___
            
            addACar.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
            [addACar setTitle:@"ADD CAR" forState:UIControlStateNormal];
            [addACar setTitleColor:[UIColor colorWithRed:105.0f/255.0f green:90.0f/255.0f blue:85.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            
           //Button with 0 border so it's shape like image shape
            addACar.layer.shadowRadius = 2.0f;
            addACar.layer.shadowOpacity = 0.5f;
            addACar.layer.shadowOffset = CGSizeZero;
            //Font size of title
            addACar.titleLabel.font = [UIFont boldSystemFontOfSize:14];

            
            
            //[addACar setBackgroundImage:[UIImage imageNamed:@"AddACar.png"] forState:UIControlStateNormal];
            [cell.contentView addSubview:addACar];
        }
    
        //
        //
        y+=20;
        fieldVal=[self.packageDetailsDict objectForKey:@"_MaxCars"];
        labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"# of Max Cars:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
        lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
        
        label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
        label.textAlignment=NSTextAlignmentLeft;
        [CommonMethods createTwoTextLabel:label firstText:@"# of Max Cars:" secondText:fieldVal firstTextColor:[UIColor whiteColor] secondTextColor:[UIColor whiteColor]];
        label.backgroundColor=[UIColor clearColor];
        
        [cell.contentView addSubview:label];
        label=nil;
        
        cell.backgroundColor = [UIColor clearColor];

        
        return cell;
        
    }
    // Configure the cell... // for section==1
    CarRecord *cr=[self.arrayOfCarRecordsForThisPackage objectAtIndex:indexPath.row];
    
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
        if (!self.carsListTableView.dragging && !self.carsListTableView.decelerating)
        {
            
            [self startDownloadForCarRecord:cr forIndexPath:indexPath forCar:1];
        }
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    //accessibility
    cell.contentView.isAccessibilityElement=YES;
    NSString *priceAccessibilityStr=(([cr price]>0)?[NSString stringWithFormat:@"%d",[cr price]]:nil);
    NSString *finalAccessibilityStr=(priceAccessibilityStr!=nil?[NSString stringWithFormat:@"%@ %@",str,priceAccessibilityStr]:str);
    NSString *mileageAccessibilityStr=([cr mileage]>0?[NSString stringWithFormat:@"%d miles",[cr mileage]]:nil);
    finalAccessibilityStr=(mileageAccessibilityStr!=nil?[NSString stringWithFormat:@"%@ %@",finalAccessibilityStr,mileageAccessibilityStr]:finalAccessibilityStr);
    cell.contentView.accessibilityLabel=finalAccessibilityStr;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122;
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
    if (indexPath.section==0) {
        //remove cell selection
        [self.carsListTableView deselectRowAtIndexPath:[self.carsListTableView indexPathForSelectedRow] animated:YES];
    }
    else if (indexPath.section==1) {
        
        CarRecord *carRecord=[self.arrayOfCarRecordsForThisPackage objectAtIndex:indexPath.row];
        
        UIStoryboard *loginStoryboard;
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            loginStoryboard=[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
        }
        else //iPad
        {
            loginStoryboard=[UIStoryboard storyboardWithName:@"LoginStoryboard-iPad" bundle:nil];
        }
        DetailViewForSeller *detailViewForSeller=[loginStoryboard instantiateViewControllerWithIdentifier:@"DetailViewForSellerID"];
        detailViewForSeller.carRecordFromFirstView=carRecord;
        
        NSString *navTitle=nil;
        
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[carRecord year],[carRecord make],[carRecord model]];
        NSUserDefaults *defaults12=[NSUserDefaults standardUserDefaults];
        [defaults12 setValue:navTitle forKey:@"navTitle"];
        [defaults12 setValue:[NSString stringWithFormat:@"%d",[carRecord carid]] forKey:CARID_KEY];
        [defaults12 synchronize];
        
        [self.navigationController pushViewController:detailViewForSeller animated:YES];
        

    }
    
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
        
        __weak PackageDetailsInfoViewController *weakSelf=self;
        
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

#pragma mark - Logout Button
- (void)logoutButtonTapped:(id)sender
{
    UIBarButtonItem *rightBarButton=self.navigationItem.rightBarButtonItem;
    rightBarButton.enabled=NO;
    
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
    
    __weak PackageDetailsInfoViewController *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        rightBarButton.enabled=YES;
        
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
                               [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                
                
            }
            else
            {
                [weakSelf packageDetailsOperationFailedMethod:nil];
                
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
        rightBarButton.enabled=YES;
        
        //call service failed
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error);
        [weakSelf handleOperationError:error];
    }];
    
    if (self.myCarsListThumbnailQueue==nil) {
        self.myCarsListThumbnailQueue=[[NSOperationQueue alloc] init];
        [self.myCarsListThumbnailQueue setName:@"myCarsListThumbnailQueue"];
        [self.myCarsListThumbnailQueue setMaxConcurrentOperationCount:3];
    }
    else
    {
        [self.myCarsListThumbnailQueue cancelAllOperations];
    }
    
    [self.myCarsListThumbnailQueue addOperation:operation];
}



#pragma mark - UCE Image Download Delegate Methods
- (void)downloadDidFinishDownloading:(CarRecord *)record forImage:(UIImage *)img forCar:(NSInteger)carNum
{
    
    
    NSInteger nRows = [self.carsListTableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CarRecord *cr = [self.arrayOfCarRecordsForThisPackage objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cr.carid==record.carid) {
                
                MyCarsListInPackageDetailsCustomCell *cell=(MyCarsListInPackageDetailsCustomCell *)[self.carsListTableView cellForRowAtIndexPath:indexPath];
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
    
    NSInteger nRows = [self.carsListTableView numberOfRowsInSection:0];
    
    NSIndexPath *indexPath;
    for (int i=0; i<nRows; i++) {
        
        indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        
        CarRecord *cr = [self.arrayOfCarRecordsForThisPackage objectAtIndex:indexPath.row];
        
        if (carNum==1) {
            if (cr.carid==record.carid) {
                
                MyCarsListInPackageDetailsCustomCell *cell=(MyCarsListInPackageDetailsCustomCell *)[self.carsListTableView cellForRowAtIndexPath:indexPath];
                [cell.spinner1 stopAnimating];
                cell.imageView1.image=[[UIImage alloc] initWithCIImage:nil];
                [cell.imageView1 setNeedsDisplay];
                
                break;
            }
        }
    }
    [self.downloadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d",record.carid]];
}

#pragma mark - Operation Failed Error Handling

- (void)packageDetailsOperationFailedMethod:(NSError *)error
{
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

- (void)handleOperationError:(NSError *)error
{
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in PackageDetailsInfoViewController" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self packageDetailsOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in PackageDetailsInfoViewController" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self packageDetailsOperationFailedMethod:error2];
    
}

#pragma mark - Prepare For Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddNewCarSegue"]) {
        //pass package id and user id to new scene
        AddNewCar *addNewCar=[segue destinationViewController];
        addNewCar.packageDetailsDict=self.packageDetailsDict;
    }
}

- (void)dealloc {
    _packageDetailsDict=nil;
}
@end
