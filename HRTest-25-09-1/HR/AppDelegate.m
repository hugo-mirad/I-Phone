//
//  AppDelegate.m
//  HR
//
//  Created by Venkata Chinni on 7/29/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "SSKeychain.h"
#import "NSString+UUID.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier"



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[UIApplication sharedApplication].statusBarHidden = YES;
    
[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    
    if (![CLLocationManager locationServicesEnabled] ) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
        
    }
    
    
    
    // getting the unique key (if present ) from keychain , assuming "userIdentifier" as a key
    NSString *retrieveuuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"Emp"];
    if (retrieveuuid == nil) { // if this is the first time app lunching , create key for device
        NSString *uuid  = [self createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:UUID_USER_DEFAULTS_KEY account:@"user"];
        // this is the one time process
    }
    
   
    
    
    
    return YES;
}
- (NSString *)createNewUUID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:UUID_USER_DEFAULTS_KEY] == nil) {
        [defaults setObject:[NSString uuid] forKey:UUID_USER_DEFAULTS_KEY]; //storing in NSUserDefaults
        [defaults synchronize];
    }
    
    
    return [defaults objectForKey:UUID_USER_DEFAULTS_KEY]; //also storing in keychain
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
