//
//  JXSelectCashWithdrawalVC.m
//  shiku_im
//
//  Created by p on 2019/12/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSelectCashWithdrawalVC.h"
#import "JXSelectCashWithdrawalCell.h"
#import "JXAddWithdrawalsAccountVC.h"

@interface JXSelectCashWithdrawalVC ()<JXAddWithdrawalsAccountVCDelegate>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIButton *editBtn;

@end

@implementation JXSelectCashWithdrawalVC


-(instancetype)init{
    if (self = [super init]) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.isShowHeaderPull = YES;
        self.isShowFooterPull = YES;
        self.title = Localized(@"JX_ChooseWithdrawalMethod");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    
    [self createHeadAndFoot];
    self.tableView.backgroundColor = HEXCOLOR(0xF4F5FA);
    _array = [NSMutableArray array];
    
    _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH -32-15, JX_SCREEN_TOP - 30, 50, 15)];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_editBtn setTitle:Localized(@"JX_Edit") forState:UIControlStateNormal];
    [_editBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateSelected];
    [_editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_editBtn addTarget:self action:@selector(editBtnAction) forControlEvents:UIControlEventTouchUpInside];
    _editBtn.selected = NO;
    [self.tableHeader addSubview:_editBtn];
    
    [self scrollToPageUp];
    // Do any additional setup after loading the view.
    
}

- (void)editBtnAction {
    _editBtn.selected = !_editBtn.selected;
}

- (void)scrollToPageUp {
    
    self.index = 0;
    [g_server manualPayGetWithdrawAccountListWithPageIndex:self.index toView:self];
}

- (void)scrollToPageDown {
    self.index ++;
    [g_server manualPayGetWithdrawAccountListWithPageIndex:self.index toView:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count + 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    JXSelectCashWithdrawalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXSelectCashWithdrawalCell"];
    if (!cell) {

        cell = [[JXSelectCashWithdrawalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JXSelectCashWithdrawalCell"];
    }
    cell.tag = indexPath.row + 10000;
    if (indexPath.row > 1) {
        NSDictionary *dict = _array[indexPath.row - 2];
        cell.data = dict;
    }else {
        cell.data = [NSDictionary dictionary];
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.row == 0 || indexPath.row == 1) {
        
        self.editBtn.selected = NO;
        
        JXAddWithdrawalsAccountVC *vc = [[JXAddWithdrawalsAccountVC alloc] init];
        if (indexPath.row == 0) {
            vc.addType = AddType_Ali;
        }else {
            vc.addType = AddType_Card;
        }
        vc.delegate = self;
        [g_navigation pushViewController:vc animated:YES];
        
    }else {
        NSDictionary *dict = _array[indexPath.row - 2];
        if (self.editBtn.selected) {
            JXAddWithdrawalsAccountVC *vc = [[JXAddWithdrawalsAccountVC alloc] init];
            if (indexPath.row == 0) {
                vc.addType = AddType_Ali;
            }else {
                vc.addType = AddType_Card;
            }
            vc.data = dict;
            vc.delegate = self;
            [g_navigation pushViewController:vc animated:YES];
        }else {
            if ([self.delegate respondsToSelector:@selector(selectCashWithdrawalWithData:)]) {
                [self.delegate selectCashWithdrawalWithData:dict];
                [self actionQuit];
            }
        }
        
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict=[_array objectAtIndex:indexPath.row - 2];
    
    UITableViewRowAction *delBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"JX_Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [g_server manualPayDeleteWithdrawAccountWithId:[dict objectForKey:@"id"] toView:self];
       
    }];
    
    return @[delBtn];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        return NO;
    }
    return YES;
}

- (void)addWithdrawalsAccountBindSuccess {
    
    [self scrollToPageUp];
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    [_wait stop];
    [self stopLoading];
    if ([aDownload.action isEqualToString:act_ManualPayGetWithdrawAccountList]) {
        
        if (self.index == 0) {
            [_array removeAllObjects];
            [_array addObjectsFromArray:array1];
        }
        else {
            [_array addObjectsFromArray:array1];
        }
        
        if (array1.count < 20) {
            self.isShowFooterPull = NO;
        }
        
        [self.tableView reloadData];
    }
    
    if ([aDownload.action isEqualToString:act_ManualPayDeleteWithdrawAccount]) {
        [self scrollToPageUp];
    }
}

- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    [_wait stop];
    
    return show_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    [_wait stop];
    return show_error;
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
