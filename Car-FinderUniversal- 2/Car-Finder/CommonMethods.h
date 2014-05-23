//
//  CommonMethods.h
//  UCE
//
//  Created by Mac on 17/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject


+ (CGFloat)descriptionLabelHeight:(NSString *)str;
+ (CGFloat)findLabelWidth:(NSString *)labelString;
+ (NSString *)findZipFromBarButtonTitle:(NSString *)bbTitle;

+ (void)putBackgroundImageOnView:(UIView *)aView;
+ (UIImageView *)backgroundImageOnTableView:(UIView *)aView;
+ (UIImageView *)backgroundImageOnCollectionView:(UIView *)aView;

+ (void)createTwoTextLabelv2: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText height:(CGFloat)height;
+ (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText;
+ (void)createTwoTextLabel: (UILabel *) myLabel firstText:(NSString *)firstText secondText:(NSString *)secondText firstTextColor:(UIColor *)ftColor secondTextColor:(UIColor *)stColor;

+(NSString *)removeContinousDotsAndSpaces:(NSString *)str;

+ (UILabel *)controllerTitle:(NSString *)aTitle;

+ (bool)canDevicePlaceAPhoneCall;

+ (BOOL) validateEmail: (NSString *)emailString;

+ (NSNumberFormatter *)sharedPriceFormatter;
+ (NSNumberFormatter *)sharedMileageFormatter;

+(void)showActivityViewer:(UIView *)aView;
+(void)showActivityViewerForLandscape:(UIView *)aView;
+(void)hideActivityViewer:(UIView *)aView;
+(BOOL)activityViewerStillAnimating:(UIView *)aView;


@end
