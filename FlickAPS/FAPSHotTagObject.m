//
//  FAPSHotTagObject.m
//  FlickAPS
//
//  Created by Abdullah  on 07/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import "FAPSHotTagObject.h"

@implementation FAPSHotTagObject

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"score": @"score",
             @"content": @"_content"
             };
}

@end
