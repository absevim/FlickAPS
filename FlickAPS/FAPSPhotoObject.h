//
//  FAPSPhotoObject.h
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAPSPublicPhoto.h"
#import "FAPSFlickrUser.h"

@interface FAPSPhotoObject : NSObject<NSCoding>
@property (nonatomic,strong) NSDictionary *dict;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *profilePhotoUrl;
@property (nonatomic, strong) FAPSPublicPhoto *publicPhoto;
@property (nonatomic, strong) FAPSFlickrUser *flickrUser;
@property (nonatomic, strong) NSMutableArray *tagsArray;
@property (nonatomic, strong) NSData *profilePhotoData;
@property (nonatomic, strong) NSData *originalPhoto;
@property (nonatomic, strong) NSData *largePhoto;

@end
