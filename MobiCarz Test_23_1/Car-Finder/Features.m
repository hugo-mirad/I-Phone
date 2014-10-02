//
//  Features.m
//  UCE
//
//  Created by Mac on 02/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Features.h"
#import "CommonMethods.h"

@interface Features ()

@property(strong,nonatomic) UIScrollView *featuresWevView;

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
    
    
    if (_viewFromFeaturesWWithLoginSection == YES) {
        //self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
        //self.view.backgroundColor = [UIColor yellowColor];
        [CommonMethods putBackgroundImageOnView:self.view];
    }
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.textColor=[UIColor  whiteColor];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:self.navTitle];
    [titleLabel sizeToFit];
    [self.navigationItem setTitleView:titleLabel];
    titleLabel=nil;
    
    
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
    
    
    
    NSMutableString *fName=nil;
    NSMutableString *fValue=nil;
    
    mainDict=[[NSMutableDictionary alloc]initWithCapacity:1];
    //[CommonMethods putBackgroundImageOnView:self.view];
    
    
    for (int line=0; line<[self.allFeaturesFromDetailView count]; line++) {
        
        NSString *currObj=[self.allFeaturesFromDetailView objectAtIndex:line];
        
        //find feature name and feature value
        NSRange objRange=[currObj rangeOfString:@","];
        NSRange fNameRange=NSMakeRange(0, objRange.location);
        fName=[[currObj substringWithRange:fNameRange] mutableCopy];
        
        NSRange fValueRange=NSMakeRange(objRange.location+1, [currObj length]-objRange.location-1);
        fValue=[[currObj substringWithRange:fValueRange]mutableCopy];
        
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
    
    NSLog(@"dic --%@",mainDict);
    
    
    
    self.featuresWevView=[[UIScrollView alloc] init];
    [self.view addSubview:self.featuresWevView];
    self.featuresWevView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    
    
}
-(void)backToResultsButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) viewWillLayoutSubviews
{
    if (self.view.frame.size.width >= 480)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            self.featuresWevView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }
        else
        {
            self.featuresWevView.frame = CGRectMake(0, 52, self.view.frame.size.width, self.view.frame.size.height-52);
        }
    }
    else
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            self.featuresWevView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }
        else
        {
            self.featuresWevView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
        }

        
    }
    
    [self addDataToScrollView];
}
-(void) addDataToScrollView
{
    
    for (id view in self.featuresWevView.subviews)
    {
        [view removeFromSuperview];
    }
    
    
    int y = 20;
    
    for (int i=0; i<[mainDict count]; i++)
    {
        
        
        UILabel *headLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, y, self.view.frame.size.width-20, 0)];
        NSString *str = [NSString stringWithFormat:@"%@ : %@", [[mainDict allKeys] objectAtIndex:i], [[mainDict allValues] objectAtIndex:i]];
        headLbl.font = [UIFont fontWithName:@"Helvetica" size:16];
        //headLbl.backgroundColor = [UIColor yellowColor];
        headLbl.numberOfLines = 0;
        headLbl.backgroundColor = [UIColor clearColor];
        headLbl.textColor = [UIColor blackColor];
        headLbl.tag = i;
        NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:str];
        
        NSRange rng= [str rangeOfString:@":"];
        
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:16.0] range:NSMakeRange(0, NSMaxRange(rng))];
        
        headLbl.attributedText = attString;
        
        CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:18] constrainedToSize:CGSizeMake(self.view.frame.size.width-20, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect rect = headLbl.frame;
        rect.size.height = size.height;
        headLbl.frame = rect;
        
        [self.featuresWevView addSubview:headLbl];
        
        y = y + size.height + 14;
    }
    
    [self.featuresWevView setContentSize:CGSizeMake(self.featuresWevView.frame.size.width, y + 20)];
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration

{
    
    
}


@end
