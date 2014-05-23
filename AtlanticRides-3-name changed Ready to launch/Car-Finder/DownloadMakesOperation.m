//
//  DownloadMakesOperation.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadMakesOperation.h"
#import "Makes.h"
#import "AppDelegate.h"


#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics


NSString *kDownloadMakesNotif=@"DownloadMakesNotif";
NSString *kMakesDictNotifKey=@"makesDictKey";



@interface DownloadMakesOperation()
@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

- (void) saveMakesDataToDisk:(NSArray *)aMakesArray;
- (void)handleDoesNotRespondToSelectorError;

//coredata
-(void)deletePersistantStore; //or inaction if u have button

@end

@implementation DownloadMakesOperation
@synthesize connection1=_connection1,data1=_data1;

@synthesize managedObjectContext=_managedObjectContext,persistentStoreCoordinator=_persistentStoreCoordinator;


-(id)init
{
    self=[super init];
    if(self)
    {
        //
    }
    return self;
}

-(void)loadMyData
{
    //Get Makes
   // http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetMakeCounts/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/12345
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetMakeCounts/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",retrieveduuid];
    NSURL *url = [NSURL URLWithString:urlStr];
    
   // NSURL *url = [NSURL URLWithString:@"http://unitedcarexchange.com/MobileService/Service.svc/GetMakes/"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    
    NSURLConnection *testConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    self.connection1 = testConnection1;
    
    testConnection1=nil;
    
    NSAssert(self.connection1!=nil, @"Failure to create URL connection");
    
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    
    if(self.connection1)
    {
        self.data1 = [[NSMutableData alloc]init];
    }
    else
    {
        NSLog(@"theConnection is NULL in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
    
    req=nil;
    url=nil;
    
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.data1 setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.data1 appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    self.connection1=nil;
    self.data1=nil;
    
	[[NSNotificationCenter defaultCenter]postNotificationName:@"MakesOperationDownloadErrorNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"MakesOperationDownloadErrorKey"]];
	
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSError *error;
    
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    NSArray *makesArray=[wholeResult objectForKey:@"GetMakeCountsResult"]; //previously GetMakesResult
    
    if([makesArray respondsToSelector:@selector(objectAtIndex:)])
    {
        //delete previous persistent store
        [self deletePersistantStore];
        [self saveMakesDataToDisk:makesArray];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kDownloadMakesNotif object:self userInfo:nil];
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        [self handleDoesNotRespondToSelectorError];
    }
    
    makesArray=nil;
    wholeResult=nil;
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void) saveMakesDataToDisk:(NSArray *)aMakesArray {
    //
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=[delegate managedObjectContext];
    
    //makes
    
    Makes *makesRecord1;
    
    //NSLog(@"aMakesArray %d",[aMakesArray count]);
    
    for (NSDictionary *individualMakeDict in aMakesArray) {
        NSNumber *makeidnum=[individualMakeDict objectForKey:@"_MakeID"];
        NSString *makeid=[NSString stringWithFormat:@"%d",[makeidnum integerValue]];
        NSString *makeName=[individualMakeDict objectForKey:@"_Make"];
        NSInteger carsCount=[[individualMakeDict objectForKey:@"_MakeCount"] integerValue];
        
        makesRecord1=[NSEntityDescription insertNewObjectForEntityForName:@"Makes" inManagedObjectContext:self.managedObjectContext];
        makesRecord1.makeID=makeid;
        makesRecord1.makeName=makeName;
        makesRecord1.carsCount=[NSNumber numberWithInteger:carsCount];
        
        makeName=nil;
        makeid=nil;
        makeidnum=nil;
    }   
    
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"there was an error saving the context. %@ - %@ - %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    }
}


-(void)main
{
    [self loadMyData];
}

- (void)handleDoesNotRespondToSelectorError
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Failed to get data." forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"UCE" code:404 userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MakesOperationDownloadErrorNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"MakesOperationDownloadErrorKey"]];
}

-(void)deletePersistantStore
{
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    
    self.persistentStoreCoordinator=[delegate persistentStoreCoordinator];
    NSPersistentStore *store = [[self.persistentStoreCoordinator persistentStores] lastObject];
    NSURL *storeURL = [[delegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"UCE.sqlite"]; //sqlite filename must be same as app name
    NSError *error;
    
    [self.persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    if(self.persistentStoreCoordinator != nil) {
        //delegate.managedObjectContext=[[NSManagedObjectContext alloc] init];
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
}


-(void)dealloc
{
    
    [_connection1 cancel];
    //NSLog(@"retain count of self.connection1 in DownloadMakesOperation is %ld",CFGetRetainCount((__bridge CFTypeRef)_connection1));
    _connection1=nil;
    //NSLog(@"retain count of self.data1 in DownloadMakesOperation is %ld",CFGetRetainCount((__bridge CFTypeRef)_data1));
    _data1=nil;
    
}

@end
