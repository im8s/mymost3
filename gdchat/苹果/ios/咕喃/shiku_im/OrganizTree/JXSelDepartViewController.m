//
//  JXSelDepartViewController.m
//  shiku_im
//
//  Created by 1 on 17/6/1.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXSelDepartViewController.h"
#import "DepartObject.h"
#import "RATreeView.h"
#import "OrganizTableViewCell.h"
#import "EmployeObject.h"

@interface JXSelDepartViewController ()<RATreeViewDelegate, RATreeViewDataSource>

@property (nonatomic, weak) RATreeView * treeView;
@end

@implementation JXSelDepartViewController

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
    }
    return self;
}
//-(void)setDataArray:(NSArray *)dataArray{
//    for (int i = 0; i<dataArray.count; i++) {
//        DepartObject * depart = dataArray[i];
//        depart
//    }
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createHeadAndFoot];
    
    [self createTreeView];
    
    if (_dataArray.count > 0){
        [_treeView reloadData];
        for (DepartObject * depart in _dataArray) {
            [_treeView expandRowForItem:depart expandChildren:YES withRowAnimation:RATreeViewRowAnimationRight];
        }
    }
}

-(void)createTreeView{
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds style:RATreeViewStylePlain];
    
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.treeFooterView = [UIView new];
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    
    //    UIRefreshControl *refreshControl = [UIRefreshControl new];
    //    [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    //    [treeView.scrollView addSubview:refreshControl];
    
//    [treeView reloadData];
    [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    
    
    self.treeView = treeView;
    treeView.frame = self.tableBody.bounds;
    treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableBody addSubview:treeView];
    
    [treeView registerClass:[OrganizTableViewCell class] forCellReuseIdentifier:NSStringFromClass([OrganizTableViewCell class])];
    
}

#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    return 44;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item{
    return NO;
}
- (BOOL)treeView:(RATreeView *)treeView shouldCollapaseRowForItem:(id)item{
    return NO;
}

-(void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item{
    DepartObject * depart = item;
    if ([self.oldDepart.departId isEqualToString:depart.departId]) {
        [JXMyTools showTipView:Localized(@"JX_AlreadyDepartment")];
        return;
    }
    
    if (depart.parentId) {
        [self chooesDepartment:item];
    }
    
//    if (depart.children.count == 0)
//        [g_server showMsg:Localized(@"OrgaVC_DepartNoChild") delay:1.8];
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    //    NSInteger numberOfChildren = [dataObject.children count];

    DepartObject * dataObject = item;
    BOOL expanded = [self.treeView isCellForItemExpanded:item];
    OrganizTableViewCell * cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([OrganizTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setupWithData:dataObject level:level expand:expanded];
    cell.additionButton.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    cell.additionButtonTapAction = ^(id sender){
        if (weakSelf.treeView.isEditing) {
            return;
        }
        [weakSelf chooesDepartment:item];
        //            [weakSelf showDepartDownListView:dataObject];
    };
    
    return cell;
    
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.dataArray count];
    }
    
    if ([item isMemberOfClass:[DepartObject class]]) {
        DepartObject * dataObject = item;
        return [dataObject.departes count];
    }else{
        return 0;
    }
}
- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.dataArray objectAtIndex:index];
    }
    if ([item isMemberOfClass:[DepartObject class]]) {
        DepartObject * dataObject = item;
        return dataObject.departes[index];
    }else{
        return nil;
    }
}

/**
 选择移动到的部门

 @param item 部门对象
 */
-(void)chooesDepartment:(id)item{
    DepartObject * depart = item;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selNewDepartmentWith:)]) {
        [self actionQuit];
        [self.delegate selNewDepartmentWith:depart];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
