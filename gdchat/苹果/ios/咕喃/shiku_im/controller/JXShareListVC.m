//
//  JXShareSelectView.m
//  shiku_im
//
//  Created by MacZ on 15/8/26.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "JXShareListVC.h"
#import "JXMyTools.h"


@implementation JXShareListVC

- (instancetype)init{
    self = [super init];
    if (self) {
        self.view.frame = [UIScreen mainScreen].bounds;
        self.title = nil;
        _pSelf = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self customView];
    [self showShareList];
}

- (void)customView{
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    self.view.alpha = 0;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideShareList)];
    [self.view addGestureRecognizer:tapGes];
    
    //底部选择项
    _listView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT, JX_SCREEN_WIDTH, 0)];
    _listView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [self.view addSubview:_listView];
//    [_listView release];
//    _listView.backgroundColor = [UIColor cyanColor];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _listView.frame.size.width, LINE_WH)];
    topLine.backgroundColor = THE_LINE_COLOR;
    [_listView addSubview:topLine];
//    [topLine release];
    
    //分享按钮
    NSArray *imgArray = @[@"ic_share_wechat",@"ic_share_moment"/*,@"ic_share_weibo",@"facebook",@"twitter",@"whatsapp",@"ic_share_sms",@"ic_share_line"*/];
    NSArray *titleArray = @[Localized(@"WeChatFriend"),Localized(@"WeChatMoment")/*,Localized(@"SinaWeibo"),Localized(@"FaceBook"),Localized(@"Twitter"),Localized(@"WhatsApp"),Localized(@"SMS"),Localized(@"Line")*/];

    CGFloat btnWidth = _listView.frame.size.width/4;
    CGFloat btnHeight = 90;
    for (int i=0; i<imgArray.count; i++) {
        UIButton *shareItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(i%4*btnWidth, i/4*btnHeight, btnWidth, btnHeight)];
        shareItemBtn.tag = i;
        [shareItemBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_listView addSubview:shareItemBtn];
//        [shareItemBtn release];
//        shareItemBtn.backgroundColor = [UIColor cyanColor];
        
        UIImageView *itemImg = [[UIImageView alloc] initWithFrame:CGRectMake((shareItemBtn.frame.size.width-50)/2, 15, 50, 50)];
        //itemImg.center = CGPointMake(shareItemBtn.center.x, itemImg.center.y);
        itemImg.image = [UIImage imageNamed:imgArray[i]];
        [shareItemBtn addSubview:itemImg];
//        [itemImg release];
//        itemImg.backgroundColor = [UIColor magentaColor];
        
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, itemImg.frame.origin.y+itemImg.frame.size.height+10, shareItemBtn.frame.size.width, 15)];
        itemLabel.text = titleArray[i];
        itemLabel.font = SYSFONT(13);
        itemLabel.textAlignment = NSTextAlignmentCenter;
        [shareItemBtn addSubview:itemLabel];
//        [itemLabel release];
//        itemLabel.backgroundColor = [UIColor purpleColor];
    }
    
    CGRect frame = _listView.frame;
    frame.size.height = ((imgArray.count - 1)/4 + 1)*btnHeight;
    _listView.frame = frame;
    
    //取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _listView.frame.size.height + 10, _listView.frame.size.width, 50)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:15/255.0 green:-97/255.0 blue:-94/255.0 alpha:1] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = SYSFONT(16);
    [cancelBtn addTarget:self action:@selector(hideShareList) forControlEvents:UIControlEventTouchUpInside];
    [_listView addSubview:cancelBtn];
//    [cancelBtn release];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cancelBtn.frame.size.width, LINE_WH)];
    bottomLine.backgroundColor = THE_LINE_COLOR;
    [cancelBtn addSubview:bottomLine];
//    [bottomLine release];
    
    frame.size.height = cancelBtn.frame.origin.y + cancelBtn.frame.size.height;
    if (THE_DEVICE_HAVE_HEAD) {
        frame.size.height += 35;
    }
    _listView.frame = frame;
}

//分享按钮点击事件
- (void)shareBtnClick:(UIButton *)shareBtn{
    if ([self.shareListDelegate respondsToSelector:@selector(didShareBtnClick:)]) {
        [self.shareListDelegate didShareBtnClick:shareBtn];
    }
    
    [self hideShareList];
}

//显示分享列表
- (void)showShareList{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 1;
        CGRect frame = _listView.frame;
        frame.origin.y = JX_SCREEN_HEIGHT - frame.size.height;
        _listView.frame = frame;
    }];
}

//隐藏分享列表
- (void)hideShareList{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
        CGRect frame = _listView.frame;
        frame.origin.y = JX_SCREEN_HEIGHT;
        _listView.frame = frame;
    }completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        _pSelf = nil;
    }];
}

- (void)dealloc {
    NSLog(@"JXShareListVC -- dealloc");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
