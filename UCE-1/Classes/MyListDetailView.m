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



@interface MyListDetailView()
@property(strong,nonatomic) UIAlertView *carDeletedAlert,*serverErrorAlert;

@property(strong,nonatomic) UITapGestureRecognizer *gestureRecognizer1;


@property(strong,nonatomic) NSOperationQueue *opQueue;
@property(strong,nonatomic) CheckButton *myListBtn,*featuresButton;
@property(strong,nonatomic) CarRecord *downloadedCarRecord;


@property(assign,nonatomic) dispatch_queue_t queue;
@property(assign,nonatomic) NSInteger tempCarid;

@property(assign,nonatomic) BOOL featuresFound;
@property(strong,nonatomic) NSArray *featuresArray;

@property(strong,nonatomic) CheckButton *viewGalleryBtn;
@property(strong,nonatomic) UIWebView *emailButton;

//gallery
@property(strong,nonatomic) NSMutableDictionary *individualcarscrolling;
@property(strong,nonatomic) NSMutableArray *arrayOfCarPicUrls;
@property(strong,nonatomic) FGalleryViewController *networkGallery;

- (void)handleDoesNotRespondToSelectorError;
-(void)retreiveUlsAndImages;

@end


@implementation MyListDetailView
@synthesize tempImageView=_tempImageView,scrollView1=_scrollView1,gestureRecognizer1=_gestureRecognizer1,callView=_callView;



@synthesize carDeletedAlert=_carDeletedAlert,serverErrorAlert=_serverErrorAlert;

@synthesize opQueue=_opQueue,myListBtn=_myListBtn,queue=_queue,tempCarid=_tempCarid;

@synthesize downloadedCarRecord=_downloadedCarRecord,featuresFound=_featuresFound,featuresArray=_featuresArray,featuresButton=_featuresButton;

@synthesize individualcarscrolling=_individualcarscrolling,arrayOfCarPicUrls=_arrayOfCarPicUrls,viewGalleryBtn=_viewGalleryBtn,networkGallery=_networkGallery;

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
    
    //NSLog(@"phone number before formatting: %@",[self.carDictionary objectForKey:@"_phone"]);
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
    
    //call callservice with 0 as user phone number
    callServiceStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/SaveCallRequestMobile/0/%d/%@/",[self.downloadedCarRecord carid],[self.downloadedCarRecord phone]];
    
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
        //NSLog(@"call service executed %@",callServiceStr);        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        //NSLog(@"call service failed %@",callServiceStr);
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
        [self.navigationController pushViewController:self.networkGallery animated:YES];
    }
}

-(void)galleryBtnTapped
{
    self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
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
        
        //NSLog(@"emailTheSeller.carRecordFromDetailView =%@ sellername=%@",self.downloadedCarRecord,[self.downloadedCarRecord sellerName]);
        
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
    NSString *featuresServiceStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/GetCarFeatures?sCarId=%d",[self.downloadedCarRecord carid]];
    
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
        
        //NSLog(@"download succeeded for car %d",num);
        //NSLog(@"response string is %@ response object is %@",[operation responseString],responseObject);
        
        //NSData *data=(NSData *)responseObject;
        NSData *data=[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
        if(error2==nil)
        {
            
            weakSelf.featuresArray=[wholeResult objectForKey:@"GetCarFeaturesResult"];
            
            if([weakSelf.featuresArray respondsToSelector:@selector(objectAtIndex:)] && weakSelf.featuresArray.count)
            {
                //NSLog(@"featuresArray count when sending notif =%d",[weakSelf.featuresArray count]);
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
        //NSLog(@"call service failed %@ error:%@ status code:%d userinfo dict=%@",callServiceStr,[error localizedDescription],[error code],[error userInfo]);
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
        //        NSLog(@"file already exists at path");
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
    //navigation bar title
    NSString *navTitle=nil;
    if(self.downloadedCarRecord!=nil)
    {
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.downloadedCarRecord year],[self.downloadedCarRecord make],[self.downloadedCarRecord model]];
    }
    
    
    UILabel *titleLabel=[[UILabel alloc]init];
    
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setText:navTitle];
    [titleLabel sizeToFit];
    [self.navigationItem setTitleView:titleLabel];
    titleLabel=nil;
    
    
    UIBarButtonItem *lb = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToResultsButtonTapped)];
    
    [self.navigationItem setLeftBarButtonItem:lb];
    lb=nil;
    
    
    self.opQueue=[[NSOperationQueue alloc]init];
    [self.opQueue setName:@"MyListDetailViewQueue"];
    [self.opQueue setMaxConcurrentOperationCount:3];
    
    
    //check if features are present or not
    [self checkForFeatures];
    
    [self retreiveUlsAndImages];
    
    
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
    
    
    
    /////
    
    UIImage *mylistImage=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"mylistAct2" ofType:@"png"]];
    CGSize mylistImageSize=mylistImage.size;
    UIImageView *myListImageView=[[UIImageView alloc] initWithImage:mylistImage];
    myListImageView.frame=CGRectMake(265,3, mylistImageSize.width, mylistImageSize.height);
    //accessibility
    myListImageView.isAccessibilityElement=YES;
    myListImageView.accessibilityLabel=@"My List";
    myListImageView.backgroundColor=[UIColor clearColor];
    [self.callView addSubview:myListImageView];
    
    
    //
    UILabel *label;
    CGFloat lWidth;
    CGFloat y=10.0f;
    
    NSString *labelStringForFindingWidth,*fieldVal,*labelString;
    
    
    label=[[UILabel alloc]init];
    labelString=@"Email:";
    lWidth=[CommonMethods findLabelWidth:labelString];
    [label setFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.backgroundColor=[UIColor clearColor];
    [self.scrollView1 addSubview:[self addPropertiesToMyLabel:label withText:labelString withBold:YES]];
    label=nil;
    
    
    UIWebView *tempEmailButton=[[UIWebView alloc]initWithFrame:CGRectMake([CommonMethods findLabelWidth:@"Email:"]+4, 2, 200, 25)]; //when using as button give y as 8
    self.emailButton=tempEmailButton;
    tempEmailButton=nil;
    self.emailButton.opaque=NO;
    [self.emailButton setBackgroundColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
    //i have created a dummy host which will be used as method name in uiwebview delegate method to trigger action
    //if the email field is not Emp, show the webview, other wise hide it
    NSString *testString = @"<a href = \"obj://emailButtonTapped\">Send email to seller</a>";
    [self.emailButton loadHTMLString:testString baseURL:nil];
    self.emailButton.delegate=self;
    self.emailButton.backgroundColor=[UIColor clearColor];
    
    //    emailLabel.font=[UIFont boldSystemFontOfSize:17];
    if(![[self.downloadedCarRecord email] isEqualToString:@"Emp"])
    {
        [self.scrollView1 addSubview:self.emailButton];
        
    }
    
    NSNumberFormatter  *priceFormatter=[[NSNumberFormatter alloc]init];
    [priceFormatter setLocale:[NSLocale currentLocale]];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter  setCurrencyGroupingSeparator:@","];
    [priceFormatter setMaximumFractionDigits:0];
    
    NSString *priceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:[self.downloadedCarRecord price]]];
    priceFormatter=nil;
    
    
    if([self.downloadedCarRecord price] ==0)
    {
        priceVal=@"";
    }
    
    y+=20;
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Price:",priceVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Price:" secondText:priceVal];
    label.backgroundColor=[UIColor clearColor];
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f+[CommonMethods findLabelWidth:@"Phone: "], 70.0f, lWidth, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Interior Color:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Interior Color %@",[self.downloadedCarRecord interiorColor]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord numberOfDoors];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Number Of Doors:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Number Of Doors:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Number Of Doors %@",[self.downloadedCarRecord numberOfDoors]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    fieldVal=[self.downloadedCarRecord ConditionDescription];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Vehicle Condition:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Vehicle Condition:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Vehicle Condition %@",[self.downloadedCarRecord ConditionDescription]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    y+=20;
    //mileage formatter
    NSNumberFormatter *mileageFormatter=[[NSNumberFormatter alloc]init];
    [mileageFormatter setLocale:[NSLocale currentLocale]];
    [mileageFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [mileageFormatter setMaximumFractionDigits:0];
    
    NSString *mileageString = [mileageFormatter stringFromNumber:[NSNumber numberWithInteger:[self.downloadedCarRecord mileage]]];
    mileageFormatter=nil;
    
    NSString *mileageStr= [NSString stringWithFormat:@"%@ mi",mileageString];
    if([self.downloadedCarRecord mileage]==0)
    {
        mileageStr=@"";
    }
    
    fieldVal=mileageStr;
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@ ",@"Mileage:",fieldVal]; //add 1 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
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
    label.textAlignment=UITextAlignmentLeft;
    [self createTwoTextLabel:label firstText:@"Drive Train:" secondText:fieldVal];
    label.backgroundColor=[UIColor clearColor];
    //accessibility
    label.accessibilityLabel=[NSString stringWithFormat:@"Drive Train %@",[self.downloadedCarRecord driveTrain]];
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    
    //
    y+=20;
    fieldVal=[[self.downloadedCarRecord vin] isEqualToString:@"Emp"]?nil:[self.downloadedCarRecord vin];
    
    labelStringForFindingWidth=[[NSString alloc] initWithFormat:@"%@ %@  ",@"VIN:",fieldVal]; //add 2 extra space to be safe side. Other wise the edge is getting cut off.
    lWidth=[CommonMethods findLabelWidth:labelStringForFindingWidth];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y, lWidth, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
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
    
    [self.scrollView1 addSubview:label];
    label=nil;
    
    //
    fieldVal=[[self.downloadedCarRecord description] isEqualToString:@"Emp"]?nil:[self.downloadedCarRecord description];
    //NSLog(@"description is %@",fieldVal);
    y+=20;
    CGFloat descHeight2=[CommonMethods descriptionLabelHeight:fieldVal]+20;
    //NSLog(@"descHeight2=%.0f",descHeight2);
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, y+4, 296, descHeight2)];
    label.textAlignment=UITextAlignmentLeft;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    
    if (fieldVal!=nil)
    {
        [self createTwoTextLabelv2:label firstText:@"Description:" secondText:fieldVal height:descHeight2];
    }
    else
    {
        [self createTwoTextLabelv2:label firstText:@"Description:" secondText:nil height:descHeight2];
    }
    label.backgroundColor=[UIColor clearColor]; 
    //NSLog(@"desc label bounds height = %.0f frame height=%.0f",label.bounds.size.height,label.frame.size.height);
    
    if (fieldVal==nil) {
        label.accessibilityLabel=@"Description";
    }
    else
    {
        label.accessibilityLabel=[NSString stringWithFormat:@"Description %@",fieldVal];
    }
    [self.scrollView1 addSubview:label];
    label=nil;
    
    
    //NSLog(@"y=%.0f",y);
    [self.scrollView1 setContentSize:CGSizeMake(self.view.frame.size.width,y+150+descHeight2)];
    self.scrollView1.clipsToBounds=YES;
    [self.scrollView1 setShowsVerticalScrollIndicator:YES];
    
    self.viewGalleryBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.viewGalleryBtn.frame=CGRectMake(10, 20, 70, 30);
    //[viewGalleryBtn setImage:viewGalleryImage forState:UIControlStateNormal];
    [self.viewGalleryBtn addTarget:self action:@selector(galleryBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewGalleryBtn setTitle:@"Gallery" forState:UIControlStateNormal];
    [self.viewGalleryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewGalleryBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.viewGalleryBtn.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.viewGalleryBtn makeGlossy];
    
    [self.callView addSubview:self.viewGalleryBtn];
    //self.viewGalleryBtn=nil;
    
    
    //design call button
    if(!IsEmpty([self.downloadedCarRecord phone]))
    {
        CheckButton *callbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        callbutton.frame=CGRectMake(95,20, 60, 30);
        //    [callbutton setTitle:@"Call" forState:UIControlStateNormal];
        //[callbutton setImage:callImage forState:UIControlStateNormal];
        [callbutton addTarget:self action:@selector(callButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [callbutton setTitle:@"Call" forState:UIControlStateNormal];
        [callbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [callbutton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        callbutton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
        [callbutton makeGlossy];
        
        [self.callView addSubview:callbutton];
    }
    
    //
    self.featuresButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    self.featuresButton.frame=CGRectMake(170,20, 80, 30);
    //[featuresButton setImage:callImage forState:UIControlStateNormal];
    [self.featuresButton addTarget:self action:@selector(featuresButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.featuresButton setTitle:@"Features" forState:UIControlStateNormal];
    [self.featuresButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.featuresButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.featuresButton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.featuresButton setHidden:YES];
    [self.featuresButton makeGlossy];
    
    [self.callView addSubview:self.featuresButton];
    //self.featuresButton=nil;
    
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
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    if (self.tempImageView==nil) {
        self.backgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        [self.backgroundImageView setImage:[UIImage imageNamed:@"back3.png"]];
        [self.backgroundImageView setUserInteractionEnabled:YES];
        [self.view addSubview:self.backgroundImageView];
        
        self.tempImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,163)];
        self.tempImageView.contentMode=UIViewContentModeScaleAspectFit;
        [self.tempImageView setUserInteractionEnabled:YES];
        [self.backgroundImageView addSubview:self.tempImageView];
        //
        self.callView=[[UIImageView alloc] initWithFrame:CGRectMake(0,self.tempImageView.frame.size.height,self.view.frame.size.width,54)];
        [self.callView setUserInteractionEnabled:YES];
        [self.callView setBackgroundColor:[UIColor clearColor]];
        [self.backgroundImageView addSubview:self.callView];
        //
        self.scrollView1=[[UIScrollView alloc] initWithFrame:CGRectMake(0,self.tempImageView.frame.size.height+self.callView.frame.size.height,self.view.frame.size.width,300)];
        
        //
        self.scrollView1.showsVerticalScrollIndicator=YES;
        self.scrollView1.scrollEnabled=YES;
        self.scrollView1.userInteractionEnabled=YES;
        
        //
        [self.backgroundImageView addSubview:self.scrollView1];
        
        //
        self.backgroundImageView.backgroundColor=[UIColor clearColor];
        self.scrollView1.backgroundColor=[UIColor clearColor];
    }
    
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

#pragma mark -
#pragma mark Notification Methods

-(void)CarRecordFromDownloadCarRecordOperationNotifMethod:(NSNotification *)notif
{
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(CarRecordFromDownloadCarRecordOperationNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        self.downloadedCarRecord=[[notif userInfo] valueForKey:@"DownloadCarRecordOperationResults"];
        
        //NSLog(@"car id received in mylistdetailview is %d price is %d",[tempCarRecord carid],[tempCarRecord price]); 
        
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
    //NSLog(@"value received in viewcontroller");
    
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
        //NSLog(@"jpg file path is %@",jpgPath1);
        [imgDataToSave writeToFile:jpgPath1 atomically:YES]; 
        
    });
    dispatch_release(self.queue);
}

-(void)noCarForThisIdNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(noCarForThisIdNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
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
        
        NSError *error=[[notif userInfo]valueForKey:@"ErrorDownloadingCarRecordNotifKey"];
        
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        self.serverErrorAlert=[[UIAlertView alloc]init];;
        self.serverErrorAlert.delegate=self;
        [self.serverErrorAlert addButtonWithTitle:@"OK"];
        
        
        
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            
            self.serverErrorAlert.title=@"No Internet Connection";
            self.serverErrorAlert.message=@"UCE cannot retreive data as it is not connected to the Internet.";
        }
        else if([error code]==-1001)
        {
            self.serverErrorAlert.title=@"Error Occured";
            self.serverErrorAlert.message=@"The request timed out.";
        }
        else
        {
            self.serverErrorAlert.title=@"Server Error";
            self.serverErrorAlert.message=@"UCE cannot retreive data because of server error.";
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
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Data could not be retreived as UCE server is down." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

-(void)getArrayOfCarPicUrls
{
    //    NSLog(@"Method 999");
    NSMutableArray *tempArrayOfCarPicUrls=[[NSMutableArray alloc]init];
    self.arrayOfCarPicUrls=tempArrayOfCarPicUrls;
    tempArrayOfCarPicUrls=nil;
    NSString *completeimagename1;
    
    NSArray *imageNames=[NSArray arrayWithObjects:@"PIC1",@"PIC2",@"PIC3",@"PIC4",@"PIC5",@"PIC6",@"PIC7",@"PIC8",@"PIC9",@"PIC10", @"PIC11",@"PIC12",@"PIC13",@"PIC14",@"PIC15",@"PIC16",@"PIC17",@"PIC18",@"PIC19",@"PIC20", nil];
    
    NSArray *imageDirs=[NSArray arrayWithObjects:@"PICLOC1",@"PICLOC2",@"PICLOC3",@"PICLOC4",@"PICLOC5",@"PICLOC6",@"PICLOC7",@"PICLOC8",@"PICLOC9",@"PICLOC10", @"PICLOC11",@"PICLOC12",@"PICLOC13",@"PICLOC14",@"PICLOC15",@"PICLOC16",@"PICLOC17",@"PICLOC18",@"PICLOC19",@"PICLOC20", nil];                         
    
    //NSLog(@"individualcarscrolling dictionary is %@",self.individualcarscrolling);
    
    //condition to check whether pic0 is empty or not
    
    
    for (int i=0; i<[imageNames count]; i++) {
        if (![[self.individualcarscrolling objectForKey:[imageNames objectAtIndex:i]] isEqualToString:@"Emp"]) {
            completeimagename1=[[NSString alloc]initWithFormat:@"http://www.unitedcarexchange.com/%@/%@",[self.individualcarscrolling objectForKey:[imageDirs objectAtIndex:i]],[self.individualcarscrolling objectForKey:[imageNames objectAtIndex:i]]];
            
            completeimagename1=[completeimagename1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self.arrayOfCarPicUrls addObject:completeimagename1];
            completeimagename1=nil;
        }
        else 
            break;
    }
    
    //NSLog(@"All the pic urls for this car are %@",self.arrayOfCarPicUrls);
    if([self.arrayOfCarPicUrls count]>0)
    {
        [self.viewGalleryBtn setHidden:NO];
    }
    
}


-(void)retreiveUlsAndImages
{
    
    //calling service
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/FindCarID/%d/",[self.downloadedCarRecord carid]];
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
        
        //NSLog(@"download succeeded for car %d",num);
        //NSData *data=(NSData *)responseObject;
        NSData *data=[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        
        weakSelf.individualcarscrolling=[[NSMutableDictionary alloc]init];
        
        NSError *error;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        
        
        NSArray *findCarIDResult=[wholeResult objectForKey:@"FindCarIDResult"];
        
        if([findCarIDResult respondsToSelector:@selector(objectAtIndex:)])
        {
            //    NSLog(@"received FindCarIDResult=%@",findCarIDResult);
            
            
            NSDictionary *individualcar = [findCarIDResult objectAtIndex:0];
            
            //        NSLog(@"individualcar is %@",individualcar);
            
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
                
                
                [weakSelf.individualcarscrolling setObject:[individualcar objectForKey:tempPicName] forKey:[picsArray objectAtIndex:i]];
                [weakSelf.individualcarscrolling setObject:[individualcar objectForKey:tempPicLocName] forKey:[picsLocArray objectAtIndex:i]];
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
    _individualcarscrolling=nil;
    _arrayOfCarPicUrls=nil;
    _networkGallery=nil;
    _callView=nil;
    _tempImageView=nil;
    _scrollView1=nil;
}

@end
