//
//  selectCountryVC.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "selectCountryVC.h"
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
#import "selectProvinceVC.h"

#define row_height 40

@interface selectCountryVC ()

@end

@implementation selectCountryVC
@synthesize showProvince;
@synthesize selected;
@synthesize delegate;
@synthesize didSelect;
@synthesize selValue;
@synthesize showArea;

- (id)init
{
    self = [super init];
    if (self) {
        self.showProvince = YES;
        self.provinceId = 0;
        self.areaId   = 0;
        self.cityId   = 0;
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack   = YES;
        self.title = Localized(@"selectCountryVC_SelCountry");
        //self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        [self createHeadAndFoot];
        self.isShowFooterPull = NO;
        self.isShowHeaderPull = NO;
        
        _table.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)dealloc{
    self.selValue = nil;
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
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [g_constant.country_name count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"msg_%d_%ld",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil){
        cell = [UITableViewCell alloc];
        [_table addToPool:cell];
        cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 300, row_height)];
        NSString* s;
        s = [g_constant.country_name objectAtIndex:indexPath.row];
        p.text = s;
        p.font = g_factory.font16;
        [cell addSubview:p];
//        [p release];
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(18,row_height-LINE_WH,JX_SCREEN_WIDTH-18-20,LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [cell addSubview:line];
//        [line release];
        
        UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_flag"]];
        iv.frame = CGRectMake(JX_SCREEN_WIDTH-20, (row_height-13)/2, 7, 13);
        [cell addSubview:iv];
//        [iv release];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selValue = [g_constant.country_name objectAtIndex:indexPath.row];
    self.selected = [[g_constant.country_value objectAtIndex:indexPath.row] intValue];
    if(self.showProvince){
        selectProvinceVC* vc = [selectProvinceVC alloc];
        vc.parentName = self.selValue;
        vc.parentId = self.selected;
        vc.didSelect = @selector(doSelect:);
        vc.showCity = YES;
        vc.showArea = YES;
        vc.delegate = self;
        vc = [vc init];
//        [g_window addSubview:vc.view];
        [g_navigation pushViewController:vc animated:YES];
        return;
    }
    if (delegate && [delegate respondsToSelector:didSelect])
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    [self actionQuit];
}

-(void)doSelect:(selectProvinceVC*)sender{
    if(sender.selected==sender.parentId)
        self.selValue = sender.selValue;
    else
        self.selValue = [NSString stringWithFormat:@"%@.%@",self.selValue,sender.selValue];
    self.provinceId = sender.parentId;
    self.cityId = sender.cityId;
    self.areaId = sender.areaId;
    self.selected = sender.selected;
    if (delegate && [delegate respondsToSelector:didSelect])
//        [delegate performSelector:didSelect withObject:self];
        [delegate performSelectorOnMainThread:didSelect withObject:self waitUntilDone:NO];
    [self actionQuit];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return row_height;
}

@end
