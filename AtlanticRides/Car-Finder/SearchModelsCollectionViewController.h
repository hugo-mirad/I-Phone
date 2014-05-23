//
//  SearchModelsCollectionViewController.h
//  Car-Finder
//
//  Created by Venkata Chinni on 11/18/13.
//
//

#import <UIKit/UIKit.h>

@interface SearchModelsCollectionViewController : UICollectionViewController

@property(copy,nonatomic) NSString *zipReceived,*makeNameReceived,*makeIDReceived;

@property(strong,nonatomic) NSDictionary *modelsDictionary;

@end
