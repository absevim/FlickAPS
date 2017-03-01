//
//  FAPSPhotoObject.m
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSPhotoObject.h"

@implementation FAPSPhotoObject

static FAPSPhotoObject *sharedPhotoObject = nil;

+ (FAPSPhotoObject *)sharedPhotoObject{
    if (sharedPhotoObject == nil) sharedPhotoObject = [[super alloc] init];
    return sharedPhotoObject;
}

+ (FAPSPhotoObject *)savedPhotoObject:(FAPSPhotoObject *)photoObject{
    sharedPhotoObject = photoObject;
    return sharedPhotoObject;
}

- (instancetype)init{
    self = [super init];
    if(!self) return nil;
    
    _fullName = @"";
    _profilePhotoUrl = @"";
    _publicPhoto = nil;
    
    return self;
}

@end
