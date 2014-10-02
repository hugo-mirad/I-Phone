//
//  SearchViewCollectionCellInfo.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/11/13.
//
//

#import "SearchResultsCollectionCellInfo.h"
#import "CarRecord.h"

@implementation SearchResultsCollectionCellInfo



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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
