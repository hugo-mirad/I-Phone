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
    NSURL *url = [NSURL URLWithString:@"http://unitedcarexchange.com/carservice/Service.svc/GetModelsInfo/"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    self.connection1=nil;
    self.data1=nil;
    
	UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Check Internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
    alert=nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    NSError *error=nil;
    
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    
    NSArray *modelsArray=[wholeResult objectForKey:@"GetModelsInfoResult"];
    
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
    
    
    //working fine
    //fetching models
    //fetching
    NSEntityDescription *modelsEntityDesc=[NSEntityDescription entityForName:@"Models" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    
    [request setEntity:modelsEntityDesc];
    
    NSPredicate *filter=[NSPredicate predicateWithFormat:@"makeID like[c] %@",@"1"];
    [request setPredicate:filter];
    
    NSArray *allmodels=[self.managedObjectContext executeFetchRequest:request error:&error];
    for (Models *aModel in allmodels) {
        //NSLog(@"model id=%@ name=%@",[aModel valueForKey:@"modelID"],[aModel valueForKey:@"modelName"]);
    }
}


-(void)main
{
    //NSLog(@"inside main of DownloadModelsOperation ");
    [self loadMyData];
}

- (void)handleDoesNotRespondToSelectorError
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Makes could not be retreived as UCE server is down." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}


-(void)dealloc
{
    //NSLog(@"DownloadModelsOperation dealloc called");
    [_connection1 cancel];
    //NSLog(@"retain count of self.connection1 in DownloadMakesOperation is %ld",CFGetRetainCount((__bridge CFTypeRef)_connection1));
    _connection1=nil;
    //NSLog(@"retain count of self.data1 in DownloadMakesOperation is %ld",CFGetRetainCount((__bridge CFTypeRef)_data1));
    _data1=nil;
}

@end
