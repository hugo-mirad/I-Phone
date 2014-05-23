//
//  DetailViewForSeller.h
//  Car-Finder
//
//  Created by Mac on 05/09/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

//for calling service to reload car record when user taps back from cameraviewcontroller after upload image. so that gallery will be upto date.
#import "CameraViewController.h"
#import "SelectedCarDetails.h"

@class CarRecord;
@class DetailViewForSeller;


@protocol DetailViewForSellerDelegate<NSObject>


-(void)thumbnailDidDownloadedInDetailView:(DetailViewForSeller *)detailViewForSeller forCarRecord:(CarRecord *)aRecord;
@end


@interface DetailViewForSeller : UIViewController<UITextFieldDelegate,FGalleryViewControllerDelegate,ReloadCarRecordDelegate,SelectedCarDetailsDelegate,UIWebViewDelegate>


@property(strong,nonatomic) CarRecord *carRecordFromFirstView;
@property(copy,nonatomic) NSString *prefNameFromPrefResultsTable;
@property(assign,nonatomic) BOOL fromPreferenceResults;

@property(unsafe_unretained) id<DetailViewForSellerDelegate> delegate;

@end

