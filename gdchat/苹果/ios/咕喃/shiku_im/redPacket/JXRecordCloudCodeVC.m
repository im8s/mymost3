//
//  JXRecordCloudCodeVC.m
//  shiku_im
//
//  Created by Apple on 16/9/18.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXRecordCloudCodeVC.h"
#import "JXRecordTBCell.h"
@interface JXRecordCloudCodeVC ()

@end

@implementation JXRecordCloudCodeVC
- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        
        _dataArr = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customView];
    [self getServerData];
}
-(void)getServerData{
    [_wait start];
    if (self.isCloud) {
        [g_server getYopWalletBill:_page toView:self];
    }else {
        [g_server getConsumeRecord:_page toView:self];
    }
}
- (void)customView{
    
    self.title = Localized(@"JXRecordCodeVC_Title");
    [self createHeadAndFoot];
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.allowsSelection = NO;
    if (@available(iOS 11.0, *)) {
        _table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

-(void)getDataObjFromArr:(NSMutableArray*)arr{
    [_table reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArr count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JXRecordTBCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JXRecordTBCell"];
    NSDictionary * cellModel = _dataArr[indexPath.row];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JXRecordTBCell" owner:self options:nil][0];
    }
    if (!self.isCloud) {
        //描述
        cell.titleLabel.text = cellModel[@"desc"];
    }
    
    //支付状态
    int payStatus = [cellModel[@"manualPay_status"] intValue];
    switch (payStatus) {
        case 0:
            cell.stastusImg.image = nil;
            break;
        case -1:
            cell.stastusImg.image = [UIImage imageNamed:@"audit_reject_icon"];
            break;
        case 1:
            cell.stastusImg.image = [UIImage imageNamed:@"audit_pass_icon"];
        default:
            break;
    }
    
    
    //转换为日期
    NSTimeInterval  creatTime = [cellModel[@"time"]  doubleValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:creatTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*60*60]];//中国专用
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    
    NSString *symbolStr;
    int type = [cellModel[@"type"] intValue];
    if (self.isCloud) {
        if (type == 2 || type == 3 || type == 5 || type == 6 || type == 7 || type == 9) {
            symbolStr = @"-";
            cell.moneyLabel.textColor = [UIColor blackColor];
            if (type == 2) {
                // 提现
                cell.titleLabel.text = Localized(@"JXMoney_withdrawals");
            }
            else if (type == 3) {
                //转账
                cell.titleLabel.text = Localized(@"JX_Transfer");
            }
            else if (type == 5 || type == 6 || type == 7) {
                //发红包
                cell.titleLabel.text = Localized(@"JX_SendGift");
            }
            else if (type == 9) {
                //提现服务费
                cell.titleLabel.text = Localized(@"JX_WithdrawalServiceFee");
            }
        }else {
            symbolStr = @"+";
            cell.moneyLabel.textColor = THEMECOLOR;
            if (type == 1) {
                //充值
                cell.titleLabel.text = Localized(@"JXLiveVC_Recharge");
            }
            else if (type == 4) {
                //接收转账
                cell.titleLabel.text = Localized(@"JX_ReceiveTransfer");
            }
            else if (type == 8) {
                //收红包
                cell.titleLabel.text = Localized(@"JX_ReceiveRedEnvelope");
            }
        }
    }else{
        if (type == 2 || type == 4 || type == 7 || type == 10 || type == 12 || type == 14) {
            symbolStr = @"-";
            cell.moneyLabel.textColor = [UIColor blackColor];
        }else {
            symbolStr = @"+";
            cell.moneyLabel.textColor = THEMECOLOR;
        }
        
        if (payStatus == -1) {
            symbolStr = @"";
            cell.moneyLabel.textColor = [UIColor redColor];
            cell.titleLabel.textColor = [UIColor redColor];
        }
        if (payStatus == 1) {
            symbolStr = @"";
            cell.moneyLabel.textColor = [UIColor blackColor];
            cell.titleLabel.textColor = [UIColor blackColor];
        }
    }
    //交易金额
    cell.moneyLabel.text = [NSString stringWithFormat:@"%@%@ %@",symbolStr,cellModel[@"money"],Localized(@"JX_ChinaMoney")];
    //是否退款
    cell.refundLabel.text = @"";
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self stopLoading];
    //消费记录
    if ([aDownload.action isEqualToString:act_consumeRecord] || [aDownload.action isEqualToString:act_getYopWalletBill]) {
        //添加到数据源
        if (dict == nil) {
            return;
        }
//        if ([dict[@"pageIndex"] intValue] == 0) {
//            _dataArr = [[NSMutableArray alloc]initWithArray:dict[@"pageData"]];
//            //            self.dataDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
//        }else if([dict[@"pageIndex"] intValue] <= [dict[@"pageCount"] intValue]){
//            [_dataArr addObjectsFromArray:dict[@"pageData"]];
//        }else{
//            //没有更多数据
//        }
        
        
        _footer.hidden = [(NSArray *)dict[@"pageData"] count] < 20;
        
        if(_page == 0){
            [_dataArr removeAllObjects];
            [_dataArr addObjectsFromArray:dict[@"pageData"]];
        }else{
            if([(NSArray *)dict[@"pageData"] count]>0){
                [_dataArr addObjectsFromArray:dict[@"pageData"]];
            }
        }

        [self getDataObjFromArr:_dataArr];
        
    }
    
    
}

-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    [self stopLoading];
    return hide_error;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
