//
//  EmailTheSeller.h
//  UCE
//
//  Created by Mac on 16/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CarRecord;


@interface EmailTheSeller : UIViewController<UIWebViewDelegate,UIAlertViewDelegate>

@property(weak,nonatomic) IBOutlet UIWebView *emailWebView;
@property(weak,nonatomic) IBOutlet UIButton *sendButton;
@property(weak,nonatomic) IBOutlet UIButton *cancelButton;

@property(strong,nonatomic) CarRecord *carRecordFromDetailView;


-(IBAction)sendButtonTapped;
-(IBAction)cancelButtonTapped;
@end
