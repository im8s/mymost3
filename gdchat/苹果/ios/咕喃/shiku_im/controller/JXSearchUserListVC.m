//
//  JXSearchUserListVC.m
//  lveliao_IM
//
//  Created by p on 2018/4/18.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXSearchUserListVC.h"
#import "JXNearCell.h"
#import "JXUserInfoVC.h"
#import "JXSearchUserVC.h"
#import "JXNearTableViewCell.h"

@interface JXSearchUserListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{

    JXCollectionView *_collectionView;
    MJRefreshHeaderView *_refreshHeader;
    MJRefreshFooterView *_refreshFooter;
}
@property (nonatomic, strong) NSMutableArray *array;
//@property (nonatomic,assign) int page;
@property (nonatomic, assign) NSInteger selectNum;
@end

@implementation JXSearchUserListVC
- (id)init
{
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
        self.isFreeOnClose = YES;
        
        self.isGotoBack = YES;
        
        _array = [[NSMutableArray alloc] init];
        _page=0;
        
        [g_notify addObserver:self selector:@selector(refreshCallPhone:) name:kNearRefreshCallPhone object:nil];
    }
    return self;
}

- (void)refreshCallPhone:(NSNotification *)notif {
//    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.selectNum inSection:0], nil]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索";
    // Do any additional setup after loading the view.
    self.tableView.backgroundColor = THEMEBACKCOLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"JXNearTableViewCell" bundle:nil] forCellReuseIdentifier:@"JXNear"];
    [self createHeadAndFoot];
    [self customView];
    [self getServerData];
}

- (void) customView {
    
    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    _collectionView = [[JXCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.tableView.frame.size.height)collectionViewLayout:layout];
//    _collectionView.frame = self.tableView.frame;
//    _collectionView.backgroundColor = THEMEBACKCOLOR;
//    _collectionView.contentSize = CGSizeMake(0, self.tableView.frame.size.height+10);
//    _collectionView.delegate = self;
//    _collectionView.dataSource = self;
//    [_collectionView registerClass:[JXNearCell class] forCellWithReuseIdentifier:NSStringFromClass([JXNearCell class])];
//    [self.view addSubview:_collectionView];
    _refreshHeader = [MJRefreshHeaderView header];
    _refreshFooter = [MJRefreshFooterView footer];
    [self addRefreshViewWith:_collectionView header:_refreshHeader footer:_refreshFooter];
}

//添加刷新控件
- (void)addRefreshViewWith:(UICollectionView *)collectionView header:(MJRefreshHeaderView *)header footer:(MJRefreshFooterView *)footer{
    header.scrollView = self.tableView;
    footer.scrollView = self.tableView;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self scrollToPageUp];
        _page = 0;
        //        [self getServerData];
    };
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [self scrollToPageDown];
        //        [self getServerData];
    };
}
//顶部刷新获取数据
-(void)scrollToPageUp{
    _page = 0;
    [self getServerData];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0];
}

-(void)scrollToPageDown{
    _page++;
    [self getServerData];
}

- (void)stopLoading {
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
}

-(void)getServerData{
    [_wait start];
    if (_isUserSearch) {
        [g_server nearbyUser:_search nearOnly:NO lat:0 lng:0 page:_page toView:self];
    }else {
        [g_server searchPublicWithKeyWorld:_keyWorld limit:20 page:_page toView:self];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
        return self.array.count;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JXNearTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXNear"];
   
    if (self.array.count) {
        [cell doRefreshNearExpert:[self.array objectAtIndex:indexPath.row]];
    }
    
//    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
     self.selectNum = indexPath.row;
    NSDictionary* d;
    d = [_array objectAtIndex:indexPath.row];
//    [g_server getUser:[d objectForKey:@"userId"] toView:self];
    int fromAddType = 0;
    NSString *name = [d objectForKey:@"nickname"];
    if ([name rangeOfString:_keyWorld].location == NSNotFound) {
        fromAddType = 4;
    }else {
        fromAddType = 5;
    }
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId = [d objectForKey:@"userId"];
    vc.fromAddType = fromAddType;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    d = nil;
        
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
}
#pragma mark UICollectionView delegate
#pragma mark-----多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
#pragma mark-----多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _array.count;
}
#pragma mark-----每一个的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((JX_SCREEN_WIDTH - 30)/2, (JX_SCREEN_WIDTH - 30)/2 + 65);
}
#pragma mark-----每一个边缘留白
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 0, 10);
}
#pragma mark-----最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma mark-----最小竖间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10.0;
}
#pragma mark-----返回每个单元格是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark-----创建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JXNearCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([JXNearCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    //        cell.delegate = self;
    //        cell.didTouch = @selector(onHeadImage:);
    //        if (_array.count)
    //            [cell doRefreshNearExpert:[_array objectAtIndex:indexPath.row]];
    if (_array.count) {
        [cell doRefreshNearExpert:[_array objectAtIndex:indexPath.row]];
    }
    //    else if (_selMenu == 2) {
    //        if (_userArray.count) {
    //            [cell doRefreshNearExpert:[_userArray objectAtIndex:indexPath.row]];
    //        }
    //    }
    
    return cell;
    
}
#pragma mark-----点击单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    [self stopAllPlayer];
    
    self.selectNum = indexPath.row;
    NSDictionary* d;
    d = [_array objectAtIndex:indexPath.row];
//    [g_server getUser:[d objectForKey:@"userId"] toView:self];
    int fromAddType = 0;
    NSString *name = [d objectForKey:@"nickname"];
    if ([name rangeOfString:_keyWorld].location == NSNotFound) {
        fromAddType = 4;
    }else {
        fromAddType = 5;
    }
    JXUserInfoVC* vc = [JXUserInfoVC alloc];
    vc.userId = [d objectForKey:@"userId"];
    vc.fromAddType = fromAddType;
    vc = [vc init];
    [g_navigation pushViewController:vc animated:YES];
    d = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self stopLoading];
    
    if([aDownload.action isEqualToString:act_nearbyUser] || [aDownload.action isEqualToString:act_nearNewUser]||[aDownload.action isEqualToString:act_PublicSearch]){
        
        if(_page == 0){
            //            [_array removeAllObjects];
            //            [_array addObjectsFromArray:array1];
            [_array removeAllObjects];
            [_array addObjectsFromArray:array1];
            
    
//            [g_server showMsg:@"暂无搜索结果"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
////                [g_navigation popToViewController:[JXSearchUserVC class] animated:true];
//                [g_navigation dismissViewController:self animated:YES];
//
//            });
            
            
        }
        else{
            if([array1 count]>0){
                [_array addObjectsFromArray:array1];
            }
        }
//        if (_array.count <= 0 && !_isUserSearch) {
//            [g_App showAlert:Localized(@"JX_NoSuchServerNo.IsAvailable")];
//        }
        
        if (_array.count == 0 && _isUserSearch) {
            [g_App showAlert:@"暂无该好友"];
        }
        else if (_array.count == 0 && !_isUserSearch){
            [g_App showAlert:Localized(@"JX_NoSuchServerNo.IsAvailable")];
        }
        
        
        [self.tableView reloadData];
        
    }
    else if([aDownload.action isEqualToString:act_UserGet]){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.user       = user;
        vc = [vc init];
        //        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        //        [user release];
    }
    //    else if ([aDownload.action isEqualToString:act_nearNewUser]) {
    //        if (_page == 0) {
    ////            [_array removeAllObjects];
    ////            [_array addObjectsFromArray:array1];
    //            [_userArray removeAllObjects];
    //            [_userArray addObjectsFromArray:array1];
    //        }else{
    //            if ([_userArray count] > 0) {
    //                [_userArray addObjectsFromArray:array1];
    //            }else{
    //                [g_App showAlert:Localized(@"JX_NotMoreData")];
    //                _isNoMoreData = YES;
    //                _search = nil;
    //                _search = [[searchData alloc] init];
    //                _search.minAge = 0;
    //                _search.maxAge = 200;
    //                _search.sex = -1;
    //                _page=0;
    //            }
    //
    //        }
    //        [_collectionView reloadData];
    //    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
