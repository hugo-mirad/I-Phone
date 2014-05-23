//
//  MyListCutomCell.m
//  XMLTable2
//
//  Created by Mac on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyListCutomCell.h"

@implementation MyListCutomCell
@synthesize imageView1=_imageView1,yearMakeModelLabel=_yearMakeModelLabel,priceLabel=_priceLabel,mileageLabel=_mileageLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [_yearMakeModelLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        self.accessibilityElementsHidden=YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        //remove default accessibility. we will give from cellforrowatindexpath
        self.accessibilityElementsHidden=YES;
    }
    return self;
}

-(BOOL) isAccessibilityElement
{
    return NO;
}

- (NSString *)accessibilityLabel
{
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)dealloc
{
    _imageView1=nil;
    _yearMakeModelLabel=nil;
    _priceLabel=nil;
    _mileageLabel=nil;
}
@end
