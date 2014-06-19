//
//  WebServiceOperation.m
//  SalesTicker
//
//  Created by Mac on 25/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "WebServiceOperation.h"
#import "SalesTickerResultViewController.h"

#import "AppDelegate.h"




@implementation WebServiceOperation

@synthesize dic2;
@synthesize success;


-(void)main
{
    //self.success = NO;
    [self WebServiceOperation];
}

-(void)WebServiceOperation
{
    ///******Starting the Web Services Process
    
    
   // AppDelegate *appClass = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
   NSUserDefaults *userNamedefault = [NSUserDefaults standardUserDefaults];
    
    
    NSString *getUserName = [userNamedefault valueForKey:@"userNameKey"];
    
    NSString *getPassWord = [userNamedefault valueForKey:@"passwordKey"];
    
    NSString *getCenterCode = [userNamedefault valueForKey:@"enterCodedKey"];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/SalesAgentLogin/%@/%@/%@",getUserName,getPassWord,getCenterCode];
     
    
   
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    
    
    NSURL *urlSalesTricker = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlReqSalesTricker = [NSURLRequest requestWithURL:urlSalesTricker];
    
    
    NSURLConnection *urlConnectionSalesTricker = [[NSURLConnection alloc] initWithRequest:urlReqSalesTricker delegate:self startImmediately:NO];
    
    
    
    //NSLog(@"urlConnectionSalesTricker = %@",urlConnectionSalesTricker);
    
    
    //  NSAssert(urlConnectionSalesTricker!=nil, @"Failure to create URL connection");
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [urlConnectionSalesTricker scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [urlConnectionSalesTricker start];
    
    
    if(urlConnectionSalesTricker)
    {
        webData = [NSMutableData data];
    }
    else
    {
        NSLog(@"Url not connected");
        
    }
    
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
    
    //NSLog(@" webData == %d",[webData length]);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    
    
	NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithCapacity:1];
    
    [userInfo setValue:error forKey:@"ErrorKey"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSalesAgentDetailsNoResultNotif" object:self userInfo:userInfo];
	
}


- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
     [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:webData options:NSJSONReadingMutableContainers error:nil];
    
    
    //NSLog(@" dic === %@",dic);
    
    
   // NSDictionary *dic1 = [dic objectForKey:@"FindCarIDResult"];
    
    
    NSArray *arr = [dic objectForKey:@"SalesAgentLoginResult"];
    
    
    
    self.dic2 = [NSDictionary dictionaryWithObjectsAndKeys:arr,@"GetSalesAgentLoginResultKey", nil];
     
    
    //NSLog(@"self.dic2 = %@",self.dic2);
    
    if ([arr count] == 0) 
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSalesAgentDetailsNoResultNotif" object:self userInfo:nil];
    }
    else if ([arr count] > 0)
    {
        if (success) {
            
            //NSLog(@"self.dic2 = %@",self.dic2);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSalesAgentDetailsResultNotif2" object:self userInfo:self.dic2];
        }
        else
        {
             //NSLog(@"self.dic2 ========= %@",self.dic2);
            
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSalesAgentDetailsResultNotif" object:self userInfo:self.dic2];
        }
    }   
    
}


@end
