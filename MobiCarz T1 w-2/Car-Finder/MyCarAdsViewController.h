//
//  MyCarAddsViewController.h
//  Car-Finder
//
//  Created by Mac on 10/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarRecord.h"

@interface MyCarAdsViewController : UIViewController<UIWebViewDelegate>
{
    UILabel *msgLbl;
}

@property(strong, nonatomic) CarRecord *carReceived;






@end
