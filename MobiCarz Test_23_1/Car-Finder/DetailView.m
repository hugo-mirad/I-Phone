//
//  DetailView.m
//  XMLTable2
//
//  Created by Mac on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailView.h"
#import "ThumbnailDownloadOperation.h"
#import "CheckButton.h"
#import "EmailTheSeller.h"
#import "CarRecord.h"

//for dialing a number
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "UIButton+Glossy.h"

#import "AFNetworking.h"
#import "Features.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

//common methods
#import "CommonMethods.h"

#import "UILabel+dynamicSizeMe.h"


#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


@interface DetailView ()

@property(strong,nonatomic) UILabel *CondDesp,*carDescription;

@property(strong,nonatomic) NSArray *carDetailLabelsArray,*cardetailarray2,*cardetailarray3,*featuresArray;


@property(strong,nonatomic) UIImageView *iViewForNewCar;
@property(strong,nonatomic) UITapGestureRecognizer *gestureRecognizer1;
@property(strong,nonatomic) NSMutableArray *mArrayForPlist;
@property(strong,nonatomic) dispatch_queue_t queue;
@property(strong,nonatomic) UIImage *carThumbnailImg;

@property(strong,nonatomic) NSOperationQueue *opQueue;
@property(strong,nonatomic) CheckButton *myListBtn,*featuresButton,*viewGalleryBtn;
@property(assign,nonatomic) BOOL found,featuresFound;
@property(strong,nonatomic) UIWebView *emailButton;


//gallery
@property(strong,nonatomic) NSMutableDictionary *imagesDictionary;
@property(strong,nonatomic) NSMutableArray *arrayOfCarPicUrls;
@property(strong,nonatomic) FGalleryViewController *networkGallery;

@property(strong,nonatomic) UIImageView *activityImageView;
@property(strong,nonatomic) UIImage *showActivityViewerImage;
@property(strong,nonatomic) UIActivityIndicatorView *activityWheel;

@property(strong,nonatomic) UILabel *descLbl;

@property(strong,nonatomic) UIImageView *backgroundImageView;
@property(strong,nonatomic) UIImageView *tempImageView;
@property(strong,nonatomic) UIScrollView *scrollView1;
@property(strong,nonatomic) UIImageView *myListView;


@property(strong,nonatomic) UILabel *label1;

- (void)handleDoesNotRespondToSelectorError;
- (void)retrieveUrlsAndImages;
- (void)getArrayOfCarPicUrls;


@end


@implementation DetailView
@synthesize tempImageView=_tempImageView, scrollView1=_scrollView1, myListView=_myListView, prefNameFromPrefResultsTable=_prefNameFromPrefResultsTable, gestureRecognizer1=_gestureRecognizer1, fromPreferenceResults=_fromPreferenceResults, iViewForNewCar=_iViewForNewCar,cardetailarray2=_cardetailarray2,cardetailarray3=_cardetailarray3,CondDesp=_CondDesp,carDescription=_carDescription,carRecordFromFirstView=_carRecordFromFirstView;

@synthesize queue=_queue,carThumbnailImg=_carThumbnailImg,opQueue=_opQueue,myListBtn=_myListBtn,carDetailLabelsArray=_carDetailLabelsArray,mArrayForPlist=_mArrayForPlist,found=_found,emailButton=_emailButton,featuresButton=_featuresButton,featuresFound=_featuresFound;

@synthesize featuresArray=_featuresArray;

@synthesize imagesDictionary=_imagesDictionary,arrayOfCarPicUrls=_arrayOfCarPicUrls,viewGalleryBtn=_viewGalleryBtn,networkGallery=_networkGallery;

@synthesize delegate=_delegate;
@synthesize backgroundImageView=_backgroundImageView;

@synthesize showActivityViewerImage=_showActivityViewerImage,activityImageView=_activityImageView,activityWheel=_activityWheel;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}





- (void)createTwoTextLabelv2: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText height:(CGFloat)height
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
        
        myLabelTextLayer.frame = CGRectMake(0, 0, 300, height);
        myLabelTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        myLabelTextLayer.alignmentMode = kCAAlignmentLeft;
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
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor = [UIColor blackColor].CGColor;
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
    CGColorRef cgColor = [UIColor blackColor].CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    
    
    // customizing second string
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor = [UIColor blackColor].CGColor;
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


- (UILabel *)addPropertiesToMyLabel:(UILabel *)aLabel withText:(NSString *)aText withBold:(BOOL)aBold
{
    static CGFloat fSize;
    [aLabel setText:aText];
    fSize=[UIFont systemFontSize];
    if (aBold) {
        aLabel.font=[UIFont boldSystemFontOfSize:fSize];
    }
    //aLabel.textColor=[UIColor blackColor];
    aLabel.backgroundColor=[UIColor clearColor];
    
    return aLabel;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.tempImageView.image=nil;
}

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}


-(void)showActivityViewer
{
    [CommonMethods showActivityViewer:self.view];
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [CommonMethods hideActivityViewer:self.view];
}

#pragma mark - Database

-(bool)canDevicePlaceAPhoneCall {
    /*
     
     Returns YES if the device can place a phone call
     
     */
    CTTelephonyNetworkInfo *netInfo=nil;
    CTCarrier *carrier=nil;
    NSString *mnc=nil;
    BOOL canPlaceCallNow=NO;
    
    // Check if the device can place a phone call
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // Device supports phone calls, lets confirm it can place one right now
        netInfo = [[CTTelephonyNetworkInfo alloc] init];
        carrier = [netInfo subscriberCellularProvider];
        mnc = [carrier mobileNetworkCode];
        if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
            // Device cannot place a call at this time.  SIM might be removed.
            canPlaceCallNow=NO;
        } else {
            // Device can place a phone call
            canPlaceCallNow=YES;
        }
    } else {
        // Device does not support phone calls
        canPlaceCallNow=NO;
    }
    mnc=nil;
    carrier=nil;
    netInfo=nil;
    return canPlaceCallNow;
}

-(NSString *)formattedPhoneNumber
{
    //when the phone number is empty string like "", substringWithRange will crash
    if(self.carRecordFromFirstView==nil || ([[self.carRecordFromFirstView phone] length]==0))
        return nil;
    
    NSRange r1=NSMakeRange(0, 3);
    NSRange r2=NSMakeRange(3, 3);
    NSRange r3=NSMakeRange(6, 4);
    NSString *s1=[NSString stringWithFormat:@"(%@) ",[[self.carRecordFromFirstView phone] substringWithRange:r1]];
    
    NSString *s2=[s1 stringByAppendingString:[[self.carRecordFromFirstView phone] substringWithRange:r2]];
    
    NSString *s3=[NSString stringWithFormat:@"%@-%@",s2,[[self.carRecordFromFirstView phone] substringWithRange:r3]];
    s1=nil;
    s2=nil;
    return s3;
}


-(void)callButtonTapped

{
    
    NSString *callServiceStr=nil;
    
    
    
    //call callservice with 0 as user phone number
    
    
    
    // call service
   
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
 
#warning Modified New web service_16/06/2014 GenericSaveCallRequestMobile
    
    NSString *brandID = @"2";
    callServiceStr=[NSString stringWithFormat:@"http://test1.unitedcarexchange.com/MobileService/GenericServices.svc/GenericSaveCallRequestMobile/0/%d/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@",[self.carRecordFromFirstView carid],[self.carRecordFromFirstView phone],retrieveduuid,brandID];
    
    
    
    //calling service
    NSURL *URL = [NSURL URLWithString:callServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service executed succesfully
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
    }];
    
    [self.opQueue addOperation:operation];
    
    
    
    //see if the device can actually make a call
    NSString *phonenum=[NSString stringWithFormat:@"tel://+1%@",[self.carRecordFromFirstView phone]];
    if([self canDevicePlaceAPhoneCall])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenum]];
    }
    
    else
    {
        NSString *msg=[NSString stringWithFormat:@"This device cannot place a call now. Use another phone to call the seller at %@.",[self formattedPhoneNumber]];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Device Cannot Call Now" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
    
}


-(void)myListBtnTapped:(id)sender
{
    CheckButton *checkBox=(CheckButton *)sender;
    if([checkBox.currentImage isEqual:[UIImage imageNamed:@"mylist2.png"]])
    {
        [checkBox setImage:[UIImage imageNamed:@"mylist2-act.png"] forState:UIControlStateNormal];
        [checkBox setEnabled:NO];
        
        
        BOOL success;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filename=[NSString stringWithFormat:@"favoritecars.plist"];
        
        NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
        success = [fileManager fileExistsAtPath:writablePath];
        
        if (success)
        {
            self.mArrayForPlist=[NSMutableArray arrayWithContentsOfFile:writablePath];
            
        }
        else
        {
            //[fileManager copyItemAtPath:defaultDBPath toPath:writablePath error:&error];
            self.mArrayForPlist=[NSMutableArray array];
            [self.mArrayForPlist writeToFile:writablePath atomically:YES];
            
        }
        
        NSMutableDictionary *carDictionaryToSave=[[NSMutableDictionary alloc]initWithCapacity:1];
        [carDictionaryToSave setObject:[NSNumber numberWithInteger:[self.carRecordFromFirstView carid]] forKey:@"Carid"];
        
        [carDictionaryToSave setObject:[NSNumber numberWithInteger:[self.carRecordFromFirstView year]] forKey:@"YearOfMake"];
        [carDictionaryToSave setObject:[self.carRecordFromFirstView make] forKey:@"Make"];
        [carDictionaryToSave setObject:[self.carRecordFromFirstView model] forKey:@"Model"];
        [carDictionaryToSave setObject:[NSNumber numberWithInteger:[self.carRecordFromFirstView price]] forKey:@"Price"];
        [carDictionaryToSave setObject:[NSNumber numberWithInteger:[self.carRecordFromFirstView mileage]] forKey:@"Mileage"];
        // save image later
        
        
        //get thumbnail data from net
        self.queue=dispatch_queue_create("MyGlobalQueue", NULL);
        NSString *dbPathForThumbnail = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cachesDir=[dbPathForThumbnail stringByAppendingPathComponent:@"Caches"];
        
        dispatch_async(self.queue, ^{
            
            //get mylistthumbnails dir path
            
            NSString *thumbnailDir = [NSString stringWithFormat:@"%@/MyListThumbnails",cachesDir];
            NSError *error = nil;
            BOOL isDir=YES;
            if(!([fileManager fileExistsAtPath:thumbnailDir isDirectory:&isDir] && isDir))
                if(![fileManager createDirectoryAtPath:thumbnailDir withIntermediateDirectories:YES attributes:nil error:&error])
                    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
            
            //save image data to file
            NSData *imgDataToSave = UIImageJPEGRepresentation(self.carThumbnailImg, 1); // convert to jpeg
            
            //get file path
            NSString  *jpgPath1=[NSString stringWithFormat:@"%@/%d.jpg",thumbnailDir,[self.carRecordFromFirstView carid]];
            [imgDataToSave writeToFile:jpgPath1 atomically:YES];
            
        });
        
        //dispatch_release(self.queue);
        
        [carDictionaryToSave setObject:[NSString stringWithFormat:@"%d.jpg",[self.carRecordFromFirstView carid]] forKey:@"fileName"];
        
        
        
        /*
         NSData *imgData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
         NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"]; // identify the home directory and file name
         [imgData writeToFile:jpgPath atomically:YES];
         */
        
        [self.mArrayForPlist addObject:carDictionaryToSave];
        [self.mArrayForPlist writeToFile:writablePath atomically:YES];
        
        
    }
    else
    {
        [checkBox setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"mylist2" ofType:@"png"]] forState:UIControlStateNormal];
    }
    
}

-(void)imageViewTapped:(UITapGestureRecognizer*)gestRecognizer
{
    
    if (![self.viewGalleryBtn isHidden]) {
        self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        self.networkGallery.carRecord=self.carRecordFromFirstView;
        [self.navigationController pushViewController:self.networkGallery animated:YES];
    }
}

-(void)galleryBtnTapped
{
    self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    self.networkGallery.carRecord=self.carRecordFromFirstView;
  //  self.networkGallery.beginsInThumbnailView=YES;
    [self.navigationController pushViewController:self.networkGallery animated:YES];
}

-(void)emailButtonTapped
{
    [self performSegueWithIdentifier:@"EmailScrollviewSegue" sender:nil];
}

#pragma mark - Prepare For Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EmailScrollviewSegue"])
    {
        EmailTheSeller *emailTheSeller=[segue destinationViewController];
        emailTheSeller.carRecordFromDetailView=self.carRecordFromFirstView;
    }
    else if([segue.identifier isEqualToString:@"FeaturesSegueFromDetailView"])
    {
        Features *features=[segue destinationViewController];
        features.allFeaturesFromDetailView=self.featuresArray;
        
        NSString *navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.carRecordFromFirstView year],[self.carRecordFromFirstView make],[self.carRecordFromFirstView model]];
        features.navTitle=navTitle;
    }
    
}



/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

-(void)backToResultsButtonTapped
{
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)checkForFeatures
{
    
   
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    

#warning Modified New web service_17/06/2014 Check feature(GetCarFeatures
    
    NSString *featuresServiceStr=[NSString stringWithFormat:@"http://test1.unitedcarexchange.com/MobileService/GenericServices.svc/GenericGetCarFeatures/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/",[self.carRecordFromFirstView carid],retrieveduuid];
    
    
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
    
    __weak DetailView *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        if(error2==nil)
        {
            
            weakSelf.featuresArray=[wholeResult objectForKey:@"GenericGetCarFeaturesResult"];
            
            if([weakSelf.featuresArray respondsToSelector:@selector(objectAtIndex:)] && weakSelf.featuresArray.count)
            {
                weakSelf.featuresFound=YES;
                
                [weakSelf.featuresButton setHidden:NO];
            }
            else
            {
                [weakSelf.featuresButton setHidden:YES];
                
                //no need to handle handleDoesNotRespondToSelectorError if array is empty in this case
            }
        }
        else
        {
            [weakSelf.featuresButton setHidden:YES];
            
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        weakSelf.featuresFound=NO;
        [weakSelf.featuresButton setHidden:YES];
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    }];
    
    [self.opQueue addOperation:operation];
    //operation=nil;
    
}

-(void)featuresButtonTapped
{
    [self performSegueWithIdentifier:@"FeaturesSegueFromDetailView" sender:nil];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //navigation bar title
    NSString *navTitle=nil;
    if(self.carRecordFromFirstView!=nil)
    {
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.carRecordFromFirstView year],[self.carRecordFromFirstView make],[self.carRecordFromFirstView model]];
    }
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    navtitle.text=navTitle; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor = [UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    
    self.navigationItem.titleView=navtitle;
    navtitle=nil;

    
    
    UIImage* image3 = [UIImage imageNamed:@"BackAll.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width/2-20, image3.size.height/2-20);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(backToResultsButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    
    UIBarButtonItem *lb= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem =lb;
    lb=nil;
    
    
    /////
    NSOperationQueue *tempOpQueue=[[NSOperationQueue alloc]init];
    self.opQueue=tempOpQueue;
    tempOpQueue=nil;
    [self.opQueue setName:@"DetailViewQueue"];
    [self.opQueue setMaxConcurrentOperationCount:3]; //one for thumbnail, one for features check, one for gallery images check
    
    
    //check if features are present or not
    [self checkForFeatures];
    
    [self retrieveUrlsAndImages];
    
    //setting thumbnail logic was moved to viewWillAppear
    
    
    
    self.scrollView1=[[UIScrollView alloc] init];//WithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height)]; //150 49 for tab bar
    //self.scrollView1=[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height)]; //150 49 for tab bar
    //
    self.scrollView1.showsVerticalScrollIndicator=YES;
    self.scrollView1.scrollEnabled=YES;
    self.scrollView1.userInteractionEnabled=YES;
    
    //
    [self.view addSubview:self.scrollView1];
    //autolayout
    [self.scrollView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:scrollView1Constraint];
    
    scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraint:scrollView1Constraint];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self.view addConstraint:scrollView1Constraint];
        
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.view addConstraint:scrollView1Constraint];

        
    } else {
        
        
//        CGRect rect;
//        
//        rect = [[UIApplication sharedApplication] statusBarFrame];
        
        // from inside the view controller
        CGSize tabBarSize = [[[self tabBarController] tabBar] bounds].size;
        
        
        //load resources for iOS 7
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationController.navigationBar.frame.size.height];
        //+rect.size.height
        [self.view addConstraint:scrollView1Constraint];
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-tabBarSize.height];
        [self.view addConstraint:scrollView1Constraint];

    }


    
    self.tempImageView=[[UIImageView alloc] init];//WithFrame:CGRectMake(0,0,self.view.frame.size.width,163)];
    self.tempImageView.frame=CGRectMake(self.view.frame.size.width/2-270/2,30,270,164);
    self.tempImageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.tempImageView setUserInteractionEnabled:YES];
    //accessibility
    self.tempImageView.isAccessibilityElement=YES;
    self.tempImageView.accessibilityLabel=navTitle;
    [self.scrollView1 addSubview:self.tempImageView];
    //
    self.myListView=[[UIImageView alloc] initWithFrame:CGRectMake(0,self.tempImageView.frame.size.height+20,self.view.frame.size.width,54)];
    [self.myListView setUserInteractionEnabled:YES];
    //self.myListView.backgroundColor = [UIColor yellowColor];
    [self.scrollView1 addSubview:self.myListView];
    //
       
    //
    self.tempImageView.tag=[self.carRecordFromFirstView carid];
    
    /*
     // setting gesture recognizer for tempimageview
     */
    self.gestureRecognizer1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    
    [self.tempImageView addGestureRecognizer:self.gestureRecognizer1];
    
    
    /////
    UILabel *label;
    CGFloat lWidth;
    CGFloat y=40.0+self.tempImageView.frame.size.height+self.myListView.frame.size.height;
    //
    NSString *labelStringForFindingWidth,*fieldVal,*labelString;
    
    label=[[UILabel alloc]init];
    labelString=@"Email:";
    
    lWidth=[CommonMethods findLabelWidth:labelString];
    [label setFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.backgroundColor=[UIColor clearColor];
    [label setTextColor:[UIColor blackColor]];
    [self.scrollView1 addSubview:[self addPropertiesToMyLabel:label withText:labelString withBold:YES]];
    label=nil;
    
    //
    self.emailButton=[[UIWebView alloc]initWithFrame:CGRectMake([CommonMethods findLabelWidth:@"Email:"]+4, self.tempImageView.frame.size.height+self.myListView.frame.size.height+32, 200, 25)]; //when using as button give y as 8
    
    self.emailButton.opaque=NO;
    [self.emailButton setBackgroundColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    //if the email field is not Emp, show the webview, other wise hide it
    NSString *testString = @"<a href = \"obj://emailButtonTapped\"><font color='#F95446'>Send email to seller</color></a>";
    [self.emailButton loadHTMLString:testString baseURL:nil];
    self.emailButton.delegate=self;
    self.emailButton.backgroundColor=[UIColor clearColor];
    self.emailButton.scrollView.scrollEnabled = NO;
    //    emailLabel.font=[UIFont boldSystemFontOfSize:17];
    if(![[self.carRecordFromFirstView email] isEqualToString:@"Emp"])
    {
        [self.scrollView1 addSubview:self.emailButton];
        
    }
    
    NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
    
    NSString *priceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:[self.carRecordFromFirstView price]]];
    
    
    if([self.carRecordFromFirstView price] ==0)
    {
        priceVal=@"";
    }
    
    
    y+=20;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Price:",priceVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Price:" secondText:priceVal];
    label.backgroundColor=[UIColor colorWithRed:0.792 green:0.788 blue:0.792 alpha:1.000];
    label.backgroundColor=[UIColor clearColor];
    
    //accessibility
    if ([self.carRecordFromFirstView price] ==0) {
        label.accessibilityLabel=@"Price";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Price %d",[self.carRecordFromFirstView price]];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[[self.carRecordFromFirstView sellerType] isEqualToString:@"Emp"]?nil:[self.carRecordFromFirstView sellerType];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Seller Type:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Seller Type:" secondText:fieldVal];
    label.backgroundColor=[UIColor colorWithRed:0.792 green:0.788 blue:0.792 alpha:1.000];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (fieldVal==nil) {
        label.accessibilityLabel=@"Seller Type";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Seller Type %@",fieldVal];
    }
    
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //Phonenum to diaplay in format (888) 888-8888
    
    
    y+=20;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@  ",@"Phone:"]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Phone:" secondText:nil];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (IsEmpty([self.carRecordFromFirstView phone])||[[self.carRecordFromFirstView phone] isEqualToString:@"Emp"]) {
        label.accessibilityLabel=@"Phone";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Phone %@",[self.carRecordFromFirstView phone]];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    NSString *phoneStr=  [NSString stringWithFormat:@"%@",[self.carRecordFromFirstView phone]];
    if(!IsEmpty(phoneStr))
    {
        phoneStr=[self formattedPhoneNumber];
    }
    
    fieldVal=phoneStr;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ ",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f+[CommonMethods findLabelWidth:@"Phone: "], y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:fieldVal secondText:nil];
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    
    //
    //phone label gesture
    UITapGestureRecognizer* phoneLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneLblTapped:)];
    // if labelView is not set userInteractionEnabled, you must do so
    [label setUserInteractionEnabled:YES];
    [label addGestureRecognizer:phoneLblGesture];
    
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    NSString *addressStr=nil;
    if(![[self.carRecordFromFirstView city] isEqualToString:@"Emp"])
    {
        addressStr=[NSString stringWithFormat:@"%@",[[self.carRecordFromFirstView city] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    if(![[self.carRecordFromFirstView state] isEqualToString:@"Emp"])
    {
        if (!IsEmpty(addressStr)) {
            addressStr=[NSString stringWithFormat:@"%@, %@",addressStr,[self.carRecordFromFirstView state]];
        }
        else
        {
            addressStr=[NSString stringWithFormat:@"%@",[self.carRecordFromFirstView state]];
        }
        
    }
    
    if(![[self.carRecordFromFirstView zipCode] isEqualToString:@"Emp"])
    {
        if (!IsEmpty(addressStr)) {
            addressStr=[NSString stringWithFormat:@"%@ %@",addressStr,[self.carRecordFromFirstView zipCode]];
        }
        else
        {
            addressStr=[NSString stringWithFormat:@"%@",[self.carRecordFromFirstView zipCode]];
        }
        
    }
    
    fieldVal=addressStr;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Location:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Location:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (fieldVal==nil) {
        label.accessibilityLabel=@"Location";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Location %@",fieldVal];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView make];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Make:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Make:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Make %@",[self.carRecordFromFirstView make]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView model];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Model:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Model:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Model %@",[self.carRecordFromFirstView model]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[NSString stringWithFormat:@"%d",[self.carRecordFromFirstView year]];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Year:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Year:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Year %d",[self.carRecordFromFirstView year]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView exteriorColor];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Exterior Color:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Exterior Color:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Exterior Color %@",[self.carRecordFromFirstView exteriorColor]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView interiorColor];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Interior Color:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Interior Color:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Interior Color %@",[self.carRecordFromFirstView interiorColor]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView numberOfDoors];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Doors:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Doors:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Doors %@",[self.carRecordFromFirstView numberOfDoors]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView ConditionDescription];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Vehicle Condition:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Vehicle Condition:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Vehicle Condition %@",[self.carRecordFromFirstView ConditionDescription]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    //mileage formatter
    
    NSNumberFormatter *mileageFormatter=[CommonMethods sharedMileageFormatter];
    
    NSString *mileageString = [mileageFormatter stringFromNumber:[NSNumber numberWithInteger:[self.carRecordFromFirstView mileage]]];
    
    NSString *mileageStr= [NSString stringWithFormat:@"%@ mi",mileageString];
    if([self.carRecordFromFirstView mileage]==0)
    {
        mileageStr=@"";
    }
    
    fieldVal=mileageStr;
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Mileage:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Mileage:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (IsEmpty(fieldVal)) {
        label.accessibilityLabel=@"Mileage";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Mileage %d miles",[self.carRecordFromFirstView mileage]];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView fueltype];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Fuel:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Fuel:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Fuel %@",[self.carRecordFromFirstView fueltype]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView transmission];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Transmission:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Transmission:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Transmission %@",[self.carRecordFromFirstView transmission]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView driveTrain];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@  ",@"Drive Train:",fieldVal]; //add 2 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Drive Train:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Drive Train %@",[self.carRecordFromFirstView driveTrain]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.carRecordFromFirstView engineCylinders];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@  ",@"Engine Cylinders:",fieldVal]; //add 2 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Engine Cylinders:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Engine Cylinders %@",[self.carRecordFromFirstView engineCylinders]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[[self.carRecordFromFirstView vin] isEqualToString:@"Emp"]?nil:[self.carRecordFromFirstView vin];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@  ",@"VIN:",fieldVal]; //add 2 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"VIN:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (fieldVal==nil) {
        label.accessibilityLabel=@"Vin";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Vin %@",[self.carRecordFromFirstView vin]];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    fieldVal=[[self.carRecordFromFirstView extraDescription] isEqualToString:@"Emp"]?nil:[self.carRecordFromFirstView extraDescription];
    y+=20;
   
    self.descLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, 100, 30)];
    self.descLbl.textAlignment=NSTextAlignmentLeft;
    self.descLbl.text=[NSString stringWithFormat:@"Description:"];
    self.descLbl.font = [UIFont boldSystemFontOfSize:14];
    self.descLbl.backgroundColor = [UIColor clearColor];
    self.descLbl.textColor = [UIColor blackColor];
    [self.scrollView1 addSubview:self.descLbl];
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect frame;
    
    CGFloat descLabelHeight=[CommonMethods descriptionLabelHeight:fieldVal];
    if(orientation == UIDeviceOrientationPortrait)
    {
        
        frame = CGRectMake(10.0f, y+26, self.view.frame.size.width-10, descLabelHeight);
    }
    else
    {
        frame = CGRectMake(10.0f,y+26,self.view.frame.size.width-10,descLabelHeight);
    }
    
    self.label1=[[UILabel alloc]initWithFrame:frame];//:CGRectMake(10.0f, y+28, 296, 9999)];
    self.label1.textAlignment=NSTextAlignmentLeft;
    
    
    
    //self.label1.text=[NSString stringWithFormat:@"%@",fieldVal];
    self.label1.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.label1.backgroundColor = [UIColor clearColor];
    self.label1.textColor = [UIColor blackColor];
    //
    if (fieldVal == nil || [fieldVal isEqualToString:@"Emp"] || IsEmpty(fieldVal)) {
        self.label1.text=@"";
    }
    else
    {
        //self.label1.text= @"sdfbjdfb fdsgfgGHSHhdgfjdsgfsdhgfjhsdgfgd  dg hghdgf df fgshgfsgedfuisd gf sfg sgdfsgd  fdsgfgdfsdui gdf sdfgsd dgfshdgf sdfsdf sidfg fd ";
        
        self.label1.text=[NSString stringWithFormat:@"%@",fieldVal];
        
    }
//    [self.label1 resizeToFit];
    //accessibility
    if (fieldVal==nil) {
        self.label1.accessibilityLabel=@"Description";
    }
    else
    {
        self.label1.accessibilityLabel=[NSString stringWithFormat:@"Description %@",fieldVal];
    }
    self.label1.numberOfLines = 0;
    [self.label1 sizeToFit];
    self.label1.lineBreakMode = NSLineBreakByWordWrapping;
    [self.scrollView1 addSubview:self.label1];


    
    
    [self.scrollView1 setContentSize:CGSizeMake(self.view.frame.size.width,y+self.descLbl.frame.size.height+self.label1.frame.size.height+20)];
    //---------------------------------
    
    
    
    ////////////
    self.scrollView1.clipsToBounds=YES;
    
    
    
    //design call button
    if(!IsEmpty([self.carRecordFromFirstView phone]) && (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone))
    {
        CheckButton *callbutton=[CheckButton buttonWithType:UIButtonTypeCustom];
        callbutton.frame=CGRectMake(10,26, 60, 30); //95,20, 60, 30
        //[callbutton setImage:callImage forState:UIControlStateNormal];
        [callbutton addTarget:self action:@selector(callButtonTapped) forControlEvents:UIControlEventTouchUpInside];

        //[callbutton setBackgroundImage:[UIImage imageNamed:@"Call"] forState:UIControlStateNormal];
        
        callbutton.backgroundColor = [UIColor colorWithRed:146.0f/255.0f green:180.0f/255.0f blue:34.0f/255.0f alpha:1.0f];

        [callbutton setTitle:@"CALL" forState:UIControlStateNormal];
        [callbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        callbutton.layer.shadowRadius = 1.0f;
        callbutton.layer.shadowOpacity = 0.5f;
        callbutton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        callbutton.titleLabel.font = [UIFont boldSystemFontOfSize:12];

        
        
        [self.myListView addSubview:callbutton];
        
    }
    
    
    //
    
    self.viewGalleryBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.viewGalleryBtn.frame=CGRectMake(80, 26, 80, 30);
    [self.viewGalleryBtn addTarget:self action:@selector(galleryBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    //[self.viewGalleryBtn setBackgroundImage:[UIImage imageNamed:@"Gallery.png"] forState:UIControlStateNormal];
    ///___
    
    self.viewGalleryBtn.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self.viewGalleryBtn setTitle:@"GALLERY" forState:UIControlStateNormal];
    [self.viewGalleryBtn setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
    self.viewGalleryBtn.layer.shadowRadius = 1.0f;
    self.viewGalleryBtn.layer.shadowOpacity = 0.5f;
    self.viewGalleryBtn.layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.viewGalleryBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
   // [self.viewGalleryBtn setShowsTouchWhenHighlighted:YES];

    
    
    [self.viewGalleryBtn setHidden:YES]; //initially hide. unhide after getArrayOfCarPicUrls finds images
    [self.myListView addSubview:self.viewGalleryBtn];
    
    //
    self.featuresButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.featuresButton.frame=CGRectMake(170,26, 80, 30); //170 20 80 30
    [self.featuresButton addTarget:self action:@selector(featuresButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    //[self.featuresButton setBackgroundImage:[UIImage imageNamed:@"Features"] forState:UIControlStateNormal];
    
    self.featuresButton.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self.featuresButton setTitle:@"FEATURES" forState:UIControlStateNormal];
    [self.featuresButton setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
    self.featuresButton.layer.shadowRadius = 1.0f;
    self.featuresButton.layer.shadowOpacity = 0.5f;
    self.featuresButton.layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.featuresButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    // [self.viewGalleryBtn setShowsTouchWhenHighlighted:YES];

    
    
    [self.featuresButton setHidden:YES];
    //[self.featuresButton makeGlossy];
    [self.myListView addSubview:self.featuresButton];
    
    
    UIImage *mylistImage=[UIImage imageNamed:@"mylist2.png"];
    CGSize mylistImageSize=mylistImage.size;
    
    self.myListBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.myListBtn.frame=CGRectMake(254,30, mylistImageSize.width, mylistImageSize.height);
    [self.myListBtn setImage:mylistImage forState:UIControlStateNormal];
    [self.myListBtn addTarget:self action:@selector(myListBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.myListBtn setEnabled:YES];
    
    //accessibility
    self.myListBtn.isAccessibilityElement=YES;
    if (self.myListBtn.isEnabled) {
        self.myListBtn.accessibilityLabel=@"Add to my list";
    }
    else
    {
        self.myListBtn.accessibilityLabel=@"Added to my list";
    }
    [self.myListView addSubview:self.myListBtn];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tempImageView.frame=CGRectMake(self.view.frame.size.width/2-270/2,30,270,164);
    
   // [self.scrollView1 setContentSize:CGSizeMake(self.view.frame.size.width,y+self.descLbl.frame.size.height+self.label1.frame.size.height+20)];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(thumbnailDownloadOperationNotifMethod:) name:@"ThumbnailDownloadOperationNotif" object:nil];
    
    //setting thumbnail
    if([self.carRecordFromFirstView thumbnailUIImage]==nil)
    {
        //
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        ThumbnailDownloadOperation *thumbnailDownloadOperation=[[ThumbnailDownloadOperation alloc]init];
        
        thumbnailDownloadOperation.completeimagename1=[self.carRecordFromFirstView imagePath];
        
        
        [self.opQueue addOperation:thumbnailDownloadOperation];
    }
    else
    {
        self.carThumbnailImg=[self.carRecordFromFirstView thumbnailUIImage];
        [self.tempImageView setImage:self.carThumbnailImg];
        //[tempImageView setNeedsDisplay];
        
    }
    
    
    //////
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString *filename=[NSString stringWithFormat:@"favoritecars.plist"];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    if (success)
    {
        self.mArrayForPlist=[NSMutableArray arrayWithContentsOfFile:writablePath];
        
    }
        /////
    // read the plist array of dictionaries and check if tempCarid is already there
    self.found=NO;
    for (NSDictionary *tempDictionary in self.mArrayForPlist) {
        
        NSInteger carid=[[tempDictionary objectForKey:@"Carid"]integerValue];
        
        if (carid ==[self.carRecordFromFirstView carid]) {
            self.found=YES;
            break;
        }
    }
    
    ///
    if(self.found)
    {
        
        [self.myListBtn setImage:[UIImage imageNamed:@"mylist2-act.png"] forState:UIControlStateNormal];
        [self.myListBtn setEnabled:NO];
        self.myListBtn.accessibilityLabel=@"Added to my list";
    }
    else
    {
        [self.myListBtn setImage:[UIImage imageNamed:@"mylist2.png"] forState:UIControlStateNormal];
        [self.myListBtn setEnabled:YES];
        self.myListBtn.accessibilityLabel=@"Add to my list";
    }
    
    
    //preferences code starts
    //if this detailview is from PreferenceResults Table, we have to start a background thread to store this carid in appropriate preference dict plist file.
    
    //similary if this carid is NOT already in preference plist, put "NEW" label over somewhere
    
    if(self.fromPreferenceResults)
    {
        NSDictionary *dictionary=[NSDictionary dictionaryWithObjectsAndKeys:self.prefNameFromPrefResultsTable,@"PrefNameKey",[NSNumber numberWithInteger:[self.carRecordFromFirstView carid]],@"Carid", nil];
        
        [NSThread detachNewThreadSelector:@selector(putCarIdInPlist:) toTarget:self withObject:dictionary];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ThumbnailDownloadOperationNotif" object:nil];
    
    //we want to update carsNotSeen value in PreferenceTable. Hence we will call notif method from here
    if (self.prefNameFromPrefResultsTable!=nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CarNotSeenValChangedNotif" object:self userInfo:[NSDictionary dictionaryWithObject:self.prefNameFromPrefResultsTable forKey:@"PreferenceChangedKey"]];
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
#pragma mark - Rotation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration
{
    __weak DetailView *weakSelf=self;
    
    NSString *fieldVal=[[self.carRecordFromFirstView extraDescription] isEqualToString:@"Emp"]?nil:[self.carRecordFromFirstView extraDescription];
    if (fieldVal == nil || [fieldVal isEqualToString:@"Emp"] || IsEmpty(fieldVal)) {
        self.label1.text=@"";
    }
    else
    {
       
        
        self.label1.text=[NSString stringWithFormat:@"%@",fieldVal];
        
    }
    
    CGFloat descLabelHeight=[CommonMethods descriptionLabelHeight:fieldVal];
    
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.label1.frame = CGRectMake(10.0f,650,self.view.frame.size.width-10,descLabelHeight);  //your landscape frame
        
      
        
    }
    else
    {
        self.label1.frame = CGRectMake(10.0f, 650, self.view.frame.size.width-10, descLabelHeight); // your portrait frame
        
        
    }
    self.label1.numberOfLines = 0;
    [self.label1 sizeToFit];
    self.label1.lineBreakMode = NSLineBreakByWordWrapping;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            weakSelf.tempImageView.frame = CGRectMake(self.view.bounds.size.width/2-270/2,20,270,164);
        }
        else{
            weakSelf.tempImageView.frame=CGRectMake(self.view.frame.size.width/2-270/2,30,270,164);
        }
        
    });

    
    
    [self.scrollView1 setContentSize:CGSizeMake(self.view.frame.size.width,608.0+self.descLbl.frame.size.height+self.label1.frame.size.height+20)];

    
}

-(void)putCarIdInPlist:(NSDictionary *)dic
{
    // read plist file.
    NSString *pName=[dic objectForKey:@"PrefNameKey"];
    NSString *carid=[dic objectForKey:@"Carid"];
    
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    
    NSString *filename=[NSString stringWithFormat:@"%@.plist",pName];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    
    if (success) //this is always true because this method is called only when this detailview appears from pref results.
    {
        NSMutableDictionary *carDictionaryToSave=[[NSMutableDictionary alloc] initWithContentsOfFile:writablePath];
        
        //see if there is an array that represents the carids
        //key for that in dictionary is carIdsArray
        
        //if array is present, check this car is present in that array or not
        
        //if array is not present, store this car id in that array.
        
        NSMutableArray *carIdsArray=[carDictionaryToSave objectForKey:@"carIdsArray"];
        if (IsEmpty(carIdsArray)) {
            carIdsArray=[NSMutableArray array];
            [carIdsArray addObject:carid];
            
            [carDictionaryToSave setObject:carIdsArray forKey:@"carIdsArray"];
            
            //similarly update carsNotSeen entry also
            NSInteger totalCarsVal=[[carDictionaryToSave objectForKey:@"totalCars"] integerValue];
            NSInteger carsNotSeenVal;
            carsNotSeenVal=totalCarsVal-1;
            [carDictionaryToSave setObject:[NSNumber numberWithInteger:carsNotSeenVal] forKey:@"carsNotSeen"];
       
            
            [carDictionaryToSave writeToFile:writablePath atomically:YES];
            
            //showing "NEW" symbol
            
            UIImageView *tempIViewForNewCar=[[UIImageView alloc]initWithFrame:CGRectMake(250, 100, 50, 50)];
            self.iViewForNewCar=tempIViewForNewCar;
            tempIViewForNewCar=nil;
            [self.iViewForNewCar setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"new" ofType:@"png"]]];
            [self.tempImageView addSubview:self.iViewForNewCar];
            
            
        }
        else //that is the array is present
        {
            BOOL present=[carIdsArray containsObject:carid];
            
            
            if(!present)
            {
                //show "NEW" symbol and also add to array.
                //showing "NEW" symbol
                
                UIImageView *tempIViewForNewCar=[[UIImageView alloc]initWithFrame:CGRectMake(250, 100, 50, 50)];
                self.iViewForNewCar=tempIViewForNewCar;
                tempIViewForNewCar=nil;
                [self.iViewForNewCar setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"new" ofType:@"png"]]];
                [self.tempImageView addSubview:self.iViewForNewCar];
                
                
                //add to array
                [carIdsArray addObject:carid];
                
                [carDictionaryToSave setObject:carIdsArray forKey:@"carIdsArray"];
                
                //similarly update carsNotSeen entry also & resultReceived entry which is used in cellforrow of PreferenceTable
                NSInteger totalCarsVal=[[carDictionaryToSave objectForKey:@"totalCars"] integerValue];
                NSInteger carsNotSeenVal;
                carsNotSeenVal=totalCarsVal-[carIdsArray count];
                [carDictionaryToSave setObject:[NSNumber numberWithInteger:carsNotSeenVal] forKey:@"carsNotSeen"];
                
                
                [carDictionaryToSave writeToFile:writablePath atomically:YES];
                
                
            }
        }
    }
    else
    {
        NSLog(@"file does not exists at path in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        
    }
    
}


-(void)thumbnailDownloadOperationNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(thumbnailDownloadOperationNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    //[self hideActivityViewer];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.carThumbnailImg=[[notif userInfo]valueForKey:@"ThumbnailDownloadOperationNotifKey"];
    
    
    // now update the imageview outlet
    [self.tempImageView setImage:self.carThumbnailImg];
    [self.tempImageView setNeedsDisplay];
    
    //also update the actual car record, so that viewwillappear will not call download thumbnail repeatedly
    
    
    self.carRecordFromFirstView.thumbnailUIImage=self.carThumbnailImg;
    
    
    //also update the incomming carrecord in home,search or pref screen
    if (self.delegate && [self.delegate respondsToSelector:@selector(thumbnailDidDownloadedInDetailView:forCarRecord:)]) {
        [self.delegate thumbnailDidDownloadedInDetailView:self forCarRecord:self.carRecordFromFirstView];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 10) ? NO : YES;
}

#pragma mark - Webview Delegate Methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    
    //check if a html link is clicked
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        
        //get url from request
        NSURL *url=[request URL];
        
        //get the url scheme i.e., http or https or ftp or objc (in our case)
        
        if ([[url scheme] isEqualToString:@"obj"]) {
            //get a hold of webview so that we can use it later
            //            self.myWebView=webView;
            
            //we get the host part of url and use it as our method that we execute
            SEL method=NSSelectorFromString([url host]);
            //now execute that method
            if ([self respondsToSelector:method]) {
                [self performSelector:method withObject:nil afterDelay:0.1f];
                
            }
            return NO;
        }
    }
    return YES;
}

- (void)handleDoesNotRespondToSelectorError
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Data could not be retrieved as MobiCarz server is down." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
#warning here added images new link
    
//http://images.mobicarz.com
    for (int i=0; i<[imageNames count]; i++) {
        
        
        if (![[self.imagesDictionary objectForKey:[imageNames objectAtIndex:i]] isEqualToString:@"Emp"]) {
            completeimagename1=[[NSString alloc]initWithFormat:@"http://images.mobicarz.com/%@%@",[self.imagesDictionary objectForKey:[imageDirs objectAtIndex:i]],[self.imagesDictionary objectForKey:[imageNames objectAtIndex:i]]];
            
            completeimagename1=[completeimagename1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.arrayOfCarPicUrls addObject:completeimagename1];
            completeimagename1=nil;
            
        }
        else
            break;
    }
    
    if([self.arrayOfCarPicUrls count]>0)
    {
        [self.viewGalleryBtn setHidden:NO];
    }
    
}

-(void)retrieveUrlsAndImages
{
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    

# warning Modified New web service_17/06/2014 FindCarID(gallery)
    
NSString *brandID = @"2";
     NSString *webServiceUrl=[NSString stringWithFormat:@"http://test1.unitedcarexchange.com/MobileService/GenericServices.svc/GenericFindCarID/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@",[self.carRecordFromFirstView carid],retrieveduuid,brandID];
    
    

    
    
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
    
    __weak DetailView *weakSelf=self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
               
        weakSelf.imagesDictionary=[[NSMutableDictionary alloc]init];
        
        NSError *error;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        
        
        NSArray *findCarIDResult=[wholeResult objectForKey:@"GenericFindCarIDResult"];
        
        if([findCarIDResult respondsToSelector:@selector(objectAtIndex:)])
        {
            
            
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
            [self handleDoesNotRespondToSelectorError];
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
    operation=nil;
    
}

#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    int num=0;
    if( gallery == self.networkGallery ) {
        num = [self.arrayOfCarPicUrls count];
    }
	return num;
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}



- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [self.arrayOfCarPicUrls objectAtIndex:index];
}

#pragma mark - Private Methods
- (void)phoneLblTapped:(id)sender
{
    //see if the device can actually make a call
    NSString *phonenum=[NSString stringWithFormat:@"tel://+1%@",[self.carRecordFromFirstView phone]];
    if([self canDevicePlaceAPhoneCall])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenum]];
    }
    
    else
    {
        NSString *msg=[NSString stringWithFormat:@"This device cannot place a call now. Use another phone to call the seller at %@.",[self formattedPhoneNumber]];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Device Cannot Call Now" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
    
}


-(void)dealloc
{
    [_carDescription removeFromSuperview];
    [_CondDesp removeFromSuperview];
    [_myListBtn removeFromSuperview];
    [_iViewForNewCar removeFromSuperview];
    
    _CondDesp=nil;
    _carDescription=nil;
    _carDetailLabelsArray=nil;
    _cardetailarray2=nil;
    _cardetailarray3=nil;
    _featuresArray=nil;
    _iViewForNewCar=nil;
    _gestureRecognizer1=nil;
    _mArrayForPlist=nil;
    
    _carThumbnailImg=nil;
    
    _opQueue=nil;
    _myListBtn=nil;
    _featuresButton=nil;
    _viewGalleryBtn=nil;
    
    
    [_emailButton setDelegate:nil];
    [_emailButton stopLoading];
    [_emailButton.scrollView setDelegate:nil];
    [_emailButton removeFromSuperview];
    _emailButton=nil;
    
    _imagesDictionary=nil;
    _arrayOfCarPicUrls=nil;
    
    _networkGallery=nil;
    
    _tempImageView=nil;
    _scrollView1=nil;
    _myListView=nil;
    _carRecordFromFirstView=nil;
    _prefNameFromPrefResultsTable=nil;
    
    _activityImageView=nil;
    _showActivityViewerImage=nil;
    _activityWheel=nil;
    
    _queue=nil;
    
    
}

@end
