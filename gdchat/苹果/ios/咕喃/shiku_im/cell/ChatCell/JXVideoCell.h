//
//  JXVideoCell.h
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBaseChatCell.h"
@class JXVideoPlayer;

@protocol JXVideoCellDelegate <NSObject>

- (void)showVideoPlayerWithTag:(NSInteger)tag;

@end


@interface JXVideoCell : JXBaseChatCell{
}
@property (nonatomic,strong) JXImageView * chatImage;
@property (nonatomic, strong) UIButton *pauseBtn;
//@property (nonatomic,assign) UIImage * videoImage;
@property (nonatomic,copy)   NSString *oldFileName;
@property (nonatomic, strong) JXVideoPlayer *player;
@property (nonatomic, assign) NSInteger indexTag;
@property (nonatomic, assign) BOOL isEndVideo;
@property (nonatomic, strong) UILabel *videoProgress;

@property (nonatomic, assign) id<JXVideoCellDelegate>videoDelegate;

- (void)timeGo:(NSString *)fileName;

// 看完视频后调用的方法
- (void)deleteMsg;


@end
