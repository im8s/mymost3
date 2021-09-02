//
//  JXMoreSelectVC.m
//  shiku_im
//
//  Created by 1 on 2019/4/16.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXMoreSelectVC.h"

@interface JXMoreSelectVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selList;
@property (nonatomic, strong) NSMutableArray *indexArr;

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JXMoreSelectVC

- (instancetype)initWithTitle:(NSString *)title dataArray:(NSArray *)dataArray {
    if (self = [super init]) {
        self.titleStr = title;
        self.dataArray = dataArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    self.baseView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.baseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.baseView];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
//    [self.baseView addGestureRecognizer:tap];

    CGFloat height = self.dataArray.count *44+44*2;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(40, (JX_SCREEN_HEIGHT-height)/2, JX_SCREEN_WIDTH-40*2, height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.baseView addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.layer.cornerRadius = 7.f;
    self.tableView.layer.masksToBounds = YES;

    
    
    self.indexArr = [NSMutableArray arrayWithArray:[self.indexStr componentsSeparatedByString:@","]];
    [self.indexArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj intValue] == 0) {
            [self.indexArr removeObject:obj];
        }
    }];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    title.text = self.titleStr;
    title.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = title;
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 44)];
    [sureBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [sureBtn setTitleColor:HEXCOLOR(0x383893) forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(clickSureBtn) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = sureBtn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"moreSelectView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (NSNumber *index in self.indexArr) {
        if ([index integerValue] == indexPath.row+1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.indexArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj intValue] == indexPath.row+1) {
                [self.indexArr removeObject:obj];
            }
        }];
    }else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.indexArr addObject:@(indexPath.row+1)];
    }
    NSLog(@"self.indexArr = %@",self.indexArr);
}


- (void)clickSureBtn {
    NSString *str = [self.indexArr componentsJoinedByString:@","];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(didSureBtn:indexStr:)]) {
        [self.delegate didSureBtn:self indexStr:str];
        [self hideView];
    }
}

- (void)hideView {
    if (self) {
        [self.view removeFromSuperview];
    }
}

@end
