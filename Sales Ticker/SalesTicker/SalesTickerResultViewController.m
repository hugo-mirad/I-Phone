//
//  SalesTickerResultViewController.m
//  SalesTicker
//
//  Created by Mac on 25/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SalesTickerResultViewController.h"
#import "WebServiceOperation.h"

#import "ViewController.h"

#import "AppDelegate.h"


@implementation SalesTickerResultViewController


@synthesize salesValusTableView;


@synthesize dateResultLabel,centerCodeResultLabel,salesResultLabel;
@synthesize successRes;


@synthesize dic2;
@synthesize tempArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //////
    
    successRes = NO;
    
    UIBarButtonItem *rightHomeButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(RefreshButtonPressed)];
    
    
    self.navigationItem.rightBarButtonItem = rightHomeButton;
    
    UIBarButtonItem *lefttHomeButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed)];
    
    
    self.navigationItem.leftBarButtonItem = lefttHomeButton;


    
        
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 100, 30)];
    
    [dateLabel setFont:[UIFont systemFontOfSize:16]];
    [dateLabel setText:@"Date :"];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:dateLabel];
    
    dateResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 200, 30)];
    
    [dateResultLabel setFont:[UIFont systemFontOfSize:16]];
    [dateResultLabel setText:@"your Date Here"];
    ;
    [dateResultLabel setTextAlignment:UITextAlignmentLeft];
    [dateResultLabel setTextColor:[UIColor whiteColor]];
    [dateResultLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:dateResultLabel];

    
     UILabel *centerCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 40, 100, 30)];
    
    [centerCodeLabel setFont:[UIFont systemFontOfSize:16]];
    [centerCodeLabel setText:@"Center Code :"];
    [centerCodeLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:centerCodeLabel];
    
    centerCodeResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 40, 200, 30)];
    
    [centerCodeResultLabel setFont:[UIFont systemFontOfSize:16]];
    [centerCodeResultLabel setText:@"your Center Code Here"];

    [centerCodeLabel setTextAlignment:UITextAlignmentLeft];
    [centerCodeResultLabel setTextColor:[UIColor whiteColor]];
    [centerCodeResultLabel setBackgroundColor:[UIColor clearColor]];
    
     
    /////////////////////////////////// From App Class We Get the Center Code 
    
    
    
    [self.view addSubview:centerCodeResultLabel];
    
    
    UILabel *salesLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 80, 100, 30)];
    
    [salesLabel setFont:[UIFont systemFontOfSize:16]];
    [salesLabel setText:@"Sales :"];
    [salesLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:salesLabel];
    
    salesResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 80, 200, 30)];
    
    [salesResultLabel setFont:[UIFont systemFontOfSize:16]];
    [salesResultLabel setText:@"your Sales Results Here"];
   
    
    [salesResultLabel setTextAlignment:UITextAlignmentLeft];
    
    [salesResultLabel setTextColor:[UIColor whiteColor]];
    [salesResultLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:salesResultLabel];

       
    [self startingOpe];
   /////Table View Delegate Methods
    
    self.salesValusTableView.dataSource = self;
    self.salesValusTableView.delegate = self;
    
}



-(void)RefreshButtonPressed
{
    
    successRes = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(opeTwo:) name:@"GetSalesAgentDetailsResultNotif2" object:nil];
    
    NSLog(@"Refresh Button Clicked");
    
    WebServiceOperation *webOperation = [[WebServiceOperation alloc] init];
    
    NSOperationQueue *opeQueue = [[NSOperationQueue alloc] init];
    webOperation.success = YES;
    [opeQueue addOperation:webOperation];
    
    //[self.salesValusTableView reloadData];

    
        
    NSLog(@"Refresh Button Clicked And Web Service Again Called");
}
 

-(void)opeTwo:(NSNotification *)notif
{
    
    self.tempArray = [[notif userInfo] valueForKey:@"GetSalesAgentLoginResultKey"];
    
    NSLog(@"self.tempArray  %@",self.tempArray);
    
    [self startingOpe];
    
    
    
    
}

-(void)logoutButtonPressed
{
    NSLog(@" u r going to login screen");
    
  
    
    
    
    NSUserDefaults *userNamedefault = [NSUserDefaults standardUserDefaults];
    
    [userNamedefault setObject:@"0" forKey:@"userNameKey"];
    
    [userNamedefault setObject:@"0" forKey:@"passwordKey"];
    
    [userNamedefault setObject:@"0" forKey:@"enterCodedKey"];
    
    [userNamedefault synchronize];
    
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
    
}




-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetSalesAgentDetailsResultNotif2" object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    navtitle.text=@"Sales Ticker Results";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationController.navigationBar.topItem setTitleView:navtitle]; 
    
    [super viewDidAppear:animated];
}


-(void)startingOpe
{
   
   // NSLog(@"-------------- %@",self.tempArray);
    
    
    self.dic2 = [self.tempArray objectAtIndex:0];
    
    
    
    NSString *dateStr = [self.dic2 objectForKey:@"Date"];
    
    
    
    dateResultLabel.text = dateStr;
   
    
    NSString *cCodeString = [self.dic2 objectForKey:@"CenterCode"];
    
    centerCodeResultLabel.text = cCodeString;
    
    
    //NSMutableArray *agentsArray = [self.tempArray objectAtIndex:0];
    
    //NSString *totalSalesCount = [dic2 objectForKey:@"TotalSalesCount"];////////////////after Deleting Count add it
    
    
    NSString *totalSalesAmount = [self.dic2 objectForKey:@"TotalSalesAmount"];
    
    
    //NSString *totalSalesRecords = [totalSalesCount stringByAppendingString:totalSalesAmount];///////////////////////////
    
    //salesResultLabel.text = totalSalesRecords;/////////////////////////////////////
    
    
    salesResultLabel.text =totalSalesAmount;
    
    [self.salesValusTableView reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    
       return [self.tempArray count];
   
          
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    NSDictionary *tempDic1=  [self.tempArray objectAtIndex:indexPath.row]; 
        
    //NSLog(@"self.tempArray ==== %@",self.tempArray);
    
    
    //NSLog(@"[tempDic1 objectForKey:@SalesAgentName ] === %@",[tempDic1 objectForKey:@"SalesAgentName" ]);
    
    if ([[tempDic1 objectForKey:@"MainCenter"] isEqualToString:[tempDic1 objectForKey:@"CenterCode"]]) 
    
    {
        
        if ([tempDic1 objectForKey:@"SalesAgentName" ] == nil )
        
    
    {
        cell.textLabel.text = @"Emp";
    }
    else if ([[tempDic1 objectForKey:@"SalesAgentName"] isKindOfClass:[NSNull class]])
    {
        
        cell.textLabel.text = @"Emp";
    
    }
    else
    {
    
   cell.textLabel.text =[tempDic1 objectForKey:@"SalesAgentName" ];
    }
    
        NSNumberFormatter  *priceFormatter=[[NSNumberFormatter alloc]init];
        [priceFormatter setLocale:[NSLocale currentLocale]];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [priceFormatter  setCurrencyGroupingSeparator:@","];
        [priceFormatter setMaximumFractionDigits:0];
        
        
    if ([tempDic1 objectForKey:@"AgentSalesAmount" ] == nil) 
    {
        cell.detailTextLabel.text = @"0";
    }
    else if ([[tempDic1 objectForKey:@"AgentSalesAmount"] isKindOfClass:[NSNull class]])
    {
        
        cell.textLabel.text = @"0";
        
    }
    
    else
    {
    
       NSString *agentSales = [tempDic1 objectForKey:@"AgentSales" ];
               
       NSString *intConver = [tempDic1 objectForKey:@"AgentSalesAmount" ];
       
        NSInteger intvalue = [intConver integerValue];
        
        NSString *priceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:intvalue]];
        
        NSString *totalValue = [NSString stringWithFormat:@"%@ (%@)",agentSales,priceVal];
        
        cell.contentView.backgroundColor=[UIColor whiteColor];
        cell.detailTextLabel.text = totalValue;
        
        
        NSString *agentCenterTotalAmount = [tempDic1 objectForKey:@"CenterSalesAmount"];
        
        
        NSString *agentCenterTotalCount = [tempDic1 objectForKey:@"CenterSalesCount"];
        
        NSInteger agentCenterTotalAmountintvalue = [agentCenterTotalAmount integerValue];
        
        NSString *agentCenterTotalpriceVal=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:agentCenterTotalAmountintvalue]];
        
         NSString *agentCenterTotalValue = [NSString stringWithFormat:@"%@ (%@)",agentCenterTotalCount,agentCenterTotalpriceVal];
        
       
        salesResultLabel.text = agentCenterTotalValue;
       
        
        
        priceFormatter=nil;
    }
                         
    }    
    else /////
    {
                    
        cell.textLabel.text =[tempDic1 objectForKey:@"CenterCode" ];
        
        NSNumberFormatter  *priceFormatter=[[NSNumberFormatter alloc]init];
        [priceFormatter setLocale:[NSLocale currentLocale]];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [priceFormatter  setCurrencyGroupingSeparator:@","];
        [priceFormatter setMaximumFractionDigits:0];

        NSString *intConverCenterSalesCount = [tempDic1 objectForKey:@"CenterSalesCount"];
        
        NSString *intConverCenterSalesAmount = [tempDic1 objectForKey:@"CenterSalesAmount" ];
        NSInteger intvalueCenterSalesAmount = [intConverCenterSalesAmount integerValue];
      // NSInteger intvalueCenterSalesAmount = [tempDic1 objectForKey:@"CenterSalesAmount" ];
        
        NSString *priceValCenterSalesAmount=[priceFormatter stringFromNumber:[NSNumber numberWithInteger:intvalueCenterSalesAmount]];
        
        NSString *centerTotalValueandCount = [NSString stringWithFormat:@"%@ (%@)",intConverCenterSalesCount,priceValCenterSalesAmount];
        
        UIColor *centerOther = [UIColor colorWithRed:0.984 green:0.961 blue:0.678 alpha:1.000];
        
        
        cell.contentView.backgroundColor = centerOther;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.text = centerTotalValueandCount;
        
        
        
        priceFormatter=nil;
    }
        return cell;
     
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
