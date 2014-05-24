//
//  AboutUs.m
//  UCE
//
//  Created by Mac on 24/06/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AboutUs.h"
#import "CommonMethods.h"

//for dialing a number
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


@implementation AboutUs

@synthesize mailLbl=_mail1Lbl,phoneLbl=_phoneLbl;

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
    self.navigationController.navigationBar.hidden = NO;
    self.toolBarLbl = [[UILabel alloc] init];
    
    [CommonMethods putBackgroundImageOnView:self.view];
    
    
    
    UIImage *faceImage = [UIImage imageNamed:@"HomeREd.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
    face.frame = CGRectMake( 40, 30, 60, 60);
    
    }
    else{
        face.frame = CGRectMake( 24, 30, 40, 40);
        
    }
    [face addTarget:self action:@selector(homeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
   // UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    [self.view addSubview:face];

    
    UILabel *companyName  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-150, 80, 300, 30)];
    [companyName setText:@"www.mobicarz.com"];
    [companyName setTextAlignment:NSTextAlignmentCenter];
    [companyName setTextColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f]];
    [companyName setBackgroundColor:[UIColor clearColor]];
    [companyName setFont:[UIFont systemFontOfSize:20]];
    //[companyName addGestureRecognizer:mailLblGesture];
    [self.view addSubview:companyName];
    
    
    UILabel *cmpStatement  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-140, 140, 300, 30)];
    [cmpStatement setText:@"Number one portal for car buyers and sellers"];
    [cmpStatement setTextAlignment:NSTextAlignmentCenter];
    cmpStatement.adjustsFontSizeToFitWidth = YES;
    [cmpStatement setTextColor:[UIColor blackColor]];
    [cmpStatement setBackgroundColor:[UIColor clearColor]];
    //[companyName addGestureRecognizer:mailLblGesture];
    [self.view addSubview:cmpStatement];
    
    
    UILabel *phoneTitle;
    
     if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
     phoneTitle  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-180, 190, 76, 30)];
     }else{
         phoneTitle  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-140, 190, 76, 30)];
     }
        [phoneTitle setText:@"Phone no :"];
        [phoneTitle setTextAlignment:NSTextAlignmentLeft];
        phoneTitle.adjustsFontSizeToFitWidth = YES;
        [phoneTitle setTextColor:[UIColor blackColor]];
        [phoneTitle setBackgroundColor:[UIColor clearColor]];
    

    [self.view addSubview:phoneTitle];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
    self.phoneLbl  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-100, 190, 200, 30)];
    }
    else{
        
        self.phoneLbl  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-60, 190, 200, 30)];
        
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
    
    
    UILabel *emailTitle;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        
    emailTitle  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-180, 240, 76, 30)];
    }else{
        emailTitle  = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-140, 240, 76, 30)];
        
    }
    [emailTitle setText:@"Email :"];
    [emailTitle setTextAlignment:NSTextAlignmentLeft];
    emailTitle.adjustsFontSizeToFitWidth = YES;
    [emailTitle setTextColor:[UIColor blackColor]];
    [emailTitle setBackgroundColor:[UIColor clearColor]];
    //[companyName addGestureRecognizer:mailLblGesture];
    [self.view addSubview:emailTitle];
        
        //email gesture
        UITapGestureRecognizer* mailLblGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mail1LblTapped:)];
        // if labelView is not set userInteractionEnabled, you must do so
     if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
    self.mailLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-120, 240, 280, 30)];
     }
     else{
         
         self.mailLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-80, 240, 280, 30)];

         
         
     }
        [self.mailLbl setText:@"info@mobicarz.com"];
        [self.mailLbl setUserInteractionEnabled:YES];
        [self.mailLbl addGestureRecognizer:mailLblGesture];
       [self.mailLbl setTextColor:[UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f]];
    [self.mailLbl setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.mailLbl];
    
    //
    /*
    UIImageView *navimage2=[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"logo2" ofType:@"png"]]];
    navimage2.frame=CGRectMake(0, 0, 94, 25);
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:navimage2];
    [self.navigationItem setLeftBarButtonItem: customItem];
     */
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            
            
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            
            self.toolbar.frame = CGRectMake(0, 0, height, 60.0f);
              //your landscape frame
            
        }else{
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            self.toolbar.frame = CGRectMake(0, 0, height, 60.0f);
            
        }
    }else{
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.toolbar.frame = CGRectMake(0, 0, width, 60.0f);
        
    }

    
    self.toolBarLbl.frame= CGRectMake(self.toolbar.frame.size.width/2-50, 10, 100, 44);
}


-(void)homeButtonTapped:(id)sender
{
    
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

-(bool)canDevicePlaceAPhoneCall {
    /*
     
     Returns YES if the device can place a phone call
     
     */
    CTTelephonyNetworkInfo *netInfo=nil;
    CTCarrier *carrier=nil;
    NSString *mnc=nil;
    BOOL canPlaceCallNow=NO;
    
    // Check if the device can place a phone call
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // Device supports phone calls, lets confirm it can place one right now
        netInfo = [[CTTelephonyNetworkInfo alloc] init];
        carrier = [netInfo subscriberCellularProvider];
        mnc = [carrier mobileNetworkCode]; 
        if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
            // Device cannot place a call at this time.  SIM might be removed.
            canPlaceCallNow=NO;
        } else {
            // Device can place a phone call
            canPlaceCallNow=YES;
        }
    } else {
        // Device does not support phone calls
        canPlaceCallNow=NO;
    }
    mnc=nil;
    carrier=nil;
    netInfo=nil;
    return canPlaceCallNow;
}

- (void)phoneLblTapped:(id)sender
{
    //see if the device can actually make a call
    NSString *phonenum=[NSString stringWithFormat:@"tel://+18884656693"];
    if([self canDevicePlaceAPhoneCall])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phonenum]];
    }
    
    else
    {
        NSString *msg=[NSString stringWithFormat:@"This device cannot place a call now. Use another phone to call MobiCarz at 888-465-6693."];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Device Cannot Call Now" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
    
}

- (void)mail1LblTapped:(id)sender
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
    }
}

#pragma mark - MailComposer Delegate Method

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    UIAlertView *alert;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            alert=[[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Our service representative will contact you shortly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;

            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"An error occurred when sending Email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
            break;
        default:
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)dealloc
{
    _phoneLbl=nil;
    _mail1Lbl=nil; 
    
}
@end
