//
//  JXCollectionView.m
//  shiku_im
//
//  Created by MacZ on 2016/10/27.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXCollectionView.h"

@interface JXCollectionView (){
    UIImageView *_emptyImg;
    UILabel *_tipLabel;
    UIButton *_reloadBtn;
}

@end

@implementation JXCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.alwaysBounceVertical = YES;
    }
    return self;
}

- (void)showEmptyImage:(EmptyType)emptyType{
    if (!_emptyImg) {
        _emptyImg = [[UIImageView alloc]initWithFrame:CGRectMake((JX_SCREEN_WIDTH-56)/2, self.frame.size.height/5, 56, 108)];
        _emptyImg.image = [UIImage imageNamed:@"no_data_for_the_time_being"];
        [self addSubview:_emptyImg];
//        [_emptyImg release];
    }
    
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_emptyImg.frame.origin.x, _emptyImg.frame.origin.y + _emptyImg.frame.size.height + 10, JX_SCREEN_WIDTH, 30)];
        CGPoint centerPoint = CGPointMake(_emptyImg.center.x, _emptyImg.frame.origin.y + _emptyImg.frame.size.height + 10);
        _tipLabel.center = centerPoint;
        _tipLabel.font = g_factory.font16;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
//        [_tipLabel release];
    }
    switch (emptyType) {
        case EmptyTypeNoData:
            _tipLabel.text = Localized(@"JX_NoData");
            break;
        case EmptyTypeNetWorkError:
            _tipLabel.text = Localized(@"JX_NetWorkError");
        default:
            break;
    }
    
    if (!_reloadBtn) {
        _reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _tipLabel.frame.origin.y + _tipLabel.frame.size.height + 20, 120, 40)];
        [_reloadBtn setTitle:Localized(@"JX_LoadAgain") forState:UIControlStateNormal];
        [_reloadBtn setBackgroundColor:HEXCOLOR(0x48d1cc)];
        _reloadBtn.layer.masksToBounds = YES;
        _reloadBtn.layer.cornerRadius = 5;
        _reloadBtn.center = CGPointMake(JX_SCREEN_WIDTH/2, _reloadBtn.center.y);
        [_reloadBtn addTarget:self.delegate
                    action:@selector(getServerData) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reloadBtn];
//        [_reloadBtn release];
    }
}

- (void)hideEmptyImage{
    if (_emptyImg) {
        [_emptyImg removeFromSuperview];
        _emptyImg = nil;
    }
    if (_tipLabel) {
        [_tipLabel removeFromSuperview];
        _tipLabel = nil;
    }
    if (_reloadBtn) {
        [_reloadBtn removeFromSuperview];
        _reloadBtn = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
