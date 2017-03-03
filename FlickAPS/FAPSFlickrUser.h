//
//  FAPSFlickrUser.h
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FAPSFlickrUser : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *iconserver;
@property (nonatomic, copy, readonly) NSNumber *iconfarm;

@end
