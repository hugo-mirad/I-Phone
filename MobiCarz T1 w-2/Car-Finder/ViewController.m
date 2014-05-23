 //
//  ViewController.m
//  Car-Finder
//
//  Created by Mac on 20/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "CommonMethods.h"

//for glossy button
#import "CheckButton.h"
#import "UIButton+Glossy.h"

//for glossy button category
#import "QuartzCore/QuartzCore.h"

#import "LoginViewController.h"
#import "AboutUs.h"


#import "AppDelegate.h"

@interface ViewController ()

@property(strong, nonatomic) UIImageView *av;

@end


@implementation ViewController


@synthesize av = _av;

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
   // //[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    self.navigationController.navigationBar.hidden = YES;
   // self.view.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];//colorWithRed:216.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f
    
    self.view.backgroundColor = [UIColor redColor];
    
    aboutUsButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
    aboutUsButton.frame=CGRectMake(self.view.frame.size.width-30-30, self.view.frame.size.height-60, 30, 30);
    }else{
        
        aboutUsButton.frame=CGRectMake(self.view.frame.size.width-90, self.view.frame.size.height-80, 50, 50);
    }
    [aboutUsButton setBackgroundImage:[UIImage imageNamed:@"Info.png"] forState:UIControlStateNormal];
    [aboutUsButton addTarget:self action:@selector(aboutUsTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //accessibility
    aboutUsButton.isAccessibilityElement=YES;
    aboutUsButton.accessibilityLabel=@"About us";
    [loginScroll addSubview:aboutUsButton];
    
    loginScroll.showsVerticalScrollIndicator = NO;
    //autolayout constraints
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(NSUInteger)supportedInterfaceOrientations
{
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            loginScroll.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        else
        {
            loginScroll.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            //loginScroll.frame = CGRectMake(0, 64-10, self.view.frame.size.width, self.view.frame.size.height-64+10);
            [loginScroll setContentSize:CGSizeMake(loginScroll.frame.size.width, loginScroll.frame.size.height)];
        }
        else
        {
            [loginScroll setContentSize:CGSizeMake(loginScroll.frame.size.width, loginScroll.frame.size.height)];
        }
    }
    else
    {
        loginScroll.frame = self.view.frame;
        [loginScroll setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    }
    
    return UIInterfaceOrientationMaskAll;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
   // aboutUsButton.hidden = YES;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            loginScroll.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        else
        {
            loginScroll.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            aboutUsButton.frame=CGRectMake(420, 270, 30, 30);

            //loginScroll.frame = CGRectMake(0, 64-10, self.view.frame.size.width, self.view.frame.size.height-64+10);
            [loginScroll setContentSize:CGSizeMake(loginScroll.frame.size.width, loginScroll.frame.size.height)];
        }
        else
        {
            aboutUsButton.frame=CGRectMake(self.view.frame.size.width-30-30, self.view.frame.size.height-40, 30, 30);
            [loginScroll setContentSize:CGSizeMake(loginScroll.frame.size.width, loginScroll.frame.size.height)];
        }
    }
    else
    {
        aboutUsButton.frame=CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height-80, 50, 50);
        loginScroll.frame = self.view.frame;
        [loginScroll setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        [loginScroll setContentSize:CGSizeMake(loginScroll.frame.size.width, loginScroll.frame.size.height)];
    }
    
    [self.view endEditing:YES];
    
    [loginScroll setContentOffset:CGPointZero];
}




- (void)viewWillAppear:(BOOL)animated
{
    //loginScroll.userInteractionEnabled = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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

#pragma mark -Button Methods
- (void)loginButtonTapped
{
   
       UIStoryboard *loginStoryboard;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        loginStoryboard=[UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
    }
    else //iPad
    {
        loginStoryboard=[UIStoryboard storyboardWithName:@"LoginStoryboard-iPad" bundle:nil];
    }
    UINavigationController *initViewController = [loginStoryboard instantiateInitialViewController];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate.window  setRootViewController:initViewController];
}

#pragma mark - Prepare For Segue

- (void)findACarButtonTapped
{
    
        
    //[self performSegueWithIdentifier:@"FindACarSegue" sender:nil];
    
    UIStoryboard *findACarStoryboard;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        findACarStoryboard=[UIStoryboard storyboardWithName:@"FindACarStoryboard" bundle:nil];
    }
    else //iPad
    {
        findACarStoryboard=[UIStoryboard storyboardWithName:@"FindACarStoryboard-iPad" bundle:nil];
    }
    UITabBarController *initViewController = [findACarStoryboard instantiateInitialViewController];
    
    AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    [appDelegate.window  setRootViewController:initViewController];
    
    
}



- (void)aboutUsTapped
{
    UIStoryboard *mainStoryboard;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    }
    else //iPad
    {
        mainStoryboard=[UIStoryboard storyboardWithName:@"MainStoryboard-iPad" bundle:nil];
    }
    AboutUs *aboutUs=[mainStoryboard instantiateViewControllerWithIdentifier:@"AboutUsId"];
    
        aboutUs.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:aboutUs animated:YES completion:nil];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
}

-(void)dealloc
{
    
    
}

@end
