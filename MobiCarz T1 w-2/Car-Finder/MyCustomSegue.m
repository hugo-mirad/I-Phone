//
//  MyCustomSegue.m
//  Car-Finder
//
//  Created by Mac on 02/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MyCustomSegue.h"

@implementation MyCustomSegue

-(void)perform
{
    
      
    [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:nil];
    
    
}

@end
