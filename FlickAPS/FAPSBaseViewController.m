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

- (NSString *)getFlickrApiUrl:(NSInteger)tag withText:(NSString *)text withTag:(NSString *)photoTag withPageNumber:(NSString *)pageNumber{
    NSString *apiUrl = @"";
    switch (tag) {
        case 0:
            apiUrl = [NSString stringWithFormat:@"%@flickr.photos.getRecent%@&per_page=7&page=%@%@",FLICKR_LINK,FLICKR_API_KEY,pageNumber,FLICKR_FORMAT];
            break;
        case 1:
            text = [text stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
            apiUrl = [NSString stringWithFormat:@"%@flickr.people.getInfo%@&user_id=%@%@",FLICKR_LINK,FLICKR_API_KEY,text,FLICKR_FORMAT];
            break;
        case 2:
            apiUrl = [NSString stringWithFormat:@"%@flickr.tags.getHotList%@%@",FLICKR_LINK,FLICKR_API_KEY,FLICKR_FORMAT];
            break;
        case 3:
            apiUrl = [NSString stringWithFormat:@"%@flickr.tags.getListPhoto%@&photo_id=%@%@",FLICKR_LINK,FLICKR_API_KEY,text,FLICKR_FORMAT];
            break;
        case 4:
            if(![text isEqualToString:@""]){
                apiUrl = [NSString stringWithFormat:@"%@flickr.photos.search%@&text=%@&per_page=7&page=%@%@",FLICKR_LINK,FLICKR_API_KEY,text,pageNumber,FLICKR_FORMAT];
            }else{
                apiUrl = [NSString stringWithFormat:@"%@flickr.photos.search%@&tags=%@&per_page=7&page=%@%@",FLICKR_LINK,FLICKR_API_KEY,photoTag,pageNumber,FLICKR_FORMAT];
            }
            break;
        default:
            break;
    }
    return apiUrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alertview Method

- (void)showAlertView:(NSString *)message withCancelButton:(NSString *)cancelButton withOtherButton:(NSString *)otherButton withTag:(NSInteger)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FlickAps"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelButton
                                          otherButtonTitles:otherButton,nil];
    alert.tag = tag;
    [alert show];
    
}





@end
