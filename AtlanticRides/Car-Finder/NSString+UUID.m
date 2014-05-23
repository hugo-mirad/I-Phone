//
//  NSString+UUID.m
//  UUIDCreation
//
//  Created by Mac on 24/06/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)uuid
{
    NSString *uuidString = nil;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    return uuidString;
}

@end
