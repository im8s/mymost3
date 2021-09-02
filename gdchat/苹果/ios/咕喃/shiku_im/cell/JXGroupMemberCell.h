//
//  JXGroupMemberCell.h
//  shiku_im
//
//  Created by IMAC on 2019/10/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXGroupMemberCell : UICollectionViewCell
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)JXLabel *label;
- (void)buildNewImageview;

@end

NS_ASSUME_NONNULL_END
