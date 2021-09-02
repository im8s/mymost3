//
//  JXSearchRecordCell.m
//  shiku_im
//
//  Created by IMAC on 2019/8/27.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "JXSearchShowCell.h"

@implementation JXSearchShowCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withNewStyle:(JXSearchShowCellStyle)newStyle{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellStyle = newStyle;
        switch (newStyle) {
            case JXSearchShowCellStyleUser:
                {
                    self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9.83333, 40, 40)];
                    self.headImgView.layer.cornerRadius = 20;
                    self.headImgView.layer.masksToBounds = YES;
                    [self.contentView addSubview:self.headImgView];
                    [self setSeparatorInset:UIEdgeInsetsMake(0, 80, 0, 0)];
                    self.aboveLable = [[UILabel alloc] initWithFrame:CGRectMake(80 ,20, JX_SCREEN_WIDTH - 90 ,22)];
                    self.aboveLable.font = [UIFont systemFontOfSize:16];
                    self.aboveLable.textAlignment = NSTextAlignmentLeft;
                    self.aboveLable.textColor = [UIColor blackColor];
                    [self.contentView addSubview:self.aboveLable];
                    self.belowLable = [[UILabel alloc] initWithFrame:CGRectMake(80 ,28.3333, 0 ,0)];
                    self.belowLable.font = [UIFont systemFontOfSize:13];
                    self.belowLable.textColor = [UIColor grayColor];
                    [self.contentView addSubview:self.belowLable];
                    self.selectionStyle = UITableViewCellSelectionStyleNone;
                    self.selectView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, JX_SCREEN_WIDTH - 16, 60)];
                    self.selectView.backgroundColor = [UIColor grayColor];
                    self.selectView.alpha = 0.3;
                    self.selectView.hidden = YES;
                    [self.contentView addSubview:self.selectView];

                }
                break;
            case JXSearchShowCellStyleRecord:
                {
                    self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9.83333, 40, 40)];
                    self.headImgView.layer.cornerRadius = 20;
                    self.headImgView.layer.masksToBounds = YES;
                    [self.contentView addSubview:self.headImgView];
                    [self setSeparatorInset:UIEdgeInsetsMake(0, 80, 0, 0)];
                    self.aboveLable = [[UILabel alloc] initWithFrame:CGRectMake(80 ,10, 108.333 ,14.3333)];
                    self.aboveLable.font = [UIFont systemFontOfSize:13];
                    self.aboveLable.textAlignment = NSTextAlignmentLeft;
                    self.aboveLable.textColor = HEXCOLOR(0x999999);
                    [self.contentView addSubview:self.aboveLable];
                    self.belowLable = [[UILabel alloc] initWithFrame:CGRectMake(80 ,30, JX_SCREEN_WIDTH - 90 ,18)];
                    self.belowLable.font = [UIFont systemFontOfSize:15];
                    self.belowLable.textAlignment = NSTextAlignmentLeft;
                    self.belowLable.textColor = [UIColor blackColor];
                    [self.contentView addSubview:self.belowLable];
                    self.rightLable = [[UILabel alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH - 170 , 10 , 160 , 14.3333)];
                    self.rightLable.textAlignment = NSTextAlignmentRight;
                    self.rightLable.font = [UIFont systemFontOfSize:13];
                    self.rightLable.textColor = [UIColor grayColor];
                    [self.contentView addSubview:self.rightLable];
                }
            default:
                break;
        }
        
    }
    return self;
}
- (void)setHeadImg:(NSString *)headImg{
    _headImg = headImg;
    _headImgView.image = [UIImage imageNamed:_headImg];
}
- (void)setAboveText:(NSString *)aboveText{
    _aboveText = aboveText;
    _aboveLable.text = _aboveText;
}
- (void)setAboveAttributedText:(NSMutableAttributedString *)aboveAttributedText{
    _aboveAttributedText = aboveAttributedText;
    _aboveLable.attributedText = _aboveAttributedText;
    _belowLable.lineBreakMode = NSLineBreakByTruncatingTail;
}
- (void)setBelowText:(NSString *)belowText{
    switch (_cellStyle) {
        case JXSearchShowCellStyleUser:
            {
                _belowText = belowText;
                _belowLable.text = _belowText;
                _aboveLable.frame = CGRectMake(80 ,7, JX_SCREEN_WIDTH - 90 ,22);
                _belowLable.frame = CGRectMake(80 ,35.3333, JX_SCREEN_WIDTH - 90 ,17);
            }
            break;
        case JXSearchShowCellStyleRecord:
            {
                _belowText = belowText;
                NSAttributedString *str = [self setContentLabelStr:_belowText searchText:self.searchText];
                _belowLable.attributedText = str;
                _belowLable.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            
        default:
            break;
    }
}
- (void)setBelowAttributedText:(NSMutableAttributedString *)belowAttributedText{
    switch (_cellStyle) {
        case JXSearchShowCellStyleUser:
            {
                _belowAttributedText = belowAttributedText;
                _belowLable.attributedText = _belowAttributedText;
                _belowLable.lineBreakMode = NSLineBreakByTruncatingTail;
                _aboveLable.frame = CGRectMake(80 ,7, JX_SCREEN_WIDTH - 90 ,22);
                _belowLable.frame = CGRectMake(80 ,35.3333, JX_SCREEN_WIDTH - 90 ,17);
            }
            break;
        case JXSearchShowCellStyleRecord:
            {
                _belowAttributedText = belowAttributedText;
                _belowLable.attributedText = _belowAttributedText;
                _belowLable.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            break;
        default:
            break;
    }

}
- (void)setRightText:(NSString *)rightText{
    _rightText = rightText;
    _rightLable.text = _rightText;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        switch (self.cellStyle) {
            case JXSearchShowCellStyleUser:
                self.selectView.hidden = NO;
                [self performSelector:@selector(hiddenSelectView) withObject:nil afterDelay:0.5];
                break;
                
            default:
                break;
        }
    }
   
}
- (void)cutSelectedView{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = CGRectInset(self.selectView.bounds, 0, 0);
    CGFloat cornerRadius = 7;
    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    layer.path = pathRef;
    CFRelease(pathRef);
    layer.fillColor = [UIColor grayColor].CGColor;
    self.selectView.backgroundColor = [UIColor clearColor];
    [self.selectView.layer addSublayer:layer];
    self.selectView.alpha = 0.3;
}
- (void)hiddenSelectView{
    self.selectView.hidden = YES;
}

- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
    NSRange range=[message rangeOfString: @"["];
    
    NSRange range1=[message rangeOfString: @"]"];
    
    
    // 动画过滤
    if ([message isEqualToString:[NSString stringWithFormat:@"[%@]",Localized(@"emojiVC_Emoji")]]) {
        [array addObject:message];
        return;
    }
    
    
    //判断当前字符串是否还有表情的标志。
    
    if (range.length>0 && range1.length>0 && range1.location > range.location) {
        
        if (range.location > 0) {
            
            NSString *str = [message substringToIndex:range.location];
            
            NSString *str1 = [message substringFromIndex:range.location];
            
            [array addObject:str];
            
            [self getMessageRange:str1 :array];
            
        }else {
            
            NSString *emojiString = [message substringWithRange:NSMakeRange(range.location + 1, range1.location - 1)];
            BOOL isEmoji = NO;
            NSString *str;
            NSString *str1;
            for (NSMutableDictionary *dic in g_constant.emojiArray) {
                NSString *emoji = [dic objectForKey:@"english"];
                if ([emoji isEqualToString:emojiString]) {
                    isEmoji = YES;
                    break;
                }
            }
            if (isEmoji) {
                str = [message substringWithRange:NSMakeRange(range.location, range1.location + 1)];
                str1 = [message substringFromIndex:range1.location + 1];
                [array addObject:str];
            }else{
                NSString *posString = [message substringWithRange:NSMakeRange(range.location + 1, range1.location)];
                NSRange posRange = [posString rangeOfString:@"["];
                if (posRange.location != NSNotFound) {
                    str = [message substringToIndex:posRange.location + 1];
                    str1 = [message substringFromIndex:posRange.location + 1];
                    [array addObject:str];
                }else{
                    str = [message substringToIndex:range.location + 1];
                    str1 = [message substringFromIndex:range.location + 1];
                    [array addObject:str];
                }
            }
            [self getMessageRange:str1 :array];
        }
        
    }else if (range.length>0 && range1.length>0 && range1.location < range.location){
        NSString *str = [message substringToIndex:range1.location + 1];
        NSString *str1 = [message substringFromIndex:range1.location + 1];
        [array addObject:str];
        [self getMessageRange:str1 :array];
    }else if (message != nil) {
        
        [array addObject:message];
        
    }
    
}
- (NSAttributedString *)setContentLabelStr:(NSString *)str searchText:(NSString *)searchText{
    NSMutableArray *conArray = [NSMutableArray array];
    
    [self getMessageRange:str :conArray];
    
    NSMutableArray *contentArray = [NSMutableArray array];
    _num = 0;
    [self splicingString:conArray inArray:contentArray];
    
    NSMutableAttributedString *strM = [[NSMutableAttributedString alloc] init];
    
    NSInteger count = contentArray.count;
    if (contentArray.count > 15) {
        count = 15;
    }
    
    for (NSInteger i = 0; i < count; i ++) {
        
        NSString *object = contentArray[i];
        
        //        NSLog(@"%@",object);
        BOOL flag = NO;
        if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
            
            //如果是表情用iOS中附件代替string在label上显示
            
            NSTextAttachment *imageStr = [[NSTextAttachment alloc]init];
            NSString *imageShortName = [object substringWithRange:NSMakeRange(1, object.length - 2)];
            for (NSInteger i = 0; i < g_constant.emojiArray.count; i ++) {
                NSDictionary *dict = g_constant.emojiArray[i];
                NSString *imageName = dict[@"english"];
                if ([imageName isEqualToString:imageShortName]) {
                    imageStr.image = [UIImage imageNamed:dict[@"filename"]];
                    flag = YES;
                    break;                }
            }
            if (!flag) {
                [strM appendAttributedString:[[NSAttributedString alloc] initWithString:object]];
                
                NSRange range = [object rangeOfString:Localized(@"JX_Draft")];
                [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                
                range = [object rangeOfString:Localized(@"JX_Someone@Me")];
                [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                continue;
            }
            //            imageStr.image = [UIImage imageNamed:[object substringWithRange:NSMakeRange(1, object.length - 2)]];
            
            //这里对图片的大小进行设置一般来说等于文字的高度
            
            CGFloat height = self.belowLable.font.lineHeight + 1;
            
            imageStr.bounds = CGRectMake(0, -4, height, height);
            
            NSAttributedString *attrString = [NSAttributedString attributedStringWithAttachment:imageStr];
            
            [strM appendAttributedString:attrString];
            
        }else{
            
            //如果不是表情直接进行拼接
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:object];
            NSRange attRange = [object rangeOfString:searchText];
            if (attRange.location != NSNotFound) {
                [attString addAttribute:NSForegroundColorAttributeName value:[g_theme themeColor] range:attRange];
            }
            
            [strM appendAttributedString:attString];
            
            NSRange range = [object rangeOfString:Localized(@"JX_Draft")];
            [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            
            range = [object rangeOfString:Localized(@"JX_Someone@Me")];
            [strM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            
            
        }
        
    }
        
    return strM;
}
//拼接字符串
- (void)splicingString:(NSMutableArray *)array inArray:(NSMutableArray *)contentArray{
    if (_num >= array.count) {
        return;
    }
    NSString *str = [NSString string];
    for (NSInteger i = _num; i < array.count; i++) {
        NSString *object = array[i];
        if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
            [contentArray addObject:str];
            [contentArray addObject:object];
            _num = i + 1;
            break;
        }else{
            _num = i + 1;
            str = [str stringByAppendingString:object];
            if (_num >= array.count) {
                [contentArray addObject:str];
                return;
            }
        }
    }
    [self splicingString:array inArray:contentArray];
}

@end
