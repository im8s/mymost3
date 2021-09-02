//
//  JXSetLabelVC.m
//  shiku_im
//
//  Created by p on 2018/6/26.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXSetLabelVC.h"
#import "JXLabelObject.h"
#import "UIImage+Color.h"


#define HEIGHT 54

@interface JXSetLabelVC ()<UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *allScrollView;
@property (nonatomic, strong) NSMutableArray *labelsArray;  // 已有标签按钮
@property (nonatomic, strong) NSMutableArray *allLabelsArray;   // 所有标签按钮


@property (nonatomic, strong) UITextField *name; //备注
@property (nonatomic, strong) UITextField *textField; //标签
@property (nonatomic, strong) UITextView *detail; //描述

@property (nonatomic, strong) UILabel *labT;
@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UIColor *textVColor;

@end

@implementation JXSetLabelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_array.count <= 0) {
        _array = [[JXLabelObject sharedInstance] fetchLabelsWithUserId:self.user.userId];
    }
    if (_allArray.count <= 0) {
        _allArray = [[JXLabelObject sharedInstance] fetchAllLabelsFromLocal];
    }
    for (JXLabelObject *labelObj in _array) {
        NSString *userIdStr = labelObj.userIdList;
        NSArray *userIds = [userIdStr componentsSeparatedByString:@","];
        if (userIdStr.length <= 0) {
            userIds = nil;
        }
        
        NSMutableArray *newUserIds = [userIds mutableCopy];
        for (NSInteger i = 0; i < userIds.count; i ++) {
            NSString *userId = userIds[i];
            NSString *userName = [JXUserObject getUserNameWithUserId:userId];
            
            if (!userName || userName.length <= 0) {
                [newUserIds removeObject:userId];
            }
            
        }
        
        NSString *string = [newUserIds componentsJoinedByString:@","];
        
        labelObj.userIdList = string;
        
        [labelObj update];
    }
    _labelsArray = [NSMutableArray array];
    _allLabelsArray = [NSMutableArray array];
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    self.tableBody.delegate = self;

    self.tableBody.backgroundColor = HEXCOLOR(0xF2F2F2);
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];
    [self customView];
}

- (void)customView {
    JXLabel *p = [self createLabel:self.tableHeader default:Localized(@"JX_Confirm") selector:@selector(onSave)];
    p.textColor = [UIColor whiteColor];
    p.layer.masksToBounds = YES;
    p.layer.cornerRadius = 3.f;
    [p setBackgroundColor:THEMECOLOR];
    [p setFont:SYSFONT(15)];
    p.textAlignment = NSTextAlignmentCenter;
    p.frame = CGRectMake(JX_SCREEN_WIDTH - 51 - 15, JX_SCREEN_TOP - 8 - 29, 51, 29);

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, JX_SCREEN_WIDTH, 50)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.tableBody addSubview:_scrollView];
    
    _allScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame), JX_SCREEN_WIDTH, self.tableBody.frame.size.height - CGRectGetMaxY(_scrollView.frame))];
    _allScrollView.backgroundColor = [UIColor clearColor];
    [self.tableBody addSubview:_allScrollView];
    
    // 创建上部分已有标签视图
    [self createLabels];
    
    // 创建下部分所有标签视图
    [self createAllLabels];
}

-(JXLabel*)createLabel:(UIView*)parent default:(NSString*)s selector:(SEL)selector{
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH/2,INSETS,JX_SCREEN_WIDTH/2 -20,44-INSETS*2)];
    p.userInteractionEnabled = NO;
    p.text = s;
    p.font = g_factory.font14;
    p.textAlignment = NSTextAlignmentLeft;
    p.didTouch = selector;
    p.delegate = self;
    [parent addSubview:p];
    return p;
}

// 创建已有标签
- (void)createLabels {
    
   [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_labelsArray removeAllObjects];
    
    int margin = 15;
    int inset = 8;
    int x = margin;
    int y = margin;
    UIButton *lastLabelBtn;
    for (NSInteger i = 0; i < _array.count; i ++) {
        JXLabelObject *labelObj = _array[i];
        CGSize size = [labelObj.groupName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
        size = CGSizeMake(size.width + 20, size.height + 10);
        if (size.width > JX_SCREEN_WIDTH-30) {
            size.width = JX_SCREEN_WIDTH-30;
        }
        UIButton *labelBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, size.width, 36)];
        [labelBtn setTitle:labelObj.groupName forState:UIControlStateNormal];
        [labelBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        [labelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [labelBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [labelBtn setBackgroundImage:[UIImage createImageWithColor:HEXCOLOR(0x4FC557)] forState:UIControlStateSelected];
        labelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        labelBtn.layer.cornerRadius = 7.f;
        labelBtn.layer.masksToBounds = YES;
        labelBtn.layer.borderColor = THEMECOLOR.CGColor;
        labelBtn.layer.borderWidth = 1.0;
        labelBtn.tag = i;
        [labelBtn addTarget:self action:@selector(labelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:labelBtn];
        [_labelsArray addObject:labelBtn];
        
        lastLabelBtn = labelBtn;
        
        x = CGRectGetMaxX(labelBtn.frame) + inset;
        
        if (i != _array.count - 1) {
            JXLabelObject *lastLabelObj = _array[i + 1];
            CGSize lastSize = [lastLabelObj.groupName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
            lastSize = CGSizeMake(lastSize.width + 20, lastSize.height + 10);
            if ((x + lastSize.width + margin) > JX_SCREEN_WIDTH) {
                x = margin;
                y = CGRectGetMaxY(labelBtn.frame) + 10;
            }
        }
        
    }
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.placeholder = Localized(@"JX_InputLabel");
        _textField.font = [UIFont systemFontOfSize:16.0];
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    
    [_scrollView addSubview:_textField];
    if (CGRectGetMaxX(lastLabelBtn.frame) + margin + 50 + margin > JX_SCREEN_WIDTH) {
        _textField.frame = CGRectMake(margin, CGRectGetMaxY(lastLabelBtn.frame) + margin, JX_SCREEN_WIDTH - margin - margin, 36);
    }else {
        CGFloat y = lastLabelBtn.frame.origin.y;
        if (!lastLabelBtn) {
            y = margin;
        }
        
        _textField.frame = CGRectMake(CGRectGetMaxX(lastLabelBtn.frame) + margin, y, JX_SCREEN_WIDTH - CGRectGetMaxX(lastLabelBtn.frame) - margin - margin, 36);
    }
    
    if ((CGRectGetMaxY(_textField.frame) + margin) > (margin * 4 + 36 * 3)) {
        _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, margin * 4 + 36 * 3);
        _scrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH, CGRectGetMaxY(_textField.frame) + margin);
    }else {
        _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, CGRectGetMaxY(_textField.frame) + margin);
        _scrollView.contentSize = CGSizeMake(JX_SCREEN_WIDTH, _scrollView.frame.size.height);
    }
    [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentSize.height - _scrollView.frame.size.height)];
    
    _allScrollView.frame = CGRectMake(_allScrollView.frame.origin.x, CGRectGetMaxY(_scrollView.frame), _allScrollView.frame.size.width, _allScrollView.frame.size.height);

}

// 创建所有标签
- (void) createAllLabels {
    
    [_allLabelsArray removeAllObjects];
    
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, JX_SCREEN_WIDTH, 15)];
    allLabel.text = Localized(@"JX_AllLabels");
    allLabel.font = [UIFont systemFontOfSize:15.0];
    allLabel.textColor = [UIColor grayColor];
    [_allScrollView addSubview:allLabel];
    
    int margin = 15;
    int inset = 8;
    int x = margin;
    int y = CGRectGetMaxY(allLabel.frame) + margin;
    UIButton *lastLabelBtn;
    for (NSInteger i = 0; i < _allArray.count; i ++) {
        JXLabelObject *labelObj = _allArray[i];
        
        BOOL flag = NO;
        for (JXLabelObject *obj in _array) {
            if ([obj.groupName isEqualToString:labelObj.groupName]) {
                flag = YES;
                break;
            }
        }
        
        CGSize size = [labelObj.groupName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
        size = CGSizeMake(size.width + 20, size.height + 10);
        if (size.width > JX_SCREEN_WIDTH-30) {
            size.width = JX_SCREEN_WIDTH-30;
        }
        UIButton *labelBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, size.width, 36)];
        [labelBtn setTitle:labelObj.groupName forState:UIControlStateNormal];
        [labelBtn setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
        [labelBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateSelected];
        [labelBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [labelBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        labelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        labelBtn.layer.cornerRadius = 7.f;
        labelBtn.layer.masksToBounds = YES;
        labelBtn.layer.borderColor = THEMECOLOR.CGColor;
        labelBtn.layer.borderWidth = 1.0;
        labelBtn.tag = i;
        [labelBtn addTarget:self action:@selector(allLabelAction:) forControlEvents:UIControlEventTouchUpInside];
        labelBtn.selected = flag;
        if (flag) {
            labelBtn.layer.borderColor = THEMECOLOR.CGColor;
        }else {
            labelBtn.layer.borderColor = HEXCOLOR(0xdcdcdc).CGColor;
        }

        [_allScrollView addSubview:labelBtn];
        [_allLabelsArray addObject:labelBtn];
        
        lastLabelBtn = labelBtn;
        
        x = CGRectGetMaxX(labelBtn.frame) + inset;
        
        if (i != _allArray.count - 1) {
            JXLabelObject *lastLabelObj = _allArray[i + 1];
            CGSize lastSize = [lastLabelObj.groupName boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
            lastSize = CGSizeMake(lastSize.width + 20, lastSize.height + 10);
            if ((x + lastSize.width + margin) > JX_SCREEN_WIDTH) {
                x = margin;
                y = CGRectGetMaxY(labelBtn.frame) + 10;
            }
        }
        
        _allScrollView.frame = CGRectMake(_allScrollView.frame.origin.x, _allScrollView.frame.origin.y, _allScrollView.frame.size.width, CGRectGetMaxY(lastLabelBtn.frame) + margin+100);
    }
}

// 已有标签点击事件
- (void)labelBtnAction:(UIButton *)labelBtn {
    
    labelBtn.selected = !labelBtn.selected;
    for (UIButton *btn in _labelsArray) {
        if (btn.tag != labelBtn.tag) {
            btn.selected = !labelBtn.selected;
        }
    }
    
    // 删除菜单
    [self becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:labelBtn.frame inView:labelBtn.superview];
    UIMenuItem *delete     = [[UIMenuItem alloc] initWithTitle:Localized(@"JX_Delete") action:@selector(deleteAction)];

    menuController.menuItems = @[delete];
    
//    [menuController setMenuVisible:YES animated:YES];
    menuController.menuVisible = YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    if (action == @selector(deleteAction))
        return YES;
    else
        return NO;
}

// 删除菜单隐藏通知，取消选中
- (void)menuControllerWillHide {
    for (UIButton *btn in _labelsArray) {
        btn.selected = NO;
    }
}

// 删除菜单点击事件
- (void)deleteAction {
    
    NSInteger index = -1;
    for (NSInteger i = 0; i < _labelsArray.count; i ++) {
        UIButton *btn = _labelsArray[i];
        if (btn.selected) {
            index = i;
            BOOL flag = NO;
            for (UIButton *allBtn in _allLabelsArray) {
                if ([btn.titleLabel.text isEqualToString:allBtn.titleLabel.text]) {
                    flag = YES;
                    // 所有标签存在将要删除的标签
                    [self allLabelAction:allBtn];
                    break;
                }
            }
            
            // 所有标签中没有将要删除的标签
            if (!flag) {
                if (index >= 0) {
                    [_array removeObjectAtIndex:index];
                    [_labelsArray removeObjectAtIndex:index];
                    [self createLabels];
                }
            }
            
            break;
        }
    }

}

// 所有标签点击事件
- (void)allLabelAction:(UIButton *)labelBtn {
    
    labelBtn.selected = !labelBtn.selected;
    if (labelBtn.selected) {
        labelBtn.layer.borderColor = THEMECOLOR.CGColor;
    }else {
        labelBtn.layer.borderColor = HEXCOLOR(0xdcdcdc).CGColor;
    }
 
    JXLabelObject *allObj = _allArray[labelBtn.tag];
    JXLabelObject *obj = nil;
    // 查找已选标签中是否有此标签
    for (JXLabelObject *labelObj in _array) {
        if ([allObj.groupName isEqualToString:labelObj.groupName]) {
            obj = labelObj;
            break;
        }
    }
    
    NSMutableArray *userIdArr = [NSMutableArray arrayWithArray: [allObj.userIdList componentsSeparatedByString:@","]];
    if (allObj.userIdList.length <= 0) {
        userIdArr = [NSMutableArray array];
    }

    NSString *userId;
    for (NSString *str in userIdArr) {
        if ([str isEqualToString:self.user.userId]) {
            userId = str;
            break;
        }
    }
    
    if (obj) {
        // 如果已选标签有此标签，删除已选标签
        [_array removeObject:obj];
        if (userId) {
            [userIdArr removeObject:userId];
        }
    }else {
        // 如果没有，添加此标签
        [_array addObject:allObj];
        if (!userId) {
            [userIdArr addObject:self.user.userId];
        }
    }
    
    NSMutableString *userIdListStr = [NSMutableString string];
    for (NSInteger i = 0; i < userIdArr.count; i ++) {
        NSString *userId = userIdArr[i];
        if (i == 0) {
            [userIdListStr appendFormat:@"%@", userId];
        }else {
            [userIdListStr appendFormat:@",%@", userId];
        }

    }
    // 更改所有标签的userList
    allObj.userIdList = userIdListStr;
    
    [self createLabels];
}

// 输入框回调
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 点击键盘完成
    if ([string isEqualToString:@"\n"]) {
        NSString *text = [NSString stringWithString:self.textField.text];
        if (textField.text.length != 0 && [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0){
            [JXMyTools showTipView:Localized(@"JX_PleaseEnterValidTagName")];
            _textField.text = nil;
            return YES;
        }
        if (textField.text.length > 0) {
            
            // 查重、如果已选标签中已存在此标签，不重复添加
            for (UIButton *labelBtn in _labelsArray) {
                if ([labelBtn.titleLabel.text isEqualToString:textField.text]) {
                    
                    _textField.text = nil;
                    return YES;
                }
            }
            
            // 查重、如果所有标签中已存在此标签
            for (UIButton *allLabelBtn in _allLabelsArray) {
                if ([allLabelBtn.titleLabel.text isEqualToString:textField.text]) {
                    
                    // 如果所有标签此标签未选中，自动选中此标签
                    if (!allLabelBtn.selected) {
                        [self allLabelAction:allLabelBtn];
                    }
                    // 如果已选中，不做操作
                    _textField.text = nil;
                    return YES;
                }
            }
            
            // 添加输入的标签
            JXLabelObject *labelObj = [[JXLabelObject alloc] init];
            labelObj.groupName = textField.text;
            [_array addObject:labelObj];
            [self createLabels];
            _textField.text = nil;
            return YES;
        }
    }
    
    
    // 删除
    if (string.length <= 0 && textField.text.length <= 0) {
        
        UIButton *lastBtn = _labelsArray.lastObject;
        if (lastBtn.selected) { // 如果已选标签最后一个标签已选中
            NSInteger index = -1;
            for (NSInteger i = 0; i < _labelsArray.count; i ++) {
                UIButton *btn = _labelsArray[i];
                if (btn.selected) {
                    index = i;
                    BOOL flag = NO;
                    for (UIButton *allBtn in _allLabelsArray) {
                        if ([btn.titleLabel.text isEqualToString:allBtn.titleLabel.text]) {
                            flag = YES;
                            // 如果所有标签中有此标签
                            [self allLabelAction:allBtn];
                            break;
                        }
                    }
                    
                    if (!flag) {    // 如果所有标签中没有此标签直接删除
                        if (index >= 0) {
                            [_array removeObjectAtIndex:index];
                            [_labelsArray removeObjectAtIndex:index];
                            [self createLabels];
                        }
                    }
                    
                    break;
                }
            }
        }else { // 如果没有选中， 第一次点击删除 选中最后一个标签
            lastBtn.selected = YES;
        }
    }
    
    return YES;
}

// 确定按钮
- (void)onSave {
    NSString *text = [NSString stringWithString:self.textField.text];
    if (self.textField.text.length != 0 && [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0){
        [JXMyTools showTipView:Localized(@"JX_PleaseEnterValidTagName")];
        _textField.text = nil;
        return;
    }
    if (self.textField.text.length > 0) {
        
        // 查重、如果已选标签中已存在此标签，不重复添加
        for (UIButton *labelBtn in _labelsArray) {
            if ([labelBtn.titleLabel.text isEqualToString:self.textField.text]) {
                
                _textField.text = nil;
                return;
            }
        }
        
        // 查重、如果所有标签中已存在此标签
        for (UIButton *allLabelBtn in _allLabelsArray) {
            if ([allLabelBtn.titleLabel.text isEqualToString:self.textField.text]) {
                
                // 如果所有标签此标签未选中，自动选中此标签
                if (!allLabelBtn.selected) {
                    [self allLabelAction:allLabelBtn];
                }
                // 如果已选中，不做操作
                _textField.text = nil;
                return;
            }
        }
        
        // 添加输入的标签
        JXLabelObject *labelObj = [[JXLabelObject alloc] init];
        labelObj.groupName = self.textField.text;
        [_array addObject:labelObj];
        [self createLabels];
        _textField.text = nil;
        return;
    }

    
    BOOL flag = NO;
    for (NSInteger i = 0; i < _array.count; i ++) {
        JXLabelObject *labelObj = _array[i];
        
        // 添加输入框输入的新创建的标签
        if (!labelObj.groupId) {
            flag = YES;
            [g_server friendGroupAdd:labelObj.groupName toView:self];
        }
    }
    
    // 没有新创建的标签，直接更新已存在标签
    if (!flag) {
        NSMutableString *userIdListStr = [NSMutableString string];
        for (NSInteger i = 0; i < _array.count; i ++) {
            JXLabelObject *obj = _array[i];
            if (i == 0) {
                [userIdListStr appendFormat:@"%@", obj.groupId];
            }else {
                [userIdListStr appendFormat:@",%@", obj.groupId];
            }
        }

        [g_server friendGroupUpdateFriendToUserId:self.user.userId groupIdStr:userIdListStr toView:self];
    }
    if ([self.delegate respondsToSelector:self.didSelect]) {
        [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:NO];
    }
    
    [self actionQuit];
}



//服务器返回数据
-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    if ([aDownload.action isEqualToString:act_FriendGroupAdd]) {
        
        NSMutableString *userIdListStr = [NSMutableString stringWithFormat:@"%@", self.user.userId];
        
        // 添加新标签后更新标签的用户列表
        [g_server friendGroupUpdateGroupUserList:dict[@"groupId"] userIdListStr:userIdListStr toView:self];
        
        JXLabelObject *label = [[JXLabelObject alloc] init];
        if (dict) {
            label.userId = dict[@"userId"];
            label.groupId = dict[@"groupId"];
            label.groupName = dict[@"groupName"];
        }
        label.userIdList = userIdListStr;
        // 插入新创建的标签
        [label insert];
        
        JXLabelObject *lastObj;
        // 查找到新创建的标签的最后一个
        for (NSInteger i = _array.count - 1; i >= 0; i --) {
            JXLabelObject *obj = _array[i];
            if (!obj.groupId) {
                lastObj = obj;
                break;
            }
        }
        
        // 更新新创建的标签的其他字段
        for (JXLabelObject *labelObj in _array) {
            if ([label.groupName isEqualToString:labelObj.groupName]) {
                labelObj.groupId = label.groupId;
                labelObj.userId = label.userId;
                labelObj.userIdList = label.userIdList;
                break;
            }
        }
        
        // 如果接口已成功添加完最后一条标签后，再更新用户的标签列表
        if ([label.groupName isEqualToString:lastObj.groupName]) {
            
            NSMutableString *userIdListStr = [NSMutableString string];
            for (NSInteger i = 0; i < _array.count; i ++) {
                JXLabelObject *obj = _array[i];
                if (i == 0) {
                    [userIdListStr appendFormat:@"[%@", obj.groupId];
                }else if (i == self.array.count - 1) {
                    [userIdListStr appendFormat:@",%@]", obj.groupId];
                }else {
                    [userIdListStr appendFormat:@",%@", obj.groupId];
                }
            }
            
            [g_server friendGroupUpdateFriendToUserId:self.user.userId groupIdStr:userIdListStr toView:self];
            
        }
    }
    
    if ([aDownload.action isEqualToString:act_FriendGroupUpdateFriend]) {
        
        // 更新数据库
        for (JXLabelObject *labelObj in _allArray) {
            [labelObj update];
        }
        self.user.remarkName = _name.text;
        if (_detail.textColor != self.textVColor) {
            self.user.describe = _detail.text;
        }else {
            self.user.describe = nil;
        }
        if ([self.delegate respondsToSelector:self.didSelect]) {
            [self.delegate performSelectorOnMainThread:self.didSelect withObject:self waitUntilDone:NO];
        }
        
//        [self actionQuit];
    }
}



-(int) didServerResultFailed:(JXConnection*)aDownload dict:(NSDictionary*)dict{
    [_wait hide];
    
    return show_error;
}

-(int) didServerConnectError:(JXConnection*)aDownload error:(NSError *)error{//error为空时，代表超时
    [_wait hide];
    return show_error;
}

-(void) didServerConnectStart:(JXConnection*)aDownload{
    [_wait start];
}


-(UITextView*)createTextField:(UIView*)parent default:(NSString*)s {
    UITextView* p = [[UITextView alloc] init];
    p.delegate = self;
    p.autocorrectionType = UITextAutocorrectionTypeNo;
    p.autocapitalizationType = UITextAutocapitalizationTypeNone;
    p.enablesReturnKeyAutomatically = YES;
    p.scrollEnabled = NO;
    p.returnKeyType = UIReturnKeyDone;
    p.showsVerticalScrollIndicator = NO;
    p.showsHorizontalScrollIndicator = NO;
    p.textAlignment = NSTextAlignmentLeft;
    p.userInteractionEnabled = YES;
    p.backgroundColor = [UIColor whiteColor];
    p.text = s;
    p.font = g_factory.font15;
    [parent addSubview:p];
    return p;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


@end
