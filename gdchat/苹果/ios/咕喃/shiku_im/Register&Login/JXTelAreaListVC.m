//
//  JXTelAreaListVC.m
//  shiku_im
//
//  Created by daxiong on 17/4/24.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXTelAreaListVC.h"
#import "JXMyTools.h"
#import "JXTelAreaCell.h"
#define TELAREA_CELL_HEIGHT 42

@interface JXTelAreaListVC ()<UITextFieldDelegate>
{
    NSString *_language;
}
@property (nonatomic, strong) NSMutableArray *telAreaArray;
@property (nonatomic, strong) UITextField *seekTextField;
@end

@implementation JXTelAreaListVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        self.title = Localized(@"JX_SelectCountryOrArea");
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        
        [self createHeadAndFoot];
        _telAreaArray = [[NSMutableArray alloc] init];
        _telAreaArray = [g_constant.telArea mutableCopy];
        
        [self customView];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _language = [[NSString alloc] initWithFormat:@"%@",g_constant.sysLanguage];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
//    }];
}
- (void) customView {
    self.isShowHeaderPull = NO;
    self.isShowFooterPull = NO;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, TELAREA_CELL_HEIGHT+5)];
    self.tableView.tableHeaderView = headView;
    
    //搜索输入框
    
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 20 - 15, 14, 20, 20)];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"ic_search_history"] forState:UIControlStateNormal];
    //[searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:searchBtn];
    
    UIView *seekBackView = [[UIView alloc] initWithFrame:CGRectMake(15, 6, JX_SCREEN_WIDTH - 30, 35)];
    //    seekBackView.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:62/255.0 blue:55/255.0 alpha:0.1];
    seekBackView.layer.masksToBounds = YES;
    seekBackView.layer.cornerRadius = 3.f;
    seekBackView.backgroundColor = HEXCOLOR(0xF2F2F2);
    [headView addSubview:seekBackView];
    //    [seekBackView release];
    
    
    
    //    UIImageView *seekImgView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 4, 25, 25)];
    //    seekImgView.image = [UIImage imageNamed:@"abc_ic_search_api_mtrl_alpha"];
    //    [seekBackView addSubview:seekImgView];
    //    [seekImgView release];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, seekBackView.frame.size.width-10, 35)];
    _seekTextField.delegate = self;
    _seekTextField.placeholder = Localized(@"JX_EnterCountry");
    //    [_seekTextField setTextColor:[UIColor whiteColor]];
    [_seekTextField setFont:SYSFONT(14)];
    //    [_seekTextField setTintColor:[UIColor whiteColor]];
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [seekBackView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void) textFieldDidChange:(UITextField *)textField {
    
    [_telAreaArray removeAllObjects];
    
    if (textField.text.length > 0) {
        _telAreaArray = [g_constant getSearchTelAreaWithName:textField.text];
        
    }else {
        _telAreaArray = [g_constant.telArea mutableCopy];
    }
    
    [self.tableView reloadData];
}

#pragma mark UITableView delegate
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 8;//_areaArray.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _telAreaArray.count;//[[_areaArray objectAtIndex:section] count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 28;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.01;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TELAREA_CELL_HEIGHT;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    static NSString *identifier = @"header";
//    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
//    if (!header){
//        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
//
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 28)];
//        label.tag = 100;
//        label.font = SYSFONT(16);
//        [header addSubview:label];
//        [label release];
//        label.backgroundColor = THEMEBACKCOLOR;
//    }
//
//    UILabel *label = [header viewWithTag:100];
//    label.text = @"  北美洲";
//
//    return header;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    JXTelAreaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JXTelAreaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    [cell doRefreshWith:[_telAreaArray objectAtIndex:indexPath.row] language:_language];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.telAreaDelegate respondsToSelector:self.didSelect]) {
//        [self.telAreaDelegate performSelector:self.didSelect withObject:[[_telAreaArray objectAtIndex:indexPath.row] objectForKey:@"prefix"]];
        [self.telAreaDelegate performSelectorOnMainThread:self.didSelect withObject:[(NSDictionary *)[_telAreaArray objectAtIndex:indexPath.row] objectForKey:@"prefix"] waitUntilDone:NO];
    }
    [self actionQuit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
