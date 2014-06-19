//
//  SalesTickerResultViewController.h
//  SalesTicker
//
//  Created by Mac on 25/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalesTickerResultViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    

    

}

@property (strong, nonatomic) NSTimer *timerObj;

@property (strong, nonatomic) IBOutlet UITableView *salesValusTableView;
//@property (strong, nonatomic) NSDictionary *webServiceResultFromViewClass;
@property (strong, nonatomic) NSArray *tempArray; 

@property (strong, nonatomic) UILabel *dateResultLabel;
@property (strong, nonatomic) UILabel *centerCodeResultLabel;

@property (strong, nonatomic) UILabel *salesResultLabel;


@property (strong, nonatomic)NSDictionary *dic2;


@property(assign , nonatomic) BOOL successRes;
-(void)startingOpe;
-(void)RefreshButtonPressed;


@end
