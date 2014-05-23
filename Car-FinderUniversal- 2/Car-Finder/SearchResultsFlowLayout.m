//
//  SearchResultsFlowLayout.m
//  Car-Finder
//
//  Created by Venkata Chinni on 1/10/14.
//
//

#import "SearchResultsFlowLayout.h"

@implementation SearchResultsFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* arr = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* atts in arr) {
        if (nil == atts.representedElementKind) {
            NSIndexPath* ip = atts.indexPath;
            atts.frame = [self layoutAttributesForItemAtIndexPath:ip].frame;
        }
    }
    return arr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* atts =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.item == 0) // degenerate case 1, first item of section
        return atts;
    
    NSIndexPath* ipPrev =
    [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    
    CGRect fPrev = [self layoutAttributesForItemAtIndexPath:ipPrev].frame;
    CGFloat rightPrev = fPrev.origin.x + fPrev.size.width + 10;
    if (atts.frame.origin.x <= rightPrev) // degenerate case 2, first item of line
        return atts;
    
    CGRect f = atts.frame;
    f.origin.x = rightPrev;
    atts.frame = f;
    return atts;
}

@end
