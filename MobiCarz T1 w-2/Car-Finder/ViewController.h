//
//  ViewController.h
//  Car-Finder
//
//  Created by Mac on 20/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

{
    IBOutlet UIScrollView *loginScroll;
    UIButton *aboutUsButton;
}

-(IBAction)loginButtonTapped;
- (IBAction)findACarButtonTapped;

@end
