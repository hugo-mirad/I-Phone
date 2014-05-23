//
//  SearchViewCollectionCellInfo.h
//  Car-Finder
//
//  Created by Venkata Chinni on 11/11/13.
//
//

#import <UIKit/UIKit.h>
@class CarRecord;

@interface SearchResultsCollectionCellInfo : UICollectionViewCell

@property(strong,nonatomic) CarRecord *car;


-(id)init;
-(id)initWithCar:(CarRecord *)aCar;

@end
