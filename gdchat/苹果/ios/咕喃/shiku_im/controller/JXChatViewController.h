//
//  JXChatViewController.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "JXTableViewController.h"
#import "JXLocationVC.h"


@class JXEmoji;
@class JXSelectImageView;
@class JXVolumeView;
@class JXRoomObject;
@class JXBaseChatCell;
@class JXVideoPlayer;
@interface JXChatViewController : JXTableViewController<UIImagePickerControllerDelegate,UITextViewDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate,AVAudioRecorderDelegate,UINavigationControllerDelegate,LXActionSheetDelegate>
{
    
    NSMutableArray *_pool;
    UITextView *_messageText;
    UIImageView *inputBar;
    UIButton* _recordBtn;
    UIButton* _recordBtnLeft;
    UIImage *_myHeadImage,*_userHeadImage;
    JXSelectImageView *_moreView;
    UIButton* _btnFace;
    emojiViewController* _faceView;
    JXEmoji* _messageConent;

    BOOL recording;
    NSTimer *peakTimer;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
	NSURL *pathURL;
    UIView* talkView;
    NSString* _lastRecordFile;
    NSString* _lastPlayerFile;
    NSTimeInterval _lastPlayerTime;
    long _lastIndex;

    double lowPassResults;
    NSTimeInterval _timeLen;
    int _refreshCount;
    
    JXVolumeView* _voice;
    NSTimeInterval _disableSay;
    NSString * _audioMeetingNo;
    NSString * _videoMeetingNo;
    NSMutableArray * _orderRedPacketArray ;
}
- (IBAction)sendIt:(id)sender;
- (IBAction)shareMore:(id)sender;
//- (void)refresh;

@property (nonatomic,strong) JXRoomObject* chatRoom;
@property (nonatomic,strong) roomData * room;
@property (nonatomic,strong) JXUserObject *chatPerson;//必须要赋值
@property (nonatomic, strong) JXMessageObject *lastMsg;
@property (nonatomic,strong) NSString* roomJid;//相当于RoomJid
@property (nonatomic,strong) NSString* roomId;
@property (nonatomic,strong) JXBaseChatCell* selCell;
@property (nonatomic,strong) JXLocationVC * locationVC;
@property (nonatomic, strong) NSMutableArray *array;

//@property (nonatomic, strong) JXMessageObject *relayMsg;
@property (nonatomic, strong) NSMutableArray *relayMsgArray;
@property (nonatomic, assign) int scrollLine;

@property (nonatomic, strong) NSMutableArray *courseArray;
@property (nonatomic, copy) NSString *courseId;

@property (nonatomic, strong) NSNumber *groupStatus;

@property (nonatomic, assign) BOOL isGroupMessages;
@property (nonatomic, strong) NSMutableArray *userIds;
@property (nonatomic, strong) NSMutableArray *userNames;

@property (nonatomic, assign) BOOL isHiddenFooter;
@property (nonatomic, strong) NSMutableArray *chatLogArray;

@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) int newMsgCount;

@property (nonatomic, strong) JXVideoPlayer *player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, copy) NSString *shareSchemes;


-(void)sendRedPacket:(NSDictionary*)redPacketDict withGreet:(NSString *)greet;
//-(void)onPlay;
//-(void)recordPlay:(long)index;
-(void)resend:(JXMessageObject*)p;
-(void)deleteMsg:(JXMessageObject*)p;
-(void)showOneMsg:(JXMessageObject*)msg;
@end
