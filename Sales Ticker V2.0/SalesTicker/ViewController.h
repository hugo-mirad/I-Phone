//
//  ViewController.h
//  xxx
//
//  Created by Mac on 25/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceOperation.h"

@interface ViewController : UIViewController<UITextFieldDelegate>


@property(strong, nonatomic)UITextField *userNameTextField,*passwordTextField,*centerCodedTextField;



@property(strong, nonatomic) NSOperationQueue *opeQueue;

@property (strong, nonatomic) NSArray *tempArray;


@property (strong, nonatomic) WebServiceOperation *webOperation;

@end