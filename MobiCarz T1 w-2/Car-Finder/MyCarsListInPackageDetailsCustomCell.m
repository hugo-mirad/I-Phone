//
//  MyCarsListInPackageDetailsCustomCell.m
//  Car-Finder
//
//  Created by Mac on 09/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MyCarsListInPackageDetailsCustomCell.h"

@interface MyCarsListInPackageDetailsCustomCell()


@end


@implementation MyCarsListInPackageDetailsCustomCell

@synthesize spinner1=_spinner1,imageView1=_imageView1,yearMakeModelLabel=_yearMakeModelLabel,priceLabel=_priceLabel,mileageLabel=_mileageLabel;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _imageView1=[[UIImageView alloc] init];
        _imageView1.frame=CGRectMake(20, 5, 96, 96);
        _imageView1.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView1];
        
        _spinner1=[[UIActivityIndicatorView alloc] init];
        _spinner1.frame=CGRectMake(50, 35, 37, 37);
        [self.contentView addSubview:_spinner1];
        
        _yearMakeModelLabel=[[UILabel alloc] init];
        _yearMakeModelLabel.frame=CGRectMake(124,15,196,21);
        _yearMakeModelLabel.font=[UIFont boldSystemFontOfSize:14];
        _yearMakeModelLabel.textColor=[UIColor orangeColor];
        _yearMakeModelLabel.lineBreakMode=NSLineBreakByClipping;
        _yearMakeModelLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_yearMakeModelLabel];
        
        
        _priceLabel=[[UILabel alloc] init];
        _priceLabel.frame=CGRectMake(124, 40, 176, 21); //124, 65, 176, 21
        _priceLabel.font=[UIFont systemFontOfSize:14];
        _priceLabel.textColor=[UIColor whiteColor];
        _priceLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        _priceLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_priceLabel];
        
        
        _mileageLabel=[[UILabel alloc] init];
        _mileageLabel.frame=CGRectMake(124, 65, 176, 21); //124, 43, 176, 21
        _mileageLabel.font=[UIFont systemFontOfSize:14];
        _mileageLabel.textColor=[UIColor whiteColor];
        _mileageLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        _mileageLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_mileageLabel];
        
       //disable accessibility as we will give it in cellforrow
        self.accessibilityElementsHidden=YES;
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (BOOL)isAccessibilityElement
{
    return NO;
}

- (NSString *)accessibilityLabel
{
    return nil;
}

-(void)dealloc
{
    _imageView1=nil;
    _spinner1=nil;
    _yearMakeModelLabel=nil;
    _mileageLabel=nil;
    _priceLabel=nil;
}


@end
