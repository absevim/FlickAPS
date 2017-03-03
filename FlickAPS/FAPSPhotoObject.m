//
//  FAPSPhotoObject.m
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSPhotoObject.h"

@implementation FAPSPhotoObject

- (instancetype)init{
    self = [super init];
    if(!self) return nil;
    
    _fullName = @"";
    _profilePhotoUrl = @"";
    _publicPhoto = nil;
    _flickrUser = nil;
    _photoSizeArray = [NSMutableArray array];
    
    return self;
}

@end
