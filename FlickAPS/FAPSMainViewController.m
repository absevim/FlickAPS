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
@property (strong, nonatomic) UIView *fullScreenView;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FAPSPhotoObject *photoObject = (FAPSPhotoObject *) self.publicPhotoArray[indexPath.row];
    [self addFullScreenView:photoObject];
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

@end
