//
//  SellerCarDetailsTwo.m
//  Car-Finder
//
//  Created by Mac on 11/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SelectedCarDetails.h"
#import "CommonMethods.h"
#import "CarRecord.h"



//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "VehicleTypeViewController.h"
#import "SellerInformationViewController.h"
#import "VehicleInformationViewController.h"
#import "VehicleFeaturesViewController.h"
#import "VehicleDescriptionViewController.h"
#import "MyCarAdsViewController.h"


#import "AFNetworking.h"
#import "CameraViewController.h"
#import "LoginViewController.h"

#import "MyCarsList.h"


@interface SelectedCarDetails ()

@property(nonatomic, retain) NSMutableArray *sellerInfoDetails;




//gallery
@property(strong,nonatomic) NSMutableDictionary *imagesDictionary;
@property(strong,nonatomic) NSMutableArray *arrayOfCarPicUrls;


@property(strong,nonatomic) FGalleryPhoto *networkGalleryPhoto;//Remove after test

@property(strong,nonatomic) NSOperationQueue *opQueue;

@property(assign,nonatomic) BOOL featuresFound;

@property(assign) BOOL selectedToGalleryViewFromLoginViews;

@property(strong,nonatomic) NSArray *featuresArray;

@property(strong,nonatomic) UIActionSheet *withdrawSoldActionSheet,*actionSheetPhotoUpload;;

@property(copy,nonatomic) NSString *statusSelected;

@property(strong, nonatomic) UIImage *photoView;

@property(strong,nonatomic) UIPopoverController *myPopoverController;

-(void)featureDetailsImplementation;


//getting urls of images
-(void)getArrayOfCarPicUrls;

- (void)handleDoesNotRespondToSelectorError;
- (void)callWebServiceToSaveData:(NSInteger)buttonIndex;
- (void)webServiceCallToSaveDataSucceededWithResponse:(NSDictionary *)aDict;
- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error;


@end

@implementation SelectedCarDetails


@synthesize sellerInfoDetails=_sellerInfoDetails;




@synthesize carReceived=_carReceived, arrayOfCarPicUrls=_arrayOfCarPicUrls, networkGallery=_networkGallery, imagesDictionary=_imagesDictionary,networkGalleryPhoto=_networkGalleryPhoto;

@synthesize opQueue=_opQueue, featuresFound=_featuresFound, featuresArray=_featuresArray,withdrawSoldActionSheet=_withdrawSoldActionSheet,actionSheetPhotoUpload=_actionSheetPhotoUpload;


@synthesize statusSelected=_statusSelected;


@synthesize newMedia=_newMedia,photoView=_photoView;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.

    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=[NSString stringWithFormat:@"%d %@ %@",[self.carReceived year],[self.carReceived make],[self.carReceived model]]; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    self.navigationItem.titleView=navtitle;
    navtitle=nil;

    
    //  [CommonMethods putBackgroundImageOnView:self.view];
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] init];
    doneButton.target = self;
    doneButton.action = @selector(doneButtonTapped);
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [doneButton setTitleTextAttributes:dic1 forState:UIControlStateNormal];
    [doneButton setTitle:[NSString stringWithFormat:@"Done"]];
    doneButton.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    self.navigationItem.leftBarButtonItem=doneButton;
    
    
    UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] init];
    logoutButton.target = self;
    logoutButton.action = @selector(logoutButtonTapped:);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [logoutButton setTitleTextAttributes:dic forState:UIControlStateNormal];
    [logoutButton setTitle:[NSString stringWithFormat:@"Logout"]];
    logoutButton.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem=logoutButton;
    
    
    //for background image;
    self.tableView.backgroundView = [CommonMethods backgroundImageOnTableView:self.tableView];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    self.sellerInfoDetails = [[NSMutableArray alloc] initWithObjects:@"Vehicle Type",@"Seller Information",@"Vehicle Information",@"Vehicle Features",@"Vehicle Description",@"Photos",@"Car Status",@"My Car Ads", nil];
    
    
    self.opQueue=[[NSOperationQueue alloc] init];
    [self.opQueue setName:@"SelectedCarDetailsOpQueue"];
    [self.opQueue setMaxConcurrentOperationCount:1];
    
    [self retrieveUrlsAndImages];
    
    
}

-(void)retrieveUrlsAndImages
{
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    //calling service
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/FindCarID/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",[self.carReceived carid],retrieveduuid]; //[self.carRecordFromFirstView carid]]; //52706
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *URL = [NSURL URLWithString:webServiceUrl];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak SelectedCarDetails *weakSelf=self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
               weakSelf.imagesDictionary=[[NSMutableDictionary alloc]init];
        
        NSError *error;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        
        NSArray *findCarIDResult=[wholeResult objectForKey:@"FindCarIDResult"];
        
        
        if([findCarIDResult respondsToSelector:@selector(objectAtIndex:)])
        {
            
            if (!findCarIDResult.count) {
                [weakSelf noRecordError]; //i.e., car id is not found in database
                return;
            }
            NSDictionary *individualcar = [findCarIDResult objectAtIndex:0];
            
            
            NSMutableString *picName=nil;
            NSMutableArray *picsArray=[[NSMutableArray alloc]init];
            
            for (int i=1; i<=20; i++) {
                picName=[[NSMutableString alloc]initWithFormat:@"PIC%d",i];
                [picsArray addObject:picName];
                picName=nil;
                
            }
            
            
            NSMutableString *picLocName=nil;
            NSMutableArray *picsLocArray=[[NSMutableArray alloc]init];
            
            for (int i=1; i<=20; i++) {
                picLocName=[[NSMutableString alloc]initWithFormat:@"PICLOC%d",i];
                [picsLocArray addObject:picLocName];
                picLocName=nil;
                
            }
            
            for (int i=0; i<20; i++) {
                NSString *tempPicName=[NSString stringWithFormat:@"_%@",[picsArray objectAtIndex:i]];
                NSString *tempPicLocName=[NSString stringWithFormat:@"_%@",[picsLocArray objectAtIndex:i]];
                
                
                [weakSelf.imagesDictionary setObject:[individualcar objectForKey:tempPicName] forKey:[picsArray objectAtIndex:i]];
                [weakSelf.imagesDictionary setObject:[individualcar objectForKey:tempPicLocName] forKey:[picsLocArray objectAtIndex:i]];
                
            }
            
            [weakSelf getArrayOfCarPicUrls];
            picsArray=nil;
            picsLocArray=nil;
        }
        else
        {
            [weakSelf handleDoesNotRespondToSelectorError];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        //The Internet connection appears to be offline.
        
        NSLog(@"call service failed %@ with error = %@ in %@:%@",webServiceUrl,[error localizedDescription],NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd));
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet Connection" message:@"The Internet connection appears to be offline." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
    }];
    
    [self.opQueue addOperation:operation];
    //operation=nil;
    
}

- (void)noRecordError
{
    //don't do anything
}

- (void)handleDoesNotRespondToSelectorError
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Data could not be retrieved as UCE server is down." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
    
}



-(void)getArrayOfCarPicUrls
{
    NSMutableArray *tempArrayOfCarPicUrls=[[NSMutableArray alloc]init];
    self.arrayOfCarPicUrls=tempArrayOfCarPicUrls;
    tempArrayOfCarPicUrls=nil;
    NSString *completeimagename1;
    
    NSArray *imageNames=[NSArray arrayWithObjects:@"PIC1",@"PIC2",@"PIC3",@"PIC4",@"PIC5",@"PIC6",@"PIC7",@"PIC8",@"PIC9",@"PIC10", @"PIC11",@"PIC12",@"PIC13",@"PIC14",@"PIC15",@"PIC16",@"PIC17",@"PIC18",@"PIC19",@"PIC20", nil];
    
    NSArray *imageDirs=[NSArray arrayWithObjects:@"PICLOC1",@"PICLOC2",@"PICLOC3",@"PICLOC4",@"PICLOC5",@"PICLOC6",@"PICLOC7",@"PICLOC8",@"PICLOC9",@"PICLOC10", @"PICLOC11",@"PICLOC12",@"PICLOC13",@"PICLOC14",@"PICLOC15",@"PICLOC16",@"PICLOC17",@"PICLOC18",@"PICLOC19",@"PICLOC20", nil];
    
    
    //condition to check whether pic0 is empty or not
    
    
    for (int i=0; i<[imageNames count]; i++) {
        
        
        if (![[self.imagesDictionary objectForKey:[imageNames objectAtIndex:i]] isEqualToString:@"Emp"]) {
            completeimagename1=[[NSString alloc]initWithFormat:@"http://www.unitedcarexchange.com/%@%@",[self.imagesDictionary objectForKey:[imageDirs objectAtIndex:i]],[self.imagesDictionary objectForKey:[imageNames objectAtIndex:i]]];
            
            completeimagename1=[completeimagename1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.arrayOfCarPicUrls addObject:completeimagename1];
            completeimagename1=nil;
            
        }
        else
            break;
    }
    
    if (self.networkGallery!=nil) {

        [self prepareNetworkGallery];
        [self.networkGallery reloadGallery];
    }
    
}

-(void)doneButtonTapped
{
    
    
    MyCarsList *myCarsList=[self.navigationController.viewControllers objectAtIndex:2];
    
    [self.navigationController popToViewController:myCarsList animated:YES];
    //update car record in delegate (DetailViewForSeller)
    if (self.delegate && [self.delegate respondsToSelector:@selector(carRecordUpdate:)]) {
        [self.delegate carRecordUpdate:self.carReceived];
    }
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
    
    return [self.sellerInfoDetails count];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectedCarDetailsCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
   
    cell.textLabel.text = [self.sellerInfoDetails objectAtIndex:indexPath.row];
    
    
    cell.textLabel.font=[UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    
    
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        
    NSString *adStatus;
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = @"Make, Model, Year etc..";
            break;
        case 1:
            cell.detailTextLabel.text = @"City, State, Zip etc..";
            break;
        case 2:
            cell.detailTextLabel.text = @"Title, Asking Price, Mileage etc..";
            break;
        case 3:
            cell.detailTextLabel.text = @"Comfort, Seats, Safety etc..";
            break;
        case 4:
            cell.detailTextLabel.text = @"Title, Description";
            break;
        case 5:
            cell.detailTextLabel.text = @"View/Upload photos";
            break;
        case 6:
            adStatus=[self.carReceived adStatus];
            if (adStatus!=nil) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"This car status is: %@",adStatus];
            }
            
            
            break;
        case 7:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Ads of \"%d %@ %@\"",[self.carReceived year],[self.carReceived make],[self.carReceived model]];
            break;
            
        default:
            break;
            
    }
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor lightGrayColor];
    bgColorView.layer.cornerRadius = 7;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
    
    
    return 0;
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
    

    NSString *adStatus;
    
    switch (indexPath.row) {
        case 0:
            
            [self performSegueWithIdentifier:@"VehicleTypeSegue" sender:self.carReceived];
            
            break;
            
            
        case 1:
            
            [self performSegueWithIdentifier:@"SellerInfoSegue" sender:self.carReceived];
            
            break;
            
        case 2:
            
            [self performSegueWithIdentifier:@"VehicleInformationSegue" sender:self.carReceived];
            break;
            
        case 3:
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            self.view.userInteractionEnabled=NO;
            
            [self featureDetailsImplementation];
            
            break;
        case 4:
            
            [self performSegueWithIdentifier:@"VehicleDescriptionSegue" sender:self.carReceived];
            
            break;
        case 5:
            
             _selectedToGalleryViewFromLoginViews = YES;
            
            [self prepareNetworkGallery];
            //self.networkGallery.beginsInThumbnailView=YES;
           
            
            [self.navigationController pushViewController:self.networkGallery animated:YES];
         
            break;
        case 6:
            
            adStatus=[self.carReceived adStatus];
            
            if (![adStatus isEqualToString:@"Active"]) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Status Cannot Be Changed" message:@"Please call customer support to change the car status." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                
                
            }
            else
            {
             
                self.withdrawSoldActionSheet=({
                    
                    
                    NSString *alertTitle=[NSString stringWithFormat:@"Car Status: %@",adStatus];
                    
                    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:alertTitle
                                                  delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:@"Sold"
                                                  otherButtonTitles:@"Withdraw", nil];
                    [actionSheet showInView:self.view];
                    
                    actionSheet;
                    
                });
             // [self performSegueWithIdentifier:@"VehicleDescriptionSegue" sender:self.carReceived];
            }
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
            
        case 7:
            
            [self performSegueWithIdentifier:@"MyCarsAddsSegue" sender:self.carReceived];
            
            
            break;
            
        default:
            break;
            
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

#pragma mark - FGalleryViewControllerDelegate Methods
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    int num=0;
    if( gallery == self.networkGallery )
    {
        num = [self.arrayOfCarPicUrls count];
        
    }
	return num;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index
{
    return [self.arrayOfCarPicUrls objectAtIndex:index];
}



- (void)UploadPhotoButtonTapped
{
    
    self.actionSheetPhotoUpload = ({
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Select Option"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Camera"
                                      otherButtonTitles:@"Photo gallery", nil];
        [actionSheet showFromBarButtonItem:self.rightBarButtonUploadPhotos animated:YES];
        
        
        actionSheet;
        
    });
    
    
}

-(void)featureDetailsImplementation
{
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    //NSString *featuresServiceStr=@"http://unitedcarexchange.com/MobileService/Service.svc/GetCarFeatures?sCarId=381";
    
    NSString *featuresServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetCarFeatures/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",[self.carReceived carid],retrieveduuid];
    
    
    
    //calling service
    NSURL *URL = [NSURL URLWithString:featuresServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    self.featuresFound=NO;
    
    //create operation
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak SelectedCarDetails *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        weakSelf.view.userInteractionEnabled=YES;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
               //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        
        
        if(error2==nil)
        {
            weakSelf.featuresFound=YES;
            weakSelf.featuresArray=[wholeResult objectForKey:@"GetCarFeaturesResult"];
            [weakSelf performSegueWithIdentifier:@"VehicleFeatureSegue" sender:weakSelf.featuresArray];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        weakSelf.view.userInteractionEnabled=YES;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        weakSelf.featuresFound=NO;
        
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
    }];
    
    [self.opQueue addOperation:operation];
    //operation=nil;
    
}

#pragma mark - Private Methods
- (BOOL)userHasLessThan20Cars
{
    BOOL userCanAddImage=NO;
    
    
    if ([self.arrayOfCarPicUrls count]<20) {
        userCanAddImage=YES;
    }
    return userCanAddImage;
}

- (void)prepareNetworkGallery
{
    if ([self userHasLessThan20Cars]) {
        
        
        
        if (self.rightBarButtonUploadPhotos==nil) {
            self.rightBarButtonUploadPhotos = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(UploadPhotoButtonTapped)];
            
            
            [self.rightBarButtonUploadPhotos setTintColor:[UIColor blueColor]];
        }
        
        
        //change after lunch
        
        if (self.networkGallery==nil) {
            self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:[NSArray arrayWithObject:self.rightBarButtonUploadPhotos ]];
        }
        
    }
    else
    {
        if (self.networkGallery==nil) {
        self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        }
    }
    self.networkGallery.selectedToGalleryViewFromLoginViews = _selectedToGalleryViewFromLoginViews;
    
    self.networkGallery.carRecord=self.carReceived;
}

#pragma mark - Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VehicleTypeSegue"]) {
        VehicleTypeViewController *vehicleTypeViewController=[segue destinationViewController];
        vehicleTypeViewController.carReceived=(CarRecord *)sender;
    }
    else if ([segue.identifier isEqualToString:@"SellerInfoSegue"]) {
        SellerInformationViewController *sellerInformationViewController=[segue destinationViewController];
        sellerInformationViewController.carReceived=(CarRecord *)sender;
    }
    else if ([segue.identifier isEqualToString:@"VehicleInformationSegue"]) {
        VehicleInformationViewController *vehicleInformationViewController=[segue destinationViewController];
        vehicleInformationViewController.carReceived=(CarRecord *)sender;
    }
    else if ([segue.identifier isEqualToString:@"VehicleFeatureSegue"]) {
        VehicleFeaturesViewController *vehicleFeaturesViewController=[segue destinationViewController];
        vehicleFeaturesViewController.featuresArray=(NSArray *)sender;
    }
    else if ([segue.identifier isEqualToString:@"VehicleDescriptionSegue"]) {
        VehicleDescriptionViewController *vehicleDescriptionViewController=[segue destinationViewController];
        vehicleDescriptionViewController.carReceived=(CarRecord *)sender;
    }
    else if ([segue.identifier isEqualToString:@"SelectedCarDetailsToCameraSegue"]) {
        CameraViewController *cameraViewcontroller=[segue destinationViewController];
        
        cameraViewcontroller.image1  = self.photoView;
        cameraViewcontroller.carReceived=(CarRecord *)sender;
        
    }
    
    else if ([segue.identifier isEqualToString:@"MyCarsAddsSegue"]) {
        MyCarAdsViewController *myCarAddsViewcontroller=[segue destinationViewController];
        
        myCarAddsViewcontroller.carReceived=(CarRecord *)sender;
        
    }
  
}

#pragma mark - ActionSheet Delegate Methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    
    if ([actionSheet isEqual:self.withdrawSoldActionSheet]) {
        
                if (buttonIndex==0 || buttonIndex==1) {
            [self callWebServiceToSaveData:buttonIndex];
            
        }
        
        
        
    }
    else if ([actionSheet isEqual:self.actionSheetPhotoUpload])
    {
        
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        
        if  ([buttonTitle isEqualToString:@"Camera"]) {
            
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            {
                if ([UIImagePickerController isSourceTypeAvailable:
                     UIImagePickerControllerSourceTypeCamera])
                {
                    UIImagePickerController *imagePicker =
                    [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    imagePicker.sourceType =
                    UIImagePickerControllerSourceTypeCamera;
                    imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                              (NSString *) kUTTypeImage,
                                              nil];
                    imagePicker.allowsEditing = NO;
                    [self presentViewController:imagePicker animated:YES completion:nil];
                    // self.newMedia = NO;
                }
            }
            else//UIUserInterfaceIdiomPad
            {
                if ([self.myPopoverController isPopoverVisible]) {
                    [self.myPopoverController dismissPopoverAnimated:YES];
                } else
                    
                    
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        UIImagePickerController *imagePicker =
                        [[UIImagePickerController alloc] init];
                        imagePicker.delegate = self;
                        imagePicker.sourceType =
                        UIImagePickerControllerSourceTypeCamera;
                        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                                  (NSString *) kUTTypeImage,
                                                  nil];
                        imagePicker.allowsEditing = NO;
                        
                        
                        self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                        
                        self.myPopoverController.delegate = self;
                        
                        [self.myPopoverController
                         presentPopoverFromBarButtonItem:self.rightBarButtonUploadPhotos
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                         animated:YES];
                        
                        //[self presentModalViewController:imagePicker animated:YES];
                        
                        self.newMedia = NO;
                    }
                }
            }
            
        }
        if ([buttonTitle isEqualToString:@"Photo gallery"]) {
            
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
            {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker =
                [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType =
                UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
                // self.newMedia = NO;
            }
            }
            else//UIUserInterfaceIdiomPad
            {
                if ([self.myPopoverController isPopoverVisible]) {
                    [self.myPopoverController dismissPopoverAnimated:YES];
                } else
                    
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        UIImagePickerController *imagePicker =
                        [[UIImagePickerController alloc] init];
                        imagePicker.delegate = self;
                        imagePicker.sourceType =
                        UIImagePickerControllerSourceTypePhotoLibrary;
                        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                                  (NSString *) kUTTypeImage,
                                                  nil];
                        imagePicker.allowsEditing = NO;
                        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
                        self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                        self.myPopoverController.delegate = self;
                        
                        [self.myPopoverController
                         presentPopoverFromBarButtonItem:self.rightBarButtonUploadPhotos
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                         animated:YES];
                        }else{
                        
                        [self presentViewController:imagePicker animated:YES completion:nil];
                        }
                        //[self presentModalViewController:imagePicker animated:YES];
                        
                        self.newMedia = NO;
                    }
                }
            }
           
            }
            //main if
        if ([buttonTitle isEqualToString:@"Cancel"]) {
        }
    }
 
}


#pragma mark - ImagePicker Delegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([self.myPopoverController isPopoverVisible]) {
            [self.myPopoverController dismissPopoverAnimated:YES];
        }
    }
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        
        
        //
        self.photoView = image; //croppedImage;
       
        
        if (self.newMedia)
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
    
    picker.delegate=nil;
    picker=nil;

    
    
    [self performSegueWithIdentifier:@"SelectedCarDetailsToCameraSegue" sender:self.carReceived];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Save failed" message: @"Failed to save image." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        alert=nil;
    }
}


- (void)callWebServiceToSaveData:(NSInteger)buttonIndex
{
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *uid=[defaults valueForKey:UID_KEY];
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    
    /*
     http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/UpdateMobileCarStatusByCarID/1902/120/Withdraw/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/12345/B2F6F696-D0E9-4CF2-B6F3-456D6F06D8A6
     
     */
    
    
    if (buttonIndex==1) {
        self.statusSelected=@"Withdraw";
    }
    else if (buttonIndex==0)
    {
        self.statusSelected=@"Sold";
    }
    NSString *updateCarDetailsServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/UpdateMobileCarStatusByCarID/%d/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@", [self.carReceived carid],uid,self.statusSelected,retrieveduuid,sessionID];
    
    
    
    
    //calling service
    NSURL *URL = [NSURL URLWithString:updateCarDetailsServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak SelectedCarDetails *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSError *error2;
        NSDictionary *responseDict=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        if(error2==nil)
        {
            [weakSelf webServiceCallToSaveDataSucceededWithResponse:responseDict];
        }
        else
        {
            [weakSelf webServiceCallToSaveDataFailedWithError:error2];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              [weakSelf webServiceCallToSaveDataFailedWithError:error];
        
    }];
    
    [self.opQueue addOperation:operation];
    
}

- (void)webServiceCallToSaveDataSucceededWithResponse:(NSDictionary *)aDict
{
    
    if ([[aDict objectForKey:@"UpdateMobileCarStatusByCarIDResult"] isEqualToString:@"Success"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Car status updated." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        //save the modified data to car record, because if the user goes back and comes to this screen again, he should see updated details.
        [self.carReceived setAdStatus:self.statusSelected];
        //reload that cell to reflect the change
        NSIndexPath *ip=[NSIndexPath indexPathForRow:6 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if ([[aDict objectForKey:@"UpdateMobileCarStatusByCarIDResult"] isEqualToString:@"Session timed out"])
    {
        //session timed out. so take the user to login screen
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if ([[aDict objectForKey:@"UpdateMobileCarStatusByCarIDResult"] isEqualToString:@"Unsucess"]||[[aDict objectForKey:@"UpdateMobileCarStatusByCarIDResult"] isEqualToString:@"Failed"])
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

- (void)webServiceCallToSaveDataFailedWithError:(NSError *)error
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
    
    __weak SelectedCarDetails *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //[weakSelf hideActivityViewer];
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
                [weakSelf selectedCarDetailsOperationFailedMethod:nil];
                
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
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"SelectedCarDetailsOpQueue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    else
    {
        [self.opQueue cancelAllOperations];
    }
    
    [self.opQueue addOperation:operation];
}

#pragma mark - Operation Failed Error Handling

- (void)selectedCarDetailsOperationFailedMethod:(NSError *)error
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
    [userInfo setValue:@"Error in SelectedCarDetails" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self selectedCarDetailsOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in SelectedCarDetails" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self selectedCarDetailsOperationFailedMethod:error2];
    
}



-(void)dealloc
{
    _carReceived=nil;
    _sellerInfoDetails=nil;
    _networkGallery=nil;
    _featuresArray=nil;
    _arrayOfCarPicUrls=nil;
    _imagesDictionary=nil;
    _opQueue=nil;
    _withdrawSoldActionSheet=nil;
    _statusSelected=nil;
}



@end
