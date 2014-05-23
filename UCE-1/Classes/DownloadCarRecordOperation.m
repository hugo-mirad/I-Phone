//
//  DownloadCarRecordOperation.m
//  XMLTable2
//
//  Created by Mac on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadCarRecordOperation.h"
#import "CarRecord.h"

@interface DownloadCarRecordOperation()
@property(strong,nonatomic) CarRecord *workingEntry;
@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

- (void)handleDoesNotRespondToSelectorError;
@end


@implementation DownloadCarRecordOperation
@synthesize caridReceived=_caridReceived,workingEntry=_workingEntry,connection1=_connection1,data1=_data1;


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //   
    }
    return self;
}


-(void)loadMyData:(NSInteger)someCarId
{
    
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/FindCarID/%d/",someCarId];
    
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    
    NSAssert(self.connection1!=nil, @"Failure to create URL connection");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    if(self.connection1)
    {
        self.data1 = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
    
    req=nil;
    url=nil;
    webServiceUrl=nil;
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
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (error!=nil)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorDownloadingCarRecordNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"ErrorDownloadingCarRecordNotifKey"]];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.workingEntry = nil;
    
    NSError *error;
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    
    
    NSArray *findCarIDResult=[wholeResult objectForKey:@"FindCarIDResult"];
    
    if([findCarIDResult respondsToSelector:@selector(objectAtIndex:)])
    {
        //    NSLog(@"received FindCarIDResult=%@",findCarIDResult);
        
        
        if (!findCarIDResult.count) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NoCarForThisIdNotif" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.caridReceived] forKey:@"caridResultKey"]];
            
            return;
        }
        
        NSDictionary *individualcar = [findCarIDResult objectAtIndex:0];
        
        //        NSLog(@"individualcar is %@",individualcar);
        
        //convert this dictionary to carrecord object
        CarRecord *tempWorkingEntry=[[CarRecord alloc]initWithDictionary:individualcar];
        self.workingEntry=tempWorkingEntry;
        tempWorkingEntry=nil;
        
        
        if (self.workingEntry==nil) {
            if (self.caridReceived!=0)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"NoCarForThisIdNotif" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.caridReceived] forKey:@"caridResultKey"]];
            }
        }
        else
        {
            //NSLog(@"retain count of self.workingEntry before performSelectorOnMainThread is %ld",CFGetRetainCount((__bridge CFTypeRef)self.workingEntry));
            
            CarRecord *tempCarRecord=self.workingEntry;
            
            NSMutableDictionary *tempUserInfo=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tempCarRecord, @"DownloadCarRecordOperationResults",nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CarRecordFromDownloadCarRecordOperationNotif" object:self userInfo:tempUserInfo];
            
            [tempUserInfo removeObjectForKey:@"DownloadCarRecordOperationResults"];
            tempUserInfo=nil;
            
            tempCarRecord=nil;
            //NSLog(@"retain count of self.workingEntry after performSelectorOnMainThread is %ld",CFGetRetainCount((__bridge CFTypeRef)self.workingEntry));
            
        }
        individualcar=nil;
        
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        self.connection1 = nil;
        self.data1=nil;
        self.workingEntry=nil;
        
        [self handleDoesNotRespondToSelectorError];
    }
    
    error=nil;
    wholeResult=nil;
    findCarIDResult=nil;
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)main
{
    [self loadMyData:self.caridReceived];
}

- (void)handleDoesNotRespondToSelectorError
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Failed to get data." forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"UCE" code:404 userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorDownloadingCarRecordNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"ErrorDownloadingCarRecordNotifKey"]];
    
}

-(void)dealloc
{
    
    //NSLog(@"retain count of self.connection1 in dealloc is %ld",CFGetRetainCount((__bridge CFTypeRef)_connection1));
    _connection1=nil;
    
    //4NSLog(@"retain count of self.data1 in dealloc is %ld",CFGetRetainCount((__bridge CFTypeRef)_data1));
    _data1=nil;
    
    //NSLog(@"retain count of self.workingEntry in dealloc is %ld",CFGetRetainCount((__bridge CFTypeRef)_workingEntry));
    _workingEntry=nil;
}

@end
