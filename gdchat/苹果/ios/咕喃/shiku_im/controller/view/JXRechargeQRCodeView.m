//
//  JXRechargeQRCodeView.m
//  shiku_im
//
//  Created by p on 2019/12/5.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXRechargeQRCodeView.h"
@interface JXRechargeQRCodeView()

@end

@implementation JXRechargeQRCodeView


- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)customView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(20, 0, JX_SCREEN_WIDTH - 40, 0)];
    content.layer.cornerRadius = 10;
    content.backgroundColor = [UIColor whiteColor];
    [self addSubview:content];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:closeBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, content.frame.size.width, 50)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = HEXCOLOR(0x556b95);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.type == RechargeType_BankCard) {
        titleLabel.text = Localized(@"JX_BankCard");
    }else {
        titleLabel.text = Localized(@"JX_ReceiptQRCode");
    }
    [content addSubview:titleLabel];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), content.frame.size.width, LINE_WH)];
    topLine.backgroundColor = THE_LINE_COLOR;
    [content addSubview:topLine];
    
    CGFloat tipY = 0.0;
    if (self.type != RechargeType_BankCard) {
        _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLine.frame) + 20, 160, 200)];
        _qrImageView.center = CGPointMake(content.frame.size.width / 2, _qrImageView.center.y);
        _qrImageView.backgroundColor = [UIColor yellowColor];
        [content addSubview:_qrImageView];
        [_qrImageView sd_setImageWithURL:[NSURL URLWithString:_qrUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
        }];
        
        UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_qrImageView.frame) + 5, 80, 20)];
        saveBtn.center = CGPointMake(content.frame.size.width / 2, saveBtn.center.y);
        saveBtn.layer.borderWidth = 1.0;
        saveBtn.layer.borderColor = [UIColor redColor].CGColor;
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [saveBtn setTitle:Localized(@"JX_SaveCollectionCode") forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:saveBtn];
        
        tipY = CGRectGetMaxY(saveBtn.frame) + 30;
    }else {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.font = [UIFont systemFontOfSize:16.0];
        nameLabel.textColor = HEXCOLOR(0x556b95);
        [content addSubview:nameLabel];
        NSString *nameStr = [NSString stringWithFormat:@"%@：%@",Localized(@"JX_Payee"),self.name];
        nameLabel.text = nameStr;
        CGSize size = [nameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:nameLabel.font} context:nil].size;
        if (size.width > (content.frame.size.width - 50 - 15)) {
            size.width = content.frame.size.width - 50 - 15;
        }
        nameLabel.frame = CGRectMake(25, CGRectGetMaxY(topLine.frame) + 30, size.width, 20);
        [content addSubview:nameLabel];
        UIButton *nameBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 10, nameLabel.frame.origin.y, 20, 20)];
        [nameBtn setBackgroundImage:[UIImage imageNamed:@"copy_icon"] forState:UIControlStateNormal];
        nameBtn.tag = 10001;
        [nameBtn addTarget:self action:@selector(copyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:nameBtn];
        
        UILabel *cardLabel = [[UILabel alloc] init];
        cardLabel.textAlignment = NSTextAlignmentLeft;
        cardLabel.font = [UIFont systemFontOfSize:16.0];
        cardLabel.textColor = HEXCOLOR(0x556b95);
        [content addSubview:cardLabel];
        NSString *cardStr = [NSString stringWithFormat:@"%@：%@",Localized(@"JX_BankCardNumber"),self.bankCard];
        cardLabel.text = cardStr;
        size = [cardStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cardLabel.font} context:nil].size;
        if (size.width > (content.frame.size.width - 50 - 15)) {
            size.width = content.frame.size.width - 50 - 15;
        }
        cardLabel.frame = CGRectMake(25, CGRectGetMaxY(nameLabel.frame) + 20, size.width, 20);
        [content addSubview:cardLabel];
        UIButton *cardBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cardLabel.frame) + 10, cardLabel.frame.origin.y, 20, 20)];
        [cardBtn setBackgroundImage:[UIImage imageNamed:@"copy_icon"] forState:UIControlStateNormal];
        cardBtn.tag = 10002;
        [cardBtn addTarget:self action:@selector(copyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:cardBtn];
        
        UILabel *bankLabel = [[UILabel alloc] init];
        bankLabel.textAlignment = NSTextAlignmentLeft;
        bankLabel.font = [UIFont systemFontOfSize:16.0];
        bankLabel.textColor = HEXCOLOR(0x556b95);
        [content addSubview:bankLabel];
        NSString *bankStr = [NSString stringWithFormat:@"%@：%@",Localized(@"JX_BankAccount"),self.bankName];
        bankLabel.text = bankStr;
        size = [bankStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:bankLabel.font} context:nil].size;
        if (size.width > (content.frame.size.width - 50 - 15)) {
            size.width = content.frame.size.width - 50 - 15;
        }
        bankLabel.frame = CGRectMake(25, CGRectGetMaxY(cardLabel.frame) + 20, size.width, 20);
        [content addSubview:bankLabel];
        UIButton *bankBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bankLabel.frame) + 10, bankLabel.frame.origin.y, 20, 20)];
        [bankBtn setBackgroundImage:[UIImage imageNamed:@"copy_icon"] forState:UIControlStateNormal];
        bankBtn.tag = 10003;
        [bankBtn addTarget:self action:@selector(copyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:bankBtn];
        
        UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bankLabel.frame) + 30, content.frame.size.width, LINE_WH)];
        middleLine.backgroundColor = THE_LINE_COLOR;
        [content addSubview:middleLine];
        
        tipY = CGRectGetMaxY(middleLine.frame) + 30;
    }
    
    
    UILabel *tipLabel = [[UILabel alloc] init];
    if (self.type != RechargeType_BankCard) {
        NSString *typeStr = Localized(@"JX_WeChat");
        if (self.type == RechargeType_Alipay) {
            typeStr = Localized(@"JX_Alipay");
        }
        NSString *tipStr = [NSString stringWithFormat:@"%@\n%@",Localized(@"JX_RechargeTipLabel1"),Localized(@"JX_RechargeTipLabel2")];
        tipLabel.text = [NSString stringWithFormat:tipStr,typeStr,self.money,g_myself.account];
    }else {
        tipLabel.text = Localized(@"JX_RechargeTip1");
    }
   
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.font = [UIFont systemFontOfSize:15.0];
    tipLabel.textColor = [UIColor lightGrayColor];
    [content addSubview:tipLabel];
    CGSize size = [tipLabel.text boundingRectWithSize:CGSizeMake(content.frame.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:tipLabel.font} context:nil].size;
    tipLabel.frame = CGRectMake(10, tipY, content.frame.size.width - 20, size.height);
    
    CGFloat bottomLineY;
    if (self.type != RechargeType_BankCard) {
        bottomLineY = CGRectGetMaxY(tipLabel.frame) + 10;
    }else {
        bottomLineY = CGRectGetMaxY(tipLabel.frame) + 30;
    }
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, bottomLineY, content.frame.size.width, LINE_WH)];
    bottomLine.backgroundColor = THE_LINE_COLOR;
    [content addSubview:bottomLine];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(bottomLine.frame) + 20, (content.frame.size.width - 60) / 2, 45)];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.borderColor = THEMECOLOR.CGColor;
    cancelBtn.layer.borderWidth = 1.0;
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:Localized(@"JX_Cencal") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:cancelBtn];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 20, CGRectGetMaxY(bottomLine.frame) + 20, (content.frame.size.width - 60) / 2, 45)];
    doneBtn.layer.cornerRadius = 5;
    doneBtn.backgroundColor = THEMECOLOR;
    UIImage *img = [UIImage createImageWithColor:[UIFactory maskColor:[g_theme themeColor]  withMask:HEXCOLOR(0x000000) withAlpha:0.2]];
    [doneBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    [doneBtn setTitle:Localized(@"JX_Confirm") forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.custom_acceptEventInterval = 2;
    [content addSubview:doneBtn];
    
    content.frame = CGRectMake(content.frame.origin.x, content.frame.origin.y, content.frame.size.width, CGRectGetMaxY(doneBtn.frame) + 20);
    content.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)setQrUrl:(NSString *)qrUrl {
 
    _qrUrl = qrUrl;
    [self customView];
    
//    CGSize size = [_tipLabel.text boundingRectWithSize:CGSizeMake(_tipLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_tipLabel.font} context:nil].size;
//    _tipLabel.frame = CGRectMake(_tipLabel.frame.origin.x, _tipLabel.frame.origin.y, _tipLabel.frame.size.width, size.height);
//    _bottomLine.frame = CGRectMake(_bottomLine.frame.origin.x, CGRectGetMaxY(_tipLabel.frame) + 10, _bottomLine.frame.size.width, _bottomLine.frame.size.height);
//    _cancelBtn.frame = CGRectMake(_cancelBtn.frame.origin.x, CGRectGetMaxY(_bottomLine.frame) + 20, _cancelBtn.frame.size.width, _cancelBtn.frame.size.height);
//    _doneBtn.frame = CGRectMake(_doneBtn.frame.origin.x, CGRectGetMaxY(_bottomLine.frame) + 20, _doneBtn.frame.size.width, _doneBtn.frame.size.height);
//    _content.frame = CGRectMake(_content.frame.origin.x, _content.frame.origin.y, _content.frame.size.width, CGRectGetMaxY(_doneBtn.frame) + 20);
//    _content.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)closeBtnAction {

    [self removeFromSuperview];
}

- (void)saveBtnAction {
    if (_qrImageView.image) {
        [self saveImageToPhotos:_qrImageView.image];
    }
}

- (void)cancelBtnAction {
    
    [self removeFromSuperview];
}

- (void)doneBtnAction {
    if ([self.delegate respondsToSelector:@selector(rechargeQRCodeView:doneBtnActionWithMoney:type:)]) {
        [self.delegate rechargeQRCodeView:self doneBtnActionWithMoney:self.money type:self.type];
        
//        [self removeFromSuperview];
    }
}

- (void)copyBtnAction:(UIButton *)btn {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (btn.tag == 10001) {
        [pasteboard setString:self.name];
    }else if (btn.tag == 10002) {
        [pasteboard setString:self.bankCard];
    }else if (btn.tag == 10003) {
        [pasteboard setString:self.bankName];
    }
    [g_server showMsg:Localized(@"JX_CopySuccess")];
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        
        msg = Localized(@"ImageBrowser_saveFaild");
        
    }else{
        
        msg = Localized(@"ImageBrowser_saveSuccess");
        
    }
    
    [g_server showMsg:msg];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
