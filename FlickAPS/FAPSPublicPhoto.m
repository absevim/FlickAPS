//
//  FAPSPublicPhoto.m
//  FlickAPS
//
//  Created by Abdullah  on 28/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSPublicPhoto.h"


@implementation FAPSPublicPhoto

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"photoId": @"id",
             @"photoOwner": @"owner",
             @"photoSecret": @"secret",
             @"photoServer": @"server",
             @"photoTitle": @"title",
             @"photoFarm" : @"farm"
             };
    
}

+ (NSValueTransformer *)JSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:[NSString class]]) {
            return @([value longValue]);
        }
        return value;
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
    
}


@end
