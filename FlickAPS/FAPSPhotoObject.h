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

@interface FAPSPhotoObject : NSObject
@property (nonatomic,strong) NSDictionary *dict;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *profilePhotoUrl;
@property (nonatomic, strong) FAPSPublicPhoto *publicPhoto;
@property (nonatomic, strong) FAPSFlickrUser *flickrUser;
@property (nonatomic, strong) NSMutableArray *photoSizeArray;

@end
