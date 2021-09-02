//
//  JXChatLogMoveSelectVC.m
//  shiku_im
//
//  Created by p on 2019/6/5.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXChatLogMoveSelectVC.h"
#import "JXCell.h"
#import "QCheckBox.h"
#import "JXChatLogQRCodeVC.h"

@interface JXChatLogMoveSelectVC ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSSet * existSet;
@property (nonatomic, strong) NSMutableArray *selUserIdArray;
@property (nonatomic, strong) NSMutableArray *selUserNameArray;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) NSMutableArray *checkBoxArr;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation JXChatLogMoveSelectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = JX_SCREEN_BOTTOM;
    self.isGotoBack   = YES;
    //self.view.frame = g_window.bounds;
    self.isShowFooterPull = NO;
    [self createHeadAndFoot];
    
    _array = [NSMutableArray array];
    _selUserIdArray = [NSMutableArray array];
    _selUserNameArray = [NSMutableArray array];
    _checkBoxArr = [NSMutableArray array];
    self.title = Localized(@"JX_ChooseAChat");
    
    CGSize size = [Localized(@"JX_CheckAll") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];

    UIButton *allSelect = [UIButton buttonWithType:UIButtonTypeSystem];
    [allSelect setTitle:Localized(@"JX_CheckAll") forState:UIControlStateNormal];
    [allSelect setTitle:Localized(@"JX_Cencal") forState:UIControlStateSelected];
    [allSelect setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [allSelect setTitleColor:THEMECOLOR forState:UIControlStateSelected];
    allSelect.tintColor = [UIColor clearColor];
    allSelect.titleLabel.font = [UIFont systemFontOfSize:15];
    allSelect.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, JX_SCREEN_TOP-15-14, size.width, 15);
    [allSelect addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableHeader addSubview:allSelect];
    
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 14)];
    self.countLabel.textColor = THEMECOLOR;
    self.countLabel.font = SYSFONT(14);
    self.countLabel.text = [NSString stringWithFormat:@"%@(0)",Localized(@"JX_NumberOfMigrations")];
    [self.tableFooter addSubview:self.countLabel];

    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 60-15, 9, 60, 27)];
    self.nextBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    self.nextBtn.backgroundColor = THEMECOLOR;
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [self.nextBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    
    self.nextBtn.layer.masksToBounds = YES;
    self.nextBtn.layer.cornerRadius = 2.f;
    [self.nextBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableFooter addSubview:self.nextBtn];
    
    
    [self getArrayData];
    
}
- (void)allSelect:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        CGSize size = [Localized(@"JX_Cencal") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        btn.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, btn.frame.origin.y, size.width, btn.frame.size.height);
    }else {
        CGSize size = [Localized(@"JX_CheckAll") sizeWithAttributes:@{NSFontAttributeName:SYSFONT(15)}];
        btn.frame = CGRectMake(JX_SCREEN_WIDTH-size.width-15, btn.frame.origin.y, size.width, btn.frame.size.height);
    }
    
    [_selUserIdArray removeAllObjects];
    [_selUserNameArray removeAllObjects];
    if (btn.selected) {
        for (JXMsgAndUserObject *userObj in _array) {
            [_selUserIdArray addObject:userObj.user.userId];
            [_selUserNameArray addObject:userObj.user.userNickname];
        }
    }
    
    [_checkBoxArr removeAllObjects];
    [self showCountLabelText];
    [self.tableView reloadData];
}

- (void)nextBtnAction:(UIButton *)btn {
    
    if (!_selUserIdArray.count) {
        [g_App showAlert:Localized(@"JX_SelectGroupUsers")];
        return;
    }
    
    JXChatLogQRCodeVC *vc = [[JXChatLogQRCodeVC alloc] init];
    vc.selUserIdArray = [_selUserIdArray copy];
    [g_navigation pushViewController:vc animated:YES];
    
    [self actionQuit];
}
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    JXMsgAndUserObject *userObj = _array[checkbox.tag % 10000];
    
    if(checked){
        BOOL flag = NO;
        for (NSInteger i = 0; i < _selUserIdArray.count; i ++) {
            NSString *selUserId = _selUserIdArray[i];
            if ([selUserId isEqualToString:userObj.user.userId]) {
                flag = YES;
                return;
            }
        }
        [_selUserIdArray addObject:userObj.user.userId];
        [_selUserNameArray addObject:userObj.user.userNickname];
    }
    else{
        [_selUserIdArray removeObject:userObj.user.userId];
        [_selUserNameArray removeObject:userObj.user.userNickname];
    }
    [self showCountLabelText];
}

-(void)getArrayData{
    _array=[[JXMessageObject sharedInstance] fetchRecentChat];
    
}

#pragma mark   ---------tableView协议----------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    JXCell *cell=nil;
    NSString* cellName = [NSString stringWithFormat:@"selVC_%d",(int)indexPath.row];
    //    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    //    QCheckBox* btn;
    //    if (!cell) {
    cell = [[JXCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    QCheckBox* btn = [[QCheckBox alloc] initWithDelegate:self];
    btn.frame = CGRectMake(13, 18.5, 22, 22);
    [cell addSubview:btn];
    //    }
    
    JXMsgAndUserObject *userObj=_array[indexPath.row];
    
    btn.tag = indexPath.section * 10000 + indexPath.row;
    BOOL flag = NO;
    for (NSInteger i = 0; i < _selUserIdArray.count; i ++) {
        NSString *selUserId = _selUserIdArray [i];
        if ([userObj.user.userId isEqualToString:selUserId]) {
            flag = YES;
            break;
        }
    }
    btn.checked = flag;
    
    [_checkBoxArr addObject:btn];
    //            cell = [[JXCell alloc] init];
    [_table addToPool:cell];
    cell.title = userObj.user.userNickname;
    //            cell.subtitle = user.userId;
    cell.bottomTitle = [TimeUtil formatDate:userObj.user.timeCreate format:@"MM-dd HH:mm"];
    cell.userId = userObj.user.userId;
    cell.isSmall = YES;
    [cell headImageViewImageWithUserId:nil roomId:nil];
    
    CGFloat headX = 13*2+22;
    
    cell.headImageView.frame = CGRectMake(headX,9.5,40,40);
    cell.headImageView.layer.cornerRadius = cell.headImageView.frame.size.width / 2;
    cell.lbTitle.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+15, 21.5, JX_SCREEN_WIDTH - 115 -CGRectGetMaxX(cell.headImageView.frame)-14, 16);
    cell.lbSubTitle.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+15, cell.lbSubTitle.frame.origin.y, JX_SCREEN_WIDTH - 55 -CGRectGetMaxX(cell.headImageView.frame)-14, cell.lbSubTitle.frame.size.height);
    cell.lineView.frame = CGRectMake(CGRectGetMaxX(cell.headImageView.frame)+15,59-LINE_WH,JX_SCREEN_WIDTH,LINE_WH);
    
    
//    cell.headImageView.frame = CGRectMake(cell.headImageView.frame.origin.x + 50, cell.headImageView.frame.origin.y, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height);
//    cell.lbTitle.frame = CGRectMake(cell.lbTitle.frame.origin.x + 50, cell.lbTitle.frame.origin.y, cell.lbTitle.frame.size.width, cell.lbTitle.frame.size.height);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QCheckBox *checkBox = nil;
    for (NSInteger i = 0; i < _checkBoxArr.count; i ++) {
        QCheckBox *btn = _checkBoxArr[i];
        if (btn.tag / 10000 == indexPath.section && btn.tag % 10000 == indexPath.row) {
            checkBox = btn;
            break;
        }
    }
    checkBox.selected = !checkBox.selected;
    [self didSelectedCheckBox:checkBox checked:checkBox.selected];
    [self showCountLabelText];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}


- (void)showCountLabelText {
    self.countLabel.text = [NSString stringWithFormat:@"%@(%ld)",Localized(@"JX_NumberOfMigrations"),_selUserIdArray.count];
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
