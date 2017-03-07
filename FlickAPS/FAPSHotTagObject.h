//
//  FAPSHotTagObject.h
//  FlickAPS
//
//  Created by Abdullah  on 07/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FAPSHotTagObject : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *score;
@property (nonatomic, copy, readonly) NSString *content;

@end
