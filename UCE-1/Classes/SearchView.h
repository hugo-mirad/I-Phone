//
//  SearchView.h
//  XMLTable2
//
//  Created by Mac on 12/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m

#import <UIKit/UIKit.h>

#define kMakeComponent 0
#define kModelComponent 1

NSInteger kTabBarHeight = 49;
NSInteger kNavigationBarHeight = 44;
float kKeyboardAnimationDuration=0.3;

@interface SearchView : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,NSFetchedResultsControllerDelegate,UIWebViewDelegate>


@end
