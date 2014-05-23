//
//  CameraViewController.m
//  Car-Finder
//
//  Created by Mac on 26/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "CommonMethods.h"

//for glossy button
#import "CheckButton.h"
#import "UIButton+Glossy.h"

#import "AFNetworking.h"

#import "UIAlertView+error.h"
//#import "UIImage+Resize.h"

#import "CarRecord.h"
#import "DetailViewForSeller.h"
#import "SelectedCarDetails.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "TPKeyboardAvoidingScrollView.h"
#import "MyCarsList.h"


@interface CameraViewController()

@property (strong, nonatomic) UIImageView *photoImageView;
@property(strong,nonatomic) CheckButton *useCameraButton, *useGalleryButton, *uploadButton;
@property(strong,nonatomic) AFHTTPClient * Client;

@property(strong,nonatomic) NSOperationQueue *findCarIDQueue;

//- (void)useCamera;
//- (void)useGallery;

- (void)handleOperationError:(NSError *)error;

@end


@implementation CameraViewController

@synthesize newMedia=_newMedia,photoImageView=_photoImageView;
@synthesize useCameraButton=_useCameraButton, useGalleryButton=_useGalleryButton, uploadButton=_uploadButton,Client=_Client;
@synthesize carReceived=_carReceived;

@synthesize delegate=_delegate,findCarIDQueue=_findCarIDQueue;

@synthesize image1=_image1;


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
    
    //self.title=@"Upload Photo";
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 120, 45)];
    navtitle.text=@"Upload Photo"; //
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle]; 
    
    self.navigationItem.titleView=navtitle;
    
    [CommonMethods putBackgroundImageOnView:self.view];
    

    
    //set up scrollview
    TPKeyboardAvoidingScrollView *cameraScrollView=[[TPKeyboardAvoidingScrollView alloc] init];//WithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:cameraScrollView];
    
    
    UIView* contentView = [UIView new];
    //contentView.backgroundColor = [UIColor greenColor];
    [cameraScrollView addSubview:contentView];

    
    
    //
    self.photoImageView=[[UIImageView alloc] init];//WithFrame:CGRectMake(20, 26, 280, 280)];
    self.photoImageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.photoImageView setUserInteractionEnabled:NO];
    //self.photoImageView.image=[UIImage imageNamed:@"logo2.png"];
    [contentView addSubview:self.photoImageView];
    
    
    
    self.uploadButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    //self.uploadButton.frame=CGRectMake(self.view.frame.size.width/2-41, 300, 82, 37); //20, 340, 82, 37
    [self.uploadButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    ///_____
    
    
    self.uploadButton.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:141.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    [self.uploadButton setTitle:@"Up Load" forState:UIControlStateNormal];
    [self.uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
    self.uploadButton.layer.shadowRadius = 2.0f;
    self.uploadButton.layer.shadowOpacity = 0.5f;
    self.uploadButton.layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.uploadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];

     //[self.uploadButton setBackgroundImage:[UIImage imageNamed:@"Upload.png"] forState:UIControlStateNormal];
    [contentView addSubview:self.uploadButton];
    
    
    
    self.photoImageView.image = self.image1;
    
    //autolayout
    [cameraScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.photoImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.uploadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIImageView *tempPhotoIV=self.photoImageView;
    CheckButton *tempUploadBtn=self.uploadButton;
    UIView *mainView=self.view;
    
    NSDictionary *viewsDict=NSDictionaryOfVariableBindings(cameraScrollView,contentView,tempPhotoIV,tempUploadBtn);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cameraScrollView]|" options:0 metrics:0 views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cameraScrollView]|" options:0 metrics:0 views:viewsDict]];
    
    [cameraScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView]|" options:0 metrics:0 views:viewsDict]];
    [cameraScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:0 views:viewsDict]];

    //first horizontally center the items
    //[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[tempPhotoIV]-|" options:0 metrics:0 views:viewsDict]];
    NSLayoutConstraint *c1=[NSLayoutConstraint constraintWithItem:tempPhotoIV attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [contentView addConstraint:c1];
    
         [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tempPhotoIV]-(==10)-[tempUploadBtn]-|" options:0 metrics:0 views:viewsDict]];
    //set width for imageview
    NSString *widthConstraint;
    NSString *heightConstraint;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        widthConstraint=@"H:[tempPhotoIV(==300@1000)]";
        heightConstraint=@"V:[tempPhotoIV(==300@1000)]";
    }
    else
    {
        widthConstraint=@"H:[tempPhotoIV(==500@1000)]";
        heightConstraint=@"V:[tempPhotoIV(==500@1000)]";
    }
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthConstraint options:0 metrics:0 views:viewsDict]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightConstraint options:0 metrics:0 views:viewsDict]];
    
    
    c1=[NSLayoutConstraint constraintWithItem:self.uploadButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.photoImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.uploadButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.uploadButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:120];
    [contentView addConstraint:c1];
    
    c1=[NSLayoutConstraint constraintWithItem:self.uploadButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
    [contentView addConstraint:c1];
    
    NSDictionary* viewsDict2 = NSDictionaryOfVariableBindings(cameraScrollView, contentView, mainView);
    
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]" options:0 metrics:0 views:viewsDict2]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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



- (void)uploadPhoto
{
    self.uploadButton.enabled=NO;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSData *data=UIImageJPEGRepresentation(self.photoImageView.image,1.0);
    
    //NSLog(@"data=%@",data);
    //
    const unsigned char *bytes = [data bytes]; // no need to copy the data
    
    NSUInteger length = [data length];
      //NSLog(@"byteArray length=%d",length);
    
    NSMutableArray *byteArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < length; i++) {
        [byteArray addObject:[NSNumber numberWithUnsignedChar:bytes[i]]];
        //NSLog(@"actual byte is %c",bytes[i]);
    }
    
    
    self.Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.unitedcarexchange.com/"]];
   
    NSDictionary * parameters = nil;
    /*
     http://www.unitedcarexchange.com/MobileService/CarService.asmx/UploadPictureByCarID?CarID="carID"&make="make"&model="model"&"year="year"&UserID="UID" &picContent="array of image"&AuthenticationID="AID"&CustomerID="CID"
     */
    
    //
    NSString *carid=[NSString stringWithFormat:@"%d",[self.carReceived carid]];
    NSString *makeName=[self.carReceived make];
    NSString *modelName=[self.carReceived model];
    NSString *year=[NSString stringWithFormat:@"%d",[self.carReceived year]];
    NSString *uid=[self.carReceived uid];
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:carid, @"CarID",makeName, @"make",modelName,@"model",year,@"year",uid,@"UserID",byteArray,@"picContent",@"ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654",@"AuthenticationID",retrieveduuid,@"CustomerID",sessionID,@"SessionID",nil];
    //NSLog(@"parameters -- %@ ", parameters);
    
   
    
    __weak CameraViewController *weakSelf=self;
    
    [self.Client setParameterEncoding:AFJSONParameterEncoding];
    [self.Client postPath:@"MobileService/CarService.asmx/UploadPictureByCarID" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        weakSelf.uploadButton.enabled=YES;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //NSLog(@"operation hasAcceptableStatusCode: %d", [operation.response statusCode]);
        
        //NSLog(@"response string: %@ ", operation.responseString);
        if ([operation.responseString isEqualToString:@"Success"]) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Upload Success" message:@"Car picture was uploaded successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
            
            
            
            
            //hide the upload, cancel buttons, nil imageview. Then unhide camera, photogallery buttons
 
            self.photoImageView.image=nil;
            //self.uploadButton.hidden=YES;
            //self.cancelButton.hidden=YES;
            
            NSLog(@"all view controllers=%@",self.navigationController.viewControllers);
         
            
            FGalleryViewController *vc=[self.navigationController.viewControllers objectAtIndex:4];
            vc.justUploaded=YES;
            [weakSelf.navigationController popViewControllerAnimated:NO];
            
        }
        else if ([operation.responseString isEqualToString:@"Failed"])
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Upload Failed" message:@"Car picture could not be uploaded." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        weakSelf.uploadButton.enabled=YES;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSLog(@"error: %@", operation.responseString);
        NSLog(@"%d",operation.response.statusCode);
        //if status code=0, the operation was cancelled
        if (operation.response.statusCode==0) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Upload Cancelled" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
            

        }
        else
        {
        [weakSelf handleOperationError:error];
        }
        
    }];
    
    
        
}

- (void)cameraOperationFailedMethod:(NSError *)error
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
    [userInfo setValue:@"Error in CameraViewController" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self cameraOperationFailedMethod:error2];
    
}


#pragma mark - Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MyCustomSegueID"]) {
        DetailViewForSeller *detailViewForSeller=[segue destinationViewController];
        detailViewForSeller.carRecordFromFirstView=self.carReceived;
    }
}
- (void)dealloc {
    _carReceived=nil;
    
    _photoImageView=nil;
    _useCameraButton=nil;
    _useGalleryButton=nil;
    _uploadButton=nil;
    
}
@end
