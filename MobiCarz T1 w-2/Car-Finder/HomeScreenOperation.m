//
//  HomeScreenOperation.m
//  XMLTable2
//
//  Created by Mac on 06/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeScreenOperation.h"
#import "PopularCarsCellInfo.h"
#import "CarRecord.h"
#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics



@interface HomeScreenOperation()

@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

- (void)handleDoesNotRespondToSelectorError;
- (void)callHomeScreenOperationFailedMethod:(NSError *)error;
- (void)handleJSONError:(NSError *)error;


@end


@implementation HomeScreenOperation



-(void)loadMyData:(NSInteger)currentPage1 pageSize:(NSInteger)pageSize1 usersZip:(NSString *)usersZip1
{
    
    //http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetRecentCarsMobile/1/20/Price/Asc/44146/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/12345
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetRecentCarsMobile/%d/%d/Price/Asc/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@",currentPage1,pageSize1,usersZip1,retrieveduuid];
    
    
    
    // NSString *webServiceUrl=[NSString stringWithFormat:@"http://unitedcarexchange.com/MobileService/Service.svc/GetRecentCarsMobile/%d/%d/Price/Asc/%@/",currentPage1,pageSize1,usersZip1];
    
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    self.connection1 = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
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
    NSString *errorString=[NSString stringWithFormat:@"Connection Failed in HomeScreenOperation with error: %@",[error localizedDescription]];
    [userInfo setValue:errorString forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    
    [self callHomeScreenOperationFailedMethod:error2];
	
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
    NSMutableArray *tempArrayOfPopularCarsCellInfoObjects=[[NSMutableArray alloc]init];
    self.arrayOfPopularCarsCellInfoObjects=tempArrayOfPopularCarsCellInfoObjects;
    tempArrayOfPopularCarsCellInfoObjects=nil;
    
    NSError *error;
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    if (wholeResult==nil) {
        [self handleJSONError:error];
        return;
    }
    
    NSArray *getRecentCarsMobileResult=[wholeResult objectForKey:@"GetRecentCarsMobileResult"];
    
    //NSInteger i=1;
    
    
    if([getRecentCarsMobileResult respondsToSelector:@selector(objectAtIndex:)])
    {
        for (NSDictionary *individualcar in getRecentCarsMobileResult) {
            
            //convert this dictionary to carrecord object
            PopularCarsCellInfo *pcCellInfo=[[PopularCarsCellInfo alloc]init];
            
            CarRecord *car=[[CarRecord alloc]initWithDictionary:individualcar];
            [pcCellInfo setCar:car];
            [self.arrayOfPopularCarsCellInfoObjects addObject:pcCellInfo];
            
            car=nil;
            pcCellInfo=nil;
            
            
        }
        
                if ([self.arrayOfPopularCarsCellInfoObjects count]==0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NoResultsForThisZipNotif" object:self];
        }
        else if ([self.arrayOfPopularCarsCellInfoObjects count]>0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"WorkingArrayFromHomeScreenOperationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:self.arrayOfPopularCarsCellInfoObjects forKey:@"HomeScreenOperationResultsKey"]];
        }
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        self.connection1 = nil;
        self.data1=nil;
        self.arrayOfPopularCarsCellInfoObjects=nil;
        
        [self handleDoesNotRespondToSelectorError];
    }
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)main
{
    [self loadMyData:self.pageNoReceived pageSize:self.pageSizeReceived usersZip:self.usersZipReceived];
}


-(void)callHomeScreenOperationFailedMethod:(NSError *)error
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HomeScreenOperationFailedNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"HomeScreenOperationFailedNotifKey"]];
}

- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in HomeScreenOperation" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callHomeScreenOperationFailedMethod:error2];
    
}

- (void)handleDoesNotRespondToSelectorError
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"DoesNotRespondToSelector error in HomeScreenOperation" forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"UCE" code:404 userInfo:userInfo];
    [self callHomeScreenOperationFailedMethod:error];
}

-(void)dealloc
{
    [_connection1 cancel];
    _connection1 = nil;
    _data1=nil;
    _arrayOfPopularCarsCellInfoObjects=nil;
    _usersZipReceived=nil;
}



@end
