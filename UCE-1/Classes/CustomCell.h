//
//  CustomCell.h
//  XMLTable2
//
//  Created by Mac on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property(weak,nonatomic)IBOutlet UIImageView *imageView1,*imageView2,*imageView3;

@property(weak,nonatomic)IBOutlet UILabel *price1,*price2,*price3;

@property(weak,nonatomic)IBOutlet UILabel *makeModel1,*makeModel2,*makeModel3;

@property(weak,nonatomic)IBOutlet UILabel *yearLabel1,*yearLabel2,*yearLabel3;

@property(weak,nonatomic) IBOutlet UIActivityIndicatorView *spinner1,*spinner2,*spinner3;



@end
