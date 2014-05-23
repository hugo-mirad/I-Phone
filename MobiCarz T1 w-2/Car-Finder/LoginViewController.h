//
//  LoginViewController.h
//  Car-Finder
//
//  Created by Mac on 20/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate,UIWebViewDelegate>
{    
    IBOutlet UIScrollView *loginScroll;
}


-(IBAction)loginButtonTapped;
- (IBAction)registerButtonTapped;

@end
