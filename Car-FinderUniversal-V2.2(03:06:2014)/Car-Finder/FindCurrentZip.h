//
//  FindCurrentZip.h
//  GPS1
//
//  Created by Mac on 15/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m part

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@protocol FindCurrentZipDelegate <NSObject>

-(void)didSendZip:(NSString *)zipVal;

@end


@interface FindCurrentZip : NSObject<CLLocationManagerDelegate>

@property(unsafe_unretained) id<FindCurrentZipDelegate> delegate;


-(void)FindingZipCode;
@end
