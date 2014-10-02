//
//  EmployeeDetailViewViewController.h
//  HR
//
//  Created by Venkata Chinni on 7/29/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EmpScheduledDetailsBO.h"

@interface EmployeeDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate,CLLocationManagerDelegate>
{
    
    //SignIn Passcode stored strings
    NSString *signInPasscode;
    NSString *signInNotes;
    NSString *onlyNumberStr;
    NSString *longitudeStr;
    NSString *latitudeStr;
    NSMutableString *currentElementValue;
    NSString *strFromLastSignOutEmp;
    
    UILabel *borderDownLineLabel;
    
    UILabel *historyLabel;

    EmpScheduledDetailsBO *objEmp;

    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSMutableArray *arrayParsedList;
    
    
    NSArray *arrayHeader;
    NSMutableArray *array;
    
    UITableView *tableViewData;
    UIView *todaySchView;
    
    UIButton *signInButton;
    UIButton *signoutButton;
    UIButton *refreshButton;
    UIButton *historyButton;
    
    UIButton *menuButton;
    
    //New
    int typeofparsing;
    
    
    NSString *Currentdate;
    NSString *Currentday;
    
    NSString *yesterdaydate;
    NSString *yesterdayday;
    
    //activityIndicator
   // UIActivityIndicatorView *activityIndicator;
    
    UIView *hisBackView;
    
    NSMutableDictionary *comEmpDetailsDic;
    
    
    
    
    NSString *lunchStartTime,*lunchEndTime;
}
@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;
@property(nonatomic, assign) BOOL tempAccess;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;


@property(copy,nonatomic) NSString *currentelementValueStr;

@end
