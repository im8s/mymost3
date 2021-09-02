//
//  JXSelectFriendVC.m
//  share
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXSelectFriendVC.h"
#import "JXShareUser.h"
#import "JXFriendCell.h"

// 多端登录userId
#define PC_USERID [NSString stringWithFormat:@"%@_pc",g_myself.userId]
#define ANDROID_USERID [NSString stringWithFormat:@"%@_android",g_myself.userId]
#define MAC_USERID [NSString stringWithFormat:@"%@_mac",g_myself.userId]
#define WEB_USERID [NSString stringWithFormat:@"%@_web",g_myself.userId]
#define IOS_USERID [NSString stringWithFormat:@"%@_ios",g_myself.userId]


#define SQUARE_HEIGHT      38      //图片宽高

@interface JXSelectFriendVC () <UITextFieldDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITextField *seekTextField;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JXShareUser *user;
@property (nonatomic, strong) NSArray *data;

@end

@implementation JXSelectFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getData];
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT)];
    baseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:baseView];

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, JX_SCREEN_TOP)];
    [baseView addSubview:headView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(8, JX_SCREEN_TOP - 40, 31, 31)];
    [btn setImage:[UIImage imageNamed:@"share_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];

    UILabel* p = [[UILabel alloc]initWithFrame:CGRectMake(60, JX_SCREEN_TOP - 35, JX_SCREEN_WIDTH-60*2, 20)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = NSTextAlignmentCenter;
    p.text = @"发送给朋友";
    p.font = [UIFont boldSystemFontOfSize:18.0];
    [headView addSubview:p];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP-LINE_WH, JX_SCREEN_WIDTH, LINE_WH)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:line];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT-JX_SCREEN_TOP)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [baseView addSubview:self.tableView];
    
    [self customSearchTextField];
}

- (void)getData {
    self.data = [[JXShareUser shareInstance] getAllUser];
}

- (void)customSearchTextField{
    
    //搜索输入框
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_TOP, JX_SCREEN_WIDTH, 55)];
    [self.view addSubview:backView];
    
    _seekTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, backView.frame.size.width - 30, 35)];
    _seekTextField.placeholder = @"搜索";
    _seekTextField.textColor = [UIColor blackColor];
    [_seekTextField setFont:SYSFONT(14)];
    _seekTextField.backgroundColor = HEXCOLOR(0xf0f0f0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_search"]];
    UIView *leftView = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.center = leftView.center;
    [leftView addSubview:imageView];
    _seekTextField.leftView = leftView;
    _seekTextField.leftViewMode = UITextFieldViewModeAlways;
    _seekTextField.borderStyle = UITextBorderStyleNone;
    _seekTextField.layer.masksToBounds = YES;
    _seekTextField.layer.cornerRadius = 3.f;
    _seekTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _seekTextField.delegate = self;
    _seekTextField.returnKeyType = UIReturnKeyGoogle;
    [backView addSubview:_seekTextField];
    [_seekTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    self.tableView.tableHeaderView = backView;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([_seekTextField isFirstResponder]) {
        [_seekTextField resignFirstResponder];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.data = [[JXShareUser shareInstance] fetchSearchUserWithString:textField.text];
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"JXFriendCell";
    JXFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[JXFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    JXShareUser *user = self.data[indexPath.row];
    [cell setDataWithUser:user];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JXShareUser *user = self.data[indexPath.row];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendToFriendSuccess:user:)]) {
        [self.delegate sendToFriendSuccess:self user:user];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self actionQuit];
        });
    }
}

- (void)actionQuit {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
