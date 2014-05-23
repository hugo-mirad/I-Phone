//
//  MyListCustomCellInfo.h
//  XMLTable2
//
//  Created by Mac on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyListCustomCellInfo : NSObject


@property(copy,nonatomic) NSString *imagePath,*make,*model,*price;
@property(assign,nonatomic) NSInteger carid,year,mileage;

-(id)init;
-(id)initWithimagePath:(NSString *)aImagePath make:(NSString *)aMake model:(NSString *)aModel price:(NSString *)aPrice carid:(NSInteger)aCarid year:(NSInteger)aYear mileage:(NSInteger)aMileage;
@end
