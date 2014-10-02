//
//  EmpWeekSummeryReportsBO.h
//  HRTest
//
//  Created by Venkata Chinni on 9/4/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmpWeekSummeryReportsBO : NSObject


//WeeklySummery&&MonthlySummery


@property (nonatomic, strong) NSString *strAASuccess;
@property (nonatomic, strong) NSString *strEmpFName;
@property (nonatomic, strong) NSString *strEmpLName;
@property (nonatomic, strong) NSString *strEmpCompanyID;
@property (nonatomic, strong) NSString *strEmpDesignation;
@property (nonatomic, strong) NSString *strEmpBusinessFname;
@property (nonatomic, strong) NSString *strEmpBusinessLName;
@property (nonatomic, strong) NSString *strEmpID;
@property (nonatomic, strong) NSString *strStartDate;
@property (nonatomic, strong) NSString *strEndDate;
@property (nonatomic, strong) NSString *strTotalDays;
@property (nonatomic, strong) NSString *strWorkedDays;
@property (nonatomic, strong) NSString *strHolidays;
@property (nonatomic, strong) NSString *strTotalHrs;
@property (nonatomic, strong) NSString *strTotalWorkedHrs;
@property (nonatomic, strong) NSString *strGrandTotalWDays;
@property (nonatomic, strong) NSString *strGrandTotalWHrs;
@property (nonatomic, strong) NSString *strGrandTotalWHrsTime;
@property (nonatomic, strong) NSString *strMonth;

@property (nonatomic, strong) NSString *strTotalHrsTime;

@end
