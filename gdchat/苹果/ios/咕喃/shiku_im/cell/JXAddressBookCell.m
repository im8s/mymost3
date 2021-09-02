//
//  JXAddressBookCell.m
//  shiku_im
//
//  Created by p on 2018/8/30.
//  Copyright © 2018年 Reese. All rights reserved.
//

#import "JXAddressBookCell.h"

@implementation JXAddressBookCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _checkBox = [[QCheckBox alloc] initWithDelegate:self];
        _checkBox.frame = CGRectMake(15, 22, 20, 20);
        _checkBox.delegate = self;
        [self.contentView addSubview:_checkBox];
        
        _headImage = [[JXImageView alloc]init];
        _headImage.userInteractionEnabled = NO;
        _headImage.tag = self.index;
        _headImage.delegate = self;
        _headImage.didTouch = @selector(headImageDidTouch);
        _headImage.frame = CGRectMake(CGRectGetMaxX(_checkBox.frame) + 10,5,52,52);
        _headImage.layer.cornerRadius = 26;
        _headImage.layer.masksToBounds = YES;
        //        _headImageView.layer.borderWidth = 0.5;
        _headImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:self.headImage];
        
        _nickName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame) + 10, 10, 300, 20)];
        _nickName.textColor = HEXCOLOR(0x333333);
        _nickName.userInteractionEnabled = NO;
        _nickName.text = @"张辉";
        _nickName.backgroundColor = [UIColor clearColor];
        _nickName.font = [UIFont systemFontOfSize:16];
        _nickName.tag = self.index;
        [self.contentView addSubview:_nickName];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImage.frame) + 10, CGRectGetMaxY(_nickName.frame) + 5, 300, 20)];
        _name.textColor = HEXCOLOR(0x999999);
        _name.userInteractionEnabled = NO;
        _name.text = @"张辉";
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont systemFontOfSize:14];
        _name.tag = self.index;
        [self.contentView addSubview:_name];
        
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-70, 20, 50, 24)];
        [_addBtn setBackgroundColor:THEMECOLOR];
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_addBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setTitleColor:[HEXCOLOR(0x333333) colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        _addBtn.titleLabel.textColor = [UIColor whiteColor];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_addBtn setTitle:Localized(@"JX_Add") forState:UIControlStateNormal];
        [_addBtn setTitle:Localized(@"JX_AlreadyAdded") forState:UIControlStateDisabled];
        [_addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _addBtn.layer.cornerRadius = 3.0;
        _addBtn.layer.masksToBounds = YES;
        [self.contentView addSubview:_addBtn];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nickName.frame), 63.5, JX_SCREEN_WIDTH-CGRectGetMinX(_nickName.frame), LINE_WH)];
        _lineView.backgroundColor = THE_LINE_COLOR;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setAddressBook:(JXAddressBook *)addressBook {
    _addressBook = addressBook;
    JXUserObject *user = [[JXUserObject sharedInstance] getUserById:addressBook.toUserId];
    if ([user.status intValue] == 2 || [user.status intValue] == -1) {
        _addBtn.enabled = NO;
        _addBtn.backgroundColor = [UIColor clearColor];
        _nickName.textColor = [HEXCOLOR(0x333333) colorWithAlphaComponent:0.3];
        _name.textColor = [HEXCOLOR(0x333333) colorWithAlphaComponent:0.3];
    }else {
        _addBtn.enabled = YES;
        _addBtn.backgroundColor = THEMECOLOR;
        UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
        [_addBtn setBackgroundImage:img forState:UIControlStateHighlighted];
        _nickName.textColor = HEXCOLOR(0x333333);
        _name.textColor = HEXCOLOR(0x999999);
    }
    if (self.isShowSelect) {
        if (_addBtn.enabled) {
            self.checkBox.hidden = NO;
        }else {
            self.checkBox.hidden = YES;
        }
        self.addBtn.hidden = YES;
        _headImage.frame = CGRectMake(CGRectGetMaxX(self.checkBox.frame) + 10, _headImage.frame.origin.y, _headImage.frame.size.width, _headImage.frame.size.height);
        _nickName.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + 10, _nickName.frame.origin.y, _nickName.frame.size.width, _nickName.frame.size.height);
        _name.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + 10, _name.frame.origin.y, _name.frame.size.width, _name.frame.size.height);
    }else {
        self.checkBox.hidden = YES;
        self.addBtn.hidden = NO;
        _headImage.frame = CGRectMake(15, _headImage.frame.origin.y, _headImage.frame.size.width, _headImage.frame.size.height);
        _nickName.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + 10, _nickName.frame.origin.y, _nickName.frame.size.width, _nickName.frame.size.height);
        _name.frame = CGRectMake(CGRectGetMaxX(self.headImage.frame) + 10, _name.frame.origin.y, _name.frame.size.width, _name.frame.size.height);
    }
    [g_server getHeadImageSmall:addressBook.toUserId userName:addressBook.addressBookName imageView:_headImage getHeadHandler:nil];
    _name.text = [NSString stringWithFormat:@"%@:%@",APP_NAME,addressBook.toUserName];
    _nickName.text = addressBook.addressBookName;
    
    _lineView.frame = CGRectMake(CGRectGetMinX(_nickName.frame), _lineView.frame.origin.y, JX_SCREEN_WIDTH-CGRectGetMinX(_nickName.frame), _lineView.frame.size.height);
    
    if (self.isInvite) {
        _addBtn.enabled = YES;
        [_addBtn setTitle:Localized(@"JX_TheInvitation") forState:UIControlStateNormal];
        [g_server getHeadImageSmall:nil userName:addressBook.addressBookName imageView:_headImage getHeadHandler:nil];
        _nickName.text = addressBook.addressBookName;
        _name.text = addressBook.toTelephone;
    }
    
}

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked{
    if ([self.delegate respondsToSelector:@selector(addressBookCell:checkBoxSelectIndexNum:isSelect:)]) {
        [self.delegate addressBookCell:self checkBoxSelectIndexNum:self.index isSelect:checked];
    }
}

- (void)addBtnAction:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(addressBookCell:addBtnAction:)]) {
        [self.delegate addressBookCell:self addBtnAction:self.addressBook];
    }
}

- (void)headImageDidTouch {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
