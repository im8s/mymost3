//
//  JXTransferNoticeVC.m
//  shiku_im
//
//  Created by 1 on 2019/3/8.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXTransferNoticeVC.h"
#import "JXTransferNoticeCell.h"
#import "JXTransferNoticeModel.h"
#import "JXTransferModel.h"
#import "JXTransferOpenPayModel.h"

@interface JXTransferNoticeVC ()
@property (nonatomic, strong) NSArray *array;

@end

@implementation JXTransferNoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = Localized(@"JX_PaymentNo.");
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    _table.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self getData];
}

- (void)getData {
    // 获取所有聊天记录
    _array = [[JXMessageObject sharedInstance] fetchAllMessageListWithUser:SHIKU_TRANSFER];
    if (_array.count > 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_array.count-1 inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXMessageObject *msg=[_array objectAtIndex:indexPath.row];

    return [JXTransferNoticeCell getChatCellHeight:msg];
//    return 215;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"JXTransferNoticeCell";
    JXTransferNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[JXTransferNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    JXMessageObject *msg = _array[indexPath.row];
//    SBJsonParser * OderJsonwriter = [SBJsonParser new];

    NSDictionary *dict = [self dictionaryWithJsonString:msg.content];
    if ([msg.type intValue] == kWCMessageTypeTransferBack) {
        JXTransferModel *model = [[JXTransferModel alloc] init];
        [model getTransferDataWithDict:dict];
        [cell setDataWithMsg:msg model:model];
    }
    else if ([msg.type intValue] == kWCMessageTypeOpenPaySuccess) {
        JXTransferOpenPayModel *model = [[JXTransferOpenPayModel alloc] init];
        [model getTransferDataWithDict:dict];
        [cell setDataWithMsg:msg model:model];
    }
    else {
        JXTransferNoticeModel *model = [[JXTransferNoticeModel alloc]init];
        [model getTransferNoticeWithDict:dict];
        [cell setDataWithMsg:msg model:model];
    }
    
    return cell;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
