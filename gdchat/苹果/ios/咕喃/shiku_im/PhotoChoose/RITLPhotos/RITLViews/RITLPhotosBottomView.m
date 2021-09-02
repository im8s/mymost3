//
//  RITLPhotosBottomView.m
//  RITLPhotoDemo
//
//  Created by YueWen on 2018/3/9.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "RITLPhotosBottomView.h"
#import "RITLPhotosConfiguration.h"
#import "NSBundle+RITLPhotos.h"
#import "RITLKit.h"
#import "Masonry.h"

@interface RITLPhotosBottomView ()
@property (nonatomic, strong) NSString *language;

@end

@implementation RITLPhotosBottomView

 -(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _language = [[NSString alloc] initWithFormat:@"%@",g_constant.sysLanguage];
        [self buildViews];
    }
    return self;
}


- (void)buildViews
{
    self.contentView = ({
        
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.clearColor;

        view;
    });
    
    self.previewButton = ({
        
        UIButton *view = [UIButton new];
        view.adjustsImageWhenHighlighted = false;
        view.backgroundColor = [UIColor clearColor];
        view.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [view setTitle:NSLocalizedString(Localized(@"JX_Preview"), @"") forState:UIControlStateNormal];
        [view setTitle:NSLocalizedString(Localized(@"JX_Preview"), @"") forState:UIControlStateDisabled];
        
        [view setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [view setTitleColor:RITLColorFromIntRBG(105, 109, 113) forState:UIControlStateDisabled];
        
        view;
    });
    if (![RITLPhotosConfiguration defaultConfiguration].isRichScan) {
        self.fullImageButton = ({
            
            UIButton *view = [UIButton new];
            if ([_language isEqualToString:@"en"]) {
                view.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 40+40+10+20);
                if (UIDevice.currentDevice.systemVersion.floatValue < 13.0) {
                    view.titleEdgeInsets = UIEdgeInsetsMake(0, -60-10, 0, 0);
                }
            } else {
                view.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 40);
                if (UIDevice.currentDevice.systemVersion.floatValue < 13.0) {
                    view.titleEdgeInsets = UIEdgeInsetsMake(0, -60, 0, 0);
                }
            }
            
            [view setImage:/*@"RITLPhotos.bundle/ritl_bottomUnselected".ritl_image*/NSBundle.ritl_bottomUnselected forState:UIControlStateNormal];
            [view setImage:/*@"RITLPhotos.bundle/ritl_bottomSelected".ritl_image*/NSBundle.ritl_bottomSelected forState:UIControlStateSelected];
            
            view.titleLabel.font = [UIFont systemFontOfSize:14];
            [view setTitle:NSLocalizedString(Localized(@"JX_OriginalImage"), @"") forState:UIControlStateNormal];
            [view setTitle:NSLocalizedString(Localized(@"JX_OriginalImage"), @"") forState:UIControlStateSelected];
            
            [view setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            
            view;
        });
    }
    
    self.sendButton = ({
        
        UIButton *view = [UIButton new];
        view.adjustsImageWhenHighlighted = false;
        
        view.custom_acceptEventInterval = 2.0f;
        view.titleLabel.font = RITLUtilityFont(RITLFontPingFangSC_Regular, 13);
        
        if (![RITLPhotosConfiguration defaultConfiguration].isRichScan) {
            [view setTitle:NSLocalizedString(Localized(@"JX_Send"), @"") forState:UIControlStateNormal];
            [view setTitle:NSLocalizedString(Localized(@"JX_Send"), @"") forState:UIControlStateDisabled];
        }else {
            [view setTitle:NSLocalizedString(Localized(@"JX_Finish"), @"") forState:UIControlStateNormal];
            [view setTitle:NSLocalizedString(Localized(@"JX_Finish"), @"") forState:UIControlStateDisabled];
        }
        
        [view setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [view setTitleColor:RITLColorFromIntRBG(92, 134, 90) forState:UIControlStateDisabled];
        
        [view setBackgroundImage:RITLColorFromIntRBG(9, 187, 7).ritl_image forState:UIControlStateNormal];
        [view setBackgroundImage:RITLColorFromIntRBG(23, 83, 23).ritl_image forState:UIControlStateDisabled];
        
        view.layer.cornerRadius = 5;
        view.clipsToBounds = true;
        
        view;
    });
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.previewButton];
    [self.contentView addSubview:self.fullImageButton];
    [self.contentView addSubview:self.sendButton];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.left.right.offset(0);
        make.height.mas_equalTo(RITL_NormalTabBarHeight - 5);
        
    }];
    
    [self.previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.offset(0);
        make.left.offset(10);
        if ([_language isEqualToString:@"en"]) {
            make.width.mas_equalTo(40+20);
        } else {
            make.width.mas_equalTo(40);
        }
    }];
    
    [self.fullImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.offset(0);
        make.height.mas_equalTo(30);
        if ([_language isEqualToString:@"en"]) {
            make.width.mas_equalTo(60+40+10+20);
        } else {
            make.width.mas_equalTo(60);
        }
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.offset(0);
        make.right.inset(10);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(30);
    }];
}

- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    if (isEdit) {
        [self.previewButton setTitle:Localized(@"JX_Edit") forState:UIControlStateNormal];
        [self.previewButton setTitle:Localized(@"JX_Edit") forState:UIControlStateDisabled];
    }else {
        [self.previewButton setTitle:Localized(@"JX_Preview") forState:UIControlStateNormal];
        [self.previewButton setTitle:Localized(@"JX_Preview") forState:UIControlStateDisabled];
    }
}

@end
