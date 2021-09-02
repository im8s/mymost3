//
//  WeiboCell.h
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBCoreLabel.h"
#import "HBShowImageControl.h"
#import "WeiboData.h"
#import "WeiboViewControlle.h"
#import <QuickLook/QuickLook.h>
#import "ReplyCell.h"
#import "JXAudioPlayer.h"
#import "JXVideoPlayer.h"

#define REPLY_BACK_COLOR 0xd5d5d5

@class MPMoviePlayerController;
@class userInfoVC;
@class WeiboCell;



@class WeiboViewControlle;

@protocol WeiboCellDelegate <NSObject>

- (void)weiboCell:(WeiboCell *)weiboCell shareUrlActionWithUrl:(NSString *)url title:(NSString *)title;

- (void)weiboCell:(WeiboCell *)weiboCell clickVideoWithIndex:(NSInteger)index;

@end

@interface WeiboCell : UITableViewCell<HBShowImageControlDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray * _replys;
    
    NSIndexPath * _indexPath;
    
    BOOL linesLimit;
    
    int replyCount;
    
    NSString* _oldInputText;
    
    NSMutableArray* _newGifts;
    
    int _heightPraise;
    
//    userInfoVC* _userVc;
    NSMutableArray* _pool;
}
@property(nonatomic,retain) UILabel *  title;
@property(nonatomic,retain) HBCoreLabel * content;
@property(nonatomic,retain) UIView * imageContent;
@property(nonatomic,strong) UIView * fileView;
@property (strong, nonatomic) UIImageView * typeView;
@property (strong, nonatomic) UILabel * fileTitleLabel;
@property(nonatomic,retain) UILabel * time;
@property(nonatomic,strong) UIButton * delBtn;
@property(nonatomic,strong) UILabel * locLabel;
@property(nonatomic,retain) JXImageView * mLogo;
@property(nonatomic,retain) UIView * replyContent;
@property(nonatomic,retain) UIButton * btnReply;  // 回复
@property(nonatomic,retain) UIButton * btnLike;   // 点赞
@property(nonatomic,retain) UIButton * btnCollection; // 收藏
@property(nonatomic,retain) UIButton * btnReport; // 举报
@property (nonatomic, assign) BOOL isPraise; // 是否点赞
@property (nonatomic, assign) BOOL isCollect; // 是否收藏
@property(nonatomic,retain) UIImageView * back;
@property(nonatomic,retain) UITableView * tableReply;
@property(nonatomic,retain) UIView * lockView;
@property(nonatomic,retain) UIButton *btnDelete;
@property(nonatomic,retain) UIButton * btnShare;
@property(nonatomic,weak) WeiboViewControlle * controller;
@property(nonatomic,weak) UITableView* tableViewP;
@property(nonatomic,retain) WeiboData* weibo;
@property(nonatomic,retain) JXImageView* imagePlayer;
@property(nonatomic,retain) UIButton* pauseBtn;
@property(nonatomic,assign) int refreshCount;
@property(nonatomic,strong) JXAudioPlayer* audioPlayer;
@property(nonatomic,retain) JXVideoPlayer* videoPlayer;
@property (nonatomic, weak) id<WeiboCellDelegate>delegate;
@property(nonatomic,retain) UILabel *moreLabel;

+(float)getHeightByContent:(WeiboData*)data;

+(float) heightForReply:(NSArray*)replys;

-(void)loadReply;

//-(void)doHideMenu;

-(void)setReplys:(NSArray*)replys;
-(NSArray *)getReplys;
//-(void)refresh:(WeiboCell *)selWeiboCell;

-(void)refresh;

- (void)setupData;

@end

