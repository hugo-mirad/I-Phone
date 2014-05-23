//
//  EditPreference.h
//  Preferences
//
//  Created by Mac on 01/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m

#import <UIKit/UIKit.h>
@class EditPreference;


@protocol EditPreferenceDelegate <NSObject>

-(void)saveButtonTapped:(EditPreference *)editPreference forPreference:(NSDictionary *)carDictionarySaved;

@end



@interface EditPreference : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UIWebViewDelegate>


@property(copy,nonatomic) NSString *prefNameReceived;
@property(unsafe_unretained) id<EditPreferenceDelegate> delegate;


@end
