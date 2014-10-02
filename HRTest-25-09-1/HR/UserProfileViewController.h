//
//  UserProfileViewController.h
//  HR
//
//  Created by Venkata Chinni on 7/31/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AsyncImageView.h"


@interface UserProfileViewController : UIViewController<UITextFieldDelegate,CLLocationManagerDelegate,NSXMLParserDelegate>
{
//*****For Employee Details view fields****//
    
    //**Employee details buttons**
    UIButton *EmpSaveButton,*EmpCancelButton;
    
    
    //Labels for editing purpose
    UILabel *nameValueLbl,*businessNameValueLbl,*empTypeValueLbl,*depmntTypeValueLbl,*shiftTypeValueLbl,*scheduleTypeValueLbl,*designationTypeValueLbl,*startDateTypeValueLbl,*activeTypeValueLbl;
    
    //Lunch break
    UILabel *lunchTimeValueLbl;
    
    //Text fields for editing purpose
    UITextField *empDetailNameTF,*businessNameTF,*empTypeTF,*depmntTypeTF,*shiftTypeTF,*scheduleTimeTF,*designationTypeTF,*startdateTF,*activeTypeTF;
    
    
    
//*****For Person details view fields****//
    
    //**Person details buttons**
    UIButton *persDetailSaveButton,*persDetailCancelButton;
    
    //Labels for editing purpose
    UILabel *perGendValueLbl,*perDBValueLbl,*phNumValueLbl,*mobNumValueLbl;
    
    //Text fields for editing purpose
    UITextField *perGendTypeTF,*perDBValueTF,*phNumValueTF,*mobNumValueTF;
    
    
    NSString *longitudeStr;
    NSString *latitudeStr;
    
    NSXMLParser *xmlParser;
    NSMutableData *webData;
    
    int typeofParsing;
    
    //activityIndicator
   // UIActivityIndicatorView *activityIndicator;
    NSMutableDictionary *comEmpDetailsDictionary;
    
}

@property(strong, nonatomic) NSMutableDictionary *CmpEmpDetailsDic;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;


@end
