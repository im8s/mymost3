//
//  JXRecordCell.m
//  shiku_im
//
//  Created by 1 on 2019/4/20.
//  Copyright © 2019年 Reese. All rights reserved.
//

#import "JXRecordCell.h"
#import "JXRecordModel.h"

@interface JXRecordCell ()
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UILabel *money;
@property (nonatomic, strong) UILabel *status;

@end

@implementation JXRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.desc = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 200, 18)];
        self.desc.font = SYSFONT(15);
        [self.contentView addSubview:self.desc];
        
        self.time = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.desc.frame)+5, 100, 15)];
        self.time.font = SYSFONT(13);
        self.time.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.time];

        self.money = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-110, 13, 100, 18)];
        self.money.font = [UIFont boldSystemFontOfSize:16];
        self.money.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.money];

        self.status = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-110, CGRectGetMaxY(self.money.frame)+5, 100, 15)];
        self.status.font = SYSFONT(13);
        self.status.textColor = [UIColor grayColor];
        self.status.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.status];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, JX_SCREEN_WIDTH, LINE_WH)];
        _lineView.backgroundColor = THE_LINE_COLOR;
        [self.contentView addSubview:_lineView];
    }
    return self;
}


- (void)setData:(JXRecordModel *)model {
    self.desc.text = model.desc;
    
    self.time.text = [self stringToDate:model.time withDateFormat:[self isThisYear:model.time] ? @"MM-dd" : @"yyyy-MM-dd"];
    self.status.text = [self getPayType:model.status];
    
    if (model.type == 1 || model.type == 2 || model.type == 3 || model.type == 4 || model.type == 7 || model.type == 10 || model.type == 12) {
        self.money.text = @"-";
        self.money.textColor = [UIColor blackColor];
    }else {
        self.money.text = @"+";
        self.money.textColor = THEMECOLOR;
    }
    
    self.money.text = [self.money.text stringByAppendingString:[NSString stringWithFormat:@"%.2f",model.money]];

}

- (NSString *)getPayType:(int)status {
    NSString *str = [NSString string];
    
    if (status == 0) {//创建
        str= Localized(@"JX_Create");
    }
    else if (status == 1) {//支付完成
        str= Localized(@"JX_PayToComplete");
    }
    else if (status == 2) {//交易完成
        str= Localized(@"JX_CompleteTheTransaction");
    }
    else if (status == -1) {//交易关闭
        str= Localized(@"JX_TradingClosed");
    }

    return str;
}

//字符串转日期格式
- (NSString *)stringToDate:(long)date withDateFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    
    NSDate*timeDate = [[NSDate alloc] initWithTimeIntervalSince1970:date];
    return [dateFormatter stringFromDate:timeDate];
}

//是否是今年
- (BOOL)isThisYear:(long)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];

    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:[NSDate dateWithTimeIntervalSince1970:date]];

    return nowCmps.year == selfCmps.year;
}


@end
