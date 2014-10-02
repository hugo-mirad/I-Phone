//
//  MyListDetailView.h
//  XMLTable2
//
//  Created by Mac on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"


@interface MyListDetailView : UIViewController<UIAlertViewDelegate,UITextFieldDelegate,UIWebViewDelegate,FGalleryViewControllerDelegate>


@property(strong,nonatomic) UIImageView *backgroundImageView;
@property(strong,nonatomic) UIImageView *callView;
@property(strong,nonatomic) UIImageView *tempImageView;
@property(strong,nonatomic) UIScrollView *scrollView1;



@end
