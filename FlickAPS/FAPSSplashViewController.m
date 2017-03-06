//
//  FAPSSplashViewController.m
//  FlickAPS
//
//  Created by Abdullah  on 28/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSSplashViewController.h"
#import <AFNetworking.h>
#import <Mantle.h>
#import <Reachability.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FAPSPublicPhoto.h"
#import "FAPSPhotoObject.h"
#import "FAPSPhotoSizeObject.h"

static Reachability *networkNotifier;
static NetworkStatus networkStatus;

@interface FAPSSplashViewController ()
@property (nonatomic,strong) NSMutableArray *publicPhotoArray;
@property (nonatomic,strong) NSMutableArray *photoSizeArray;
@property SDWebImageDownloader *downloader;

@end

@implementation FAPSSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.publicPhotoArray = [[NSMutableArray alloc]init];
    self.photoSizeArray = [[NSMutableArray alloc]init];
    self.downloader = [SDWebImageDownloader sharedDownloader];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([self checkReachability]) {
        [userDefaults setObject:self.photoSizeArray forKey:@"photoArray"];
        [userDefaults synchronize];
        [self getRecentPublicPhotos];
    }else{
        [self hideSplash];
    }
}

#pragma mark - FlickR request methods

- (void)getRecentPublicPhotos{
   
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[self getFlickrApiUrl:0 withParameter:@""]
      parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"photos"];
             NSDictionary *publicPhotoDictionary = [responseDictionary objectForKey:@"photo"];
             NSError *error;
             
             for (NSDictionary *dictionary in publicPhotoDictionary) {
                 FAPSPublicPhoto *publicPhoto =  [MTLJSONAdapter modelOfClass:FAPSPublicPhoto.class fromJSONDictionary:dictionary error:&error];
                 
                 [self.publicPhotoArray addObject:publicPhoto];
                 [self getPublicPhotoFlickrUser:publicPhoto];
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];
}

- (void)getPublicPhotoFlickrUser:(FAPSPublicPhoto *)publicPhoto{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[self getFlickrApiUrl:1 withParameter:publicPhoto.photoOwner]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"person"];
             NSError *error;
             NSDictionary *responseDictionaryForFullName = [[responseDictionary valueForKey:@"username"] objectForKey:@"_content"];
             NSString *fullName = [NSString stringWithFormat:@"%@",responseDictionaryForFullName];
             FAPSFlickrUser *flickrUser = [MTLJSONAdapter modelOfClass:FAPSFlickrUser.class fromJSONDictionary:responseDictionary error:&error];
             
             FAPSPhotoObject *photo = [[FAPSPhotoObject alloc]init];
             photo.fullName = fullName;
             photo.flickrUser = flickrUser;
             photo.publicPhoto = publicPhoto;
             photo.profilePhotoUrl  = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg",flickrUser.iconfarm,flickrUser.iconserver,publicPhoto.photoOwner];
             
            // [self getAllPhotoSizes:photo];
             [self getUserProfilePhoto:photo];
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];
}

- (void)getAllPhotoSizes:(FAPSPhotoObject *)photoObject{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[self getFlickrApiUrl:2 withParameter:photoObject.publicPhoto.photoId]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"sizes"];
             NSDictionary *responsePhotoSizeDictionary = [responseDictionary valueForKey:@"size"];
             NSError *error;
             
             for (NSDictionary *dictionary in responsePhotoSizeDictionary) {
                 FAPSPhotoSizeObject *photoSizeObject =  [MTLJSONAdapter modelOfClass:FAPSPhotoSizeObject.class fromJSONDictionary:dictionary error:&error];
                 [photoObject.photoSizeArray addObject:photoSizeObject];
             }
             [self.photoSizeArray addObject:photoObject];
             
             if (self.publicPhotoArray.count == self.photoSizeArray.count) {
                 for (FAPSPhotoObject *photoObject in self.photoSizeArray) {
                     [self savePhotoSizeObject:photoObject];
                 }
                 [self hideSplash];
             }
             
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
                                // progression tracking code
                            }
                           completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                               if (data) {
                                   photo.profilePhotoData = data;
                               }else{
                                   photo.profilePhotoData = UIImagePNGRepresentation([UIImage imageNamed:@"noUser.png"]);
                               }
                               
                               [self getOrginalPhoto:photo];
                              // [self getAllPhotoSizes:photo];
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
                               [self getAllPhotoSizes:photo];
                           }];
}

#pragma mark - NSUserDefaults method

- (void)savePhotoSizeObject:(FAPSPhotoObject *)photoObject{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photoArray = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"photoArray"]];
    
    NSData *removedData;
    for (NSData *data in photoArray) {
        FAPSPhotoObject *savedPhotoObject = (FAPSPhotoObject *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([savedPhotoObject.publicPhoto.photoId isEqualToString:photoObject.publicPhoto.photoId]) {
            removedData = data;
        }
    };
    [photoArray removeObject:removedData];
    
    NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:photoObject];
    [photoArray addObject:savedData];
    [userDefaults setObject:photoArray forKey:@"photoArray"];
    [userDefaults synchronize];
}

#pragma mark -

- (void)hideSplash{
    [self performSegueWithIdentifier:@"SplashToMainViewSegue" sender:self];
}

#pragma mark - Reachability Method

- (BOOL)checkReachability{
    networkNotifier = [Reachability reachabilityForInternetConnection];
    [networkNotifier startNotifier];
    
    NetworkStatus status = [networkNotifier currentReachabilityStatus];
    networkStatus = status;
    BOOL isConnected;
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN){
        isConnected = YES;
    }else {
        isConnected = NO;
    }
    return isConnected;
}

@end
