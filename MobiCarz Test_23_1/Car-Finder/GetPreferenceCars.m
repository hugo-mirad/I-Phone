//
//  GetPreferenceCars.m
//  Preferences2
//
//  Created by Mac on 15/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetPreferenceCars.h"
//#import "PreferenceResultsTableCellInfo.h"
#import "PreferenceResultsCollectionCellInfo.h"
#import "CarRecord.h"

#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics




@interface GetPreferenceCars()

@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

- (void)handleDoesNotRespondToSelectorError;
- (void)handleJSONError:(NSError *)error;
- (void)callGetPreferenceCarsOperationFailedMethod:(NSError *)error;

@end


@implementation GetPreferenceCars
@synthesize connection1=_connection1,data1=_data1;

@synthesize makeIdReceived=_makeIdReceived,modelIdReceived=_modelIdReceived,priceReceived=_priceReceived,mileageReceived=_mileageReceived,yearReceived=_yearReceived,zipReceived=_zipReceived,pageNoReceived=_pageNoReceived,pageSizeReceived=_pageSizeReceived;


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        
    }
    return self;
}

-(void)loadMyData
{
    
    //Preferences
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];

 
    
    NSString *brandID = @"2";
    
     NSString *urlStr=[NSString stringWithFormat:@"http://test1.unitedcarexchange.com/MobileService/GenericServices.svc/GenericGetCarsFilterMobile/%@/%@/%@/%@/%@/asc/price/%d/%d/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@",self.makeIdReceived,self.modelIdReceived,self.mileageReceived,self.yearReceived,self.priceReceived,self.pageSizeReceived,self.pageNoReceived,self.zipReceived,retrieveduuid,brandID];
    
    
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    
    if( self.connection1)
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
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    _connection1=nil;
    
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *errorString=[NSString stringWithFormat:@"Connection Failed in GetPreferenceCars with error: %@",[error localizedDescription]];
    [userInfo setValue:errorString forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    
    [self callGetPreferenceCarsOperationFailedMethod:error2];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSError *error=nil;
    
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    if (wholeResult==nil) {
        [self handleJSONError:error];
        return;
    }
    
    NSArray *prefCarsArray=[wholeResult objectForKey:@"GenericGetCarsFilterMobileResult"];
    
    if([prefCarsArray respondsToSelector:@selector(objectAtIndex:)])
    {
        
        NSMutableArray *tempArrayOfPreferenceCells=[[NSMutableArray alloc]init];
        
       
        
        for (NSDictionary *tempDict in prefCarsArray) {
            
            PreferenceResultsCollectionCellInfo *pCellInfo=[[PreferenceResultsCollectionCellInfo alloc]init];
            CarRecord *car1=[[CarRecord alloc]initWithDictionary:tempDict];
            [pCellInfo setCar:car1];
            [tempArrayOfPreferenceCells addObject:pCellInfo];
            
            
            //check if this object is correct
            
            car1=nil;
            pCellInfo=nil;
            
        }
        
  
        //////////
        //we need not consider 0 results option, as this class will not even be called if there are 0 results. The view cars button will be disabled in Preferences Screen
        if (tempArrayOfPreferenceCells && tempArrayOfPreferenceCells.count)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PreferenceResultsForPreferenceResultsTable" object:self userInfo:[NSDictionary dictionaryWithObject:tempArrayOfPreferenceCells forKey:@"prefCarsArrayKey"]]; 
        }
     
    }
    else
    {
        NSLog(@"does not respond to selector. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
        self.connection1 = nil;
        self.data1=nil;
        
        [self handleDoesNotRespondToSelectorError];
    }
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)main
{
    [self loadMyData];
}

- (void)callGetPreferenceCarsOperationFailedMethod:(NSError *)error
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"GetPreferenceCarsOperationFailedNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"GetPreferenceCarsOperationFailedNotifKey"]];
}

- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in GetPreferenceCars" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self callGetPreferenceCarsOperationFailedMethod:error2];
    
}

- (void)handleDoesNotRespondToSelectorError
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"DoesNotRespondToSelector error in GetPreferenceCars" forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"MobiCarz" code:404 userInfo:userInfo];
    [self callGetPreferenceCarsOperationFailedMethod:error];
    
}

-(void)cancelDownload
{
    [_connection1 cancel];
    _connection1=nil;
    _data1=nil;
}

-(void)dealloc
{
    [self cancelDownload];
    _makeIdReceived=nil;
    _modelIdReceived=nil;
    _priceReceived=nil;
    _mileageReceived=nil;
    _yearReceived=nil;
    _zipReceived=nil;
}

@end
