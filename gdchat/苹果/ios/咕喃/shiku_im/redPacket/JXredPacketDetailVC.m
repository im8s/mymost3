//
//  JXredPacketDetailVC.m
//  shiku_im
//
//  Created by Apple on 16/8/30.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXredPacketDetailVC.h"
#import "JXRPacketListCell.h"
#import "JXRedPacketListVC.h"

@interface JXredPacketDetailVC () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *replyLab;

@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *replayTitle;
@property (nonatomic, strong) UITextView *replayTextView;
@property (nonatomic, assign) int replayNum;

@property (nonatomic, strong) NSString *replyContent;
@property (nonatomic, strong) NSString *money;

@property (nonatomic, strong) UIColor *watermarkColor;

@property (nonatomic, strong) UILabel *tintLab;

@end

@implementation JXredPacketDetailVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.heightHeader = 0;
        self.heightFooter = 0;
        self.isGotoBack   = YES;
       
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self createHeadAndFoot];
    
    self.watermarkColor = [UIColor lightGrayColor];
    
    //获取数据
    _packetObj = [JXPacketObject getPacketObject:_dataDict];
    _OpenMember = [self arraySortDESC:[JXGetPacketList getPackList:_dataDict]];
    
    NSNumber * typeNum = _dataDict[@"packet"][@"type"];
    switch ([typeNum intValue]) {
        case 1:
            self.title = Localized(@"JX_UsualGift");
            break;
        case 2:
            self.title = Localized(@"JX_LuckGift");
            break;
        case 3:
            self.title = Localized(@"JX_MesGift");
            break;
        default:
            break;
    }
    
    self.replyContent = [NSString string];
    for (JXGetPacketList * memberObj in _OpenMember) {
        if ([memberObj.userId intValue] == [MY_USER_ID intValue]) {
            self.replyContent = memberObj.reply;
            self.money = [NSString stringWithFormat:@"%.2f %@",memberObj.money,Localized(@"JX_ChinaMoney")];
        }
    }

    _table.backgroundColor = [UIColor whiteColor];
    _table.allowsSelection = NO;
    self.isShowFooterPull = NO;
    
    self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self createCustomView];
    _table.frame = CGRectMake(0, CGRectGetMaxY(_contentView.frame), JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT - CGRectGetMaxY(_contentView.frame));
    
//    _getPacketListTBV.delegate = self;
//    _getPacketListTBV.dataSource = self;
//    _getPacketListTBV.separatorStyle = UITableViewCellSeparatorStyleNone;
//    //设置tableview不可被点击
//    _getPacketListTBV.allowsSelection = NO;
//    _wait = [ATMHud sharedInstance];
    
    [self setViewSize];
    [self setViewData];
    
    self.isShowHeaderPull = NO;
    self.isShowFooterPull = NO;
    
}


-(void)createCustomView{
    _headImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 150)];
    _headImgV.image = [UIImage imageNamed:@"redPacket"];
    _headImgV.userInteractionEnabled = YES;
    [self.view addSubview:_headImgV];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 46, 46, 46)];
    [closeBtn setBackgroundImage:[[UIImage imageNamed:@"title_back_black_big"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headImgV addSubview:closeBtn];

    
    UIButton *listBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 62-15, JX_SCREEN_TOP - 32, 62, 20)];
    [listBtn setTitle:Localized(@"JX_RedPacketRecord") forState:UIControlStateNormal];
    listBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [listBtn addTarget:self action:@selector(listBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_headImgV addSubview:listBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP - 32, JX_SCREEN_WIDTH, 20)];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = Localized(@"JX_ShikuRedPacket");
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:18.0];
    [_headImgV addSubview:title];
    
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headImgV.frame), JX_SCREEN_WIDTH, self.money.length > 0 ? 210 : 150)];
    _contentView.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self.view addSubview:_contentView];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -34, 68, 68)];
    _headerImageView.center = CGPointMake(_headImgV.frame.size.width / 2, _headerImageView.center.y);
    _headerImageView.image = [UIImage imageNamed:@"avatar_normal"];
    _headerImageView.userInteractionEnabled = YES;
    [_contentView addSubview:_headerImageView];
    
//    _totalMoneyLabel = [UIFactory createLabelWith:CGRectMake(CGRectGetMaxX(_headerImageView.frame) +8, CGRectGetMinY(_headerImageView.frame), 130, 27) text:@"共100.01元"];
//    _totalMoneyLabel.textColor = [UIColor yellowColor];
//    _totalMoneyLabel.font = g_factory.font20;
//    [_headImgV addSubview:_totalMoneyLabel];
    
    _fromUserLabel = [UIFactory createLabelWith:CGRectMake(0, CGRectGetMaxY(_headerImageView.frame) + 10, _contentView.frame.size.width, 22) text:Localized(@"JX_IsRedEnvelopes")];
    _fromUserLabel.textColor = HEXCOLOR(0x323232);
    _fromUserLabel.textAlignment = NSTextAlignmentCenter;
    _fromUserLabel.font = g_factory.font15;
    [_contentView addSubview:_fromUserLabel];
    
    _greetLabel = [UIFactory createLabelWith:CGRectMake(0, CGRectGetMaxY(_fromUserLabel.frame) + 5, _contentView.frame.size.width, 22) text:Localized(@"JX_KungHeiFatChoi")];
    _greetLabel.textColor = HEXCOLOR(0x323232);
    _greetLabel.textAlignment = NSTextAlignmentCenter;
    _greetLabel.font = g_factory.font15;
    [_contentView addSubview:_greetLabel];
    
    if (self.money.length > 0) {
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.money];
        [attStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:50]} range:NSMakeRange(0, self.money.length-1)];
        UILabel *moneyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_greetLabel.frame) + 10, JX_SCREEN_WIDTH, 60)];
        moneyLab.attributedText = attStr;
        moneyLab.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:moneyLab];
                
        _replyLab = [UIFactory createLabelWith:CGRectMake((JX_SCREEN_WIDTH-200)/2, CGRectGetMaxY(moneyLab.frame) + 10, 200, 20) text:self.replyContent.length > 0 ? self.replyContent : Localized(@"JX_ThankForReply!")];
        _replyLab.textColor = HEXCOLOR(0xE9996B);
        _replyLab.textAlignment = NSTextAlignmentCenter;
        _replyLab.userInteractionEnabled = YES;
        _replyLab.font = g_factory.font16;
        [_contentView addSubview:_replyLab];
    }

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyToTheRedPacket)];
    [_replyLab addGestureRecognizer:tap];


    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 30)];
    _showNumLabel = [UIFactory createLabelWith:CGRectMake(15, 0, JX_SCREEN_WIDTH - 10, 30) text:Localized(@"JX_ ReceiveRed")];
    _showNumLabel.textColor = [UIColor grayColor];
    _showNumLabel.font = g_factory.font14;
    [headView addSubview:_showNumLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 30 - LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
    lineView.backgroundColor = THE_LINE_COLOR;
    [headView addSubview:lineView];
    
    self.tableView.tableHeaderView = headView;
    
    [self setupReplayView];
}

- (void)setupReplayView {
    int height = 44;
    self.bigView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.bigView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.bigView.hidden = YES;
    [g_App.window addSubview:self.bigView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.bigView addGestureRecognizer:tap];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5)];
    self.baseView.backgroundColor = [UIColor whiteColor];
    self.baseView.layer.masksToBounds = YES;
    self. baseView.layer.cornerRadius = 4.0f;
    [self.bigView addSubview:self.baseView];
    int n = 20;
    _replayTitle = [[UILabel alloc] initWithFrame:CGRectMake(INSETS, n, self.baseView.frame.size.width - INSETS*2, 20)];
    _replayTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    _replayTitle.textColor = HEXCOLOR(0x333333);
    _replayTitle.font = SYSFONT(16);
    [self.baseView addSubview:_replayTitle];
    
    n = n + height;
    self.replayTextView = [self createTextField:self.baseView default:nil hint:nil];
    self.replayTextView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    self.replayTextView.frame = CGRectMake(10, n, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.replayTextView.delegate = self;
    self.replayTextView.textColor = HEXCOLOR(0x595959);
    n = n + INSETS + height;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, n, self.baseView.frame.size.width, 44)];
    [self.baseView addSubview:self.topView];
    
    //水印
    self.tintLab = [[UILabel alloc] initWithFrame:CGRectMake(5, 35.5/2-10, self.replayTextView.frame.size.width-10, 20)];
    self.tintLab.textColor = self.watermarkColor;
    [self.replayTextView addSubview:self.tintLab];
    
    // 两条线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.baseView.frame.size.width, LINE_WH)];
    topLine.backgroundColor = THE_LINE_COLOR;
    [self.topView addSubview:topLine];
    UIView *botLine = [[UIView alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, 0, LINE_WH, self.topView.frame.size.height)];
    botLine.backgroundColor = THE_LINE_COLOR;
    [self.topView addSubview:botLine];
    
    // 取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:SYSFONT(15)];
    [cancelBtn addTarget:self action:@selector(hideBigView) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    // 发送
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.baseView.frame.size.width/2, CGRectGetMaxY(topLine.frame), self.baseView.frame.size.width/2, botLine.frame.size.height)];
    [sureBtn setTitle:Localized(@"JX_Send") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0x55BEB8) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:SYSFONT(15)];
    [sureBtn addTarget:self action:@selector(onRelease) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:sureBtn];
    
}

- (void)hideBigView {
    [self resignKeyBoard];
}

- (void)onRelease {
    if (self.replayTextView.text.length > 0) {
        [g_server redPacketReply:self.packetObj.packetId content:self.replayTextView.text toView:self];
        [self hideBigView];
    }
}

- (void)replyToTheRedPacket {
    if (self.replayTextView.text.length > 0) {
        self.replayTextView.text = nil;
    }
    self.bigView.hidden = NO;
    [self.replayTextView becomeFirstResponder];
    
    self.replayTextView.textColor = self.watermarkColor;
    self.tintLab.hidden = NO;
    self.tintLab.text = self.replyContent.length > 0 ? self.replyContent : Localized(@"JX_ThankForReply!");
}


- (void)textViewDidChange:(UITextView *)textView {
    self.tintLab.hidden = textView.text.length > 0;
    
    if (textView.text.length > 10) {
        textView.text = [textView.text substringToIndex:10];
    }
    
    static CGFloat maxHeight =66.0f;

    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(JX_SCREEN_WIDTH-80-INSETS*2, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    NSLog(@"--------%@",NSStringFromCGRect(self.baseView.frame));
    
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4+35-size.height, JX_SCREEN_WIDTH-80, 162-35+size.height);
    self.topView.frame = CGRectMake(0, 118-35+size.height, self.baseView.frame.size.width, 40);
}


- (void)closeBtnAction:(UIButton *)btn {
    [self actionQuit];
}

- (void)listBtnAction:(UIButton *)btn {
    JXRedPacketListVC *vc = [[JXRedPacketListVC alloc] init];
    [g_navigation pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
}

-(void)quitOutAnimate{
    [self actionQuit];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//    }];
}

- (void)setViewSize{
    _headerImageView.layer.cornerRadius = 5;
    _headerImageView.clipsToBounds = YES;
}

- (void)creatTBHeaderView{
    //红包过时，提示
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 30)];
    _table.tableHeaderView = headerView;
    _returnMoneyLabel = [[UILabel alloc]initWithFrame:headerView.frame];
    
    _returnMoneyLabel.font = g_UIFactory.font12;
    _returnMoneyLabel.text = [NSString stringWithFormat:@"%@(%.2f%@)%@",Localized(@"JXredPacketDetailVC_ReturnMoney1"),_packetObj.over,Localized(@"JX_ChinaMoney"),Localized(@"JXredPacketDetailVC_ReturnMoney2")];
    _returnMoneyLabel.textAlignment = NSTextAlignmentCenter;
    _returnMoneyLabel.center = headerView.center;
    [headerView addSubview:_returnMoneyLabel];
}
//填写界面上的数据
- (void)setViewData{
    [g_server getHeadImageSmall:_packetObj.userId userName:_packetObj.userName imageView:_headerImageView getHeadHandler:nil];
    _totalMoneyLabel.text = [NSString stringWithFormat:@"%@%.2f%@",Localized(@"JXredPacketDetailVC_All"),_packetObj.money,Localized(@"JX_ChinaMoney")];
    _fromUserLabel.text = [NSString stringWithFormat:@"%@%@", _packetObj.userName,Localized(@"JX_WhoIsRedEnvelopes")];
    _greetLabel.text = _packetObj.greetings;
    NSString * isCanOpen = nil;
    NSString *over = [NSString stringWithFormat:@"%.2f",_packetObj.over];

    if(self.code == 100102 || [over doubleValue] < 0.01){
        isCanOpen = Localized(@"JXredPacketDetailVC_DrawOver");
    }else if(self.code == 100101){ // _dataDict[@"resultMsg"]
        isCanOpen = Localized(@"JXredPacketDetailVC_Overdue");
        [self creatTBHeaderView];

    }else if ([_OpenMember count] < _packetObj.count) {
        isCanOpen = Localized(@"JXredPacketDetailVC_DrawOK");
    }
    if ([over doubleValue] < 0.01) {
        _showNumLabel.text = [NSString stringWithFormat:@"%@%ld/%ld,%@",Localized(@"JXredPacketDetailVC_Drawed"),[_OpenMember count],_packetObj.count,isCanOpen];
    }else{
        _showNumLabel.text = [NSString stringWithFormat:@"%@%ld/%ld, %@%.2f%@,%@",Localized(@"JXredPacketDetailVC_Drawed"),[_OpenMember count],_packetObj.count,Localized(@"JXredPacketDetailVC_Rest"),_packetObj.over,Localized(@"JX_ChinaMoney"),isCanOpen];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)back:(id)sender {
    [self quitOutAnimate];
}

#pragma mark  --------------------TableView-------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_OpenMember count];
}

-(JXRPacketListCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //领取过红包的用户，使用JXRPacketListCell展示
    NSString * cellName = @"RPacketListCell";
    JXRPacketListCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){

        cell = [[NSBundle mainBundle] loadNibNamed:@"JXRPacketListCell" owner:self options:nil][0];
        
        cell.line = [[UIView alloc] init];
        cell.line.frame = CGRectMake(15, 68-LINE_WH, JX_SCREEN_WIDTH-15, LINE_WH);
        cell.line.backgroundColor = THE_LINE_COLOR;
        [cell.contentView addSubview:cell.line];
    }
    
    
    JXGetPacketList * memberObj = _OpenMember[indexPath.row];
    [g_server getHeadImageSmall:memberObj.userId userName:memberObj.userName imageView:cell.headerImage getHeadHandler:nil];
    //用户名
    cell.nameLabel.text = memberObj.userName;
    //回复内容
    cell.contentLab.text = memberObj.reply;
    //日期
    NSTimeInterval  getTime = memberObj.time;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:getTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*60*60]];//中国专用
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    //金额
    cell.moneyLabel.text = [NSString stringWithFormat:@"%.2f %@",memberObj.money,Localized(@"JX_ChinaMoney")];
    
    
    
    NSString *over = [NSString stringWithFormat:@"%.2f",_packetObj.over];
    
    if (_packetObj.status == 2 && [over doubleValue] < 0.01 && indexPath.row == [self getMaxMoney] && self.isGroup) {
        cell.kingImgV.hidden = NO;
        cell.bestLab.hidden = NO;
    }else {
        cell.kingImgV.hidden = YES;
        cell.bestLab.hidden = YES;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}


//-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
//    
//    if ([aDownload.action isEqualToString:act_getRedPacket]) {
//        self.dataDict = [[NSDictionary alloc]initWithDictionary:dict];
//    }
//    
//    
//}
//
//-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
//
//    //自己查看红包
//    if ([aDownload.action isEqualToString:act_getRedPacket]) {
//        self.dataDict = [[NSDictionary alloc]initWithDictionary:dict];
//    }
//    return hide_error;
//}

- (void)resignKeyBoard {
    self.bigView.hidden = YES;
    [self hideKeyBoard];
    [self resetBigView];
}

- (void)resetBigView {
    self.replayTextView.frame = CGRectMake(10, 64, self.baseView.frame.size.width - INSETS*2, 35.5);
    self.baseView.frame = CGRectMake(40, JX_SCREEN_HEIGHT/4-.5, JX_SCREEN_WIDTH-80, 162.5);
    self.topView.frame = CGRectMake(0, 118, self.baseView.frame.size.width, 40);
}

- (void)hideKeyBoard {
    if (self.replayTextView.isFirstResponder) {
        [self.replayTextView resignFirstResponder];
    }
}
-(UITextView*)createTextField:(UIView*)parent default:(NSString*)s hint:(NSString*)hint{
    UITextView* p = [[UITextView alloc] initWithFrame:CGRectMake(0,INSETS,JX_SCREEN_WIDTH,54)];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = g_factory.font16;
    [parent addSubview:p];
    return p;
}


- (void)dealloc {
//    [_headerImageView release];
//    [_totalMoneyLabel release];
//    [_fromUserLabel release];
//    [_greetLabel release];
//    [_showNumLabel release];
//    [_getPacketListTBV release];
//    [super dealloc];
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait hide];
    if([aDownload.action isEqualToString:act_redPacketReply]){
        for (JXGetPacketList * memberObj in _OpenMember) {
            if ([memberObj.userId intValue] == [MY_USER_ID intValue]) {
                memberObj.reply = self.replayTextView.text;
            }
        }
        self.replyContent = self.replayTextView.text;
        self.replyLab.text = self.replayTextView.text;
        
        [_table reloadData];
    }
}



-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    if([aDownload.action isEqualToString:act_redPacketReply]){
        [g_server showMsg:Localized(@"JX_FailureReply")];
    }
    return hide_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    if([aDownload.action isEqualToString:act_redPacketReply]){
        [g_server showMsg:Localized(@"JX_FailureReply")];
    }
    return hide_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


- (NSArray *)arraySortDESC:(NSArray *)dataDict {
    //对数组按领取时间time  进行降序排序
    
    // 排序key, 某个对象的属性名称，是否升序, YES-升序, NO-降序
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    // 排序结果
    return [dataDict sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


- (NSUInteger)getMaxMoney {
    // 获取手气最佳用户的index
    NSArray *tempArr = [NSArray array];
    
    NSMutableArray *list = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"money" ascending:NO];
    // 排序结果
    tempArr = [_OpenMember sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    JXGetPacketList *tempPacket = (JXGetPacketList *)tempArr.firstObject;
    NSString *tempMoney = [NSString stringWithFormat:@"%.2f",tempPacket.money];
    for (JXGetPacketList *packet in _OpenMember) {
        NSString *money = [NSString stringWithFormat:@"%.2f",packet.money];
        if ([money doubleValue] == [tempMoney doubleValue]) {
            [list addObject:packet];
        }
    }
    if (list.count > 1) {
        NSArray *sortArr = list.copy;
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
        sortArr = [sortArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
        JXGetPacketList *sortPacket = (JXGetPacketList *)sortArr.firstObject;
        for (JXGetPacketList *packet in _OpenMember) {
            if ([packet.userId intValue] == [sortPacket.userId intValue]) {
                return [_OpenMember indexOfObject:packet];
            }
        }
    }else {
        return [_OpenMember indexOfObject:[list firstObject]];
    }
    return 0;
}

@end
