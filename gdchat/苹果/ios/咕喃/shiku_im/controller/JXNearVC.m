//
//  JXNearVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXNearVC.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "JXTopMenuView.h"
#import "QCheckBox.h"
#import "JXConstant.h"
#import "JXSearchUserVC.h"
#import "selectProvinceVC.h"
#import "JXUserInfoVC.h"
#import "searchData.h"
//#import "JXCell.h"
#import "MJRefresh.h"
#import "JXNearCell.h"
#import "JXTopSiftJobView.h"
#import "JXLocMapVC.h"
#import "JXGooMapVC.h"
#import "JXNearTableViewCell.h"
#import "JXLocationVC.h"
//#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//只引入所需的单个头文件
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
//#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

@interface JXNearVC () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,JXActionSheetVCDelegate,UITableViewDelegate,UITableViewDataSource,BMKMapViewDelegate,BMKLocationManagerDelegate>
{
    JXTopSiftJobView *_topSiftView; //表头筛选控件
    int _selMenu;

    BOOL _isLoading;
    BOOL _selected; //cell点击延时,防止多次快速点击
    BOOL _isNoMoreData;
    
    JXCollectionView *_collectionView;
    MJRefreshHeaderView *_refreshHeader;
    MJRefreshFooterView *_refreshFooter;
    BMKMapView * _imageMapView;
    BMKLocationManager *_locService;
    
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *nearArray;
//@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, assign) NSInteger selectNum;
@property (nonatomic, assign) double locX;
@property (nonatomic, assign) double locY;
@end

@implementation JXNearVC

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
        _nearArray = [NSMutableArray array];
//        _userArray = [NSMutableArray array];
        
        _selMenu = 0;
        _page=0;
        _isLoading=0;
        
        [g_notify addObserver:self selector:@selector(searchAddUser:) name:kSeachAddUserNotification object:nil];
        [g_notify addObserver:self selector:@selector(refreshCallPhone:) name:kNearRefreshCallPhone object:nil];
        
    }
    return self;
}

- (void)refreshCallPhone:(NSNotification *)notif {
    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.selectNum inSection:0], nil]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if (!self.isSearch) {
//        [self scrollToPageUp];
//    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableBody.backgroundColor = THEMEBACKCOLOR;
    [self createHeadAndFoot];
    CGRect frame = self.tableBody.frame;
    if (!_isSearch) {
        frame.origin.y += 40;
        
        frame.size.height -= 40;
        
        self.title = Localized(@"JXNearVC_NearHere");
    }else {
        self.title = Localized(@"JXNearVC_AddFriends");
    }
    
    self.tableBody.frame = frame;
    
    [self customView];
    
//    UIButton* btn = [UIFactory createButtonWithImage:@"search" highlight:nil target:self selector:@selector(onSearch)];
//    btn.custom_acceptEventInterval = 1.0f;
//    btn.frame = CGRectMake(JX_SCREEN_WIDTH-100, JX_SCREEN_TOP - 38, 30, 30);
//    [self.tableHeader addSubview:btn];
//
  UIButton* btn  = [UIFactory createButtonWithRect:CGRectMake(JX_SCREEN_WIDTH-50, JX_SCREEN_TOP - 38, 40, 30) title:Localized(@"JX_Screening") titleFont:SYSFONT(16) titleColor:THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor] normal:nil selected:nil selector:@selector(onScreening) target:self];
    btn.custom_acceptEventInterval = 1.0f;

    [self.tableHeader addSubview:btn];
    
    _search = [[searchData alloc] init];
    _search.minAge = 0;
    _search.maxAge = 200;
    _search.sex = -1;
    
    [self scrollToPageUp];
//    [self initBaiduMapView];
}
- (void)initBaiduMapView{
    _imageMapView = [[BMKMapView alloc]init];
    _imageMapView.delegate = self;
//    [self.view addSubview:_imageMapView];
//    [_imageMapView release];
    _imageMapView.zoomLevel = 13;
    _imageMapView.showsUserLocation = YES;
//    [_imageMapView updateLocationData:userLocation];
    //定位服务
    if (_locService == nil) {
        _locService = [[BMKLocationManager alloc] init];
        _locService.delegate = self;
        _locService.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locService.desiredAccuracy = kCLLocationAccuracyBest;
    }
    [_locService startUpdatingLocation];
}
- (void) customView {
    //顶部筛选控件
    _topSiftView = [[JXTopSiftJobView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 40)];
    _topSiftView.delegate = self;
    _topSiftView.isShowMoreParaBtn = NO;
    _topSiftView.preferred = _selMenu;
    _topSiftView.dataArray = [[NSArray alloc] initWithObjects:Localized(@"JXNearVC_NearPer"),Localized(@"JXNearVC_Map"), nil];

    [self.view addSubview:_topSiftView];
    
    
    [self.view addSubview:self.tableView];
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    _collectionView = [[JXCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.tableBody.frame.size.height)collectionViewLayout:layout];
//    _collectionView.frame = self.tableBody.frame;
//    _collectionView.backgroundColor = THEMEBACKCOLOR;
//    _collectionView.contentSize = CGSizeMake(0, self.tableBody.frame.size.height+10);
//    _collectionView.delegate = self;
//    _collectionView.dataSource = self;
//    [_collectionView registerClass:[JXNearCell class] forCellWithReuseIdentifier:NSStringFromClass([JXNearCell class])];
//    [self.view addSubview:_collectionView];
//    _refreshHeader = [MJRefreshHeaderView header];
//    _refreshFooter = [MJRefreshFooterView footer];
//    [self addRefreshViewWith:_collectionView header:_refreshHeader footer:_refreshFooter];
}

- (void)onScreening {
    JXActionSheetVC *actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_OnlySeeFemale"),Localized(@"JX_OnlyLookAtMen"),Localized(@"JX_NoGender")]];
    actionVC.delegate = self;
    [self presentViewController:actionVC animated:NO completion:nil];

}

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    [_wait start];
    if (index == 2) {
        _search.sex = -1;
    }else {
        _search.sex = (int)index;
    }
    [self scrollToPageUp];
}


//添加刷新控件
- (void)addRefreshViewWith:(UICollectionView *)collectionView header:(MJRefreshHeaderView *)header footer:(MJRefreshFooterView *)footer{
    header.scrollView = collectionView;
    footer.scrollView = collectionView;
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_selMenu == 0) {
        return _nearArray.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JXNearTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXNear"];
    if (_selMenu == 0) {
        if (_nearArray.count) {
            [cell doRefreshNearExpert:[_nearArray objectAtIndex:indexPath.row]];
        }
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
       if (_selected == false) {   //防多次快速点击cell
            _selected = true;
            //点击过一次之后。5秒再让cell点击可以响应
            [self performSelector:@selector(changeDidSelect) withObject:nil afterDelay:0.2];
            
            NSDictionary* d;
            if (_selMenu == 0) {
                d = [_nearArray objectAtIndex:indexPath.row];
            }
            self.selectNum = indexPath.row;
    //        else if (_selMenu == 2) {
    //            d = [_userArray objectAtIndex:indexPath.row];
    //        }
    //        [_array objectAtIndex:indexPath.row];
    //        [g_server getUser:[d objectForKey:@"userId"] toView:self];
            JXUserInfoVC* vc = [JXUserInfoVC alloc];
            vc.userId       = [d objectForKey:@"userId"];
            vc.fromAddType = 6;
            vc = [vc init];
            [g_navigation pushViewController:vc animated:YES];
            d = nil;
        }
    
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
//    return _array.count;
    if (_selMenu == 0) {
        return _nearArray.count;
    }
    return 0;
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
    if (_selMenu == 0) {
        if (_nearArray.count) {
            [cell doRefreshNearExpert:[_nearArray objectAtIndex:indexPath.row]];
        }
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
    
    if (_selected == false) {   //防多次快速点击cell
        _selected = true;
        //点击过一次之后。5秒再让cell点击可以响应
        [self performSelector:@selector(changeDidSelect) withObject:nil afterDelay:0.2];
        
        NSDictionary* d;
        if (_selMenu == 0) {
            d = [_nearArray objectAtIndex:indexPath.row];
        }
        self.selectNum = indexPath.row;
//        else if (_selMenu == 2) {
//            d = [_userArray objectAtIndex:indexPath.row];
//        }
//        [_array objectAtIndex:indexPath.row];
//        [g_server getUser:[d objectForKey:@"userId"] toView:self];
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.userId       = [d objectForKey:@"userId"];
        vc.fromAddType = 6;
        vc = [vc init];
        [g_navigation pushViewController:vc animated:YES];
        d = nil;
    }
}
-(void)changeDidSelect{
    _selected = false;
}



- (void)dealloc {
//    NSLog(@"JXNearVC.dealloc");
//    [_search release];
//    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}

-(void)changeToMap{
    //创建地图视图
    [self createMap];
   
}

-(void)createMap{
//    NSString *countryCode = [[NSUserDefaults standardUserDefaults] objectForKey:kISOcountryCode];
//    if ([countryCode isEqualToString:@"CN"] || !countryCode) {
    
//        if (!_mapVC) {
//            _mapVC = [[JXLocMapVC alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.tableBody.frame.size.height) andType:2];
//            [self.view addSubview:_mapVC.view];
//        }
//        _mapVC.view.frame = self.tableBody.frame;
//        _mapVC.view.hidden = NO;
        
//    }else {
//    BOOL isShowGoo = [g_default boolForKey:kUseGoogleMap];
    if (g_config.isChina) {
        if (!_mapVC) {
            _mapVC = [[JXLocMapVC alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.tableBody.frame.size.height) andType:2];
            [self.view addSubview:_mapVC.view];
        }
        _mapVC.search = _search;
        _mapVC.view.frame = self.tableBody.frame;
        _mapVC.view.hidden = NO;
        [_mapVC getDataByCurrentLocation];
    } else {
        if (!_goomapVC) {
            _goomapVC = [[JXGooMapVC alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, self.tableBody.frame.size.height) andType:2];
            [self.view addSubview:_goomapVC.view];
        }
        _goomapVC.search = _search;
        _goomapVC.view.frame = self.tableBody.frame;
        _goomapVC.view.hidden = NO;
        [_goomapVC getDataByCurrentLocation];
    }
    

    
        //AppStore上线ipv6被拒,先隐藏google地图
//        [self checkAfterScroll:0];
//        [_topSiftView resetAllParaBtn];
//    }
}
-(void)getServerData{
    [_wait start];
//    self.isShowFooterPull = _selMenu == 1;
    if (_selMenu == 0) {
        
        self.tableView.hidden = NO;
//        [_refreshHeader beginRefreshing];
        //18938880001
        if ([g_myself.telephone isEqualToString:@"18938880001"]) {
            [g_server nearbyNewUser:_search nearOnly:_bNearOnly page:_page toView:self];
        }else {
            [g_server nearbyUser:_search nearOnly:_bNearOnly lat:self.locX lng:self.locY page:_page toView:self];

        }
    
    }else if(_selMenu == 1){
        self.tableView.hidden = YES;
        //Map
        [_wait stop];
        [self changeToMap];
        
    }
//    else if(_selMenu == 2){
//        //新用户
//        [g_server nearbyNewUser:_search nearOnly:_bNearOnly page:_page toView:self];
//    }
}

//顶部刷新获取数据
-(void)scrollToPageUp{
    if(_isLoading)
        return;
    _page = 0;
//    _search = nil;
    _bNearOnly = YES;
    [self getServerData];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:1.0];
}

-(void)scrollToPageDown{
    if(_isLoading)
        return;
    if (!_isNoMoreData) {
        _page++;
    }
    [self getServerData];
}

- (void)stopLoading {
    _isLoading = NO;
    [_refreshHeader endRefreshing];
    [_refreshFooter endRefreshing];
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    [self stopLoading];
    
    
    if([aDownload.action isEqualToString:act_nearbyUser] || [aDownload.action isEqualToString:act_nearNewUser]){
        BOOL scrollToTop = NO;
        if (_isNoMoreData) {
            _isNoMoreData = NO;
            scrollToTop = YES;
        }
        
        if(_page == 0){
//            [_array removeAllObjects];
//            [_array addObjectsFromArray:array1];
            [_nearArray removeAllObjects];
            [_nearArray addObjectsFromArray:array1];
        }else{
            if([array1 count]>0){
                [_nearArray addObjectsFromArray:array1];
            }else{//刷新到最后没有数据，重新配置参数，加载所有
                [g_App showAlert:Localized(@"JX_NotMoreData")];
                _isNoMoreData = YES;
                _bNearOnly = YES;
                _search = nil;
                _search = [[searchData alloc] init];
                
                _search.sex = -1;
                _page=0;
            }
            
        }
//        _refreshCount++;
//        [_table reloadData];
//        self.isShowFooterPull = [array1 count]>=jx_page_size;
        [self.tableView reloadData];
        if (scrollToTop) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
//        [_collectionView reloadData];
//        if (scrollToTop)
//            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        
    }else if([aDownload.action isEqualToString:act_UserGet]){
        JXUserObject* user = [[JXUserObject alloc]init];
        [user getDataFromDict:dict];
        
        JXUserInfoVC* vc = [JXUserInfoVC alloc];
        vc.user       = user;
        vc.fromAddType = 6;
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
    [self stopLoading];
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait stop];
    [self stopLoading];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}

//-(void)buildMenu{
//    _tb = [JXTopMenuView alloc];
//    _tb.items = [NSArray arrayWithObjects:@"最新",@"最热",@"附近",nil];
//    _tb.delegate = self;
//    _tb.onClick  = @selector(actionSegment:);
//    [_tb initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 44)];
//    [_tb selectOne:0];
//    [self.tableHeader addSubview:_tb];
////    [_tb release];
//}

//-(void)actionSegment:(UIButton*)sender{
//    [_array removeAllObjects];
////    _refreshCount++;
////    [_table reloadData];
//    [_collectionView reloadData];
//    [self scrollToPageUp];
//}


/**
 消息列表添加好友的搜索
 */
-(void)searchAddUser:(NSNotification *)notificition{
    [g_mainVC doSelected:2];
    
    searchData * searchData = notificition.object;
    [self doSearch:searchData];

}

-(void)onSearch{
//    [_topSiftView resetItemBtnWith:0];
//    [_topSiftView moveBottomSlideLine:0];
//    [_topSiftView resetBottomLineIndex:0];
    
    JXSearchUserVC* vc = [[JXSearchUserVC alloc]init];
    vc.delegate  = self;
    vc.didSelect = @selector(doSearch:);
//    [g_window addSubview:vc.view];
    [g_navigation pushViewController:vc animated:YES];
}

-(void)doSearch:(searchData*)p{

    _search = p;
    _bNearOnly = NO;
    _isSearch = YES;
    _page = 0;
    _selMenu = 0;
    [_topSiftView resetBottomLineIndex:0];
    [self checkAfterScroll:0];
    [self getServerData];
}

-(void)onHeadImage:(UIView*)sender{
}

//筛选点击
- (void)topItemBtnClick:(UIButton *)btn{
    [self checkAfterScroll:(btn.tag-100)];
    [_topSiftView resetAllParaBtn];
}

- (void)checkAfterScroll:(CGFloat)offsetX{
    if (offsetX == 0) {
        self.tableView.hidden = NO;
        _selMenu = 0;
        if (_nearArray.count <= 0) {
            if (!_isSearch) {
                [self scrollToPageUp];
            }
        }else {
            [_collectionView reloadData];
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
        _mapVC.view.hidden = YES;
        _goomapVC.view.hidden = YES;
    }else if (offsetX == 1){
        self.tableView.hidden = YES;
        _selMenu = 1;
        [self changeToMap];
        [_topSiftView resetBottomLineIndex:1];
    }
//    else if (offsetX == 2){
//        _selMenu = 2;
////        _page=0;
//        _search = nil;
//        _search = [[searchData alloc] init];
//        _search.minAge = 0;
//        _search.maxAge = 200;
//        _search.sex = -1;
//        _bNearOnly = NO;
//
//        if (_userArray.count <= 0) {
//            [self scrollToPageUp];
//        }else {
//            [_collectionView reloadData];
//            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//        }
//
//        _mapVC.view.hidden = YES;
//        _goomapVC.view.hidden = YES;
//    }
    
}
#pragma mark BMKLocationServiceDelegate

-(void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error{
    
//        self.locY = location.location.coordinate.longitude;
//        self.locX = location.location.coordinate.latitude;

//    self.locX = 30.618153;
//    self.locY = 104.0719;
    
    g_server.latitude = self.locX;
    g_server.longitude = self.locY;
    [_locService stopUpdatingLocation];
    [self getServerData];
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
       

    
}
-(UITableView *) tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.tableBody.frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = RGB(245, 245, 245);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.estimatedSectionFooterHeight = 0;
        [_tableView registerNib:[UINib nibWithNibName:@"JXNearTableViewCell" bundle:nil] forCellReuseIdentifier:@"JXNear"];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _tableView;
}
@end
