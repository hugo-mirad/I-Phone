//
//  ViewController.h
//  HR
//
//  Created by Venkata Chinni on 7/29/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<NSXMLParserDelegate,CLLocationManagerDelegate,UITextFieldDelegate>
{
    UITextField *cmpCodeTextField;
    UITextField *empCompanyIDTF;
    UITextField *passwordTextField;
    UITextField *secureCodeTextField;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSMutableData *webData;
    
    
    NSMutableDictionary *comEmpDetailsDictionary;
    
   // UIActivityIndicatorView *activityIndicator;
    
    
    UILabel *fromLabel;
    BOOL saveDefaults;
    
    NSCharacterSet *upperCaseChars;
    NSCharacterSet *lowerCaseChars;
    NSCharacterSet *numbers;
    NSString *specialCharacterString;
    NSCharacterSet *specialCharacterSet;
    BOOL lowerCaseLetter,upperCaseLetter,digit,specialCharacter;
    
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;


@property(strong, nonatomic) UIButton *radiobutton1;

@end
