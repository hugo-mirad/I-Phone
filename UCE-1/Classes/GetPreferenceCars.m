//
//  GetPreferenceCars.m
//  Preferences2
//
//  Created by Mac on 15/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetPreferenceCars.h"
#import "PreferenceResultsTableCellInfo.h"
#import "CarRecord.h"


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
    NSString *urlStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/GetCarsFilterMobile/%@/%@/%@/%@/%@/asc/price/%d/%d/%@",self.makeIdReceived,self.modelIdReceived,self.mileageReceived,self.yearReceived,self.priceReceived,self.pageSizeReceived,self.pageNoReceived,self.zipReceived];
    
    //NSLog(@"urlStr=%@",urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
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
    //	NSLog(@"did receive data setlength%@",data1);
    //	NSLog(@"DONE,Received Bytes => %d",[data1 length]);
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    _connection1=nil;
    
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *errorString=[NSString stringWithFormat:@"Connection Failed in GetPreferenceCars with error: %@",[error localizedDescription]];
    [userInfo setValue:errorString forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    
    [self callGetPreferenceCarsOperationFailedMethod:error2];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSError *error=nil;
    
    NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:self.data1 options:NSJSONReadingMutableContainers error:&error];
    
    if (wholeResult==nil) {
        [self handleJSONError:error];
        return;
    }
    
    NSArray *prefCarsArray=[wholeResult objectForKey:@"GetCarsFilterMobileResult"];
    
    if([prefCarsArray respondsToSelector:@selector(objectAtIndex:)])
    {
        //NSLog(@"prefCarsArray count when sending notif =%d",[prefCarsArray count]);
        
        NSMutableArray *tempArrayOfPreferenceCells=[[NSMutableArray alloc]init];
        
        NSInteger i=1;
        PreferenceResultsTableCellInfo *pCellInfo=[[PreferenceResultsTableCellInfo alloc]init];
        
        for (NSDictionary *tempDict in prefCarsArray) {
            CarRecord *car1=[[CarRecord alloc]initWithDictionary:tempDict];
            
            if(i==1)
                [pCellInfo setCar1:car1];
            
            else if(i==2)
                [pCellInfo setCar2:car1];
            
            else if(i==3)
                [pCellInfo setCar3:car1];
            i++;
            
            if(i==4 && ([prefCarsArray count]/3>[tempArrayOfPreferenceCells count])){
                [tempArrayOfPreferenceCells addObject:pCellInfo];
                i=1;
                pCellInfo=nil;
                pCellInfo=[[PreferenceResultsTableCellInfo alloc]init];
            }
            else if(i<=4 && ([prefCarsArray count]/3==[tempArrayOfPreferenceCells count]))  // if this is the set of reminder dictionaries (<3) after using all dictionaries in result 
            {
                
                [tempArrayOfPreferenceCells addObject:pCellInfo];
            }
            
            //check if this object is correct
            //NSLog(@"Car Details: %d - %@ - %@ - %d - %d",[car1 carid],[car1 make],[car1 model],[car1 price],[car1 year]);
            
            car1=nil;
            
        }
        pCellInfo=nil;
        //NSLog(@"tempArrayOfPreferenceCells count is %d",[tempArrayOfPreferenceCells count]);
        /*
         //test if tempArrayOfPreferenceCells is created properly or not.
         for (PreferenceResultsTableCellInfo *cInfo in tempArrayOfPreferenceCells) {
         NSLog(@"Car1 details: %d - %@ - %@ - %d - %d - %@",[[cInfo car1] carid],[[cInfo car1] make],[[cInfo car1] model],[[cInfo car1] price],[[cInfo car1] year],[[cInfo car1] imagePath]);
         
         NSLog(@"Car2 details: %d - %@ - %@ - %d - %d - %@",[[cInfo car2] carid],[[cInfo car2] make],[[cInfo car2] model],[[cInfo car2] price],[[cInfo car2] year],[[cInfo car2] imagePath]);
         
         NSLog(@"Car3 details: %d - %@ - %@ - %d - %d - %@",[[cInfo car3] carid],[[cInfo car3] make],[[cInfo car3] model],[[cInfo car3] price],[[cInfo car3] year],[[cInfo car3] imagePath]);
         
         }
         */
        
        //////////
        //we need not consider 0 results option, as this class will not even be called if there are 0 results. The view cars button will be disabled in Preferences Screen
        if (tempArrayOfPreferenceCells && tempArrayOfPreferenceCells.count)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PreferenceResultsForPreferenceResultsTable" object:self userInfo:[NSDictionary dictionaryWithObject:tempArrayOfPreferenceCells forKey:@"prefCarsArrayKey"]]; 
        }
        pCellInfo=nil;
        tempArrayOfPreferenceCells=nil; 
        
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
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self callGetPreferenceCarsOperationFailedMethod:error2];
    
}

- (void)handleDoesNotRespondToSelectorError
{
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"DoesNotRespondToSelector error in GetPreferenceCars" forKey:NSLocalizedDescriptionKey];
    
    NSError *error=[NSError errorWithDomain:@"UCE" code:404 userInfo:userInfo];
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
