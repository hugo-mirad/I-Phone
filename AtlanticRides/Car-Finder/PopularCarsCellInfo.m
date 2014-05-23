//
//  PopularCarsCellInfo.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/8/13.
//
//

#import "PopularCarsCellInfo.h"

@implementation PopularCarsCellInfo

-(id)initWithCar:(CarRecord *)aCar
{
    self=[super init];
    if(self)
    {
        _car=aCar;
        
        
    }
    return self;
}

-(id)init
{
    return [self initWithCar:nil];
}

-(void)dealloc
{
    //NSLog(@"CustomCellInfo dealloc called");
    _car=nil;
}


@end
