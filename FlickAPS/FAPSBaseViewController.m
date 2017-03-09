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
NSString *FLICKR_API_KEY = @"&api_key=e47df99961f0f684875506c1cd1e3ca1";
NSString *FLICKR_FORMAT = @"&format=json&nojsoncallback=1";
NSString *FLICKR_AUTH_TOKEN = @"&auth_token=72157677324780094-d1695453ff72d6e6";

@interface FAPSBaseViewController ()

@end

@implementation FAPSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  
    
}

- (NSString *)getFlickrApiUrl:(NSInteger)tag withParameter:(NSString *)parameter{
    NSString *apiUrl = @"";
    switch (tag) {
        case 0:
            /*https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=216973c8a63e3101968818cc48ddfa37&per_page=10&format=json&nojsoncallback=1*/
            apiUrl = [NSString stringWithFormat:@"%@flickr.photos.getRecent%@&per_page=7&page=%@%@",FLICKR_LINK,FLICKR_API_KEY,parameter,FLICKR_FORMAT];
            break;
        case 1:
            parameter = [parameter stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
            apiUrl = [NSString stringWithFormat:@"%@flickr.people.getInfo%@&user_id=%@%@",FLICKR_LINK,FLICKR_API_KEY,parameter,FLICKR_FORMAT];
            break;
        case 2:
            apiUrl = [NSString stringWithFormat:@"%@flickr.tags.getHotList%@%@",FLICKR_LINK,FLICKR_API_KEY,FLICKR_FORMAT];
            break;
        case 3:
            apiUrl = [NSString stringWithFormat:@"%@flickr.tags.getListPhoto%@&photo_id=%@%@",FLICKR_LINK,FLICKR_API_KEY,parameter,FLICKR_FORMAT];
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
