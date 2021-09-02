//
//  JXSelectCashWithdrawalCell.m
//  shiku_im
//
//  Created by p on 2019/12/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSelectCashWithdrawalCell.h"

@implementation JXSelectCashWithdrawalCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self customSubviews:reuseIdentifier];
    }
    return self;
}

-(void)customSubviews:(NSString *)identifier{
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 10, JX_SCREEN_WIDTH - 30, 55)];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.layer.cornerRadius = 5.0;
    baseView.layer.masksToBounds = YES;
    [self.contentView addSubview:baseView];
    
    
    _addLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, baseView.frame.size.width, baseView.frame.size.height)];
    _addLabel.font = [UIFont systemFontOfSize:17.0];
    _addLabel.textAlignment = NSTextAlignmentCenter;
    _addLabel.textColor = HEXCOLOR(0x2966CE);
    if ([identifier isEqualToString:@"addAli"]) {
        _addLabel.text = Localized(@"JX_AddNewAlipay");
    }else {
        _addLabel.text = Localized(@"JX_AddNewBankCard");
    }
    _addLabel.hidden = YES;
    [baseView addSubview:_addLabel];
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 25, 25)];
    self.icon.image = [UIImage imageNamed:@"withdrawal_aliPay"];
    [baseView addSubview:self.icon];
    
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.icon.frame) + 5, 0, baseView.frame.size.width - CGRectGetMaxX(self.icon.frame) - 5, baseView.frame.size.height)];
    self.name.font = [UIFont systemFontOfSize:17.0];
    self.name.textAlignment = NSTextAlignmentLeft;
    self.name.text = @"dghjjk@163.com";
    [baseView addSubview:self.name];
    
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    
    if (self.tag - 10000 == 0 || self.tag - 10000 == 1) {
        self.icon.hidden = YES;
        self.name.hidden = YES;
        self.addLabel.hidden = NO;
        if (self.tag - 10000 == 0) {
            _addLabel.text = Localized(@"JX_AddNewAlipay");
        }else {
            _addLabel.text = Localized(@"JX_AddNewBankCard");
        }
    }else {
        self.icon.hidden = NO;
        self.name.hidden = NO;
        self.addLabel.hidden = YES;
        if ([[data objectForKey:@"type"] intValue] == 1) {
            self.icon.image = [UIImage imageNamed:@"withdrawal_aliPay"];
            self.name.text = [data objectForKey:@"aliPayName"];
        }else {
            self.icon.image = [UIImage imageNamed:@"yinlian"];
            NSString *bankCardNo = [data objectForKey:@"bankCardNo"];
            NSString *last4Num = [bankCardNo substringFromIndex:bankCardNo.length - 4];
            self.name.text = [NSString stringWithFormat:@"%@ (%@)",[data objectForKey:@"bankName"],last4Num];
        }
    }
    
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
