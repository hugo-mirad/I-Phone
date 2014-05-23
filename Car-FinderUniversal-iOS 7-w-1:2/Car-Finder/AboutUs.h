//
//  AboutUs.h
//  UCE
//
//  Created by Mac on 24/06/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutUs : UIViewController<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UILabel *contactLbl;
@property (strong, nonatomic) UILabel *phoneLbl;
@property (strong, nonatomic) UILabel *mailLbl;

@property(strong,nonatomic) UIToolbar *toolbar;
@property(strong,nonatomic) UILabel *toolBarLbl;



//-(IBAction)homeButtonTapped:(id)sender;
@end
