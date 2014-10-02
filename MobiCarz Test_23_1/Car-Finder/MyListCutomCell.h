//
//  MyListCutomCell.h
//  XMLTable2
//
//  Created by Mac on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyListCutomCell : UITableViewCell

@property(weak,nonatomic) IBOutlet UIImageView *imageView1;
@property(weak,nonatomic) IBOutlet UILabel *yearMakeModelLabel,*priceLabel,*mileageLabel;

@end
