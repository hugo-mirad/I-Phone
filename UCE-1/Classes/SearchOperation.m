//
//  SearchOperation.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchOperation.h"
#import "CarRecord.h"


@interface SearchOperation()

@property(retain,nonatomic) CarRecord *workingEntry;

@property(strong,nonatomic) NSMutableArray  *workingArray;
@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;



- (void)handleDoesNotRespondToSelectorError;
- (void)callSearchOperationFailedMethod:(NSError *)error;
- (void)handleJSONError:(NSError *)error;

@end


@implementation SearchOperation
@synthesize makeIdReceived=_makeIdReceived,modelIdReceived=_modelIdReceived,zipReceived=_zipReceived,milesReceived=_milesReceived,workingEntry=_workingEntry,workingArray=_workingArray,makeNameReceived=_makeNameReceived,modelNameReceived=_modelNameReceived,pageNoReceived=_pageNoReceived;

@synthesize connection1=_connection1,data1=_data1;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //intialize ivars
    }
    return self;
}


//-(void)loadMyData:(NSString *)someMakeIdReceived model:(NSString *)someModelIdReceived zip:(NSString *)someZipReceived miles:(NSString *)someMilesReceived
-(void)loadMyData:(NSString *)someMakeNameReceived model:(NSString *)someModelNameReceived zip:(NSString *)someZipReceived miles:(NSString *)someMilesReceived pageNo:(NSInteger)somePageNo

{
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/GetCarsSearchJSON/%@/%@/%@/%@/%d/9/Price/",someMakeNameReceived,someModelNameReceived,someZipReceived,someMilesReceived,somePageNo];
    
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"SearchOperation: webServiceUrl=%@",webServiceUrl);
    
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    self.connection1 = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if( self.connection1)
    {
        self.data1 = [NSMutableData data];
    }
    else
    {
        NSLog(@"SearchOperation: theConnection is NULL in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
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
    
    _connection1=nil;
    
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *errorString=[NSString stringWithFormat:@"Connection Failed in SearchOperation with error: %@",[error localizedDescription]];
    [userInfo setValue:errorString forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    
    [self callSearchOperationFailedMethod:error2];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.workingArray = [[NSMutableArray alloc]init];
    
    NSError *error;
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    if (wholeResult==nil) {
        //NSString *errorStr=[[NSString alloc] initWithData:self.data1 encoding:NSUTF8StringEncoding];
        //NSLog(@"JSON error string is : %@",errorStr);
        //NSLog(@"error link is: %@",[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        [self handleJSONError:error];
        return;
    }
    
    
    NSArray *getCarsSearchJSONResult=[wholeResult objectForKey:@"GetCarsSearchJSONResult"];
    
    if([getCarsSearchJSONResult respondsToSelector:@selector(objectAtIndex:)])
    {
        for (NSDictionary *individualcar in getCarsSearchJSONResult) {
            
            //        NSLog(@"individualcar is %@",individualcar);
            
            //convert this dictionary to carrecord object
            CarRecord *carRecord=[[CarRecord alloc]initWithDictionary:individualcar];
            
            [self.workingArray addObject:carRecord]; 
            //NSLog(@"self.workingArray count = %d",[self.workingArray count]);
            //carRecord = nil;
        }
        
        if ([self.workingArray count]==0) {
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CountOfSearchResultsNotif" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[self.workingArray count]] forKey:@"CountOfSearchResults"]];
        }
        else if ([self.workingArray count]>0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"WorkingArrayFromSearchOperationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:self.workingArray forKey:@"SearchOperationResults"]];
        }
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        self.connection1 = nil;
        self.data1=nil;
        self.workingArray=nil;
        self.workingEntry=nil;
        
        [self handleDoesNotRespondToSelectorError];
    }
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)main
{
    [self loadMyData:self.makeNameReceived model:self.modelNameReceived zip:self.zipReceived miles:self.milesReceived pageNo:self.pageNoReceived];
    
}

- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in SearchOperation" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callSearchOperationFailedMethod:error2];
    
}


- (void)handleDoesNotRespondToSelectorError
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"DoesNotRespondToSelector in SearchOperation" forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"UCE" code:404 userInfo:userInfo];
    
    [self callSearchOperationFailedMethod:error];
}

- (void)callSearchOperationFailedMethod:(NSError *)error
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SearchOperationFailedNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"SearchOperationFailedNotifKey"]];
}

-(void)dealloc
{
    [_connection1 cancel];
    _connection1=nil;
    _data1=nil;
    _workingArray=nil;
    _workingEntry=nil;
    _makeIdReceived=nil;
    _modelIdReceived=nil;
    _zipReceived=nil;
    _milesReceived=nil;
    _makeNameReceived=nil;
    _modelNameReceived=nil;
}

@end
