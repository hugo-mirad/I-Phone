//
//  PreferenceTableCellInfo.h
//  UCE
//
//  Created by Mac on 18/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CarRecord;


@interface PreferenceResultsTableCellInfo : NSObject

@property(strong,nonatomic) CarRecord *car1,*car2,*car3;


-(id)init;
-(id)initWithCar1:(CarRecord *)aCar1 car2:(CarRecord *)aCar2 car3:(CarRecord *)aCar3;

@end
