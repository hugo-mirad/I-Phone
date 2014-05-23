//
//  MainTable.h
//  Preferences2
//
//  Created by Mac on 04/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m

#import <UIKit/UIKit.h>
#import "EditPreference.h"

@interface PreferencesTable : UITableViewController<UITextFieldDelegate,UIAlertViewDelegate,EditPreferenceDelegate>

@end
