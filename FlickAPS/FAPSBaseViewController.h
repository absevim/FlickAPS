//
//  FAPSBaseViewController.h
//  FlickAPS
//
//  Created by Abdullah  on 26/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FAPSBaseViewController : UIViewController

- (NSString *)getFlickrApiUrl:(NSInteger)tag withParameter:(NSString *)parameter;


@end

