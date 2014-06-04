//
//  SearchViewCollectionCell.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/11/13.
//
//

#import "SearchResultsCollectionCell.h"

@implementation SearchResultsCollectionCell


@synthesize imageView=_imageView,price=_price;
@synthesize makeModel=_makeModel,spinner=_spinner;

@synthesize yearLabel=_yearLabel;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



@end
