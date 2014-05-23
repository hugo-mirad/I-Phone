//
//  PreferenceResultsCollectionCellInfo.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/11/13.
//
//

#import "PreferenceResultsCollectionCellInfo.h"

@interface PreferenceResultsCollectionCellInfo ()

@end

@implementation PreferenceResultsCollectionCellInfo

@synthesize car=_car;


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
    _car=nil;
}

@end
