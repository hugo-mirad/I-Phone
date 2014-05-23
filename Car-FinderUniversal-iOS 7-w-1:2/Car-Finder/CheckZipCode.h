//
//  CheckZipCode.h
//  UCE
//
//  Created by Mac on 17/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m

#import <Foundation/Foundation.h>

@interface CheckZipCode : NSOperation<NSXMLParserDelegate>

@property(copy,nonatomic) NSString *zipValReceived;

@end
