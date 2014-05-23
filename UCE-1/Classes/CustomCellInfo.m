//
//  CustomCellInfo.m
//  XMLTable2
//
//  Created by Mac on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomCellInfo.h"

@implementation CustomCellInfo
@synthesize car1=_car1,car2=_car2,car3=_car3;


-(id)initWithCar1:(CarRecord *)aCar1 car2:(CarRecord *)aCar2 car3:(CarRecord *)aCar3
{
    self=[super init];
    if(self)
    {
        _car1=aCar1;
        _car2=aCar2;
        _car3=aCar3;
        
    }
    return self;
}

-(id)init
{
    return [self initWithCar1:nil car2:nil car3:nil];
}

-(void)dealloc
{
    //NSLog(@"CustomCellInfo dealloc called");
    _car1=nil;
    _car2=nil;
    _car3=nil;
}

@end
