//
//  ViewController.m
//  SalesTicker
//
//  Created by Mac on 25/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SalesTickerResultViewController.h"

#import "WebServiceOperation.h"

#import "AppDelegate.h"

@implementation ViewController

@synthesize opeQueue;

@synthesize webOperation;

@synthesize userNameTextField,passwordTextField,centerCodedTextField;


@synthesize tempArray;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.opeQueue = [[NSOperationQueue alloc] init];
    [self.opeQueue setMaxConcurrentOperationCount:1];
    
    
    self.navigationController.navigationBar.tintColor=[UIColor darkGrayColor];
        
    UIImageView *navimage2=[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"logo2" ofType:@"png"]]];
    navimage2.frame=CGRectMake(0, 0, 94, 25);
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:navimage2];
    [self.navigationItem setLeftBarButtonItem: customItem];
    

    //************** User Name Label and Text Field***************//
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 20, 100, 40)];
    
    [userNameLabel setFont:[UIFont systemFontOfSize:16]];
    [userNameLabel setText:@"User Name :"];
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:userNameLabel];
    
    
    
    self.userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 24, 200, 40)];
    self.userNameTextField.placeholder = @"Enter User Name";
    self.userNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.userNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.userNameTextField setTextColor:[UIColor whiteColor]];
    [self.userNameTextField setFont:[UIFont systemFontOfSize:16]];
    self.userNameTextField.returnKeyType = UIReturnKeyDone;
    self.userNameTextField.textAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNameTextField.delegate = self;
        
    [self.userNameTextField setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.userNameTextField];
    
    
    
    //************** passWord Label and Text Field***************//
    
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 80, 100, 40)];
    
    [passwordLabel setFont:[UIFont systemFontOfSize:16]];
    [passwordLabel setText:@"PassWord :"];
    [passwordLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:passwordLabel];
    
    
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 84, 200, 40)];
    self.passwordTextField.placeholder = @"Enter Password";
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.secureTextEntry=YES;
    self.passwordTextField.delegate = self;
    self.passwordTextField.textAlignment = UIControlContentVerticalAlignmentCenter;
    [self.passwordTextField setTextColor:[UIColor whiteColor]];
    [self.passwordTextField setFont:[UIFont systemFontOfSize:16]];
    [self.passwordTextField setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.passwordTextField];
    
    
    
    //************** center Code Label and Text Field***************//
    
    
    UILabel *centerCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 140, 100, 40)];
    
    [centerCodeLabel setFont:[UIFont systemFontOfSize:16]];
    [centerCodeLabel setText:@"Cente Code :"];
    [centerCodeLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:centerCodeLabel];
    
    self.centerCodedTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 144, 200, 40)];
    self.centerCodedTextField.placeholder = @"Enter Center Code";
    self.centerCodedTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.centerCodedTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.centerCodedTextField setTextColor:[UIColor whiteColor]];
    [self.centerCodedTextField setFont:[UIFont systemFontOfSize:16]];
    [self.centerCodedTextField setBackgroundColor:[UIColor clearColor]];
    self.centerCodedTextField.textAlignment = UIControlContentVerticalAlignmentCenter;
    self.centerCodedTextField.returnKeyType = UIReturnKeyDone;
    self.centerCodedTextField.delegate = self;
    
    
    [self.view addSubview:self.centerCodedTextField];

    //************** Login Button ***************//
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(self.view.frame.size.width-100, 200, 80, 30);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButton setTintColor:[UIColor greenColor]];
    [loginButton addTarget:self action:@selector(LoginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
}

-(void)LoginButtonPressed
{
    
    NSString *userNameStr = self.userNameTextField.text;
    NSString *passWordStr = self.passwordTextField.text;
    NSString *centerCodeStr = self.centerCodedTextField.text;
    
    //NSLog(@"%@,  %@,  %@",userNameStr,passWordStr,centerCodeStr);
    
        
    NSUserDefaults *userNamedefault = [NSUserDefaults standardUserDefaults];
    
    [userNamedefault setObject:userNameStr forKey:@"userNameKey"];
    
    [userNamedefault setObject:passWordStr forKey:@"passwordKey"];
    
    [userNamedefault setObject:centerCodeStr forKey:@"enterCodedKey"];
    
    [userNamedefault synchronize];
    
     
              
        self.webOperation = [[WebServiceOperation alloc] init];
        [self.opeQueue addOperation:webOperation];
     
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.centerCodedTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    
}

- (void)viewDidUnload
{
        
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startOpeFaild:) name:@"GetSalesAgentDetailsNoResultNotif" object:nil];
        
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startingOpe:) name:@"GetSalesAgentDetailsResultNotif" object:nil];
    
    
    self.userNameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.centerCodedTextField.text = @"";
    
    
    
       [super viewWillAppear:animated];
     
}

-(void)startOpeFaild:(NSNotification *)notif
{
    NSDictionary *userInfo=[notif userInfo];
    //NSLog(@"userInfo=%@",userInfo);
    
    NSError *error=[userInfo valueForKey:@"ErrorKey"];
    
    
    if ([error code]==kCFURLErrorNotConnectedToInternet) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        
        [alert show];
        
        alert = nil;
    }
    else if ([error code]==kCFURLErrorTimedOut) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        
        [alert show];
        
        alert = nil;
    }
    else
         
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter Valid Values " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    
    [alert show];
    
    alert = nil;
    }
   
}

-(void)startingOpe:(NSNotification *)notif
{
    
    self.tempArray = [[notif userInfo] valueForKey:@"GetSalesAgentLoginResultKey"];
    
    //NSLog(@"self.tempArray -- %@",self.tempArray);
    
    [self performSegueWithIdentifier:@"LoginViewToSalesTickerViewSegue" sender:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 44)];
    navtitle.text=@"Sales Ticker";
    navtitle.textAlignment=UITextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:18];
    [self.navigationController.navigationBar.topItem setTitleView:navtitle]; 
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetSalesAgentDetailsResultNotif" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LoginViewToSalesTickerViewSegue"]) {
        SalesTickerResultViewController *salesView = [segue destinationViewController];
        
        salesView.tempArray = self.tempArray;
        
        //NSLog(@"salesView--- %@",salesView.tempArray);
    }
    
}
@end
