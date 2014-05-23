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

@property (weak, nonatomic) IBOutlet UILabel *contactLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *mailLbl;

@property(weak,nonatomic) IBOutlet UIToolbar *toolbar;



//-(IBAction)homeButtonTapped:(id)sender;
@end
