//
//  addMsgVC.h
//  sjvodios
//
//  Created by  on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "admobViewController.h"
#import "JXVideoPlayer.h"
#import "JXAudioPlayer.h"
#import "JXAudioRecorderViewController.h"

@class JXTextView;
@class StreamPlayerViewController;

@protocol JXServerResult;

@interface addMsgVC : admobViewController<JXServerResult,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,JXAudioRecorderDelegate,LXActionSheetDelegate>{
    int _nSelMenu;
    UIScrollView* svImages;
    UIScrollView* svAudios;
    UIScrollView* svVideos;
    UIScrollView* svFiles;

    int  _recordCount;
    int  _refreshCount;
    int  _buildHeight;
    NSInteger  _photoIndex;
    
    UIButton* _sendBtn;
    
    UITextView*  _remark;
    JXAudioPlayer* audioPlayer;
    JXVideoPlayer* videoPlayer;
    NSMutableArray* _array;
    NSMutableArray* _images;
    NSString* tUrl;
    NSString* oUrl;
}
@property(assign)BOOL isChanged;
@property(nonatomic,assign)int  dataType;
@property(nonatomic,retain) NSString* audioFile;
@property(nonatomic,retain) NSString* videoFile;
@property(nonatomic,retain) NSString* fileFile;
@property (nonatomic, weak) NSObject* delegate;
@property (nonatomic, assign) SEL		didSelect;

@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareIcon;
@property (nonatomic, copy) NSString *shareUr;

@property (nonatomic, strong) NSString *urlShare; // 链接分享


@property (nonatomic, assign) BOOL isShortVideo;

//
@property (nonatomic,assign) int maxImageCount;

@property (nonatomic,copy) void(^block)(void);

-(void)showImages;
-(void)doRefresh;

@end
