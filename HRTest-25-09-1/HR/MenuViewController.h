//
//  MenuViewController.h
//  HR
//
//  Created by Venkata Chinni on 7/30/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,NSXMLParserDelegate>


{
    NSMutableArray *menuArray;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSMutableData *webData;
    
    NSXMLParser *xmlParser;
    
    NSMutableString *resultString;
    
   // UIActivityIndicatorView *activityIndicator;

}

@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

@end
