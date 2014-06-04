//
//  PackageDetailsInfoViewController.h
//  Car-Finder
//
//  Created by Mac on 22/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageDetailsInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic) NSDictionary *packageDetailsDict;

@property(strong,nonatomic) NSArray *arrayOfCarRecordsForThisPackage;


@end
