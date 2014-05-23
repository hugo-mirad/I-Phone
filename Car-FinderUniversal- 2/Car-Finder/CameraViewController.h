//
//  CameraViewController.h
//  Car-Finder
//
//  Created by Mac on 26/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarRecord;

@protocol ReloadCarRecordDelegate <NSObject>

- (void)reloadCarWithID:(NSString *)carid;

@end

@interface CameraViewController : UIViewController

@property(assign,nonatomic) BOOL newMedia;

@property(strong,nonatomic) CarRecord *carReceived;

@property(unsafe_unretained) id<ReloadCarRecordDelegate> delegate;

@property(strong,nonatomic) UIImage *image1;



@end
