//
//  MyListDetailView.m
//  XMLTable2
//
//  Created by Mac on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyListDetailView.h"
#import "CarRecord.h"
#import "ThumbnailDownloadOperation.h"
#import "CheckButton.h"
//for dialing a number
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "UIButton+Glossy.h"
#import "EmailTheSeller.h"
#import "Features.h"
#import "AFNetworking.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

#import "CommonMethods.h"


#import "UILabel+dynamicSizeMe.h"

#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


@interface MyListDetailView()
@property(strong,nonatomic) UIAlertView *carDeletedAlert,*serverErrorAlert;

@property(strong,nonatomic) UITapGestureRecognizer *gestureRecognizer1;


@property(strong,nonatomic) NSOperationQueue *opQueue;
@property(strong,nonatomic) CheckButton *myListBtn,*featuresButton;
@property(strong,nonatomic) CarRecord *downloadedCarRecord;


@property(strong,nonatomic) dispatch_queue_t queue;
@property(assign,nonatomic) NSInteger tempCarid;

@property(assign,nonatomic) BOOL featuresFound;
@property(strong,nonatomic) NSArray *featuresArray;

@property(strong,nonatomic) CheckButton *viewGalleryBtn;
@property(strong,nonatomic) UIWebView *emailButton;

//gallery
@property(strong,nonatomic) NSMutableDictionary *imagesDictionary;
@property(strong,nonatomic) NSMutableArray *arrayOfCarPicUrls;
@property(strong,nonatomic) FGalleryViewController *networkGallery;


@property(strong,nonatomic) UILabel *label1,*descLbl;

- (void)handleDoesNotRespondToSelectorError;
-(void)retrieveUrlsAndImages;

@end


@implementation MyListDetailView
@synthesize tempImageView=_tempImageView,scrollView1=_scrollView1,gestureRecognizer1=_gestureRecognizer1,callView=_callView;



@synthesize carDeletedAlert=_carDeletedAlert,serverErrorAlert=_serverErrorAlert;

@synthesize opQueue=_opQueue,myListBtn=_myListBtn,queue=_queue,tempCarid=_tempCarid;

@synthesize downloadedCarRecord=_downloadedCarRecord,featuresFound=_featuresFound,featuresArray=_featuresArray,featuresButton=_featuresButton;

@synthesize imagesDictionary=_imagesDictionary,arrayOfCarPicUrls=_arrayOfCarPicUrls,viewGalleryBtn=_viewGalleryBtn,networkGallery=_networkGallery;

@synthesize emailButton=_emailButton,backgroundImageView=_backgroundImageView;

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
    aLabel.textColor=[UIColor blackColor];
    aLabel.backgroundColor=[UIColor clearColor];
    
    return aLabel;
}


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
    if(self.downloadedCarRecord==nil || ([[self.downloadedCarRecord phone] length]==0))
        return nil;
    
    NSRange r1=NSMakeRange(0, 3);
    NSRange r2=NSMakeRange(3, 3);
    NSRange r3=NSMakeRange(6, 4);
    NSString *s1=[NSString stringWithFormat:@"(%@) ",[[self.downloadedCarRecord phone] substringWithRange:r1]];
    
    NSString *s2=[s1 stringByAppendingString:[[self.downloadedCarRecord phone] substringWithRange:r2]];
    
    NSString *s3=[NSString stringWithFormat:@"%@-%@",s2,[[self.downloadedCarRecord phone] substringWithRange:r3]];
    s1=nil;
    s2=nil;
    return s3;
}



-(void)callButtonTapped
{
    NSString *callServiceStr=nil;
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    
    callServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/SaveCallRequestMobile/0/%d/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",[self.downloadedCarRecord carid],[self.downloadedCarRecord phone],retrieveduuid];
    
    
    
    //call callservice with 0 as user phone number
    //callServiceStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/MobileService/Service.svc/SaveCallRequestMobile/0/%d/%@/",[self.downloadedCarRecord carid],[self.downloadedCarRecord phone]];
    
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
    NSString *phonenum=[NSString stringWithFormat:@"tel://+1%@",[self.downloadedCarRecord phone]];
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


-(void)imageViewTapped:(UITapGestureRecognizer*)gestRecognizer
{
    if (![self.viewGalleryBtn isHidden]) {
        self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        self.networkGallery.carRecord=self.downloadedCarRecord;
        [self.navigationController pushViewController:self.networkGallery animated:YES];
    }
}

-(void)galleryBtnTapped
{
    self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    self.networkGallery.carRecord=self.downloadedCarRecord;
    [self.navigationController pushViewController:self.networkGallery animated:YES];
}

-(void)emailButtonTapped
{
    [self performSegueWithIdentifier:@"EmailScrollviewSegueFromMyListDetailView" sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EmailScrollviewSegueFromMyListDetailView"])
    {
        
        EmailTheSeller *emailTheSeller=[segue destinationViewController];
        
        emailTheSeller.carRecordFromDetailView=self.downloadedCarRecord;
        
        //carRecord=nil;
    }
    else if([segue.identifier isEqualToString:@"FeaturesSegueFromMyListDetailView"])
    {
        Features *features=[segue destinationViewController];
        features.allFeaturesFromDetailView=self.featuresArray;
        
        NSString *navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.downloadedCarRecord year],[self.downloadedCarRecord make],[self.downloadedCarRecord model]];
        features.navTitle=navTitle;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    self.tempImageView.image=nil;
}


-(void)backToResultsButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)checkForFeatures
{
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSString *featuresServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetCarFeatures/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/",[self.downloadedCarRecord carid],retrieveduuid];
    
    
    // NSString *featuresServiceStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/MobileService/Service.svc/GetCarFeatures?sCarId=%d",[self.downloadedCarRecord carid]];
    
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
    
    __weak MyListDetailView *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        if(error2==nil)
        {
            
            weakSelf.featuresArray=[wholeResult objectForKey:@"GetCarFeaturesResult"];
            
            if([weakSelf.featuresArray respondsToSelector:@selector(objectAtIndex:)] && weakSelf.featuresArray.count)
            {
                weakSelf.featuresFound=YES;
                
                [weakSelf.featuresButton setHidden:NO];
            }
            else
            {
                [weakSelf.featuresButton setHidden:YES];
                
                NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error2);
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
        
        //weakSelf.HTTPErroCodeNum=[error code];
    }];
    
    [self.opQueue addOperation:operation];
    //operation=nil;
    
}

-(void)featuresButtonTapped
{
    //call segue here
    [self performSegueWithIdentifier:@"FeaturesSegueFromMyListDetailView" sender:nil];
}

-(BOOL)loadFromCacheIfPresent
{
    BOOL success;
    __block BOOL loadedFromCache=NO;
    
    //      NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename=[NSString stringWithFormat:@"favoritecars.plist"];
    
    NSString *writablePath = [dbPath stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writablePath];
    
    
    
    NSArray *mArrayForPlist=nil;
    if (success)
    {
        mArrayForPlist=[NSMutableArray arrayWithContentsOfFile:writablePath];
        
    }
    else
    {
        NSLog(@"file does not exists at path, %@ in %@:%@",writablePath,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
    __block NSString  *jpgPath1;
    [mArrayForPlist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dictionary=(NSDictionary *)obj;
        NSInteger carid=[[dictionary objectForKey:@"Carid"]integerValue];
        if (carid==[self.downloadedCarRecord carid]) {
            
            //see if thumbnail is present
            NSString *dbPathForThumbnail = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *cachesDir=[dbPathForThumbnail stringByAppendingPathComponent:@"Caches"];
            
            NSString *thumbnailDir = [NSString stringWithFormat:@"%@/MyListThumbnails",cachesDir];
            //NSError *error = nil;
            BOOL isDir=YES;
            if([fileManager fileExistsAtPath:thumbnailDir isDirectory:&isDir] && isDir)
            {
                //get file path
                jpgPath1=[NSString stringWithFormat:@"%@/%d.jpg",thumbnailDir,carid];
                
                if ([fileManager fileExistsAtPath:jpgPath1])
                {
                    loadedFromCache=YES;
                }
                
            }
            *stop=YES;
        }
    }];
    
    
    //thumbnail exists. so load this thumbnail
    if (loadedFromCache) {
        [self.tempImageView setImage:[UIImage imageWithContentsOfFile:jpgPath1]];
        [self.tempImageView setNeedsDisplay];
    }
    
    return loadedFromCache;
}

- (void)displayData
{
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    
    
    NSString *navTitle=nil;
        if(self.downloadedCarRecord!=nil)
        {
            navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.downloadedCarRecord year],[self.downloadedCarRecord make],[self.downloadedCarRecord model]];
        }
    
    navtitle.text=navTitle;

     //
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView= navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;
    
    
    self.opQueue=[[NSOperationQueue alloc]init];
    [self.opQueue setName:@"MyListDetailViewQueue"];
    [self.opQueue setMaxConcurrentOperationCount:3];
    
    
    //check if features are present or not
    [self checkForFeatures];
    
    [self retrieveUrlsAndImages];
    
    
    if(self.downloadedCarRecord!=nil)
    {
        if(![self loadFromCacheIfPresent])
        {
            
            ThumbnailDownloadOperation *thumbnailDownloadOperation=[[ThumbnailDownloadOperation alloc]init];
            thumbnailDownloadOperation.completeimagename1=[self.downloadedCarRecord imagePath];
            
            
            [self.opQueue addOperation:thumbnailDownloadOperation];
        }
    }
    // setting gesture recognizer for tempimageview
    
    self.tempImageView.tag=[[NSString stringWithFormat:@"%d",[self.downloadedCarRecord carid]]integerValue];
    
    self.gestureRecognizer1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    
    [self.tempImageView addGestureRecognizer:self.gestureRecognizer1];
    //accessibility
    self.tempImageView.isAccessibilityElement=YES;
    self.tempImageView.accessibilityLabel=navTitle;
    
    
    
      //
    UILabel *label;
    CGFloat lWidth;
    CGFloat y=40.0+self.tempImageView.frame.size.height+self.callView.frame.size.height;
    
    NSString *labelStringForFindingWidth,*fieldVal,*labelString;
    
    
    label=[[UILabel alloc]init];
    labelString=@"Email:";
    lWidth=[CommonMethods findLabelWidth:labelString];
    [label setFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    [label setTextColor:[UIColor blackColor]];
    label.backgroundColor=[UIColor clearColor];
    [self.scrollView1 addSubview:[self addPropertiesToMyLabel:label withText:labelString withBold:YES]];
    label=nil;
    
    
    UIWebView *tempEmailButton=[[UIWebView alloc]initWithFrame:CGRectMake([CommonMethods findLabelWidth:@"Email:"]+4, self.tempImageView.frame.size.height+self.callView.frame.size.height+32, 200, 25)]; //when using as button give y as 8
    self.emailButton=tempEmailButton;
    tempEmailButton=nil;
    self.emailButton.opaque=NO;
    [self.emailButton setBackgroundColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    //if the email field is not Emp, show the webview, other wise hide it
    NSString *testString = @"<a href = \"obj://emailButtonTapped\"><font color=' #f95446'>Send email to seller</color></a>";
    [self.emailButton loadHTMLString:testString baseURL:nil];
    self.emailButton.delegate=self;
    self.emailButton.scrollView.scrollEnabled = NO;
    self.emailButton.backgroundColor=[UIColor clearColor];
    
    //    emailLabel.font=[UIFont boldSystemFontOfSize:17];
    if(![[self.downloadedCarRecord email] isEqualToString:@"Emp"])
    {
        [self.scrollView1 addSubview:self.emailButton];
        
    }
    
    NSNumberFormatter *priceFormatter=[CommonMethods sharedPriceFormatter];
    
    NSString *priceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:[self.downloadedCarRecord price]]];
    
    
    if([self.downloadedCarRecord price] ==0)
    {
        priceVal=@"";
    }
    
    y+=20;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Price:",priceVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Price:" secondText:priceVal];
    label.backgroundColor=[UIColor clearColor];
    //label.textColor = [UIColor whiteColor];
    
    //accessibility
    if ([self.downloadedCarRecord price] ==0) {
        label.accessibilityLabel=@"Price";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Price %d",[self.downloadedCarRecord price]];
    }
    
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[[self.downloadedCarRecord sellerType] isEqualToString:@"Emp"]?nil:[self.downloadedCarRecord sellerType];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Seller Type:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Seller Type:" secondText:fieldVal];
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
    
    //
    y+=20;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@  ",@"Phone:"]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Phone:" secondText:nil];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (IsEmpty([self.downloadedCarRecord phone])||[[self.downloadedCarRecord phone] isEqualToString:@"Emp"]) {
        label.accessibilityLabel=@"Phone";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Phone %@",[self.downloadedCarRecord phone]];
    }
    
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    NSString *phoneStr=  [NSString stringWithFormat:@"%@",[self.downloadedCarRecord phone]];
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
    if(![[self.downloadedCarRecord city] isEqualToString:@"Emp"])
    {
        addressStr=[NSString stringWithFormat:@"%@",[[self.downloadedCarRecord city] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    if(![[self.downloadedCarRecord state] isEqualToString:@"Emp"])
    {
        if (!IsEmpty(addressStr)) {
            addressStr=[NSString stringWithFormat:@"%@, %@",addressStr,[self.downloadedCarRecord state]];
        }
        else
        {
            addressStr=[NSString stringWithFormat:@"%@",[self.downloadedCarRecord state]];
        }
    }
    if(![[self.downloadedCarRecord zipCode] isEqualToString:@"Emp"])
    {
        if (!IsEmpty(addressStr)) {
            addressStr=[NSString stringWithFormat:@"%@ %@",addressStr,[self.downloadedCarRecord zipCode]];
        }
        else
        {
            addressStr=[NSString stringWithFormat:@"%@",[self.downloadedCarRecord zipCode]];
        }
    }
    
    fieldVal=addressStr;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Address:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Address:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    if (fieldVal==nil) {
        label.accessibilityLabel=@"Address";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Address %@",fieldVal];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord make];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Make:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Make:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Make %@",[self.downloadedCarRecord make]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord model];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Model:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Model:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Model %@",[self.downloadedCarRecord model]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[NSString stringWithFormat:@"%d",[self.downloadedCarRecord year]];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Year:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Year:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Year %d",[self.downloadedCarRecord year]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord exteriorColor];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Exterior Color:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Exterior Color:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Exterior Color %@",[self.downloadedCarRecord exteriorColor]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord interiorColor];
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Interior Color:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Interior Color:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Interior Color %@",[self.downloadedCarRecord interiorColor]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord numberOfDoors];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Doors:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Doors:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Doors %@",[self.downloadedCarRecord numberOfDoors]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord ConditionDescription];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Vehicle Condition:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Vehicle Condition:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Vehicle Condition %@",[self.downloadedCarRecord ConditionDescription]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    //mileage formatter
    NSNumberFormatter *mileageFormatter=[CommonMethods sharedMileageFormatter];
    
    NSString *mileageString = [mileageFormatter stringFromNumber:[NSNumber numberWithInteger:[self.downloadedCarRecord mileage]]];
    
    NSString *mileageStr= [NSString stringWithFormat:@"%@ mi",mileageString];
    if([self.downloadedCarRecord mileage]==0)
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
        label.accessibilityLabel=[NSString stringWithFormat:@"Mileage %d",[self.downloadedCarRecord mileage]];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord fueltype];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Fuel:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Fuel:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Fuel %@",[self.downloadedCarRecord fueltype]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord transmission];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Transmission:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Transmission:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Transmission %@",[self.downloadedCarRecord transmission]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord driveTrain];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Drive Train:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Drive Train:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Drive Train %@",[self.downloadedCarRecord driveTrain]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord engineCylinders];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@  ",@"Engine Cylinders:",fieldVal]; //add 2 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=NSTextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Engine Cylinders:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Engine Cylinders %@",[self.downloadedCarRecord engineCylinders]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[[self.downloadedCarRecord vin] isEqualToString:@"Emp"]?nil:[self.downloadedCarRecord vin];
    
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
        label.accessibilityLabel=[NSString stringWithFormat:@"Vin %@",[self.downloadedCarRecord vin]];
    }
    label.textColor = [UIColor blackColor];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    fieldVal=[[self.downloadedCarRecord extraDescription] isEqualToString:@"Emp"]?nil:[self.downloadedCarRecord extraDescription];
    y+=20;
    
    
    _descLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, 100, 30)];
    _descLbl.textAlignment=NSTextAlignmentLeft;
    _descLbl.text=[NSString stringWithFormat:@"Description:"];
    _descLbl.font = [UIFont boldSystemFontOfSize:14];
    _descLbl.backgroundColor = [UIColor clearColor];
    _descLbl.textColor = [UIColor blackColor];
    [self.scrollView1 addSubview:_descLbl];
    
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
    
    [label resizeToFit];
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
    
    
    [self.scrollView1 setContentSize:CGSizeMake(self.view.frame.size.width,y+_descLbl.frame.size.height+self.label1.frame.size.height+20)];
    //---------------------------------
    
    
    self.scrollView1.clipsToBounds=YES;
    [self.scrollView1 setShowsVerticalScrollIndicator:YES];
    
    
    //design call button
    if(!IsEmpty([self.downloadedCarRecord phone]) && (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone))
    {

        
        CheckButton *callbutton=[CheckButton buttonWithType:UIButtonTypeCustom];
        callbutton.frame=CGRectMake(16,26, 70, 30); //95,20, 60, 30
        //[callbutton setImage:callImage forState:UIControlStateNormal];
        [callbutton addTarget:self action:@selector(callButtonTapped) forControlEvents:UIControlEventTouchUpInside];
         // [callbutton setBackgroundImage:[UIImage imageNamed:@"Call"] forState:UIControlStateNormal];
        callbutton.backgroundColor = [UIColor colorWithRed:146.0f/255.0f green:180.0f/255.0f blue:34.0f/255.0f alpha:1.0f];

        [callbutton setTitle:@"CALL" forState:UIControlStateNormal];
        [callbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //Button with 0 border so it's shape like image shape
        callbutton.layer.shadowRadius = 1.0f;
        callbutton.layer.shadowOpacity = 0.5f;
        callbutton.layer.shadowOffset = CGSizeZero;
        //Font size of title
        callbutton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        //[callbutton makeGlossy];
        [self.callView addSubview:callbutton];
    }
    
    self.viewGalleryBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.viewGalleryBtn.frame=CGRectMake(102, 26, 90, 30);
    //[viewGalleryBtn setImage:viewGalleryImage forState:UIControlStateNormal];
    [self.viewGalleryBtn addTarget:self action:@selector(galleryBtnTapped) forControlEvents:UIControlEventTouchUpInside];
   // [self.viewGalleryBtn setBackgroundImage:[UIImage imageNamed:@"Gallery.png"] forState:UIControlStateNormal];
    
    self.viewGalleryBtn .backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self.viewGalleryBtn  setTitle:@"GALLERY" forState:UIControlStateNormal];
    [self.viewGalleryBtn  setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
    self.viewGalleryBtn .layer.shadowRadius = 1.0f;
    self.viewGalleryBtn .layer.shadowOpacity = 0.5f;
    self.viewGalleryBtn .layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.viewGalleryBtn .titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    [self.viewGalleryBtn setHidden:YES]; //initially hide. unhide after getArrayOfCarPicUrls finds images
    [self.callView addSubview:self.viewGalleryBtn];
    
    
    //
    self.featuresButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.featuresButton.frame=CGRectMake(210,26, 90, 30); //170 20 80 30
    [self.featuresButton addTarget:self action:@selector(featuresButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    //[self.featuresButton setBackgroundImage:[UIImage imageNamed:@"Features"] forState:UIControlStateNormal];
    
    self.featuresButton .backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self.featuresButton  setTitle:@"FEATURES" forState:UIControlStateNormal];
    [self.featuresButton  setTitleColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
    self.featuresButton .layer.shadowRadius = 1.0f;
    self.featuresButton .layer.shadowOpacity = 0.5f;
    self.featuresButton .layer.shadowOffset = CGSizeZero;
    //Font size of title
    self.featuresButton .titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    
    [self.featuresButton setHidden:YES];
    [self.callView addSubview:self.featuresButton];
    
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
    ////[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    
   // if (self.tempImageView==nil) {
//        self.backgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//        [self.backgroundImageView setImage:[UIImage imageNamed:@"back.png"]];
//        [self.backgroundImageView setUserInteractionEnabled:YES];
//        [self.view addSubview:self.backgroundImageView];
//        //autolayout constraints
//        UIView *superview = self.view;
//        [self.backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        NSLayoutConstraint *avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
//        [self.view addConstraint:avAConstraint1]; //left of av
//        
//        
//        
//        avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
//        [self.view addConstraint:avAConstraint1]; //right of av
//        
//        avAConstraint1= [NSLayoutConstraint constraintWithItem:self.backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//        [self.view addConstraint:avAConstraint1]; //bottom of av
//        
//        
//        avAConstraint1 =
//        [NSLayoutConstraint constraintWithItem:self.backgroundImageView
//                                     attribute:NSLayoutAttributeTop
//                                     relatedBy:0
//                                        toItem:self.view
//                                     attribute:NSLayoutAttributeTop
//                                    multiplier:1
//                                      constant:0];
//        
//        [self.view addConstraint:avAConstraint1]; //top of av to top of self.view
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

        
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.scrollView1=[[UIScrollView alloc] init];//WithFrame:CGRectMake(0,self.tempImageView.frame.size.height+self.callView.frame.size.height,self.view.frame.size.width,150)];
        
        //
        self.scrollView1.showsVerticalScrollIndicator=YES;
        self.scrollView1.scrollEnabled=YES;
        self.scrollView1.userInteractionEnabled=YES;
        
       // self.backgroundImageView.backgroundColor=[UIColor clearColor];
        self.scrollView1.backgroundColor=[UIColor clearColor];
        
        [self.view addSubview:self.scrollView1];
        //autolayout
        [self.scrollView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        [self.view addConstraint:scrollView1Constraint];
        
        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [self.view addConstraint:scrollView1Constraint];
        
//        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
//        [self.backgroundImageView addConstraint:scrollView1Constraint];
//        
//        scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//        [self.backgroundImageView addConstraint:scrollView1Constraint];
        
        
        
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
            
            //load resources for earlier versions
            scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
            [self.view addConstraint:scrollView1Constraint];
            
            scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [self.view addConstraint:scrollView1Constraint];
            
            
        } else {
            
            
//            CGRect rect;
//            
//            rect = [[UIApplication sharedApplication] statusBarFrame];
            
            // from inside the view controller
            CGSize tabBarSize = [[[self tabBarController] tabBar] bounds].size;
            
            
            //load resources for iOS 7
            
            
            scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationController.navigationBar.frame.size.height];
            //+rect.size.height
            [self.view addConstraint:scrollView1Constraint];
            
            scrollView1Constraint=[NSLayoutConstraint constraintWithItem:self.scrollView1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-tabBarSize.height];
            [self.view addConstraint:scrollView1Constraint];
           
            
        }
        
        
      //  self.tempImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,163)];
        self.tempImageView=[[UIImageView alloc] init];
        self.tempImageView.frame=CGRectMake(self.view.frame.size.width/2-270/2,30,270,164);
        self.tempImageView.contentMode=UIViewContentModeScaleAspectFit;
        [self.tempImageView setUserInteractionEnabled:YES];
        [self.scrollView1 addSubview:self.tempImageView];
        //
        self.callView=[[UIImageView alloc] initWithFrame:CGRectMake(0,self.tempImageView.frame.size.height+20,self.view.frame.size.width,54)];
        [self.callView setUserInteractionEnabled:YES];
        [self.callView setBackgroundColor:[UIColor clearColor]];
        [self.scrollView1 addSubview:self.callView];
        //
        
        
   // }
    
    ///
   if (self.downloadedCarRecord.make!=nil) {
        
        [self displayData];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tempImageView.frame=CGRectMake(self.view.frame.size.width/2-270/2,30,270,164);

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CarRecordFromDownloadCarRecordOperationNotifMethod:) name:@"CarRecordFromDownloadCarRecordOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noCarForThisIdNotifMethod:) name:@"NoCarForThisIdNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(thumbnailDownloadOperationNotifMethod:) name:@"ThumbnailDownloadOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(errorDownloadingCarRecordNotifMethod:) name:@"ErrorDownloadingCarRecordNotif" object:nil];
    
    [self.myListBtn setEnabled:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CarRecordFromDownloadCarRecordOperationNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NoCarForThisIdNotif" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ThumbnailDownloadOperationNotif" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ErrorDownloadingCarRecordNotif" object:nil];
    
    [super viewWillDisappear:animated];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration
{
    
  
    __weak MyListDetailView *weakSelf=self;
    
    NSString *fieldVal=[[self.downloadedCarRecord extraDescription] isEqualToString:@"Emp"]?nil:[self.downloadedCarRecord extraDescription];
    if (fieldVal == nil || [fieldVal isEqualToString:@"Emp"] || IsEmpty(fieldVal)) {
        self.label1.text=@"";
    }
    else
    {
        //self.label1.text= @"sdfbjdfb fdsgfgGHSHhdgfjdsgfsdhgfjhsdgfgd  dg hghdgf df fgshgfsgedfuisd gf sfg sgdfsgd  fdsgfgdfsdui gdf sdfgsd dgfshdgf sdfsdf sidfg fd ";
        
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
    
    [self.scrollView1 setContentSize:CGSizeMake(self.view.frame.size.width,608.0+_descLbl.frame.size.height+self.label1.frame.size.height+20)];
    
}

#pragma mark Notification Methods

-(void)CarRecordFromDownloadCarRecordOperationNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(CarRecordFromDownloadCarRecordOperationNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        self.downloadedCarRecord=[[notif userInfo] valueForKey:@"DownloadCarRecordOperationResults"];
        
        [self displayData]; // re execute displayData as the notification method is executed after view is loaded
        
        //check if features are present or not
        [self checkForFeatures];
    }
}

#pragma mark -
#pragma mark Delegate Methods

-(void)thumbnailDownloadOperationNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(thumbnailDownloadOperationNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    UIImage *anImage=[[notif userInfo]valueForKey:@"ThumbnailDownloadOperationNotifKey"];
    
    // now update the imageview outlet
    [self.tempImageView setImage:anImage];
    [self.tempImageView setNeedsDisplay];
    
    
    //also update the actual car record, so that viewwillappear will not call download thumbnail repeatedly
    self.downloadedCarRecord.thumbnailUIImage=anImage;
    anImage=nil;
    
    //save this thumbnail in cache for future use
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *cachesDir=[dbPath stringByAppendingPathComponent:@"Caches"];
    
    
    self.queue=dispatch_queue_create("QueueToSaveThumbnailInMyListDetailView", NULL);
    
    dispatch_async(self.queue, ^{
        
        //get mylistthumbnails dir path
        
        NSString *thumbnailDir = [NSString stringWithFormat:@"%@/MyListThumbnails",cachesDir];
        NSError *error = nil;
        BOOL isDir=YES;
        if(!([fileManager fileExistsAtPath:thumbnailDir isDirectory:&isDir] && isDir))
            if(![fileManager createDirectoryAtPath:thumbnailDir withIntermediateDirectories:YES attributes:nil error:&error])
                NSLog(@"Error: Create folder failed in MyListDetailView:thumbnailDownloadOperationNotifMethod");
        
        //save image data to file
        NSData *imgDataToSave = UIImageJPEGRepresentation(self.downloadedCarRecord.thumbnailUIImage, 1); // convert to jpeg
        
        //get file path
        NSString  *jpgPath1=[NSString stringWithFormat:@"%@/%d.jpg",thumbnailDir,[self.downloadedCarRecord carid]];
        [imgDataToSave writeToFile:jpgPath1 atomically:YES];
        
    });
}

-(void)noCarForThisIdNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(noCarForThisIdNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        self.tempCarid=[[[notif userInfo] valueForKey:@"caridResultKey"]integerValue];
        
        UIAlertView *tempCarDeletedAlert=[[UIAlertView alloc]initWithTitle:@"No Car" message:@"This car was removed from our database.Do you want to delete it from My List?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        self.carDeletedAlert=tempCarDeletedAlert;
        tempCarDeletedAlert=nil;
        
        [self.carDeletedAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView isEqual:self.carDeletedAlert])
    {
        [self.navigationController popViewControllerAnimated:YES];
        
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"YES"])
        {
            //delete from my list. This code is already there in deleteCarFromMyList method of MyListCustomTable. Use that
            
            if (self.tempCarid!=0)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"DeleteCarFromMyListRemovedFromDatabaseNotif" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.tempCarid] forKey:@"carIdResultKey"]];
            }
        }
    }
    else if([alertView isEqual:self.serverErrorAlert])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TextField Delegate Method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return (newLength > 10) ? NO : YES;
}

-(void)errorDownloadingCarRecordNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(errorDownloadingCarRecordNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        //[self hideActivityViewer];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSError *error=[[notif userInfo]valueForKey:@"ErrorDownloadingCarRecordNotifKey"];
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        self.serverErrorAlert=[[UIAlertView alloc]init];;
        self.serverErrorAlert.delegate=self;
        [self.serverErrorAlert addButtonWithTitle:@"OK"];
        
        
        
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            
            self.serverErrorAlert.title=@"No Internet Connection";
            self.serverErrorAlert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==-1001)
        {
            self.serverErrorAlert.title=@"Error Occured";
            self.serverErrorAlert.message=@"The request timed out.";
        }
        else
        {
            self.serverErrorAlert.title=@"Server Error";
            self.serverErrorAlert.message=@"MobiCarz cannot retrieve data because of server error.";
        }
        
        [self.serverErrorAlert show];
    }
}

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
    
    if([self.arrayOfCarPicUrls count]>0)
    {
        [self.viewGalleryBtn setHidden:NO];
    }
    
}


-(void)retrieveUrlsAndImages
{
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/FindCarID/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",[self.downloadedCarRecord carid],retrieveduuid];
    
    //calling service
    // NSString *webServiceUrl=[NSString stringWithFormat: @"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/FindCarID/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",[self.downloadedCarRecord carid],retrieveduuid];
    
    
    
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
    
    __weak MyListDetailView *weakSelf=self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
               weakSelf.imagesDictionary=[[NSMutableDictionary alloc]init];
        
        NSError *error;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        
        
        NSArray *findCarIDResult=[wholeResult objectForKey:@"FindCarIDResult"];
        
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
        
        NSLog(@"call service failed with error = %@ in %@:%@",error,NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        
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
    NSString *phonenum=[NSString stringWithFormat:@"tel://+1%@",[self.downloadedCarRecord phone]];
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
    _carDeletedAlert=nil;
    _serverErrorAlert=nil;
    _gestureRecognizer1=nil;
    _opQueue=nil;
    _myListBtn=nil;
    _featuresButton=nil;
    _downloadedCarRecord=nil;
    _featuresArray=nil;
    _viewGalleryBtn=nil;
    _emailButton=nil;
    _imagesDictionary=nil;
    _arrayOfCarPicUrls=nil;
    _networkGallery=nil;
    _backgroundImageView=nil;
    _callView=nil;
    _tempImageView=nil;
    _scrollView1=nil;
    _queue=nil;
}

@end
