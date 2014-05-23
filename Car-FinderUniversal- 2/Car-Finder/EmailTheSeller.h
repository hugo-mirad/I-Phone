
//
//  EmailTheSeller.h
//  UCE
//
//  Created by Mac on 16/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CarRecord;


@interface EmailTheSeller : UIViewController<UIWebViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property(weak,nonatomic) IBOutlet UIButton *sendButton;
@property(weak,nonatomic) IBOutlet UIButton *cancelButton;

@property(strong,nonatomic) UIImageView *backgroundImageView;

@property(strong,nonatomic) CarRecord *carRecordFromDetailView;


@end
