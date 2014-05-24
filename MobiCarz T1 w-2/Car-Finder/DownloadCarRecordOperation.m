//
//  DownloadCarRecordOperation.m
//  XMLTable2
//
//  Created by Mac on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadCarRecordOperation.h"
#import "CarRecord.h"

#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics




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
    
    
    
      NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/FindCarID/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",someCarId,retrieveduuid];
    
   // NSString *webServiceUrl=[NSString stringWithFormat:@"http://unitedcarexchange.com/MobileService/Service.svc/FindCarID/%d/",someCarId];
    
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    
    NSAssert(self.connection1!=nil, @"Failure to create URL connection");
    
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
    
    
    if (error!=nil)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorDownloadingCarRecordNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"ErrorDownloadingCarRecordNotifKey"]];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    self.workingEntry = nil;
    
    NSError *error;
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    
    
    NSArray *findCarIDResult=[wholeResult objectForKey:@"FindCarIDResult"];
    
    if([findCarIDResult respondsToSelector:@selector(objectAtIndex:)])
    {
        
        
        if (!findCarIDResult.count) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NoCarForThisIdNotif" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.caridReceived] forKey:@"caridResultKey"]];
            
            return;
        }
        
        NSDictionary *individualcar = [findCarIDResult objectAtIndex:0];
        
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
            
            CarRecord *tempCarRecord=self.workingEntry;
            
            NSMutableDictionary *tempUserInfo=[[NSMutableDictionary alloc] initWithObjectsAndKeys:tempCarRecord, @"DownloadCarRecordOperationResults",nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CarRecordFromDownloadCarRecordOperationNotif" object:self userInfo:tempUserInfo];
            
            [tempUserInfo removeObjectForKey:@"DownloadCarRecordOperationResults"];
            tempUserInfo=nil;
            
            tempCarRecord=nil;
            
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
    
    NSError *error=[NSError errorWithDomain:@"MobiCarz" code:404 userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ErrorDownloadingCarRecordNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"ErrorDownloadingCarRecordNotifKey"]];
    
}

-(void)dealloc
{
    
    _connection1=nil;
    _data1=nil;
    _workingEntry=nil;
}

@end
