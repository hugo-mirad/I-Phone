//
//  WebServiceOperation.h
//  SalesTicker
//
//  Created by Mac on 25/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceOperation : NSOperation
{
    NSMutableData *webData;
    
    
    
    
    
}
@property (strong, nonatomic)NSDictionary *dic2;
@property (assign, nonatomic) BOOL success;

-(void)WebServiceOperation;
@end
