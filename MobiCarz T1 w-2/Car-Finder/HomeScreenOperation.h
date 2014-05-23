//
//  HomeScreenOperation.h
//  XMLTable2
//
//  Created by Mac on 06/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeScreenOperation : NSOperation


@property(strong,nonatomic) NSMutableArray *arrayOfPopularCarsCellInfoObjects;

@property(assign,nonatomic) NSInteger pageNoReceived,pageSizeReceived;
@property(copy,nonatomic) NSString *usersZipReceived;


@end
