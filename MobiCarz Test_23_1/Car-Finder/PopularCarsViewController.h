//
//  PopularCarsViewController.h
//  Car-Finder
//
//  Created by Venkata Chinni on 11/8/13.
//
//

#import <UIKit/UIKit.h>
#import "HomeScreenOperation.h"
#import "FindCurrentZip.h"
#import "DetailView.h"

@interface PopularCarsViewController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,FindCurrentZipDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,DetailViewDelegate>

@end
