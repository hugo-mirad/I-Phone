//
//  HomeScreenOperation.m
//  XMLTable2
//
//  Created by Mac on 06/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeScreenOperation.h"
#import "CustomCellInfo.h"
#import "CarRecord.h"


@interface HomeScreenOperation()

@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

- (void)handleDoesNotRespondToSelectorError;
- (void)callHomeScreenOperationFailedMethod:(NSError *)error;
- (void)handleJSONError:(NSError *)error;


@end


@implementation HomeScreenOperation
@synthesize pageNoReceived=_pageNoReceived,pageSizeReceived=_pageSizeReceived,usersZipReceived=_usersZipReceived,connection1=_connection1,data1=_data1,arrayOfAllCustomCellInfoObjects=_arrayOfAllCustomCellInfoObjects;


-(void)loadMyData:(NSInteger)currentPage1 pageSize:(NSInteger)pageSize1 usersZip:(NSString *)usersZip1
{
    
    NSString *webServiceUrl=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/GetRecentCarsMobile/%d/%d/Price/Asc/%@/",currentPage1,pageSize1,usersZip1];
    
    webServiceUrl=[webServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"webServiceUrl for HomeScreenOperation is %@",webServiceUrl);
    
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    self.connection1 = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    NSAssert(self.connection1!=nil, @"Failure to create URL connection");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    
    if(self.connection1)
    {
        //        NSLog(@"connection established.");
        self.data1 = [NSMutableData data];
        //        NSString *returnString = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        //        NSLog(@"Data returned is %@",returnString); 
    }
    else
    {
        NSLog(@"theConnection is NULL in %@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.data1 setLength:0];
    //	NSLog(@"did receive response%@",data1);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.data1 appendData:data];
    //	NSLog(@"DONE,Received Bytes => %d",[data1 length]);
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    _connection1=nil;
    
	NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *errorString=[NSString stringWithFormat:@"Connection Failed in HomeScreenOperation with error: %@",[error localizedDescription]];
    [userInfo setValue:errorString forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    
    [self callHomeScreenOperationFailedMethod:error2];
	
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
	
    NSMutableArray *tempArrayOfAllCustomCellInfoObjects=[[NSMutableArray alloc]init];
    self.arrayOfAllCustomCellInfoObjects=tempArrayOfAllCustomCellInfoObjects;
    tempArrayOfAllCustomCellInfoObjects=nil;
    
    NSError *error;
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    if (wholeResult==nil) {
        [self handleJSONError:error];
        return;
    }
    
    NSArray *getRecentCarsMobileResult=[wholeResult objectForKey:@"GetRecentCarsMobileResult"];
    
    NSInteger i=1;
    CustomCellInfo *cci=[[CustomCellInfo alloc]init];
    
    if([getRecentCarsMobileResult respondsToSelector:@selector(objectAtIndex:)])
    {
        for (NSDictionary *individualcar in getRecentCarsMobileResult) {
            
            //        NSLog(@"individualcar is %@",individualcar);
            
            //convert this dictionary to carrecord object
            
            CarRecord *car1=[[CarRecord alloc]initWithDictionary:individualcar];
            
            if(i==1)
                [cci setCar1:car1];
            
            else if(i==2)
                [cci setCar2:car1];
            
            else if(i==3)
                [cci setCar3:car1];
            i++;
            
            
            if(i==4 && ([getRecentCarsMobileResult count]/3>[self.arrayOfAllCustomCellInfoObjects count])){
                [self.arrayOfAllCustomCellInfoObjects addObject:cci];
                i=1;
                cci=nil;
                cci=[[CustomCellInfo alloc]init];
            }
            else if(i<=4 && ([getRecentCarsMobileResult count]/3==[self.arrayOfAllCustomCellInfoObjects count]))  // if this is the set of reminder dictionaries (<3) after using all dictionaries in result 
            {
                [self.arrayOfAllCustomCellInfoObjects addObject:cci];
            }
            
            car1=nil;
            
            //         NSLog(@"[arrayOfAllCustomCellInfoObjects count] inside else is %d",[arrayOfAllCustomCellInfoObjects count]);
            
        }
        cci=nil;
        /* 
         NSLog(@"arrayOfAllCustomCellInfoObjects count is %d",[arrayOfAllCustomCellInfoObjects count]);
         
         //test if arrayOfAllCustomCellInfoObjects is created properly or not.
         for (CustomCellInfo *cInfo in arrayOfAllCustomCellInfoObjects) {
         NSLog(@"Car1 details: %d - %@ - %@ - %d - %d - %@",[[cInfo car1] carid],[[cInfo car1] make],[[cInfo car1] model],[[cInfo car1] price],[[cInfo car1] year],[[cInfo car1] imagePath]);
         
         NSLog(@"Car2 details: %d - %@ - %@ - %d - %d - %@",[[cInfo car2] carid],[[cInfo car2] make],[[cInfo car2] model],[[cInfo car2] price],[[cInfo car2] year],[[cInfo car2] imagePath]);
         
         NSLog(@"Car3 details: %d - %@ - %@ - %d - %d - %@",[[cInfo car3] carid],[[cInfo car3] make],[[cInfo car3] model],[[cInfo car3] price],[[cInfo car3] year],[[cInfo car3] imagePath]);
         
         
         }
         */
        if ([self.arrayOfAllCustomCellInfoObjects count]==0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NoResultsForThisZipNotif" object:self];
        }
        else if ([self.arrayOfAllCustomCellInfoObjects count]>0)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"WorkingArrayFromHomeScreenOperationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:self.arrayOfAllCustomCellInfoObjects forKey:@"HomeScreenOperationResultsKey"]];
        }
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        self.connection1 = nil;
        self.data1=nil;
        self.arrayOfAllCustomCellInfoObjects=nil;
        
        [self handleDoesNotRespondToSelectorError];
    }
    cci=nil;
  	
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
    //NSLog(@"HomeScreenOperation dealloc called");
    
    _connection1 = nil;
    _data1=nil;
    _arrayOfAllCustomCellInfoObjects=nil;
    _usersZipReceived=nil;
}



@end
