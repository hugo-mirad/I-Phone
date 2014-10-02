//
//  ShiftSchTopButtonViewController.h
//  HRTest
//
//  Created by Venkata Chinni on 8/25/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EmpsShiftDetailsBO.h"



@protocol ShiftSchTopButtonViewController <NSObject>

-(void) didSelectRowShiftName:(NSString *) ShiftName ShiftIDEmp:(NSString *) ShiftID;
-(void) didSelectRowReportName:(NSString *) ReportName ;

@end


@interface ShiftSchTopButtonViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,NSXMLParserDelegate>

{
    
     EmpsShiftDetailsBO *objEmps;
    
    NSMutableString *currentElementValue;
    NSMutableArray *menuArray,*tempArray;
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    
    NSMutableString *resultString;
    NSString *resultStr;
    
    int typeofParsing;
    int tableRows;
    
    NSMutableArray *arrayParsedList;
    UIActivityIndicatorView *activityIndicator;

}
@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;
@property (nonatomic, strong) id <ShiftSchTopButtonViewController> delegate;

@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

@end