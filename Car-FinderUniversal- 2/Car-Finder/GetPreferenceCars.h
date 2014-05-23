//
//  GetPreferenceCars.h
//  Preferences2
//
//  Created by Mac on 15/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private .ivars to .m

#import <Foundation/Foundation.h>

@interface GetPreferenceCars : NSOperation

@property(copy,nonatomic) NSString *makeIdReceived,*modelIdReceived,*priceReceived,*mileageReceived,*yearReceived,*zipReceived;

@property(assign,nonatomic)  NSInteger pageNoReceived,pageSizeReceived;
@end
