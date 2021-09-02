//
//  JXBaseChatCell.h
//  shiku_im
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXConnection.h"
#import "JXMessageObject.h"
#import "QBPopupMenuItem.h"
#import "QBPlasticPopupMenu.h"
#import "QCheckBox.h"
@class JXEmoji;
@class JXImageView;
@class JXLabel;
@class SCGIFImageView;
@class JXBaseChatCell;


#define kSystemImageCellWidth (JX_SCREEN_WIDTH - 15 * 2 - CHAT_WIDTH_ICON-HEAD_SIZE)

typedef enum : NSUInteger {
    CollectTypeDefult   = 0,// 默认
    CollectTypeEmoji    = 6,//表情
    CollectTypeImage    = 1,//图片
    CollectTypeVideo    = 2,//视频
    CollectTypeFile     = 3,//文件
    CollectTypeVoice    = 4,//语音
    CollectTypeText     = 5,//文本
} CollectType;

@protocol JXChatCellDelegate <NSObject>

// 长按回复
- (void)chatCell:(JXBaseChatCell *)chatCell replyIndexNum:(int)indexNum;
// 长按删除
- (void)chatCell:(JXBaseChatCell *)chatCell deleteIndexNum:(int)indexNum;
// 长按转发
- (void)chatCell:(JXBaseChatCell *)chatCell RelayIndexNum:(int)indexNum;
// 长按收藏
- (void)chatCell:(JXBaseChatCell *)chatCell favoritIndexNum:(int)indexNum type:(CollectType)collectType;
// 长按撤回
- (void)chatCell:(JXBaseChatCell *)chatCell withdrawIndexNum:(int)indexNum;
// 开启、关闭多选
- (void)chatCell:(JXBaseChatCell *)chatCell selectMoreIndexNum:(int)indexNum;
// 多选，选择
- (void)chatCell:(JXBaseChatCell *)chatCell checkBoxSelectIndexNum:(int)indexNum isSelect:(BOOL)isSelect;

// 开始录制
- (void)chatCell:(JXBaseChatCell *)chatCell startRecordIndexNum:(int)indexNum;
// 结束录制
- (void)chatCell:(JXBaseChatCell *)chatCell stopRecordIndexNum:(int)indexNum;

// 重发消息
- (void)chatCell:(JXBaseChatCell *)chatCell resendIndexNum:(int)indexNum;

// 语音播放转换
- (void)chatCell:(JXBaseChatCell *)chatCell audioPlayChangeIndexNum:(int)indexNum;

// 获取录制状态
- (BOOL) getRecording;
// 获取开始录制num
- (NSInteger) getRecordStarNum;

@end


@interface JXBaseChatCell : UITableViewCell<LXActionSheetDelegate>

@property (nonatomic,strong) UIButton * bubbleBg;
@property (nonatomic,strong) UIButton * readImage;
@property (nonatomic,strong) JXImageView * burnImage;
@property (nonatomic,strong) JXImageView * sendFailed;
@property (nonatomic,strong) JXLabel * readView;
@property (nonatomic,strong) JXLabel * readNum;
@property (nonatomic,strong) UIActivityIndicatorView * wait;
@property (nonatomic,strong) JXMessageObject * msg;
@property (nonatomic,strong) UIImageView * headImage;
@property (nonatomic,strong) UIImageView * cerImgView; // 认证图标
@property (nonatomic,strong) UILabel* timeLabel;
@property (nonatomic,strong) UILabel *nicknameLabel;
@property (nonatomic,assign) SEL didTouch;
@property (nonatomic,assign) int indexNum;
@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu;
@property (nonatomic, strong) QBPopupMenu *popupMenu;
@property (nonatomic, weak) id<JXChatCellDelegate>chatCellDelegate;

@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL	  readDele;

@property (nonatomic, assign) BOOL isCourse;

@property (nonatomic, assign) BOOL isShowRecordCourse;

@property (nonatomic, assign) BOOL isShowHead;
@property (nonatomic, assign) BOOL isWithdraw;  // 是否显示撤回
@property (nonatomic, assign) BOOL isNotRecord;  // 不显示录制课程

@property (nonatomic, assign) BOOL isSelectMore;
@property (nonatomic, strong) QCheckBox *checkBox;

@property (nonatomic, strong) roomData *room;

@property (nonatomic, assign) double loadProgress;
@property (nonatomic, strong) NSString *fileDict;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isBlackTip;

-(void)creatUI;
-(void)drawIsRead;
-(void)drawIsSend;
-(void)drawIsReceive;
- (void)drawReadPersons:(int)num;
- (void)setBackgroundImage;
- (void)setCellData;
-(void)setHeaderImage;
-(void)isShowSendTime;
//-(void)downloadFile:(JXImageView*)iv;
- (void)setMaskLayer:(UIImageView *)imageView;
- (void)sendMessageToUser;
- (void)setAgreeRefuseBtnStatusAfterReply;  //回应交换电话后更新按钮状态（子类实现）
- (void)updateFileLoadProgress;
// 获取cell 高度
+ (float) getChatCellHeight:(JXMessageObject *)msg;

- (void)drawReadDelView:(BOOL)isSelected;

@end
