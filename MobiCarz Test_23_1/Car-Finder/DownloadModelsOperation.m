//
//  DownloadModelsOperation.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadModelsOperation.h"
#import "Models.h"
#import "AppDelegate.h"

#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

NSString *kDownloadModelsNotif=@"DownloadModelsNotif";
NSString *kModelsDictNotifKey=@"modelsDictKey";


@interface DownloadModelsOperation()
@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;


- (void) saveModelsDataToDisk:(NSArray *)arrayModels;
- (void)handleDoesNotRespondToSelectorError;


@end


@implementation DownloadModelsOperation
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
    //GetModelsInfo

     NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];


#warning Modified New web service_16/06/2014 Download Models
    NSString *urlStr = [NSString stringWithFormat:@"http://test1.unitedcarexchange.com/MobileService/GenericServices.svc/GenericGetModelsInfo/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",retrieveduuid];//New
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    
    if( self.connection1)
    {
        NSMutableData *tempData1=[[NSMutableData alloc]init];
        self.data1 = tempData1;
        tempData1=nil;
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
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    self.connection1=nil;
    self.data1=nil;
    
	UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Check Internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
    alert=nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
    NSError *error=nil;
    
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    
    NSArray *modelsArray=[wholeResult objectForKey:@"GenericGetModelsInfoResult"];
    
    if([modelsArray respondsToSelector:@selector(objectAtIndex:)])
    {
        [self saveModelsDataToDisk:modelsArray];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kDownloadModelsNotif object:self userInfo:nil];
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        [self handleDoesNotRespondToSelectorError];
    }
    
    modelsArray=nil;
    wholeResult=nil;
    //stringData=nil;
    //data=nil;
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}


- (void) saveModelsDataToDisk:(NSMutableArray *)arrayModels {
    //
    AppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    self.managedObjectContext=[delegate managedObjectContext];
    //
    //models
    
    NSNumber *makeidnum;
    NSString *makeid;
    NSNumber *modelidnum;
    NSString *modelId;
    NSString *modelName;
    
    for (NSDictionary *individualModelDict in arrayModels) {
        
        makeidnum=[individualModelDict objectForKey:@"_MakeID"];
        
        makeid=[[NSString alloc]initWithFormat:@"%d",[makeidnum integerValue]];
        
        modelidnum=[individualModelDict objectForKey:@"_MakeModelID"];
        modelId=[[NSString alloc]initWithFormat:@"%d",[modelidnum integerValue]];
        
        modelName=[individualModelDict objectForKey:@"_Model"];
        
        
        
        Models *modelsRecord1=[NSEntityDescription insertNewObjectForEntityForName:@"Models" inManagedObjectContext:self.managedObjectContext];
        modelsRecord1.makeID=makeid;
        modelsRecord1.modelID=modelId;
        modelsRecord1.modelName=modelName;
        
    } 
    
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"there was an error saving the context. %@:%@  %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    }
    
  
}


-(void)main
{
    //NSLog(@"inside main of DownloadModelsOperation ");
    [self loadMyData];
}

- (void)handleDoesNotRespondToSelectorError
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Makes could not be retrieved as MobiCarz server is down." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}


-(void)dealloc
{
    [_connection1 cancel];
    _connection1=nil;
    _data1=nil;
}

@end
