//
//  JXGroupHelperListVC.m
//  shiku_im
//
//  Created by 1 on 2019/5/28.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXGroupHelperListVC.h"
#import "JXAutoReplyAideVC.h"
#import "JXHelperModel.h"
#import "JXGroupHelperCell.h"

@interface JXGroupHelperListVC () <JXGroupHelperCellDelegate>
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *groupHelperArr;
@property (nonatomic, assign) NSInteger cellIndex;


@end


@implementation JXGroupHelperListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    [self createHeadAndFoot];
        
    self.title = Localized(@"JX_GroupAssistants");
    _groupHelperArr = [NSMutableArray array];
    _array = [NSMutableArray array];
    
    [g_server queryGroupHelper:self.roomId toView:self];
    [g_notify addObserver:self selector:@selector(updateAddBtnStatus:) name:kUpdateChatVCGroupHelperData object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)updateAddBtnStatus:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    
    JXGroupHelperCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.cellIndex inSection:0]];
    
    if ([[dict objectForKey:@"delete"] intValue] == 1) {
        cell.addBtn.hidden = NO;
    }else {
        cell.addBtn.hidden = YES;
    }
    
//    [self.tableView reloadData];
}

- (void)dealloc {
    [g_notify removeObserver:self];
}


- (void)getServerData {
    
    [g_server getHelperList:(int)_page pageSize:20 toView:self];
}

//顶部刷新获取数据
-(void)scrollToPageUp{
    
    _page = 0;
    [self getServerData];
}

-(void)scrollToPageDown{
    
    [self getServerData];
}

#pragma mark   ---------tableView协议----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = [NSString stringWithFormat:@"JXGroupHelperCell_%ld",indexPath.row];
    JXGroupHelperCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXGroupHelperCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        JXHelperModel *model;
        if (_array.count > 0) {
            model = [_array objectAtIndex:indexPath.row];
        }
        cell.tag = indexPath.row;
        cell.delegate = self;
        cell.groupHelperArr = _groupHelperArr;
        [cell setDataWithModel:model];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self doAutoScroll:indexPath];
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cellIndex = indexPath.row;
    
    JXAutoReplyAideVC *vc = [[JXAutoReplyAideVC alloc] init];
    vc.model = [_array objectAtIndex:indexPath.row];
    vc.roomId = self.roomId;
    vc.roomJid = self.roomJid;
    
    [g_navigation pushViewController:vc animated:YES];
    
}

- (void)groupHelperCell:(JXGroupHelperCell *)cell clickAddBtnWithIndex:(NSInteger)index {
    self.cellIndex = index;
    JXHelperModel *model = [_array objectAtIndex:index];
    [g_server addGroupHelper:self.roomId roomJid:self.roomJid helperId:model.helperId toView:self];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if( [aDownload.action isEqualToString:act_getHelperList]){
        [self stopLoading];
        
        if (array1.count < 20) {
            _footer.hidden = YES;
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        if(_page == 0){
            [_array removeAllObjects];
            for (int i = 0; i < array1.count; i++) {
                JXHelperModel *model = [[JXHelperModel alloc] init];
                [model getDataWithDict:array1[i]];
                [arr addObject:model];
            }
            [_array addObjectsFromArray:arr];
        }else{
            if([array1 count]>0){
                for (int i = 0; i < array1.count; i++) {
                    JXHelperModel *model = [[JXHelperModel alloc] init];
                    [model getDataWithDict:array1[i]];
                    [arr addObject:model];
                }
                [_array addObjectsFromArray:arr];
            }
        }
        _page ++;
        [self.tableView reloadData];
    }
    
    // 获取群助手
    if ([aDownload.action isEqualToString:act_queryGroupHelper]) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < array1.count; i++) {
            JXGroupHeplerModel *model = [[JXGroupHeplerModel alloc] init];
            [model getDataWithDict:array1[i]];
            [arr addObject:model.helperId];
        }
        _groupHelperArr = arr;
        
        [self getServerData];
    }

    
    if ([aDownload.action isEqualToString:act_addGroupHelper]) {
        [g_server showMsg:Localized(@"JX_AddSuccess")];
        JXGroupHelperCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.cellIndex inSection:0]];
        cell.addBtn.hidden = YES;

        [g_notify postNotificationName:kUpdateChatVCGroupHelperData object:nil];
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
