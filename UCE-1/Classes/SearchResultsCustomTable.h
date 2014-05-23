//
//  SearchViewCustomTable.h
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailView.h"


@interface SearchResultsCustomTable : UITableViewController<DetailViewDelegate,UIAlertViewDelegate>

@property(assign,nonatomic) BOOL allMilesSelected;

@property(copy,nonatomic) NSString *makeIdReceived,*modelIdReceived,*zipReceived,*milesReceived,*makeNameReceived,*modelNameReceived;


@end
