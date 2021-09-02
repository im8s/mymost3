//
//  JXSelectAddressBookVC.m
//  shiku_im
//
//  Created by p on 2019/4/3.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSelectAddressBookVC.h"
#import "QCheckBox.h"
#import "BMChineseSort.h"
#import "JXAddressBookCell.h"

@interface JXSelectAddressBookVC ()<QCheckBoxDelegate,JXAddressBookCellDelegate>

@property(nonatomic,strong)NSMutableArray *array;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property (nonatomic, strong)NSMutableArray *abUreadArr;

@property (nonatomic, assign) BOOL isShowSelect;
@property (nonatomic, strong) NSMutableArray *selectABs;
@property (nonatomic, strong) UIView *doneBtn;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) NSDictionary *phoneNumDict;
@property (nonatomic, strong) NSMutableArray *headerCheckBoxs;
@property (nonatomic, strong) NSMutableArray *allAbArr;

@end

@implementation JXSelectAddressBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    self.isShowFooterPull = NO;
    
    [self createHeadAndFoot];
    
    _phoneNumDict = [[JXAddressBook sharedInstance] getMyAddressBook];
    _headerCheckBoxs = [NSMutableArray array];
    
    self.title = Localized(@"SELECT_CONTANTS");
    
    _array = [NSMutableArray array];
    _indexArray = [NSMutableArray array];
    _letterResultArr = [NSMutableArray array];
    _selectABs = [NSMutableArray array];
    _allAbArr = [NSMutableArray array];
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_selectBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [_selectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _selectBtn.tintColor = [UIColor clearColor];
    _selectBtn.frame = CGRectMake(JX_SCREEN_WIDTH - 32-15, JX_SCREEN_TOP - 30, 32, 15);
    _selectBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_selectBtn addTarget:self action:@selector(selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:_selectBtn];
    
    [self getServerData];
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    [self addressBookCell:nil checkBoxSelectIndexNum:checkbox.tag isSelect:checked];
}

- (void)selectBtnAction:(UIButton *)btn {
    if (_selectABs.count <= 0) {
        [g_App showAlert:Localized(@"JX_PleaseSelectContactPerson")];
        return;
    }

    if ([self.delegate respondsToSelector:@selector(selectAddressBookVC:doneAction:)]) {
        [self.delegate selectAddressBookVC:self doneAction:_selectABs];
    }
    
    [self actionQuit];
}
- (void)getServerData {
    [_array removeAllObjects];
    [_allAbArr removeAllObjects];
    NSMutableArray *arr = [[JXAddressBook sharedInstance] fetchAllAddressBook];
    
    for (NSString *key in _phoneNumDict.allKeys) {
        BOOL flag = NO;
        for (JXAddressBook *obj in arr) {
            if ([obj.toTelephone isEqualToString:key]) {
                flag = YES;
                break;
            }
        }
        if (!flag) {
            JXAddressBook *ab = [[JXAddressBook alloc] init];
            ab.toTelephone = key;
            ab.addressBookName = _phoneNumDict[key];
            [_array addObject:ab];
        }
    }
    
    //选择拼音 转换的 方法
    BMChineseSortSetting.share.sortMode = 2; // 1或2
    //排序 Person对象
    [BMChineseSort sortAndGroup:_array key:@"addressBookName" finish:^(bool isSuccess, NSMutableArray *unGroupArr, NSMutableArray *sectionTitleArr, NSMutableArray<NSMutableArray *> *sortedObjArr) {
        if (isSuccess) {
            self.indexArray = sectionTitleArr;
            self.letterResultArr = sortedObjArr;
            [_table reloadData];
        }
    }];
    
    //    //根据Person对象的 name 属性 按中文 对 Person数组 排序
    //    self.indexArray = [BMChineseSort IndexWithArray:_array Key:@"addressBookName"];
    //    self.letterResultArr = [BMChineseSort sortObjectArray:_array Key:@"addressBookName"];
}
#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.indexArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.indexArray objectAtIndex:section];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.tintColor = HEXCOLOR(0xF2F2F2);
    [header.textLabel setTextColor:HEXCOLOR(0x999999)];
    [header.textLabel setFont:SYSFONT(15)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[self.letterResultArr objectAtIndex:section] count];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return self.indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"JXAddressBookCell";
    JXAddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    JXAddressBook *addressBook = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (!cell) {
        cell = [[JXAddressBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.isInvite = YES;
    cell.index = indexPath.section * 1000 + indexPath.row;
    cell.isShowSelect = YES;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_selectABs containsObject:addressBook]) {
        cell.checkBox.selected = YES;
    }else {
        cell.checkBox.selected = NO;
    }
    cell.addressBook = addressBook;
    cell.headImage.userInteractionEnabled = NO;
    
    if (indexPath.row == [(NSArray *)[self.letterResultArr objectAtIndex:indexPath.section] count]-1) {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,0);
    }else {
        cell.lineView.frame = CGRectMake(cell.lineView.frame.origin.x, cell.lineView.frame.origin.y, cell.lineView.frame.size.width,LINE_WH);
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXAddressBookCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.checkBox.selected = !cell.checkBox.selected;
    [self addressBookCell:cell checkBoxSelectIndexNum:cell.index isSelect:cell.checkBox.selected];

}

- (void)addressBookCell:(JXAddressBookCell *)abCell checkBoxSelectIndexNum:(NSInteger)indexNum isSelect:(BOOL)isSelect {
    
    JXAddressBook *ab;
    if (abCell) {
        ab = [[self.letterResultArr objectAtIndex:abCell.index / 1000] objectAtIndex:abCell.index % 1000];
    }else {
        ab = self.abUreadArr[indexNum];
    }
    if (isSelect) {
        [_selectABs addObject:ab];
    }else {
        [_selectABs removeObject:ab];
    }
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
