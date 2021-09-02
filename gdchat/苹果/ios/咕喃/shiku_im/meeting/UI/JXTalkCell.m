//
//  JXTalkCell.m
//  lveliao_IM
//
//  Created by p on 2019/6/18.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTalkCell.h"

@interface JXTalkCell()

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UILabel *lastTime;
@property (nonatomic, strong) UILabel *talkTime;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JXTalkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self customView];
        [g_notify addObserver:self selector:@selector(talkAction:) name:@"TalkActionNotfi" object:nil];
    }
    
    return self;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    
//    if (self) {
//        
//        [self customView];
//        [g_notify addObserver:self selector:@selector(talkAction:) name:@"TalkActionNotfi" object:nil];
//    }
//    return self;
//    
//}

- (void)dealloc {
    [g_notify removeObserver:self];
}

- (void)talkAction:(NSNotification *)notif {
    
    NSDictionary *dict = notif.object;
    if ([[dict objectForKey:@"userId"] isEqualToString:_talkModel.userId]) {
        if ([[dict objectForKey:@"type"] isEqualToString:@"1"]) {
//            _headImage.layer.borderWidth = 2;
            _talkModel.talkTime = 1;
            _talkModel.lastTime = [[NSDate date] timeIntervalSince1970];
            _talkTime.text = [TimeUtil getTimeShort1:_talkModel.talkTime];
            _lastTime.text = [TimeUtil formatDate:[NSDate dateWithTimeIntervalSince1970:_talkModel.lastTime] format:@"HH:mm:ss"];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        }else {
            [_timer invalidate];
            _timer = nil;
            _headImage.layer.borderWidth = 0;
        }
    }
}

- (void)timerAction:(NSTimer *)timer {
    _talkModel.talkTime ++;
    _talkTime.text = [TimeUtil getTimeShort1:_talkModel.talkTime];
}

- (void)customView {
    
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 52, 52)];
    _headImage.layer.cornerRadius = 5;
    _headImage.layer.masksToBounds = YES;
    _headImage.layer.borderColor = [UIColor redColor].CGColor;
    [self addSubview:_headImage];
    
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(_headImage.frame) + 14, 92 - 24, 13)];
    _userName.textAlignment = NSTextAlignmentCenter;
    _userName.textColor = HEXCOLOR(0x999999);
    _userName.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:_userName];
    
//    _lastTime = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 100, 10, 100, 20)];
//    _lastTime.textColor = [UIColor lightGrayColor];
//    _lastTime.font = [UIFont systemFontOfSize:15.0];
//    [self addSubview:_lastTime];
//
//    UILabel *lastTip = [[UILabel alloc] initWithFrame:CGRectMake(_lastTime.frame.origin.x - 100, 10, 100, 20)];
//    lastTip.textColor = [UIColor lightGrayColor];
//    lastTip.font = [UIFont systemFontOfSize:15.0];
//    lastTip.text = Localized(@"JX_LastGrabWheat:");
//    lastTip.textAlignment = NSTextAlignmentRight;
//    [self addSubview:lastTip];
//
//    _talkTime = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 100, CGRectGetMaxY(_lastTime.frame), 100, 20)];
//    _talkTime.textColor = [UIColor lightGrayColor];
//    _talkTime.font = [UIFont systemFontOfSize:15.0];
//    [self addSubview:_talkTime];
//
//    UILabel *talkTip = [[UILabel alloc] initWithFrame:CGRectMake(_talkTime.frame.origin.x - 100, CGRectGetMaxY(lastTip.frame), 100, 20)];
//    talkTip.textColor = [UIColor lightGrayColor];
//    talkTip.font = [UIFont systemFontOfSize:15.0];
//    talkTip.text = Localized(@"JX_SpeechTime:");
//    talkTip.textAlignment = NSTextAlignmentRight;
//    [self addSubview:talkTip];
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - .5, JX_SCREEN_WIDTH, .5)];
//    line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//    [self addSubview:line];
}

- (void)setTalkModel:(JXTalkModel *)talkModel {
    _talkModel = talkModel;

    [g_server getHeadImageSmall:talkModel.userId userName:talkModel.userName imageView:_headImage getHeadHandler:nil];
    _userName.text = talkModel.userName;
//    if (talkModel.lastTime > 0) {
//        _lastTime.text = [TimeUtil formatDate:[NSDate dateWithTimeIntervalSince1970:talkModel.lastTime] format:@"HH:mm:ss"];
//    }else {
//        _lastTime.text = nil;
//    }
//
//    if (talkModel.talkTime > 0) {
//        _talkTime.text = [TimeUtil getTimeShort1:talkModel.talkTime];
//    }else {
//        _talkTime.text = nil;
//    }

}

@end
