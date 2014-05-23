//
//  CarsTable.h
//  XmlTable
//
//  Created by Mac on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeScreenOperation.h"
#import "DetailView.h"
#import "FindCurrentZip.h"


@interface CustomTable : UITableViewController<DetailViewDelegate, FindCurrentZipDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@end
