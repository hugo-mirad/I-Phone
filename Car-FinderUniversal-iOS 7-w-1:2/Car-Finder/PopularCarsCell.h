//
//  PopularCarsCell.h
//  Car-Finder
//
//  Created by Venkata Chinni on 11/8/13.
//
//

#import <UIKit/UIKit.h>

@interface PopularCarsCell : UICollectionViewCell

@property(weak,nonatomic)IBOutlet UIImageView *imageView;

@property(weak,nonatomic)IBOutlet UILabel *price;

@property(weak,nonatomic)IBOutlet UILabel *makeModel;

@property(weak,nonatomic)IBOutlet UILabel *yearLabel;

@property(weak,nonatomic) IBOutlet UIActivityIndicatorView *spinner;



@end
