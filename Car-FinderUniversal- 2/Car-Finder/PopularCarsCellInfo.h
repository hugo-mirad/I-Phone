//
//  PopularCarsCellInfo.h
//  Car-Finder
//
//  Created by Venkata Chinni on 11/8/13.
//
//

#import <Foundation/Foundation.h>

@class CarRecord;

@interface PopularCarsCellInfo : NSObject

@property(strong,nonatomic) CarRecord *car;

-(id)init;
-(id)initWithCar:(CarRecord *)aCar;


@end
