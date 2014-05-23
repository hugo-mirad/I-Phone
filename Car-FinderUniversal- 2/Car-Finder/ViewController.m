 //
//  ViewController.m
//  Car-Finder
//
//  Created by Mac on 20/07/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "CommonMethods.h"

#import "CheckButton.h"

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
   // self.navigationController.navigationBar.tintColor=[UIColor blackColor];
  
     UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2-60), 0, 120, 45)];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        
        //load resources for earlier versions
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        navtitle.textColor=[UIColor  whiteColor];
   
        
    } else {
        navtitle.textColor=[UIColor  colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f];

        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39.0f/255.0f green:39.0f/255.0f blue:39.0f/255.0f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        //load resources for iOS 7
        
    }
        navtitle.text=@"UCE Car Finder"; //
        navtitle.textAlignment=NSTextAlignmentLeft;
        navtitle.backgroundColor=[UIColor clearColor];
    
        navtitle.font=[UIFont boldSystemFontOfSize:16];
        //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
        
        self.navigationItem.titleView=navtitle;
        //navtitle.center=self.navigationItem.titleView.center;
        navtitle=nil;
    
    // update status bar to be see-through
	//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
    //


//    [self.navigationController.navigationBar.layer setBorderWidth:0.6];// Just to make sure its working
//    [self.navigationController.navigationBar.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    _av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _av.backgroundColor = [UIColor clearColor];
    _av.opaque = NO;
    //av.image = [UIImage imageNamed:@"back3.png"];
    
      if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
          _av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"launch-768x1004" ofType:@"jpg"]];
          
      }else{
          
          _av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"launch-640x960" ofType:@"jpg"]];
      }
    
    
 
    [self.view addSubview:_av];
    
    
    
    //autolayout constraints
    UIView *superview = self.view;
    [_av setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *avAConstraint1= [NSLayoutConstraint constraintWithItem:_av attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //left of av
    
    
    
    avAConstraint1= [NSLayoutConstraint constraintWithItem:_av attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //right of av
    
    avAConstraint1= [NSLayoutConstraint constraintWithItem:_av attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:avAConstraint1]; //bottom of av
    
   
    avAConstraint1 =
    [NSLayoutConstraint constraintWithItem:_av
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:superview
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:avAConstraint1]; //top of av to top of self.view
    
    
    //
    
    CheckButton *findACarButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    findACarButton.frame=CGRectMake(self.view.frame.size.width/2-100,self.view.frame.size.height/2-30,200,61); //112,118,120,37 //y was 208
        [findACarButton addTarget:self action:@selector(findACarButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    //_____
   
    
    findACarButton.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:2.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
     [findACarButton setTitle:@"Find A Car" forState:UIControlStateNormal];
    [findACarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //Button with 0 border so it's shape like image shape
   // [findACarButton.layer setBorderWidth:1];
   // findACarButton.layer.shadowColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f].CGColor;
    findACarButton.layer.shadowRadius = 2.0f;
    findACarButton.layer.shadowOpacity = 0.5f;
    findACarButton.layer.shadowOffset = CGSizeZero;
    //Font size of title
    findACarButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [findACarButton setShowsTouchWhenHighlighted:YES];
    
    //accessibility
    findACarButton.isAccessibilityElement=YES;
    findACarButton.accessibilityLabel=@"FIND A CAR";
    [self.view addSubview:findACarButton];
    
    //autolayout constriants
   // CGFloat viewHeight=self.view.frame.size.height;
    
    [findACarButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *findACarButtonConstraint=[NSLayoutConstraint constraintWithItem:findACarButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [self.view addConstraint:findACarButtonConstraint]; //center horizontally
  
    
    CGFloat superviewPortraitHeight;
    CGFloat superviewLandscapeHeight;
    superviewPortraitHeight=460;
    superviewLandscapeHeight=320;
    
    CGFloat multiplier = (230.0 - 130.0) / (superviewPortraitHeight - superviewLandscapeHeight);
    CGFloat constant = 130.0 - superviewLandscapeHeight * multiplier;
   
    
    findACarButtonConstraint=[NSLayoutConstraint constraintWithItem:findACarButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:multiplier constant:constant];
    
    [self.view addConstraint:findACarButtonConstraint]; //fix distance from bottom
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        
     
        findACarButtonConstraint=[NSLayoutConstraint constraintWithItem:findACarButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:200];
        [self.view addConstraint:findACarButtonConstraint]; //fix width as given by designer
        
        findACarButtonConstraint=[NSLayoutConstraint constraintWithItem:findACarButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:40];
        [self.view addConstraint:findACarButtonConstraint]; //fix height as given by designer
    }
        else
    {
        
        findACarButtonConstraint=[NSLayoutConstraint constraintWithItem:findACarButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:136];
        [self.view addConstraint:findACarButtonConstraint]; //fix width as given by designer
        
        findACarButtonConstraint=[NSLayoutConstraint constraintWithItem:findACarButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:findACarButtonConstraint]; //fix height as given by designer
        
    }
    
   
    
    CheckButton *loginButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame=CGRectMake(self.view.frame.size.width/2-100,self.view.frame.size.height/2-30+70,200,61); //112,248,120,37
    [loginButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];


    //________
    
    
    loginButton.backgroundColor = [UIColor colorWithRed:241.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithRed:105.0f/255.0f green:90.0f/255.0f blue:85.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    loginButton.layer.shadowRadius = 2.0f;
    loginButton.layer.shadowOpacity = 0.5f;
    loginButton.layer.shadowOffset = CGSizeZero;
    //[loginButton.layer setBorderWidth:0.5f];
    //Font size of title
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
   // [loginButton setTintColor:[UIColor grayColor]];

    //accessibility
    loginButton.isAccessibilityElement=YES;
    loginButton.accessibilityLabel=@"Login";
    [self.view addSubview:loginButton];
    
    
    //autolayout constraints
    [loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *loginButtonConstraint=[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:findACarButton attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [self.view addConstraint:loginButtonConstraint]; //align left edges of findacar, login buttons
    
    loginButtonConstraint=[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:findACarButton attribute:NSLayoutAttributeBottom multiplier:1 constant:10];
    [self.view addConstraint:loginButtonConstraint]; //fix distance b/w findacar, login buttons to 40

   
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        
        
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:200];
        [self.view addConstraint:loginButtonConstraint]; //fix width as given by designer
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:40];
        [self.view addConstraint:loginButtonConstraint]; //fix height as given by designer
    }
    else
    {
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:136];
        [self.view addConstraint:loginButtonConstraint]; //fix width as given by designer
        
        loginButtonConstraint=[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
        [self.view addConstraint:loginButtonConstraint]; //fix height as given by designer
    }
    
    
    
    CheckButton *aboutUsButton=[CheckButton buttonWithType:UIButtonTypeCustom];
    //aboutUsButton.frame=CGRectMake(self.view.frame.size.width-30-30, self.view.frame.size.height-30-30-40, 30, 30);
    [aboutUsButton setBackgroundImage:[UIImage imageNamed:@"InfoBtn.png"] forState:UIControlStateNormal];
    [aboutUsButton addTarget:self action:@selector(aboutUsTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //accessibility
    aboutUsButton.isAccessibilityElement=YES;
    aboutUsButton.accessibilityLabel=@"About us";
    [self.view addSubview:aboutUsButton];
    
    //autolayout constraints
    
    [aboutUsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *aboutUsButtonConstraint=[NSLayoutConstraint constraintWithItem:aboutUsButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:-66];
    [self.view addConstraint:aboutUsButtonConstraint]; //
    
    aboutUsButtonConstraint=[NSLayoutConstraint constraintWithItem:aboutUsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeBottom multiplier:1 constant:-60];
    [self.view addConstraint:aboutUsButtonConstraint]; //
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   
    
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        _av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"launch-1024x748-filp" ofType:@"jpg"]];
        
    }else{
        
        _av.image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"launch-640x960-1" ofType:@"jpg"]];
    }

   
    
    
    
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
