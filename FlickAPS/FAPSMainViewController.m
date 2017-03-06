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
#import "FAPSCollectionCell.h"

@interface FAPSMainViewController ()
@property (nonatomic, strong) NSMutableArray *publicPhotoArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSUserDefaults *userDefaults;
@end

@implementation FAPSMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 350);
    // A total of 4 views displayed at a time,  we divide width / 4,
    // and cell will automatically adjust its size.
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
