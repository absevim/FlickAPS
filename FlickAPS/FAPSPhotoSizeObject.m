//
//  FAPSPhotoSizeObject.m
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSPhotoSizeObject.h"

@implementation FAPSPhotoSizeObject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"media": @"media",
             @"label": @"label",
             @"url": @"url"
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
