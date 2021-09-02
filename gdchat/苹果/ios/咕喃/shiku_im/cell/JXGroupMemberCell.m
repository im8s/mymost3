//
//  JXGroupMemberCell.m
//  shiku_im
//
//  Created by IMAC on 2019/10/11.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXGroupMemberCell.h"

@implementation JXGroupMemberCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        _imageView.layer.cornerRadius = 5;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
        _label = [[JXLabel alloc] initWithFrame:CGRectMake(0, 55, 52, 15)];
        _label.font = g_factory.font12;
        _label.textColor = HEXCOLOR(0x333333);
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)buildNewImageview{
    if (_imageView) {
        [_imageView sd_cancelCurrentAnimationImagesLoad];
        [_imageView removeFromSuperview];
        _imageView = nil;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        _imageView.layer.cornerRadius = 5;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
    }

}

@end
