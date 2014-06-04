//
//  AddNewCar.h
//  Car-Finder
//
//  Created by Venkata Chinni on 10/11/13.
//
//

#import <UIKit/UIKit.h>



@interface AddNewCar : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,NSXMLParserDelegate>

@property(strong,nonatomic) NSDictionary *packageDetailsDict;

@end
