//
//  CheckZipCode.m
//  UCE
//
//  Created by Mac on 17/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckZipCode.h"
#import "SSKeychain.h"

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics



@interface CheckZipCode()

@property(strong,nonatomic) NSURLConnection *connection1;
@property(strong,nonatomic) NSMutableData *data1;

//xml
@property(strong,nonatomic) NSXMLParser *xmlParser;
@property(copy,nonatomic) NSString *currentelement,*currentElementChars;

@end


@implementation CheckZipCode
@synthesize connection1=_connection1,data1=_data1,zipValReceived=_zipValReceived,xmlParser=_xmlParser,currentelement=_currentelement,currentElementChars=_currentElementChars;

-(void)main
{
    
     NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    //50197 
    NSString *soapMsg=
    [NSString stringWithFormat: 
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
     "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
     "<soap12:Body>"
     "<CheckZips xmlns=\"http://tempuri.org/\">"
     "<zipId>%@</zipId>"
     "<AuthenticationID>ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654</AuthenticationID>"
     "<CustomerID>%@</CustomerID>"
     "</CheckZips>"
     "</soap12:Body>"
     "</soap12:Envelope>",self.zipValReceived,retrieveduuid];
    
    
    
    //50197     
    
    
   // Check ZipCode
//http://www.unitedcarexchange.com/MobileService/CarService.asmx/CheckZips?zipId=07304&AuthenticationID=ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654&CustomerID=12345
    
    
   //  NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
//    NSString *urlStr = [NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/CarService.asmx/CheckZips?zipId=%@&AuthenticationID=ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654&CustomerID=%@",self.zipValReceived,retrieveduuid];

//    
  NSURL *url = [NSURL URLWithString:@"http://www.unitedcarexchange.com/MobileService/CarService.asmx"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    //---set the various headers---
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMsg length]];
    
    
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [req addValue:@"http://tempuri.org/CheckZips" forHTTPHeaderField:@"SOAPAction"];
    
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    
    //---set the HTTP method and body---
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.connection1 = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    [self.connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection1 start];
    
    
    if(self.connection1)
    {
        self.data1 = [NSMutableData data];
    }
    else
    {
        NSLog(@"theConnection is NULL in %@:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    NSLog(@"CheckZipCode: Method 111");
	[self.data1 setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSLog(@"CheckZipCode: Method 222");
	[self.data1 appendData:data];

    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //    NSLog(@"CheckZipCode: Method 333");
    
    _connection1=nil;
    
	
    if (error!=nil)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckZipCodeNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"CheckZipCodeNotifKey"]];
        
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   
	
    self.xmlParser=[[NSXMLParser alloc]initWithData:self.data1];
    
    self.xmlParser.delegate=self;
    
    [self.xmlParser parse];
    self.xmlParser=nil;
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}


#pragma mark -
#pragma mark XML Parser Methods


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    //    NSLog(@"CheckZipCode: method 555");
    
    
    self.currentelement=[NSString stringWithString:elementName];
    
    if([elementName isEqualToString:@"CheckZipsResult"])
    {
        NSString *tempCurrentElementChars=[[NSString alloc]init];
        self.currentElementChars=tempCurrentElementChars;
        tempCurrentElementChars=nil;
        
        //        NSLog(@"The root element found");
    }
    
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string

{
    //    NSLog(@"CheckZipCode: method 666");
    if([self.currentelement isEqualToString:@"CheckZipsResult"])
    {
        self.currentElementChars=[[self.currentElementChars stringByAppendingString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
    }
    
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([self.currentelement isEqualToString:@"CheckZipsResult"]) {
        
        
        //        NSLog(@"The result received is %@",currentElementChars);
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    //    NSLog(@"The result received is %@",self.currentElementChars);
    
    //raise notification and send true or false value.
    if (self.currentElementChars!=nil)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckZipCodeNotif" object:self userInfo:[NSDictionary dictionaryWithObject:self.currentElementChars forKey:@"CheckZipCodeNotifKey"]];
    }
    else
    {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
        [userInfo setValue:@"Failed to get data." forKey:NSLocalizedDescriptionKey];
        
        NSError *error=[NSError errorWithDomain:@"UCE" code:404 userInfo:userInfo];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CheckZipCodeNotif" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"CheckZipCodeNotifKey"]];
    }
    
}


- (void)cancelDownload
{
    [_connection1 cancel];
    _connection1 = nil;
    _data1=nil;
    
}

-(void)dealloc
{
    [self cancelDownload];
    _zipValReceived=nil;
    _currentElementChars=nil;
    _currentelement=nil;
    _xmlParser=nil;
}


@end
