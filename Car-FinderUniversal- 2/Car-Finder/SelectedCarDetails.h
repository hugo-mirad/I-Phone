//
//  SellerCarDetailsTwo.h
//  Car-Finder
//
//  Created by Mac on 11/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarRecord.h"

#import "FGalleryViewController.h"
//#import "CameraViewController.h"

@protocol SelectedCarDetailsDelegate <NSObject>

- (void)carRecordUpdate:(CarRecord *)car;

@end

@interface SelectedCarDetails : UITableViewController<FGalleryViewControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate>


@property (strong,nonatomic) CarRecord *carReceived;

@property (assign,nonatomic) BOOL newMedia;


@property(strong,nonatomic) UIBarButtonItem *rightBarButtonUploadPhotos;
@property(strong,nonatomic) FGalleryViewController *networkGallery;

@property(unsafe_unretained) id<SelectedCarDetailsDelegate> delegate;

- (BOOL)userHasLessThan20Cars;
-(void)retrieveUrlsAndImages;


@end
