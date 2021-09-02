//
//  emojiViewController.m
//
//  Created by daxiong on 13-11-27.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "emojiViewController.h"
#import "menuImageView.h"
#import "FaceViewController.h"
#import "gifViewController.h"
#import "AppDelegate.h"

@implementation emojiViewController
@synthesize delegate;
@synthesize faceView=_faceView;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xF2F2F2);
        _faceView = [[FaceViewController alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.frame.size.height-JX_SCREEN_BOTTOM)];
        [self addSubview:_faceView];
        _faceView.hidden   = NO;
        
        _gifView = [[gifViewController alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.frame.size.height-JX_SCREEN_BOTTOM)];
        [self addSubview:_gifView];
        _gifView.hidden   = YES;
        
        _favoritesVC = [[FavoritesVC alloc] init];
        _favoritesVC.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, self.frame.size.height-JX_SCREEN_BOTTOM);
        [self addSubview:_favoritesVC.view];
        _favoritesVC.view.hidden = YES;

        _tb = [menuImageView alloc];
        
        //表情 动画 收藏 发送
        _tb.items = [NSArray arrayWithObjects:Localized(@"emojiVC_Emoji"),Localized(@"emojiVC_Anma"),Localized(@"JX_CustomExpression"),Localized(@"JX_Send"),nil];
        _tb.type  = 0;
        _tb.delegate = self;
        _tb.showSelected = YES;
        _tb.offset   = 0;
        _tb.itemWidth = 300/4;
        _tb.onClick  = @selector(actionSegment:);
        _tb = [_tb initWithFrame:CGRectMake(10, self.frame.size.height-JX_SCREEN_BOTTOM, JX_SCREEN_WIDTH-20, height_im_footer)];
        [self addSubview:_tb];
//        [_tb release];
        [_tb selectOne:0];
}
    return self;
}

-(void) dealloc{
//    [delegate release];
//    [_tb release];
//    [_faceView release];
//    [_gifView release];
//    [super dealloc];
}

-(void)actionSegment:(UIButton*)sender{
    switch (sender.tag){
        case 0:
            _faceView.hidden   = NO;
            _gifView.hidden   = YES;
            _favoritesVC.view.hidden = YES;
            break;
        case 1:
            _faceView.hidden   = YES;
            _gifView.hidden   = NO;
            _favoritesVC.view.hidden = YES;
            break;
        case 2:
            _faceView.hidden   = YES;
            _gifView.hidden   = YES;
            _favoritesVC.view.hidden = NO;
            break;
        case 3:
            //发送全局通知
            [g_notify postNotificationName:kSendInputNotifaction object:nil userInfo:nil];
            break;
    }
}

-(void)setDelegate:(id)value{
    if(delegate != value){
        delegate = value;
        _faceView.delegate = delegate;
        _gifView.delegate = delegate;
        _favoritesVC.delegate = delegate;
    }
}

-(void)selectType:(int)n{
    [_tb selectOne:n];
    _faceView.hidden   = NO;
    _gifView.hidden   = YES;
    _favoritesVC.view.hidden = YES;
}

@end
