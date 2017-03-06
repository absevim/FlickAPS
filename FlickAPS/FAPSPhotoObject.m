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
    _profilePhotoData = [NSData data];
    _originalPhoto = [NSData data];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_fullName forKey:@"fullNameKey"];
    [aCoder encodeObject:_profilePhotoUrl forKey:@"profilePhotoKey"];
    [aCoder encodeObject:_publicPhoto forKey:@"publicPhotoKey"];
    [aCoder encodeObject:_flickrUser forKey:@"flickrUserKey"];
    [aCoder encodeObject:_photoSizeArray forKey:@"photoSizeArrayKey"];
    [aCoder encodeObject:_profilePhotoData forKey:@"profilePhotoData"];
    [aCoder encodeObject:_originalPhoto forKey:@"originalPhotoData"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(!self) return nil;
    
    _fullName = [aDecoder decodeObjectForKey:@"fullNameKey"];
    _profilePhotoUrl = [aDecoder decodeObjectForKey:@"profilePhotoKey"];
    _publicPhoto = [aDecoder decodeObjectForKey:@"publicPhotoKey"];
    _flickrUser = [aDecoder decodeObjectForKey:@"flickrUserKey"];
    _photoSizeArray = [aDecoder decodeObjectForKey:@"photoSizeArrayKey"];
    _profilePhotoData = [aDecoder decodeObjectForKey:@"profilePhotoData"];
    _originalPhoto = [aDecoder decodeObjectForKey:@"originalPhotoData"];
    
    return self;
}

@end
