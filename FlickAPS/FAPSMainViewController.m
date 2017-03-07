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
#import "FAPSPhotoObject.h"
#import "FAPSHotTagObject.h"
#import "FAPSCollectionCell.h"

@interface FAPSMainViewController ()
@property (nonatomic, strong) NSMutableArray *publicPhotoArray;
@property (nonatomic, strong) NSMutableArray *hotTagsArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIView *fullScreenView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property NSUserDefaults *userDefaults;
@end

@implementation FAPSMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    self.searchView.hidden = YES;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard)];
    [self getHotTags];

}

- (void)getHotTags{
   NSArray *hotTagArrayFromUserDefaults = [self.userDefaults objectForKey:@"hotTagArray"];
    self.hotTagsArray = [NSMutableArray array];
    for (NSData *hotTagData in hotTagArrayFromUserDefaults) {
        FAPSHotTagObject *hotTag = (FAPSHotTagObject *)[NSKeyedUnarchiver unarchiveObjectWithData:hotTagData];
        [self.hotTagsArray addObject:hotTag];
    }
    [self getPhotoObjects];
}

- (void)getPhotoObjects{
    NSArray *photoArrayFromUserDefaults = [self.userDefaults objectForKey:@"photoArray"];
    self.publicPhotoArray = [[NSMutableArray alloc] init];
    for (NSData *photoData in photoArrayFromUserDefaults) {
        FAPSPhotoObject *photoObject = (FAPSPhotoObject *) [NSKeyedUnarchiver unarchiveObjectWithData:photoData];
        [self.publicPhotoArray addObject:photoObject];
    }
    [self.collectionView reloadData];
}

#pragma mark - CollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.publicPhotoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FAPSCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flickrCell" forIndexPath:indexPath];
    
    FAPSPhotoObject *photoObject = (FAPSPhotoObject *) self.publicPhotoArray[indexPath.row];
    cell.username.text = photoObject.fullName;
    cell.userPhoto.layer.cornerRadius = cell.userPhoto.frame.size.width / 2;
    cell.userPhoto.clipsToBounds = YES;
    cell.userPhoto.image = [UIImage imageWithData:photoObject.profilePhotoData];
    cell.originalPhoto.image = [UIImage imageWithData:photoObject.originalPhoto];
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

#pragma mark - Full Screen Methods

- (void)addFullScreenView:(FAPSPhotoObject *)photoObject{
    self.fullScreenView = [[UIView alloc] init];
    [self.fullScreenView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.85f]];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownToCloseFullScreen:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.fullScreenView addGestureRecognizer:swipeGesture];
    
    [self.view addSubview:self.fullScreenView];
    [self fullScreenViewForConstraint:self.fullScreenView withView:self.view withState:0];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageWithData:photoObject.originalPhoto];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.fullScreenView addSubview:imageView];
    [self fullScreenViewForConstraint:imageView withView:self.fullScreenView withState:1];
}

- (void)swipeDownToCloseFullScreen:(UISwipeGestureRecognizer *)recognizer {
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

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchView.hidden = NO;
    return YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{

  
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchView.hidden = YES;
}
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    return YES;
    
}

#pragma mark - Tableview Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.hotTagsArray.count;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"hotTagCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dataCell"];
    }
    FAPSHotTagObject *hotTagObject = (FAPSHotTagObject *)self.hotTagsArray[indexPath.row];
    cell.textLabel.text = hotTagObject.content;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
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
    [self.view removeGestureRecognizer:self.tap];
    [self.searchBar resignFirstResponder];
}

@end
