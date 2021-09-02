//
//  roomData.m
//  shiku_im
//
//  Created by flyeagleTang on 15-2-6.
//  Copyright (c) 2015年 Reese. All rights reserved.
//

#import "roomData.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "SDWebImageManager.h"
#import <UIKit/UIKit.h>
#import "QQHeader.h"


@implementation roomData

@synthesize countryId;//国家
@synthesize provinceId;//省份
@synthesize cityId;//城市
@synthesize areaId;//区域

@synthesize name;//名字
@synthesize desc;//名字

@synthesize longitude;
@synthesize latitude;

@synthesize category;
@synthesize maxCount;
@synthesize curCount;
@synthesize createTime;
@synthesize updateTime;
@synthesize updateUserId;
@synthesize roomId;
@synthesize subject;
@synthesize userId;
@synthesize userNickName;
//@synthesize members;
@synthesize note;
@synthesize roomJid;

-(id)init{
    self = [super init];
    _members = [[NSMutableArray alloc]init];
    return self;
}

+(void)roomHeadImageRoomId:(NSString *)roomId  toView:(UIImageView *)toView{
    roomData * room = [[roomData alloc]init];
    room.roomId = roomId;
//    [room roomHeadImageToView:toView];
}
-(void)roomHeadImageToView:(UIImageView *)toView{
    
    //获取全部
    NSArray * allMem = [memberData fetchAllMembers:self.roomId];
    if (toView){
        toView.image = [UIImage imageNamed:@"groupImage"];//先设置一张默认群组图片
    }
    if(!allMem || allMem.count <= 1){
        return;//数据库没有值
    }
    
    NSMutableArray * userIdArr = [[NSMutableArray alloc] init];
    NSMutableArray * downLoadImageArr = [[NSMutableArray alloc] init];
    __block int finishCount = 0;
    NSString * roomIdStr = [self.roomJid mutableCopy];
    
    if (roomIdStr.length  <= 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //webcache
        SDWebImageManager * manager = [SDWebImageManager sharedManager];
        for (int i = 0; (i<allMem.count) && (i<10); i++) {
            memberData * member = allMem[i];
            //取userId
            long longUserId = member.userId;
            if (longUserId >= 10000000){
                [userIdArr addObject:[NSNumber numberWithLong:longUserId]];
            }
            if(userIdArr.count >= 5)
                break;
        }
        for (NSNumber * userIdNum in userIdArr) {
            NSString* dir  = [NSString stringWithFormat:@"%ld",[userIdNum longValue] % 10000];
            NSString* url  = [NSString stringWithFormat:@"%@avatar/t/%@/%@.jpg",g_config.downloadAvatarUrl,dir,userIdNum];
            
            [manager loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                finishCount++;
                if(image){
                    [downLoadImageArr addObject:image];
                }
                if(error){
                    
                }
                if (downLoadImageArr.count >= 5 || finishCount >= userIdArr.count){
                    if (downLoadImageArr.count <userIdArr.count){
                        UIImage * defaultImage = [UIImage imageNamed:@"userhead"];
                        for (int i=(int)downLoadImageArr.count; i<userIdArr.count; i++) {
                            [downLoadImageArr addObject:defaultImage];
                        }
                    }
                    //生成群头像
                    UIImage * drawimage = [self combineImage:downLoadImageArr];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary * groupDict = @{@"groupHeadImage":drawimage,@"roomJid":roomIdStr};
                        [g_notify postNotificationName:kGroupHeadImageModifyNotifaction object:groupDict];
                        if (toView) {
                            toView.image = drawimage;
                        }
                        
                        NSString *groupImagePath = [NSString stringWithFormat:@"%@%@/%@.%@",NSTemporaryDirectory(),g_myself.userId,roomIdStr,@"jpg"];
                        if (groupImagePath && [[NSFileManager defaultManager] fileExistsAtPath:groupImagePath]) {
                            NSError * error = nil;
                            [[NSFileManager defaultManager] removeItemAtPath:groupImagePath error:&error];
                            if (error)
                                NSLog(@"删除文件错误:%@",error);
                        }
                        [g_server saveImageToFile:drawimage file:groupImagePath isOriginal:NO];
                        //                        g_notify postNotificationName:<#(nonnull NSNotificationName)#> object:<#(nullable id)#>
                        return ;
                    });
                }
            }];
            
//            [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                
//            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                
//            }];
        }
        
    });

}

- (UIImage *)combineImage:(NSArray *)imageArray {
    UIView *view5 = [JJHeaders createHeaderView:140
                                         images:imageArray];
    view5.center = CGPointMake(235, 390);
    view5.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    
    
    CGSize s = view5.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, YES, 1.0);
    [view5.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
////    CGFloat width = 25;
////    CGFloat height = 25;
////    CGSize offScreenSize = CGSizeMake(width, height);
////
//
//    CGSize headSize = CGSizeMake(100, 100);
//    UIGraphicsBeginImageContext(headSize);
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//
//    
//    
////
////    CGRect rect = CGRectMake(0, 0, width/2, height);
////    [leftImage drawInRect:rect];
////    
////    rect.origin.x += width/2;
////    [rightImage drawInRect:rect];
////    
////    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
////    
////    UIGraphicsEndImageContext();
////    
////    return imagez;
//    //获得当前画板
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    UIColor *aColor = [UIColor colorWithRed:1 green:0.0 blue:0 alpha:1];
////    
////    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
////    
////    CGContextSetLineWidth(context, 3.0);//线的宽度
////    
////    CGContextAddArc(context, 250, 40, 40, 0, 2 * M_PI, 0); //添加一个圆
////    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
////    
////    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
//
//    UIImage * sssImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return [UIImage imageNamed:@""];
}


-(void)dealloc{
//    NSLog(@"roomData.dealloc");
    [_members removeAllObjects];
//    [members release];
//    
//    [super dealloc];
}

-(NSString *)roomDataToNSString{
    
    SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
    NSString * jsonString = [OderJsonwriter stringWithObject:[self toDictionary]];
//    [OderJsonwriter release];
    return jsonString;
}

-(NSDictionary*)toDictionary{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    [dict setValue:self.roomJid forKey:@"jid"];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.desc forKey:@"desc"];
    [dict setValue:self.roomId forKey:@"id"];
    [dict setValue:[NSNumber numberWithLong:self.userId] forKey:@"userId"];
    
    return dict;
}

-(void)getDataFromDict:(NSDictionary*)dict{
    self.countryId = [[dict objectForKey:@"countryId"] intValue];
    self.provinceId = [[dict objectForKey:@"provinceId"] intValue];
    self.cityId = [[dict objectForKey:@"cityId"] intValue];
    self.areaId = [[dict objectForKey:@"areaId"] intValue];
    self.maxCount = [[dict objectForKey:@"maxUserSize"] intValue];
    
    self.longitude = [[dict objectForKey:@"longitude"] longValue];
    self.latitude = [[dict objectForKey:@"latitude"] longValue];

    self.name = [dict objectForKey:@"name"];
    self.desc = [dict objectForKey:@"desc"];
    self.showRead = [[dict objectForKey:@"showRead"] boolValue];
    self.category = [[dict objectForKey:@"category"] intValue];
    self.maxCount = [[dict objectForKey:@"maxUserSize"] intValue];
    self.curCount = [[dict objectForKey:@"userSize"] intValue];

    self.createTime = [[dict objectForKey:@"createTime"] longLongValue];
    self.updateTime = [[dict objectForKey:@"updateTime"] longLongValue];
    
    self.isLook = [[dict objectForKey:@"isLook"] boolValue];
    self.isNeedVerify = [[dict objectForKey:@"isNeedVerify"] boolValue];
    self.showMember = [[dict objectForKey:@"showMember"] boolValue];
    self.allowSendCard = [[dict objectForKey:@"allowSendCard"] boolValue];
    self.allowInviteFriend = [[dict objectForKey:@"allowInviteFriend"] boolValue];
    self.allowUploadFile = [[dict objectForKey:@"allowUploadFile"] boolValue];
    self.allowConference = [[dict objectForKey:@"allowConference"] boolValue];
    self.allowSpeakCourse = [[dict objectForKey:@"allowSpeakCourse"] boolValue];
    self.offlineNoPushMsg = [[(NSDictionary *)[dict objectForKey:@"member"] objectForKey:@"offlineNoPushMsg"] boolValue];

    self.isNeedVerify = [[dict objectForKey:@"isNeedVerify"] boolValue];
    self.allowHostUpdate = [[dict objectForKey:@"allowHostUpdate"] boolValue];
    self.isAttritionNotice = [[dict objectForKey:@"isAttritionNotice"] boolValue];
    
    self.chatRecordTimeOut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"chatRecordTimeOut"]];
    self.talkTime = [[dict objectForKey:@"talkTime"] longLongValue];
    self.isSecretGroup = [[dict objectForKey:@"isSecretGroup"] boolValue];

    NSString * userIdStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"userId"]];
    NSRegularExpression*tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger letterMatchCount = [tLetterRegularExpression numberOfMatchesInString:userIdStr options:NSMatchingReportProgress range:NSMakeRange(0, userIdStr.length)];
    
    if(letterMatchCount == 0){
        self.userId = [[NSNumber numberWithLongLong:[userIdStr longLongValue]] longValue];
    }

    if (![dict objectForKey:@"id"]) {
        self.roomId = [dict objectForKey:@"roomId"];
    }else{
        self.roomId = [dict objectForKey:@"id"];
    }
    self.roomJid = [dict objectForKey:@"jid"];
    self.subject = [dict objectForKey:@"subject"];
    self.note = [(NSDictionary *)[dict objectForKey:@"notice"] objectForKey:@"text"];
    self.userNickName = [dict objectForKey:@"nickname"];
    self.lordRemarkName = [dict objectForKey:@"remarkName"];
//    self.call = [dict objectForKey:@"call"];
    
    if([self.note length]<=0)
        self.note = Localized(@"JX_NotAch");
    
    _tableName = self.roomId;
    
    [_members removeAllObjects];
    NSArray* array = [dict objectForKey:@"members"];
    NSMutableArray *arr = [NSMutableArray array];
    for(int i=0;i<[array count];i++){
        NSDictionary* p = [array objectAtIndex:i];
        memberData* option = [[memberData alloc] init];
        [option getDataFromDict:p];
        option.roomId = self.roomId;
//        [option insert];
        p = nil;

        [arr addObject:option];
    }
    
    [self insertArray:arr withTransaction:YES];
    
    self.members = arr;
    
    self.curCount = [_members count];
    array = nil;
}

-(BOOL)checkTableCreatedInDb:(NSString *)queryRoomId{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE IF NOT EXISTS 'member_%@' ('userId' INTEGER PRIMARY KEY NOT NULL  UNIQUE , 'roomId' VARCHAR, 'userName' VARCHAR, 'cardName' VARCHAR, 'role' INTEGER, 'createTime' VARCHAR, 'remarkName' VARCHAR)",queryRoomId];
    BOOL worked = [db executeUpdate:createStr];
    return worked;
}

- (void)insertArray:(NSArray *)dataArray withTransaction:(BOOL)useTransaction{
    if (!self.userId) {
        return;
    }
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    if (useTransaction) {
        [db beginTransaction];
        BOOL isRollBack = NO;
        @try {
            for (NSInteger i = 0; i < dataArray.count; i++) {
                memberData *memberData = dataArray[i];
                NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO member_%@ (roomId,userId,userName,cardName,role,createTime,remarkName) VALUES (?,?,?,?,?,?,?)",memberData.roomId];
                BOOL worked = [db executeUpdate:insertStr,memberData.roomId,[NSNumber numberWithLong:memberData.userId],memberData.userNickName,memberData.userNickName,memberData.role,[NSNumber numberWithLongLong:memberData.createTime],memberData.lordRemarkName];
                if (!worked) {
                    [self updateMember:memberData withDataBase:db];
                }
            }
        } @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
        } @finally {
            if (!isRollBack) {
                [db commit];
                [db close];
            }else{
                [db close];
                [self insertArray:dataArray withTransaction:NO];
            }
        }
        
    }else{
        for (NSInteger i = 0; i < dataArray.count; i++) {
            memberData *memberData = dataArray[i];
            NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO member_%@ (roomId,userId,userName,cardName,role,createTime,remarkName) VALUES (?,?,?,?,?,?,?)",memberData.roomId];
            BOOL worked = [db executeUpdate:insertStr,memberData.roomId,[NSNumber numberWithLong:memberData.userId],memberData.userNickName,memberData.userNickName,memberData.role,[NSNumber numberWithLongLong:memberData.createTime],memberData.lordRemarkName];
            if (!worked) {
                [self updateMember:memberData withDataBase:db];
            }
        }
        [db close];
    }
}

- (BOOL)updateMember:(memberData *)member withDataBase:(FMDatabase *)db{
    NSString* sql = [NSString stringWithFormat:@"update member_%@ set roomId=?,userId=?,userName=?,cardName=?,role=?,createTime=?,remarkName=? where userId=?",member.roomId];
    BOOL worked = [db executeUpdate:sql,member.roomId,[NSNumber numberWithLong:member.userId],member.userNickName,member.cardName,member.role,[NSNumber numberWithLongLong:member.createTime],member.lordRemarkName,[NSNumber numberWithLong:member.userId]];
    return worked;
}


-(void)setMembers:(NSMutableArray *)members{
    _tableName = self.roomId;
    
    [_members removeAllObjects];
//    NSArray* array = [dict objectForKey:@"members"];
    
    if ([[members firstObject] isMemberOfClass:[memberData class]]) {
        _members = members;
    }else{
        for(int i=0;i<[members count];i++){
            NSDictionary* p = [members objectAtIndex:i];
            memberData* option = [[memberData alloc] init];
            [option getDataFromDict:p];
            option.roomId = self.roomId;
            [option insert];
            p = nil;
            
            [_members addObject:option];
        }
    }
//    [self roomHeadImageToView:nil];

}
-(BOOL)isMember:(NSString*)theUserId{
    for(int i=0;i<[_members count];i++){
        memberData* p = [_members objectAtIndex:i];
        if([theUserId intValue] == p.userId)
            return YES;
    }
    return NO;
}

-(memberData*)getMember:(NSString*)theUserId{
    for(int i=0;i<[_members count];i++){
        memberData* p = [_members objectAtIndex:i];
        if([theUserId intValue] == p.userId)    
            return p;
    }
    return nil;
}

-(NSString*)getNickNameInRoom{
    for(int i=0;i<[_members count];i++){
        memberData* p = [_members objectAtIndex:i];
        if([g_myself.userId intValue] == p.userId)
            return p.userNickName;
    }
    return g_myself.userNickname;
}

-(NSInteger)getCurCount{
    return  [_members count];
}

-(void)setNickNameForUser:(JXUserObject*)user{
    for (int i=0; i<[_members count]; i++) {
        memberData* p = [_members objectAtIndex:i];
        if([user.userId intValue] == p.userId){
            user.userNickname = p.userNickName;
            break;
        }
    }
}

-(void)setRole:(int)role withUserId:(NSString *)userId; {
    for (int i=0; i<[_members count]; i++) {
        memberData* p = [_members objectAtIndex:i];
        if([userId intValue] == p.userId){
            p.role = [NSNumber numberWithInt:role];
            break;
        }
    }
}

@end


@implementation memberData
@synthesize active;
@synthesize talkTime;
@synthesize role;
@synthesize createTime;
@synthesize updateTime;
@synthesize sub;
@synthesize userId;
@synthesize userNickName;

-(id)init{
    self = [super init];
    return self;
}

-(void)dealloc{
//    NSLog(@"memberData.dealloc");
//    [super dealloc];
}

-(void)getDataFromDict:(NSDictionary*)dict{
    self.userId = [[dict objectForKey:@"userId"] longValue];
    self.userNickName = [dict objectForKey:@"nickname"];
    self.lordRemarkName = [dict objectForKey:@"remarkName"];
    self.sub = [[dict objectForKey:@"sub"] intValue];
    self.role = [NSNumber numberWithInt:[[dict objectForKey:@"role"] intValue]];

    self.talkTime = [[dict objectForKey:@"talkTime"] longLongValue];
    self.active = [[dict objectForKey:@"active"] longLongValue];    
    self.createTime = [[dict objectForKey:@"createTime"] longLongValue];
    self.updateTime = [[dict objectForKey:@"updateTime"] longLongValue];
    self.offlineNoPushMsg = [[dict objectForKey:@"offlineNoPushMsg"] intValue];
    
    
//    self.roomId;
//    self.userId;
//    self.userName;
//    self.cardName;
//    self.isAdmin;
    
}


#pragma mark -数据库
-(BOOL)checkTableCreatedInDb:(NSString *)queryRoomId{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE IF NOT EXISTS 'member_%@' ('userId' INTEGER PRIMARY KEY NOT NULL  UNIQUE , 'roomId' VARCHAR, 'userName' VARCHAR, 'cardName' VARCHAR, 'role' INTEGER, 'createTime' VARCHAR, 'remarkName' VARCHAR)",queryRoomId];
    BOOL worked = [db executeUpdate:createStr];
    return worked;
}

-(BOOL)insert{
    if (!self.userId) {
        return NO;
    }
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    
//    NSString* sql= [NSString stringWithFormat:@"select userId from member_%@ where userId=?",self.roomId];
//    FMResultSet *rs=[db executeQuery:sql,[NSNumber numberWithLong:self.userId]];
//    while ([rs next]) {
//        //不重复保存
//        return NO;
//    }
    
    if([self.role integerValue] == 0){
        self.role = [NSNumber numberWithInteger:3];
    }
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO member_%@ (roomId,userId,userName,cardName,role,createTime,remarkName) VALUES (?,?,?,?,?,?,?)",self.roomId];
    BOOL worked = [db executeUpdate:insertStr,self.roomId,[NSNumber numberWithLong:self.userId],self.userNickName,self.userNickName,self.role,[NSNumber numberWithLongLong:self.createTime],self.lordRemarkName];
    if (!worked) {
        [self update];
    }
    db = nil;
    return worked;
}

-(BOOL)update{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];

    NSString* sql = [NSString stringWithFormat:@"update member_%@ set roomId=?,userId=?,userName=?,cardName=?,role=?,createTime=?,remarkName=? where userId=?",self.roomId];
    BOOL worked = [db executeUpdate:sql,self.roomId,[NSNumber numberWithLong:self.userId],self.userNickName,self.cardName,self.role,[NSNumber numberWithLongLong:self.createTime],self.lordRemarkName,[NSNumber numberWithLong:self.userId]];
    return worked;
}
-(BOOL)remove{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from member_%@ where userId=?",self.roomId],[NSNumber numberWithLong:self.userId]];
    return worked;
}

//删除房间成员列表
-(BOOL)deleteRoomMemeber{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"delete from member_%@",self.roomId]];
    return worked;
}


+(NSArray <memberData *>*)fetchAllMembers:(NSString *)queryRoomId{
    NSString* sql = [NSString stringWithFormat:@"select * from member_%@",queryRoomId];
    return [[[memberData alloc] init] doFetch:sql roomId:queryRoomId];
}

+(NSArray <memberData *>*)fetchAllMembers:(NSString *)queryRoomId sortByName:(BOOL)sortByName{
    NSString* sql;
    if (sortByName){//群@,名字排序
        sql = [NSString stringWithFormat:@"select * from member_%@ where userId != '%@'  order by cardName",queryRoomId,MY_USER_ID];
    }else{//群成员,身份+加入时间
        sql = [NSString stringWithFormat:@"select * from member_%@ order by role,createTime",queryRoomId];
    }
    return [[[memberData alloc] init] doFetch:sql roomId:queryRoomId];
}

+(NSArray <memberData *>*)fetchAllMembersAndHideMonitor:(NSString *)queryRoomId sortByName:(BOOL)sortByName{
    NSString* sql;
    if (sortByName){//群@,名字排序
        sql = [NSString stringWithFormat:@"select * from member_%@ where (userId != '%@' and role != 4 and role!=5) order by cardName",queryRoomId,MY_USER_ID];
    }else{//群成员,身份+加入时间
        sql = [NSString stringWithFormat:@"select * from member_%@ where ((role != 4 and role!=5) or userId == '%@') order by role,createTime",queryRoomId,MY_USER_ID];
    }
    return [[[memberData alloc] init] doFetch:sql roomId:queryRoomId];
}

-(memberData *)searchMemberByName:(NSString *)cardName{
    NSString* sql = [NSString stringWithFormat:@"select * from member_%@ where cardName=%@",self.roomId,cardName];
    NSMutableArray* rmArray = [self doFetch:sql roomId:self.roomId];
    return (rmArray.count ? [rmArray firstObject] : nil);
}

-(memberData*)getCardNameById:(NSString*)aUserId {
    NSString* sql = [NSString stringWithFormat:@"select * from member_%@ where userId=%@",self.roomId,aUserId];
    NSMutableArray* rmArray = [self doFetch:sql roomId:self.roomId];
    return (rmArray.count ? [rmArray firstObject] : nil);
}

// 查找群主
+ (memberData *)searchGroupOwner:(NSString *)roomId {
    NSString* sql = [NSString stringWithFormat:@"select * from member_%@ where role=1",roomId];
    NSMutableArray* rmArray = [[[memberData alloc] init] doFetch:sql roomId:roomId];
    return (rmArray.count ? [rmArray firstObject] : nil);
}

// 更新身份
- (BOOL)updateRole {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    
    NSString* sql = [NSString stringWithFormat:@"update member_%@ set role=? where userId=?",self.roomId];
    BOOL worked = [db executeUpdate:sql,self.role,[NSNumber numberWithLong:self.userId]];
    return worked;
}

- (BOOL)updateCardName {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    
    NSString* sql = [NSString stringWithFormat:@"update member_%@ set cardName=? where userId=?",self.roomId];
    BOOL worked = [db executeUpdate:sql,self.cardName,[NSNumber numberWithLong:self.userId]];
    return worked;
}

// 更新群昵称
- (BOOL)updateUserNickName {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:self.roomId];
    
    NSString* sql = [NSString stringWithFormat:@"update member_%@ set userName=? where userId=?",self.roomId];
    BOOL worked = [db executeUpdate:sql,self.userNickName,[NSNumber numberWithLong:self.userId]];
    return worked;
}

+(NSMutableArray *)searchMemberByFilter:(NSString *)filter room:(NSString *)roomId{
    NSString * sql = [NSString stringWithFormat:@"select * from member_%@ where (userName like '%%%@%%' or cardName like '%%%@%%')",roomId,filter,filter];
    NSMutableArray* rmArray = [[[memberData alloc] init] doFetch:sql roomId:roomId];
    return rmArray;
}


-(NSMutableArray*)doFetch:(NSString*)sql roomId:(NSString *)queryRoomId
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:queryRoomId];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        memberData * mem = [[memberData alloc] init];
        mem.userId = [[rs objectForColumnName:@"userId"] longValue];
        mem.roomId = [rs stringForColumn:@"roomId"];
        mem.userNickName = [rs stringForColumn:@"userName"];
        mem.lordRemarkName = [rs stringForColumn:@"remarkName"];
        mem.cardName = [rs stringForColumn:@"cardName"];
        mem.role = [rs objectForColumnName:@"role"];
        mem.createTime = [[rs objectForColumnName:@"createTime"] longLongValue];
        [resultArr addObject:mem];
    }
    [rs close];
    if([resultArr count]==0){
        resultArr = nil;
    }
    return resultArr;
}

+ (memberData *)fetchMembersWithText:(NSString *)text withRoomId:(NSString *)roomId{
    NSString *sql = [NSString stringWithFormat:@"select * from member_%@ where userName like '%%%@%%'",roomId,text];
    return [memberData doFetchOneMember:sql roomId:roomId];
}
+ (memberData *)doFetchOneMember:(NSString*)sql roomId:(NSString *)roomId
{
    memberData *member = [[memberData alloc] init];
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [member checkTableCreatedInDb:roomId];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        member.userId = [[rs objectForColumnName:@"userId"] longValue];
        member.roomId = [rs stringForColumn:@"roomId"];
        member.userNickName = [rs stringForColumn:@"userName"];
        member.lordRemarkName = [rs stringForColumn:@"remarkName"];
        member.cardName = [rs stringForColumn:@"cardName"];
        member.role = [rs objectForColumnName:@"role"];
        member.createTime = [[rs objectForColumnName:@"createTime"] longLongValue];
        break;
    }
    [rs close];
    if (!member.userNickName) {
        return nil;
    }
    return member;
}
@end
