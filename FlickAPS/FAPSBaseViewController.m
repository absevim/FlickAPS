//
//  ViewController.m
//  FlickAPS
//
//  Created by Abdullah  on 26/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSBaseViewController.h"
#import <AFNetworking.h>

@interface FAPSBaseViewController ()

@end

@implementation FAPSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=9c22b20cee67d026184473f2e1db396e&format=json&nojsoncallback=1&auth_token=72157677324780094-d1695453ff72d6e6&api_sig=35687cb02a874349049bb55012efcbb0" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSError *error;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
