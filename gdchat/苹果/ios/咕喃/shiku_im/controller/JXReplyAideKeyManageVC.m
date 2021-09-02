//
//  JXReplyAideKeyManageVC.m
//  shiku_im
//
//  Created by p on 2019/5/15.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXReplyAideKeyManageVC.h"
#import "JXGroupHeplerModel.h"

@interface JXReplyAideKeyManageVC ()

@property (nonatomic, strong) UIView *keysView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *keyText;
@property (nonatomic, strong) UITextView *replyText;
@property (nonatomic, strong) NSMutableArray *groupHelperArr;
@property (nonatomic, assign) NSInteger index;


@end

@implementation JXReplyAideKeyManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.heightHeader = JX_SCREEN_TOP;
    self.heightFooter = 0;
    self.isGotoBack = YES;
    [self createHeadAndFoot];
    
    self.title = [NSString stringWithFormat:@"%@%@",Localized(@"KEYWORD"),Localized(@"JX_KeywordsAdministration")];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.tableBody addGestureRecognizer:tap];
    
    if (!_keys) {
        _keys = [NSMutableArray array];
    }
    _groupHelperArr = [NSMutableArray array];
    [g_server queryGroupHelper:self.roomId toView:self];
    
    [self customView];
    
    [self createKeys];
    
}

- (void)tapAction {

    [self.view endEditing:YES];
}

- (void)customView {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, JX_SCREEN_WIDTH - 15, 20)];
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = Localized(@"JX_KeywordHasBeenSet:");
    [self.tableBody addSubview:label];
    
    _keysView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame) + 10, JX_SCREEN_WIDTH, 0)];
    [self.tableBody addSubview:_keysView];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_keysView.frame), JX_SCREEN_WIDTH, 0)];
    [self.tableBody addSubview:_contentView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, JX_SCREEN_WIDTH - 15, 20)];
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = [NSString stringWithFormat:@"%@：",Localized(@"KEYWORD")];
    [_contentView addSubview:label];
    
    _keyText = [[UITextView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(label.frame) + 10, JX_SCREEN_WIDTH - 30, 100)];
    _keyText.layer.masksToBounds = YES;
    _keyText.layer.cornerRadius = 7.f;
    _keyText.font = SYSFONT(15);
    _keyText.backgroundColor = HEXCOLOR(0xF2F2F2);
    [_contentView addSubview:_keyText];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_keyText.frame) + 20, JX_SCREEN_WIDTH - 15, 20)];
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = [NSString stringWithFormat:@"%@：",Localized(@"JX_ContentOfReply")];
    [_contentView addSubview:label];
    
    _replyText = [[UITextView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(label.frame) + 10, JX_SCREEN_WIDTH - 30, 100)];
    _replyText.layer.masksToBounds = YES;
    _replyText.layer.cornerRadius = 7.f;
    _replyText.font = SYSFONT(15);
    _replyText.backgroundColor = HEXCOLOR(0xF2F2F2);
    [_contentView addSubview:_replyText];
    
    UIButton *btn = [UIFactory createCommonButton:Localized(@"JX_Add") target:self action:@selector(onAddKeyword)];
//    [btn setBackgroundImage:nil forState:UIControlStateHighlighted];
    btn.custom_acceptEventInterval = 1.f;
    btn.frame = CGRectMake(15,CGRectGetMaxY(_replyText.frame) + 30, JX_SCREEN_WIDTH-30, 40);
    [btn setBackgroundImage:nil forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 7.f;
    btn.backgroundColor = THEMECOLOR;
    [_contentView addSubview:btn];
    
    _contentView.frame = CGRectMake(_contentView.frame.origin.x, _contentView.frame.origin.y, _contentView.frame.size.width, CGRectGetMaxY(btn.frame));
}

- (void)onAddKeyword {
    if (_keyText.text.length <= 0 || _replyText.text.length <= 0) {
        [g_server showMsg:Localized(@"JX_KeywordAndReplyContentCannotBeEmpty")];
        return;
    }
    [g_server addAutoResponse:self.roomId helperId:self.helperId keyword:_keyText.text value:_replyText.text toView:self];
}

- (void)createKeys {
    
    
    [_keysView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat inset = 20;
    
    UILabel *lastLabel = nil;
    for (NSInteger i = 0; i < _keys.count; i ++) {
        NSDictionary *dic = _keys[i];
        
        NSString *name = [dic objectForKey:@"keyWord"];
        CGSize size = [name boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14.0];
        label.tag = i;
        label.text = name;
        label.backgroundColor = THEMECOLOR;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 2.0;
        label.layer.masksToBounds = YES;
        if (!lastLabel) {
            label.frame = CGRectMake(inset, 10, (size.width + 20) > (JX_SCREEN_WIDTH - inset*2) ? (JX_SCREEN_WIDTH - inset*2) : (size.width + 20), 30);
        }else {
            
            if ((CGRectGetMaxX(lastLabel.frame) + inset + size.width + 20) > (JX_SCREEN_WIDTH - inset*2)) {
                label.frame = CGRectMake(inset, CGRectGetMaxY(lastLabel.frame) + inset, (size.width + 20) > (JX_SCREEN_WIDTH - inset*2) ? (JX_SCREEN_WIDTH - inset*2) : (size.width + 20), 30);
            }else {
                label.frame = CGRectMake(CGRectGetMaxX(lastLabel.frame) + inset, lastLabel.frame.origin.y, (size.width + 20) > (JX_SCREEN_WIDTH - inset*2) ? (JX_SCREEN_WIDTH - inset*2) : (size.width + 20), 30);
            }
            
        }
        
        [_keysView addSubview:label];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) - 15, label.frame.origin.y - 5, 20, 20)];
        btn.tag = i;
        [btn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [_keysView addSubview:btn];
        
        lastLabel = label;
    }
    
    _keysView.frame = CGRectMake(_keysView.frame.origin.x, _keysView.frame.origin.y, _keysView.frame.size.width, CGRectGetMaxY(lastLabel.frame));
    
    _contentView.frame = CGRectMake(_contentView.frame.origin.x, CGRectGetMaxY(_keysView.frame), _contentView.frame.size.width,  _contentView.frame.size.height);
    
}

- (void)onDelete:(JXImageView *)iv {
    self.index = iv.tag;
    
    for (JXGroupHeplerModel *hModel in _groupHelperArr) {
        if ([hModel.helperId isEqualToString:self.model.helperId]) {
            [g_server deleteAutoResponse:hModel.groupHelperId keyWordId:[(NSDictionary *)_keys[iv.tag] objectForKey:@"id"] toView:self];
        }
    }
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
    [_wait stop];
    // 获取群助手
    if ([aDownload.action isEqualToString:act_addAutoResponse]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:_keyText.text forKey:@"keyWord"];
        [_keys addObject:dict];
        _keyText.text = nil;
        _replyText.text = nil;
        
        [self createKeys];
    }
    if ([aDownload.action isEqualToString:act_queryGroupHelper]) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < array1.count; i++) {
            JXGroupHeplerModel *model = [[JXGroupHeplerModel alloc] init];
            [model getDataWithDict:array1[i]];
            [arr addObject:model];
        }
        _groupHelperArr = arr;
//        for (JXGroupHeplerModel *hModel in arr) {
//            if ([hModel.helperId isEqualToString:self.model.helperId]) {
//                _keys = [NSMutableArray arrayWithArray:hModel.keywords];
//                [self createKeys];
//            }
//        }
    }
    if ([aDownload.action isEqualToString:act_deleteAutoResponse]) {
        [_keys removeObjectAtIndex:self.index];
        [self createKeys];
    }

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


@end
