//
//  JXEmoji.m
//  sjvodios
//
//  Created by jixiong on 13-7-9.
//
//

#import "JXEmoji.h"
#import "FaceViewController.h"
#import "emojiViewController.h"
#import "webpageVC.h"
#import "JXActionSheetVC.h"

#import <CoreText/CoreText.h>

@interface JXEmoji () <JXActionSheetVCDelegate>

@property (nonatomic, strong) JXActionSheetVC *actionVC;

@end

@implementation JXEmoji
@synthesize maxWidth,faceHeight,faceWidth,offset;

#define BEGIN_FLAG @"["
#define END_FLAG @"]"
#define AT_FLAG @"@"

static NSMutableArray *faceArray;
static NSMutableArray *imageArrayC;
static NSMutableArray *imageArrayE;
static NSMutableArray *shortNameArrayC;
static NSMutableArray *shortNameArrayE;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if(shortNameArrayC==nil){
            /*
            faceArray = [[NSArray alloc]initWithObjects:@"[微笑]",@"[撇嘴]",@"[色]",@"[发呆]",@"[得意]",@"[流泪]",@"[害羞]",@"[闭嘴]",@"[睡]",@"[大哭]",
                         @"[尴尬]",@"[发怒]",@"[调皮]",@"[龇牙]",@"[惊讶]",@"[难过]",@"[严肃]",@"[冷汗]",@"[抓狂]",@"[吐]",@"[偷笑]",@"[可爱]",@"[白眼]",@"[傲慢]",
                         @"[饥饿]",@"[困]",@"[惊恐]",@"[流汗]",@"[憨笑]",@"[大兵]",@"[奋斗]",@"[咒骂]",@"[疑问]",@"[嘘]",@"[晕]",@"[折磨]",@"[衰]",@"[骷髅]",
                         @"[敲打]",@"[再见]",@"[擦汗]",@"[抠鼻]",@"[鼓掌]",@"[糗大了]",@"[坏笑]",@"[左哼哼]",@"[右哼哼]",@"[哈欠]",@"[鄙视]",@"[委屈]",@"[快哭了]",
                         @"[阴险]",@"[亲嘴]",@"[吓]",@"[可怜]",@"[菜刀]",@"[西瓜]",@"[啤酒]",@"[篮球]",@"[乒乓]",@"[咖啡]",@"[饭]",@"[猪头]",@"[玫瑰]",@"[凋谢]",
                         @"[示爱]",@"[爱心]",@"[心碎]",@"[蛋糕]",@"[闪电]",@"[炸弹]",@"[刀]",@"[足球]",@"[瓢虫]",@"[便便]",@"[拥抱]",@"[月亮]",@"[太阳]",@"[礼物]",
                         @"[强]",@"[弱]",@"[握手]",@"[胜利]",@"[抱拳]",@"[勾引]",@"[拳头]",@"[差劲]",@"[爱你]",@"[NO]",@"[OK]",@"[苹果]",@"[可爱狗]",@"[小熊]",@"[彩虹]",@"[皇冠]",@"[钻石]",nil];
            
            imageArray = [[NSMutableArray alloc] init];
            for (int i = 0;i<[faceArray count];i++){
//                NSString* s = [NSString stringWithFormat:@"%@f%.3d.png",[self imageFilePath],i];
                NSString* s = [NSString stringWithFormat:@"f%.3d.png",i];
                [imageArray addObject:s];
            }*/
//            faceArray  = g_faceVC.faceArray;
//            imageArrayC = g_faceVC.imageArrayC;
//            imageArrayE = g_faceVC.imageArrayE;
            shortNameArrayC = g_faceVC.shortNameArrayC;
            shortNameArrayE = g_faceVC.shortNameArrayE;
        }
        data = [[NSMutableArray alloc] init];
        faceWidth  = 23;
        faceHeight = 23;
        _top       = 0;
        offset     = 0;
        maxWidth   = JX_SCREEN_WIDTH-INSETS-HEAD_SIZE - 100;
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.textAlignment = NSTextAlignmentLeft;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)dealloc{
//    [data release];
//    [super dealloc];
}

/*
-(void) drawRect:(CGRect)rect
{
    [self.textColor set];
//    if( [data count]==1){
//        if (![self.text hasPrefix:BEGIN_FLAG] && ![self.text hasSuffix:END_FLAG]){
//            [super drawRect:rect];
//            return;
//        }
//    }
    
    CGFloat upX=0;
    CGFloat upY=0;
    CGFloat height = 0;
    //    NSLog(@"%f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    for (int i=0;i<[data count];i++) {
        
        
        NSString *str=[data objectAtIndex:i];
        unsigned long n = NSNotFound;
        
        if ([str hasPrefix:BEGIN_FLAG]&&[str hasSuffix:END_FLAG]) {
            n = [shortNameArrayC indexOfObject:str];
            if(n != NSNotFound){
                //                NSString *imageName = [imageArrayC objectAtIndex:n];
                NSDictionary *dic = [g_constant.emojiArray objectAtIndex:n];
                NSString *imageName = dic[@"filename"];
                UIImage *img=[UIImage imageNamed:imageName];
                
                if ((faceWidth+upX) >= maxWidth)
                {
                    upY = upY + height;
                    upX = 0;
                }
                //
                [img drawInRect:CGRectMake(upX, upY+_top, faceWidth, faceHeight)];
                //                NSLog(@"%@,%f,%f",str,upX,upY);
                upX=faceWidth+upX;
                height = faceHeight;
            }else {
                n = [shortNameArrayE indexOfObject:str];
                if(n != NSNotFound){
                    //                    NSString *imageName = [imageArrayC objectAtIndex:n];
                    NSDictionary *dic = [g_constant.emojiArray objectAtIndex:n];
                    NSString *imageName = dic[@"filename"];
                    UIImage *img=[UIImage imageNamed:imageName];
                    if ((faceWidth+upX) >= maxWidth)
                    {
                        upY = upY + height;
                        upX = 0;
                        height = 0;
                    }
                    [img drawInRect:CGRectMake(upX, upY+_top, faceWidth, faceHeight)];
                    upX=faceWidth+upX;
                    height = faceHeight;
                    
                    //                NSLog(@"%@,%f,%f",str,upX,upY);
                }
            }
        }
        
        if(n == NSNotFound){
            
            NSArray *arr = [self setTextWithLinkAttribute:str];
            for (int j = 0; j < [str length]; j++) {
                NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                CGSize size = [temp boundingRectWithSize:CGSizeMake(_size, _size) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
                if([temp isEqualToString:@"\n"] || [temp isEqualToString:@"\r"]){
                    upY = upY + 20;
                    upX = 0;
                }else{
                    //                    CGSize size=[temp sizeWithFont:self.font constrainedToSize:CGSizeMake(_size, _size)];
//                    CGSize size = [temp boundingRectWithSize:CGSizeMake(_size, _size) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
                    
                    if ((upX+size.width) >= maxWidth)
                    {
                        //                        upY = upY + size.height;
                        upY = upY + size.height;;
                        upX = 0;
                        height = 0;
                    }
//                    [temp drawInRect:CGRectMake(upX, upY+_top + 3, size.width, size.height) withFont:self.font];
                    BOOL flag = NO;
                    for (NSInteger i = 0; i < arr.count; i ++) {
                        NSRange range = [arr[i] rangeValue];
                        if (j >= range.location && j < range.length + range.location) {
                            flag = YES;
                            break;
                        }
                    }
                    if (flag) {
                        [temp drawInRect:CGRectMake(upX, upY+_top + 3, size.width, size.height) withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:[UIColor blueColor]}];
                    }else {
 
                        [temp drawInRect:CGRectMake(upX, upY+_top + 3, size.width, size.height) withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:[UIColor blackColor]}];
                    }
                    upX=upX+size.width;
                    
                    if (height != faceHeight) {
                        height = _size;
                    }
                }
                //                NSLog(@"%@,%f,%f",temp,upX,upY);
            }
        }
    }
    
}
*/

//判断是否含有表情
- (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    isEomji = YES;
                }
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                isEomji = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                isEomji = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                isEomji = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                isEomji = YES;
            }
            if (!isEomji && substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                if (ls == 0x20e3) {
                    isEomji = YES;
                }
            }
        }
    }];
    return isEomji;
}

//将表情和文字分开，装进array
-(void)getImageRange:(NSString*)message  array: (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    NSRange atRange = [message rangeOfString:AT_FLAG];
    //判断当前字符串是否还有表情的标志。
    
    self.contentEmoji = [self isContainsEmoji:message];
    
    if (((range.length>0 && range1.length>0) || atRange.length>0) && range1.location > range.location) {
        if (range.length>0 && range1.length>0) {
//            self.contentEmoji = YES;
//            if (range.location > 0) {
//                [array addObject:[message substringToIndex:range.location]];
//                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
//                NSString *str=[message substringFromIndex:range1.location+1];
//                [self getImageRange:str array:array];
//            }else {
//                NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
//                //排除文字是“”的
//                if (![nextstr isEqualToString:@""]) {
//                    [array addObject:nextstr];
//                    NSString *str=[message substringFromIndex:range1.location+1];
//                    [self getImageRange:str array:array];
//                }else {
//                    return;
//                }
//            }

            
            if (range.location > 0) {

                NSString *str = [message substringToIndex:range.location];

                NSString *str1 = [message substringFromIndex:range.location];

                [array addObject:str];

                [self getImageRange:str1 array:array];

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
                    self.contentEmoji = YES;
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
                        str = [message substringToIndex:range1.location + 1];
                        str1 = [message substringFromIndex:range1.location + 1];
                        [array addObject:str];
                    }
                }
                [self getImageRange:str1 array:array];
            }

            
        } else if (atRange.length>0) {
            if (atRange.location > 0) {
                [array addObject:[message substringToIndex:atRange.location]];
                [array addObject:[message substringWithRange:NSMakeRange(atRange.location, 1)]];
                NSString *str=[message substringFromIndex:atRange.location+1];
                [self getImageRange:str array:array];
            }else{
                [array addObject:[message substringWithRange:NSMakeRange(atRange.location, 1)]];
                NSString *str=[message substringFromIndex:atRange.location+1];
                [self getImageRange:str array:array];
            }
            
        }else if (message != nil) {
            [array addObject:message];
        }
    }
    
    else if (range.length>0 && range1.length>0 && range1.location < range.location){
        NSString *str = [message substringToIndex:range1.location + 1];
        NSString *str1 = [message substringFromIndex:range1.location + 1];
        [array addObject:str];
        [self getImageRange:str1 array:array];
    }

    else if (message != nil) {
        [array addObject:message];
    }
}

//获取特殊文本的范围
#pragma mark ------------特殊字符-----------------
-(void)setAttributedTextRange:(NSString *)text{
    
    NSError *error = NULL;
    
    NSString * patren = @"[^0-9]";
    
    NSRegularExpression * reg = [NSRegularExpression regularExpressionWithPattern:patren options:0 error:&error];
    
    NSString * numberString = [reg stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@" "];
    //提取所有数字串
    NSArray * array = [numberString componentsSeparatedByString:@" "];
    
    NSMutableArray * numberArr = [[NSMutableArray alloc]init];
    //除去空格,并在手机号前后加空格
    NSMutableString * muText = [[NSMutableString alloc]initWithString:text];

    //因为插入空格后位置发生变化
    int plus = 0;
    for (int i = 0; i < [array count]; i++) {
        
        NSString * number = array[i];
        if (![number isEqualToString:@""] && number.length >5) {
            
            NSRange range = [text rangeOfString:number];
            [muText insertString:@" " atIndex:range.location +plus*2];
            [muText insertString:@" " atIndex:(range.location + range.length+1+plus*2)];
            //保存空格位置，以后删除
            [numberArr addObject:[NSNumber numberWithInteger:range.location]];
            [numberArr addObject:[NSNumber numberWithInteger:(range.location + range.length)]];
            
            plus++;
        }
    }
    text = muText;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink  error:&error];
    
    self.matches = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    [self highlightLinksWithIndex:NSNotFound];
    
    //删除之前添加的空格
    
    for (int i = 0; i < [numberArr count]; i++) {
        NSNumber * index = numberArr[i];
        [muText deleteCharactersInRange:NSMakeRange([index integerValue], 1)];
    }
    
    text = muText;

}

- (NSArray *)setTextWithAttribute:(NSString *)text attributedText:(NSMutableAttributedString *)attributedText regulaStr:(NSString *)regulaStr  {
    
    NSError *error;
    //可以识别url的正则表达式
//    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if (!arrayOfAllMatches || arrayOfAllMatches.count <= 0) {
        return nil;
    }
    
    
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSMutableArray *rangeArr=[[NSMutableArray alloc]init];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch;
        substringForMatch = [text substringWithRange:match.range];
        [arr addObject:substringForMatch];
        
    }
    NSString *subStr=[text copy];
    NSUInteger index = 0;
    for (NSString *str in arr) {
        NSValue *value = [self rangesOfString:str inString:subStr];
        NSRange range = [value rangeValue];
        
        if ((range.location + range.length) < text.length) {
            subStr = [subStr substringFromIndex:range.location + range.length];
        }
        range.location += index;
        value = [NSValue valueWithRange:range];
        [rangeArr addObject:value];
        index = range.location + range.length;
        
        
    }
//    UIFont *font = self.font;
//    NSMutableAttributedString *attributedText;
//    attributedText=[[NSMutableAttributedString alloc]initWithString:subStr attributes:@{NSFontAttributeName :font}];
    
    self.matches = [NSMutableArray array];
    for(NSValue *value in rangeArr)
    {
        NSInteger index=[rangeArr indexOfObject:value];
        NSRange range=[value rangeValue];
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink  error:&error];
        [self.matches addObjectsFromArray:[detector matchesInString:text options:0 range:range]];
        
        NSString * urlStr = [[arr objectAtIndex:index] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [attributedText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:urlStr] range:range];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
        
    }
//    self.attributedText = attributedText;
    
    return rangeArr;
}

//获取查找字符串在母串中的NSRange
- (NSValue *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    
    NSRange searchRange = NSMakeRange(0, [str length]);
    
    NSRange range;
    
    if ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return [NSValue valueWithRange:range];
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index <= range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    if(self.contentEmoji){
        return;
    }
    
    NSMutableAttributedString* attributedString = [self.attributedText mutableCopy];
    
    //因为之前添加空格位置发生变化
    int plus = 0;
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypePhoneNumber||[match resultType] == NSTextCheckingTypeLink) {
            NSRange matchRange;
            if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                matchRange = NSMakeRange(match.range.location -1 -2*plus, match.range.length);
                plus++;
            }else{
                matchRange = NSMakeRange(match.range.location -2*plus, match.range.length);
            }
            

            if (matchRange.location == 18446744073709551615 &&matchRange.length !=0) {
                matchRange.location =0;
            }
            //被点击时吗，判断index在range蓝色字体范围内，则变灰，默认为蓝色
            if ((matchRange.location + matchRange.length) > attributedString.length) {
                matchRange.length = attributedString.length - matchRange.location;
            }
            if (matchRange.length <= attributedString.length) {
                if ([self isIndex:index inRange:matchRange]) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
                }
                else {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
                }
                
                //添加下划线
                if ([match resultType] == NSTextCheckingTypeLink) {
                    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
                }
            }
            
        }
    }
    
    self.attributedText = attributedString;
}

//被点击时获取特殊字符的位置
- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    ////////
    NSMutableAttributedString* optimizedAttributedText = [self.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName]) {
            
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.font range:NSMakeRange(0, [self.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName]) {
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        
        NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
        
        if ([paragraphStyle lineBreakMode] == kCTLineBreakByTruncatingTail) {
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        }
        
        [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
        [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
    }];
    
    ////////
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = [self textRect];
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    //////
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + textRect.size.width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

//上面的方法调用
- (CGRect)textRect {
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    textRect.origin.y = (self.bounds.size.height - textRect.size.height)/2;
    
    if (self.textAlignment == NSTextAlignmentCenter) {
        textRect.origin.x = (self.bounds.size.width - textRect.size.width)/2;
    }
    if (self.textAlignment == NSTextAlignmentRight) {
        textRect.origin.x = self.bounds.size.width - textRect.size.width;
    }
    
    return textRect;
}

- (void)setText:(NSString *)text {
    int faceIndex = 0;
    [data removeAllObjects];
    
    [self getImageRange:text array:data];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] init];
    for (int i=0;i<[data count];i++) {
         NSString *str=[data objectAtIndex:i];
         BOOL isFace = NO;
         NSInteger n;
         if ([str hasPrefix:BEGIN_FLAG]&&[str hasSuffix:END_FLAG]) {
              isFace = [shortNameArrayC indexOfObject:str] != NSNotFound;
              n = [shortNameArrayC indexOfObject:str];
              if (!isFace) {
                  isFace = [shortNameArrayE indexOfObject:str] != NSNotFound;
                  n = [shortNameArrayE indexOfObject:str];
              }
              
              if(isFace){
                  NSDictionary *dic = [g_constant.emojiArray objectAtIndex:n];
                  // 创建图片图片附件
                  NSTextAttachment *attach = [[NSTextAttachment alloc] init];
                  attach.image = [UIImage imageNamed:dic[@"filename"]];
                  attach.bounds = CGRectMake(0, 0, faceWidth, faceHeight);
                  NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];
                  
                  //将图片插入到合适的位置
                  [attStr insertAttributedString:attachString atIndex:faceIndex];
                  faceIndex ++;
              }
        }
        //不是表情
        if(!isFace) {
            if (str.length > 0) {
                // 防止出现特殊符号自动换行问题
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;

                NSAttributedString *att = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : self.font,NSParagraphStyleAttributeName:paragraphStyle}];
                [attStr insertAttributedString:att atIndex:faceIndex];
                
                NSMutableString *string = [str mutableCopy];
                for (NSInteger i = 0; i < faceIndex; i ++) {
                    [string insertString:@" " atIndex:0];
                }
//                NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z0-9]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
//                 NSString *regulaStr = @"^((https?|ftp|file)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
//                NSString *regulaStr = @"(((ht|f)tp(s?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&%\$#\=~_\-]+))*";
                
                
//                regulaStr = @"((((ht|f)tp(s?))\\://)([a-zA-Z0-9\\-]+)(.[a-zA-Z0-9\\-]+)+|([a-zA-Z0-9\\-]+.)+(com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk))(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\;\?\'\\\\+&%\\$#\\=~_\\-]+))*";
                
                NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z0-9]+)(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(([a-zA-Z0-9\\-]+\\.)+(com|cn|cc|top|xyz|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk)(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
                
//                regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
                
                [self setTextWithAttribute:string attributedText:attStr regulaStr:regulaStr];
                
                regulaStr = @"((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}$";
                [self setTextWithAttribute:string attributedText:attStr regulaStr:regulaStr];
                
            }
            
            faceIndex += str.length;
        }
        
    }
    
    self.attributedText = attStr;
    CGSize size1 = [self sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y, size1.width, size1.height);
    

}

/*
-(void) setText:(NSString *)text{
    [super setText:text];
    [data removeAllObjects];
    [self getImageRange:text array:data];
 
    _size      = self.font.pointSize;
    
    //    maxWidth   = self.frame.size.width+offset;
//    maxWidth   = self.frame.size.width-_size*0.5;
    NSString *firstStr = data.firstObject;
    NSString *tempStr = [firstStr substringWithRange:NSMakeRange(0, 1)];
    CGSize size =[tempStr boundingRectWithSize:CGSizeMake(_size, _size) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    CGFloat upX = 0;
    CGFloat upY = size.height;
    CGFloat height = 0;
    BOOL isMoreLine=NO;
    if (data) {
        for (int i=0;i<[data count];i++) {
            NSString *str=[data objectAtIndex:i];
            BOOL isFace = NO;
            //是表情
            if ([str hasPrefix:BEGIN_FLAG]&&[str hasSuffix:END_FLAG]) {
                isFace = [shortNameArrayC indexOfObject:str] != NSNotFound;
                if (!isFace) {
                    isFace = [shortNameArrayE indexOfObject:str] != NSNotFound;
                }
                
                if(isFace){
 
                    if ((upX + faceWidth) >= maxWidth)
                    {
                        upY = upY + height;
                        upX = 0;
                        isMoreLine = YES;
                        height = 0;
                    }
                    
                    upX=faceWidth+upX;
                    height = faceHeight;
                    
                    if (!isMoreLine) {
                        upY = height;
                    }
                }
            }
            //不是表情
            if(!isFace) {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    CGSize size =[temp boundingRectWithSize:CGSizeMake(_size, _size) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
                    if([temp isEqualToString:@"\n"] || [temp isEqualToString:@"\r"]){
                        upY = upY + 20;
                        upX = 0;
                        isMoreLine = YES;
                    }else{
                        //                        CGSize size=[temp sizeWithFont:self.font constrainedToSize:CGSizeMake(_size, _size)];
                        
                        
                        if ((upX + size.width) >= maxWidth)
                        {
                            upY = upY + size.height;
                            upX = 0;
                            isMoreLine = YES;
                            height = 0;
                        }
                        upX=upX+size.width;
                        if (height != faceHeight) {
                            height = size.height;
                        }
                        
                        if (!isMoreLine) {
                            upY = height;
                        }
                    }
                }
            }
        }
    }
    if(upY<self.frame.size.height){
        //        _top = (self.frame.size.height-upY)/2;
        //        NSLog(@"_top=%d/%d",_top,self.frame.size.height);
    }
    if(upY<_size)
        upY = _size;
//    if(upY<self.frame.size.height)
//        upY = self.frame.size.height;
    
    if(isMoreLine){
        CGSize moreSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
        if (moreSize.width > maxWidth) {
            upX = maxWidth;
        }else {
            upX = moreSize.width;
        }
    }
    else
        upX = upX;
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y, upX, upY + 3); //@ 需要将该view的尺寸记下，方便以后使用
    //    NSLog(@"%d,%.1f %.1f", [data count], upX, upY);
    
    if (!self.contentEmoji) {
        if (text == nil) {
            return;
        }
//        if (self.isShowNumber) {
            [self setAttributedTextRange:text];
//        }
        
        // 显示链接
//        [self setTextWithLinkAttribute:text];
    }
    
}
*/
 
#pragma mark ---------------点击事件----------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.lastTouches = touches;
    
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    
    if (![self label:self didBeginTouch:touch onCharacterAtIndex:index]) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    self.lastTouches = touches;
    
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    
    if (![self label:self didMoveTouch:touch onCharacterAtIndex:index]) {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.lastTouches) {
        return;
    }
    
    self.lastTouches = nil;
    
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    
    if (![self label:self didEndTouch:touch onCharacterAtIndex:index]) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.lastTouches) {
        return;
    }
    
    self.lastTouches = nil;
    
    UITouch *touch = [touches anyObject];
    
    if (![self label:self didCancelTouch:touch]) {
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void)cancelCurrentTouch {
    
    if (self.lastTouches) {
        [self label:self didCancelTouch:[self.lastTouches anyObject]];
        self.lastTouches = nil;
    }
}

#pragma mark -------------点击处理------------------

- (BOOL)label:(JXEmoji *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
    return YES;
}

- (BOOL)label:(JXEmoji *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
    return YES;
}
//这里对文本的电话号码处理
- (BOOL)label:(JXEmoji *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [g_window endEditing:YES];
    
    [self highlightLinksWithIndex:NSNotFound];
    
    int plus = 0;
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            
            NSRange matchRange = NSMakeRange(match.range.location -1 -2*plus, match.range.length);
            
            if (matchRange.location == 18446744073709551615 &&matchRange.length !=0) {
                matchRange.location =0;
            }
            
            self.textCopy = match.phoneNumber;
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                self.actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_Copy"),Localized(@"JXEmoji_CallPhone")]];
                self.actionVC.delegate = self;
                self.actionVC.tag = 1;
                [g_App.window addSubview:self.actionVC.view];

                break;
            }
            plus++;
        }else if ([match resultType] == NSTextCheckingTypeLink){
            NSRange matchRange = NSMakeRange(match.range.location -2*plus, match.range.length);
            
            self.textCopy = [NSString stringWithFormat:@"%@",match.URL];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
//                self.actionVC = [[JXActionSheetVC alloc] initWithImages:@[] names:@[Localized(@"JX_Copy"),Localized(@"JXEmoji_OpenUrl")]];
//                self.actionVC.delegate = self;
//                self.actionVC.tag = 2;
//                [g_App.window addSubview:self.actionVC.view];
                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                [g_window endEditing:YES];
                    
                    webpageVC *webVC = [webpageVC alloc];
                    webVC.isGotoBack= YES;
                    webVC.isSend = YES;
                    webVC.url = self.textCopy;
                    webVC = [webVC init];
                    [g_navigation.navigationView addSubview:webVC.view];
                    //                [g_navigation pushViewController:webVC animated:YES];
                    
                    //                NSURL *cleanURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.textCopy]];
                    //                [[UIApplication sharedApplication] openURL:cleanURL];
//                });
                

                break;
            }
        }
    }
    
    return YES;
}

#pragma -mark actionSheet回调方法

- (void)actionSheet:(JXActionSheetVC *)actionSheet didButtonWithIndex:(NSInteger)index {
    self.backgroundColor=[UIColor clearColor];
    if (actionSheet.tag==1) {
        //复制
        if(index==0){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:self.textCopy];
        }else if(index==1){//打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.textCopy]]];
        }
    }else if (actionSheet.tag==2){
        //打开网址
        if(index==1){
            
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.textCopy]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [g_window endEditing:YES];
                
                webpageVC *webVC = [webpageVC alloc];
                webVC.isGotoBack= YES;
                webVC.isSend = YES;
                webVC.url = self.textCopy;
                webVC = [webVC init];
                [g_navigation.navigationView addSubview:webVC.view];
//                [g_navigation pushViewController:webVC animated:YES];
                
//                NSURL *cleanURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.textCopy]];
//                [[UIApplication sharedApplication] openURL:cleanURL];
            });
            [actionSheet.view removeFromSuperview];
            
        }else if(index==0){//复制
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:self.textCopy];
        }
    }
}


- (BOOL)label:(JXEmoji *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
}


@end
