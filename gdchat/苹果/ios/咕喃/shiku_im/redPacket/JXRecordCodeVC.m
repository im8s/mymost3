//
//  JXRecordCodeVC.m
//  shiku_im
//
//  Created by Apple on 16/9/18.
//  Copyright © 2016年 Reese. All rights reserved.
//

#import "JXRecordCodeVC.h"
#import "JXRecordTBCell.h"
#import "JXDatePicker.h"

#define PAGESIZE 50

@interface JXRecordCodeVC ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) NSMutableArray *years;
@property (nonatomic, strong) NSMutableArray *months;
@property (nonatomic,copy) NSString *currentYear;
@property (nonatomic,copy) NSString *currentMonth;
@property (nonatomic, assign) BOOL isNext;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic, assign) BOOL isNextMonth; // 是否下翻新一个月的数据
@property (nonatomic, assign) BOOL isUpMonth; // 是否上翻新一个月的数据
@property (nonatomic, assign) BOOL isNeedCount;
@property (nonatomic, assign) BOOL isReload;

@end

@implementation JXRecordCodeVC
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

- (void)getYearsArray {
    _years = [NSMutableArray array];
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];
    self.currentYear = [dateformatter stringFromDate:senddate];
    [dateformatter setDateFormat:@"MM"];
    self.currentMonth = [dateformatter stringFromDate:senddate];

    
    for (NSInteger i = 1970; i <= [self.currentYear integerValue]; i ++) {
        [_years addObject:[NSString stringWithFormat:@"%ld",i]];
    }
}

- (void)getMonthsArray {
    _months = [NSMutableArray arrayWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12", nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customView];
    self.isNext = YES;
    self.isUpMonth = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM"];
    NSString *endMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] + 1];
    NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, endMonth]];
    if ([endMonth integerValue] > 12) {
        endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, @"01"]];
    }
    
    NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, self.currentMonth]];
    self.startTime = [NSString stringWithFormat:@"%ld", (long)[startDate timeIntervalSince1970]];
    self.endTime = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
    self.isNeedCount = YES;
    [self getServerData];
    
    
    int height = 200;
    if (THE_DEVICE_HAVE_HEAD) {
        height = 235;
    }
    
}
-(void)getServerData{
    [_wait start];

    [g_server queryConsumeRecordCountWithStartTime:self.startTime endTime:self.endTime needCount:self.isNeedCount isNext:self.isNext pageSize:PAGESIZE toView:self];
    
//    if (self.isCloud) {
//        [g_server getYopWalletBill:_page toView:self];
//    }else {
//        [g_server getConsumeRecord:_page toView:self];
//    }

}

- (void)scrollToPageUp {
    self.isNext = NO;
    
    
    NSDictionary *dict = _dataArr.firstObject;
    self.currentYear = [dict objectForKey:@"currentYear"];
    self.currentMonth = [dict objectForKey:@"currentMonth"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM"];
    NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, self.currentMonth]];
    
    if (self.isUpMonth) {
        self.currentMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] + 1];
        if ([self.currentMonth integerValue] > 12) {
            self.currentMonth = @"01";
            self.currentYear = [NSString stringWithFormat:@"%ld",[self.currentYear integerValue] + 1];
        }
        startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, self.currentMonth]];
        
        
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy"];
        NSString *year = [dateformatter stringFromDate:senddate];
        [dateformatter setDateFormat:@"MM"];
        NSString *month = [dateformatter stringFromDate:senddate];
        NSDate *currentDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", year, month]];
        if ([startDate timeIntervalSince1970] > [currentDate timeIntervalSince1970]) {
            self.currentYear = year;
            self.currentMonth = month;
            startDate = currentDate;
            self.isNext = YES;
            self.isReload = YES;
        }
        
        NSString *endMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] + 1];
        NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, endMonth]];
        if ([endMonth integerValue] > 12) {
            endDate = [formatter dateFromString:[NSString stringWithFormat:@"%ld%@", [self.currentYear integerValue] + 1, @"01"]];
        }
        
        self.startTime = [NSString stringWithFormat:@"%ld", (long)[startDate timeIntervalSince1970]];
        self.endTime = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
        self.isNeedCount = YES;
    }else {
        NSDictionary *dict = _dataArr.firstObject;
        NSArray *recordList = [dict objectForKey:@"recordList"];
        NSDictionary *record = recordList.firstObject;
        
        NSString *endMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] + 1];
        NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, endMonth]];
        if ([endMonth integerValue] > 12) {
            endDate = [formatter dateFromString:[NSString stringWithFormat:@"%ld%@", [self.currentYear integerValue] + 1, @"01"]];
        }
        self.startTime = [NSString stringWithFormat:@"%ld", [[record objectForKey:@"time"] longValue]];
        self.endTime = [NSString stringWithFormat:@"%ld",(long)[endDate timeIntervalSince1970]];
        self.isNeedCount = NO;
    }
    [self getServerData];
}

- (void)scrollToPageDown {
    
    self.isNext = YES;
    
    
    NSDictionary *dict = _dataArr.lastObject;
    self.currentYear = [dict objectForKey:@"currentYear"];
    self.currentMonth = [dict objectForKey:@"currentMonth"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM"];
    
    if (self.isNextMonth) {
        self.currentMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] - 1];
        if ([self.currentMonth integerValue] <= 0) {
            self.currentMonth = @"12";
            self.currentYear = [NSString stringWithFormat:@"%ld",[self.currentYear integerValue] - 1];
        }
        
        NSString *endMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] + 1];
        NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, endMonth]];
        if ([endMonth integerValue] > 12) {
            endDate = [formatter dateFromString:[NSString stringWithFormat:@"%ld%@", [self.currentYear integerValue] + 1, @"01"]];
        }
        
        NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, self.currentMonth]];
        
        self.startTime = [NSString stringWithFormat:@"%ld", (long)[startDate timeIntervalSince1970]];
        self.endTime = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
        self.isNeedCount = YES;
    }else {
        NSDictionary *dict = _dataArr.lastObject;
        NSArray *recordList = [dict objectForKey:@"recordList"];
        NSDictionary *record = recordList.lastObject;
        self.endTime = [NSString stringWithFormat:@"%ld", [[record objectForKey:@"time"] longValue]];
        
        NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, self.currentMonth]];
        
        self.startTime = [NSString stringWithFormat:@"%ld",(long)[startDate timeIntervalSince1970]];
        self.isNeedCount = NO;
    }
    [self getServerData];
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
    [self getYearsArray];
    [self getMonthsArray];
    [self createSelectDateView];
}

- (void)createSelectDateView {
    
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP)];
    _selectView.backgroundColor = [UIColor clearColor];
    _selectView.hidden = YES;
    [self.view addSubview:_selectView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelBtnAction)];
    [_selectView addGestureRecognizer:tap];
    
    UIView *selV = [[UIView alloc] initWithFrame:CGRectMake(0, _selectView.frame.size.height - 220, JX_SCREEN_WIDTH, 220)];
    selV.backgroundColor = HEXCOLOR(0xF2F2F2);
    [_selectView addSubview:selV];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(selV.frame.size.width - 80, 20, 60, 20)];
    [btn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [selV addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 20)];
    [btn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [selV addSubview:btn];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, selV.frame.size.width, selV.frame.size.height - 40)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [_pickerView selectRow:_years.count - 1 inComponent:0 animated:NO];
    [_pickerView selectRow:[self.currentMonth integerValue] - 1 inComponent:1 animated:NO];
    [selV addSubview:_pickerView];
}
- (void)btnAction:(UIButton *)btn {
    
    _selectView.hidden = YES;
    NSInteger yearRow = [_pickerView selectedRowInComponent:0];
    NSInteger monthRow = [_pickerView selectedRowInComponent:1];
    NSString *year = _years[yearRow];
    NSString *month = _months[monthRow];
    
    self.currentYear = year;
    self.currentMonth = month;
    
    [_dataArr removeAllObjects];
    
    self.isNext = YES;
    self.isUpMonth = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM"];
    NSString *endMonth = [NSString stringWithFormat:@"%02ld",[self.currentMonth integerValue] + 1];
    NSDate *endDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, endMonth]];
    if ([endMonth integerValue] > 12) {
        endDate = [formatter dateFromString:[NSString stringWithFormat:@"%ld%@", [self.currentYear integerValue] + 1, @"01"]];
    }
    
    NSDate *startDate = [formatter dateFromString:[NSString stringWithFormat:@"%@%@", self.currentYear, self.currentMonth]];
    self.startTime = [NSString stringWithFormat:@"%ld", (long)[startDate timeIntervalSince1970]];
    self.endTime = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
    self.isNeedCount = YES;
    [self getServerData];
    
}

- (void)cancelBtnAction {
    _selectView.hidden = YES;
}
-(void)getDataObjFromArr:(NSMutableArray*)arr{
    [_table reloadData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return _years.count;
    }
    return _months.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return _years[row];
    }
    return _months[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_dataArr count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = _dataArr[section];
    NSArray *recordList = [dict objectForKey:@"recordList"];
    return [recordList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JXRecordTBCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JXRecordTBCell"];
    
    NSDictionary *dict = _dataArr[indexPath.section];
    NSArray *recordList = [dict objectForKey:@"recordList"];
    NSDictionary * cellModel = recordList[indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *dict = _dataArr[section];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 60)];
    headerView.backgroundColor = HEXCOLOR(0xF1F1F1);
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 20)];
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.text = [NSString stringWithFormat:@"%@%@%@%@", dict[@"currentYear"], Localized(@"JX_Year"), dict[@"currentMonth"], Localized(@"JX_Month")];
    dateLabel.font = [UIFont systemFontOfSize:16.0];
    CGSize size = [dateLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:dateLabel.font} context:nil].size;
    dateLabel.frame = CGRectMake(dateLabel.frame.origin.x, dateLabel.frame.origin.y, size.width, dateLabel.frame.size.height);
    [headerView addSubview:dateLabel];
    
    UIImageView *unfoldView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dateLabel.frame) + 5, 10, 20, 20)];
    unfoldView.image = [UIImage imageNamed:@"room_unfold"];
    [headerView addSubview:unfoldView];
    
    UILabel *statistic = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(dateLabel.frame) + 5, headerView.frame.size.width - 30, 20)];
    statistic.textColor = [UIColor lightGrayColor];
    statistic.text = [NSString stringWithFormat:@"%@ ￥%@  %@ ￥%@", Localized(@"JX_Expenditure"), dict[@"expenses"], Localized(@"JX_Income"), dict[@"income"]];
    statistic.font = [UIFont systemFontOfSize:14.0];
    [headerView addSubview:statistic];
    
    UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(dateLabel.frame) + 20, headerView.frame.size.height)];
    selectBtn.backgroundColor = [UIColor clearColor];
    [selectBtn addTarget:self action:@selector(selectDateAction) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:selectBtn];
    
    return headerView;
}

- (void)selectDateAction {
    _selectView.hidden = NO;
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self stopLoading];
    //消费记录
    if ([aDownload.action isEqualToString:act_queryConsumeRecordCount]) {
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
        
        if (self.isNext) {
            if (self.isReload) {
                self.isReload = NO;
                [_dataArr removeAllObjects];
            }
            if (self.isNeedCount) {
                NSMutableDictionary *recordObj = [dict mutableCopy];
                [recordObj setObject:self.currentYear forKey:@"currentYear"];
                [recordObj setObject:self.currentMonth forKey:@"currentMonth"];
                [_dataArr addObject:recordObj];
            }else {
                NSMutableDictionary *recordObj = [dict mutableCopy];
                NSMutableArray *recordList = recordObj[@"recordList"];
                
                NSMutableDictionary *oldObj = _dataArr.lastObject;
                NSMutableArray *oldList = oldObj[@"recordList"];
                [oldList addObjectsFromArray:recordList];
            }
            
            
            if ([(NSArray *)[dict objectForKey:@"recordList"] count] < PAGESIZE) {
                self.isNextMonth = YES;
            }else {
                self.isNextMonth = NO;
            }
            
        }else {
            
            
            NSMutableDictionary *recordObj = [dict mutableCopy];
            NSMutableArray *recordList = [NSMutableArray array];
            NSArray *arr = recordObj[@"recordList"];
            for (NSInteger i = arr.count - 1; i >= 0; i --) {
                NSDictionary *record = arr[i];
                [recordList addObject:record];
            }
            [recordObj setObject:recordList forKey:@"recordList"];
            
            if (self.isNeedCount) {
                [recordObj setObject:self.currentYear forKey:@"currentYear"];
                [recordObj setObject:self.currentMonth forKey:@"currentMonth"];
                [_dataArr insertObject:recordObj atIndex:0];
            }else {
                
                NSMutableDictionary *oldObj = _dataArr.firstObject;
                NSMutableArray *oldList = oldObj[@"recordList"];
                [recordList addObjectsFromArray:oldList];
                [oldObj setObject:recordList forKey:@"recordList"];
            }
            
            if ([(NSArray *)[dict objectForKey:@"recordList"] count] < PAGESIZE) {
                self.isUpMonth = YES;
            }else {
                self.isUpMonth = NO;
            }
        }
        
        
//        _footer.hidden = [dict[@"pageData"] count] < 20;
//
//        if(_page == 0){
//            [_dataArr removeAllObjects];
//            [_dataArr addObjectsFromArray:dict[@"pageData"]];
//        }else{
//            if([dict[@"pageData"] count]>0){
//                [_dataArr addObjectsFromArray:dict[@"pageData"]];
//            }
//        }

        [self getDataObjFromArr:_dataArr];
        
    }
    
    
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    [self stopLoading];
    return show_error;
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
