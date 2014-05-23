//
//  PreferenceResultsCollectionCellInfo.h
//  Car-Finder
//
//  Created by Venkata Chinni on 11/11/13.
//
//

#import <UIKit/UIKit.h>
@class CarRecord;

@interface PreferenceResultsCollectionCellInfo : NSObject



@property(strong,nonatomic) CarRecord *car;


-(id)init;
-(id)initWithCar:(CarRecord *)aCar;

@end
