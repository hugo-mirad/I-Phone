//
//  SearchModelsCollectionViewController.m
//  Car-Finder
//
//  Created by Venkata Chinni on 11/18/13.
//
//

#import "SearchModelsCollectionViewController.h"

#import "SearchModelsCollectionCell.h"
#import "CommonMethods.h"
#import "SearchResultsViewController.h"
#import "SearchOperation.h"


@interface SearchModelsCollectionViewController ()


@property(strong,nonatomic) NSOperationQueue *downloadMakesOperationQueue;

@property(strong,nonatomic) NSMutableArray *sortedModels;

@property(copy,nonatomic) NSString *modelNameSelected,*modelIdSelected;
@property(strong,nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation SearchModelsCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Controller Life Cyle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    
    
    UILabel *navtitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 130, 44)];
    navtitle.text=self.makeNameReceived;
    navtitle.textAlignment=NSTextAlignmentCenter;
    navtitle.backgroundColor=[UIColor clearColor];
    navtitle.textColor=[UIColor whiteColor];
    navtitle.font=[UIFont boldSystemFontOfSize:14];
    //[self.navigationController.navigationBar.topItem setTitleView:navtitle];
    self.navigationItem.titleView=navtitle;
    navtitle=nil;
    
    self.collectionView.backgroundView = [CommonMethods backgroundImageOnCollectionView:self.collectionView];
    
  
    
    
    [self displayModelsButtons:NO];
    
    self.downloadMakesOperationQueue=[[NSOperationQueue alloc]init];
    [self.downloadMakesOperationQueue setName:@"SearchViewQueue"];
    [self.downloadMakesOperationQueue setMaxConcurrentOperationCount:1];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.sortedModels && self.sortedModels.count) {
        return self.sortedModels.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SearchModelsCollectionCell *cell=(SearchModelsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchModelsCollectionCellID" forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UILabel *newLbl=[[UILabel alloc] init];
    newLbl.text=self.sortedModels[indexPath.item];
    CGSize newLblSize= [newLbl intrinsicContentSize];
    newLblSize.width+=2;
    newLblSize.height+=2;
    
    return newLblSize;
    
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)configureCell:(SearchModelsCollectionCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.modelLabel.text=self.sortedModels[indexPath.item];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
   
    
    NSString *btnTitle=self.sortedModels[indexPath.item];
    NSLog(@"makeBtnTapped ... %@",btnTitle);
    
    
    //get models related to this make from coredata and pass zip, makename, makeid, all models with their ids to next view
    self.modelNameSelected=self.sortedModels[indexPath.item];
    
    
    //
    __weak SearchModelsCollectionViewController *weakSelf=self;
    [self.modelsDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        if([(NSString *)obj isEqualToString:btnTitle])
        {
            //NSLog(@"selected make is %@. id is %@",[weakSelf.sortedMakes objectAtIndex:row],key);
            
            weakSelf.modelIdSelected=(NSString *)key;
            *stop=YES;
        }
    }];
    
    //
    SearchOperation *searchOperation=[[SearchOperation alloc]init];
    
    searchOperation.makeIdReceived=self.makeIDReceived;
    searchOperation.modelIdReceived=self.modelIdSelected;
    
    searchOperation.makeNameReceived=self.makeNameReceived;
    searchOperation.modelNameReceived=self.modelNameSelected;
    searchOperation.zipReceived=self.zipReceived;
    if ([self.zipReceived isEqualToString:@"0"]) {
        searchOperation.milesReceived=@"5";
        
    }
    else
    {
        searchOperation.milesReceived=@"4";
    }
    searchOperation.pageNoReceived=1;
    
    [self.downloadMakesOperationQueue addOperation:searchOperation];
    
    
    
    BOOL allMilesSelected;
    NSString *miles;
    
    if([self.zipReceived isEqualToString:@"0"])
    {
        allMilesSelected=YES;
        miles=@"5";
    }
    else{
        allMilesSelected=NO;
        miles=@"4";
    }

    NSDictionary *dictionary=@{@"zipCode":self.zipReceived,@"allMilesSelected":[NSNumber numberWithBool:allMilesSelected],@"makeName":self.makeNameReceived,@"makeID":self.makeIDReceived,@"modelName":self.modelNameSelected,@"modelId":self.modelIdSelected,@"miles":miles};
    
    [self performSegueWithIdentifier:@"Searchviewsegue" sender:dictionary];
    
    
}


#pragma mark - Private Methods
- (void)displayModelsButtons:(BOOL)showPopularModels
{
    //NSLog(@"self.modelsDictionary=%@",self.modelsDictionary);
    
    NSMutableDictionary *dictAfterRemovingAllModels=[self.modelsDictionary mutableCopy];
    [dictAfterRemovingAllModels removeObjectForKey:@"0"];
    
    NSArray *allModels=[dictAfterRemovingAllModels allValues];
    
    self.sortedModels=[[allModels sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
    
    //NSLog(@"self.sortedModels--%d", self.sortedModels.count);
    if (self.sortedModels.count ==1)
    {
        NSLog(@"self.sortedModels--%d", self.sortedModels.count);
    }
    else{
    
    //reinsert All Models entry at 0th position
    [self.sortedModels insertObject:@"All Models" atIndex:0];
    
    [dictAfterRemovingAllModels setObject:@"All Models" forKey:@"0"];
    
    self.modelsDictionary=[NSDictionary dictionaryWithDictionary:dictAfterRemovingAllModels];
    }
    [self.collectionView reloadData];
}

#pragma mark - Prepare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Searchviewsegue"]) {
        
        
        SearchResultsViewController *searchResultsCustomTable=[segue destinationViewController];
        
        
        /*
         NSDictionary *dictionary=@{@"zipCode":self.zipReceived,@"allMilesSelected":[NSNumber numberWithBool:allMilesSelected],@"makeName":self.makeNameReceived,@"makeID":self.makeIDReceived,@"modelName":modelNameSelected,@"modelId":modelIdSelected,@"miles":miles};
         */
        NSDictionary *dictionary=(NSDictionary *)sender;
        
        
        searchResultsCustomTable.allMilesSelected=[[dictionary objectForKey:@"allMilesSelected"] boolValue];
        
        
        
        searchResultsCustomTable.makeIdReceived=[dictionary objectForKey:@"makeID"];
        searchResultsCustomTable.modelIdReceived=[dictionary objectForKey:@"modelId"];
        searchResultsCustomTable.makeNameReceived=[dictionary objectForKey:@"makeName"];
        searchResultsCustomTable.modelNameReceived=[dictionary objectForKey:@"modelName"];
        searchResultsCustomTable.zipReceived=[dictionary objectForKey:@"zipCode"];
        
        
        searchResultsCustomTable.milesReceived=[dictionary objectForKey:@"miles"];
        
        
        
        //NSLog(@"SearchView-prepareForSegue: Search results are being retreived makeName=%@ model Name=%@ zip=%@ miles=%@",self.makeNameSelected,self.modelNameSelected,self.zipStr,self.radiusSelected);
        
    }
}



-(void)dealloc
{
    
}

@end
