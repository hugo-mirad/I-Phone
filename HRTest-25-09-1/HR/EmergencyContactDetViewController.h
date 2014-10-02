//
//  EmergencyContactDetViewController.h
//  HRTest
//
//  Created by Venkata Chinni on 8/25/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EmpScheduledDetailsBO.h"


@interface EmergencyContactDetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,NSXMLParserDelegate>
{
    
    UITableView *contactTableView;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    //activityIndicator
   // UIActivityIndicatorView *activityIndicator;
    
    
    NSXMLParser *xmlParser;
    NSMutableData *webData;
    
    NSMutableArray *arrayParsedList;

    EmpScheduledDetailsBO *objEmp;
    
      NSMutableString *currentElementValue;

}
@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;



@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;



@end
