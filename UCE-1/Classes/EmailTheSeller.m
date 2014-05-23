//
//  EmailTheSeller.m
//  UCE
//
//  Created by Mac on 16/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailTheSeller.h"
#import "CarRecord.h"
#import "AFNetworking.h"
#import "UIButton+Glossy.h"

@interface EmailTheSeller()

@property(strong,nonatomic) NSOperationQueue *emailOpQueue;
@property(strong,nonatomic) UIAlertView *emailSentAlert;


- (void)mailServiceCallSuccessMethod;
- (void)mailServiceCallFailedMethod:(NSError *)error;

@end

@implementation EmailTheSeller
@synthesize emailWebView=_emailWebView;
@synthesize carRecordFromDetailView=_carRecordFromDetailView,emailOpQueue=_emailOpQueue;
@synthesize sendButton=_sendButton,cancelButton=_cancelButton,emailSentAlert=_emailSentAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL) validateEmail: (NSString *)emailString {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"; 
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:emailString];
}

-(void)backBarButtonTapped
{
    /*
     UITabBarController *tabBar = self.tabBarController;
     //do anything with view controllers, pass values etc here before switching views
     [tabBar setSelectedIndex:0];
     */
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 // Do any additional setup after loading the view, typically from a nib.
 
 
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 45)];
    navtitle.text=@"Enter Your Details";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    [self.navigationItem setTitleView:navtitle];
    navtitle=nil;
    
    
    //back button
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonTapped)];
    self.navigationItem.leftBarButtonItem=backButton;
    backButton=nil;
    
    //self.emailWebView.backgroundColor = [UIColor clearColor];
    self.emailWebView.opaque = NO;
    UIImage *img=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back3" ofType:@"png"]];
    [self.emailWebView setBackgroundColor:[UIColor colorWithPatternImage:img]];
    
    //get html file
    NSString *path=[[NSBundle mainBundle]pathForResource:@"email" ofType:@"html"];
    NSData *htmlData=[NSData dataWithContentsOfFile:path];
    
    //set base url
    NSString *resourceUrl=[[NSBundle mainBundle]resourcePath];
    resourceUrl=[resourceUrl stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    resourceUrl=[resourceUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *baseUrl=[NSURL URLWithString:[NSString stringWithFormat:@"file:/@//"]];
    
    //now load the html and pass css and .js files as baseUrl
    [self.emailWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:baseUrl];
    
    //we will use self as delegate for our UIWebView
    self.emailWebView.delegate=self;
    
    //making buttons glossy
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.sendButton makeGlossy];
    
    
    //
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.cancelButton.backgroundColor=[UIColor colorWithRed:0.9 green:0.639 blue:0.027 alpha:1.000];
    [self.cancelButton makeGlossy];
    
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
            SEL method=NSSelectorFromString([url host]);
            
            //now execute that method
            if ([self respondsToSelector:method]) {
                [self performSelector:method withObject:nil afterDelay:0.1f];
                
            }
            return NO;
        }
    }
    return YES;
    
}

/*
 - (void)webViewDidFinishLoad:(UIWebView *)webView {
 
 [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"text\").innerHTML=\"Hello World\";"];
 }
 
 */
-(IBAction)cancelButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)removeContinousDotsAndSpaces:(NSString *)str
{
    //NSLog(@"str received is %@",str);
    
    NSString *trimmedString = str;
    while ([trimmedString rangeOfString:@".."].location != NSNotFound) {
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@".." withString:@"."];
    }
    
    while ([trimmedString rangeOfString:@"  "].location != NSNotFound) {
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    
    //NSLog(@"trimmedString is %@",trimmedString);
    
    return trimmedString;
}



-(void)callEmailServiceWith:(NSString *)buyerEmailAddress buyerPhoneNumber:(NSString *)buyerPhoneNumber city:(NSString *)city fName:(NSString *)fName lName:(NSString *)lName comments:(NSString *)msg
{
    
    NSString *buyerEmail; //=IsEmpty(buyerEmailAddress)?@"info@unitedcarexchange.com":buyerEmailAddress;
    if (IsEmpty([buyerEmailAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerEmail=@"info@unitedcarexchange.com";
    }
    else
    {
        buyerEmail=[self removeContinousDotsAndSpaces:buyerEmailAddress];
        buyerEmail=[buyerEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *buyerCity;
    if (IsEmpty([city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerCity=@" ";
    }
    else
    {   
        buyerCity=[self removeContinousDotsAndSpaces:city];
        buyerCity=[buyerCity stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *buyerPhone=buyerPhoneNumber;
    NSString *buyerFirstName;
    if (IsEmpty([fName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerFirstName=@" ";
    }
    else
    {
        buyerFirstName=[fName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *buyerLastName;
    if (IsEmpty([lName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerLastName=@" ";
    }
    else
    {
        buyerLastName=[lName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *buyerComments;
    if (IsEmpty([msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])) {
        buyerComments=@" ";
        
    }
    else
    {   
        buyerComments=[self removeContinousDotsAndSpaces:msg];
        buyerComments=[buyerComments stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    NSString *ipAddress=@" ";
    
    //
    
    NSString *sellerphone;
    if (IsEmpty([[self.carRecordFromDetailView phone] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[[self.carRecordFromDetailView phone] isEqualToString:@"Emp"]) {
        sellerphone=@" ";
    }
    else
    {
        sellerphone=[self.carRecordFromDetailView phone];
    }
    
    
    NSString *sellerprice;
    NSString *sellerPriceStr=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    
    if (IsEmpty([sellerPriceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[sellerPriceStr isEqualToString:@"Emp"]) {
        sellerprice=@" ";
    }
    else
    {
        sellerprice=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    }
    
    
    NSString *carid=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView carid]];
    
    
    NSString *sYear;
    NSString *sYearStr=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView year]];
    if (IsEmpty([sYearStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[sYearStr isEqualToString:@"Emp"]) {
        sYear=@" ";
    }
    else
    {
        sYear=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView year]];
    }
    
    
    NSString *make=[[self.carRecordFromDetailView make] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *model=[[self.carRecordFromDetailView model] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *price;
    NSString *priceStr=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    if (IsEmpty([priceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])||[priceStr isEqualToString:@"Emp"]) {
        price=@" ";
    }
    else
    {
        price=[NSString stringWithFormat:@"%d",[self.carRecordFromDetailView price]];
    }
    
    
    NSString *emailServiceStr=[NSString stringWithFormat:@"http://unitedcarexchange.com/carservice/Service.svc/SaveBuyerRequestMobile/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/%@/",buyerEmail,buyerCity,buyerPhone,buyerFirstName,buyerLastName,buyerComments,ipAddress,sellerphone,sellerprice,carid,sYear,make,model,price,[self.carRecordFromDetailView sellerEmail]];//[self.carRecordFromDetailView sellerEmail]];
    
    emailServiceStr=[emailServiceStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"emailServiceStr=%@",emailServiceStr);
    
    //calling service
    NSURL *URL = [NSURL URLWithString:emailServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    
    self.emailOpQueue=[[NSOperationQueue alloc]init];
    [self.emailOpQueue setName:@"EmailTheSeller Operation Queue"];
    [self.emailOpQueue setMaxConcurrentOperationCount:1];
    
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //NSLog(@"mail service call succeeded");
        [self mailServiceCallSuccessMethod];
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //call service failed
        //NSLog(@"call service failed error:%@ status code:%d userinfo dict=%@",[error localizedDescription],[error code],[error userInfo]);
        [self mailServiceCallFailedMethod:error];
        
    }];
    
    [self.emailOpQueue addOperation:operation];
    
}


-(IBAction)sendButtonTapped
{
    NSString *fName= [self.emailWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"Fname\").value;"];
    
    NSString *lName= [self.emailWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"Lname\").value;"];
    
    NSString *buyerPhoneNumber= [self.emailWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"mobile\").value;"];
    
    NSString *buyerEmailAddress= [self.emailWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"UserEmail\").value;"];
    
    NSString *msg= [self.emailWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"message\").value;"];
    
    NSString *city= [self.emailWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"city\").value;"];
    
    
    //NSLog(@"First name is %@ lastname=%@ phone no:=%@ email = %@ msg = %@ city=%@",fName,lName,buyerPhoneNumber,buyerEmailAddress,msg,city);
    
    
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc]init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    NSNumber *phoneNum=[numberFormatter numberFromString:buyerPhoneNumber];
    
    if (phoneNum==nil || ([buyerPhoneNumber length]>0 && [buyerPhoneNumber length]<10)) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Phone Number" message:@"Enter a valid phone number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
    }
    else
    {    
        buyerEmailAddress=[buyerEmailAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(!IsEmpty(buyerEmailAddress))
            if (![self validateEmail:buyerEmailAddress]) {
                //NSLog(@"email is not valid");
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Invalid Email" message:@"Enter a valid email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                return;
            }
            else
            {
                //NSLog(@"email is valid");
            }
        //call email service here
        //NSLog(@"call email service here");
        [self callEmailServiceWith:buyerEmailAddress buyerPhoneNumber:buyerPhoneNumber city:city fName:fName lName:lName comments:msg];
        
        
        
    }
    numberFormatter=nil;
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
    //return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
    return YES;
}

#pragma mark - Delegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if ([alertView isEqual:self.emailSentAlert]) {
    
    [self.navigationController popViewControllerAnimated:YES];
    //}
}

- (void)mailServiceCallSuccessMethod
{
    self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Your email has been sent." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [self.emailSentAlert show];
}

- (void)mailServiceCallFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    if([error code]==kCFURLErrorNotConnectedToInternet)
    {
        self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"No Internet Connection" message:@"UCE could not send email as it is not connected to the Internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.emailSentAlert show];
    }
    else if([error code]==-1001)
    {
        self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"Error Occured" message:@"The request timed out." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.emailSentAlert show];
        
    }
    else
    {
        self.emailSentAlert=[[UIAlertView alloc]initWithTitle:@"Email Service Failed" message:@"UCE could not connect to mail server." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.emailSentAlert show];
    }
}


-(void)dealloc
{
    [_emailWebView setDelegate:nil];
    [_emailWebView stopLoading];
    [_emailWebView.scrollView setDelegate:nil];
    
    _emailWebView=nil;
    _carRecordFromDetailView=nil;
    
    [_emailOpQueue cancelAllOperations];
    _emailOpQueue=nil;
    
    _sendButton=nil;
    _cancelButton=nil;
}

@end
