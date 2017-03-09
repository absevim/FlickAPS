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
#import "FAPSTagsObject.h"
#import "FAPSHotTagObject.h"

static Reachability *networkNotifier;
static NetworkStatus networkStatus;

@interface FAPSSplashViewController ()
@property (nonatomic,strong) NSMutableArray *publicPhotoArray;
@property (nonatomic,strong) NSMutableArray *photoSizeArray;
@property SDWebImageDownloader *downloader;
@property AFHTTPSessionManager *manager;
@end

@implementation FAPSSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self checkReachability]) {
        self.manager = [AFHTTPSessionManager manager];
        self.downloader = [SDWebImageDownloader sharedDownloader];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"hotTagArray"];
        [userDefaults synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getHotTags];
        });
    }else{
        NSLog(@"Alert");
    }
}

#pragma mark - FlickR request methods

- (void)getHotTags{
    [self.manager GET:[self getFlickrApiUrl:2 withParameter:@""]
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary *responseDictionary = [[(NSDictionary *)responseObject valueForKey:@"hottags"] valueForKey:@"tag"];
                  NSError *error;
                  
                  for (NSDictionary *dictionary in responseDictionary) {
                    FAPSHotTagObject *hotTag = [MTLJSONAdapter modelOfClass:FAPSHotTagObject.class
                                                         fromJSONDictionary:dictionary
                                                                      error:&error];
                      [self saveHotTags:hotTag];
                  }
                  [self hideSplash];
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"%@",error);
              }];
}

- (void)saveHotTags:(FAPSHotTagObject *)hotTag{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *hotTagArray = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"hotTagArray"]];
    
    NSData *removedData;
    for (NSData *data in hotTagArray) {
        FAPSHotTagObject *savedHotTagObject = (FAPSHotTagObject *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([savedHotTagObject.content isEqualToString:hotTag.content]) {
            removedData = data;
        }
    };
    [hotTagArray removeObject:removedData];
    
    NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:hotTag];
    [hotTagArray addObject:savedData];
    [userDefaults setObject:hotTagArray forKey:@"hotTagArray"];
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
