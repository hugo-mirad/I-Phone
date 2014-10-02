//
//  CustomerSupport.m
//  Car-Finder
//
//  Created by Mac on 30/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CustomerSupport.h"

#import "CommonMethods.h"

//for storing UUID into keychain
#import "SSKeychain.h" //3rd party
#define UUID_USER_DEFAULTS_KEY @"userIdentifier" //for analytics
#define UID_KEY @"UId" //id of logged in user. It is used in different web service calls to modify data at backend.
#define SESSIONID_KEY @"SessionID"

#import "AFNetworking.h"

@interface CustomerSupport()

@property(strong,nonatomic) UILabel *phoneLbl,*smsLbl,*mailLbl;
@property(strong,nonatomic) NSOperationQueue *opQueue;

@end

@implementation CustomerSupport

@synthesize phoneLbl=_phoneLbl,smsLbl=_smsLbl,mailLbl=_mailLbl,opQueue=_opQueue;

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

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CommonMethods putBackgroundImageOnView:self.view];
    
//    //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
//    
//    self.navigationItem.titleView=[CommonMethods controllerTitle:@"Customer Support"];
    
   
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
//        
//        //load resources for earlier versions
//       //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
//        navtitle.textColor=[UIColor  whiteColor];
//        
//        
//    } else {
//        navtitle.textColor=[UIColor  colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];
//        
//        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
//        //load resources for iOS 7
//        
//    }
    navtitle.textColor=[UIColor  whiteColor];
    navtitle.text=@"Customer Support"; //
    navtitle.textAlignment=NSTextAlignmentLeft;
    navtitle.backgroundColor=[UIColor clearColor];
    
    navtitle.font=[UIFont boldSystemFontOfSize:16];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    
    self.navigationItem.titleView=navtitle;
    //navtitle.center=self.navigationItem.titleView.center;
    navtitle=nil;

    UIImage* image3 = [UIImage imageNamed:@"BackAll.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width/2-20, image3.size.height/2-20);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(backToResultsButtonTapped)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    
    UIBarButtonItem *lb= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem =lb;
    lb=nil;
    

    UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] init];
    logoutButton.target = self;
    logoutButton.action = @selector(logoutButtonTapped:);
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [logoutButton setTitleTextAttributes:dic forState:UIControlStateNormal];
    [logoutButton setTitle:[NSString stringWithFormat:@"Logout"]];
    logoutButton.tintColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem=logoutButton;
    

    
    
    
  
    UILabel *companyName  = [[UILabel alloc] init];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        companyName.frame = CGRectMake(20, 50, 300, 30);
    }else{
        companyName.frame = CGRectMake(20, 90, 300, 30);
    }
    
    ;
    [companyName setText:@"www.mobicarz.com"];
    [companyName setTextAlignment:NSTextAlignmentCenter];
    [companyName setTextColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f]];
    [companyName setBackgroundColor:[UIColor clearColor]];
    //[companyName addGestureRecognizer:mailLblGesture];
    [self.view addSubview:companyName];
    
    
    UILabel *cmpStatement  = [[UILabel alloc] init ];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
    cmpStatement.frame =  CGRectMake(10, 90, 300, 30);
    }else{
        cmpStatement.frame =  CGRectMake(10, 140, 300, 30);
    }
    [cmpStatement setText:@"Number one portal for car buyers and sellers"];
    [cmpStatement setTextAlignment:NSTextAlignmentCenter];
    cmpStatement.adjustsFontSizeToFitWidth = YES;
    [cmpStatement setTextColor:[UIColor blackColor]];
    [cmpStatement setBackgroundColor:[UIColor clearColor]];
    //[companyName addGestureRecognizer:mailLblGesture];
    [self.view addSubview:cmpStatement];
    
    
  UILabel *phoneTitle  = [[UILabel alloc] init];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        phoneTitle.frame = CGRectMake(20, 140, 76, 30);

    }else{
        phoneTitle.frame = CGRectMake(20, 190, 76, 30);

    }
        
        [phoneTitle setText:@"Phone no :"];
        [phoneTitle setTextAlignment:NSTextAlignmentLeft];
        phoneTitle.adjustsFontSizeToFitWidth = YES;
        [phoneTitle setTextColor:[UIColor blackColor]];
        [phoneTitle setBackgroundColor:[UIColor clearColor]];
        
    
    [self.view addSubview:phoneTitle];
    
    
     self.phoneLbl  = [[UILabel alloc] init];
       if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
           self.phoneLbl.frame =  CGRectMake(100, 140, 200, 30);

       }else{
      self.phoneLbl.frame =  CGRectMake(100, 190, 200, 30);
       }
    [self.phoneLbl setText:@"888-465-6693"];
    [self.phoneLbl setUserInteractionEnabled:YES];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        UITapGestureRecognizer* phoneLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneLblTapped:)];
        // if labelView is not set userInteractionEnabled, you must do so
        
        
        [self.phoneLbl addGestureRecognizer:phoneLblGesture];
    }
    else
    {
       // [self.phoneLbl setHidden:YES];
    }
    [self.phoneLbl setBackgroundColor:[UIColor clearColor]];
    [self.phoneLbl setTextColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f]];
    //phone label gesture
    [self.view addSubview:self.phoneLbl];
    
    
    
     UILabel *emailTitle  = [[UILabel alloc] init];
if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
    emailTitle.frame =  CGRectMake(20, 190, 76, 30);
     }else{
     emailTitle.frame =  CGRectMake(20, 240, 76, 30);
     }
    [emailTitle setText:@"Email :"];
    [emailTitle setTextAlignment:NSTextAlignmentLeft];
    emailTitle.adjustsFontSizeToFitWidth = YES;
    [emailTitle setTextColor:[UIColor blackColor]];
    [emailTitle setBackgroundColor:[UIColor clearColor]];
    //[companyName addGestureRecognizer:mailLblGesture];
    [self.view addSubview:emailTitle];
    
    //email gesture
    UITapGestureRecognizer* mailLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mailLblTapped:)];
    // if labelView is not set userInteractionEnabled, you must do so
     self.mailLbl = [[UILabel alloc] init];
if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
    self.mailLbl.frame = CGRectMake(76, 190, 280, 30);
     }else{
    self.mailLbl.frame = CGRectMake(76, 240, 280, 30);
     }
    [self.mailLbl setText:@"info@mobicarz.com"];
    [self.mailLbl setUserInteractionEnabled:YES];
    [self.mailLbl addGestureRecognizer:mailLblGesture];
    [self.mailLbl setTextColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f]];
    [self.mailLbl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.mailLbl];
    
        
}
-(void)backToResultsButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Private Methods


- (void)phoneLblTapped:(id)sender
{
    //see if the device can actually make a call
    NSString *phonenum=[NSString stringWithFormat:@"tel://+1888-465-6693"];
    if([CommonMethods canDevicePlaceAPhoneCall])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenum]];
    }
    
    else
    {
        NSString *msg=[NSString stringWithFormat:@"This device cannot place a call now. Use another phone to call MobiCarz at (888)465-6693."];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Device Cannot Call Now" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
    
}

- (void)smsLblTapped:(id)sender
{
    MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
    
    //see if the device can actually make a call
    if([MFMessageComposeViewController canSendText])
    {
        smsController.body = @"SMS message here";
        smsController.recipients = [NSArray arrayWithObjects:@"1(888)465-6693", nil];
        smsController.messageComposeDelegate = self;
        [self presentViewController:smsController animated:YES completion:nil];
    }
    
    
}

- (void)mailLblTapped:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@""];
        NSArray *toRecipients = [NSArray arrayWithObjects:@"info@mobicarz.com", nil];
        [mailer setToRecipients:toRecipients];
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        mailer.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
    }
}


#pragma mark - Message Composer Delegate Method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"SMS Cancelled");
			break;
            
		case MessageComposeResultFailed:
			NSLog(@"SMS Failed");
			break;
		case MessageComposeResultSent:
            NSLog(@"SMS Sent");
			break;
		default:
			break;
	}
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Mail Composer Delegate Method

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Logout Button
- (void)logoutButtonTapped:(id)sender
{
    UIBarButtonItem *rightBarButton=self.navigationItem.rightBarButtonItem;
    rightBarButton.enabled=NO;
    
   
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    NSString *uid=[defaults valueForKey:UID_KEY];
    

    NSString *brandID = @"2";
    NSString *logoutServiceStr=[NSString stringWithFormat:@"http://test1.unitedcarexchange.com/MobileService/GenericServices.svc/GenericPerformLogoutMobile/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/%@", uid,sessionID,retrieveduuid,brandID];
    
    //calling service
    NSURL *URL = [NSURL URLWithString:logoutServiceStr];
    NSURLCacheStoragePolicy policy = NSURLCacheStorageNotAllowed;
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:policy timeoutInterval:60.0];
    
    //create operation
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }];
    
    __weak CustomerSupport *weakSelf=self;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        rightBarButton.enabled=YES;
        
        //call service executed succesfully
        NSError *error2=nil;
        NSDictionary *wholeResult=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error2];
        
        if(error2==nil)
        {
            
            NSString *logoutResult=[wholeResult objectForKey:@"GenericPerformLogoutMobileResult"];
            
            
            //check status
            
            if ([logoutResult isEqualToString:@"Success"])
            {
                //perform segue here
                //go to login screen
               
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                
                
            }
            else
            {
                [weakSelf customerSupportOperationFailedMethod:nil];
                
            }
            
        }
        else
        {
            //handle JSON error here
           // NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
            [weakSelf handleJSONError:error2];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        rightBarButton.enabled=YES;
        
        //call service failed
        NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([weakSelf class]),NSStringFromSelector(_cmd),error);
        //handle service error here
        NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error);
        [weakSelf handleOperationError:error];
    }];
    
    if (self.opQueue==nil) {
        self.opQueue=[[NSOperationQueue alloc] init];
        [self.opQueue setName:@"CustomerSupport Queue"];
        [self.opQueue setMaxConcurrentOperationCount:1];
    }
    else
    {
        [self.opQueue cancelAllOperations];
    }
    
    [self.opQueue addOperation:operation];
}

#pragma mark - Operation Failed Error Handling

- (void)customerSupportOperationFailedMethod:(NSError *)error
{
    NSLog(@"Error Occurred. %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),error);
    
    UIAlertView *alert=[[UIAlertView alloc]init];
    alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    
    if (error) {
        if ([error code]==kCFURLErrorNotConnectedToInternet) {
            alert.title=@"No Internet Connection";
            alert.message=@"MobiCarz cannot retrieve data as it is not connected to the Internet.";
        }
        else if([error code]==kCFURLErrorTimedOut)
        {
            alert.title=@"Error Occured";
            alert.message=@"The request timed out.";
        }
        else
        {
            alert.title=@"Server Error";
            alert.message=[error localizedDescription];
        }
        
    }
    else //just for safe side though error object would not be nil
    {
        alert.title=@"Server Error";
        alert.message=@"MobiCarz could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
}

- (void)handleOperationError:(NSError *)error
{
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self customerSupportOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"MobiCarz" code:[error code] userInfo:userInfo];
    [self customerSupportOperationFailedMethod:error2];
    
}

- (void)dealloc {
    _phoneLbl=nil;
    _smsLbl=nil;
    _mailLbl=nil;
}
@end
