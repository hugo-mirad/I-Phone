//
//  DetailView.h
//  XMLTable2
//
//  Created by Mac on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

@class CarRecord;
@class DetailView;


@protocol DetailViewDelegate<NSObject>


-(void)thumbnailDidDownloadedInDetailView:(DetailView *)detailView forCarRecord:(CarRecord *)aRecord;
@end


@interface DetailView : UIViewController<UITextFieldDelegate,UIWebViewDelegate,FGalleryViewControllerDelegate>


@property(strong,nonatomic) UIImageView *backgroundImageView;
@property(strong,nonatomic) UIImageView *tempImageView;
@property(strong,nonatomic) UIScrollView *scrollView1;
@property(strong,nonatomic) UIImageView *myListView;


@property(strong,nonatomic) CarRecord *carRecordFromFirstView;
@property(copy,nonatomic) NSString *prefNameFromPrefResultsTable;
@property(assign,nonatomic) BOOL fromPreferenceResults;

@property(unsafe_unretained) id<DetailViewDelegate> delegate;

@end
