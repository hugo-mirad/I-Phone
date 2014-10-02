//
//  NoteViewController.m
//  HRTest
//
//  Created by User on 8/13/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
   // txtViewSignIn.text = self.strText;
    
    
    NSUserDefaults *defalts = [NSUserDefaults standardUserDefaults];
    
    int typeOfEmpDetails = [[defalts objectForKey:@"typeOfEmpDetailsKey"] intValue];
    
    if (typeOfEmpDetails == 890)
    {
        [defalts removeObjectForKey:@"typeOfEmpDetailsKey"];
        //self.view.backgroundColor = [UIColor blackColor ];
        
        
//        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 130, 30)];
//        nameLbl.font = [UIFont boldSystemFontOfSize:13];
//        nameLbl.text = [NSString stringWithFormat:@"Emergency Contact :"];
//        nameLbl.textColor = [UIColor whiteColor];
//        [self.view addSubview:nameLbl];
        
        UILabel *nameLblVal = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 280, 30)];
        nameLblVal.font = [UIFont boldSystemFontOfSize:12];
        nameLblVal.backgroundColor = [UIColor clearColor];
        nameLblVal.text = [NSString stringWithFormat:@"  %@",_strSelName];
        nameLblVal.textColor = [UIColor whiteColor];
        [self.view addSubview:nameLblVal];
        
      
        
//        UILabel *relPhoneNumLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 34, 70, 26)];//(4, 34, 200, 26)
//        relPhoneNumLbl.font = [UIFont systemFontOfSize:12];
//        relPhoneNumLbl.text = [NSString stringWithFormat:@"Phone#      :"];
//        relPhoneNumLbl.textColor = [UIColor whiteColor];
//        [self.view addSubview:relPhoneNumLbl];
        
        UILabel *relPhoneNumValLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 34, 280, 26)];//(4, 34, 200, 26)
        relPhoneNumValLbl.font = [UIFont systemFontOfSize:12];
        relPhoneNumValLbl.backgroundColor = [UIColor clearColor];
        relPhoneNumValLbl.text = [NSString stringWithFormat:@"  %@",_strSelNameRelaPhoneNum];
        relPhoneNumValLbl.textColor = [UIColor whiteColor];
        [self.view addSubview:relPhoneNumValLbl];
        
        
        
//        
//        UILabel *relEmailIDLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 60, 70, 24)];//(4, 60, 200, 24)
//        relEmailIDLbl.font = [UIFont systemFontOfSize:12];
//        relEmailIDLbl.text = [NSString stringWithFormat:@"Email ID     :"];
//        relEmailIDLbl.textColor = [UIColor whiteColor];
//        [self.view addSubview:relEmailIDLbl];
        
        
        UILabel *relEmailIDValLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 66, 280, 34)];//(4, 60, 200, 24)
        relEmailIDValLbl.font = [UIFont systemFontOfSize:12];
        relEmailIDValLbl.backgroundColor = [UIColor clearColor];
        relEmailIDValLbl.text = [NSString stringWithFormat:@"  %@",_strSelNameEmailID];
        relEmailIDValLbl.textColor = [UIColor whiteColor];
        [self.view addSubview:relEmailIDValLbl];
        relEmailIDValLbl.numberOfLines = 0;
        [relEmailIDValLbl sizeToFit];
        
        
        
        
        UILabel *relLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 90, 280, 24)];//(4, 84, 200, 24)
        relLbl.font = [UIFont systemFontOfSize:12];
        relLbl.backgroundColor = [UIColor clearColor];
        relLbl.text = [NSString stringWithFormat:@"  %@",_strSelNameRela];
        relLbl.textColor = [UIColor whiteColor];
        [self.view addSubview:relLbl];
        
        
//        UILabel *relAddrLbl = [[UILabel alloc] initWithFrame:CGRectMake(4, 98, 70, 64)];
//        relAddrLbl.font = [UIFont systemFontOfSize:12];
//        relAddrLbl.text = [NSString stringWithFormat:@"Address     :"];
//        relAddrLbl.textColor = [UIColor whiteColor];
//        [self.view addSubview:relAddrLbl];
        
        UILabel *relAddrValLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 122, 280, 64)];
        relAddrValLbl.font = [UIFont systemFontOfSize:12];
        relAddrValLbl.backgroundColor = [UIColor clearColor];
        relAddrValLbl.text = [NSString stringWithFormat:@"%@",_strSelNameRelaAddr];
        relAddrValLbl.textColor = [UIColor whiteColor];
        [self.view addSubview:relAddrValLbl];
        relAddrValLbl.numberOfLines = 0;
//     
        [relAddrValLbl sizeToFit];
       
    }
    else
    {
    NSString *strNotes = self.strText;
    
   NSString *myString = [strNotes stringByReplacingOccurrencesOfString:@"" withString:@"\n\n"];

   
    
    NSString *day = self.dayStr;
    
        UILabel *lblName  = [[UILabel alloc] init];
        lblName.text = [NSString stringWithFormat:@"   %@", day];
        lblName.textColor = [UIColor blackColor];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            lblName.frame = CGRectMake(2, 0, 286, 24);
            lblName.font = [UIFont boldSystemFontOfSize:14];
        }
        else
        {
            lblName.frame = CGRectMake(2, 2, 326, 32);
            lblName.font = [UIFont boldSystemFontOfSize:22];
        }
        lblName.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:lblName];
    
    
        
        UIScrollView *scr = [[UIScrollView alloc] init];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            scr.frame = CGRectMake(0, 24, 288, 96);
        }
        else
        {
            scr.frame = CGRectMake(0, 32, 330, 168);
        }
        scr.showsVerticalScrollIndicator= NO;
        //scr.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:scr];
        
        
        
    lblSignIn = [[UILabel alloc] init];
    lblSignIn.numberOfLines = 0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            lblSignIn.frame = CGRectMake(4, 10, 282, 90);
            lblSignIn.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            lblSignIn.frame = CGRectMake(10, 8, 300, 90);
            lblSignIn.font = [UIFont systemFontOfSize:20];
        }
    lblSignIn.backgroundColor = [UIColor clearColor];
    lblSignIn.text = myString;
    lblSignIn.textColor = [UIColor whiteColor];
    [lblSignIn sizeToFit];
    [scr addSubview:lblSignIn];
    
    NSString *modifidedStr = self.strModifidedNote;
    
    lblModifiedNote = [[UILabel alloc] init];
    lblModifiedNote.numberOfLines = 0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            lblModifiedNote.frame = CGRectMake(4, lblSignIn.frame.origin.y+lblSignIn.frame.size.height+10, 280, 40);
            lblModifiedNote.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            lblModifiedNote.frame = CGRectMake(20, lblSignIn.frame.origin.y+lblSignIn.frame.size.height+10, 300, 40);
            lblModifiedNote.font = [UIFont systemFontOfSize:20];
        }
    lblModifiedNote.backgroundColor = [UIColor clearColor];
    lblModifiedNote.text = modifidedStr;
    lblModifiedNote.textColor = [UIColor whiteColor];
    [lblModifiedNote sizeToFit];
    [scr addSubview:lblModifiedNote];
    
    int contentHeight;
    if (modifidedStr.length != 0)
    {
         contentHeight = lblModifiedNote.frame.size.height + lblModifiedNote.frame.origin.y;
    }
    else
    {
         contentHeight = lblSignIn.frame.size.height + lblSignIn.frame.origin.y;
    }
    
        //scr.backgroundColor = [UIColor yellowColor];
 
    [scr setContentSize:(CGSizeMake(200, contentHeight+20))];
    
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
