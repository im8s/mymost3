//
//  JXQRCodeViewController.m
//  shiku_im
//
//  Created by 1 on 17/9/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXQRCodeViewController.h"
#import "QRImage.h"
#import "JXRelayVC.h"

@interface JXQRCodeViewController ()

@property (nonatomic, strong) UIImageView * qrImageView;

@property (nonatomic, strong) UIButton * saveButton;

@property (nonatomic, strong) UIView *baseView;



@end

@implementation JXQRCodeViewController

-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.title = Localized(@"JXQR_QRImage");
        self.isGotoBack = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self.tableHeader addSubview:self.saveButton];
    
//    NSMutableDictionary * qrDict = [NSMutableDictionary dictionary];
    NSMutableString * qrStr = [NSMutableString stringWithFormat:@"%@?action=",g_config.website];
    if(self.type == QRUserType)
        [qrStr appendString:@"user"];
//        [qrDict setObject:@"user" forKey:@"action"];
    else if(self.type == QRGroupType)
        [qrStr appendString:@"group"];
//        [qrDict setObject:@"group" forKey:@"action"];
    if(self.account != nil)
        [qrStr appendFormat:@"&shikuId=%@",self.account];
//        [qrDict setObject:self.userId forKey:@"shiku"];
    
    
//     = [[[SBJsonWriter alloc] init] stringWithObject:qrDict];
    UIImageView *imageView = [[UIImageView alloc] init];

    __weak __typeof(self) weakSelf = self;
    if (self.type == QRGroupType) {
//        [g_server roomHeadImage:self.roomJId roomId:self.userId getHeadHandler:^(BOOL isRoom, UIImage *image, NSError *error) {
//            [weakSelf setupViewWithImage:image qrStr:qrStr];
//        }];
        [g_server getRoomHeadImageSmall:self.roomJId roomId:self.userId imageView:imageView getHeadHandler:^(BOOL isRoom, UIImage * _Nullable image, NSError * _Nullable error) {
            [weakSelf setupViewWithImage:image qrStr:qrStr];
        }];
    }else {
        [g_server getHeadImageLarge:self.userId userName:self.nickName imageView:imageView getHeadHandler:^(BOOL isRoom, UIImage * _Nullable image, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误");
            }
            [weakSelf setupViewWithImage:image qrStr:qrStr];
        }];
    }

}

- (void)setupViewWithImage:(UIImage *)image  qrStr:(NSString *)qrStr {
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, JX_SCREEN_WIDTH-30, 433)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    [self.tableBody addSubview:self.baseView];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    icon.image = image;
    icon.layer.cornerRadius = 5;
    icon.layer.masksToBounds = YES;
    [self.baseView addSubview:icon];
    
    CGSize size = [self.nickName sizeWithAttributes:@{NSFontAttributeName:SYSFONT(17)}];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame)+15, 41, size.width, size.height)];
    name.text = self.nickName;
    [self.baseView addSubview:name];
    
    
    UIImage * qrImage = [QRImage qrImageForString:qrStr imageSize:300 logoImage:image logoImageSize:70];
    _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(39, CGRectGetMaxY(icon.frame)+33, self.baseView.frame.size.width-39*2, self.baseView.frame.size.width-39*2)];
    _qrImageView.image = qrImage;
    [self.baseView addSubview:_qrImageView];
    
    
    NSString *tintStr;
    if (self.type == QRUserType) {
        tintStr = Localized(@"JX_ScanQrAddFriend");
        
        UIImageView *sex = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame)+15, 0, 14, 14)];
        sex.image = [UIImage imageNamed:@""];
        [self.baseView addSubview:sex];
        sex.center = CGPointMake(sex.frame.origin.x, name.center.y);
        if ([self.sex intValue] == 0) {// 女
            sex.image = [UIImage imageNamed:@"basic_famale"];
        }else {// 男
            sex.image = [UIImage imageNamed:@"basic_male"];
        }
        
    }else {
        tintStr = Localized(@"JX_ScanQrJoinRoom");
    }
    
    UILabel *tintLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_qrImageView.frame)+20, self.baseView.frame.size.width, 14)];
    tintLab.text = tintStr;
    tintLab.textAlignment = NSTextAlignmentCenter;
    tintLab.font = SYSFONT(14);
    tintLab.textColor = HEXCOLOR(0x999999);
    [self.baseView addSubview:tintLab];
    
    self.baseView.frame = CGRectMake(self.baseView.frame.origin.x, self.baseView.frame.origin.y, self.baseView.frame.size.width, CGRectGetMaxY(tintLab.frame) + 20);
    
    CGFloat w = (JX_SCREEN_WIDTH-15*3)/2;
    
    UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.baseView.frame)+30, w, 40)];
    [save setTitle:Localized(@"HBImageScroller_SavePhone") forState:UIControlStateNormal];
    save.layer.cornerRadius = 7.f;
    save.layer.masksToBounds = YES;
    save.backgroundColor = [UIColor whiteColor];
    [save.titleLabel setFont:SYSFONT(16)];
    [save setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:save];
    
    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(save.frame)+15, CGRectGetMaxY(self.baseView.frame)+30, w, 40)];
    [share setTitle:Localized(@"JX_small_share") forState:UIControlStateNormal];
    share.layer.cornerRadius = 7.f;
    share.layer.masksToBounds = YES;
    share.backgroundColor = THEMECOLOR;
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [share setBackgroundImage:img forState:UIControlStateHighlighted];
    [share.titleLabel setFont:SYSFONT(16)];
    [share addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableBody addSubview:share];

}

-(void)saveButtonAction{
    UIImage * image = [UIImage imageWithView:self.baseView];
    [self saveToLibary:image];
}

- (void)shareButtonAction {
    NSString *name = @"jpg";

    NSString *file = [FileInfo getUUIDFileName:name];
    [g_server saveImageToFile:[UIImage imageWithView:self.baseView] file:file isOriginal:YES];

    [g_server uploadFile:file validTime:nil messageId:nil toView:self];
    
}


-(void)saveToLibary:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        [g_server showMsg:Localized(@"JX_SaveSuessed") delay:1.5f];
    }else{
        [g_App showAlert:error.description];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIButton *)saveButton{
    if(!_saveButton){
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.frame = CGRectMake(JX_SCREEN_WIDTH-15-18, JX_SCREEN_TOP - 15-18, 18, 18);
        [_saveButton setImage:[UIImage imageNamed:@"saveLibary_black"] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];

    if ([aDownload.action isEqualToString:act_UploadFile]) {
        NSDictionary* p = nil;
        if([(NSArray *)[dict objectForKey:@"images"] count]>0)
            p = [[dict objectForKey:@"images"] objectAtIndex:0];
      

        JXMessageObject *msg = [[JXMessageObject alloc] init];
        msg.fromUserId = MY_USER_ID;
        msg.fromUserName = MY_USER_NAME;
        msg.type = [NSNumber numberWithInt:kWCMessageTypeImage];
        msg.content  = [p objectForKey:@"oUrl"];
        msg.timeSend     = [NSDate date];
        msg.isSend       = [NSNumber numberWithInt:transfer_status_ing];
        msg.isRead       = [NSNumber numberWithBool:NO];
        msg.isUpload     = [NSNumber numberWithBool:NO];

        [msg setMsgId];
        
        JXRelayVC *vc = [[JXRelayVC alloc] init];
        vc.relayMsgArray = [NSMutableArray arrayWithObject:msg];
        [g_navigation pushViewController:vc animated:YES];
    }
    
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];

    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    
    [_wait stop];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


@end
