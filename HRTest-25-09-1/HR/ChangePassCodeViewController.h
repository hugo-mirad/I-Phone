//
//  ChangePassCodeViewController.h
//  HRTest
//
//  Created by Venkata Chinni on 8/21/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ChangePassCodeViewController : UIViewController<CLLocationManagerDelegate,NSXMLParserDelegate>

{
    
    UITextField *oldSecrecodeTextField;
    UITextField *newSecrecodeTextField;
    UITextField *confirmSecrecodeTextField;
    
    NSString *oldSecrCode;
    NSString *newSecrCode;
    
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSMutableString *resultString;
    
    NSString *resultStr;

    
    NSCharacterSet *upperlowerCaseChars;
    //NSCharacterSet *lowerCaseChars;
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
