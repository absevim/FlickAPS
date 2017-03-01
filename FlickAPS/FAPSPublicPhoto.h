//
//  FAPSPublicPhoto.h
//  FlickAPS
//
//  Created by Abdullah  on 28/02/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FAPSPublicPhoto : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *photoId;
@property (nonatomic, copy, readonly) NSString *photoOwner;
@property (nonatomic, copy, readonly) NSString *photoSecret;
@property (nonatomic, copy, readonly) NSNumber *photoFarm;
@property (nonatomic, copy, readonly) NSString *photoServer;
@property (nonatomic, copy, readonly) NSString *photoTitle;


@end
