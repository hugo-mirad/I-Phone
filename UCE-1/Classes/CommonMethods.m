//
//  CommonMethods.m
//  UCE
//
//  Created by Mac on 17/05/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CommonMethods.h"

@implementation CommonMethods

-(id)init
{
    self=[super init];
    if (self) {
        //init statements
    }
    return self;
}

+ (CGFloat)descriptionLabelHeight:(NSString *)str
{
    NSString *fieldVal=[str isEqualToString:@"Emp"]?nil:str;
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10.0f, 370.0f, 296, 20.0f)];
    label.textAlignment=UITextAlignmentLeft;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    //Calculate the expected size based on the font and linebreak mode of your label
    //FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize;
    if (fieldVal!=nil)
    {
        expectedLabelSize = [fieldVal sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    }
    else
    {
        expectedLabelSize=label.frame.size;
    }
    label=nil;
    return expectedLabelSize.height;
}

+ (CGFloat)findLabelWidth:(NSString *)labelString
{
    CGFloat fSize=[UIFont systemFontSize];
    return [labelString length]*(fSize/2+1);
}

+ (NSString *)findZipFromBarButtonTitle:(NSString *)bbTitle
{
    //return zip if found in bar button title, else return nil 
    NSString *onlyZip=nil;
    //NSString *updateZipBtnTitle=self.rightBarbutton.title;
    if ([bbTitle length]>5) {
        //NSLog(@"updateZipBtnTitle=%@",updateZipBtnTitle);
        NSRange zipRange=NSMakeRange(4, 5);
        onlyZip=[bbTitle substringWithRange:zipRange];
        //NSLog(@"onlyZip=%@",onlyZip);
    }
    return onlyZip;
}

@end
