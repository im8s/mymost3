//
//  WeiboViewControlle.h
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageLoadFootView.h"
#import "WeiboData.h"
#import "HBCoreLabel.h"
//#import "admobViewController.h"
#import "JXTableViewController.h"
#import "JX_SelectMenuView.h"
#import "JXTextView.h"
@class JXServer;
@class WeiboReplyData;
@class JXTextView;
@class WeiboCell;
@class userInfoVC;
@class JXMenuView;

#define WeiboUpdateNotification  @"WeiboUpdateNotification"

@class WeiboViewControlle;
@protocol weiboVCDelegate <NSObject>

- (void) weiboVC:(WeiboViewControlle *)weiboVC didSelectWithData:(WeiboData *)data;

@end

@interface WeiboViewControlle : JXTableViewController<HBCoreLabelDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate>
{
    JXTextView* _input;
    
    UIView* _inputParent;
    
    void(^_block)(NSString*string);
    
//    WeiboData * _deleteWeibo;
    
    NSIndexPath *_deletePath;
    
    BOOL  animationEnd;
    
    NSMutableArray* _pool;
    
    UIView * _bgBlackAlpha;
    JX_SelectMenuView * _selectView;
}

@property(nonatomic,strong) JXUserObject* user;
@property(nonatomic,strong)NSMutableArray* datas;
@property(nonatomic,strong)WeiboData * selectWeiboData;
@property(nonatomic,strong)WeiboCell* selectWeiboCell;
//@property(nonatomic,strong)WeiboReplyData * replyData;
@property(nonatomic,strong)WeiboReplyData * replyDataTemp;
@property(nonatomic,strong)WeiboData * deleteWeibo;
@property(nonatomic,assign) int refreshCount;
@property(nonatomic,assign) NSInteger refreshCellIndex;
@property(nonatomic,assign) int deleteReply;

@property (nonatomic, assign) BOOL isDetail;
@property (nonatomic, copy) NSString *detailMsgId;
@property (nonatomic, assign) BOOL isNotShowRemind;
@property (nonatomic, assign) BOOL isCollection;
@property (nonatomic, weak) id<weiboVCDelegate>delegate;
@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) NSInteger videoIndex;


@property(nonatomic,retain) JXVideoPlayer* videoPlayer;

@property(nonatomic,strong) JXMenuView *menuView;

//输入后面的透明view
@property (nonatomic,retain) UIView * clearBackGround;
-(void)doShowAddComment:(NSString*)s;
-(NSString*)getLastMessageId:(NSArray*)objects;

-(void)delBtnAction:(WeiboData *)cellData;
-(void)btnReplyAction:(UIButton *)sender WithCell:(WeiboCell *)cell;
-(void)fileAction:(WeiboData *)cellData;
-(void)setupTableViewHeight:(CGFloat)height tag:(NSInteger)tag;
//收藏
-(instancetype)initCollection;


@end
