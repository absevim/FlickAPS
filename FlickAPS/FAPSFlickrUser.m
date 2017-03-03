//
//  FAPSFlickrUser.m
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSFlickrUser.h"

@implementation FAPSFlickrUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"iconserver": @"iconserver",
             @"iconfarm": @"iconfarm"
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
