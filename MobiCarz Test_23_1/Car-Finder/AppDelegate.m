//
//  AppDelegate.m
//  XMLTable2
//
//  Created by Mac on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TestFlight.h"

#import "SellerInformationViewController.h"
#import "TabBarViewController.h"
#import "ViewController.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#import "NSString+UUID.h"


#define UUID_USER_DEFAULTS_KEY @"userIdentifier"

//for makes, models
#import "DownloadMakesOperation.h"
#import "DownloadModelsOperation.h"

//#import "SVProgressHUD.h"
//#import "SVStatusHUD.h"

@interface AppDelegate ()

@property(strong,nonatomic) NSOperationQueue *downloadMakesOperationQueue;



- (void)downloadMakesIfNotPresent;
-(void)updateMakesModelsButtonTapped;
-(void)startDownloadMakesOperation;

-(void)showActivityViewer;
-(void)hideActivityViewer;

@end


@implementation AppDelegate

@synthesize window = _window,downloadMakesOperationQueue=_downloadMakesOperationQueue;


@synthesize managedObjectContext=__managedObjectContext,managedObjectModel=__managedObjectModel,persistentStoreCoordinator=__persistentStoreCoordinator;


static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // !!!: Use the next line only during beta
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    //
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f]];
    
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    
    
    //Push notification lines
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
   // return YES;

    
    
#ifdef TESTFLIGHT
    [TestFlight takeOff:@"XYZ"]; //b75dc0d4-0c34-4535-960b-06e5dc3e5260
#endif
    
    // The rest of your application:didFinishLaunchingWithOptions method
   
    
    // getting the unique key (if present ) from keychain , assuming "userIdentifier" as a key
    NSString *retrieveuuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    if (retrieveuuid == nil) { // if this is the first time app lunching , create key for device
        NSString *uuid  = [self createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:UUID_USER_DEFAULTS_KEY account:@"user"];
        // this is the one time process
    }
    
    //download makes, models if not present
    self.downloadMakesOperationQueue=[[NSOperationQueue alloc]init];
    [self.downloadMakesOperationQueue setName:@"App Delegate Queue"];
    [self.downloadMakesOperationQueue setMaxConcurrentOperationCount:1];
    
    [self checkConditionForDownloadingMakes];
    
    
    if (launchOptions != nil) {
        
        NSLog(@"Try to move from here");
//        TabBarViewController *tabViewController = [[TabBarViewController alloc] init];
//        
//        [tabViewController setSelectedIndex:2];
        
        self.launchDic = [[NSDictionary alloc]initWithDictionary:launchOptions];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Trying to move 3rd Tab" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
        
    }
    else
    {
        NSLog(@"Normal view");
    }
    return YES;
}


//////----------
//- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//
//{
//    
//    
//    
//    NSString * tokenAsString = [[[deviceToken description]
//                                 
//                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
//                                
//                                stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    
//    
//    NSLog(@"My token is: %@", tokenAsString);
//    
//    device_id = tokenAsString;
//    
//    NSString* url = [[NSString alloc]initWithFormat:@"%@%@/iphone",PUSH_URL,tokenAsString];
//    
//    
//    
//    NSLog(@"REQUEST is %@",url);
//    
//    //NSError* error = nil;
//    
//    //[NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSASCIIStringEncoding error:&error];
//    
//    
//    
//    DCConnection* conDelegate = [[DCConnection alloc]init];
//    
//    NSURL *urlc = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:urlc];
//    
//    NSURLConnection *con; 
//    
//    con = [[NSURLConnection alloc]initWithRequest:request delegate:conDelegate];
//    
//    
//    
//}
//
//- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
//
//{
//    
//    NSLog(@"Failed to get token, error: %@", error);
//    
//}
//
//
//
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//
//{
//    
//    UIApplicationState state = [application applicationState];
//    
//    if (state == UIApplicationStateActive) {
//        
//        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"DC iPhone app"
//                                  
//                                                            message:message
//                                  
//                                                           delegate:nil
//                                  
//                                                  cancelButtonTitle:@"OK"
//                                  
//                                                  otherButtonTitles:nil, nil];
//        
//        [alertView show];
//        
//        alertView = nil;
//        
//    } 
////
////    
////    
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//
//{
//    
//    if (buttonIndex == 0)
//        
//    {
//        
//        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//        
//        
//        
//        if ([device_id length] > 1 && device_id != nil)
//            
//        {
//            
//            NSString* url = [[NSString alloc]initWithFormat:@"%@%@/iphone",PUSH_URL,device_id];
//            
//            //NSLog(@"%@",url);
//            
//            
//            
//            // UPLOAD TO SERVER.
//            
//            //NSLog(@"REQUEST is %@",url);
//            
//            
//            
//            DCConnection* conDelegate = [[DCConnection alloc]init];
//            
//            NSURL *urlc = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//            
//            NSURLRequest *request = [NSURLRequest requestWithURL:urlc];
//            
//            NSURLConnection *con; 
//            
//            con = [[NSURLConnection alloc]initWithRequest:request delegate:conDelegate];
//            
//        }
//        
//        
//        
//    }
//    
//    
//}

///////--------

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSString * tokenAsString = [[[deviceToken description]
                                 
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
 
     NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *deviceTKNum = [NSUserDefaults standardUserDefaults];
    [deviceTKNum setObject:tokenAsString forKey:@"deviceTokenIDKey"];
    [deviceTKNum synchronize];
    
	NSLog(@"My token is: %@", tokenAsString);
    
    
    //BrandID == 2 for MobiCarz
    ///BrandID == 1 for UCE
    
    
    NSString* url = [[NSString alloc]initWithFormat:@"http://www.unitedcarexchange.com/NotificationService/Service.svc/SaveDevice/%@/Iphone/%@/2/",tokenAsString,retrieveduuid];
    //
    //
    //
        NSLog(@"REQUEST is %@",url);
   
  
    //
        NSURL *urlc = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
        NSURLRequest *request = [NSURLRequest requestWithURL:urlc];
    
        NSURLConnection *con;
    
        con = [[NSURLConnection alloc]initWithRequest:request delegate:nil];
    
    if (con)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device ID Registered" message:tokenAsString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];

    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device ID Not Registered" message:tokenAsString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }

    
/// here append the device tocken to url.
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DeviceTKID" message:tokenAsString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
//    
//    
//    NSUserDefaults *deviceTKNum = [NSUserDefaults standardUserDefaults];
//    [deviceTKNum setObject:tokenAsString forKey:@"deviceTokenIDKey"];
//    [deviceTKNum synchronize];
    
//	NSLog(@"My token is: %@", tokenAsString);
}




- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
    
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo

{
    
    
    
    NSLog(@"userInfo %@",userInfo);
    
    for (id key in userInfo)
    {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    
    [application setApplicationIconBadgeNumber:[[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue]];
    
    NSLog(@"Badge %d",[[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue]);
    
    NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    

//    UIApplicationState state = [application applicationState];
//
//    if (state == UIApplicationStateActive) {
//
//        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
//
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"MobiCarz Notification"
//
//                                                            message:message
//
//                                                           delegate:nil
//
//                                                  cancelButtonTitle:@"OK"
//
//                                                  otherButtonTitles:nil, nil];
//
//        [alertView show];
//
//        alertView = nil;
//
//    }



}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
   
    
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
     [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MakesModels" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UCE.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Downloading Makes, models

- (void)checkConditionForDownloadingMakes
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *date=[defaults objectForKey:@"SavedDate"];
    
    //or check is existing makes is nil .ie., previously downloaded makes became corrupt
    //fetching makes
    NSEntityDescription *makesEntityDesc=[NSEntityDescription entityForName:@"Makes" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *makesRequest=[[NSFetchRequest alloc]init];
    [makesRequest setEntity:makesEntityDesc];
    NSError *makesError;
    NSArray *allMakes=[self.managedObjectContext executeFetchRequest:makesRequest error:&makesError];
    
    //fetching models
    NSEntityDescription *modelsEntityDesc=[NSEntityDescription entityForName:@"Models" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *modelsRequest=[[NSFetchRequest alloc] init];
    [modelsRequest setEntity:modelsEntityDesc];
    NSError *modelsError;
    NSArray *allModels=[self.managedObjectContext executeFetchRequest:modelsRequest error:&modelsError];
    
    
    //check for allMakes empty or not instead of self.makesDictionary nil or not
    

    if (date==nil || IsEmpty(allMakes)||IsEmpty(allModels)) {
        date=[NSDate date];
        //NSLog(@"date is %@",date);
        
        [defaults setObject:date forKey:@"SavedDate"];
        [defaults synchronize];
        
        //download makes, models
        [self downloadMakesIfNotPresent];
    }
    else
    {
        NSCalendar *gregorian=[NSCalendar autoupdatingCurrentCalendar];
        NSTimeZone *timezone=[NSTimeZone systemTimeZone];
        
        //NSLog(@"SavedDate=%@",date);
        
        NSDateComponents *dateComponents=[[NSDateComponents alloc] init];
        [dateComponents setCalendar:gregorian];
        [dateComponents setTimeZone:timezone];
        
        [dateComponents setDay:30];
        //[dateComponents setMinute:1];
        
        NSDate *newDate=[gregorian dateByAddingComponents:dateComponents toDate:date options:0];
        //NSLog(@"new date is %@",newDate);
        
        NSDate *currentDate=[NSDate date];
        
        
        if ([currentDate compare:newDate]==NSOrderedDescending) {
            //NSLog(@"new date is newer than old date");
            
            //download makes, models
            [self downloadMakesIfNotPresent];
        }
    }
}

- (void)downloadMakesIfNotPresent
{
    [self startDownloadMakesOperation];
    /*
     //
     //AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
     //self.managedObjectContext=[delegate managedObjectContext];
     
     //fetching makes
     NSEntityDescription *makesEntityDesc=[NSEntityDescription entityForName:@"Makes" inManagedObjectContext:self.managedObjectContext];
     NSFetchRequest *makesRequest=[[NSFetchRequest alloc]init];
     [makesRequest setEntity:makesEntityDesc];
     NSError *makesError;
     NSArray *allMakes=[self.managedObjectContext executeFetchRequest:makesRequest error:&makesError];
     
     //fetching models
     NSEntityDescription *modelsEntityDesc=[NSEntityDescription entityForName:@"Models" inManagedObjectContext:self.managedObjectContext];
     NSFetchRequest *modelsRequest=[[NSFetchRequest alloc] init];
     [modelsRequest setEntity:modelsEntityDesc];
     NSError *modelsError;
     NSArray *allModels=[self.managedObjectContext executeFetchRequest:modelsRequest error:&modelsError];
     //NSLog(@"allMakes=%@ makesError=%@ allModels=%@ modelsError=%@",allMakes,makesError,allModels,modelsError);
     
     
     //check for allMakes empty or not instead of self.makesDictionary nil or not
     if (IsEmpty(allMakes)||IsEmpty(allModels)) {
     */
    //lets call updateMakesModelsButtonTapped, so it will take care of downloading makes and models
    //[self updateMakesModelsButtonTapped];
    //}
    
}

-(void)updateMakesModelsButtonTapped
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSThread detachNewThreadSelector:@selector(showActivityViewer) toTarget:self withObject:nil];
    
    //[[self makesPicker] setUserInteractionEnabled:NO];
    //[[self modelsPicker] setUserInteractionEnabled:NO];
    /*
     NSString *fileLocation = [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"png"];
     NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
     
     
     [SVStatusHUD showWithImage:[UIImage imageWithData:imageData]];
     */
    
    [self startDownloadMakesOperation];
    /*
     + (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType networkIndicator:(BOOL)show;
     +
     */
}




-(void)startDownloadMakesOperation
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadMakesNotifMethod:) name:kDownloadMakesNotif object:nil];
    
    DownloadMakesOperation *downloadMakesOperation=[[DownloadMakesOperation alloc]init];
    [self.downloadMakesOperationQueue addOperation:downloadMakesOperation];
    
   
}

-(void)kDownloadMakesNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadMakesNotifMethod:) withObject:notif waitUntilDone:NO];
    }
    else
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadMakesNotif object:nil];
        
        //[self loadMakesDataFromDisk];
        [self startDownloadModelsOperation];
    }
    [self hideActivityViewer];
    
}


-(void)startDownloadModelsOperation
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kDownloadModelsNotifMethod:) name:kDownloadModelsNotif object:nil];
    
    DownloadModelsOperation *downloadModelsOperation=[[DownloadModelsOperation alloc]init];
    [self.downloadMakesOperationQueue addOperation:downloadModelsOperation];
     [self hideActivityViewer];
}

-(void)kDownloadModelsNotifMethod:(NSNotification *)notif
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(kDownloadModelsNotifMethod:) withObject:notif waitUntilDone:NO];
        return;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDownloadModelsNotif object:nil];
    
    //[SVStatusHUD dismissView];
    
    [self hideActivityViewer];
}

-(void)showActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    NSString *fileLocation;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {

    
    if(([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight))
    {
        //Do what you want in Landscape Left
        fileLocation = [[NSBundle mainBundle] pathForResource:@"loadingiPadF" ofType:@"png"];
    }
    }
    else
    {
    fileLocation = [[NSBundle mainBundle] pathForResource:@"loading2" ofType:@"png"];
    }
    NSData *imageData = [NSData dataWithContentsOfFile:fileLocation];
    
    
    UIImage *backgroundImage=[[UIImage alloc] initWithData:imageData];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImage=nil;
    
    backgroundImageView.alpha = 1.0f;
    backgroundImageView.tag=999;
    
    UIActivityIndicatorView *activityIndicatorView;
    if (activityIndicatorView!=nil) {
        activityIndicatorView=nil;
    }
    activityIndicatorView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //activityIndicatorView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
    activityIndicatorView.center=self.window.center;
    activityIndicatorView.tag  = 1000;
    
    
    
    activityIndicatorView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
    
    [backgroundImageView addSubview:activityIndicatorView];
    [self.window addSubview:backgroundImageView];
    [activityIndicatorView startAnimating];
    
    
}

-(void)hideActivityViewer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UIActivityIndicatorView *tmpIndicatorView = (UIActivityIndicatorView *)[self.window viewWithTag:1000];
    tmpIndicatorView.hidesWhenStopped=YES;
    [tmpIndicatorView stopAnimating];
    [tmpIndicatorView removeFromSuperview];
    tmpIndicatorView=nil;
    
    
    UIImageView *tmpImgView=(UIImageView *)[self.window viewWithTag:999];
    [tmpImgView removeFromSuperview];
    tmpImgView=nil;
}


@end
