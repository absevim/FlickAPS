//
//  FAPSCollectionCell.h
//  FlickAPS
//
//  Created by Abdullah  on 07/03/2017.
//  Copyright © 2017 Abdullah Sevim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAPSCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *originalPhoto;
@end
