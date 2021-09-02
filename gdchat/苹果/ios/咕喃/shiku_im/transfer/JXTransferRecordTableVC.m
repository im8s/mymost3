//
//  JXTransferRecordTableVC.m
//  shiku_im
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTransferRecordTableVC.h"
#import "JXRecordModel.h"
#import "JXRecordCell.h"

@interface JXTransferRecordTableVC ()
//@property (nonatomic, strong) JXRecordModel *model;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *indexArr;

@end

@implementation JXTransferRecordTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    _array = [[NSMutableArray alloc] init];
    _indexArr = [[NSMutableArray alloc] init];

    self.title = Localized(@"JX_TransferTheDetail");
    _table.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self getServerData];
}


- (void)getServerData {
    [g_server getConsumeRecordList:self.userId pageIndex:_page pageSize:20 toView:self];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.indexArr.count > 0) {
        return self.indexArr.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_array.count > 0) {
        return [(NSArray *)[_array objectAtIndex:section] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"JXRecordCell";
    JXRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    JXRecordModel *model = _array[indexPath.section][indexPath.row];
    
    [cell setData:model];
    
    if (indexPath.row == [(NSArray *)[_array objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 40)];
    
    view.backgroundColor = HEXCOLOR(0xF2F2F2);
    UILabel *label = [[JXLabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 48)];
    double payMoney = 0;
    double getMoney = 0;
    if (self.indexArr.count > 0) {
        for (JXRecordModel *model in _array[section]) {
            if (model.type == 1 || model.type == 2 || model.type == 3 || model.type == 4 || model.type == 7 || model.type == 10 || model.type == 12) {
                payMoney += model.money;
            }else {
                getMoney += model.money;
            }
        }
        
        label.text = [NSString stringWithFormat:@"%@   %@:%.2f  %@:%.2f",[self.indexArr objectAtIndex:section],Localized(@"JX_Expenditure"),payMoney,Localized(@"JX_Income"),getMoney];
    }
    label.font = SYSFONT(13);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    
    [view addSubview:label];

    return view;
    
}


- (void)handleBillData:(NSArray *)arr
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSInteger currentYear = nowCmps.year;
    NSInteger currentMonth = nowCmps.month;
    
    for (JXRecordModel *model in arr) {
        
        NSString *key;
            
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate dateWithTimeIntervalSince1970:model.time]];
        NSInteger billYear = [components year];
        NSInteger billMonth = [components month];
        
        
        if (billYear == currentYear)//本年,对比之后的结果是本年
        {
            if (billMonth ==currentMonth)//本月
            {
                key =Localized(@"JX_This month");
            }
            else//其他月
            {
                key =[NSString stringWithFormat:@"%02ld%@",billMonth,Localized(@"JX_Month")];
            }
        }
        else//非本年
        {
            key =[NSString stringWithFormat:@"%ld%@%2ld%@",billYear,Localized(@"JX_Year"),billMonth,Localized(@"JX_Month")];
        }
        
        
        BOOL isContained =NO;//_indexArr 是否包含key
        NSInteger containedIndex = 0;//记录index

        
        if ([self.indexArr containsObject:key]) {
            isContained = YES;
            containedIndex = [self.indexArr indexOfObject:key];
        }else {
            [self.indexArr addObject:key];
        }
        
        
        if (isContained)//如果包含,把Model加进小数组存储
        {
            [[_array objectAtIndex:containedIndex] addObject:model];
        }
        else//如果不包含，则创建个小数组添加进_array，然后把model添加进去
        {
            NSMutableArray *subArr = [[NSMutableArray alloc] init];
            [subArr addObject:model];
            [_array addObject:subArr];
        }
    }
    
    [_table reloadData];
}



-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_getConsumeRecordList]){
        NSArray *arr = [dict objectForKey:@"pageData"];
        if (arr.count <= 0) {
        }
        NSMutableArray *mutArr = [[NSMutableArray alloc] init];
        if(_page == 0){
            [_array removeAllObjects];
            [_indexArr removeAllObjects];
            for (int i = 0; i < arr.count; i++) {
                JXRecordModel *model = [[JXRecordModel alloc] init];
                [model getDataWithDict:arr[i]];
                [mutArr addObject:model];
            }
//            [_array addObjectsFromArray:mutArr];
        }else{
            if([arr count]>0){
                for (int i = 0; i < arr.count; i++) {
                    JXRecordModel *model = [[JXRecordModel alloc] init];
                    [model getDataWithDict:arr[i]];
                    [mutArr addObject:model];
                }
//                [_array addObjectsFromArray:mutArr];
            }
        }
        _page ++;
        if (mutArr.count > 0) {
            [_table hideEmptyImage];
        }else {
            [_table showEmptyImage:EmptyTypeNoData];
        }
        [self setIsShowFooterPull:arr.count >= 20];
        
        [self handleBillData:mutArr];
        

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
