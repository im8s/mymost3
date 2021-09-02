//
//  WeiboReplyData.m
//  wq8
//
//  Created by weqia on 13-9-5.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "WeiboReplyData.h"
#import "NSStrUtil.h"
@implementation WeiboReplyData
@synthesize height,title,messageId,toUserId,toNickName,toBody,body,userId,userNickName,giftCount,giftId,giftName,giftPrice,addHeight,replyId,createTime,height2;

#pragma -mark 接口方法

-(id)init{
    self = [super init];
    self.userNickName = @"";
    addHeight = 0;
    return self;
}

+(NSString *)getPrimaryKey
{
    return @"replyId";
}

+(NSString *)getTableName
{
    return @"WeiboReplyData";
}
+(NSCache*)shareCacheForReply
{
    static NSCache * cache=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache=[[NSCache alloc]init];
        cache.totalCostLimit=0.3*1024*1024;
    });
    return cache;
}
-(MatchParser*)getMatch
{
    if (_match) {
        _match.data=self;
        self.height=_match.height;
        return _match;
    }
    NSString *key=[NSString stringWithFormat:@"%@+%f+type:%d",self.body,self.createTime,self.type];
    MatchParser *parser=[[WeiboReplyData shareCacheForReply] objectForKey:key];
    if (parser) {
        _match=parser;
        self.height=parser.height;
        parser.data=self;
        return parser;
    }else{
        MatchParser* parser=nil;
        parser=[self createMatchType1];
        if (parser) {
            [[WeiboReplyData shareCacheForReply]  setObject:parser forKey:key];
        }
        return parser;
    }
}
-(MatchParser*)getMatch:(void(^)(MatchParser *parser,id data))complete data:(id)data
{
    if (_match) {
        _match.data=self;
        self.height=_match.height;
        return _match;
    }
    NSString *key=[NSString stringWithFormat:@"%@+%f+type:%d",self.body,self.createTime,self.type];
    MatchParser *parser=[[WeiboReplyData shareCacheForReply] objectForKey:key];
    if (parser) {
        _match=parser;
        self.height=parser.height;
        parser.data=self;
        return parser;
    }else{
        __block MatchParser* parser=nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            parser=[self createMatchType1];
            if (parser) {
                _match=parser;
                [[WeiboReplyData shareCacheForReply]  setObject:parser forKey:key];
                complete(parser,data);
            }
        });
        return nil;
    }
}

-(void)setMatch
{
    if (_match&&[_match isKindOfClass:[MatchParser class]]&&self.title!=nil&&[self.title isKindOfClass:[NSAttributedString class]]) {
        return;
    }else{
        NSString *key=[NSString stringWithFormat:@"%@+%f+type:%d",self.body,self.createTime,self.type];
        MatchParser *parser=[[WeiboReplyData shareCacheForReply] objectForKey:key];
        if (parser&&self.title!=nil&&[self.title isKindOfClass:[NSAttributedString class]]) {
            _match=parser;
            self.height=parser.height;
            parser.data=self;
        }else{
            MatchParser* parser=nil;
            parser=[self createMatchType1];
            if (parser) {
                [[WeiboReplyData shareCacheForReply]  setObject:parser forKey:key];
            }
        }
    }
}
-(void)setMatch:(MatchParser *)match
{
    _match=match;
}



-(MatchParser*)createMatchType1
{

  //  if([NSStrUtil notEmptyOrNull:self.mid]){
        
//        UIFont*font=[UIFont systemFontOfSize:13];
//        UIFont*font2=[UIFont systemFontOfSize:13];
//        CTFontRef fontRef=CTFontCreateWithName((__bridge CFStringRef)(font.fontName),font.pointSize,NULL);
//        CTFontRef sfontRef=CTFontCreateWithName((__bridge CFStringRef)(font2.fontName),font2.pointSize,NULL);
//        NSMutableAttributedString * strings=nil;
//        strings=[[NSMutableAttributedString alloc]init];
//        ContactData *contact = [[WeqiaAppDelegate App].dbUtil searchSingle:[ContactData class]where:[NSString stringWithFormat:@"mid='%@'",self.mid]orderBy:nil];
//        if([NSStrUtil notEmptyOrNull:contact.mName]){
//            NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,[UIColor colorWithIntegerValue:HEIGHT_TEXT_COLOR alpha:1].CGColor,kCTForegroundColorAttributeName,nil];
//            [strings appendAttributedString:[[NSAttributedString alloc] initWithString:contact.mName attributes:dic]];
//            if (contact) {
//                if([NSStrUtil notEmptyOrNull:self.up_mid]){
//                    ContactData *up_contact = [[WeqiaAppDelegate App].dbUtil searchSingle:[ContactData class]where:[NSString stringWithFormat:@"mid='%@'",self.up_mid] orderBy:nil];
//                    if([NSStrUtil notEmptyOrNull:up_contact.mName]){
//                        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)sfontRef,kCTFontAttributeName,[UIColor blackColor].CGColor,kCTForegroundColorAttributeName,nil];
//                        [strings appendAttributedString:[[NSAttributedString alloc] initWithString:@"回复" attributes:dic]];
//                        dic=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,[UIColor colorWithIntegerValue:HEIGHT_TEXT_COLOR alpha:1].CGColor,kCTForegroundColorAttributeName,nil];
//                        [strings appendAttributedString:[[NSAttributedString alloc] initWithString:up_contact.mName attributes:dic]];
//                    }
//                }
//            }
//        }
//        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,[UIColor blackColor].CGColor,kCTForegroundColorAttributeName,nil];
//        [strings appendAttributedString:[[NSAttributedString alloc] initWithString:@":" attributes:dic]];
//        CFRelease(fontRef);
//        CFRelease(sfontRef);
    
 //   }
    UIFont*font=g_factory.font14;
    CTFontRef fontRef=CTFontCreateWithName((__bridge CFStringRef)(font.fontName),font.pointSize,NULL);
    NSString*  s ;
    if (toNickName) {
        s = [NSString stringWithFormat:@"%@%@%@",userNickName,Localized(@"JX_Reply"),toNickName];
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:s];
        [attributedString addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x576b95) range:NSMakeRange(0, [userNickName length])];
        [attributedString addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x576b95) range:NSMakeRange([userNickName length] +2, [toNickName length])];
        [attributedString addAttribute:NSFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [s length])];
        self.title = attributedString;
    }else{
        s = [NSString stringWithFormat:@"%@",userNickName];//回复者的名字
        NSMutableAttributedString * strings=[[NSMutableAttributedString alloc]initWithString:s attributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef,kCTFontAttributeName,HEXCOLOR(0x576b95).CGColor,kCTForegroundColorAttributeName,nil]];
        self.title=strings;
    }
    
    
 
    
    
    CFRelease(fontRef);

#pragma mark -  点赞换行
    //点赞换行宽度－－－－－－－－－－－
    return [self createMatch:JX_SCREEN_WIDTH -117];
}


-(MatchParser*)createMatch:(float)width
{
    if(_match==nil||![_match isKindOfClass:[MatchParser class]]){
        MatchParser * parser=[[MatchParser alloc]init];
        parser.keyWorkColor= [UIColor blueColor];
        parser.font=g_factory.font14;
        parser.width=width;

        NSString* s;
        if(self.type == reply_data_praise)
            s = self.body;
        else
            s = [NSString stringWithFormat:@":%@",self.body];
        [parser match:s atCallBack:^BOOL(NSString * string) {
            return NO;
        }title:self.title];
        _match=parser;
        parser.data=self;
        self.height=parser.height+addHeight;
        return parser;
    }
    return nil;
}

-(void)updateMatch:(void(^)(NSMutableAttributedString * string, NSRange range))link
{
    if(_match){
        NSString* s = [NSString stringWithFormat:@":%@",self.body];
        [_match match:s atCallBack:^BOOL(NSString * string) {

            return NO;
        } title:self.title link:link];
    }
}

-(void)getDataFromDict:(NSDictionary*)dict{
    self.userId= [[dict objectForKey:@"userId"] stringValue];
    self.userNickName = [dict objectForKey:@"nickname"];
    self.createTime = [[dict objectForKey:@"time"] longLongValue];

    if(self.type == reply_data_praise){
//        self.body= [NSString stringWithFormat:@"给了一个赞"];
        self.replyId = [dict objectForKey:@"praiseId"];
    }
    
    if(self.type == reply_data_gift){
        self.replyId = [dict objectForKey:@"giftId"];
        self.giftCount = [[dict objectForKey:@"count"] stringValue];
        self.giftId = [[dict objectForKey:@"id"] stringValue];
        self.giftPrice = [dict objectForKey:@"price"];
        self.giftName = [dict objectForKey:@"giftId"];
        self.body= [NSString stringWithFormat:@"%@%@",Localized(@"JXLiveVC_Give"),giftName];
    }
    
    if(self.type == reply_data_comment){
//        self.body= [NSString stringWithFormat:@":%@",[dict objectForKey:@"body"]];
        self.body= [dict objectForKey:@"body"];
        self.replyId= [dict objectForKey:@"commentId"];
        self.toUserId = [[dict objectForKey:@"toUserId"] stringValue];
        self.toBody = [dict objectForKey:@"toBody"];
        self.toNickName = [dict objectForKey:@"toNickname"];
        
    }
    [self setMatch];
}

-(void)getHeight2{
    if(height2>0)
        return;
    height2 = 15;
    JXEmoji* p = [[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 220, 15)];
    p.font = g_factory.font11;
    p.offset = -12;
    p.text = self.body;
    height2 += p.frame.size.height;
    
    if([toNickName length]>0 && [toUserId length]>0 && [toBody length]>0){
        p.frame = CGRectMake(20, 0, 235,15);
        p.font = g_factory.font11;
        p.offset = -15;
        p.text    = self.toBody;
        height2 += p.frame.size.height;
        height2 += 20;
    }
    
    if(height2<60)
        height2 = 60;
}

@end
