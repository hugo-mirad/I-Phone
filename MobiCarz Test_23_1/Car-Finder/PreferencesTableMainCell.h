//
//  MainTableCell.h
//  Preferences2
//
//  Created by Mac on 04/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CheckButton;


@interface PreferencesTableMainCell : UITableViewCell

@property(weak,nonatomic) IBOutlet UILabel *makeModelLabel;
@property(weak,nonatomic) IBOutlet UILabel *yearMileageLabel;
@property(weak,nonatomic) IBOutlet UILabel *priceLabel;

@property(weak,nonatomic) IBOutlet UILabel *CarsCountLabel;

@property(weak,nonatomic) IBOutlet UILabel *totalCarsFoundLabel;

@property(assign,nonatomic)  BOOL useColorBackground;

@property(strong,nonatomic) CheckButton *viewCarsBtn;
@end
