//
//  MainTableCell.m
//  Preferences2
//
//  Created by Mac on 04/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesTableMainCell.h"
#import "CheckButton.h"

@implementation PreferencesTableMainCell
@synthesize makeModelLabel=_makeModelLabel,yearMileageLabel=_yearMileageLabel,priceLabel=_priceLabel;

@synthesize totalCarsFoundLabel=_totalCarsFoundLabel,useColorBackground=_useColorBackground,viewCarsBtn=_viewCarsBtn;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        _viewCarsBtn=[CheckButton buttonWithType:UIButtonTypeCustom];
        _viewCarsBtn.tag=23;
        
        _viewCarsBtn.frame=CGRectMake(220,10, 32, 32);
        
        [_viewCarsBtn setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        
        _viewCarsBtn.isAccessibilityElement=YES;
        _viewCarsBtn.accessibilityLabel=@"Delete preference";
        [self.contentView addSubview:_viewCarsBtn];
        
    }
    
    return self;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)dealloc
{
    _makeModelLabel=nil;
    _yearMileageLabel=nil;
    _priceLabel=nil;
    _totalCarsFoundLabel=nil;    
    _viewCarsBtn=nil;
}

@end
