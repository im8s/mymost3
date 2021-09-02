//
//  WeiboReplyData.h
//  wq8
//
//  Created by weqia on 13-9-5.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "Jastor.h"
#import "MatchParser.h"

#define reply_data_comment 1
#define reply_data_praise 2
#define reply_data_gift 3

@interface WeiboReplyData : Jastor<MatchParserDelegate>
{
    __weak MatchParser * _match;
}
//@property(nonatomic,copy) NSString * files;
@property(nonatomic,strong) NSString * replyId;
@property(nonatomic,strong) NSString * messageId;
@property(nonatomic,strong) NSString * body;
@property(nonatomic,strong) NSString * userId;
@property(nonatomic,strong) NSString * userNickName;
@property(nonatomic,strong) NSString * toUserId;
@property(nonatomic,strong) NSString * toNickName;
@property(nonatomic,strong) NSString * toBody;
@property(nonatomic,strong) NSString * giftId;
@property(nonatomic,strong) NSString * giftName;
@property(nonatomic,strong) NSString * giftCount;
@property(nonatomic,strong) NSString * giftPrice;
@property(assign) NSTimeInterval createTime;

@property(nonatomic) int height2;
@property(nonatomic) int height;
@property(nonatomic) int addHeight;
@property(nonatomic,strong) NSAttributedString * title;
@property(nonatomic,weak,getter = getMatch,setter = setMatch:) MatchParser * match;
@property(nonatomic) int type;

-(MatchParser*)createMatchType1;
-(void)setMatch;
-(void)updateMatch:(void(^)(NSMutableAttributedString * string, NSRange range))link;
-(void)getHeight2;

+(NSCache*)shareCacheForReply;
-(void)getDataFromDict:(NSDictionary*)dict;

@end



