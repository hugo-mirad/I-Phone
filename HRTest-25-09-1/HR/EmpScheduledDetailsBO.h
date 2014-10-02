//
//  EmpScheduledDetailsBO.h
//  HRTest
//
//  Created by User on 8/9/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmpScheduledDetailsBO : NSObject

@property (nonatomic, strong) NSString *strAaSuccess1;
@property (nonatomic, strong) NSString *strEmpCompanyID;
@property (nonatomic, strong) NSString *strOffset;
@property (nonatomic, strong) NSString *strDesignation;
@property (nonatomic, strong) NSString *strEmpID;
@property (nonatomic, strong) NSString *strBusinessFname;
@property (nonatomic, strong) NSString *strBusinessLastname;
@property (nonatomic, strong) NSString *strDeptname;
@property (nonatomic, strong) NSString *strScheduleStart;
@property (nonatomic, strong) NSString *strScheduleEnd;
@property (nonatomic, strong) NSString *strLunchStart;
@property (nonatomic, strong) NSString *strLunchEnd;
@property (nonatomic, strong) NSString *strPhoto;
@property (nonatomic, strong) NSString *strShiftID;
@property (nonatomic, strong) NSString *strOfficeID;
@property (nonatomic, strong) NSString *strDeptID1;
@property (nonatomic, strong) NSString *strSchdeuleID;
@property (nonatomic, strong) NSString *strCompanyID;
@property (nonatomic, strong) NSString *strSignInTime;
@property (nonatomic, strong) NSString *strIsLate;
@property (nonatomic, strong) NSString *strSignOutTime;
@property (nonatomic, strong) NSString *strAttendID;
@property (nonatomic, strong) NSString *strDay;
@property (nonatomic, strong) NSString *strOnlySignInTime;
@property (nonatomic, strong) NSString *strOnlySignOutTime;
@property (nonatomic, strong) NSDate *dateSignInTime;



@property (nonatomic, strong) NSString *strNotes;
@property (nonatomic, strong) NSString *strModifiedNotes;

@property (nonatomic, strong) NSString *strDate;
@property (nonatomic, strong) NSDate *dateOnly;



//Emergency Contact details

@property (nonatomic, strong) NSString *strAAsuccess;
@property (nonatomic, strong) NSString *strContactFName;
@property (nonatomic, strong) NSString *strContactLName;
@property (nonatomic, strong) NSString *strRelation;
@property (nonatomic, strong) NSString *strPhone;
@property (nonatomic, strong) NSString *strAddress;

@property (nonatomic, strong) NSString *strCity;
@property (nonatomic, strong) NSString *strStateCode;
@property (nonatomic, strong) NSString *strStateID;
@property (nonatomic, strong) NSString *strZip;
@property (nonatomic, strong) NSString *strEmail;
@property (nonatomic, strong) NSString *strEmergContactID;






@end
