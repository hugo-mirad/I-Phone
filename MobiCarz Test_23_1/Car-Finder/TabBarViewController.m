//
//  TabBarViewController.m
//  Firstcry
//
//  Created by Webtransform-MAC on 10/26/13.
//  Copyright (c) 2013 Webtransform Tech. All rights reserved.
//

#import "TabBarViewController.h"
#import "AppDelegate.h"

#import "PreferencesTable.h"
//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#import "NSString+UUID.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier"


@interface TabBarViewController ()

{
    NSDictionary  *individualcarPrefCount;
    NSMutableData *data1;
    NSURLConnection *con;
    
}
@property(strong, nonatomic) NSURLConnection *carsCountConnection;
@property(strong, nonatomic) NSMutableData *carsCountData;
@end



@implementation TabBarViewController



AppDelegate *appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    
    UITabBarController *tabBarController = (UITabBarController *)self;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        tabBar.tintColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
//        tabBar.selectedImageTintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
        
        [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"Popular_act.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Popular.png"]];
        [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"Search_act.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Search.png"]];
        [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"Preference_act.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Preference.png"]];
        [tabBarItem4 setFinishedSelectedImage:[UIImage imageNamed:@"My_List_act.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"My_List.png"]];

    }
    else
    {
        tabBar.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    
    }
    
#warning here added temp badge value after confirmation remome
    tabBarItem3.badgeValue = [NSString stringWithFormat:@"4"];
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
#warning here sending device ID statically
    //BrandID == 2 for MobiCarz
    ///BrandID == 1 for UCE
    NSUserDefaults *deviceTKNum = [NSUserDefaults standardUserDefaults];
    NSString *deviceTockenStr = [deviceTKNum objectForKey:@"deviceTokenIDKey"];
    
    
    NSString* url = [[NSString alloc]initWithFormat:@"http://www.unitedcarexchange.com/NotificationService/Service.svc/SaveDevice/%@/Iphone/%@/2/",deviceTockenStr,retrieveduuid];
    //@"f429371abf6c69a1eeaa8411b3c21ac021a6619af4fb2ad3eed8e9f309db24cf"
    //
    NSLog(@"REQUEST is %@",url);
    
    //
    NSURL *urlc = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlc];
    
    
    
    con = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    [con start];
    
    if (con)
    {
        data1 = [NSMutableData data];
        // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification connection Done" message:tokenAsString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        // [alert show];
        
    }else{
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification connection Not Done" message:tokenAsString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        // [alert show];
    }

    
    
   
//    tabBar.badgeValue = [[UIApplication sharedApplication] setApplicationIconBadgeNumber:integerValue];
    
    if ([appDelegate.launchDic count])
    {
        self.selectedIndex = 2;
         //[self prefCount];
        
    }
    else
        self.selectedIndex = 0;
      //[self prefCount];
}


#warning here we are getting the preference count when Push notification available

-(void)prefCount:(NSString *)deviceID
{
    

    
    //BrandID = 2 for MobiCarz
    //BrandID = 1 for UCE
    
    
    NSString *url = [[NSString alloc] initWithFormat:@"http://www.unitedcarexchange.com/NotificationService/Service.svc/GetPreferencesCount/%@/Iphone/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/2/",deviceID];
    
    NSURL *urlcOne = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *requestOne = [NSURLRequest requestWithURL:urlcOne];
    
    
    self.carsCountConnection = [[NSURLConnection alloc]initWithRequest:requestOne delegate:self];
    
    [self.carsCountConnection start];
    
    if(self.carsCountConnection)
    {
        self.carsCountData = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL in %@:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   
    if (connection == con) {
        [data1 setLength:0];
    }
    else if(connection == _carsCountConnection)
    {
        [self.carsCountData setLength:0];
    }
	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == con)
    {
        [data1 appendData:data];
    }
    else if(connection == _carsCountConnection)
    {
        [self.carsCountData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if (connection == con)
    {
         con = nil;;
    }
    else if(connection == _carsCountConnection)
    {
         _carsCountConnection = nil;
    }

   
    NSLog(@"error--%@",error);
    
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSError *error=nil;
    
   
    if (connection == con)
    {
        NSDictionary  *wholeR=[NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableContainers error:&error];
        NSString *deviceID = [wholeR objectForKey:@"SaveDeviceResult"];
        
        [[NSUserDefaults standardUserDefaults] setValue:deviceID forKey:@"SaveDeviceResultKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
#warning here put condition for push notification available give the device id and procede to [self prefCount:deviceID];
        
        [self prefCount:deviceID];
        
    }
    else if(connection == _carsCountConnection){
        
      NSDictionary  *wholeResultForCarsCountDic=[NSJSONSerialization JSONObjectWithData:self.carsCountData options:NSJSONReadingMutableContainers error:&error];
        
       NSMutableArray *findCarIDResult=[wholeResultForCarsCountDic objectForKey:@"GetPreferencesCountResult"];
       
       [[NSUserDefaults standardUserDefaults] setValue:findCarIDResult forKey:@"findCarIDResultArray"];
       [[NSUserDefaults standardUserDefaults] synchronize];
       
       
     //  NSLog(@"wholeResultForCarsCountDic--%@,findCarIDResult--%@",wholeResultForCarsCountDic,findCarIDResult);
       
       
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
