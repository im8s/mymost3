//
//  JXSystemImage2Cell.m
//  shiku_im
//
//  Created by p on 2017/7/20.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXSystemImage2Cell.h"
#import "ImageResize.h"

@interface JXSystemImage2Cell ()

@property (nonatomic, strong) UIImageView *imageBackground;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *subViews;
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation JXSystemImage2Cell

-(void)creatUI{
    _imageBackground =[[UIImageView alloc]initWithFrame:CGRectZero];
    _imageBackground.userInteractionEnabled = YES;
    [_imageBackground setBackgroundColor:[UIColor clearColor]];
    _imageBackground.layer.cornerRadius = 6;
    _imageBackground.layer.masksToBounds = YES;
    [self.bubbleBg addSubview:_imageBackground];
    
    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(18, 15, kSystemImageCellWidth - 30, 150)];
    _imageV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapAction:)];
    [_imageV addGestureRecognizer:tap];
    [_imageBackground addSubview:_imageV];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageV.frame.size.height - 30, _imageV.frame.size.width, 30)];
    _title.font = SYSFONT(15.0);
    _title.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
    _title.textColor = [UIColor whiteColor];
    _title.numberOfLines = 0;
    _title.text = Localized(@"JXSystemImage_multiple");
    [_imageV addSubview:_title];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(_imageV.frame) + 15, kSystemImageCellWidth - 30, LINE_WH)];
    _lineView.backgroundColor = THE_LINE_COLOR;
    [_imageBackground addSubview:_lineView];
    
    _subViews = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lineView.frame), kSystemImageCellWidth, 0)];
    [_imageBackground addSubview:_subViews];
}

-(void)setCellData{
    [super setCellData];
    
    SBJsonParser * parser = [[SBJsonParser alloc] init] ;
    NSArray *content = [parser objectWithString:self.msg.content];

    if (content.count <= 0) {
        return;
    }
    
    NSDictionary *dict = [content objectAtIndex:0];

//    [_imageV sd_setImageWithURL:[dict objectForKey:@"img"] placeholderImage:[UIImage imageNamed:@"Default_Gray" ]];
    
    [_imageV sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:@"Default_Gray"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        if (error) {
//            NSLog(@"error = %@",error);
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                NSData *data = [NSData dataWithContentsOfURL:imageURL];
//                UIImage *image = [UIImage imageWithData:data];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    _imageV.image = image;
//                });
//            });
//        }
        _imageV.image = [ImageResize image:image fillSize:_imageV.frame.size];
    }];

    _title.text = [dict objectForKey:@"title"];
    CGSize size = [_title.text boundingRectWithSize:CGSizeMake(_title.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSFONT(15.0)} context:nil].size;
    _title.frame = CGRectMake(_title.frame.origin.x, _imageV.frame.size.height - size.height - 10, _title.frame.size.width, size.height + 10);
    
    [self creatSubViews:content];
    
    if(self.msg.isMySend)
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMinX(self.headImage.frame)- kSystemImageCellWidth - CHAT_WIDTH_ICON, INSETS, kSystemImageCellWidth, 180 + _subViews.frame.size.height);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bubble_whrite_right_icon"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
        
    }
    else
    {
        self.bubbleBg.frame=CGRectMake(CGRectGetMaxX(self.headImage.frame) + CHAT_WIDTH_ICON, INSETS2(self.msg.isGroup), kSystemImageCellWidth, 180 + _subViews.frame.size.height);
        _imageBackground.frame = self.bubbleBg.bounds;
        
        _imageBackground.image = [[UIImage imageNamed:@"chat_bg_white"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
    }
    
    if (self.msg.isShowTime) {
        CGRect frame = self.bubbleBg.frame;
        frame.origin.y = self.bubbleBg.frame.origin.y + 40;
        self.bubbleBg.frame = frame;
    }
    [self setMaskLayer:_imageBackground];
}

- (void) creatSubViews:(NSArray *)array{
    
    [_subViews.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _subViews.frame = CGRectMake(_subViews.frame.origin.x, _subViews.frame.origin.y, _subViews.frame.size.width, 0);
    for (NSInteger i = 1; i < array.count; i ++) {
        NSDictionary *dict = array[i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, _subViews.frame.size.height, _subViews.frame.size.width, 70)];
        [_subViews addSubview:btn];
        btn.tag = i;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_subViews.frame.size.width - 65, 10, 50, 50)];

//        [imageView sd_setImageWithURL:[dict objectForKey:@"img"] placeholderImage:[UIImage imageNamed:@"Default_Gray" ]];
//        [imageView sd_setImageWithURL:[dict objectForKey:@"img"] placeholderImage:[UIImage imageNamed:@"Default_Gray" ] options:SDWebImageRetryFailed];
        [btn addSubview:imageView];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:@"Default_Gray"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                NSLog(@"error = %@",error);
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                    });
                });
            }
        }];

        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, _subViews.frame.size.width - 65 - 18, btn.frame.size.height)];
        label.text = [dict objectForKey:@"title"];
        label.numberOfLines = 0;
        label.font = SYSFONT(14.0);
        [btn addSubview:label];
        
        UIView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(18, btn.frame.size.height - LINE_WH, btn.frame.size.width - 30, LINE_WH)];
        lineView.backgroundColor = THE_LINE_COLOR;
        [btn addSubview:lineView];
        
        [btn addTarget:self action:@selector(subViewsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _subViews.frame = CGRectMake(_subViews.frame.origin.x, _subViews.frame.origin.y, _subViews.frame.size.width, _subViews.frame.size.height + btn.frame.size.height);
    }
}

- (void) subViewsBtnAction:(UIButton *) btn {
    SBJsonParser * parser = [[SBJsonParser alloc] init] ;
    NSArray *content = [parser objectWithString:self.msg.content];
    [g_notify postNotificationName:kCellSystemImage2DidTouchNotifaction object:content[btn.tag]];
}

-(void)tapAction:(UITapGestureRecognizer *)tap
{
    SBJsonParser * parser = [[SBJsonParser alloc] init] ;
    NSArray *content = [parser objectWithString:self.msg.content];
    [g_notify postNotificationName:kCellSystemImage2DidTouchNotifaction object:content.firstObject];
}

+ (float)getChatCellHeight:(JXMessageObject *)msg {
    
    if ([msg.chatMsgHeight floatValue] > 1) {
        return [msg.chatMsgHeight floatValue];
    }
    
    float n = 0;
    SBJsonParser * parser = [[SBJsonParser alloc] init] ;
    NSArray *content = [parser objectWithString:msg.content];
    if (content.count <= 0) {
        return 0;
    }
    if (msg.isShowTime) {
        n = 190 + 70 * (content.count - 1) + 40 + INSETS;
    }else {
        n = 190 + 70 * (content.count - 1) + INSETS;
    }
    
    msg.chatMsgHeight = [NSString stringWithFormat:@"%f",n];
    if (!msg.isNotUpdateHeight) {
        [msg updateChatMsgHeight];
    }
    return n;
}

@end
