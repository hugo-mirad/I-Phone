//
//  ThumbnailDownloadOperation.m
//  XMLTable2
//
//  Created by Mac on 03/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailDownloadOperation.h"

@interface ThumbnailDownloadOperation()

@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

@property(assign,nonatomic) BOOL finished;

@end

@implementation ThumbnailDownloadOperation
@synthesize completeimagename1=_completeimagename1,connection1=_connection1,data1=_data1,finished=_finished;

-(void)main
{
    self.finished=NO;
    
    NSURL *url = [NSURL URLWithString:self.completeimagename1];
    
    NSURLRequest *req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    
    NSURLConnection *tempConnection1=[[NSURLConnection alloc] initWithRequest:req delegate:self];
    self.connection1 = tempConnection1;
    tempConnection1=nil;
    
    
    NSMutableData *tempData1=[[NSMutableData alloc]init];
    self.data1 = tempData1;
    tempData1=nil;
    
    while(!self.finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
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
    self.finished = YES;
    
	UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Check Internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
    alert=nil;
    self.connection1=nil;
    
	
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
    self.connection1=nil;
    
    
    UIImage *img=[[UIImage alloc]initWithData:self.data1];
    
    if (img!=nil)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ThumbnailDownloadOperationNotif" object:self userInfo:[NSDictionary dictionaryWithObject:img forKey:@"ThumbnailDownloadOperationNotifKey"]];
    }
    
    self.finished = YES;
    
    img=nil;
	
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(void)dealloc
{
    _connection1=nil;
    _data1=nil;
    _completeimagename1=nil;
    
}


@end
