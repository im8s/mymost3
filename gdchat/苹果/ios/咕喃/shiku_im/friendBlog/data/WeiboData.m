//
//  WeiboData.m
//  wq
//
//  Created by weqia on 13-8-28.
//  Copyright (c) 2013年 Weqia. All rights reserved.
//

#import "WeiboData.h"
#import "JSONKit.h"
@implementation WeiboData

@synthesize tag,height,linesLimit,uploadFailed,heightOflimit,shouldExtend,miniWidth,numberOfLineLimit,numberOfLinesTotal,willDisplay,imageHeight,replyHeight,fileHeight;
@synthesize tMans;
@synthesize minHeightForComment;

@synthesize messageId;
@synthesize userId;
@synthesize userNickName;
@synthesize content;
@synthesize createTime;
@synthesize deviceModel;
@synthesize location;
@synthesize type;
@synthesize flag;
@synthesize title;
@synthesize visible;
@synthesize loveCount;
@synthesize playCount;
@synthesize forwardCount;
@synthesize shareCount;
@synthesize praiseCount;
@synthesize commentCount;
@synthesize giftCount;
@synthesize giftTotalPrice;
@synthesize replys;
@synthesize gifts;
@synthesize praises;
@synthesize larges;
@synthesize smalls;
@synthesize images;
@synthesize audios;
@synthesize videos;
@synthesize files;
@synthesize time;
@synthesize remark;
@synthesize address;
@synthesize isPraise;
@synthesize isCollect;
@synthesize heightPraise;
@synthesize isVideo;


#pragma -mark 接口方法

-(id)init{
    self = [super init];
    praises = [[NSMutableArray alloc]init];
    replys  = [[NSMutableArray alloc]init];
    smalls  = [[NSMutableArray alloc]init];
    larges  = [[NSMutableArray alloc]init];
    videos  = [[NSMutableArray alloc]init];
    audios  = [[NSMutableArray alloc]init];
    files   = [[NSMutableArray alloc]init];
    minHeightForComment = 0;
    height = 0;
    heightOflimit = 0;
    imageHeight = 0;
    replyHeight = 0;
    fileHeight = 0;
    heightPraise = 0;
    return self;
}

-(void)dealloc{
    self.images = nil;
//    [super dealloc];
}

+(NSString *)getPrimaryKey
{
    return @"weiboId";
}

+(NSString *)getTableName
{
    return @"WeiboData";
}

+(int)newTag
{
    static int tag=1000;
    return tag++;
}

+(NSCache*)shareCacheForWeibo;
{
    static NSCache * cache=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache=[[NSCache alloc]init];
        cache.totalCostLimit=0.1*1024*1024;
    });
    return cache;
}

-(MatchParser*)getMatch
{
    if (_match&&[_match isKindOfClass:[MatchParser class]]) {
        _match.data=self;
        return _match;
    }else{
        NSString *key=[NSString stringWithFormat:@"%@:local=%d:content=%@",self.messageId,self.local,self.content];
        MatchParser *parser=[[WeiboData shareCacheForWeibo] objectForKey:key];
        if (parser) {
            _match=parser;
            self.height=parser.height;
            self.heightOflimit=parser.heightOflimit;
            self.miniWidth=parser.miniWidth;
            self.numberOfLinesTotal=parser.numberOfTotalLines;
            self.numberOfLineLimit=parser.numberOfLimitLines;
            parser.data=self;
            if (_match.numberOfTotalLines>_match.numberOfLimitLines) {
                self.shouldExtend=YES;
            }else{
                self.shouldExtend=NO;
            }
            return parser;
        }else{
            //说说文本换行长度限制，但这方法未被调用
            parser=[self createMatch:JX_SCREEN_WIDTH -67-15];
            if (parser) {
                [[WeiboData shareCacheForWeibo]  setObject:parser forKey:key];
            }
            return parser;
        }
    }
}
-(MatchParser*)getMatch:(void(^)(MatchParser *parser,id data))complete data:(id)data
{
    if (_match&&[_match isKindOfClass:[MatchParser class]]) {
        _match.data=self;
        return _match;
    }else{
        NSString *key=[NSString stringWithFormat:@"%@:local=%d:content=%@",self.messageId,self.local,self.content];
        MatchParser *parser=[[WeiboData shareCacheForWeibo] objectForKey:key];
        if (parser) {
            _match=parser;
            self.height=parser.height;
            self.heightOflimit=parser.heightOflimit;
            self.miniWidth=parser.miniWidth;
            self.numberOfLinesTotal=parser.numberOfTotalLines;
            self.numberOfLineLimit=parser.numberOfLimitLines;
            parser.data=self;
            if (_match.numberOfTotalLines>_match.numberOfLimitLines) {
                self.shouldExtend=YES;
            }else{
                self.shouldExtend=NO;
            }
            return parser;
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //说说文本换行长度限制
                MatchParser*parser=[self createMatch:JX_SCREEN_WIDTH - 67-15];
                if (parser) {
                    _match=parser;
                    [[WeiboData shareCacheForWeibo]  setObject:parser forKey:key];
                    if (complete) {
                        complete(parser,data);
                    }
                }
            });
            return nil;
        }
    }
}

-(void)setMatch
{
    if (_match&&[_match isKindOfClass:[MatchParser class]]) {
        _match.data=self;
        return;
    }else{
        NSString *key=[NSString stringWithFormat:@"%@:local=%d:content=%@",self.messageId,self.local,self.content];
        MatchParser *parser=[[WeiboData shareCacheForWeibo] objectForKey:key];
        if (parser) {
            _match=parser;
            self.height=parser.height;
            self.heightOflimit=parser.heightOflimit;
            self.miniWidth=parser.miniWidth;
            self.numberOfLinesTotal=parser.numberOfTotalLines;
            self.numberOfLineLimit=parser.numberOfLimitLines;
            parser.data=self;
            if (_match.numberOfTotalLines>_match.numberOfLimitLines) {
                self.shouldExtend=YES;
            }else{
                self.shouldExtend=NO;
            }
            parser.data=self;
        }else{
            //说说文本换行长度限制
            MatchParser* parser=[self createMatch:JX_SCREEN_WIDTH -67-15];
            if (parser) {
                [[WeiboData shareCacheForWeibo]  setObject:parser forKey:key];
            }
        }
    }
}
-(void)setMatch:(MatchParser *)match
{
    _match=match;
}


-(MatchParser*)createMatch:(float)width
{
    MatchParser * parser=[[MatchParser alloc]init];
    parser.keyWorkColor=[UIColor blueColor];
    parser.width=width;
    parser.numberOfLimitLines=5;
    self.numberOfLineLimit=5;
    [parser match:self.content atCallBack:^BOOL(NSString * string) {
        NSString *partInStr;
        if (![tMans isKindOfClass:[NSString class]]) {
            partInStr = [tMans JSONString];
        } else {
            partInStr = (NSString*)tMans;
        }
        return NO;
    }];
    _match=parser;
    self.height=_match.height;
    self.heightOflimit=parser.heightOflimit;
    self.miniWidth=parser.miniWidth;
    self.numberOfLinesTotal=parser.numberOfTotalLines;
    parser.data=self;
    if (_match.numberOfTotalLines>_match.numberOfLimitLines) {
        self.shouldExtend=YES;
    }else{
        self.shouldExtend=NO;
    }
    return parser;
}
-(void)updateMatch:(void(^)(NSMutableAttributedString * string, NSRange range))link
{
    [_match match:self.content atCallBack:^BOOL(NSString * string) {
        NSString *partInStr;
        if (![tMans isKindOfClass:[NSString class]]) {
            partInStr = [tMans JSONString];
        } else {
            partInStr = (NSString*)tMans;
        }
        return NO;
    } title:nil link:link];
}


-(void)getWeiboReplysByType:(int)type1
{
    static int replyId=0;
    NSMutableArray * datas=[[NSMutableArray alloc]init];
    WeiboReplyData * data=[[WeiboReplyData alloc]init];
    data.type=1;
    data.body=[NSString stringWithFormat:@"我说好! %d %d %d",replyId,replyId,replyId];
    data.messageId=self.messageId;
    [data setMatch];
    [datas addObject:data];
    
    data=[[WeiboReplyData alloc]init];
    data.type=1;
    data.body=[NSString stringWithFormat:@"[开心][酷] %d %d %d",replyId,replyId,replyId];
    data.messageId=self.messageId;
    [data setMatch];
    [datas addObject:data];
    
    self.replys=datas;
    
//    NSTimeInterval n = [[NSDate date] timeIntervalSinceReferenceDate];
}
-(void)deleteByReplyId:(NSString*)replyId
{
}

-(void)updateRepleys
{
    
}

-(NSString*)formatdate:(NSDate*)d format:(NSString*)str{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    f.dateFormat = str;
    NSString* s = [f stringFromDate:d];
//    [f release];
    return  s;
}

-(void)getDataFromDict:(NSDictionary*)dict{
    [images removeAllObjects];
    [larges removeAllObjects];
    [praises removeAllObjects];
    [replys removeAllObjects];
    [gifts removeAllObjects];
    [smalls removeAllObjects];
    
//    {"userId":100407,"flag":3,"visible":3,"body":{"text":"10099æ°åå¡åæ¹é å®æ¯ï¼è§é¢æ¯æµè¯ææï¼ï¼ï¼10099","type":1,"videos":["http://192.168.1.240:8081/video/VID_20140519_190116.mp4"]},"count":{"play":0,"forward":0,"share":0,"collect":0,"praise":0,"comment":0,"money":0,"total":0},"time":1404444296250,"msgId":"53b61e88e4b0724d97d84804","comments":[],"praises":[],"gifts":[]}
    
    self.messageId = [dict objectForKey:@"msgId"];
    self.userId = [[dict objectForKey:@"userId"] stringValue];
    self.userNickName = [dict objectForKey:@"nickname"];
    self.createTime = [[dict objectForKey:@"time"] longLongValue];
    self.deviceModel = [dict objectForKey:@"model"];
    self.location = [dict objectForKey:@"location"];
    self.longitude = [dict objectForKey:@"longitude"];
    self.latitude = [dict objectForKey:@"latitude"];
    self.flag = [[dict objectForKey:@"flag"] intValue];
    self.visible = [[dict objectForKey:@"visible"] intValue];
    self.isPraise = [[dict objectForKey:@"isPraise"] boolValue];
    self.isCollect = [[dict objectForKey:@"isCollect"] boolValue];
    self.isAllowComment = [[dict objectForKey:@"isAllowComment"] intValue];
    
    self.loveCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"collect"] intValue];
    self.shareCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"share"] intValue];
    self.playCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"play"] intValue];
    self.forwardCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"forward"] intValue];
    self.praiseCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"praise"] intValue];
    self.commentCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"comment"] intValue];
    self.giftCount = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"money"] intValue];
    self.giftTotalPrice = [[(NSDictionary *)[dict objectForKey:@"count"] objectForKey:@"total"] intValue];

    self.title = [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"title"];
    self.type = [[(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"type"] intValue];
    self.content= [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"text"];
//    self.audios   = [[dict objectForKey:@"body"] objectForKey:@"audios"];
//    self.videos   = [[dict objectForKey:@"body"] objectForKey:@"videos"];
    self.time = [(NSDictionary *)[dict objectForKey:@"body"]  objectForKey:@"time"];
    self.address = [(NSDictionary *)[dict objectForKey:@"body"]  objectForKey:@"address"];
    self.remark = [(NSDictionary *)[dict objectForKey:@"body"]  objectForKey:@"remark"];
    
    if (self.type == weibo_dataType_share) {
        self.sdkUrl = [(NSDictionary *)[dict objectForKey:@"body"]  objectForKey:@"sdkUrl"];
        self.sdkIcon = [(NSDictionary *)[dict objectForKey:@"body"]  objectForKey:@"sdkIcon"];
        self.sdkTitle = [(NSDictionary *)[dict objectForKey:@"body"]  objectForKey:@"sdkTitle"];
    }

    NSDictionary* row = nil;
    
    NSArray* p = [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"images"];
    self.images = [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"images"];
    
    for(int i=0;i<[p count];i++){
        row = [p objectAtIndex:i];
        
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= [row objectForKey:@"tUrl"];
        url.mime=@"image/pic";
        [smalls addObject:url];
        
        url =[[ObjUrlData alloc]init];
        url.url= [row objectForKey:@"oUrl"];
        url.mime=@"image/pic";
        [larges addObject:url];
    }

    p = [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"audios"];
    for(int i=0;i<[p count];i++){
        row = [p objectAtIndex:i];
        
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= [row objectForKey:@"oUrl"];
        url.fileSize = [row objectForKey:@"size"];
        url.timeLen = [row objectForKey:@"length"];
        [audios addObject:url];
    }

    p = [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"videos"];
    for(int i=0;i<[p count];i++){
        row = [p objectAtIndex:i];
        
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= [row objectForKey:@"oUrl"];
        url.fileSize = [row objectForKey:@"size"];
        url.timeLen = [row objectForKey:@"length"];
        [videos addObject:url];
    }
    
    p = [(NSDictionary *)[dict objectForKey:@"body"] objectForKey:@"files"];
    for(int i=0;i<[p count];i++){
        row = [p objectAtIndex:i];
        
        ObjUrlData * url=[[ObjUrlData alloc] init];
        url.url= [row objectForKey:@"oUrl"];
        url.fileSize = [row objectForKey:@"size"];
        url.timeLen = [row objectForKey:@"length"];
        if ([row objectForKey:@"oFileName"]) {
            url.name = [row objectForKey:@"oFileName"];
        }else {
            url.name = [url.url lastPathComponent];
        }
        [files addObject:url];
    }
    
    if( ([self.audios count]>0 || [self.videos count]>0) && [self.images count]<=0){//假如没图，则用头像代替
        ObjUrlData * url=[[ObjUrlData alloc]init];
//        url.url= @"http://www.feizl.com/upload2007/2013_02/130227014423722.jpg";
        url.url= [g_server getHeadImageOUrl:userId];
        url.mime=@"image/pic";
        [smalls addObject:url];
    }

    p = [dict objectForKey:@"praises"];
    for(int i=0;i<[p count];i++){
        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
        reply.type=reply_data_praise;
//        reply.addHeight = self.minHeightForComment;
        reply.messageId=self.messageId;
        row = [p objectAtIndex:i];
        [reply getDataFromDict:row];
        [praises addObject:reply];
    }

    
    p = [dict objectForKey:@"gifts"];
    for(int i=0;i<[p count];i++){
        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
        reply.type=reply_data_gift;
//        reply.addHeight = self.minHeightForComment;
        reply.messageId=self.messageId;
        row = [p objectAtIndex:i];
        [reply getDataFromDict:row];
        [gifts addObject:reply];
    }
    
    p = [dict objectForKey:@"comments"];
    for(NSInteger i = 0; i < p.count; i++){
        WeiboReplyData * reply=[[WeiboReplyData alloc]init];
        reply.type=reply_data_comment;
        reply.addHeight = self.minHeightForComment;
        reply.messageId=self.messageId;
        row = [p objectAtIndex:i];
        [reply getDataFromDict:row];
        [replys addObject:reply];
    }

    p = nil;
    row = nil;
}

-(NSString*)getLastReplyId:(int)page{
    NSString* lastId = @"";
    if(page > 0){
        NSInteger n = [replys count]-1;
        if(n>=0){
            WeiboReplyData* p = [replys objectAtIndex:n];
            lastId = p.replyId;
            p = nil;
        }
    }
    return lastId;
}

-(NSString*)getAllPraiseUsers{
    if([praises count]<=0)
        return nil;
    NSString* s=@"";
    NSInteger m = [praises count];
    NSInteger n = m;
    if(n>20)
        n = 20;
    WeiboReplyData* p = [praises objectAtIndex:0];
    s = p.userNickName;
    
    for(int i=1;i<n;i++){
        p = [praises objectAtIndex:i];
        s = [s stringByAppendingString:@","];
        s = [s stringByAppendingString:p.userNickName];
    }
    if(m>=20)
        s = [s stringByAppendingString:[NSString stringWithFormat:@" %d%@",self.praiseCount,Localized(@"WeiboData_PerZan1")]];
    else
        s = [s stringByAppendingString:[NSString stringWithFormat:@" %d%@",self.praiseCount,Localized(@"WeiboData_PerZan1")]];
    return s;
}

-(int)heightPraise{
    if([praises count]<=0){
        heightPraise = 0;
        return heightPraise;
    }
    WeiboReplyData* p = [[WeiboReplyData alloc]init];
    p.type = reply_data_praise;
    p.body = [self getAllPraiseUsers];
    [p getMatch];
    heightPraise = p.height+6;
    return heightPraise;
}

-(int) heightForReply
{
    if([replys count]==0)
        return self.heightPraise;
    int m=6;
    int n = self.heightPraise;
    if(n>0)//评论和赞只加一个6
        m = 0;
    for(WeiboReplyData * data in replys){
        m+=data.height+4;
    }
    return m+n;
}

-(int) height2ForReply
{
    if([replys count]==0)
        return 0;
    int n=0;
    for(WeiboReplyData * data in replys){
        [data getHeight2];
        n+=data.height2;
    }
    return n;
}

-(NSString*)getMediaURL{
    ObjUrlData* p=nil;
    if(self.isVideo){
        if([videos count]>0)
            p = [videos objectAtIndex:0];
    }
    else{
        if([audios count]>0)
            p = [audios objectAtIndex:0];
    }
    return p.url;
}

-(BOOL)isVideo{
    return [videos count]>0;
    return type == weibo_dataType_video;
}


#pragma -mark 私有方法


@end
