//
//  selectProvinceVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "selectProvinceVC.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
//#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXTableView.h"
#import "JXNewFriendViewController.h"
#import "menuImageView.h"
#import "JXConstant.h"
#import "selectCityVC.h"
#import <CoreLocation/CoreLocation.h>
#define row_height 40

@interface selectProvinceVC ()<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocationManager *locationManager;
@property(nonatomic,strong)NSMutableString * cityName;
@end

@implementation selectProvinceVC
@synthesize showCity;
@synthesize selected;
@synthesize delegate;
@synthesize didSelect;
@synthesize selValue;
@synthesize showArea;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.provinceId = 0;
        self.areaId   = 0;
        self.cityId   = 0;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack   = YES;
        self.title =Localized(@"selectProvinceVC_SelProvince");
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.isShowFooterPull = NO;
        self.isShowHeaderPull = NO;
        self.cityName = [[NSMutableString alloc]initWithString:Localized(@"selectProvinceVC_Locationing")];
        if(self.parentId<=0)
            self.parentId = 1;
        _province = [g_constant getProvince:self.parentId];

        _table.backgroundColor = [UIColor whiteColor];
        _array = [[NSMutableDictionary alloc]init];
        //定位方法
        if ([g_config.isOpenPositionService intValue] == 0) {
            [self locate];
        }
        [_array setObject:Localized(@"selectProvinceVC_Beijing") forKey:@"110100"];//110000,110100
        [_array setObject:Localized(@"selectProvinceVC_Shanghai") forKey:@"310100"];//310000,310100
        [_array setObject:Localized(@"selectProvinceVC_Guangzhou") forKey:@"440100"];//440000,440100
        [_array setObject:Localized(@"selectProvinceVC_Shenzhen") forKey:@"440300"];//440000,440300
    }
    return self;
}

-(void)dealloc{
    self.parentName = nil;
    self.selValue = nil;
//    [_province release];
    [_array removeAllObjects];
//    [_array release];
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, row_height)];
    v.backgroundColor = HEXCOLOR(0xF2F2F2);
    
    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
    NSString* s;
    switch (section) {
        case 0:
            s = Localized(@"selectProvinceVC_NowLocation");
            break;
        case 1:
            s = Localized(@"selectProvinceVC_HotCity");
            break;
        case 2:
            s = Localized(@"selectProvinceVC_SelCity");
            break;
    }
    p.text = s;
    p.font = g_factory.font15;
    p.textColor = HEXCOLOR(0x999999);
    [v addSubview:p];

    [_table addToPool:v];
    return v;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n;
    switch (section) {
        case 0:
            n = 1;
            break;
        case 1:
            n = [[_array allKeys] count];
            break;
        case 2:
            n = [[_province allKeys] count];
            break;
    }
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld_%ld",_refreshCount,indexPath.row,(long)indexPath.section];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
//    if(cell==nil){
        cell = [UITableViewCell alloc];
        [_table addToPool:cell];
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
        NSMutableString* s;
        switch (indexPath.section) {
            case 0:
                s = self.cityName;
                break;
            case 1:
                s = [[_array allValues] objectAtIndex:indexPath.row];
                break;
            case 2:
                s = [g_constant.province_name objectAtIndex:indexPath.row];
                break;
        }
        p.text = s;
        p.font = g_factory.font16;
        [cell addSubview:p];
//        [p release];
    
        if([self tableView:_table numberOfRowsInSection:indexPath.section] != indexPath.row+1){
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake(18,row_height-1,JX_SCREEN_WIDTH-18-20,LINE_WH)];
            line.backgroundColor = THE_LINE_COLOR;
            [cell addSubview:line];
//            [line release];
        }
        if(indexPath.section==2){
            UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_flag"]];
            iv.frame = CGRectMake(JX_SCREEN_WIDTH-20, (row_height-13)/2, 7, 13);
            [cell addSubview:iv];
//            [iv release];
        }
//    }
    
//   //清除cell上所有空间
//    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
//    for (UIView *subview in subviews) {
//        [subview removeFromSuperview];
//    }
//    [subviews release];
//    
//    
//    
//    //重新添加定位后的Label
//    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
//    
//    p.text = self.cityName;
//    p.font = g_factory.font14;
//    
//    [cell addSubview:p];
//    [p release];
//    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if(indexPath.section==0){
        self.selValue = self.cityName;
//        NSLog(@"%@",g_constant.cityN);
        
        //市
        NSString * cityNameS = [NSString stringWithFormat:@"%@%@",self.cityName,Localized(@"selectProvinceVC_City")];
        //县
        NSString * cityNameX = [NSString stringWithFormat:@"%@%@",self.cityName,Localized(@"selectProvinceVC_County")];
        //区
        NSString * cityNameQ = [NSString stringWithFormat:@"%@%@",self.cityName,Localized(@"selectProvinceVC_Area")];
        
        if ([g_constant.cityN valueForKey:self.cityName]) {
            self.cityId = [[g_constant.cityN valueForKey:self.cityName] intValue];
            self.provinceId = [[g_constant.cityN valueForKey:self.cityName] intValue];
        }else if ([g_constant.cityN valueForKey:cityNameS]){
            self.cityId = [[g_constant.cityN valueForKey:cityNameS] intValue];
            self.provinceId = [[g_constant.cityN valueForKey:cityNameS] intValue];
        }else if ([g_constant.cityN valueForKey:cityNameX]){
            self.cityId = [[g_constant.cityN valueForKey:cityNameX] intValue];
            self.provinceId = [[g_constant.cityN valueForKey:cityNameX] intValue];
        }else if ([g_constant.cityN valueForKey:cityNameQ]){
            self.cityId = [[g_constant.cityN valueForKey:cityNameQ] intValue];
            self.provinceId = [[g_constant.cityN valueForKey:cityNameQ] intValue];
        }
        
        else{
            if ([self.cityName isEqualToString:Localized(@"selectProvinceVC_Locationing")]|| [self.cityName isEqualToString:@""]) {
                self.selValue = Localized(@"selectProvinceVC_LocationFiled");
            }
            self.cityId = 1;
            self.provinceId = 1;
        }
//        self.provinceId = 1;
    }
    if(indexPath.section==1){
        self.selValue = [[_array allValues] objectAtIndex:indexPath.row];
        self.selected = [[[_array allKeys] objectAtIndex:indexPath.row] intValue];
        self.provinceId = [[g_constant getParentWithCityId:self.selected] intValue];
        self.cityId = self.selected;
    }
    if(indexPath.section==2){
        self.selValue = [g_constant.province_name objectAtIndex:indexPath.row];
        self.selected = [[g_constant.province_value objectAtIndex:indexPath.row] intValue];
        self.provinceId = self.selected;
        if(self.showCity){
            selectCityVC* vc = [selectCityVC alloc];
            vc.parentName = self.selValue;
            vc.parentId = self.selected; 
            vc.didSelect = @selector(doSelect:);
            vc.delegate = self;
            vc.showArea = self.showArea;
            vc = [vc init];
//            [g_window addSubview:vc.view];
            [g_navigation pushViewController:vc animated:YES];
            return;
        }
    }
    if (delegate && [delegate respondsToSelector:didSelect])
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    [self actionQuit];
}

//-(NSInteger)getCityIdForCity:(NSString*)cityName{
//    int n = 0;
//    
//    for (id key in [g_constant.city allValues]) {
//        
//        if ([cityName isEqualToString:value]) {
//            
//        }
//    }
//    
//    
//    
//    return 1;
//}

-(void)doSelect:(selectCityVC*)sender{
    [self actionQuit];
    if(sender.selected==sender.parentId)
        self.selValue = sender.selValue;
    else
        self.selValue = [NSString stringWithFormat:@"%@-%@",self.selValue,sender.selValue];
    self.provinceId = sender.parentId;
    self.cityId = sender.cityId;
    self.areaId = sender.areaId;
    self.selected = sender.selected;
    if (delegate && [delegate respondsToSelector:didSelect])
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return row_height;
}

#pragma mark - 定位方法
- (void)locate

{
    
    // 判断定位操作是否被允许
    
    if([CLLocationManager locationServicesEnabled]) {
        
        self.locationManager = [[CLLocationManager alloc] init] ;
        
        self.locationManager.delegate = self;
        
    }else {
        
        //提示用户无法进行定位操作
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  
                                  Localized(@"JX_Tip") message:Localized(@"JXServer_CannotLocation") delegate:nil cancelButtonTitle:Localized(@"JX_Cencal") otherButtonTitles:Localized(@"JX_Confirm"), nil];
        
        [alertView show];
        
    }
    
    // 开始定位
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
}


//实现定位协议回调方法
#pragma mark - CoreLocation Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations

{
    
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    
    CLLocation *currentLocation = [locations lastObject];
    
    // 获取当前所在的城市名
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //根据经纬度反向地理编译出地址信息
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     
    {
        
        if (array.count > 0)
            
        {
            
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            //将获得的所有信息显示到label上
            
//            NSLog(@"%@",placemark.name);
            
            //获取城市
            
            NSString *city = placemark.locality;
            
            if (!city) {
                
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                
                city = placemark.administrativeArea;
                
            }
            if (city) {
                self.cityName = [NSMutableString stringWithString:city];
            }
            
            [_table reloadData];

        }
        
        else if (error == nil && [array count] == 0)
            
        {
            
//            NSLog(@"No results were returned.");
            
        }
        
        else if (error != nil)
            
        {
            
//            NSLog(@"An error occurred = %@", error);
            
        }
        
    }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
  
    
    
    [manager stopUpdatingLocation];
    
}
//
//- (void)locationManager:(CLLocationManager *)manager
//
//       didFailWithError:(NSError *)error {
//    
//    if (error.code == kCLErrorDenied) {
//        
//        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
//        
//    }
//    
//}



@end
