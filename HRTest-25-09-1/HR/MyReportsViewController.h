//
//  MyReportsViewController.h
//  HRTest
//
//  Created by Venkata Chinni on 8/27/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmpReportsDetailsBO.h"
#import <CoreLocation/CoreLocation.h>
#import "FPPopoverController.h"
#import "ShiftSchTopButtonViewController.h"
#import "EmpWeekSummeryReportsBO.h"

@interface MyReportsViewController : UIViewController<CLLocationManagerDelegate,NSXMLParserDelegate,UITableViewDataSource,UITableViewDelegate,ShiftSchTopButtonViewController>

{
    
    NSDate *prviDayEnd;
    
    
    BOOL previousButtonHideStatus;
    
    
    int typeofParsing;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    
    NSMutableArray *arrayParsedList;
    
    EmpReportsDetailsBO *objEmpReports;
    NSMutableString *currentElementValue;
    
    EmpWeekSummeryReportsBO *objWeekReports;
    
    FPPopoverController *pop;
    
     UITableView *contactTableView;
    
    UIButton *reportsButtons;
    
    //UIActivityIndicatorView *activityIndicator;
    UIView *backView;
    
    UIButton *currentButton;
    UIButton *previousButton;
    UIButton *nextButton;
    
    
   // NSString *endDatelastWeek;
    NSString *weekStartendDateDetails;
    
    NSString *endDatelastWeek;
    NSString *startDatelastWeek;
    
    
    int previousOrNextButton;

    NSString *previousendDatelastWeek;
    NSString *previousstartDatelastWeek;
    
    
    
    //Weekly Summery strings
    NSString *tempPrviWeekEndDate;
    NSString *tempPrviWeekStrtDate;
    
    //Monthly Summery report
    NSString *endDate;
    NSString *startDate;
    
    int ifThisWeekSummery;
    
    
    UIView *underBackView;
}

@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

@end
