//
//  ChangePasswordViewController.h
//  HRTest
//
//  Created by Venkata Chinni on 8/11/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ChangePasswordViewController : UIViewController<CLLocationManagerDelegate,NSXMLParserDelegate>

{
    
    UITextField *oldPswTextField;
    UITextField *newPswTextField;
    UITextField *confirmpswTextField;
    
    NSString *oldPassword;
    NSString *newPassword;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    
    NSMutableString *resultString;
    
    NSString *resultStr;
    
    
    NSCharacterSet *upperCaseChars;
    NSCharacterSet *lowerCaseChars;
    NSCharacterSet *numbers;
    NSString *specialCharacterString;
    NSCharacterSet *specialCharacterSet;
    BOOL lowerCaseLetter,upperCaseLetter,digit,specialCharacter;
    
  //  UIActivityIndicatorView *activityIndicator;

}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;
@end
