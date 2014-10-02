//
//  PreferenceResultsTable.h
//  UCE
//
//  Created by Mac on 18/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  moved private ivars to .m part

#import <UIKit/UIKit.h>
#import "DetailView.h"




@interface PreferenceResultsViewController : UICollectionViewController <UICollectionViewDataSource,UICollectionViewDelegate,DetailViewDelegate,UIAlertViewDelegate>


@property(copy,nonatomic) NSString *prefNameReceived;


@end
