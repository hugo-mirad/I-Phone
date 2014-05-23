//
//  Features.h
//  UCE
//
//  Created by Mac on 02/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Features : UIViewController

@property(weak,nonatomic) IBOutlet UIWebView *featuresWevView;

@property(strong,nonatomic) NSArray *allFeaturesFromDetailView;

@property(copy,nonatomic) NSString *navTitle;
@end
