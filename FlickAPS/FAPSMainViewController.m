//
//  FAPSMainViewController.m
//  FlickAPS
//
//  Created by Abdullah  on 28/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSMainViewController.h"
#import <AFNetworking.h>
#import <Mantle.h>
#import <PureLayout.h>
#import <ProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FAPSPhotoObject.h"
#import "FAPSTagsObject.h"
#import "FAPSHotTagObject.h"
#import "FAPSCollectionCell.h"

@interface FAPSMainViewController ()

@property (strong, nonatomic) NSMutableArray *publicPhotoArray;
@property (strong, nonatomic) NSMutableArray *dictionaryArray;
@property (strong, nonatomic) NSMutableArray *photoArrayWithPhotos;
@property (strong, nonatomic) NSMutableArray *filteredPublicPhotoArray;
@property (strong, nonatomic) NSMutableArray *hotTagsArray;
@property (strong, nonatomic) NSMutableArray *filteredHotTagsArray;
@property (strong, nonatomic) UIView *fullScreenView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *currentPage;
@property (strong, nonatomic) NSString *totalPage;
@property (assign, nonatomic) NSInteger pageNumber;
@property (assign, nonatomic) NSInteger totalPageNumber;
@property (assign, nonatomic) NSInteger totalItem;
@property NSUserDefaults *userDefaults;
@property BOOL isSearching;
@property BOOL isHotTagSearching;
@property (nonatomic) CGFloat lastContentOffset;

@property (nonatomic,strong) NSMutableArray *photoSizeArray;
@property SDWebImageDownloader *downloader;
@property AFHTTPSessionManager *manager;
@end

@implementation FAPSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.collectionView.delegate = self;
    self.filteredPublicPhotoArray = [[NSMutableArray alloc]init];
    self.filteredHotTagsArray = [[NSMutableArray alloc]init];
    self.photoArrayWithPhotos = [[NSMutableArray alloc]init];
    self.publicPhotoArray = [[NSMutableArray alloc]init];
    self.photoSizeArray = [[NSMutableArray alloc]init];
    self.dictionaryArray = [[NSMutableArray alloc]init];
    self.manager = [AFHTTPSessionManager manager];
    self.downloader = [SDWebImageDownloader sharedDownloader];
    self.pageNumber = 1;
    self.searchBar.delegate = self;
    self.searchView.hidden = YES;
    self.isSearching = NO;
    self.isHotTagSearching = NO;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard)];
    UITextField *searchBarTextField = [self.searchBar valueForKey:@"_searchField"];
    searchBarTextField.clearButtonMode = UITextFieldViewModeNever;
     [self getHotTags];
}

- (void)getHotTags{
   NSArray *hotTagArrayFromUserDefaults = [self.userDefaults objectForKey:@"hotTagArray"];
   NSString *pageNumberString = [NSString stringWithFormat:@"%li",self.pageNumber];
    self.hotTagsArray = [NSMutableArray array];
    for (NSData *hotTagData in hotTagArrayFromUserDefaults) {
        FAPSHotTagObject *hotTag = (FAPSHotTagObject *)[NSKeyedUnarchiver unarchiveObjectWithData:hotTagData];
        [self.hotTagsArray addObject:hotTag];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getRecentPublicPhotos:pageNumberString];
    });
}

#pragma mark - CollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count;
    
    if (self.isSearching) {
        count = self.filteredPublicPhotoArray.count;
    } else {
        if (self.pageNumber == self.totalPageNumber
            || self.totalItem == self.publicPhotoArray.count) {
            count = self.publicPhotoArray.count;
        }else{
            count = self.publicPhotoArray.count+1;
        }
    }
    return count ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FAPSCollectionCell *cell = nil;
    if (indexPath.row == [self.publicPhotoArray count]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flickrCell" forIndexPath:indexPath];
        cell.username.text = @"";
        cell.userPhoto.image = nil;
        cell.originalPhoto.image = [UIImage imageNamed:@"loading.png"];
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"loadingCell" forIndexPath:indexPath];
        FAPSPhotoObject *photoObject = [[FAPSPhotoObject alloc]init];
        if (self.isSearching){
            photoObject = (FAPSPhotoObject *)self.filteredPublicPhotoArray[(NSUInteger)indexPath.row];
        }else{
            photoObject = (FAPSPhotoObject *)self.publicPhotoArray[(NSUInteger)indexPath.row];
        }
        cell.username.text = photoObject.fullName;
        cell.tag = indexPath.row;
        cell.userPhoto.layer.cornerRadius = cell.userPhoto.frame.size.width / 2;
        cell.userPhoto.clipsToBounds = YES;
        cell.userPhoto.image = [UIImage imageWithData:photoObject.profilePhotoData];
        cell.originalPhoto.image = [UIImage imageWithData:photoObject.originalPhoto];
        self.isSearching = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissKeyboard];
    FAPSPhotoObject *photoObject = (FAPSPhotoObject *) self.publicPhotoArray[indexPath.row];
    [self addFullScreenView:photoObject];
}

- (void)scrollViewDidScroll:(UICollectionView *)collectionView{
    if (collectionView == self.collectionView) {
        [self dismissKeyboard];
    }
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [self.publicPhotoArray count] - 1) {
        [self getRecentPublicPhotos:[NSString stringWithFormat:@"%li",self.pageNumber]];
    }
}

#pragma mark - Full Screen Methods

- (void)addFullScreenView:(FAPSPhotoObject *)photoObject{
    self.fullScreenView = [[UIView alloc] init];
    [self.fullScreenView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.85f]];
    
    UITapGestureRecognizer *swipeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseFullScreen:)];
    [self.fullScreenView addGestureRecognizer:swipeGesture];
    
    [self.view addSubview:self.fullScreenView];
    [self fullScreenViewForConstraint:self.fullScreenView withView:self.view withState:0];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageWithData:photoObject.originalPhoto];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.fullScreenView addSubview:imageView];
    [self fullScreenViewForConstraint:imageView withView:self.fullScreenView withState:1];
}

- (void)tapToCloseFullScreen:(UISwipeGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^(void) {
                        [self.fullScreenView removeFromSuperview];
                     }
                    completion:NULL];
}

#pragma mark - Search Bar Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isSearching = NO;
        self.isHotTagSearching = NO;
        [self.filteredPublicPhotoArray removeAllObjects];
        [self.filteredHotTagsArray removeAllObjects];
        [self.collectionView reloadData];
        [self.tableView reloadData];
        [self dismissKeyboard];
    });
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchView.hidden = NO;
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = searchBar.text;
    [self searchWithTag:searchString];
    [self searchWithUserName:searchString];
    self.isSearching = YES;
    [self.collectionView reloadData];
    [self dismissKeyboard];
  
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.searchView.hidden = YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.filteredHotTagsArray removeAllObjects];
    for (FAPSHotTagObject *hotTag in self.hotTagsArray) {
        NSRange rangeValue = [hotTag.content rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitivePredicateOption)];
        if (rangeValue.length>0) {
            [self.filteredHotTagsArray addObject:hotTag];
            self.isHotTagSearching = YES;
            [self.tableView reloadData];
        }
    }
}
#pragma mark - Tableview Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger hotTagCount;
    if (self.isHotTagSearching == YES) {
        hotTagCount = self.filteredHotTagsArray.count;
    }else{
        hotTagCount = self.hotTagsArray.count;
    }
    return hotTagCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"hotTagCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dataCell"];
    }
    FAPSHotTagObject *hotTagObject;
    if (self.isHotTagSearching == YES) {
        hotTagObject = (FAPSHotTagObject *)self.filteredHotTagsArray[indexPath.row];
    }else{
        hotTagObject = (FAPSHotTagObject *)self.hotTagsArray[indexPath.row];
    }
    cell.textLabel.text = hotTagObject.content;
    return cell;
}

#pragma mark - Search Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FAPSHotTagObject *hotTag;
    if (self.isHotTagSearching == YES) {
        hotTag = (FAPSHotTagObject *)self.filteredHotTagsArray[indexPath.row];
    }else{
        hotTag = (FAPSHotTagObject *)self.hotTagsArray[indexPath.row];
    }
    [self searchWithTag:hotTag.content];
    self.isSearching = YES;
    [self.collectionView reloadData];
    [self dismissKeyboard];
}

- (void)searchContent:(NSString *)content withFilterContent:(NSString *)filterContent withFilteredPhoto:(FAPSPhotoObject *)filteredPhoto{
    NSComparisonResult result = [content compare:filterContent options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:[content rangeOfString:filterContent options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]];
    if (result == NSOrderedSame){
        [self.filteredPublicPhotoArray addObject:filteredPhoto];
    }
}

- (void)searchWithTag:(NSString *)hotTagContent{
    [self.filteredPublicPhotoArray removeAllObjects];
    for (FAPSPhotoObject *filteredPhoto in self.publicPhotoArray) {
        for(FAPSTagsObject *tagObject in filteredPhoto.tagsArray){
            if (tagObject != nil) {
                [self searchContent:tagObject.content withFilterContent:hotTagContent withFilteredPhoto:filteredPhoto];
            }
        }
    }
}

- (void)searchWithUserName:(NSString *)userNameContent{
    for (FAPSPhotoObject *filteredPhoto in self.publicPhotoArray) {
        [self searchContent:filteredPhoto.fullName withFilterContent:userNameContent withFilteredPhoto:filteredPhoto];
    }
}

#pragma mark - Full Screen Constraint Method

- (void)fullScreenViewForConstraint:(UIView *)fullScreenView withView:(UIView *)selfView withState:(NSInteger)state{
    ALDimension dimension;
    switch (state) {
        case 0:
            dimension = ALDimensionHeight;
            break;
        case 1:
            dimension = ALDimensionWidth;
            break;
            
        default:
            break;
    }
    [fullScreenView autoMatchDimension:ALDimensionWidth
                           toDimension:ALDimensionWidth
                                ofView:selfView
                        withMultiplier:1.0];
    [fullScreenView autoMatchDimension:ALDimensionHeight
                           toDimension:dimension
                                ofView:selfView
                        withMultiplier:1.0];
    [fullScreenView autoAlignAxis:ALAxisHorizontal
                 toSameAxisOfView:selfView];
    [fullScreenView autoAlignAxis:ALAxisVertical
                 toSameAxisOfView:selfView];
}

- (void) dismissKeyboard
{
    self.searchView.hidden = YES;
    self.searchBar.showsCancelButton = NO;
    [self.view removeGestureRecognizer:self.tap];
    [self.searchBar resignFirstResponder];
}

#pragma mark - Loading Flickr Data Methods

- (void)getRecentPublicPhotos:(NSString *)pageNumber{
    [self.manager GET:[self getFlickrApiUrl:0 withParameter:pageNumber]
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"photos"];
                  NSDictionary *publicPhotoDictionary = [responseDictionary objectForKey:@"photo"];
                  
                  self.totalItem = [(NSString *)[responseObject objectForKey:@"total"] integerValue];
                  self.totalPageNumber = [(NSString *)[responseDictionary objectForKey:@"pages"]integerValue];
                  NSError *error;
                  for (NSDictionary *dictionary in publicPhotoDictionary){
                      FAPSPublicPhoto *publicPhoto =  [MTLJSONAdapter modelOfClass:FAPSPublicPhoto.class
                                                                fromJSONDictionary:dictionary
                                                                             error:&error];
                      [self getPublicPhotoFlickrUser:publicPhoto];
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"%@",error);
              }];
}

- (void)getPublicPhotoFlickrUser:(FAPSPublicPhoto *)publicPhoto{
        [self.manager GET:[self getFlickrApiUrl:1 withParameter:publicPhoto.photoOwner]
               parameters:nil
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"person"];
                      NSError *error;
                      NSDictionary *responseDictionaryForFullName = [[responseDictionary valueForKey:@"username"] objectForKey:@"_content"];
                      NSString *fullName = [NSString stringWithFormat:@"%@",responseDictionaryForFullName];
                      FAPSFlickrUser *flickrUser = [MTLJSONAdapter modelOfClass:FAPSFlickrUser.class
                                                             fromJSONDictionary:responseDictionary
                                                                          error:&error];
                      FAPSPhotoObject *photo = [[FAPSPhotoObject alloc]init];
                      photo.fullName = fullName;
                      photo.flickrUser = flickrUser;
                      photo.publicPhoto = publicPhoto;
                      photo.profilePhotoUrl  = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg",flickrUser.iconfarm,flickrUser.iconserver,publicPhoto.photoOwner];
                      [self getUserProfilePhoto:photo];
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      NSLog(@"%@",error);
                  }];
}

- (void)getPhotoTags:(FAPSPhotoObject *)photoObject{
    [self.manager GET:[self getFlickrApiUrl:3 withParameter:photoObject.publicPhoto.photoId]
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary *responseDictionary = [[[(NSDictionary *)responseObject objectForKey:@"photo"] valueForKey:@"tags"] objectForKey:@"tag"];
                  NSError *error;
                  
                  for (NSDictionary *dictionary in responseDictionary) {
                      FAPSTagsObject *tagObject =  [MTLJSONAdapter modelOfClass:FAPSTagsObject.class
                                                             fromJSONDictionary:dictionary
                                                                          error:&error];
                      if (tagObject){
                         [photoObject.tagsArray addObject:tagObject];
                      }
                  }
                  [self savePhoto:photoObject];
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"%@",error);
              }];
}

#pragma mark - Image downloading methods

- (void)getUserProfilePhoto:(FAPSPhotoObject *)photo{
    [self.downloader downloadImageWithURL:[NSURL URLWithString:photo.profilePhotoUrl]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 }
                                completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                    if (data) {
                                        photo.profilePhotoData = data;
                                    }else{
                                        photo.profilePhotoData = UIImagePNGRepresentation([UIImage imageNamed:@"noUser.png"]);
                                    }
                                    [self getOrginalPhoto:photo];
                                }];
}

- (void)getOrginalPhoto:(FAPSPhotoObject *)photo{
    NSString *photoUrl = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg",photo.publicPhoto.photoFarm,photo.publicPhoto.photoServer,photo.publicPhoto.photoId,photo.publicPhoto.photoSecret];
    [self.downloader downloadImageWithURL:[NSURL URLWithString:photoUrl]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     // progression tracking code
                                 }
                                completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                    photo.originalPhoto = data;
                                    [self getPhotoTags:photo];
                                }];
}

- (void)savePhoto:(FAPSPhotoObject *)photo{
        FAPSPhotoObject *removePhoto;
        for (FAPSPhotoObject *tempPhoto in self.publicPhotoArray) {
            if ([tempPhoto.publicPhoto.photoId isEqualToString:photo.publicPhoto.photoId]) {
                NSLog(@"bezokko");
                removePhoto = tempPhoto;
            }
        };
        [self.publicPhotoArray removeObject:removePhoto];
        [self.publicPhotoArray addObject:photo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

@end
