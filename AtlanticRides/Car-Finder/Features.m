//
//  Features.m
//  UCE
//
//  Created by Mac on 02/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Features.h"

@interface Features ()

@property(strong,nonatomic) UIWebView *featuresWevView;

@end

@implementation Features
@synthesize featuresWevView=_featuresWevView,allFeaturesFromDetailView=_allFeaturesFromDetailView;

@synthesize navTitle=_navTitle;

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
    
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    //navigation bar title
    UILabel *titleLabel=[[UILabel alloc]init];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:self.navTitle];
    [titleLabel sizeToFit];
    [self.navigationItem setTitleView:titleLabel];
    titleLabel=nil;
    
    
    //NSLog(@"allFeatures=%@",self.allFeaturesFromDetailView);
    NSMutableString *fName=nil;
    NSMutableString *fValue=nil;
    
    NSMutableDictionary *mainDict=[[NSMutableDictionary alloc]initWithCapacity:1];
    
    
    for (int line=0; line<[self.allFeaturesFromDetailView count]; line++) {
        
        NSString *currObj=[self.allFeaturesFromDetailView objectAtIndex:line];
        
        //find feature name and feature value
        NSRange objRange=[currObj rangeOfString:@","];
        NSRange fNameRange=NSMakeRange(0, objRange.location);
        fName=[[currObj substringWithRange:fNameRange] mutableCopy];
        
        
        
        NSRange fValueRange=NSMakeRange(objRange.location+1, [currObj length]-objRange.location-1);
        fValue=[[currObj substringWithRange:fValueRange]mutableCopy];
        //NSLog(@"fName=%@ fValue=%@",fName,fValue);
        
        __block BOOL fNameFoundInMainDict=NO;
        
        [mainDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)key isEqualToString:fName]) {
                fNameFoundInMainDict=YES;
                *stop=YES;
            }
        }];
        
        if (fNameFoundInMainDict) {
            NSMutableString *thisFNameValue=[[mainDict objectForKey:fName]mutableCopy];
            
            [thisFNameValue appendString:[NSString stringWithFormat:@", %@",fValue]];
            
            [mainDict setObject:(NSString *)thisFNameValue forKey:fName];
            
        }
        else
        {
            [mainDict setObject:fValue forKey:fName];
        }
    }
    
    //NSLog(@"mainDict=%@",mainDict);
    
    __block NSMutableString *htmlStr=[NSMutableString string];
    
    htmlStr=[@"<html><body><font color='white'><b><center>Car Features</center></b><br />" mutableCopy];
    
    
    
    NSArray *sortedFNameKeys=[[mainDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    //NSLog(@"sortedFNameKeys=%@",sortedFNameKeys);
    
    [sortedFNameKeys enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mainDict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key1, id obj1, BOOL *stop) {
            if([obj isEqualToString:key1])
            {
                [htmlStr appendString:[NSString stringWithFormat:@"<b>%@:</b> %@<p>",key1,obj1]];
            }
        }];
    }];
    
    //
    
    
    [htmlStr appendString:@"</font></body></html>"];
    
    //NSLog(@"htmlStr=%@",htmlStr);
    self.featuresWevView=[[UIWebView alloc] init];
    //self.featuresWevView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.featuresWevView];
    
    
    //self.featuresWevView.backgroundColor = [UIColor clearColor];
    self.featuresWevView.opaque = NO;
    UIImage *img=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back" ofType:@"png"]];
    [self.featuresWevView setBackgroundColor:[UIColor colorWithPatternImage:img]];
    
    //autolayout constraints
    [self.featuresWevView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Create & Add Constraint
    NSLayoutConstraint *constraint =
    [NSLayoutConstraint constraintWithItem:self.featuresWevView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0];
    [self.view addConstraint:constraint];
    
    constraint =
    [NSLayoutConstraint constraintWithItem:self.featuresWevView
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeLeading
                                multiplier:1
                                  constant:0];
    [self.view addConstraint:constraint];
    
    constraint =
    [NSLayoutConstraint constraintWithItem:self.featuresWevView
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1
                                  constant:0];
    [self.view addConstraint:constraint];
    
    constraint =
    [NSLayoutConstraint constraintWithItem:self.featuresWevView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    [self.view addConstraint:constraint];
    
    
    [self.featuresWevView loadHTMLString:htmlStr baseURL:nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"self.view height=%.0f self.featuresWevView height=%.0f",self.view.frame.size.height, self.featuresWevView.frame.size.height);
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
    return YES;
}

-(void)dealloc
{
    [_featuresWevView setDelegate:nil];
    [_featuresWevView stopLoading];
    [_featuresWevView.scrollView setDelegate:nil];
    
    _featuresWevView=nil;
    _navTitle=nil;
    
    _allFeaturesFromDetailView=nil;
    
}

@end
