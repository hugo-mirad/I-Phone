//
//  SellerInformationViewController.h
//  CarDetails
//
//  Created by Mac on 23/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarRecord.h"

@interface SellerInformationViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

@property(strong,nonatomic) CarRecord *carReceived;

@end
