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
    
    //[CommonMethods putBackgroundImageOnView:self.view];
    
    UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    //av.image = [UIImage imageNamed:@"back3.png"];
    
    
    av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"launch-640x960-1" ofType:@"jpg"]];
    
    
    [self.view addSubview:av];

    
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    self.navigationItem.titleView=[CommonMethods controllerTitle:@"Customer Support"];
    
    UIBarButtonItem *logoutButton=[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logoutButtonTapped:)];
    self.navigationItem.rightBarButtonItem=logoutButton;
    
    CGFloat labelWidth;
    
    //    labelWidth=[CommonMethods findLabelWidth:@"www.unitedcarexchange.com"];
    //    UILabel *headingLabel=[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-(labelWidth/2), 46, labelWidth+2, 21)];
    UILabel *headingLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 40, 280, 21)];
    headingLabel.text=@"www.unitedcarexchange.com";
    headingLabel.backgroundColor=[UIColor clearColor];
    headingLabel.textColor = [UIColor orangeColor];
    headingLabel.textAlignment=NSTextAlignmentLeft;
    headingLabel.font=[UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:headingLabel];
    headingLabel=nil;
    
    
    //    labelWidth=[CommonMethods findLabelWidth:@"Number 1 portal for car buyers/sellers"];
    //    headingLabel=[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-(labelWidth/2), 86, labelWidth+2, 21)];
    headingLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 66, 280, 21)];
    headingLabel.text=@"Number one portal for car buyers and sellers";
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.backgroundColor=[UIColor clearColor];
    headingLabel.textAlignment=NSTextAlignmentLeft;
    headingLabel.font=[UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:headingLabel];
    headingLabel=nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
    
    labelWidth=[CommonMethods findLabelWidth:@"Contact:"];
    headingLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 100, labelWidth+2, 21)];
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.text=@"Contact:";
    headingLabel.backgroundColor=[UIColor clearColor];
    headingLabel.textAlignment=NSTextAlignmentLeft;
    headingLabel.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:headingLabel];
    headingLabel=nil;
    
    
    labelWidth=[CommonMethods findLabelWidth:@"(888) 786-8307"];
    self.phoneLbl=[[UILabel alloc] initWithFrame:CGRectMake([CommonMethods findLabelWidth:@"Contact:"]+2, 100, labelWidth+2, 21)];
    self.phoneLbl.text=@"(888) 786-8307";
    self.phoneLbl.textColor = [UIColor whiteColor];
    self.phoneLbl.backgroundColor=[UIColor clearColor];
    self.phoneLbl.textAlignment=NSTextAlignmentLeft;
    self.phoneLbl.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:self.phoneLbl];
    
    //phone label gesture
    if([CommonMethods canDevicePlaceAPhoneCall])
    {
        self.phoneLbl.textColor=[UIColor orangeColor];
        UITapGestureRecognizer *phoneLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneLblTapped:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [self.phoneLbl setUserInteractionEnabled:YES];
        [self.phoneLbl addGestureRecognizer:phoneLblGesture];
    }
    }
    
    
    ////////////
    labelWidth=[CommonMethods findLabelWidth:@"Email:"];
    headingLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 150, labelWidth+2, 21)];
    headingLabel.text=@"Email:";
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.backgroundColor=[UIColor clearColor];
    headingLabel.textAlignment=NSTextAlignmentLeft;
    headingLabel.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:headingLabel];
    headingLabel=nil;
    
    labelWidth=[CommonMethods findLabelWidth:@"info@unitedcarexchange.com"];
    self.mailLbl=[[UILabel alloc] initWithFrame:CGRectMake([CommonMethods findLabelWidth:@"Email:"]+12, 150, labelWidth+2, 21)];
    self.mailLbl.text=@"info@unitedcarexchange.com";
    self.mailLbl.backgroundColor=[UIColor clearColor];
    self.mailLbl.textAlignment=NSTextAlignmentLeft;
    self.mailLbl.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:self.mailLbl];
    
    if ([MFMailComposeViewController canSendMail])
    {
        self.mailLbl.textColor=[UIColor orangeColor];
        //email gesture
        UITapGestureRecognizer* mailLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mailLblTapped:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [self.mailLbl setUserInteractionEnabled:YES];
        [self.mailLbl addGestureRecognizer:mailLblGesture];
    }
    
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
    NSString *phonenum=[NSString stringWithFormat:@"tel://+18887868307"];
    if([CommonMethods canDevicePlaceAPhoneCall])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenum]];
    }
    
    else
    {
        NSString *msg=[NSString stringWithFormat:@"This device cannot place a call now. Use another phone to call UCE at (888)786-8307."];
        
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
        smsController.recipients = [NSArray arrayWithObjects:@"1(888)786-8307", nil];
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
        NSArray *toRecipients = [NSArray arrayWithObjects:@"info@unitedcarexchange.com", nil];
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
    
    /*
     http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLogoutMobile/{UserID}/{SessionID}/{AuthenticationID}/{CustomerID}/
     */
    NSString *retrieveduuid = [SSKeychain passwordForService:UUID_USER_DEFAULTS_KEY account:@"user"];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    NSString *sessionID=[defaults valueForKey:SESSIONID_KEY];
    NSString *uid=[defaults valueForKey:UID_KEY];
    //NSLog(@"retrieveuuid=%@",retrieveduuid);
    
    
    NSString *logoutServiceStr=[NSString stringWithFormat:@"http://www.unitedcarexchange.com/MobileService/ServiceMobile.svc/PerformLogoutMobile/%@/%@/ds3lkDFD1F5fFGnf2daFs45REsd6re54yb0sc654/%@/", uid,sessionID,retrieveduuid] ; //]@"din9030231534",@"dinesh"];
    
    //NSLog(@"logoutServiceStr=%@",logoutServiceStr);
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
        //NSLog(@"wholeResult=%@",wholeResult);
        
        if(error2==nil)
        {
            
            NSString *logoutResult=[wholeResult objectForKey:@"PerformLogoutMobileResult"];
            
            
            //check status
            
            if ([logoutResult isEqualToString:@"Success"])
            {
                //perform segue here
                //go to login screen
                /*
                 UIStoryboard *loginstoryboard=[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
                 LoginViewController *loginViewController=[loginstoryboard instantiateViewControllerWithIdentifier:@"LoginViewControllerID"];
                 [weakSelf.navigationController presentViewController:loginViewController animated:YES completion:nil];
                 */
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                
                
            }
            else
            {
                NSLog(@"logoutResult=%@",logoutResult);
                [weakSelf customerSupportOperationFailedMethod:nil];
                
            }
            
        }
        else
        {
            //handle JSON error here
            NSLog(@"There was error parsing json result in: %@:%@ %@",[weakSelf class],NSStringFromSelector(_cmd),error2);
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
            alert.message=@"UCE Car Finder cannot retrieve data as it is not connected to the Internet.";
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
        alert.message=@"UCE Car Finder could not retrieve data due to server error.";
    }
    [alert show];
    alert=nil;
}

- (void)handleOperationError:(NSError *)error
{
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"Error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self customerSupportOperationFailedMethod:error2];
    
}


- (void)handleJSONError:(NSError *)error
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:1];
    [userInfo setValue:@"JSON error in LoggedUserMainTable" forKey:NSLocalizedDescriptionKey];
    
    NSError *error2=[NSError errorWithDomain:@"UCE" code:[error code] userInfo:userInfo];
    [self customerSupportOperationFailedMethod:error2];
    
}

- (void)dealloc {
    _phoneLbl=nil;
    _smsLbl=nil;
    _mailLbl=nil;
}
@end
