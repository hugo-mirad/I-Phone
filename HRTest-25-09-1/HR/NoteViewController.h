//
//  NoteViewController.h
//  HRTest
//
//  Created by User on 8/13/14.
//  Copyright (c) 2014 Hugomirad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteViewController : UIViewController
{
    
    UILabel *lblSignIn,*lblModifiedNote;
    
    
}

@property (nonatomic, strong) NSString *strText,*strModifidedNote,*dayStr;
//For Emergency contact details strings
@property (nonatomic, strong) NSString *strSelName,*strSelNameRela,*strSelNameRelaPhoneNum,*strSelNameEmailID,*strSelNameRelaAddr;

@end
