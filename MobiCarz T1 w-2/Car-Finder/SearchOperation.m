//
//  SearchOperation.m
//  XMLTable2
//
//  Created by Mac on 14/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchOperation.h"
#import "CarRecord.h"

#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics

//#import "SearchResultsCustomCellInfo.h"

#import "SearchResultsCollectionCellInfo.h"


@interface SearchOperation()

@property(retain,nonatomic) CarRecord *workingEntry;

@property(strong,nonatomic) NSMutableArray  *workingArray,*arrayOfAllSearchResultsCustomCellInfoObjects;
@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;



- (void)handleDoesNotRespondToSelectorError;
- (void)callSearchOperationFailedMethod:(NSError *)error;
- (void)handleJSONError:(NSError *)error;

@end


@implementation SearchOperation
@synthesize makeIdReceived=_makeIdReceived,modelIdReceived=_modelIdReceived,zipReceived=_zipReceived,milesReceived=_milesReceived,workingEntry=_workingEntry,workingArray=_workingArray,makeNameReceived=_makeNameReceived,modelNameReceived=_modelNameReceived,pageNoReceived=_pageNoReceived,arrayOfAllSearchResultsCustomCellInfoObjects=_arrayOfAllSearchResultsCustomCellInfoObjects;

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
    
   // Search screen
//http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetCarsSearchJSON/Alfa Romeo/Spider/92404/5/1/9/Price/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/12345 
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
     NSString *webServiceUrl=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetCarsSearchJSON/%@/%@/%@/%@/%d/18/Price/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",someMakeNameReceived,someModelNameReceived,someZipReceived,someMilesReceived,somePageNo,retrieveduuid];
    
    
    
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    self.connection1 = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    
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
    
    _connection1=nil;
    
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *errorString=[NSString stringWithFormat:@"Connection Failed in SearchOperation with error: %@",[error localizedDescription]];
    [userInfo setValue:errorString forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    
    [self callSearchOperationFailedMethod:error2];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    self.workingArray = [[NSMutableArray alloc]init];
    self.arrayOfAllSearchResultsCustomCellInfoObjects=[[NSMutableArray alloc]init];
    
    
    NSError *error;
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    if (wholeResult==nil) {
        
        [self handleJSONError:error];
        return;
    }
    
    
    NSArray *getCarsSearchJSONResult=[wholeResult objectForKey:@"GetCarsSearchJSONResult"];
    
    if([getCarsSearchJSONResult respondsToSelector:@selector(objectAtIndex:)])
    {
        
        
               
        for (NSDictionary *individualcar in getCarsSearchJSONResult) {
            
           
            
            //convert this dictionary to carrecord object
            
            SearchResultsCollectionCellInfo *srcCellInfo=[[SearchResultsCollectionCellInfo alloc]init];
            CarRecord *car=[[CarRecord alloc]initWithDictionary:individualcar];
            
           
                [srcCellInfo setCar:car];
            
            [self.arrayOfAllSearchResultsCustomCellInfoObjects addObject:srcCellInfo];
            
           
            car=nil;
            srcCellInfo=nil;
            
            
        }
        
                if ([self.arrayOfAllSearchResultsCustomCellInfoObjects count]==0) {
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CountOfSearchResultsNotif" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:[self.arrayOfAllSearchResultsCustomCellInfoObjects count]] forKey:@"CountOfSearchResults"]];
        }
        else if ([self.arrayOfAllSearchResultsCustomCellInfoObjects count]>0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"WorkingArrayFromSearchOperationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:self.arrayOfAllSearchResultsCustomCellInfoObjects forKey:@"SearchOperationResults"]];
        }
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        
        self.connection1 = nil;
        self.data1=nil;
        self.workingArray=nil;
        self.workingEntry=nil;
        self.arrayOfAllSearchResultsCustomCellInfoObjects=nil;
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
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self callSearchOperationFailedMethod:error2];
    
}


- (void)handleDoesNotRespondToSelectorError
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"DoesNotRespondToSelector in SearchOperation" forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"MobiCarz" code:404 userInfo:userInfo];
    
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
