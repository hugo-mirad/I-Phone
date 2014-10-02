//
//  EmpsShiftDetailsBO.h
//  HRTest
//
//  Created by Venkata Chinni on 8/27/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmpsShiftDetailsBO : NSObject



@property (nonatomic, strong) NSString *strAaSuccess1;
@property (nonatomic, strong) NSString *strStartTime;
@property (nonatomic, strong) NSString *strShiftEnd;
@property (nonatomic, strong) NSString *strShiftname;
@property (nonatomic, strong) NSString *strShiftID;
@property (nonatomic, strong) NSString *strIsCrossOver;

@property (nonatomic, strong) NSString *strOfficeID;
@property (nonatomic, strong) NSString *strCompanyID;
@property (nonatomic, strong) NSString *strOfficeCode;
@property (nonatomic, strong) NSString *strCompanyCode;
@property (nonatomic, strong) NSString *strShiftStartTime;
@property (nonatomic, strong) NSString *strShiftEndTime;


//Multiple SignIn/Out
@property (nonatomic, strong) NSString *strSignInTime;
@property (nonatomic, strong) NSString *strSignOutTime;
@property (nonatomic, strong) NSString *strDate;


@end
