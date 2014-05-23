//
//  MyCarAddsViewController.m
//  Car-Finder
//
//  Created by Mac on 10/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MyCarAdsViewController.h"
#import "CommonMethods.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party

#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"


#import "AFNetworking.h"

@interface MyCarAdsViewController ()

@property(weak,nonatomic) IBOutlet UIWebView *multisiteWebView;

@property(strong,nonatomic) NSMutableData *webData;

@end

@implementation MyCarAdsViewController

@synthesize carReceived=_carReceived;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CommonMethods putBackgroundImageOnView:self.view];
    
    
    NSString *navTitle=nil;
    if(self.carReceived!=nil)
    {
        navTitle=[NSString stringWithFormat:@"%d %@ %@",[self.carReceived year],[self.carReceived make],[self.carReceived model]];
    }
    UILabel *titleLabel=[[UILabel alloc]init];
    
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:navTitle];
    [titleLabel sizeToFit];
    [self.navigationItem setTitleView:titleLabel];
    titleLabel=nil;
    
    
    [self retrieveMultiSiteResults];
   
    
}


-(void)retrieveMultiSiteResults
{
    
    
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    
    // GetMulti sites 
    //http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetMultisiteListingsByCarID/1902/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/00C7AE59-D28D-47FB-B538-C9125B88D218/7D80EB35-1DE8-405B-A3DF-F50B4C902B8E/120/
    
    
    NSString *multiSiteServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/GetMultisiteListingsByCarID/%d/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@/%@/",[self.carReceived carid],retrieveduuid,sessionID,[self.carReceived uid]];
    

    //calling service
    multiSiteServiceStr = [multiSiteServiceStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *multiSiteUrl = [NSURL URLWithString:multiSiteServiceStr];
    
    NSURLRequest *multiSiteUrlReq = [NSURLRequest requestWithURL:multiSiteUrl];
    
    
    NSURLConnection *urlConnectionSalesTricker = [[NSURLConnection alloc] initWithRequest:multiSiteUrlReq delegate:self startImmediately:NO];
    
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [urlConnectionSalesTricker scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [urlConnectionSalesTricker start];
    
    
    if(urlConnectionSalesTricker)
    {
        self.webData = [NSMutableData data];
    }
    else
    {
        NSLog(@"Url not connected");
        
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
    
    //NSLog(@" webData == %d",[webData length]);
}



- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.webData options:NSJSONReadingMutableContainers error:nil];
    
    
    NSArray *arr = [dic objectForKey:@"GetMultisiteListingsByCarIDResult"];
    //NSLog(@"arr=%@",arr);
   NSDictionary *tempDicMultiSiteListing = [arr objectAtIndex:0];
    //NSLog(@"tempDic -- %@ ",self.tempDicMultiSiteListing);
    
    
    UILabel *msgLbl;
    
    if ([[tempDicMultiSiteListing objectForKey:@"AASuccess"] isEqualToString:@"Session timed out"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Session Timed Out" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    else if ([[tempDicMultiSiteListing objectForKey:@"AASuccess"] isEqualToString:@"Failure"])
    {
        
        msgLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-140, self.view.frame.size.height/2, 280, 40)];
        msgLbl.textAlignment = NSTextAlignmentCenter;
        msgLbl.text = @"There are no Ads for this car.";
        msgLbl.textColor = [UIColor whiteColor];
        msgLbl.backgroundColor = [UIColor clearColor];
        [self.view addSubview:msgLbl];
        
        

        return;

    }
    else {

    
        
        [msgLbl setHidden:YES];
    
    int i=1;
    NSMutableString *allRows=[@"<html><body style=\"color:white\"><table border=\"1\"><tr><th>S.No</th><th>Website</th><th>Posted Data</th><th>Validity (days)</th></tr>" mutableCopy];
    
    for (NSDictionary *dict in arr) {
        //construct html table row for each dictionary
        
        NSLog(@"dict--%@",dict);
        
        NSString *postedDate = [dict objectForKey:@"PostedDate"];
        
        // Search from back to get the last space character
        NSRange range= [postedDate rangeOfString: @" " options: NSBackwardsSearch];
        
        // Take the first substring: from 0 to the space character
        NSString *onlyPostedDate= [postedDate substringToIndex: range.location]; // @"this is a"

        
        
        NSString *htmlStr=[NSString stringWithFormat:@"<tr><td>%d</td><td><a href=\"obj://%@\" style=\"color:orange\">%@</a></td><td>%@</td><td>%@ days</td></tr>",i++,[dict objectForKey:@"MultisitesURL"],[dict objectForKey:@"MultiSiteName"],onlyPostedDate,[dict objectForKey:@"ValidDays"]];
        [allRows appendString:htmlStr];
    }
   
    
    [allRows appendString:@"</table></body></html>"];
    
    
   [self.multisiteWebView loadHTMLString:allRows baseURL:nil];
    
    self.multisiteWebView.delegate=self;
    self.multisiteWebView.opaque=NO;
    //
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    //check if a html link is clicked
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        
        //get url from request
        NSURL *url=[request URL];
        
        
        //get the url scheme i.e., http or https or ftp or objc (in our case)
        
        if ([[url scheme] isEqualToString:@"obj"]) {
            //get a hold of webview so that we can use it later
            //            self.myWebView=webView;
            
            //we get the host part of url and use it as our method that we execute
            
            //now execute that method
            [self performSelector:@selector(loadMultiSitePage:) withObject:url afterDelay:0.1f];
                
            return NO;
        }
    }
    return YES;
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadMultiSitePage:(NSURL *)url
{
    //NSLog(@"url=%@ absoluteString=%@",url,[url absoluteString]);
    
    NSString *urlStr=[url absoluteString];
    urlStr =[urlStr stringByReplacingOccurrencesOfString:@"obj" withString:@"http"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    
}

-(void)dealloc
{
    _carReceived=nil;
    _multisiteWebView=nil;
    _webData=nil;
}

@end
