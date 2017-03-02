//
//  FAPSPhotoSizeObject.h
//  FlickAPS
//
//  Created by Abdullah  on 02/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FAPSPhotoSizeObject : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *media;
@property (nonatomic, copy, readonly) NSString *label;
@property (nonatomic, copy, readonly) NSString *url;

@end
