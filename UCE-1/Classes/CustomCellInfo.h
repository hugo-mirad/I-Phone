//
//  CustomCellInfo.h
//  XMLTable2
//
//  Created by Mac on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CarRecord;


@interface CustomCellInfo : NSObject


@property(strong,nonatomic) CarRecord *car1,*car2,*car3;

-(id)init;
-(id)initWithCar1:(CarRecord *)aCar1 car2:(CarRecord *)aCar2 car3:(CarRecord *)aCar3;

@end
