//
//  JXProgressVC.m
//  shiku_im
//
//  Created by Apple on 16/10/10.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXProgressVC.h"

@interface JXProgressVC ()

@end

@implementation JXProgressVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.title = Localized(@"JXProgressVC_SnyFriend");
        self.isGotoBack = YES;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        [self createHeadAndFoot];
        [self createProgressView];
        [self customView];
        if (self.dataArray.count <= 300) {
            
            [self dealWithFriendData:_dataArray];
        }
        
//        dispatch_async(dispatch_get_global_queue(1, 0), ^{
//        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self dealWithFriendData:_dataArray];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
    
}

- (void)customView{
    //按钮
//    _comBtn = [[UIButton alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 50, 300, 100, 30)];
//    _comBtn.layer.cornerRadius = 5;
//    _comBtn.clipsToBounds = YES;
//    [_comBtn setTitle:Localized(@"JXProgressVC_SnyNow") forState:UIControlStateNormal];
//    [_comBtn setBackgroundImage:[UIImage imageNamed:@"feaBtn_backImg_sel"] forState:UIControlStateNormal];
//    _comBtn.titleLabel.font = g_factory.font15;
//    [_comBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_comBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    _comBtn.tag = 1;
//    [self.tableBody addSubview:_comBtn];
//    [_comBtn release];
    //本地与服务器好友数量
//    _dbCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 100, 160, 200, 30)];
//    _dbCountLabel.text = [NSString stringWithFormat:@"%@%ld",Localized(@"JXProgressVC_LFriendCount"),_dbFriends];
//    _dbCountLabel.font = [UIFont systemFontOfSize:13];
//    _dbCountLabel.textAlignment = NSTextAlignmentCenter;
//    [self.tableBody addSubview:_dbCountLabel];
//    [_dbCountLabel release];
    
    _sysCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2 - 100, 200, 200, 30)];
    _sysCountLabel.text = [NSString stringWithFormat:@"%@%lu",Localized(@"JXProgressVC_SFriendCount"),(unsigned long)[_dataArray count]];
    _sysCountLabel.font = [UIFont systemFontOfSize:13];
    _sysCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.tableBody addSubview:_sysCountLabel];
//    [_sysCountLabel release];
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 1) {
        [self dealWithFriendData:_dataArray];
    }else if (btn.tag == 2){
        [self actionQuit];
    }
}

-(void)createProgressView{
    //ProgressView
    UIView * centerView = [[UIView alloc]initWithFrame:CGRectMake(50, 50, JX_SCREEN_WIDTH - 100, 80)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.layer.cornerRadius = 10;
    [self.tableBody addSubview:centerView];
//        [centerView release];
    
//    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, JX_SCREEN_WIDTH - 100, 25)];
//    _titleLabel.text = @"是否同步好友";
//    _titleLabel.textAlignment = NSTextAlignmentCenter;
//    _titleLabel.font = [UIFont systemFontOfSize:13];
//    [centerView addSubview:_titleLabel];
//    [_titleLabel release];
//    
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(5, 40, JX_SCREEN_WIDTH - 110, 5)];
    [centerView addSubview:_progressView];
//    [_progressView release];
    
    
    _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, JX_SCREEN_WIDTH - 100, 20)];
    _progressLabel.font = [UIFont systemFontOfSize:12];
    _progressLabel.text = @"";
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:_progressLabel];
//    [_progressLabel release];
}

-(void)dealWithFriendData:(NSArray *)array1{
//    if (_dbFriends == [array1 count]) {
////        [g_App showAlert:Localized(@"JXAlert_SynchFirend")];
////        [JXMyTools showTipView:Localized(@"JXAlert_SynchFirend")];
//        [_comBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
//        _comBtn.tag = 2;
//        [self actionQuit];
//        return;
//    }
   
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_wait start:Localized(@"JXProgressVC_SnyFriend")];
//    });
    
//    _titleLabel.text = @"正在同步好友";
    
    // 删除本地数据库好友 重新插入
//    [[JXUserObject sharedInstance] deleteAllUser];
    
    //遍历服务器返回的好友
    _progressView.progress = 0.0;
    NSMutableArray *userIds = [NSMutableArray array];
    for (int i = 0; i< [array1 count]; i++) {
        NSDictionary * dict = array1[i];
        JXUserObject * user = [[JXUserObject alloc]init];
        //数据转为一个好友对象
        [user getDataFromDictSmall:dict];
        //访问数据库是否存在改好友，没有则写入数据库
        if (user.userId.length > 5) {
            [userIds addObject:user.userId];
            [user insertFriend];
        }
//        [user release];
        
        [_progressView setProgress:((i+1)*1.0)/([array1 count]*1.0) animated:YES];
        _progressLabel.text = [NSString stringWithFormat:@"%d/%lu",i+1,(unsigned long)[array1 count]];
        NSLog(@"%@",_progressLabel.text);
        [[NSRunLoop currentRunLoop]runUntilDate:[NSDate distantPast]];//重要
    }
    
    [_wait start:Localized(@"JXProgressVC_SnyFriend")];
    
    // 删除服务器上已经删除的

    NSArray *arr = [g_server.myself fetchAllFriendsOrNotFromLocal];
    for (NSInteger i = 0; i < arr.count; i ++) {
        JXUserObject *locUser = arr[i];
        //        BOOL flag = NO;
        //        for (NSInteger j = 0; j < array1.count; j ++) {
        //            NSDictionary * dict = array1[j];
        //            JXUserObject * serverUser = [[JXUserObject alloc]init];
        //            //数据转为一个好友对象
        //            [serverUser getDataFromDictSmall:dict];
        //            if ([locUser.userId isEqualToString:serverUser.userId]) {
        //                flag = YES;
        //                break;
        //            }
        //        }
        //
        //        if (!flag) {
        //            [locUser delete];
        //        }
        
        if (![userIds containsObject:locUser.userId] && [locUser.status intValue] == friend_status_friend) {
            [locUser delete];
        }
        
    }
    
//    _dbFriends = [array1 count];
////    _titleLabel.text = @"同步完成";
//    _dbCountLabel.text = _dbCountLabel.text = [NSString stringWithFormat:@"%@%ld",Localized(@"JXProgressVC_LFriendCount"),[array1 count]];
//    _sysCountLabel.text = [NSString stringWithFormat:@"%@%ld",Localized(@"JXProgressVC_SFriendCount"),[array1 count]];
//    [_comBtn setTitle:Localized(@"JX_Finish") forState:UIControlStateNormal];
//    _comBtn.tag = 2;
    
    [[JXXMPP sharedInstance] login];
//    [[JXXMPP sharedInstance] performSelector:@selector(login) withObject:nil afterDelay:1];//1秒后执行xmpp登录
    [g_notify postNotificationName:kXMPPNewFriendNotifaction object:nil];
    [g_notify postNotificationName:kChatViewDisappear object:nil];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_wait stop];
        [self actionQuit];
//    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
