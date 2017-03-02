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
#import "FAPSPublicPhoto.h"
#import "FAPSPhotoObject.h"
#import "FAPSPhotoSizeObject.h"


@interface FAPSSplashViewController ()
@property (nonatomic,strong) NSMutableArray *publicPhotoArray;
@property (nonatomic,strong) NSMutableArray *publicPhotoWithUserArray;
@property (nonatomic,strong) NSMutableArray *photoSizeArray;

@end

@implementation FAPSSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.publicPhotoArray = [[NSMutableArray alloc]init];
    self.photoSizeArray = [[NSMutableArray alloc]init];
    [self getRecentPublicPhotos];

   
   // [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2.];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getRecentPublicPhotos{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[self getFlickrApiUrl:0 withParameter:@""] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"photos"];
        NSDictionary *publicPhotoDictionary = [responseDictionary objectForKey:@"photo"];
        NSError *error;
        
        for (NSDictionary *dictionary in publicPhotoDictionary) {
           FAPSPublicPhoto *publicPhoto =  [MTLJSONAdapter modelOfClass:FAPSPublicPhoto.class fromJSONDictionary:dictionary error:&error];

            [self.publicPhotoArray addObject:publicPhoto];
            [self getPublicPhotoFlickrUser:publicPhoto];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)getPublicPhotoFlickrUser:(FAPSPublicPhoto *)publicPhoto{
    
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[self getFlickrApiUrl:1 withParameter:publicPhoto.photoOwner] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDictionary = [[(NSDictionary *)responseObject valueForKey:@"person"] objectForKey:@"username"];
            NSString *fullName = [responseDictionary valueForKey:@"_content"];
            
            FAPSPhotoObject *photo = [[FAPSPhotoObject alloc]init];
            photo.fullName = fullName;
            photo.publicPhoto = publicPhoto;
            [self getAllPhotoSizes:photo];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];

}

- (void)getAllPhotoSizes:(FAPSPhotoObject *)photoObject{
    
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[self getFlickrApiUrl:2 withParameter:photoObject.publicPhoto.photoId] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"sizes"];
            NSDictionary *responsePhotoSizeDictionary = [responseDictionary valueForKey:@"size"];
            NSError *error;
            
            for (NSDictionary *dictionary in responsePhotoSizeDictionary) {
                FAPSPhotoSizeObject *photoSizeObject =  [MTLJSONAdapter modelOfClass:FAPSPhotoSizeObject.class fromJSONDictionary:dictionary error:&error];
                [photoObject.photoSizeArray addObject:photoSizeObject];
               
            }
            [self.photoSizeArray addObject:photoObject];
            
            if (self.publicPhotoArray.count == self.photoSizeArray.count) {
                [self hideSplash];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

- (void)hideSplash{
    [self performSegueWithIdentifier:@"SplashToMainViewSegue" sender:self];
    
}

@end
