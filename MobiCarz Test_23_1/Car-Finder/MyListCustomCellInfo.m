//
//  MyListCustomCellInfo.m
//  XMLTable2
//
//  Created by Mac on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyListCustomCellInfo.h"

@implementation MyListCustomCellInfo
@synthesize imagePath=_imagePath,make=_make,model=_model,price=_price,carid=_carid,year=_year,mileage=_mileage;

-(id)initWithimagePath:(NSString *)aImagePath make:(NSString *)aMake model:(NSString *)aModel price:(NSString *)aPrice carid:(NSInteger)aCarid year:(NSInteger)aYear mileage:(NSInteger)aMileage
{
    self=[super init];
    if (self) {
        _imagePath=aImagePath;
        _make=aMake;
        _model=aModel;
        _price=aPrice;
        _carid=aCarid;
        _year=aYear;
        _mileage=aMileage;
    }
    return self;
}

-(id)init
{
    return [self initWithimagePath:nil make:nil model:nil price:nil carid:0 year:0 mileage:0];
}

-(void)dealloc
{
    _imagePath=nil;
    _make=nil;
    _model=nil;
    _price=nil;
    
}

@end
