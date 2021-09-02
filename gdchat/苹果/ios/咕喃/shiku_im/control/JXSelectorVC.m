//
//  JXSelectorVC.m
//  shiku_im
//
//  Created by p on 2017/8/26.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXSelectorVC.h"

@interface JXSelectorVC ()

@end

@implementation JXSelectorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    //    self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
    self.isGotoBack = YES;
    _table.backgroundColor = HEXCOLOR(0xF2F2F2);
    [self createHeadAndFoot];
    self.isShowFooterPull = NO;
    self.isShowHeaderPull = NO;
    
    //保存按钮
    UIButton *resaveBtn = [[UIButton alloc] init];
    //                           WithFrame:CGRectMake(JX_SCREEN_WIDTH-44-10, 20+12, 44, 20)];
    resaveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [resaveBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    resaveBtn.titleLabel.font = SYSFONT(15);
    resaveBtn.custom_acceptEventInterval = 1.0f;
    [resaveBtn addTarget:self action:@selector(confirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    //resaveBtn.backgroundColor = [UIColor redColor];
    resaveBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [resaveBtn setTitleColor:THESIMPLESTYLE ? [UIColor blackColor] : [UIColor whiteColor] forState:UIControlStateNormal];
    [resaveBtn sizeToFit];
    [self.tableHeader addSubview:resaveBtn];
    //    [resaveBtn release];
    
    
    [self.tableHeader addConstraints:@[
                                       [NSLayoutConstraint constraintWithItem:resaveBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableHeader attribute:NSLayoutAttributeTop multiplier:1.0 constant:JX_SCREEN_TOP - 38],
                                       [NSLayoutConstraint constraintWithItem:resaveBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.tableHeader attribute:NSLayoutAttributeRight multiplier:1.0 constant:- 10]]];
}

- (void) confirmBtnAction {
    if ([self.selectorDelegate respondsToSelector:@selector(selector:selectorAction:)]) {
        [self.selectorDelegate selector:self selectorAction:self.selectIndex];
    }
    
    if(self.delegate != nil && [self.delegate respondsToSelector:self.didSelected])
        [self.delegate performSelectorOnMainThread:self.didSelected withObject:self waitUntilDone:NO];
    
    [self actionQuit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"SelectorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 56 - LINE_WH, JX_SCREEN_WIDTH - 15, LINE_WH)];
        line.backgroundColor = THE_LINE_COLOR;
        [cell.contentView addSubview:line];
        
        UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 30, 0, 15, 15)];
        selectImage.tag = 1000;
        selectImage.center = CGPointMake(selectImage.center.x, 56 / 2);
        selectImage.image = [UIImage imageNamed:@"ic_selected_done_2"];
        [cell.contentView addSubview:selectImage];
        
        
        cell.textLabel.text = self.array[indexPath.row];
    }
    
    UIView *view = [cell.contentView viewWithTag:1000];
    
    if (self.selectIndex == indexPath.row) {
        view.hidden = NO;
    }else {
        view.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectIndex = indexPath.row;
    [_table reloadData];
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
