//
//  ScheduleViewController.h
//  HR
//
//  Created by Venkata Chinni on 7/31/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EmpScheduledDetailsBO.h"
#import "AsyncImageView.h"
#import "FPPopoverController.h"

#import "ShiftSchTopButtonViewController.h"




@interface ScheduleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,NSXMLParserDelegate,ShiftSchTopButtonViewController>
{
    FPPopoverController *pop;

    EmpScheduledDetailsBO *objEmp;
    
    
    NSArray *SectionTitles;
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSXMLParser *xmlParser;
    
    NSMutableData *webData;
    
    NSMutableString *currentElementValue;
    
    NSMutableArray *arrayParsedList;
    NSMutableArray *arrayHeader;
    
    int typeofParsing;
    
    NSMutableDictionary *dictMain;
    
    UITableView *tableViewData;
    
    //activityIndicator
  //  UIActivityIndicatorView *activityIndicator;
    
    
    UIView *topNaviView;
    
    UIButton *shiftButton;
    
    NSString *shiftIDFromSelection,*shiftNameFromSelection;
    
    BOOL shiftIDbool,tempBoolinbool,tempBoolForSchdRecords,tempBoolForSigINRecords,tempBoolForSigOutRecords;
    
}
-(void)selectedTableRow:(NSUInteger)rowNum;

@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;
@end
