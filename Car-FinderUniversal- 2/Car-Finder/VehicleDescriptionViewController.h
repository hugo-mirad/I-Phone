//
//  VehicleDescriptionViewController.h
//  Car-Finder
//
//  Created by Mac on 11/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarRecord;

@interface VehicleDescriptionViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>

@property(strong,nonatomic) CarRecord *carReceived;

@end
