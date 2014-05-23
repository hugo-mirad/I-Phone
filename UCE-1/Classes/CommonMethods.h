//
//  CommonMethods.h
//  UCE
//
//  Created by Mac on 17/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject


+ (CGFloat)descriptionLabelHeight:(NSString *)str;
+ (CGFloat)findLabelWidth:(NSString *)labelString;
+ (NSString *)findZipFromBarButtonTitle:(NSString *)bbTitle;

@end
