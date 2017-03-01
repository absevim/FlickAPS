//
//  FAPSBaseViewController.m
//  FlickAPS
//
//  Created by Abdullah  on 26/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSBaseViewController.h"
#import <AFNetworking.h>
#import <Mantle.h>
#import "FAPSPublicPhoto.h"


NSString *FLICKR_LINK = @"https://api.flickr.com/services/rest/?method=";
NSString *FLICKR_API_KEY = @"&api_key=e1ff347654cd916bf712d231bf6d98f2";
NSString *FLICKR_FORMAT = @"&format=json&nojsoncallback=1";
NSString *FLICKR_AUTH_TOKEN = @"&auth_token=72157677324780094-d1695453ff72d6e6";

@interface FAPSBaseViewController ()

@end

@implementation FAPSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  
    
}

- (NSString *)getFlickrApiUrl:(NSInteger)tag withUserId:(NSString *)userId{
    NSString *apiUrl = @"";
    switch (tag) {
        case 0:
            apiUrl = [NSString stringWithFormat:@"%@flickr.photos.getRecent%@%@",FLICKR_LINK,FLICKR_API_KEY,FLICKR_FORMAT];
            break;
        case 1:
            userId = [userId stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
            apiUrl = [NSString stringWithFormat:@"%@flickr.people.getInfo%@&user_id=%@%@",FLICKR_LINK,FLICKR_API_KEY,userId,FLICKR_FORMAT];
            
        default:
            break;
    }
    return apiUrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
