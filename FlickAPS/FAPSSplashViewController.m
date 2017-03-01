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


@interface FAPSSplashViewController ()
@property (nonatomic,strong) NSMutableArray *publicPhotoArray;
@property (nonatomic,strong) NSMutableArray *publicPhotoWithUserArray;

@end

@implementation FAPSSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.publicPhotoArray = [[NSMutableArray alloc]init];
    self.publicPhotoWithUserArray = [[NSMutableArray alloc]init];
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
    [manager GET:[self getFlickrApiUrl:0 withUserId:@""] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = [(NSDictionary *)responseObject valueForKey:@"photos"];
        NSDictionary *publicPhotoDictionary = [responseDictionary objectForKey:@"photo"];
        NSError *error;
        
        for (NSDictionary *dictionary in publicPhotoDictionary) {
            FAPSPublicPhoto *publicPhoto =  [MTLJSONAdapter modelOfClass:FAPSPublicPhoto.class fromJSONDictionary:dictionary error:&error];

            [self.publicPhotoArray addObject:publicPhoto];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getPublicPhotoFlickrUser];
            
        });
        [self hideSplash];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)getPublicPhotoFlickrUser{

    for (FAPSPublicPhoto *publicPhoto in self.publicPhotoArray) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:[self getFlickrApiUrl:1 withUserId:publicPhoto.photoOwner] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDictionary = [[(NSDictionary *)responseObject valueForKey:@"person"] objectForKey:@"username"];
            NSString *fullName = [responseDictionary valueForKey:@"_content"];
            
            FAPSPhotoObject *photo = [[FAPSPhotoObject alloc]init];
            photo.fullName = fullName;
            photo.publicPhoto = publicPhoto;
            [self.publicPhotoWithUserArray addObject:photo];
            
            if (self.publicPhotoWithUserArray.count > 0) {
                NSLog(@"Bezokko");
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    }


    
}

- (void)hideSplash{
    [self performSegueWithIdentifier:@"SplashToMainViewSegue" sender:self];
    
}

@end
