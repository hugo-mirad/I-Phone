//
//  CommonMethods.m
//  UCE
//
//  Created by Mac on 17/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CommonMethods.h"

//for combining label & value into single uilabel
#import "QuartzCore/QuartzCore.h"
#import "CoreText/CoreText.h"

//for dialing a number
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>



@implementation CommonMethods


-(id)init
{
    self=[super init];
    if (self) {
        //init statements
    }
    return self;
}

+ (CGFloat)descriptionLabelHeight:(NSString *)str
{
    NSString *fieldVal=[str isEqualToString:@"Emp"]?nil:str;
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, 370.0f, 296, 20.0f)];
    label.textAlignment=NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    //Calculate the expected size based on the font and linebreak mode of your label
    //FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize;
    if (fieldVal!=nil)
    {
        expectedLabelSize = [fieldVal sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    }
    else
    {
        expectedLabelSize=label.frame.size;
    }
    label=nil;
    return expectedLabelSize.height;
}

+ (CGFloat)findLabelWidth:(NSString *)labelString
{
    CGFloat fSize=[UIFont systemFontSize];
    return [labelString length]*(fSize/2+1);
}

+ (NSString *)findZipFromBarButtonTitle:(NSString *)bbTitle
{
    //return zip if found in bar button title, else return nil
    NSString *onlyZip=nil;
    //NSString *updateZipBtnTitle=self.rightBarbutton.title;
    if ([bbTitle length]>8) {
        //NSLog(@"updateZipBtnTitle=%@",updateZipBtnTitle);
        NSRange zipRange=NSMakeRange(4, 5);
        onlyZip=[bbTitle substringWithRange:zipRange];
        //NSLog(@"onlyZip=%@",onlyZip);
    }
    return onlyZip;
}

+ (void)putBackgroundImageOnView:(UIView *)aView
{
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    //av.image = [UIImage imageNamed:@"back3.png"];
    av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back" ofType:@"png"]];
    [aView addSubview:av];
    
    //autolayout constraints
    [av setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview=aView;
    NSLayoutConstraint *constraint=[NSLayoutConstraint constraintWithItem:av attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [superview addConstraint:constraint];
    
    constraint=[NSLayoutConstraint constraintWithItem:av attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [superview addConstraint:constraint];
    
    constraint=[NSLayoutConstraint constraintWithItem:av attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [superview addConstraint:constraint];
    
    constraint=[NSLayoutConstraint constraintWithItem:av attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [superview addConstraint:constraint];
}

+ (UIImageView *)backgroundImageOnTableView:(UIView *)aView
{
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    //av.image = [UIImage imageNamed:@"back3.png"];
    av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back" ofType:@"png"]];
    return av;
}

+ (UIImageView *)backgroundImageOnCollectionView:(UIView *)aView
{
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    //av.image = [UIImage imageNamed:@"back3.png"];
    av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back" ofType:@"png"]];
    return av;
}

+ (void)createTwoTextLabelv2: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText height:(CGFloat)height
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
    
    //NSLog(@"secondText=%@ finalText=%@ attrStr=%@",secondText,finalText,attrStr);
    
    if (secondText!=nil) {
        [attrStr addAttributes:subAttributes range:NSMakeRange(firstText.length, lengthOfSecondString)];
    }
    
    // you can add another subattribute in the similar way as above , if you want change the third textstring style
    /* Set the attributes string in the text layer :) */
    myLabelTextLayer.string = attrStr;
    myLabelTextLayer.opacity = 1.0; //to remove blurr effect
    //NSLog(@"label height inside func=%.0f",myLabel.frame.size.height);
    
}

+ (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText
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

+ (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText firstTextColor:(UIColor *)ftColor secondTextColor:(UIColor *)stColor
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
    CGColorRef cgColor = ftColor.CGColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)ctBoldFont, (id)kCTFontAttributeName,
                                cgColor, (id)kCTForegroundColorAttributeName, nil];
    CFRelease(ctBoldFont);
    
    
    
    // customizing second string
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGColorRef cgSubColor = stColor.CGColor;
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


+(NSString *)removeContinousDotsAndSpaces:(NSString *)str
{
    //NSLog(@"str received is %@",str);
    
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    while ([trimmedString rangeOfString:@".."].location != NSNotFound) {
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@".." withString:@"."];
    }
    
    while ([trimmedString rangeOfString:@"  "].location != NSNotFound) {
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    
    //NSLog(@"trimmedString is %@",trimmedString);
    
    return trimmedString;
}

+ (UILabel *)controllerTitle:(NSString *)aTitle
{
    
    CGFloat labelWidth=[self findLabelWidth:aTitle];
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelWidth+2, 44)]; //add 2 to label width to be on safe side. otherwise, text is getting cut off
    navtitle.text=aTitle;
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    
    return navtitle;
    
}

+ (bool)canDevicePlaceAPhoneCall
{
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

+ (BOOL) validateEmail: (NSString *)emailString {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

+ (NSNumberFormatter *)sharedPriceFormatter
{
    static NSNumberFormatter *_priceFormatter=nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (_priceFormatter==nil) {
            _priceFormatter=[[NSNumberFormatter alloc] init];
            [_priceFormatter setLocale:[NSLocale currentLocale]];
            [_priceFormatter setMaximumFractionDigits:0];
            [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        }
        
    });
    return _priceFormatter;
}

+ (NSNumberFormatter *)sharedMileageFormatter
{
    static NSNumberFormatter *_mileageFormatter=nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (_mileageFormatter==nil) {
            _mileageFormatter=[[NSNumberFormatter alloc]init];
            [_mileageFormatter setLocale:[NSLocale currentLocale]];
            [_mileageFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [_mileageFormatter setMaximumFractionDigits:0];
        }
    });
    return _mileageFormatter;
}
/*
+(void)showActivityViewer:(UIView *)aView
{
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
   
    
    static UIActivityIndicatorView *_activityIndicatorView=nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_activityIndicatorView==nil) {
            
            NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"png"];
            NSData *imageData = [[NSData alloc] initWithContentsOfFile:fileLocation];
            
            
            
            UIImage *backgroundImage=[[UIImage alloc] initWithData:imageData];
            
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            
            
            backgroundImageView.alpha = 1.0f;
            backgroundImageView.tag=999;
            _activityIndicatorView=[[UIActivityIndicatorView alloc] init];
            _activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
            
            //activityIndicatorView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
            _activityIndicatorView.center=CGPointMake(aView.center.x, aView.center.y);
            _activityIndicatorView.tag  = 1000;
            
            
            
            _activityIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                      UIViewAutoresizingFlexibleRightMargin |
                                                      UIViewAutoresizingFlexibleTopMargin |
                                                      UIViewAutoresizingFlexibleBottomMargin);
            
            [backgroundImageView addSubview:_activityIndicatorView];
            [aView addSubview:backgroundImageView];
            [_activityIndicatorView startAnimating];

        }
        
    });
}
*/
+(void)showActivityViewer:(UIView *)aView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"LoadingImages" ofType:@"png"];
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:fileLocation];
        
        
        
        UIImage *backgroundImage=[[UIImage alloc] initWithData:imageData];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        
        
        backgroundImageView.alpha = 1.0f;
        backgroundImageView.tag=999;
        
        UIActivityIndicatorView *activityIndicatorView;
        if (activityIndicatorView!=nil) {
            activityIndicatorView=nil;
        }
        activityIndicatorView=[[UIActivityIndicatorView alloc] init];
        activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
        
        //activityIndicatorView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        activityIndicatorView.center=aView.center;
        activityIndicatorView.tag  = 1000;
        
        
        
        activityIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin |
                                                  UIViewAutoresizingFlexibleTopMargin |
                                                  UIViewAutoresizingFlexibleBottomMargin);
        
        [backgroundImageView addSubview:activityIndicatorView];
        [aView addSubview:backgroundImageView];
        [activityIndicatorView startAnimating];

    });
}

+(void)showActivityViewerForLandscape:(UIView *)aView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"LoadingImagesForLandscape" ofType:@"png"];
        NSData *imageData = [[NSData alloc] initWithContentsOfFile:fileLocation];
        
        
        
        UIImage *backgroundImage=[[UIImage alloc] initWithData:imageData];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        
        
        backgroundImageView.alpha = 1.0f;
        backgroundImageView.tag=999;
        
        UIActivityIndicatorView *activityIndicatorView;
        if (activityIndicatorView!=nil) {
            activityIndicatorView=nil;
        }
        activityIndicatorView=[[UIActivityIndicatorView alloc] init];
        activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
        
        //activityIndicatorView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        activityIndicatorView.center=aView.center;
        activityIndicatorView.tag  = 1000;
        
        
        
        activityIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin |
                                                  UIViewAutoresizingFlexibleTopMargin |
                                                  UIViewAutoresizingFlexibleBottomMargin);
        
        [backgroundImageView addSubview:activityIndicatorView];
        [aView addSubview:backgroundImageView];
        [activityIndicatorView startAnimating];
        
    });
}


+(void)hideActivityViewer:(UIView *)aView
{
    
    UIActivityIndicatorView *tmpIndicatorView = (UIActivityIndicatorView *)[aView viewWithTag:1000];
    tmpIndicatorView.hidesWhenStopped=YES;
    [tmpIndicatorView stopAnimating];
    [tmpIndicatorView removeFromSuperview];
    tmpIndicatorView=nil;
    
    
    UIImageView *tmpImgView=(UIImageView *)[aView viewWithTag:999];
    [tmpImgView removeFromSuperview];
    tmpImgView=nil;
    
    
}

+(BOOL)activityViewerStillAnimating:(UIView *)aView
{
    UIActivityIndicatorView *tmpIndicatorView = (UIActivityIndicatorView *)[aView viewWithTag:1000];
    if (tmpIndicatorView.isAnimating) {
        return YES;
    }
    return NO;
}

@end
