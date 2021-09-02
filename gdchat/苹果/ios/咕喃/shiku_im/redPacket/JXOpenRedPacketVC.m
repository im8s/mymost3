//
//  JXOpenRedPacketVC.m
//  shiku_im
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXOpenRedPacketVC.h"
#import "JXredPacketDetailVC.h"
@interface JXOpenRedPacketVC ()

@end

@implementation JXOpenRedPacketVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [UIColor clearColor];
        _wait = [ATMHud sharedInstance];
        _pSelf = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    _wait = [ATMHud sharedInstance];
    
    self.blackBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.blackBgView.backgroundColor = [UIColor blackColor];
    self.blackBgView.alpha = 0.15;
    [self.view addSubview:self.blackBgView];
    
    self.centerRedPView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 288)];
    self.centerRedPView.center = self.view.center;
    [self.view addSubview:self.centerRedPView];
    
    UIImageView *redBgImage = [[UIImageView alloc] initWithFrame:self.centerRedPView.bounds];
    redBgImage.image = [UIImage imageNamed:Localized(@"JX_BigRed")];
    [self.centerRedPView addSubview:redBgImage];
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 48, 48)];
    self.headerImageView.center = CGPointMake(self.centerRedPView.frame.size.width / 2, self.headerImageView.center.y);
    self.headerImageView.image = [UIImage imageNamed:@"avatar_normal"];
    [self.centerRedPView addSubview:self.headerImageView];
    
    self.fromUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerImageView.frame) + 7, self.centerRedPView.frame.size.width, 21)];
    self.fromUserLabel.textAlignment = NSTextAlignmentCenter;
    self.fromUserLabel.text = Localized(@"JX_LuckyStar");
    self.fromUserLabel.textColor = [UIColor whiteColor];
    self.fromUserLabel.font = [UIFont systemFontOfSize:15.0];
    [self.centerRedPView addSubview:self.fromUserLabel];
    
    self.greetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.fromUserLabel.frame) + 8, self.centerRedPView.frame.size.width, 21)];
    self.greetLabel.textAlignment = NSTextAlignmentCenter;
    self.greetLabel.text = Localized(@"JX_KungHeiFatChoi");
    self.greetLabel.textColor = [UIColor whiteColor];
    self.greetLabel.font = [UIFont systemFontOfSize:14.0];
    [self.centerRedPView addSubview:self.greetLabel];
    
    self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.greetLabel.frame) + 12, 122, 45)];
    self.moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyLabel.center = CGPointMake(self.centerRedPView.frame.size.width / 2, self.moneyLabel.center.y);
    self.moneyLabel.text = @"100.01";
    self.moneyLabel.textColor = [UIColor yellowColor];
    self.moneyLabel.font = [UIFont systemFontOfSize:32.0];
    [self.centerRedPView addSubview:self.moneyLabel];
    
    UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.moneyLabel.frame), self.moneyLabel.frame.origin.y + 15, 17, 16)];
    yuan.textAlignment = NSTextAlignmentCenter;
    yuan.text = Localized(@"JX_ChinaMoney");
    yuan.textColor = [UIColor blackColor];
    yuan.font = [UIFont systemFontOfSize:13.0];
    [self.centerRedPView addSubview:yuan];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.centerRedPView.frame.size.width - 30, 0, 30, 30)];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerRedPView addSubview:closeBtn];
    
    UIButton *detailBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.centerRedPView.frame.size.height - 53, self.centerRedPView.frame.size.width, 30)];
    [detailBtn setTitle:Localized(@"JX_ShowDetail") forState:UIControlStateNormal];
    detailBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [detailBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(toRedPacketDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerRedPView addSubview:detailBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self shakeToShow:_centerRedPView];
    
    //解析数据,获取红包详情
    _packetObj = [JXPacketObject getPacketObject:_dataDict];
    _packetListArray = [JXGetPacketList getPackList:_dataDict];
    
    [self setViewSize];
    [self setViewData];
}

-(void)setViewSize{
    _headerImageView.layer.cornerRadius = 24;
    _headerImageView.clipsToBounds = YES;
}

-(void)setViewData{
    [g_server getHeadImageSmall:_packetObj.userId userName:_packetObj.userName imageView:_headerImageView getHeadHandler:nil];
    _fromUserLabel.text = _packetObj.userName;
    _greetLabel.text = _packetObj.greetings;
//    //1是普通红包，2是手气红包
//    if (_packetObj.type == 1) {
//        _moneyLabel.text = [NSString stringWithFormat:@"%ld",_packetObj.money];
//    }else if (_packetObj.type == 2){
    for (JXGetPacketList * listObj in _packetListArray) {
        NSString * userIdStr = [NSString stringWithFormat:@"%@",listObj.userId];
        if ([MY_USER_ID isEqualToString:userIdStr]) {
            _moneyLabel.text = [NSString stringWithFormat:@"%.2f",listObj.money];
        }
//        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self quitOutAnimate];
}
- (IBAction)toRedPacketDetail:(id)sender {
    JXredPacketDetailVC * redPacketDetailVC = [[JXredPacketDetailVC alloc]init];
    redPacketDetailVC.dataDict = [[NSDictionary alloc]initWithDictionary:self.dataDict];
//    [g_window addSubview:redPacketDetailVC.view];
    [g_navigation pushViewController:redPacketDetailVC animated:YES];
    [self quitOutAnimate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)quitOutAnimate{
    _blackBgView.alpha = 0.0;
    [self viewControllerSmallAnimation:self];
}

- (void)doRemove{
    [self.view removeFromSuperview];
    _pSelf = nil;
}

- (void)dealloc {
//    [_headerImageView release];
//    [_fromUserLabel release];
//    [_greetLabel release];
//    [_moneyLabel release];
//    [_centerRedPView release];
//    [_blackBgView release];
//    [super dealloc];
}

- (void)shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}


- (void)viewControllerSmallAnimation:(UIViewController *)aView{
    [UIView beginAnimations:@"doViewSmall" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:aView];
    [UIView setAnimationDidStopSelector:@selector(doRemove)];
    CGAffineTransform newTransform =  CGAffineTransformScale(aView.view.transform, 0.1, 0.1);
    [aView.view setTransform:newTransform];
    [UIView commitAnimations];
}

@end
