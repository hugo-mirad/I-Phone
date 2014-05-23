//
//  SearchOperation.h
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m

#import <Foundation/Foundation.h>

@interface SearchOperation : NSOperation
        
@property(copy,nonatomic) NSString *makeIdReceived,*modelIdReceived,*zipReceived,*milesReceived,*makeNameReceived,*modelNameReceived;
@property(assign,nonatomic) NSInteger pageNoReceived;


@end
