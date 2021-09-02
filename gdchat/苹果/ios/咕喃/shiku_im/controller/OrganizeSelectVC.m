//
//  OrganizeSelectVC.m
//  shiku_im
//
//  Created by IMAC on 2019/8/14.
//  Copyright © 2019 Reese. All rights reserved.
//
#import "OrganizeSelectVC.h"
#import "DepartObject.h"
#import "EmployeObject.h"

#import "RATreeView.h"
#import "OrganizTableViewCell.h"
#import "EmployeeTableViewCell.h"
#import "JX_DownListView.h"

#import "JXAddDepartViewController.h"
#import "JXSelFriendVC.h"
#import "JXSelectFriendsVC.h"
#import "JXUserInfoVC.h"
#import "JXSelDepartViewController.h"
#import "QCheckBox.h"
@interface OrganizeSelectVC ()<RATreeViewDelegate, RATreeViewDataSource,SelDepartDelegate,UIAlertViewDelegate,QCheckBoxDelegate>

@property (nonatomic, strong) NSMutableArray<DepartObject *> * dataArray;
@property (nonatomic, weak) RATreeView * treeView;
@property (nonatomic, strong) UIButton * moreButton;


@property (atomic, strong) id currentOrgObj;
@property (nonatomic, assign) BOOL afterDelCompany;
@property (nonatomic, strong) UIControl * control;

@property (nonatomic, strong) NSMutableDictionary * allDataDict;
@property (nonatomic, strong) NSMutableDictionary * employeesDict;
@property (nonatomic, strong) NSMutableDictionary * companyDict;

@property (nonatomic, copy) NSString * companyId;
@property (nonatomic, copy) NSString * companyName;


@property (nonatomic, copy) void (^rowActionAfterRequestBlock)(id sender);
@property (nonatomic, strong) UIView * noCompanyView;

@property (atomic, strong) id item;

@property (nonatomic, assign) BOOL isNotDele;

@property (nonatomic,strong)NSMutableDictionary *colleagueDic;
@property (nonatomic,strong)NSMutableDictionary *checkBoxDic;

@end

@implementation OrganizeSelectVC
- (id)init
{
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        
        self.title = Localized(@"OrganizVC_Organiz");
        self.tableBody.backgroundColor = THEMEBACKCOLOR;
        self.isFreeOnClose = YES;
        self.isGotoBack = YES;
        _dataArray = [NSMutableArray new];
        _allDataDict = [NSMutableDictionary new];
        _employeesDict = [NSMutableDictionary new];
        _companyDict = [NSMutableDictionary new];
        
        _colleagueDic = [NSMutableDictionary dictionary];
        
        [self createTreeView];
        
        [g_server getCompanyAuto:self];
        
        _checkBoxDic = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    
    UIButton *allSelect = [UIButton buttonWithType:UIButtonTypeSystem];
    [allSelect setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    if (THESIMPLESTYLE) {
        [allSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [allSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    allSelect.tintColor = [UIColor clearColor];
    allSelect.frame = CGRectMake(JX_SCREEN_WIDTH - 70, JX_SCREEN_TOP - 34, 60, 24);
    [allSelect addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:allSelect];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_treeView reloadRows];
}

-(void)createTreeView{
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStylePlain];
    
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.treeFooterView = [UIView new];
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    treeView.estimatedRowHeight = 0;
    treeView.estimatedSectionHeaderHeight = 0;
    treeView.estimatedSectionFooterHeight = 0;
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    [treeView.scrollView addSubview:refreshControl];
    
    [treeView reloadData];
    [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    
    
    self.treeView = treeView;
    treeView.frame = self.tableBody.bounds;
    treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableBody addSubview:treeView];
    
    [treeView registerClass:[OrganizTableViewCell class] forCellReuseIdentifier:NSStringFromClass([OrganizTableViewCell class])];
    [treeView registerClass:[EmployeeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([EmployeeTableViewCell class])];
    
}
- (void)confirmBtnAction:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(selectOrganizeVC:selectArray:)]) {
        [self.delegate selectOrganizeVC:self selectArray:_seletedArray];
    }
    [self actionQuit];
}

#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    if ([item isMemberOfClass:[EmployeObject class]]) {
        return 60;
    }
    return 44;
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    if ([item isMemberOfClass:[DepartObject class]]) {
        OrganizTableViewCell * cell = (OrganizTableViewCell *)[self.treeView cellForItem:item];
        cell.arrowExpand = YES;
    }
}


- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    if ([item isMemberOfClass:[DepartObject class]]) {
        OrganizTableViewCell * cell = (OrganizTableViewCell *)[self.treeView cellForItem:item];
        cell.arrowExpand = NO;
    }
}

#pragma mark 左划手势 -删除
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item
{
    return NO;
}

-(UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(id)item{
    if (treeView.editing)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

}


-(void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item{
    if ([item isMemberOfClass:[EmployeObject class]]){
        QCheckBox *checkBox = nil;
        NSArray *array = [_checkBoxDic allKeys];
        NSInteger user = [((EmployeObject *)item).userId intValue];
        for (NSString *userId in array) {
            QCheckBox *btn = [_checkBoxDic objectForKey:userId];
            if (btn.tag == user + 10086) {
                checkBox = btn;
                break;
            }
        }
        checkBox.selected = !checkBox.selected;
        [self didSelectedCheckBox:checkBox checked:checkBox.selected];
    }else{
        DepartObject * depart = item;
        if (depart.children.count == 0)
            [g_server showMsg:Localized(@"OrgaVC_DepartNoChild") delay:1.8];
    }
}
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    NSString *userId = [NSString stringWithFormat:@"%ld",checkbox.tag - 10086];
    EmployeObject *employe = [_colleagueDic objectForKey:userId];
    if(checked){
        for (NSInteger i = 0; i < _seletedArray.count; i++) {
            EmployeObject *employ1 = _seletedArray[i];
            if ([employ1.userId isEqualToString:employe.userId]) {
                [_seletedArray removeObjectAtIndex:i];
                i = i - 1;
            }
        }
        [_seletedArray addObject:employe];
    }else{
        for (NSInteger i = 0; i < _seletedArray.count; i++) {
            EmployeObject *employer = _seletedArray[i];
            if ([employer isEqual:employe] || [employer.userId isEqualToString:employe.userId]) {
                [_seletedArray removeObjectAtIndex:i];
                i = i - 1;
            }
        }
    }
}
#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    if ([item isMemberOfClass:[DepartObject class]]) {
        DepartObject * dataObject = item;
        BOOL expanded = [self.treeView isCellForItemExpanded:item];
//        OrganizTableViewCell * cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([OrganizTableViewCell class])];
        OrganizTableViewCell *cell = [[OrganizTableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setupWithData:dataObject level:level expand:expanded];
        cell.additionButton.hidden = YES;
        return cell;
    }else if ([item isMemberOfClass:[EmployeObject class]]) {
        EmployeObject * dataObject = item;
        EmployeeTableViewCell *cell = [[EmployeeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCheckBoxCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        BOOL flag = NO;
        for (EmployeObject *employe in _seletedArray) {
            if ([employe.userId isEqualToString:dataObject.userId] && [employe.nickName isEqualToString:dataObject.nickName]) {
                flag = YES;
                break;
            }
        }
        [_colleagueDic setObject:dataObject forKey:dataObject.userId];
        QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
        btn.tag = [dataObject.userId intValue] + 10086;
        btn.checked = flag;
        btn.frame = CGRectMake(JX_SCREEN_WIDTH-40, 17.5, 25, 25);
        [cell addSubview:btn];
        [_checkBoxDic setObject:btn forKey:dataObject.userId];
        [cell setupWithData:dataObject level:level];
        return cell;
    }
    return nil;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.dataArray count];
    }
    
    if ([item isMemberOfClass:[EmployeObject class]]) {
        return 0;
    }else{
        DepartObject * dataObject = item;
        return [dataObject.children count];
    }
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.dataArray objectAtIndex:index];
    }
    if ([item isMemberOfClass:[EmployeObject class]]) {
        return nil;
    }else{
        DepartObject * dataObject = item;
        return dataObject.children[index];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
-(void)dealloc{
    self.rowActionAfterRequestBlock = nil;
}
#pragma mark - Actions

- (void)refreshControlChanged:(UIRefreshControl *)refreshControl
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

#pragma mark alertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            DepartObject * orgObject = _currentOrgObj;
            [g_server quitCompany:orgObject.companyId toView:self];
        }else{
            self.rowActionAfterRequestBlock = nil;
        }
    }else if (alertView.tag == 2001) {
    
    }
}


#pragma mark - selDepart Delegate
-(void)selNewDepartmentWith:(DepartObject *)newDepart{
    EmployeObject * employeeOBJ = _currentOrgObj;
    [g_server modifyDpart:employeeOBJ.userId companyId:employeeOBJ.companyId newDepartmentId:newDepart.departId toView:self];
    
    OrganizTableViewCell * cell = (OrganizTableViewCell *)[self.treeView cellForItem:newDepart];
    if (!cell.arrowExpand) {
        cell.arrowExpand = YES;
        [self.treeView expandRowForItem:newDepart expandChildren:NO withRowAnimation:RATreeViewRowAnimationNone];
    }
    
    __weak typeof(self) weakSelf = self;
    self.rowActionAfterRequestBlock = ^(id sender) {
        DepartObject * oldDepart = [weakSelf.treeView parentForItem:employeeOBJ];
        NSInteger index = [oldDepart.children indexOfObject:employeeOBJ];
        [newDepart addChild:employeeOBJ];
        [oldDepart removeChild:employeeOBJ];
        [weakSelf.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:newDepart withAnimation:RATreeViewRowAnimationNone];
        if (index < 0 || index > (oldDepart.children.count + 1)) {
            [weakSelf.treeView reloadData];
        }else {
            [weakSelf.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:oldDepart withAnimation:RATreeViewRowAnimationNone];
        }

    };
}

-(void)expandAllRows{
    for (DepartObject * depart in _dataArray) {
        if (!depart.parentId.length) {
            [_treeView expandRowForItem:depart expandChildren:NO withRowAnimation:RATreeViewRowAnimationAutomatic];
        }
    }
    [_treeView reloadRows];
}

#pragma mark 获取数据后处理及刷新
/** 自动获取公司成树后reload */
-(void)autoConstructTreeView:(NSArray *)originalArray{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * array = [self getRootArray:originalArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            _dataArray = [NSMutableArray arrayWithArray:array];
            if (_dataArray.count > 0){
                [_treeView reloadData];
                [self performSelector:@selector(expandAllRows) withObject:nil afterDelay:0.1f];

            }
        });
    });
}


#pragma mark 数据成树
/** 所有公司数据 */
-(NSArray <DepartObject *>*) getRootArray:(NSArray *)originalArray{
    NSMutableArray * rootArr = [[NSMutableArray alloc] init];
    for (NSDictionary * companyDict in originalArray) {
        [_companyDict setObject:companyDict forKey:companyDict[@"id"]];
        NSArray * compRootDepartArr = [self constructCompanyObject:companyDict];
        [rootArr addObjectsFromArray:compRootDepartArr];
    }
    return rootArr;
}

/** 公司实体数据 - 返回根部门数组 */
-(NSArray <DepartObject *>*) constructCompanyObject:(NSDictionary *)companyDict{
    NSArray *departDictArr = companyDict[@"departments"];
    //    NSArray * rootDpartArr = companyDict[@"rootDpartId"];
    return [self constructDepartObject:departDictArr];
}
/** 部门列表 */
-(NSArray <DepartObject *>*) constructDepartObject:(NSArray *)departArray{
    NSMutableArray * rootArr = [[NSMutableArray alloc] init];
    NSMutableDictionary * allDataDict = [NSMutableDictionary new];
    NSMutableArray *allDataArr = [NSMutableArray array];
    for (NSDictionary * departData in departArray) {
        if (!departData[@"parentId"]) {
            [rootArr addObject:departData];
            if (![_employeesDict objectForKey:departData[@"companyId"]])
                [_employeesDict setObject:[NSMutableSet set] forKey:departData[@"companyId"]];
        }
        [allDataDict setObject:departData forKey:departData[@"id"]];
        [allDataArr addObject:departData];
    }
    
    //
    for (NSDictionary *departData in departArray) {
        if (departData[@"employees"]) {
            NSMutableSet * emplySet = [_employeesDict objectForKey:departData[@"companyId"]];
            NSArray * emplArr = departData[@"employees"];
            for (NSDictionary * emp in emplArr) {
                if (emp[@"departmentId"] != nil && emp[@"userId"] != nil)
                    [emplySet addObject:[NSString stringWithFormat:@"%@",emp[@"userId"]]];
            }
        }
    }
    
    NSMutableArray * departArr = [[NSMutableArray alloc] init];
    for (NSDictionary * rootData in rootArr) {
        DepartObject * departObj  = [DepartObject departmentObjectWith:rootData allData:allDataArr];
        [departArr addObject:departObj];
    }
    [_allDataDict addEntriesFromDictionary:allDataDict];
    return departArr;
}

#pragma mark - **数据请求**
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if([aDownload.action isEqualToString:act_getCompany]){//自动查找公司
        if (!array1) {
            
        }else{
            [self autoConstructTreeView:array1];
        }
        
    }
}

#pragma mark -
-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait stop];
    self.rowActionAfterRequestBlock = nil;
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    self.rowActionAfterRequestBlock = nil;
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_wait start];
    });
}

@end
