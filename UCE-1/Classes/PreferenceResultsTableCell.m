//
//  PreferenceTableCell.m
//  UCE
//
//  Created by Mac on 18/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferenceResultsTableCell.h"

@implementation PreferenceResultsTableCell
@synthesize imageView1=_imageView1,imageView2=_imageView2,imageView3=_imageView3,price1=_price1,price2=_price2,price3=_price3,makeModel1=_makeModel1,makeModel2=_makeModel2,makeModel3=_makeModel3,spinner1=_spinner1,spinner2=_spinner2,spinner3=_spinner3;

@synthesize yearLabel1=_yearLabel1, yearLabel2=_yearLabel2,yearLabel3=_yearLabel3;

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
    //NSLog(@"PreferenceResultsTableCell dealloc called");
    
    _imageView1=nil;
    _imageView2=nil;
    _imageView3=nil;
    _price1=nil;
    _price2=nil;
    _price3=nil;
    _makeModel1=nil;
    _makeModel2=nil;
    _makeModel3=nil;
    _spinner1=nil;
    _spinner2=nil;
    _spinner3=nil;
    _yearLabel1=nil;
    _yearLabel2=nil;
    _yearLabel3=nil;
    
}

@end
