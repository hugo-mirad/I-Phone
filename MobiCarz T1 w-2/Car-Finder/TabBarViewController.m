//
//  TabBarViewController.m
//  Firstcry
//
//  Created by Webtransform-MAC on 10/26/13.
//  Copyright (c) 2013 Webtransform Tech. All rights reserved.
//

#import "TabBarViewController.h"
#import "AppDelegate.h"


@interface TabBarViewController ()

@end

@implementation TabBarViewController

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
        tabBar.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    
    //[tabBar setSelectedImageTintColor:[UIColor greenColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
