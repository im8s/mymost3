//
//  JXBaseChatCell.m
//  shiku_im
//
//  Created by Apple on 16/10/11.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXBaseChatCell.h"
#import "JXImageView.h"
#import "roomData.h"


#define CER_HEIGHT 3  // 管理员边框和头像的距离

static double g_timeSend=0;

@implementation JXBaseChatCell
//没有xib的初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _bubbleBg = [[UIButton alloc] init];
    [self.contentView addSubview:self.bubbleBg];
    [_bubbleBg addTarget:self action:@selector(didTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor clearColor];

    self.contentView.clipsToBounds = YES;
    [self creatBaseUI];
    [self creatUI];
    
    [g_notify addObserver:self selector:@selector(notifyDrawIsReceive:) name:kMsgDrawIsReceiveNotifaction object:nil];//
    [g_notify addObserver:self selector:@selector(updateLoadFileProgress:) name:kUploadFileProgressNotifaction object:nil];
    self.layer.masksToBounds = YES;
    
    //添加长按手势
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
    longPress.minimumPressDuration = 1;
    [self.contentView addGestureRecognizer:longPress];

    return self;
}
//有xib的初始化
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bubbleBg = [[UIButton alloc]init];
    [self.contentView addSubview:self.bubbleBg];
    [_bubbleBg addTarget:self action:@selector(didTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor clearColor];
    [self creatBaseUI];
    [self creatUI];
}
//子类创建对应UI
- (void)creatUI{
    
}
//子类根据数据显示界面
-(void)setCellData{

    _readImage.hidden = YES;
    memberData *data = [[memberData alloc] init];
    data.roomId = self.room.roomId;
    data = [data getCardNameById:self.msg.fromUserId];
    JXUserObject *allUser = [[JXUserObject alloc] init];
    allUser = [allUser getUserById:[NSString stringWithFormat:@"%ld",data.userId]];
    memberData *data1 = [_room getMember:MY_USER_ID];
    if ([data1.role intValue] == 1) {
        self.nicknameLabel.text = data.lordRemarkName.length > 0  ? data.lordRemarkName : allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName.length > 0  ? data.userNickName : self.msg.fromUserName;
    }else {
        self.nicknameLabel.text = allUser.remarkName.length > 0  ? allUser.remarkName : data.userNickName.length > 0  ? data.userNickName : self.msg.fromUserName;
    }
    if (!_room.allowSendCard && [data1.role intValue] != 1 && [data1.role intValue] != 2 && self.nicknameLabel.text.length > 0) {
        self.nicknameLabel.text = [self.nicknameLabel.text substringToIndex:[self.nicknameLabel.text length]-1];
        self.nicknameLabel.text = [self.nicknameLabel.text stringByAppendingString:@"*"];
    }
    
    if (self.msg.isGroup && !self.msg.isMySend) {
        self.nicknameLabel.hidden = NO;
    }else {
        self.nicknameLabel.hidden = YES;
    }
    memberData *roleData = [_room getMember:self.msg.fromUserId];
    NSString *imageStr;
    if ([roleData.role intValue] == 1) {
        imageStr = @"icon_certification_owner";
    }else if ([roleData.role intValue] == 2) {
        imageStr = @"icon_certification";
    }
    _cerImgView.image = [UIImage imageNamed:imageStr];

    if (self.msg.isGroup) {
        if ([roleData.role intValue] == 1 || [roleData.role intValue] == 2) {
            self.cerImgView.hidden = NO;
        }else {
            self.cerImgView.hidden = YES;
        }
    }
    
//    [self creatLongPressItems];
    NSArray *array = [self.msg fetchReadList];
    _readNum.text = [NSString stringWithFormat:@"%ld%@",array.count,Localized(@"JXLiveVC_countPeople")];
    
    CGSize size = [_readNum.text sizeWithAttributes:@{NSFontAttributeName:_readNum.font}];
    _readNum.frame = CGRectMake(_readView.frame.size.width - size.width-10, _readNum.frame.origin.y, size.width+10, _readNum.frame.size.height);
}
//创建子类通用UI
-(void)creatBaseUI{
    
    _checkBox = [[QCheckBox alloc] initWithDelegate:self];
    _checkBox.frame = CGRectMake(13, INSETS, 22, 22);
    [self.contentView addSubview:_checkBox];
    
    //头像
    _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(MAX_INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
    _headImage.layer.cornerRadius = 5;
    _headImage.layer.masksToBounds = YES;
    [self.contentView addSubview:_headImage];
    _headImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_headImage addGestureRecognizer:tap];
//    [tap release];
//    [_headImage release];
    _cerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(INSETS, INSETS, HEAD_SIZE, HEAD_SIZE)];
    [self.contentView addSubview:_cerImgView];
    //已读人数
    _readView = [[JXLabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    _readView.backgroundColor = [UIColor clearColor];
    _readView.userInteractionEnabled = YES;
    _readView.delegate = self;
    _readView.didTouch = @selector(showReadPersons);
    [self.contentView addSubview:_readView];
    
    _readNum = [[JXLabel alloc] initWithFrame:CGRectMake(_readView.frame.size.width - 30, 0, 30, 15)];
    _readNum.textColor = [UIColor whiteColor];
    _readNum.layer.cornerRadius = 3.0;
    _readNum.layer.masksToBounds = YES;
    _readNum.backgroundColor = HEXCOLOR(0x7bd581);
    _readNum.text = @"10人";
    _readNum.font = [UIFont systemFontOfSize:11];
    _readNum.textAlignment = NSTextAlignmentCenter;
    [_readView addSubview:_readNum];
    
    _nicknameLabel = [[UILabel alloc] init];
    _nicknameLabel.textColor = [UIColor grayColor];
    _nicknameLabel.font = SYSFONT(12.0);
    _nicknameLabel.text = @"userName";
    [self.contentView addSubview:_nicknameLabel];
    
    //等待
    _wait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_wait];
    //    [_wait release];
    
    //发送失败
    _sendFailed = [[JXImageView alloc]init];
    _sendFailed.image = [UIImage imageNamed:@"im_send_fail_nor"];
    //    _sendFailed.textColor = [UIColor redColor];
    //    _sendFailed.userInteractionEnabled = YES;
    _sendFailed.backgroundColor = [UIColor clearColor];
    //    _sendFailed.text = @"!";
    _sendFailed.delegate = self;
    _sendFailed.didTouch = @selector(showResendMenu);
    //    _sendFailed.font = [UIFont boldSystemFontOfSize:35];
    //    _sendFailed.textAlignment = NSTextAlignmentRight;
    _sendFailed.hidden = YES;
    [self.contentView addSubview:_sendFailed];
    //    [_sendFailed release];
}

- (void) tapAction {
    _headImage.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _headImage.userInteractionEnabled = YES;
    });
    [g_notify postNotificationName:kCellHeadImageNotification object:self.msg];
}

//发送失败，重新发送
-(void)showResendMenu{
    [g_window endEditing:YES];
    if (self.chatCellDelegate && [self.chatCellDelegate respondsToSelector:@selector(chatCell:resendIndexNum:)]) {
        [self.chatCellDelegate chatCell:self resendIndexNum:self.indexNum];
    }
//    LXActionSheet* _menu = [[LXActionSheet alloc]
//                            initWithTitle:nil
//                            delegate:self
//                            cancelButtonTitle:Localized(@"JX_Cencal")
//                            destructiveButtonTitle:Localized(@"JXBaseChatCell_SendAngin")
//                            otherButtonTitles:@[Localized(@"JX_Delete")]];
//    [g_window addSubview:_menu];
//    [_menu release];
}

//- (void)didClickOnButtonIndex:(LXActionSheet*)sender buttonIndex:(int)buttonIndex{
//
//    if(buttonIndex == 0)
//        [g_notify postNotificationName:kCellResendMsgNotifaction object:[NSNumber numberWithInt:self.indexNum]];
//    if(buttonIndex == 1)
//        [g_notify postNotificationName:kCellDeleteMsgNotifaction object:[NSNumber numberWithInt:self.indexNum]];
//}

// 群组内几人查看点击
- (void)showReadPersons {
    [g_notify postNotificationName:kCellShowReadPersonsNotifaction object:[NSNumber numberWithInt:self.indexNum]];
}

//展示发言时间
-(void)isShowSendTime{
    
    //系统提示发送消息时间
    if(self.msg.isShowTime && [self.msg.type intValue] != kWCMessageTypeRemind){//超过15分钟则显示时间
        if(_timeLabel == nil){
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _timeLabel.textColor = HEXCOLOR(0x999999);
            _timeLabel.font = g_factory.font12;
            _timeLabel.userInteractionEnabled = NO;
            _timeLabel.frame = CGRectMake(JX_SCREEN_WIDTH/2 -40-4, 10, 86+8, 19);
            _timeLabel.layer.cornerRadius = 3.f;
            _timeLabel.layer.masksToBounds = YES;
            _timeLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_timeLabel];
        }
        if (self.isBlackTip) {
            _timeLabel.textColor = [UIColor blackColor];
            _nicknameLabel.textColor = [UIColor blackColor];
        }else {
            _timeLabel.textColor = HEXCOLOR(0x999999);
            _nicknameLabel.textColor = [UIColor grayColor];
        }

        _timeLabel.hidden = NO;
        NSDateFormatter* f=[[NSDateFormatter alloc]init];
        [f setDateFormat:@"MM-dd HH:mm"];
        _timeLabel.text = [f stringFromDate:self.msg.timeSend];
        
        g_timeSend = [self.msg.timeSend timeIntervalSince1970];
    }else{
        _timeLabel.hidden = YES;
    }
}
//获取头像
-(void)setHeaderImage{
    
    
    if ([self.msg.type intValue] == kWCMessageTypeRemind || [self.msg.type intValue] == kWCMessageTypeChatKeyGroupRequest) {
        self.checkBox.hidden = YES;
    }else {
        if (self.isSelectMore) {
            self.checkBox.hidden = NO;
        }else {
            self.checkBox.hidden = YES;
        }
    }
    
    if([_msg.type intValue] != kWCMessageTypeRemind && ![_msg isPinbaMsg]){
        if ([_msg.type intValue] == kWCMessageTypePhoneAsk) {
            if (_msg.isMySend) {
                return;
            }
        }
        if(_msg.isMySend){//头像
            _headImage.frame = CGRectMake(JX_SCREEN_WIDTH-MAX_INSETS-HEAD_SIZE, INSETS, HEAD_SIZE, HEAD_SIZE);
            _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT/2-0.35, _headImage.frame.origin.y-CER_HEIGHT/2+1, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
            _nicknameLabel.textAlignment = NSTextAlignmentRight;
            _nicknameLabel.frame = CGRectMake(JX_SCREEN_WIDTH-MAX_INSETS-HEAD_SIZE - 200 - 10, 6, 200, 12);
            if (_msg.isShowTime) {
                _headImage.frame = CGRectMake(JX_SCREEN_WIDTH-MAX_INSETS-HEAD_SIZE, INSETS + 40, HEAD_SIZE , HEAD_SIZE);
                _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT/2-0.35, _headImage.frame.origin.y-CER_HEIGHT/2+1, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
                _nicknameLabel.frame = CGRectMake(JX_SCREEN_WIDTH-MAX_INSETS-HEAD_SIZE - 200 - 10, 6 + 40, 200, 12);
            }
        }else{
            if (self.isSelectMore) {
                if ([self.msg.type intValue] != kWCMessageTypeRemind) {
                    _headImage.frame =  CGRectMake(CGRectGetMaxX(_checkBox.frame) + 13, INSETS,HEAD_SIZE , HEAD_SIZE);
                }else {
                    _headImage.frame =  CGRectMake(MAX_INSETS, INSETS,HEAD_SIZE , HEAD_SIZE);
                }
            }else {
                _headImage.frame =  CGRectMake(MAX_INSETS, INSETS,HEAD_SIZE , HEAD_SIZE);
            }
            _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT/2-0.35, _headImage.frame.origin.y-CER_HEIGHT/2+1, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
            _nicknameLabel.textAlignment = NSTextAlignmentLeft;
            _nicknameLabel.frame = CGRectMake(CGRectGetMaxX(_headImage.frame) + 15, 6, 200, 12);
            if (_msg.isShowTime) {
                _headImage.frame = CGRectMake(_headImage.frame.origin.x, INSETS + 40, HEAD_SIZE , HEAD_SIZE);
                _cerImgView.frame = CGRectMake(_headImage.frame.origin.x-CER_HEIGHT/2-0.35, _headImage.frame.origin.y-CER_HEIGHT/2+1, _headImage.frame.size.width+CER_HEIGHT, _headImage.frame.size.height+CER_HEIGHT);
                _nicknameLabel.frame = CGRectMake(_nicknameLabel.frame.origin.x, 6 + 40, 200, 12);
            }
        }
        
        float cellH = [[self class] getChatCellHeight:self.msg];
        _checkBox.center = CGPointMake(_checkBox.center.x, cellH / 2);
        
//        if () {
        NSString *headUserId = _msg.fromUserId;
//        if (_msg.isMySend) {
//            if ([_msg.toUserId isEqualToString:ANDROID_USERID] || [_msg.toUserId isEqualToString:PC_USERID] || [_msg.toUserId isEqualToString:MAC_USERID]) {
//                headUserId = IOS_USERID;
//            }
//        }
//        if (self.isShowHead) {
//        _headImage.image = nil;
        [g_server getHeadImageSmall:headUserId userName:_msg.fromUserName imageView:_headImage getHeadHandler:nil];
//        }else {
//            _headImage.image = [UIImage imageNamed:@"avatar_normal"];
//        }
//        }else{
//            [g_server getHeadImageSmall:[_msg.fromUserId longLongValue]-1 imageView:_headImage];
//        }
    }
}

//聊天框
- (void)setBackgroundImage{
     //初步过滤不需要bgImage的cell
    if([_msg.type intValue] == kWCMessageTypeRemind || [_msg isPinbaMsg] || [_msg.type intValue] == kWCMessageTypeSystemImage1 || [_msg.type intValue] == kWCMessageTypeSystemImage2){
        
        _readView.hidden = YES;
        return;
    }
    if (self.msg.isGroup && self.msg.showRead && [self.msg.isSend intValue] == 1) {
        _readView.hidden = NO;
    }else {
        _readView.hidden = YES;
    }
    
    //依数据过滤不需要bgImage的cell
    if ([_msg.type intValue] == kWCMessageTypePhoneAsk || [_msg.type intValue] == kWCMessageTypeResumeAsk) {
        if (_msg.isMySend) {
            return;
        }
    }
    
    //送达已读图标
    int n = 26;
    int h = _bubbleBg.frame.size.height;
    if(self.msg.isMySend){
        _wait.frame = CGRectMake(_bubbleBg.frame.origin.x-n-INSETS, (h-n)/2+INSETS, n, n);
        
        _readView.frame = CGRectMake(_bubbleBg.frame.origin.x - _readView.frame.size.width - INSETS - 2,  _bubbleBg.frame.origin.y + 2, _readView.frame.size.width, _readView.frame.size.height);
        _readNum.frame = CGRectMake(_readView.frame.size.width - 30, _readNum.frame.origin.y, _readNum.frame.size.width, _readNum.frame.size.height);
        
    }else{
        _wait.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+INSETS, (h-n)/2+INSETS, n, n);
        _readView.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+INSETS + 2, _bubbleBg.frame.origin.y + 2, _readView.frame.size.width, _readView.frame.size.height);
        _readNum.frame = CGRectMake(0, _readNum.frame.origin.y, _readNum.frame.size.width, _readNum.frame.size.height);
    }
    if (self.msg.isShowTime) {
        CGRect frame = _wait.frame;
        frame.origin.y = _wait.frame.origin.y + 40;
        _wait.frame = frame;
    }
    
    _sendFailed.frame = _wait.frame;
    
    // 阅后即焚标记(使用时才创建)
    if (!_burnImage) {
        _burnImage = [[JXImageView alloc] init];
        _burnImage.image = [UIImage imageNamed:@"burn_default"];
        _burnImage.hidden = YES;
        [self.contentView addSubview:_burnImage];
    }

    //送达
    if(self.msg.isMySend){
        [self drawSendOrReadImage];
        if (([_msg.type intValue] == kWCMessageTypeFile || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVideo) && [self.msg.isSend intValue] == transfer_status_yes) {
            // 进度条发送时可能会出现进度条一直存在， 这里处理， 收到回执就隐藏进度条
            [self sendMessageToUser];
        }
    }else{
        //阅后即焚标记
        [self drawReadDelView:NO];
        
        if([self.msg.type intValue] != kWCMessageTypeVoice && [self.msg.type intValue] != kWCMessageTypeVideo && [self.msg.type intValue] != kWCMessageTypeFile && [self.msg.type intValue] != kWCMessageTypeLocation && [self.msg.type intValue] != kWCMessageTypeCard && [self.msg.type intValue] != kWCMessageTypeLink && [self.msg.type intValue] != kWCMessageTypeMergeRelay)
            _readImage.hidden = YES;
            _sendFailed.hidden = YES;
        }
    
        if ([_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVideo || [_msg.type intValue] == kWCMessageTypeLocation || [_msg.type intValue] == kWCMessageTypeRedPacket || [_msg.type intValue] == kWCMessageTypeFile || [_msg.type intValue] == kWCMessageTypeCard || [_msg.type intValue] == kWCMessageTypeLink || [_msg.type intValue] == kWCMessageTypeGif || [_msg.type intValue] == kWCMessageTypeShake || [_msg.type intValue] == kWCMessageTypeMergeRelay || [_msg.type intValue] == kWCMessageTypeShare || [_msg.type intValue] == kWCMessageTypeTransfer || [_msg.type intValue] == kWCMessageTypeChatKeyGroupRequest) {
            return;
        }
    
        if(_msg.isMySend){
            [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"chat_bg_blue"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch] forState:UIControlStateNormal];
            [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"chat_bg_blue_press"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch] forState:UIControlStateHighlighted];
        }else{
            [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"chat_bg_white"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch] forState:UIControlStateNormal];
            [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"chat_bg_white_press"]stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch] forState:UIControlStateHighlighted];
    }
}

//阅后即焚标记
- (void)drawReadDelView:(BOOL)isSelected {
    // isSelected    YES 文本倒计时状态   NO 文本未点击状态
    _burnImage.frame = CGRectMake(CGRectGetMaxX(_bubbleBg.frame)+(isSelected ? 11 : 6), _bubbleBg.frame.origin.y+(isSelected ? 22 : 14), 15, 15);

    if ([self.msg.type intValue] == kWCMessageTypeGif || [self.msg.type intValue] == kWCMessageTypeShake) {
        _burnImage.frame = CGRectMake(CGRectGetMaxX(_bubbleBg.frame)+(isSelected ? 11 : 6), 22+(isSelected ? 22 : 14), _burnImage.frame.size.width, _burnImage.frame.size.height);
        if (self.msg.isShowTime) {
            CGRect burnFrame = _burnImage.frame;
            burnFrame.origin.y = _burnImage.frame.origin.y + 40;
            _burnImage.frame = burnFrame;
        }
    }
    if (([_msg.type intValue] == kWCMessageTypeText || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVoice || [_msg.type intValue] == kWCMessageTypeVideo)) {
        _burnImage.hidden = ![_msg.isReadDel boolValue];
    }else {
        _burnImage.hidden = YES;
    }

    if (self.isCourse) {
        _burnImage.hidden = YES;
    }

}
//下载
//-(void)downloadFile:(JXImageView*)iv{
//    if([_msg.content length]<=0)
//        return;
//    if(_msg.isMySend && [[NSFileManager defaultManager] fileExistsAtPath:_msg.fileName] ){//如本地文件存在
//        if([[_msg.fileName pathExtension] isEqualToString:@"jpg"] && iv!=nil){
//            UIImage* p = [[UIImage alloc]initWithContentsOfFile:_msg.fileName];
//            iv.image = p;
////            [p release];
//        }
//        return;
//    }
//    
//    NSString* ext  = [[_msg.content lastPathComponent] pathExtension];
//    NSString *filepath = [myTempFilePath stringByAppendingPathComponent:[_msg.content lastPathComponent]];
//    
//    if( ![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
//        [g_server addTask:_msg.content param:iv toView:self];
//    }
//    else{
//        [self doSaveOK];
//        if([ext isEqualToString:@"jpg"] && iv!=nil){
//            UIImage* p = [[UIImage alloc]initWithContentsOfFile:filepath];
//            iv.image = p;
////            [p release];
//        }
//    }
//    
//    filepath = nil;
//    ext = nil;
//}

- (void)didServerResultSucces:(JXConnection *)task dict:(NSDictionary *)dict array:(NSArray *)array1{
    [self doSaveOK];
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [self doSaveError];
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{
    [self doSaveError];
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
}

-(void)doSaveError{
    NSLog(@"http失败");
    [_msg updateIsReceive:transfer_status_no];
    [self drawIsReceive];
}

-(void)doSaveOK{
    _msg.fileName = [myTempFilePath stringByAppendingPathComponent:[_msg.content lastPathComponent]];
    [_msg updateIsReceive:transfer_status_yes];
    [self setBackgroundImage];
    [self drawIsReceive];
}

//语音红点
-(void)drawIsRead{
    if (self.msg.isMySend) {
        return;
    }
    if([self.msg.isRead boolValue]){
        if (_readImage == nil) {
            JXImageView * imageV = (JXImageView *) [self viewWithTag:131];
            imageV.hidden = YES;
        }else{
            _readImage.hidden = YES;
        }
    }
    else{
        if(_readImage==nil){
            _readImage=[[UIButton alloc]init];
            [_readImage setImage:[UIImage imageNamed:@"new_tips"] forState:UIControlStateNormal];
            _readImage.hidden = YES;
            [self.contentView addSubview:_readImage];
        }
        _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+7, _bubbleBg.frame.origin.y+13, 10, 10);
        [_readImage setImage:[UIImage imageNamed:@"new_tips"] forState:UIControlStateNormal];
        _readImage.tag = 131;
        _readImage.hidden = YES;
        
    }
}
//改为消息已发送
-(void)drawIsSend{
    
    int n = [self.msg.isSend intValue];
    _wait.hidden = n != transfer_status_ing;
    if(n){
        [_wait stopAnimating];
        if (self.msg.isGroup) {
//            if (self.readView.hidden && self.msg.showRead) {
//                self.readView.hidden = NO;
//            }
            if (self.msg.isGroup && self.msg.showRead && [self.msg.isSend intValue] == 1) {
                _readView.hidden = NO;
            }else {
                _readView.hidden = YES;
            }
            
            if([_msg.type intValue] == kWCMessageTypeRemind || [_msg isPinbaMsg] || [_msg.type intValue] == kWCMessageTypeSystemImage1 || [_msg.type intValue] == kWCMessageTypeSystemImage2){
                
                _readView.hidden = YES;
            }

            NSArray *array = [self.msg fetchReadList];
            _readNum.text = [NSString stringWithFormat:@"%ld%@",array.count,Localized(@"JXLiveVC_countPeople")];
            
            CGSize size = [_readNum.text sizeWithAttributes:@{NSFontAttributeName:_readNum.font}];
            if (self.msg.isMySend) {
                _readNum.frame = CGRectMake(_readView.frame.size.width - size.width-10, _readNum.frame.origin.y, size.width+10, _readNum.frame.size.height);
            }else {
                
                _readNum.frame = CGRectMake(0, _readNum.frame.origin.y, size.width+10, _readNum.frame.size.height);
            }
        }else {
            if (self.msg.isMySend) {
                //送达
                [self drawSendOrReadImage];
            }
        }
        if (([_msg.type intValue] == kWCMessageTypeFile || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVideo) && [self.msg.isRead intValue] == 0 && [self.msg.isSend intValue] == transfer_status_yes) {
            // 进度条发送时可能会出现进度条一直存在， 这里处理， 收到回执就隐藏进度条
            [self sendMessageToUser];
        }

    }
    else
        [_wait startAnimating];
    if(n == transfer_status_no){
        _sendFailed.hidden = NO;
//        _readImage.hidden = YES;
    }else{
        _sendFailed.hidden = YES;
//        _readImage.hidden = NO;
    }
    
    if (self.isCourse) {
        _sendFailed.hidden = YES;
    }
    
}

-(void)drawSendOrReadImage{
    //消息发送失败
    if([self.msg.isSend intValue] == transfer_status_no){
        _readImage.hidden = YES;
        _sendFailed.hidden = NO;
        return;
    }
    //消息发送成功
    if([self.msg.isSend intValue] == transfer_status_yes || [self.msg.isSend intValue] == transfer_status_ing){
        _sendFailed.hidden = YES;
        

        //不显示的条件
        if ([self.msg.type intValue] == kWCMessageTypeRemind || self.msg.isGroup || !self.msg.isVisible || [_msg isPinbaMsg]) {
//            if (!self.isGroup && self.msg.isVisible) {
//                if(_readImage == nil){
//                    NSLog(@"哈哈");
//                }
//                _readImage.hidden = NO;
//                        if( [self.msg.isRead intValue] == 0){
//                //            _readImage.image = [UIImage imageNamed:@"send"];
//                            [_readImage setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
//                            [_readImage setTitle:Localized(@"JX_Unread") forState:UIControlStateNormal];
//
//                        }else{
//                            [_readImage setTitleColor:HEXCOLOR(0xCCCCCC) forState:UIControlStateNormal];
//                            [_readImage setTitle:Localized(@"JX_Read") forState:UIControlStateNormal];
//                //            _readImage.image = [UIImage imageNamed:@"read"];
//                        }
//            }else{
                 _readImage.hidden = YES;
                return;
//            }
           
            
        }
        
        //判断是否要新建
        if (_readImage == nil) {
            if ([g_myself.isShowMsgState intValue] == 1) {
                _readImage = [[UIButton alloc]init];
                _readImage.hidden = YES;
                [self.contentView addSubview:_readImage];
            }
        }
        [_readImage.titleLabel setFont:SYSFONT(12)];

        //设置图片
        _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x-20-INSETS*0.5-10, _bubbleBg.frame.origin.y+2, 30, 12);
        _burnImage.frame = CGRectMake(_bubbleBg.frame.origin.x-20-INSETS*0.5+2, _bubbleBg.frame.origin.y+20, 15, 15);
        
        if ([self.msg.type intValue] == kWCMessageTypeGif || [self.msg.type intValue] == kWCMessageTypeShake) {
            _readImage.frame = CGRectMake(JX_SCREEN_WIDTH-HEAD_SIZE-imageItemHeight-INSETS*2 + 40 - 20 - INSETS * .5-10, 20, _readImage.frame.size.width, _readImage.frame.size.height);
            _burnImage.frame = CGRectMake(JX_SCREEN_WIDTH-HEAD_SIZE-imageItemHeight-INSETS*2 + 40 - 20 - INSETS * .5+2, 20+18, _burnImage.frame.size.width, _burnImage.frame.size.height);
            if (self.msg.isShowTime) {
                CGRect frame = _readImage.frame;
                frame.origin.y = _readImage.frame.origin.y + 40;
                _readImage.frame = frame;
                
                CGRect burnFrame = _burnImage.frame;
                burnFrame.origin.y = _burnImage.frame.origin.y + 40;
                _burnImage.frame = burnFrame;
            }
        }
        if( [self.msg.isRead intValue] == 0){
//            _readImage.image = [UIImage imageNamed:@"send"];
            [_readImage setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
            [_readImage setTitle:Localized(@"JX_Unread") forState:UIControlStateNormal];

        }else{
            [_readImage setTitleColor:HEXCOLOR(0xCCCCCC) forState:UIControlStateNormal];
            [_readImage setTitle:Localized(@"JX_Read") forState:UIControlStateNormal];
//            _readImage.image = [UIImage imageNamed:@"read"];
        }
        
        if (_readImage) {
            // 适配未读/已读 英文版
            CGSize size = [_readImage.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_readImage.titleLabel.font}];
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x-size.width-INSETS*0.5, _readImage.frame.origin.y, size.width, _readImage.frame.size.height);
        }

        [_readImage setImage:nil forState:UIControlStateNormal];
        _readImage.hidden = NO;
        if (([_msg.type intValue] == kWCMessageTypeText || [_msg.type intValue] == kWCMessageTypeImage || [_msg.type intValue] == kWCMessageTypeVoice || [_msg.type intValue] == kWCMessageTypeVideo || [_msg.type intValue] == kWCMessageTypeReply)) {
            _burnImage.hidden = ![_msg.isReadDel boolValue];
        }else {
            _burnImage.hidden = YES;
        }
    }
    
    if (self.isCourse) {
        _sendFailed.hidden = YES;
        _readImage.hidden = YES;
        _burnImage.hidden = YES;
    }
}

- (void)sendMessageToUser {
    // 消息已经送达
    
}


- (void)drawReadPersons:(int)num{
    _readNum.text = [NSString stringWithFormat:@"%d%@",num,Localized(@"JXLiveVC_countPeople")];
    
    CGSize size = [_readNum.text sizeWithAttributes:@{NSFontAttributeName:_readNum.font}];
    _readNum.frame = CGRectMake(_readView.frame.size.width - size.width-10, _readNum.frame.origin.y, size.width+10, _readNum.frame.size.height);
}

-(void)drawIsReceive{
    int n = [_msg.isReceive intValue];
    _wait.hidden = n!=0;
    if(_wait.hidden)
        [_wait stopAnimating];
    else
        [_wait startAnimating];
    
    if(n == transfer_status_no){
        _sendFailed.hidden = NO;
        _readImage.hidden = YES;
    }else{
        _sendFailed.hidden = YES;
        _readImage.hidden = NO;
    }
    
    if (self.isCourse) {
        _sendFailed.hidden = YES;
        _readImage.hidden = YES;
    }
}

-(void)notifyDrawIsReceive:(NSNotification*)sender{
    if(sender.object == self.msg)
        [self drawIsReceive];
}

- (void)updateLoadFileProgress:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    NSProgress *progress = [dict objectForKey:@"uploadProgress"];
    self.fileDict = [dict objectForKey:@"file"];
    self.loadProgress = progress.fractionCompleted;
    NSLog(@"-------------- %f--- %@  ---  %@",self.loadProgress,self.fileDict, self.msg.messageId);
    
    [self updateFileLoadProgress];
}

- (void)updateFileLoadProgress {
}

-(void)didTouch:(UIButton*)button{
}

//回应交换电话后更新按钮状态
- (void)setAgreeRefuseBtnStatusAfterReply{
    
}

// 设置图片外框
//djkbug
- (void)setMaskLayer:(UIImageView *)imageView {
    UIImage *maskImage = nil;
    if(self.msg.isMySend){
        maskImage = [[UIImage imageNamed:@"chat_bg_blue"] stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
        
    }else{
        maskImage = [[UIImage imageNamed:@"chat_bg_white"] stretchableImageWithLeftCapWidth:stretch topCapHeight:stretch];
        
    }
    
    UIImageView *maskImageView = [[UIImageView alloc] initWithImage:maskImage];
    maskImageView.userInteractionEnabled = YES;
    
    maskImageView.frame = imageView.bounds;
    imageView.layer.mask = maskImageView.layer;

    //djk改图片不显示bug   非常重要
    
    CGSize maskSize =CGSizeMake(imageView.bounds.size.width,         imageView.bounds.size.height);
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, maskSize.width, maskSize.height);
     
    [maskLayer setContents:(id)maskImage.CGImage];
    [maskLayer setContentsScale:maskImage.scale];
    [maskLayer setContentsCenter:CGRectMake(((maskImage.size.width/2) - 1)/maskImage.size.width, ((maskImage.size.height/1.5) - 1)/maskImage.size.height, 1 / maskImage.size.width, 1 / maskImage.size.height)];
        
    imageView.layer.mask = maskLayer;
    imageView.layer.masksToBounds = YES;

}

// 获取cell 高度
+ (float) getChatCellHeight:(JXMessageObject *)msg {

    return 0;
}

#pragma mark ------------------设置plasticPopupMenu位置---------------------
- (void)doLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (self.isSelectMore) {
        return;
    }
    if(longPress.state == UIGestureRecognizerStateBegan)
    {
        
        [self creatLongPressItems];
        
        if (longPress.view == self.contentView) {
            CGPoint touchPoint = [longPress locationInView:self.contentView];
            BOOL iscontain = CGRectContainsPoint(self.headImage.frame, touchPoint);
            if (iscontain) {
                //@
                if ([self.msg.fromUserId isEqualToString:MY_USER_ID]) {
                    return;
                }
                [g_notify postNotificationName:kCellLongGesHeadImageNotification object:self.msg];
                return;
            }
        }
        
        CGRect frame = [self.contentView convertRect:self.bubbleBg.frame toView:self.superview.superview.superview];
     
        UIView *view = self.superview.superview;
        CGFloat y = frame.origin.y;
        if (view.frame.origin.y > 0) {
            y = frame.origin.y - 64;
        }
        
        
        //判断是否自己发送的
        if (!self.msg.isMySend) {
//            [self.plasticPopupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y, self.bubbleBg.frame.size.width + 120, 35) animated:YES];
            [self.popupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y, self.bubbleBg.frame.size.width + 120, 35) animated:YES];
        }else{

//            [self.plasticPopupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y,(self.bubbleBg.frame.origin.x +  self.bubbleBg.frame.size.width /2)*2, 35) animated:YES];
            [self.popupMenu showInView:self.superview.superview targetRect:CGRectMake(self.frame.origin.x, y,(self.bubbleBg.frame.origin.x +  self.bubbleBg.frame.size.width /2)*2, 35) animated:YES];
        }
    }
}

- (void)creatLongPressItems
{
    
    if ([self.msg.type intValue] == kWCMessageTypeRemind || self.isSelectMore) {
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    if ([self.msg.type intValue] == kWCMessageTypeVoice) {
        
        NSString *playTitle;
        BOOL flag = [g_default boolForKey:kChatVCMessageAudioIsNotPlayback];
        if(!flag) {
            //听筒播放
            playTitle = Localized(@"JX_HandsetPlayback");
        }else {
            //扬声器播放
            playTitle = Localized(@"JX_SpeakerPlay");
        }
        
        QBPopupMenuItem *item9 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", playTitle] target:self action:@selector(audioPlayChangeAction)];
        [items addObject:item9];
    }

    
    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_Delete")] target:self action:@selector(deleteAction)];
    [items addObject:item4];
    
    if (self.isCourse) {
        QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
        popupMenu.highlightedColor = [UIColor lightGrayColor];
        popupMenu.height = 35;
        self.popupMenu = popupMenu;

//        QBPlasticPopupMenu *plasticPopupMenu = [QBPlasticPopupMenu popupMenuWithItems:items];
//        plasticPopupMenu.height = 35;
//        self.plasticPopupMenu = plasticPopupMenu;
        return;
    }
    if (![self.msg.isReadDel boolValue]) {
        QBPopupMenuItem *item8 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ",Localized(@"JX_Reply")] target:self action:@selector(replyMsg)];
        [items addObject:item8];
    }

    if (([self.msg.type intValue] == kWCMessageTypeText || [self.msg.type intValue] == kWCMessageTypeReply) && ![self.msg.isReadDel boolValue]) {
        QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_Copy")] target:self action:@selector(myCopy)];
        [items addObject:item1];
    }
    if ([self.msg.type intValue] == kWCMessageTypeText || [self.msg.type intValue] == kWCMessageTypeReply || [self.msg.type intValue] == kWCMessageTypeImage || [self.msg.type intValue] == kWCMessageTypeVoice || [self.msg.type intValue] == kWCMessageTypeLocation || [self.msg.type intValue] == kWCMessageTypeGif || [self.msg.type intValue] == kWCMessageTypeVideo || [self.msg.type intValue] == kWCMessageTypeAudio || [self.msg.type intValue] == kWCMessageTypeCard || [self.msg.type intValue] == kWCMessageTypeFile || [self.msg.type intValue] == kWCMessageTypeLink || [self.msg.type intValue] == kWCMessageTypeShare || [self.msg.type intValue] == kWCMessageTypeSystemImage1 || [self.msg.type intValue] == kWCMessageTypeSystemImage2) {
        if (![self.msg.isReadDel boolValue]) {
            QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_Relay")] target:self action:@selector(relayAction)];
            [items addObject:item2];
        }
        
        if (self.isWithdraw) {
            // 自己发的5分钟之内可以撤回
//            NSDate * today = [NSDate date];
//            long long now = [today timeIntervalSince1970];
//            long distance = now - [self.msg.timeSend timeIntervalSince1970];
//            long distanceM = distance / 60;
//            if (distanceM < 5) {
            QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_Withdraw")] target:self action:@selector(withdrawAction)];
            [items addObject:item3];
//            }
        }
    }
    
    if ([self.msg.type intValue] == kWCMessageTypeImage || [self.msg.type intValue] == kWCMessageTypeVideo || [self.msg.type intValue] == kWCMessageTypeFile || [self.msg.type intValue] == kWCMessageTypeVoice || [self.msg.type intValue] == kWCMessageTypeText || [self.msg.type intValue] == kWCMessageTypeReply) {
        if ([self.msg.type intValue] == kWCMessageTypeImage && ![self.msg.isReadDel boolValue]) {
            QBPopupMenuItem *item5 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_AddToTheExpression")] target:self action:@selector(favoritEmojiAction)];
            [items addObject:item5];
        }
        if (![self.msg.isReadDel boolValue] && [self.msg.isEncrypt intValue] != 3) {
        QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_Collection")] target:self action:@selector(favoritAction)];
        [items addObject:item6];
        }
        
    }
    
    if ([self.msg.type intValue] != kWCMessageTypeRemind) {
        
        QBPopupMenuItem *item7 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", Localized(@"JX_Multiselect")] target:self action:@selector(selectMoreAction)];
        [items addObject:item7];
    }
    
    if (self.msg.isMySend && !self.isNotRecord) {
        NSString *str;
        if (self.isShowRecordCourse && [self.msg.isReadDel intValue] != 1) {
            if (![self.chatCellDelegate getRecording]) {
                str = Localized(@"JX_StartRecording");
                QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:str target:self action:@selector(recordAction)];
                [items addObject:item6];
            }else if (self.indexNum >= [self.chatCellDelegate getRecordStarNum]) {
                str = Localized(@"JX_StopRecording");
                QBPopupMenuItem *item6 = [QBPopupMenuItem itemWithTitle:[NSString stringWithFormat:@"  %@  ", str] target:self action:@selector(recordAction)];
                [items addObject:item6];
            }
        }
    }
    
    
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
    popupMenu.highlightedColor = [UIColor lightGrayColor];
    popupMenu.height = 35;
    self.popupMenu = popupMenu;

//    QBPlasticPopupMenu *plasticPopupMenu = [QBPlasticPopupMenu popupMenuWithItems:items];
//    plasticPopupMenu.height = 35;
//    self.plasticPopupMenu = plasticPopupMenu;
    
}

// 转发
- (void)relayAction {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:RelayIndexNum:)]) {
        [self.chatCellDelegate chatCell:self RelayIndexNum:self.indexNum];
    }
}

// 撤回
- (void)withdrawAction {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:withdrawIndexNum:)]) {
        [self.chatCellDelegate chatCell:self withdrawIndexNum:self.indexNum];
    }
}

// 收藏
- (void)favoritAction{
    int msgType = [self.msg.type intValue];
    CollectType collectType = 0;
          if (msgType == kWCMessageTypeImage) {
        collectType = CollectTypeImage;
    }else if (msgType == kWCMessageTypeVideo) {
        collectType = CollectTypeVideo;
    }else if (msgType == kWCMessageTypeFile) {
        collectType = CollectTypeFile;
    }else if (msgType == kWCMessageTypeVoice) {
        collectType = CollectTypeVoice;
    }else if (msgType == kWCMessageTypeText) {
        collectType = CollectTypeText;
    }else {
        
    }
    if (collectType == 0) {
        return;
    }
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:favoritIndexNum:type:)]) {
        [self.chatCellDelegate chatCell:self favoritIndexNum:self.indexNum type:collectType];
    }
}

-(void)favoritEmojiAction{
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:favoritIndexNum:type:)]) {
        [self.chatCellDelegate chatCell:self favoritIndexNum:self.indexNum type:CollectTypeEmoji];
    }
}
// 回复
- (void)replyMsg {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:replyIndexNum:)]) {
        [self.chatCellDelegate chatCell:self replyIndexNum:self.indexNum];
    }
}

// 删除
- (void)deleteAction {
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:deleteIndexNum:)]) {
        [self.chatCellDelegate chatCell:self deleteIndexNum:self.indexNum];
    }
}

// 多选
- (void)selectMoreAction {
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:selectMoreIndexNum:)]) {
        [self.chatCellDelegate chatCell:self selectMoreIndexNum:self.indexNum];
    }
}
// 多选选择
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:checkBoxSelectIndexNum:isSelect:)]) {
        [self.chatCellDelegate chatCell:self checkBoxSelectIndexNum:self.indexNum isSelect:checked];
    }
}

// 录制
- (void)recordAction {
    if ([self.chatCellDelegate getRecording]) {
        if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:stopRecordIndexNum:)]) {
            [self.chatCellDelegate chatCell:self stopRecordIndexNum:self.indexNum];
        }
    }else {
        if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:startRecordIndexNum:)]) {
            [self.chatCellDelegate chatCell:self startRecordIndexNum:self.indexNum];
            
        }
    }
    [self creatLongPressItems];
}

// 语音播放转换
- (void)audioPlayChangeAction {
    
    if ([self.chatCellDelegate respondsToSelector:@selector(chatCell:audioPlayChangeIndexNum:)]) {
        [self.chatCellDelegate chatCell:self audioPlayChangeIndexNum:self.indexNum];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)dealloc{
    NSLog(@"JXBaseChatCell.delloc");
//    [super dealloc];
//    [_bubbleBg release];
    _bubbleBg = nil;
}

@end
