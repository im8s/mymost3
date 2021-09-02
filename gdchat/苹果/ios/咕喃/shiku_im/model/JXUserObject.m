//
//  JXUserObject.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXUserObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "JXFriendObject.h"
#import "JXMessageObject.h"
#import "roomData.h"
#import "resumeData.h"
#import "DESUtil.h"
#import "JXRoomRemind.h"
#import "JXUserPublicKeyObj.h"
#import "MD5Util.h"

@implementation JXUserObject

@synthesize
telephone,
password,
birthday,
companyName,
model,
osVersion,
serialNumber,
location,
//description,
sex,
countryId,
provinceId,
cityId,
areaId,
latitude,
longitude,
level,
vip,
fansCount,
attCount;


static JXUserObject *sharedUser;

+(JXUserObject*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser=[[JXUserObject alloc]init];
    });
    return sharedUser;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"friend";
        
        _favorites = [NSMutableArray array];
        _phoneDic = [NSMutableDictionary dictionary];
        _msgBackGroundUrl = [NSString string];
    }
    return self;
}

-(void)dealloc{
    self.telephone = nil;
    self.password = nil;
    self.userType = nil;
    self.birthday = nil;
    self.companyName = nil;
    self.model = nil;
    self.osVersion = nil;
    self.serialNumber = nil;
    self.location = nil;
    self.sex = nil;
    self.role = nil;
    self.countryId = nil;
    self.provinceId = nil;
    self.cityId = nil;
    self.areaId = nil;
    self.latitude = nil;
    self.longitude = nil;
    self.level = nil;
    self.vip = nil;
    self.fansCount = nil;
    self.attCount = nil;
    self.myInviteCode = nil;
//    NSLog(@"JXUserObject.dealloc");
//    [super dealloc];
}

-(BOOL)insert{
    self.roomFlag   = [NSNumber numberWithInt:0];
    self.companyId  = [NSNumber numberWithInt:0];
    if ([self.offlineNoPushMsg intValue] <= 0) {
        self.offlineNoPushMsg = [NSNumber numberWithInt:0];
    }
    self.isAtMe = [NSNumber numberWithInt:0];
    self.talkTime = [NSNumber numberWithLong:0];
    return [super insert];
}

-(BOOL)insertRoom
{
    self.roomFlag= [NSNumber numberWithInt:1];
    self.companyId= [NSNumber numberWithInt:0];
    self.status= [NSNumber numberWithInt:2];
    if ([self.offlineNoPushMsg intValue] <= 0) {
        self.offlineNoPushMsg = [NSNumber numberWithInt:0];
    }
    self.isAtMe = [NSNumber numberWithInt:0];
    return [super insert];
}

-(JXUserObject*)userFromDictionary:(NSDictionary*)aDic
{
    JXUserObject* user = [[JXUserObject alloc]init];
    [super userFromDictionary:user dict:aDic];
    return user;
}
//好友关系
-(NSMutableArray*)fetchAllFriendsFromLocal
{
    NSString* sql = @"select * from friend where (status=2 or status=10) and companyId=0 and roomFlag!=1 and isDevice!=1 and userType != 2 order by status desc, timeCreate desc";

    return [self doFetch:sql];
}

// 获取系统公众号
-(NSMutableArray*)fetchSystemUser {
    NSString* sql = @"select * from friend where (userType=2 and (status=8 or status=2) and companyId=0 and roomFlag=0 and isDevice=0) or userId=1100 order by timeCreate asc";
    return [self doFetch:sql];
}

//搜索好友
-(NSMutableArray*)fetchFriendsFromLocalWhereLike:(NSString *)searchStr
{
    NSString* sql = [NSString stringWithFormat:@"select * from friend where (status=8 or status=2) and companyId=0 and roomFlag=0  and userNickname like '%%%@%%' order by status desc, timeCreate desc",searchStr];
    return [self doFetch:sql];
}

//获取数据库好友列表所有的好友、公众号、群组
-(NSMutableArray*)fetchAllFriends
{
    NSString* sql = @"select * from friend where (status=-1 or status=1 or status=2 or status=8) and companyId=0 order by status desc, timeCreate desc";
    return [self doFetch:sql];
}


//所有联系人,0没任何关系，－1黑名单，2好友关系，8系统账号，1单向关注
-(NSMutableArray*)fetchAllFriendsOrNotFromLocal
{
    NSString* sql = @"select * from friend where (status=-1 or status=1 or status=2) and companyId=0 and roomFlag=0 order by status desc, timeCreate desc";
    return [self doFetch:sql];
}

-(NSMutableArray*)fetchAllRoomsFromLocal
{
    
    NSString *isSecretGroup = @"";
#ifdef IS_MsgEncrypt
    if ([g_config.isOpenSecureChat boolValue]) {
        isSecretGroup = @"";
    }else {
        isSecretGroup = @"and isSecretGroup != 1";
    }
#else
    isSecretGroup = @"and isSecretGroup != 1";
#endif
    NSString* sql = [NSString stringWithFormat:@"select * from friend where roomFlag=1 and companyId =0 and groupStatus = 0 %@ order by status desc, timeCreate desc",isSecretGroup];
    return [self doFetch:sql];
}

// 获取指定类型群组
-(NSMutableArray*)fetchRoomsFromLocalWithCategory:(NSNumber *)category
{
    NSString* sql = [NSString stringWithFormat:@"select * from friend where roomFlag=1 and category=%@ and companyId =0 order by status desc, timeCreate desc",category];
    ;
    return [self doFetch:sql];
}

-(NSMutableArray*)fetchAllCompanyFromLocal
{
    NSString* sql = [NSString stringWithFormat:@"select * from friend where companyId>0 and roomFlag=0 and userId!='%@' order by status desc, timeCreate desc",MY_USER_ID];
    return [self doFetch:sql];
}
//主动打招呼后status＝1
-(NSMutableArray*)fetchAllPayFromLocal
{
    NSString* sql = [NSString stringWithFormat:@"select * from friend where status=1 and companyId=0 and roomFlag=0 and userId!='%@' order by status desc, timeCreate desc",MY_USER_ID];
    return [self doFetch:sql];
}

-(NSMutableArray*)fetchAllUserFromLocal
{
    NSString* sql = [NSString stringWithFormat:@"select * from friend where status=2 and userType != 2 and companyId=0 and roomFlag=0 and userId!='%@' order by status desc, timeCreate desc",MY_USER_ID];
    return [self doFetch:sql];
}

-(NSMutableArray*)fetchAllBlackFromLocal
{
    NSString* sql = @"select * from friend where status=-1 and roomFlag=0 order by status desc, timeCreate desc";
    return [self doFetch:sql];
}

-(NSMutableArray*)fetchBlackFromLocalWhereLike:(NSString *)searchStr
{
    NSString* sql = [NSString stringWithFormat:@"select * from friend where status<0 and (userNickname like '%%%@%%' or remarkName like '%%%@%%') order by status desc, timeCreate desc",searchStr,searchStr];
    return [self doFetch:sql];
}

//插入本地不存在的好友
- (void)insertFriend{
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:g_server.myself.userId];
    FMResultSet * rs =  [db executeQuery:[NSString stringWithFormat:@"select * from friend where userId=?"],self.userId];
    if (![rs next]) {
        
        NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO friend ('userId','userNickname','remarkName','role','createUserId','userDescription','userHead','roomFlag','category','timeCreate','newMsgs','status','userType','companyId','type','content','isMySend','roomId','timeSend','downloadTime','lastInput','showRead','showMember','allowSendCard','allowInviteFriend','allowUploadFile','allowConference','allowSpeakCourse','isNeedVerify','topTime','encryptType','groupStatus','isOnLine','isOpenReadDel','isSendRecipt','isDevice','chatRecordTimeOut','offlineNoPushMsg','isAtMe','talkTime','publicKeyDH','publicKeyRSARoom','chatKeyGroup','isSecretGroup','isLostChatKeyGroup') VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        BOOL worked = [db executeUpdate:insertStr,self.userId,self.userNickname,self.remarkName,self.role,self.createUserId,self.userDescription,nil,self.roomFlag,self.category,self.timeCreate,self.msgsNew,self.status,self.userType,self.companyId,self.type,self.content,self.isMySend,self.roomId,self.timeSend,self.downloadTime,self.lastInput,self.showRead,self.showMember,self.allowSendCard,self.allowInviteFriend,self.allowUploadFile,self.allowConference,self.allowSpeakCourse,self.isNeedVerify,self.topTime,self.encryptType,self.groupStatus,self.isOnLine,self.isOpenReadDel, self.isSendRecipt,self.isDevice,self.chatRecordTimeOut,self.offlineNoPushMsg,self.isAtMe,self.talkTime,self.publicKeyDH,self.publicKeyRSARoom,self.chatKeyGroup,self.isSecretGroup,self.isLostChatKeyGroup];
        NSLog(@"%d",worked);
    }else{
        //因为以前的漏洞，取消黑名单后status出现与服务端不一致
//        NSString * status=[rs objectForColumnName:kUSER_STATUS];
//        if ([status intValue] != [self.status intValue]) {
            NSString *insertStr=[NSString stringWithFormat:@"update friend set userNickname =?,status=?,userType=?,publicKeyDH=?,publicKeyRSARoom=? where userId=?"];
            BOOL worked = [db executeUpdate:insertStr,self.userNickname,self.status,self.userType,self.publicKeyDH,self.publicKeyRSARoom,self.userId];
            NSLog(@"%d",worked);
//        }
    }
    [g_App copyDbWithUserId:MY_USER_ID];
}

-(void)createSystemFriend{
    JXUserObject* user = [[JXUserObject alloc] init];
    user.userId = CALL_CENTER_USERID;
    user.userNickname = Localized(@"JXUserObject_SysMessage");
    
    // status 暂不用8， 改为2. 消息界面需要用到好友关系
    user.status = [NSNumber numberWithInt:2];
    user.userType = [NSNumber numberWithInt:2];
    user.roomFlag = [NSNumber numberWithInt:0];
//    user.role = [NSNumber numberWithInt:2];
    user.content = Localized(@"JXUserObject_Wealcome");
    user.timeSend = [NSDate date];
    user.chatRecordTimeOut = g_myself.chatRecordTimeOut;
    if(!user.haveTheUser)
        [user insert];
    else {
        [user updateUserNickname];
    }
    
    user.userId = FRIEND_CENTER_USERID;
    user.userNickname = Localized(@"JXNewFriendVC_NewFirend");
    user.status = [NSNumber numberWithInt:8];
    user.userType = [NSNumber numberWithInt:0];
    user.roomFlag = [NSNumber numberWithInt:0];
//    user.content = Localized(@"JXUserObject_Friend");
    user.content = nil;
    user.timeSend = [NSDate date];
    user.chatRecordTimeOut = g_myself.chatRecordTimeOut;
    if(!user.haveTheUser)
        [user insert];
    else {
        [user updateUserNickname];
    }
    
    user.userId = BLOG_CENTER_USERID;
    user.userNickname = Localized(@"JXUserObject_BusinessMessage");
    user.status = [NSNumber numberWithInt:9];
    user.userType = [NSNumber numberWithInt:0];
    user.roomFlag = [NSNumber numberWithInt:0];
    user.content = nil;
    user.timeSend = [NSDate date];
    user.chatRecordTimeOut = g_myself.chatRecordTimeOut;
    if(!user.haveTheUser)
        [user insert];
    else {
        [user update];
    }
    
    // 我的其他端设备
    NSArray *names = @[Localized(@"JX_MyAndroid"), Localized(@"JX_MyWindowsComputer"), Localized(@"JX_MyMacComputer"), Localized(@"JX_MyWebPage")];
    NSArray *userIds = @[ANDROID_USERID, PC_USERID, MAC_USERID, WEB_USERID];
    
    for (NSInteger i = 0; i < names.count; i ++) {
//        BOOL isMultipleLogin = [[g_default objectForKey:kISMultipleLogin] boolValue];
        BOOL isMultipleLogin = [g_myself.multipleDevices intValue] > 0 ? YES : NO;
        user.userId = userIds[i];
        user.userNickname = names[i];
        user.status = [NSNumber numberWithInt:10];
        user.userType = [NSNumber numberWithInt:0];
        user.roomFlag = [NSNumber numberWithInt:0];
        user.isDevice = [NSNumber numberWithInt:1];
        user.isOnLine = [NSNumber numberWithInt:0];
        user.content = nil;
        user.timeSend = [NSDate date];
        user.chatRecordTimeOut = g_myself.chatRecordTimeOut;
        if (isMultipleLogin) {
            if (![user haveTheUser]) {
                [user insert];
            }else {
                [user updateIsOnLine];
                [user updateUserNickname];
                [g_notify postNotificationName:kUpdateIsOnLineMultipointLogin object:nil];
            }
        }else {
            [user delete];
        }
    }
    
}

-(NSMutableArray*)doFetch:(NSString*)sql
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [super checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXUserObject *user=[[JXUserObject alloc] init];
        [super userFromDataset:user rs:rs];
//        [self userFromDataset:rs];
        [resultArr addObject:user];
//        [user release];
    }
    [rs close];
    if([resultArr count]==0){
//        [resultArr release];
        resultArr = nil;
    }
    return resultArr;
}

-(JXUserObject*)getUserById:(NSString*)aUserId
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    FMResultSet *rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where userId=?",_tableName],aUserId];
    if ([rs next]) {
        JXUserObject *user=[[JXUserObject alloc]init];
        [super userFromDataset:user rs:rs];
        [rs close];
        return user;
    };
    return nil;
}


-(JXUserObject*)getUserByRoomId:(NSString*)roomId {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    FMResultSet *rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where roomId=?",_tableName],roomId];
    if ([rs next]) {
        JXUserObject *user=[[JXUserObject alloc]init];
        [super userFromDataset:user rs:rs];
        [rs close];
        return user;
    };
    return nil;
}

-(int)getNewTotal
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
     
    int n = 0;
    FMResultSet *rs=[db executeQuery:[NSString stringWithFormat:@"select sum(newMsgs) from %@ where newMsgs>0",_tableName]];
    if ([rs next]) {
        n = [[rs objectForColumnIndex:0] intValue];
        [rs close];
    };
    return n;
}

-(void)getDataFromDict:(NSDictionary*)dict{
    self.type = nil;
    self.content = nil;
//    self.timeSend = nil;
    self.msgsNew = nil;
//    self.timeCreate = [NSDate date];
    self.roomFlag = [NSNumber numberWithInt:0];

    /*
    我是A,调user/get?userId=B
    friends->isBeenBlack，A是不是被B拉黑
    friends->Blacklist，A是不是拉黑B
    */
    
    self.status = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"status"];
    self.timeCreate = [dict objectForKey:@"createTime"];
    self.userType = [dict objectForKey:@"userType"];
    
    if([[(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"blacklist"] boolValue])
        self.status = [NSNumber numberWithInt:friend_status_black];
    
    self.isBeenBlack = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"isBeenBlack"];
    if ([self.isBeenBlack intValue] == 1) {
        self.status = [NSNumber numberWithInt:friend_status_hisBlack];
    }
//    if([[[dict objectForKey:@"friends"] objectForKey:@"isBeenBlack"] boolValue])
//        self.status = [NSNumber numberWithInt:friend_status_hisBlack];
    self.userId = [[dict objectForKey:@"userId"] stringValue];
    NSString *remarkName = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"remarkName"];
    if (remarkName.length > 0) {
        self.remarkName = remarkName;
    }
    NSString *describe = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"describe"];
    if (describe.length > 0) {
        self.describe = describe;
    }
//    if ([dict objectForKey:@"toFriendsRole"]) {
//        NSArray *roleDict = [dict objectForKey:@"toFriendsRole"];
//        self.role = @([[[roleDict firstObject] objectForKey:@"role"] intValue]);
//    }
    self.userNickname = [dict objectForKey:@"nickname"];
    self.userDescription = [dict objectForKey:@"description"];
    self.companyId = [dict objectForKey:@"companyId"];
    self.companyName = [(NSDictionary *)[dict objectForKey:@"company"] objectForKey:@"name"];
    self.msgBackGroundUrl = [dict objectForKey:@"msgBackGroundUrl"];
    self.showLastLoginTime = [dict objectForKey:@"showLastLoginTime"];
    
    self.telephone = [dict objectForKey:@"telephone"];
    self.phone = [dict objectForKey:@"phone"];
    self.password = [dict objectForKey:@"password"];
    self.userType = [dict objectForKey:@"userType"];
    self.birthday = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"birthday"] longLongValue]];
    self.sex  = [dict objectForKey:@"sex"];
    self.countryId = [dict objectForKey:@"countryId"];
    self.provinceId = [dict objectForKey:@"provinceId"];
    self.cityId = [dict objectForKey:@"cityId"];
    self.areaId = [dict objectForKey:@"areaId"];
    self.fansCount = [dict objectForKey:@"fansCount"];
    self.attCount = [dict objectForKey:@"attCount"];
    self.level = [dict objectForKey:@"level"];
    self.vip = [dict objectForKey:@"vip"];
    self.notSeeHim = [dict objectForKey:@"notSeeHim"];
    self.notLetSeeHim = [dict objectForKey:@"notLetSeeHim"];

    self.model = [dict objectForKey:@"model"];
    self.osVersion = [dict objectForKey:@"osVersion"];
    self.serialNumber = [dict objectForKey:@"serialNumber"];
    self.location = [dict objectForKey:@"location"];
//    self.latitude = [dict objectForKey:@"latitude"];
//    self.longitude = [dict objectForKey:@"longitude"];
    self.latitude  = [(NSDictionary *)[dict objectForKey:@"loc"] objectForKey:@"lat"];
    self.longitude = [(NSDictionary *)[dict objectForKey:@"loc"] objectForKey:@"lng"];
    
    if ([dict objectForKey:@"friends"]) {
        self.offlineNoPushMsg = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"offlineNoPushMsg"];
        self.isOpenReadDel = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"isOpenSnapchat"];
        long time = [[(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"openTopChatTime"] longLongValue];
        self.topTime = [NSDate dateWithTimeIntervalSince1970:time];
        self.chatRecordTimeOut = [NSString stringWithFormat:@"%@", [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"chatRecordTimeOut"]];
    }
    if ([dict objectForKey:@"member"]) {
        long time = [[(NSDictionary *)[dict objectForKey:@"member"] objectForKey:@"openTopChatTime"] longLongValue];
        self.topTime = [NSDate dateWithTimeIntervalSince1970:time];
        self.offlineNoPushMsg = [(NSDictionary *)[dict objectForKey:@"member"] objectForKey:@"offlineNoPushMsg"];
        
        self.timeCreate = [(NSDictionary *)[dict objectForKey:@"member"] objectForKey:@"createTime"];
    }
    if ([dict objectForKey:@"settings"]) {
        self.isOpenPrivacyPosition = [NSString stringWithFormat:@"%@",[(NSDictionary *)[dict objectForKey:@"settings"] objectForKey:@"isOpenPrivacyPosition"]];
    }

    self.encryptType = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"encryptType"];
    
//    self.chatRecordTimeOut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"chatRecordTimeOut"]];
    self.talkTime = [dict objectForKey:@"talkTime"];
    self.myInviteCode = [dict objectForKey:@"myInviteCode"];
    self.setAccountCount = [dict objectForKey:@"setAccountCount"];
    self.account = [dict objectForKey:@"account"];
    
    if ([(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"dhMsgPublicKey"]) {
        self.publicKeyDH = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"dhMsgPublicKey"];
    }
    if ([(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"rsaMsgPublicKey"]) {
        self.publicKeyRSARoom = [(NSDictionary *)[dict objectForKey:@"friends"] objectForKey:@"rsaMsgPublicKey"];
    }
    if ([dict objectForKey:@"chatKeyGroup"]) {
        self.chatKeyGroup = [dict objectForKey:@"chatKeyGroup"];
    }
    if ([dict objectForKey:@"isSecretGroup"]) {
        self.isSecretGroup = [dict objectForKey:@"isSecretGroup"];
    }
    if ([dict objectForKey:@"isLostChatKeyGroup"]) {
        self.isLostChatKeyGroup = [dict objectForKey:@"isLostChatKeyGroup"];
    }
}

-(void)getDataFromDictSmall:(NSDictionary*)dict{
    self.type = nil;
    self.content = nil;
    self.timeSend = nil;
    self.msgsNew = nil;
    self.roomFlag = [NSNumber numberWithInt:0];
    
    self.timeCreate = [dict objectForKey:@"createTime"];
    self.status = [dict objectForKey:@"status"];
    if ([[dict objectForKey:@"isBeenBlack"] intValue] == 1) {
        self.status = [NSNumber numberWithInt:friend_status_hisBlack];
    }
    self.userType = [dict objectForKey:@"toUserType"];
    if ([[dict objectForKey:@"blacklist"] integerValue] == 1) {
        self.status = [NSNumber numberWithInt:-1];
    }
//    if ([dict objectForKey:@"toFriendsRole"]) {
//        NSArray *roleDict = [dict objectForKey:@"toFriendsRole"];
//        self.role = @([[[roleDict firstObject] objectForKey:@"role"] intValue]);
//    }
    self.userId = [[dict objectForKey:@"toUserId"] stringValue];
    self.remarkName = [dict objectForKey:@"remarkName"];
    if ([[dict objectForKey:@"remarkName"] length] > 0) {
        self.userNickname = [dict objectForKey:@"remarkName"];
    }else {
        self.userNickname = [dict objectForKey:@"toNickname"];
    }
    self.describe = [dict objectForKey:@"describe"];
    if ([dict objectForKey:@"companyId"]) {
        self.companyId = [dict objectForKey:@"companyId"];
    }else {
        self.companyId = [NSNumber numberWithInt:0];
    }
    if ([dict objectForKey:@"chatRecordTimeOut"]) {
        self.chatRecordTimeOut = [NSString stringWithFormat:@"%@",[dict objectForKey:@"chatRecordTimeOut"]];
    }
    if ([dict objectForKey:@"talkTime"]) {
        self.talkTime = [dict objectForKey:@"talkTime"];
    }
    if ([dict objectForKey:@"offlineNoPushMsg"]) {
        self.offlineNoPushMsg = [dict objectForKey:@"offlineNoPushMsg"];
    }
    if ([dict objectForKey:@"openTopChatTime"]) {
        long time = [[dict objectForKey:@"openTopChatTime"] longLongValue];
        if (time > 0) {
            self.topTime = [NSDate dateWithTimeIntervalSince1970:time];
        }
    }

    if ([dict objectForKey:@"dhMsgPublicKey"]) {
        self.publicKeyDH = [dict objectForKey:@"dhMsgPublicKey"];
    }
    if ([dict objectForKey:@"rsaMsgPublicKey"]) {
        self.publicKeyRSARoom = [dict objectForKey:@"rsaMsgPublicKey"];
    }
    if ([dict objectForKey:@"chatKeyGroup"]) {
        self.chatKeyGroup = [dict objectForKey:@"chatKeyGroup"];
    }
    if ([dict objectForKey:@"encryptType"]) {
        self.encryptType = [dict objectForKey:@"encryptType"];
    }
    
#ifndef IS_MsgEncrypt
    if ([self.encryptType intValue] == 3 || [self.encryptType intValue] == 2) {
        self.encryptType = [NSNumber numberWithInt:1];
    }
#else
    if (![g_config.isOpenSecureChat boolValue]) {
        if ([self.encryptType intValue] == 3 || [self.encryptType intValue] == 2) {
            self.encryptType = [NSNumber numberWithInt:1];
        }
    }
#endif
    
    if ([dict objectForKey:@"isSecretGroup"]) {
        self.isSecretGroup = [dict objectForKey:@"isSecretGroup"];
    }
    if ([dict objectForKey:@"isLostChatKeyGroup"]) {
        self.isLostChatKeyGroup = [dict objectForKey:@"isLostChatKeyGroup"];
    }
    if ([dict objectForKey:@"rsaMsgPublicKey"]) {
        self.publicKeyRSARoom = [dict objectForKey:@"rsaMsgPublicKey"];
    }
    
    if ([dict objectForKey:@"dhMsgPublicKey"]) {
        self.publicKeyDH = [dict objectForKey:@"dhMsgPublicKey"];
    }
}

-(void)copyFromResume:(resumeBaseData*)resume{
    self.telephone   = resume.telephone;
    self.userNickname= resume.name;
    self.birthday    = [NSDate dateWithTimeIntervalSince1970:resume.birthday];
    self.sex         = [NSNumber numberWithBool:resume.sex];
    self.countryId   = [NSNumber numberWithInt:resume.countryId];
    self.provinceId  = [NSNumber numberWithInt:resume.provinceId];
    self.cityId      = [NSNumber numberWithInt:resume.cityId];
    self.areaId      = [NSNumber numberWithInt:resume.areaId];
    self.latitude    = [NSNumber numberWithDouble:g_server.latitude];
    self.longitude   = [NSNumber numberWithDouble:g_server.longitude];
}

+(void)deleteUserAndMsg:(NSString*)s{
    JXUserObject* p = [[JXUserObject alloc]init];
    p.userId = s;

    [p notifyDelFriend];
    [p delete];
//    [p release];
    
    JXMessageObject* m = [[JXMessageObject alloc]init];
    m.fromUserId = MY_USER_ID;
    m.toUserId = s;
    [m deleteAll];
//    [m release];
}

+(BOOL)updateNewMsgsTo0{
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"update friend set newMsgs=0"]];
    return worked;
}

-(void)copyFromRoomMember:(memberData*)p{
    self.userId = [NSString stringWithFormat:@"%ld",p.userId];
    self.userNickname = p.userNickName;
}

// 更新最后输入
- (BOOL) updateLastInput {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set lastInput=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.lastInput,self.userId];
    return worked;
}

// 更新消息界面显示的最后一条消息
- (BOOL) updateLastContent {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set content=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.content,self.userId];
    return worked;
}


+(NSString*)getUserNameWithUserId:(NSString*)userId{
    if(userId==nil)
        return nil;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    //获取用户名
    NSString* sql= [NSString stringWithFormat:@"select userNickname from friend where userId=%@",userId];
    FMResultSet *rs=[db executeQuery:sql];
    if([rs next]) {
        NSString* s = [rs objectForColumnName:@"userNickname"];
        return s;
    }
    
    return nil;
}

+(NSMutableArray *)getUserNameWithUserIdsArray:(NSArray *)userIdsArray{
    if (userIdsArray.count == 0) {
        return nil;
    }
    NSMutableArray *userNamesArray = [NSMutableArray array];
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    //获取用户名
    for (NSInteger i = 0; i < userIdsArray.count; i++) {
        NSString *userId = userIdsArray[i];
        NSString* sql= [NSString stringWithFormat:@"select userNickname from friend where userId=%@",userId];
        FMResultSet *rs=[db executeQuery:sql];
        if([rs next]) {
            NSString* s = [rs objectForColumnName:@"userNickname"];
            if (!s) {
                s = @"";
            }
            [userNamesArray addObject:s];
        }
    }
    if (userNamesArray.count > 0) {
        return userNamesArray;
    }
    return nil;
}

// 更新置顶时间
- (BOOL) updateTopTime {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set topTime=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.topTime,self.userId];
    return worked;
}

// 更新群组有效性
- (BOOL) updateGroupInvalid {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set groupStatus=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.groupStatus,self.userId];
    return worked;
}

// 更新用户昵称
- (BOOL) updateUserNickname {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *nickName;
    if (self.remarkName.length > 0) {
        nickName = self.remarkName;
    }else {
        nickName = self.userNickname;
    }
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set userNickname=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,nickName,self.userId];
    return worked;
}

// 更新用户备注
- (BOOL) updateRemarkName {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set remarkName=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.remarkName,self.userId];
    return worked;
}

// 更新用户聊天记录过期时间
- (BOOL) updateUserChatRecordTimeOut {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set chatRecordTimeOut=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.chatRecordTimeOut,self.userId];
    return worked;
}

// 更新列表最近一条消息记录
- (BOOL) updateUserLastChatList:(NSArray *)array {
    NSMutableArray *userArray = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i ++) {
        NSDictionary *dict = array[i];
        if ([g_xmpp.blackList containsObject:dict[@"jid"]]) {
            continue;
        }
        JXUserObject *user = [[JXUserObject sharedInstance] getUserById:dict[@"jid"]];
        
        
        NSNumber *isEncrypt = dict[@"isEncrypt"];
        
        int encryptType = [[dict objectForKey:@"encryptType"] intValue];
        if ([isEncrypt boolValue] && encryptType == 0) {
            isEncrypt = [NSNumber numberWithInt:1];
        }else {
            isEncrypt = [NSNumber numberWithInt:encryptType];
        }

        NSString *messageId = dict[@"messageId"];
        long timeSend = [dict[@"timeSend"] longLongValue];
        NSString *content = dict[@"content"];
        NSString *fromUserId = [dict objectForKey:@"from"];
        NSString *toUserId = [dict objectForKey:@"to"];
        
        if ([current_chat_userId isEqualToString:user.userId]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [g_notify postNotificationName:kChatVCMessageSync object:@(timeSend)];
            });
        }
        
        content = [self getLastListContent:dict];
        
//#ifdef IS_MsgEncrypt
        
        // 消息验签字段
        NSString *msgSignature = [dict objectForKey:@"signature"];
        
        if ([[dict objectForKey:@"isRoom"] boolValue]) {
            
            if ([user.isSecretGroup boolValue]) {
#ifdef IS_MsgEncrypt
                if ([g_config.isOpenSecureChat boolValue]) {
                    if (!user.roomId || user.roomId.length <= 0 || content.length <= 0 || !content || !user.chatKeyGroup) {
                        continue;
                    }
                    NSString *chatKeyGroup = [g_msgUtil decryptRoomMsgKey:user.roomId randomKey:user.chatKeyGroup];
                    
                    NSData *keyData = [g_msgUtil getMsgContentKeyWithMsgId:messageId key:chatKeyGroup];
                    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    NSData *deContentData = [AESUtil decryptAESData:contentData key:keyData];
                    NSString *deContent = [[NSString alloc] initWithData:deContentData encoding:NSUTF8StringEncoding];
                    
                    
                    NSString *signature = [g_msgUtil getRoomMsgMacWithContent:content fromUserId:fromUserId toUserId:toUserId isEncrypt:[isEncrypt integerValue] msgId:messageId randomKey:[keyData base64EncodedStringWithOptions:0]];
                    
                    if (![user.isLostChatKeyGroup boolValue]) {
                        // 验签成功
                        content = deContent;
                    }else if ([self.type integerValue] == kWCMessageTypeChatKeyGroupRequest || [self.type integerValue] == kWCMessageTypeChatKeyGroupSend) {
    //                    self.content = messCont;
    //                    content = @"[密文消息]";
                    }else {
                        
                        content = [NSString stringWithFormat:@"[%@]",Localized(@"JX_CiphertextMessage")];
                    }
    //                else {
    //                    self.isVerifySignatureFailed = [NSNumber numberWithBool:YES];   // 将消息标明为验签失败消息
    //
    //                    // 将消息放入缓存队列
    //                    NSMutableArray *arr = [g_msgUtil.verifyFailedDic objectForKey:user.userId];
    //                    if (!arr) {
    //                        arr = [NSMutableArray array];
    //                    }
    //
    //                    self.content = messCont;
    //
    //                    JXMessageObject *msg = [[JXMessageObject alloc] init];
    //                    [msg copy:self];
    //
    //                    [arr addObject:msg];
    //                    [g_msgUtil.verifyFailedDic setObject:arr forKey:user.userId];
    //
    //                    if (![g_msgUtil.getDHListIds containsObject:user.userId]) {
    //
    //                        [g_msgUtil.getDHListIds addObject:user.userId];
    //                        // 获取群组最新的通讯秘钥
    //                        [g_msgUtil getChatKeyGroupWithRoomId:user.roomId];
    //                    }
    //                }
                }
#endif
            }else {
                
                if ([isEncrypt integerValue] == 1) {
                    //        self.content = [DESUtil decryptDESStr:messCont key:[NSString stringWithFormat:@"%@",[p objectForKey:kMESSAGE_TIMESEND]]];
                    NSMutableString *str = [NSMutableString string];
                    [str appendString:APIKEY];
                    [str appendString:[NSString stringWithFormat:@"%ld",(long)[self.timeSend timeIntervalSince1970]]];
                    [str appendString:messageId];
                    NSString *keyStr = [g_server getMD5String:str];
                    content = [DESUtil decryptDESStr:content key:keyStr];
                    
                }else{
                }
                
            }
        }else {
            
            if ([isEncrypt integerValue] == 3) {
#ifdef IS_MsgEncrypt
                if ([g_config.isOpenSecureChat boolValue]) {
                    if (user.publicKeyDH && user.publicKeyDH.length > 0) {
                        // 签名
//                        NSString *signature = [g_msgUtil getChatMsgMacWithContent:content fromUserId:fromUserId toUserId:toUserId isEncrypt:[isEncrypt integerValue] msgId:messageId publicKey:user.publicKeyDH];
//                        if ([msgSignature isEqualToString:signature]) {
                            // 验签成功
                            content = [g_msgUtil decryptContentWithPublicKey:user.publicKeyDH content:content msgId:messageId];
                        
//                        }else if ([self.type integerValue] == kWCMessageTypeChatKeyGroupRequest || [self.type integerValue] == kWCMessageTypeChatKeyGroupSend) {
//    //                        self.content = messCont;
//
//    //                        content = @"[密文消息]";
//                        }
//                        else { // 验签失败
//
//                            // 获取好友公钥表
//                            NSMutableArray *keys = [[JXUserPublicKeyObj sharedManager] fetchPublicKeyWithUserId:user.userId];
//                            BOOL flag = NO;
//                            // 公钥表里公钥依次解密
//                            for (NSInteger i = 0; i < keys.count; i ++) {
//                                JXUserPublicKeyObj *obj = keys[i];
//                                if (obj.publicKey && obj.publicKey.length > 0) {
//                                    NSString *signature = [g_msgUtil getChatMsgMacWithContent:content fromUserId:fromUserId toUserId:toUserId isEncrypt:[isEncrypt integerValue] msgId:messageId publicKey:obj.publicKey];
//                                    if ([msgSignature isEqualToString:signature]) {
//                                        flag = YES;
//                                        content = [g_msgUtil decryptContentWithPublicKey:obj.publicKey content:content msgId:messageId];
//                                        break;
//                                    }
//                                }
//                            }
//                            if (!flag) {
//
//                                content = @"[密文消息]";
//                            }
//    //                        if (!flag) {    // 解密失败，调用获取服务器公钥表接口
//    //                            self.isVerifySignatureFailed = [NSNumber numberWithBool:YES];   // 将消息标明为验签失败消息
//    //
//    //                            // 将消息放入缓存队列
//    //                            NSMutableArray *arr = [g_msgUtil.verifyFailedDic objectForKey:user.userId];
//    //                            if (!arr) {
//    //                                arr = [NSMutableArray array];
//    //                            }
//    //
//    //                            self.content = messCont;
//    //
//    //                            JXMessageObject *msg = [[JXMessageObject alloc] init];
//    //                            [msg copy:self];
//    //
//    //                            [arr addObject:msg];
//    //                            [g_msgUtil.verifyFailedDic setObject:arr forKey:user.userId];
//    //
//    //                            if (![g_msgUtil.getDHListIds containsObject:user.userId]) {
//    //
//    //                                [g_msgUtil.getDHListIds addObject:user.userId];
//    //                                // 获取服务器公钥表
//    //                                [g_msgUtil getDHPublicKeyWithUserId:user.userId];
//    //                            }
//    //
//                            }
                        }else { // 朋友表没有此用户公钥
                    
                            content = [NSString stringWithFormat:@"[%@]",Localized(@"JX_CiphertextMessage")];
    //                    if (user) {
    //                        self.isVerifySignatureFailed = [NSNumber numberWithBool:YES];   // 将消息标明为验签失败消息
    //
    //                        // 将消息放入缓存队列
    //                        NSMutableArray *arr = [g_msgUtil.verifyFailedDic objectForKey:user.userId];
    //                        if (!arr) {
    //                            arr = [NSMutableArray array];
    //                        }
    //
    //                        self.content = messCont;
    //
    //                        JXMessageObject *msg = [[JXMessageObject alloc] init];
    //                        [msg copy:self];
    //
    //                        [arr addObject:msg];
    //                        [g_msgUtil.verifyFailedDic setObject:arr forKey:user.userId];
    //
    //                        if (![g_msgUtil.getDHListIds containsObject:user.userId]) {
    //
    //                            [g_msgUtil.getDHListIds addObject:user.userId];
    //                            // 获取服务器公钥表
    //                            [g_msgUtil getDHPublicKeyWithUserId:user.userId];
    //                        }
    //                    }else {
    //                        self.content = messCont;
    //                    }
    //
                    }
                }
#endif
            }else if ([isEncrypt integerValue] == 2) {
                
                NSMutableString *str = [NSMutableString string];
                [str appendString:APIKEY];
                [str appendString:messageId];
                NSData *keyData = [MD5Util getMD5DataWithString:str];
                
                NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
                NSData *aesData = [AESUtil decryptAESData:contentData key:keyData];
                content = [[NSString alloc] initWithData:aesData encoding:NSUTF8StringEncoding];
                
//                if (IsStringNull(self.content)) {
//                    self.content = messCont;
//                }
            }else if ([isEncrypt integerValue] == 1) {
                
                NSMutableString *str = [NSMutableString string];
                [str appendString:APIKEY];
                [str appendString:[NSString stringWithFormat:@"%ld",(long)[self.timeSend timeIntervalSince1970]]];
                [str appendString:messageId];
                NSString *keyStr = [g_server getMD5String:str];
                content = [DESUtil decryptDESStr:content key:keyStr];
//                if (IsStringNull(self.content)) {
//                    self.content = messCont;
//                }
                
            }else {
//                self.content = messCont;
            }
        }
        
//#else
//    if ([isEncrypt boolValue]) {
//        NSMutableString *str = [NSMutableString string];
//        [str appendString:APIKEY];
//        [str appendString:[NSString stringWithFormat:@"%ld",timeSend]];
//        [str appendString:messageId];
//        NSString *keyStr = [g_server getMD5String:str];
//        content = [DESUtil decryptDESStr:content key:keyStr];
//
//    }else{
////        content = content;
//    }
//#endif
        
        user.content = content;
        user.type = dict[@"type"];
        user.timeSend = [NSDate dateWithTimeIntervalSince1970:timeSend / 1000.0];
        
        if (user) {
            if (user.content.length > 0) {
//                [user update];
                [userArray addObject:user];
            }
        }else {
//            user = [[JXUserObject alloc] init];
//            
//            user.content = content;
//            user.type = dict[@"type"];
//            if ([dict[@"isRoom"] boolValue]) {
//                user.roomFlag= [NSNumber numberWithInt:1];
//                user.companyId= [NSNumber numberWithInt:0];
//                user.status= [NSNumber numberWithInt:2];
//                user.offlineNoPushMsg = [NSNumber numberWithInt:0];
//                user.isAtMe = [NSNumber numberWithInt:0];
//            }
//            user.timeSend = [NSDate dateWithTimeIntervalSince1970:timeSend];
//            user.userId = dict[@"jid"];
//            user.userNickname = dict[@"toUserName"];
//            [user insert];
        }
    }
    [self updateLastListContent:userArray withTransaction:YES];
    return YES;
}

- (void)updateLastListContent:(NSArray *)dataArray withTransaction:(BOOL )useTransaction{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    if (useTransaction) {
        [db beginTransaction];
        BOOL isRollBack = NO;
        @try {
            for (NSInteger i = 0; i < dataArray.count; i++) {
                JXUserObject *user = dataArray[i];
                if (user.roomId.length > 0) {
                    user.roomFlag= [NSNumber numberWithInt:1];
                    user.companyId= [NSNumber numberWithInt:0];
                    if (!user.status) {
                        user.status= [NSNumber numberWithInt:2];
                    }
                }
                if(!user.timeSend)
                    user.timeSend = [NSDate date];
                if (!user.companyId) {
                    user.companyId = [NSNumber numberWithInt:0];
                }
                if ([user.userId intValue] == [SHIKU_TRANSFER intValue]) {
                    user.userNickname = Localized(@"JX_PaymentNo.");
                }
                if ([user.topTime timeIntervalSince1970] > 0) {
                    user.topTime = self.topTime;
                }else {
                    user.topTime = nil;
                }
                if (!user.content) {
                    user.content = @" ";
                }
                NSString* sql = [NSString stringWithFormat:@"update %@ set userNickname=?,remarkName=?,describe=?,role=?,userDescription=?,userHead=?,roomFlag=?,type=?,companyId=?,content=?,timeCreate=?,status=?,userType=?,isMySend=?,newMsgs=?,timeSend=?,downloadTime=?,roomId=?,showRead=?,showMember=?,allowSendCard=?,allowInviteFriend=?,allowUploadFile=?,allowConference=?,allowSpeakCourse=?,isNeedVerify=?,topTime=?,groupStatus=?,isOnLine=?,isOpenReadDel=?,isSendRecipt=?,isDevice=?,chatRecordTimeOut=?,offlineNoPushMsg=?,isAtMe=?,talkTime=?,joinTime=? where userId=?",_tableName];
                [db executeUpdate:sql,user.userNickname,user.remarkName,user.describe,user.role,user.userDescription,user.userHead,user.roomFlag,user.type,user.companyId,user.content,user.timeCreate,user.status,user.userType,user.isMySend,user.msgsNew,user.timeSend,user.downloadTime,user.roomId,user.showRead,user.showMember,user.allowSendCard,user.allowInviteFriend,user.allowUploadFile,user.allowConference,user.allowSpeakCourse,user.isNeedVerify,user.topTime,user.groupStatus,user.isOnLine,user.isOpenReadDel,user.isSendRecipt,user.isDevice,user.chatRecordTimeOut,user.offlineNoPushMsg,user.isAtMe,user.talkTime,user.joinTime,user.userId];
            }
        } @catch (NSException *exception) {
            isRollBack = YES;
            [db rollback];
        } @finally {
            if (!isRollBack) {
                [db commit];
                [db close];
                [g_App copyDbWithUserId:MY_USER_ID];
            }else{
                [db close];
                [self updateLastListContent:dataArray withTransaction:NO];
            }
        }
    }else{
        for (NSInteger i = 0; i < dataArray.count; i++) {
            JXUserObject *user = dataArray[i];
            if(!user.timeSend)
                user.timeSend = [NSDate date];
            if (!user.companyId) {
                user.companyId = [NSNumber numberWithInt:0];
            }
            if ([user.userId intValue] == [SHIKU_TRANSFER intValue]) {
                user.userNickname = Localized(@"JX_PaymentNo.");
            }
            if ([user.topTime timeIntervalSince1970] > 0) {
                user.topTime = self.topTime;
            }else {
                user.topTime = nil;
            }
            NSString* sql = [NSString stringWithFormat:@"update %@ set userNickname=?,remarkName=?,describe=?,role=?,userDescription=?,userHead=?,roomFlag=?,type=?,companyId=?,content=?,timeCreate=?,status=?,userType=?,isMySend=?,newMsgs=?,timeSend=?,downloadTime=?,roomId=?,showRead=?,showMember=?,allowSendCard=?,allowInviteFriend=?,allowUploadFile=?,allowConference=?,allowSpeakCourse=?,isNeedVerify=?,topTime=?,groupStatus=?,isOnLine=?,isOpenReadDel=?,isSendRecipt=?,isDevice=?,chatRecordTimeOut=?,offlineNoPushMsg=?,isAtMe=?,talkTime=?,joinTime=? where userId=?",_tableName];
            BOOL worked = [db executeUpdate:sql,user.userNickname,user.remarkName,user.describe,user.role,user.userDescription,user.userHead,user.roomFlag,user.type,user.companyId,user.content,user.timeCreate,user.status,user.userType,user.isMySend,user.msgsNew,user.timeSend,user.downloadTime,user.roomId,user.showRead,user.showMember,user.allowSendCard,user.allowInviteFriend,user.allowUploadFile,user.allowConference,user.allowSpeakCourse,user.isNeedVerify,user.topTime,user.groupStatus,user.isOnLine,user.isOpenReadDel,user.isSendRecipt,user.isDevice,user.chatRecordTimeOut,user.offlineNoPushMsg,user.isAtMe,user.talkTime,user.joinTime,user.userId];
            
            if (!worked) {
                NSLog(@"存失败");
            }
        }
        [db close];
        [g_App copyDbWithUserId:MY_USER_ID];
    }
}

- (NSString *)getLastListContent:(NSDictionary *)dict {
    int type = [dict[@"type"] intValue];
    NSString *content = dict[@"content"];
    NSString *fromUserId = dict[@"from"];
    NSString *fromUserName = dict[@"fromUserName"];
    if (!fromUserName) {
        fromUserName = @"";
    }
    NSString *toUserId = dict[@"to"];
    NSString *toUserName = dict[@"toUserName"];
    if (!toUserName) {
        toUserName = @"";
    }
    
    
    NSString *from = fromUserId;
    NSRange range = [from rangeOfString:@"/"];
    NSString *device = [from substringFromIndex:range.location + 1];
    if ([device isEqualToString:@"ios"]) {
        fromUserId  = IOS_USERID;
    }
    if ([device isEqualToString:@"android"]) {
        fromUserId  = ANDROID_USERID;
    }
    if ([device isEqualToString:@"pc"]) {
        fromUserId  = PC_USERID;
    }
    if ([device isEqualToString:@"mac"]) {
        fromUserId  = MAC_USERID;
    }
    if ([device isEqualToString:@"web"]) {
        fromUserId  = WEB_USERID;
    }

    
    switch (type) {
        case kWCMessageTypeWithdraw:{
            if ([dict[@"isRoom"] boolValue]) {
                
                if ([fromUserId isEqualToString:MY_USER_ID] || IS_HAVE_DEVICE(fromUserId)) {
                    content = Localized(@"JX_AlreadyWithdraw");
                }else {
                    content = [NSString stringWithFormat:@"%@ %@",fromUserName, Localized(@"JX_OtherWithdraw")];

                }
            }else {
                if ([fromUserId isEqualToString:MY_USER_ID] || IS_HAVE_DEVICE(fromUserId)) {

                    content = Localized(@"JX_AlreadyWithdraw");
                }else {
                    content = [NSString stringWithFormat:@"%@ %@",fromUserName, Localized(@"JX_OtherWithdraw")];
                }
            }
        }
            break;
            
        case kWCMessageTypeShare:
            content = [NSString stringWithFormat:@"[%@]",Localized(@"JXLink")];
            break;
        case kWCMessageTypeRedPacketReceive:
            content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXRed_whoGet")];
            break;
        case kWCMessageTypeRedPacketReturn:
            content = [NSString stringWithFormat:@"%@",Localized(@"JX_ RedEnvelopeExpired")];
            break;
        case kWCMessageTypeGroupFileUpload:
            content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXMessage_fileUpload")];
            break;
        case kWCMessageTypeGroupFileDelete:
            content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXMessage_fileDelete")];
            break;
        case kWCMessageTypeGroupFileDownload:
            content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXMessage_fileDownload")];
            break;
        case kRoomRemind_RoomName:
            content = [NSString stringWithFormat:@"%@%@%@",fromUserName,Localized(@"JXMessageObject_UpdateRoomName"),content];
            break;
        case kRoomRemind_NickName:{
            content = [NSString stringWithFormat:@"%@%@%@",fromUserName,Localized(@"JXMessageObject_UpdateNickName"),content];
        }
            break;
        case kRoomRemind_DelRoom:
            if ([toUserId isEqualToString:MY_USER_ID]) {
                content = [NSString stringWithFormat:Localized(@"JX_DissolutionGroup"),fromUserName];
            }else {
                content = [NSString stringWithFormat:@"%@%@:%@",fromUserName,Localized(@"JXMessage_delRoom"),content];
            }
            
            break;
        case kRoomRemind_AddMember:
            if([toUserId isEqualToString:fromUserId]) {
                content = nil;
                if (![toUserId isEqualToString:MY_USER_ID] && !IS_OTHER_DEVICE(toUserId)) {
                    content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXMessageObject_GroupChat")];
                }
            }
            else
                content = [NSString stringWithFormat:@"%@%@%@",fromUserName,Localized(@"JXMessageObject_InterFriend"),toUserName];
            break;
        case kLiveRemind_ExitRoom:
            if([toUserId isEqualToString:fromUserId]){
                content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"EXITED_LIVE_ROOM")];//退出
                
            }else{
                content = [NSString stringWithFormat:@"%@%@",toUserName,Localized(@"JX_LiveVC_kickLive")];//被踢出
            }
            break;
        case kRoomRemind_DelMember:
            if([toUserId isEqualToString:fromUserId]){
                    content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXMessageObject_OutGroupChat")];
            }else{
                if ([toUserId isEqualToString:MY_USER_ID]) {
                    content = [NSString stringWithFormat:Localized(@"JX_OutOfTheGroup"),fromUserName];
                }else {
                    if ([fromUserName isEqualToString:toUserName]) {
                        content = [NSString stringWithFormat:@"%@%@",fromUserName,Localized(@"JXRoomMemberVC_OutPutRoom")];
                    }else {
                        content = [NSString stringWithFormat:@"%@%@%@",fromUserName,Localized(@"JXMessageObject_KickOut"),toUserName];
                    }
                }
            }
                
            break;
        case kRoomRemind_NewNotice:
            content = [NSString stringWithFormat:@"%@%@%@",fromUserName,Localized(@"JXMessageObject_AddNewAdv"),content];
            break;
        case kLiveRemind_ShatUp:
        case kRoomRemind_DisableSay:{
            if([content longLongValue]==0){
                content = [NSString stringWithFormat:@"%@%@%@%@",fromUserName,Localized(@"JXMessageObject_Yes"),toUserName,Localized(@"JXMessageObject_CancelGag")];
            }else{
                NSDate* d = [NSDate dateWithTimeIntervalSince1970:[content longLongValue]];
                NSString* t = [TimeUtil formatDate:d format:@"MM-dd HH:mm"];
                content = [NSString stringWithFormat:@"%@%@%@%@%@",fromUserName,Localized(@"JXMessageObject_Yes"),toUserName,Localized(@"JXMessageObject_SetGagWithTime"),t];
                d = nil;
            }
            break;
        }
        case kLiveRemind_SetManager:
        case kRoomRemind_SetManage:{
            if ([content integerValue] == 1) {
                content = [NSString stringWithFormat:@"%@%@%@%@",Localized(@"JXGroup_Owner"),Localized(@"JXSettingVC_Set"),toUserName,Localized(@"JXMessage_admin")];
            }else {
                content = [NSString stringWithFormat:@"%@%@%@",Localized(@"JXGroup_Owner"),Localized(@"CANCEL_ADMINISTRATOR"),toUserName];
            }
            break;
        }
        case kRoomRemind_EnterLiveRoom:{
            content = [NSString stringWithFormat:@"%@%@",toUserName,Localized(@"Enter_LiveRoom")];//加入房间消息
            break;
        }
        case kRoomRemind_ShowRead:{
            if ([content integerValue] == 1)
                content = [NSString stringWithFormat:@"%@%@%@",Localized(@"JXGroup_Owner"),Localized(@"JX_Enable"),Localized(@"JX_RoomReadMode")];
            else
                content = [NSString stringWithFormat:@"%@%@%@",Localized(@"JXGroup_Owner"),Localized(@"JX_Disable"),Localized(@"JX_RoomReadMode")];
            break;
        }
        case kRoomRemind_NeedVerify:{
            
            if (!content || content.length <= 0) {
                content = Localized(@"JX_GroupInvitationConfirmation");
            }else {
                if ([content integerValue] == 1)
                    content = Localized(@"JX_GroupOwnersOpenValidation");
                else
                    content = Localized(@"JX_GroupOwnersCloseValidation");
            }
            
            break;
        }
        case kRoomRemind_IsLook:{
            if ([content integerValue] == 0)
                content = Localized(@"JX_GroupOwnersPublicGroup");
            else
                content = Localized(@"JX_GroupOwnersPrivateGroup");
            break;
        }
            
        case kRoomRemind_ShowMember:{
            if ([content integerValue] == 1)
                content = Localized(@"JX_GroupOwnersShowMembers");
            else
                content = Localized(@"JX_GroupOwnersNotShowMembers");
            break;
        }
            
        case kRoomRemind_allowSendCard:{
            if ([content integerValue] == 1)
                content = Localized(@"JX_ManagerOpenChat");
            else
                content = Localized(@"JX_ManagerOffChat");
            break;
        }
            
        case kRoomRemind_RoomAllBanned:{
            if ([content integerValue] > 0)
                content = Localized(@"JX_ManagerOpenSilence");
            else
                content = Localized(@"JX_ManagerOffSilence");
            break;
        }
            
        case kRoomRemind_RoomAllowInviteFriend:{
            if ([content integerValue] > 0)
                content = Localized(@"JX_ManagerOpenInviteFriends");
            else
                content = Localized(@"JX_ManagerOffInviteFriends");
            break;
        }
            
        case kRoomRemind_RoomAllowUploadFile:{
            if ([content integerValue] > 0)
                content = Localized(@"JX_ManagerOpenSharedFiles");
            else
                content = Localized(@"JX_ManagerOffSharedFiles");
            break;
        }
            
        case kRoomRemind_RoomAllowConference:{
            if ([content integerValue] > 0)
                content = Localized(@"JX_ManagerOpenMeetings");
            else
                content = Localized(@"JX_ManagerOffMeetings");
            break;
        }
            
        case kRoomRemind_RoomAllowSpeakCourse:{
            if ([content integerValue] > 0)
                content = Localized(@"JX_ManagerOpenLectures");
            else
                content = Localized(@"JX_ManagerOffLectures");
            break;
        }
            
        case kRoomRemind_RoomTransfer:{
            content = [NSString stringWithFormat:@"\"%@\"%@", toUserName,Localized(@"JX_NewGroupManager")];
            break;
        }
        case kRoomRemind_SetInvisible:{
            if ([content integerValue] == 1) {
                content = [NSString stringWithFormat:@"%@%@%@%@",fromUserName,Localized(@"JXSettingVC_Set"),toUserName,Localized(@"JX_ForTheInvisibleMan")];
            }else if ([content integerValue] == -1){
                content = [NSString stringWithFormat:@"%@%@%@",fromUserName,Localized(@"JX_EliminateTheInvisible"),toUserName];
            }else if ([content integerValue] == 2){
                content = [NSString stringWithFormat:@"%@%@%@%@",fromUserName,Localized(@"JXSettingVC_Set"),toUserName,@"为监控人"];
            }else if ([content integerValue] == 0){
                content = [NSString stringWithFormat:@"%@%@%@",fromUserName,@"取消监控人",toUserName];
            }
            break;
        }
            
        case kRoomRemind_RoomDisable:{
            if ([content integerValue] == 1) {
                content = [NSString stringWithFormat:@"%@",Localized(@"JX_ThisGroupHasBeenDisabled")];
            }else {
                content = [NSString stringWithFormat:@"%@",Localized(@"JX_GroupNotUse")];
            }
            break;
        }
            
        case kRoomRemind_SetRecordTimeOut:{
            NSArray *pickerArr = @[Localized(@"JX_Forever"), Localized(@"JX_OneHour"), Localized(@"JX_OneDay"), Localized(@"JX_OneWeeks"), Localized(@"JX_OneMonth"), Localized(@"JX_OneQuarter"), Localized(@"JX_OneYear")];
            double outTime = [content doubleValue];
            NSString *str;
            if (outTime <= 0) {
                str = pickerArr[0];
            }else if (outTime == 0.04) {
                str = pickerArr[1];
            }else if (outTime == 1) {
                str = pickerArr[2];
            }else if (outTime == 7) {
                str = pickerArr[3];
            }else if (outTime == 30) {
                str = pickerArr[4];
            }else if (outTime == 90) {
                str = pickerArr[5];
            }else{
                str = pickerArr[6];
            }
            content = [NSString stringWithFormat:@"%@%@",Localized(@"JX_GroupManagerSetMsgDelTime"),str];
        }
        default:
            break;
    }
    
    return content;
}

// 更新群组全员禁言时间
- (BOOL) updateGroupTalkTime {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set talkTime=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.talkTime,self.userId];
    return worked;
}

// 更新是否开启阅后即焚标志
- (BOOL) updateIsOpenReadDel {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set isOpenReadDel=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.isOpenReadDel,self.userId];
    return worked;
}

// 更新消息免打扰
- (BOOL) updateOfflineNoPushMsg {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set offlineNoPushMsg=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.offlineNoPushMsg,self.userId];
    return worked;
}

// 更新@我
- (BOOL) updateIsAtMe{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set isAtMe=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.isAtMe,self.userId];
    return worked;
}

// 更新userType
- (BOOL) updateUserType {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set userType=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.userType,self.userId];
    return worked;
}

// 更新创建者
- (BOOL)updateCreateUser {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set createUserId=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.createUserId,self.userId];
    return worked;
}

// 更新群组设置
- (BOOL)updateGroupSetting {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set showRead=?,allowSendCard=?,allowConference=?,allowSpeakCourse=?,isNeedVerify=?,talkTime=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.showRead,self.allowSendCard,self.allowConference,self.allowSpeakCourse,self.isNeedVerify,self.talkTime,self.userId];
    return worked;
}

// 更新好友关系
- (BOOL)updateStatus {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set status=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.status,self.userId];
    return worked;
}

// 更新新消息数量
- (BOOL)updateNewMsgNum {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set newMsgs=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.msgsNew,self.userId];
    return worked;
}

// 更新我的设备是否在线
- (BOOL)updateIsOnLine {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set isOnLine=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.isOnLine,self.userId];
    return worked;
}

// 更新群组最后群成员加入时间
- (BOOL)updateJoinTime {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set joinTime=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.joinTime,self.userId];
    return worked;
}

// 删除用户过期聊天记录
- (BOOL) deleteUserChatRecordTimeOutMsg {
    NSMutableArray *array = [[JXMessageObject sharedInstance] fetchRecentChat];
    for (NSInteger i = 0; i < array.count; i ++) {
        JXMsgAndUserObject *userObj = array[i];
        [[JXMessageObject sharedInstance] deleteTimeOutMsg:userObj.user.userId chatRecordTimeOut:userObj.user.chatRecordTimeOut];
    }
    return YES;
}

- (BOOL) deleteAllUser {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where length(userId) > 5 and length(userId) < 10",_tableName];
    BOOL worked=[db executeUpdate:sql,self.userId];
    return worked;
}


// 清除所有黑名单好友
- (BOOL)deleteAllBlackUser {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where status=-1",_tableName];
    BOOL worked=[db executeUpdate:sql];
    return worked;
}

//插入已拨打的电话号码
- (BOOL) insertPhone:(NSString *)phone time:(NSDate *)time {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkPhoneTableCreatedInDb:db];
    FMResultSet * rs =  [db executeQuery:[NSString stringWithFormat:@"select * from telePhone where phone=?"],phone];
    BOOL flag = NO;
    if([rs next]) {
        flag = YES;
    }
    
    //    FMDBQuickCheck(worked);
    if (!flag) {
        NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('phone','time') VALUES (?,?)",@"telePhone"];
        BOOL worked = [db executeUpdate:insertStr,phone, time];
        return worked;
    }
    return YES;
}

// 删除已拨打的电话号码
- (BOOL) deletePhone:(NSString *)phone {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkPhoneTableCreatedInDb:db];
    BOOL worked = [db executeUpdate:[NSString stringWithFormat:@"delete from telePhone where phone=?"],phone];
    return worked;
}

- (NSMutableDictionary *) getPhoneDic {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkPhoneTableCreatedInDb:db];
     NSString* sql = [NSString stringWithFormat:@"select * from telePhone"];
    FMResultSet *rs = [db executeQuery:sql];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    while ([rs next]) {
        
        [dict setObject:[rs dateForColumn:@"time"] forKey:[rs stringForColumn:@"phone"]];
    }
    
    return dict;
}

-(BOOL)checkPhoneTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE IF NOT EXISTS '%@' ('phone' VARCHAR, 'time' DATETIME)",@"telePhone"];
    
    BOOL worked = [db executeUpdate:createStr];
    //    FMDBQuickCheck(worked);
    return worked;
}

// 更新好友DH公钥和RSA公钥
- (BOOL)updateDHPublicKeyAndRSAPublicKey {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set publicKeyDH=?,publicKeyRSARoom=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.publicKeyDH,self.publicKeyRSARoom,self.userId];
    return worked;
}
//查找好友
- (NSMutableArray *)searchContacts:(NSString *)searchtext limit:(BOOL )limit{
    NSString *sql;
    if (limit) {
        sql = [NSString stringWithFormat:@"select * from friend where (status=2 and companyId=0 and roomFlag=0 and isDevice=0) and ((userNickname like '%%%@%%') or (userId like '%%%@%%')) order by timeCreate limit 4",searchtext,searchtext];
    }else{
        sql = [NSString stringWithFormat:@"select * from friend where (status=2 and companyId=0 and roomFlag=0 and isDevice=0) and ((userNickname like '%%%@%%') or (userId like '%%%@%%')) order by timeCreate",searchtext,searchtext];
    }
    return [self doFetch:sql];
}
//查找群组昵称
- (NSMutableArray *)searchGroup:(NSString *)searchtext limit:(BOOL )limit{
    NSString *sql;
    if (limit) {
        sql = [NSString stringWithFormat:@"select * from friend where roomFlag=1 and userNickname like '%%%@%%' order by timeCreate limit 4",searchtext];
    }else{
        sql = [NSString stringWithFormat:@"select * from friend where roomFlag=1 and userNickname like '%%%@%%' order by timeCreate",searchtext];
    }
    return [self doFetch:sql];
}
//查找成员
- (NSMutableArray *)searchGroupMember:(NSString *)searchtext limit:(BOOL )limit{
    NSString *sql = [NSString stringWithFormat:@"select * from friend where roomFlag=1"];
    NSMutableArray *searchArray = [NSMutableArray array];
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [super checkTableCreatedInDb:db];
    FMResultSet *rs=[db executeQuery:sql];
    if (limit) {
        while ([rs next]) {
            NSString *userId = [rs stringForColumn:kROOM_ID];
            memberData *member =  [memberData fetchMembersWithText:searchtext withRoomId:userId];
            if (member != nil) {
                [searchArray addObject:member];
            }
            if (searchArray.count >= 4) {
                break;
            }
        }
    }else{
        while ([rs next]) {
            NSString *userId = [rs stringForColumn:kROOM_ID];
            memberData *member =  [memberData fetchMembersWithText:searchtext withRoomId:userId];
            if (member != nil) {
                [searchArray addObject:member];
            }
            
        }
    }
    [rs close];
    return searchArray;
}
//根据roomId查找群组
- (JXUserObject *)groupForRoomId:(NSString *)roomId{
    NSString *sql = [NSString stringWithFormat:@"select * from friend where roomFlag=1 and roomId='%@'",roomId];
    return [self doFetchOneGroup:sql];
}
- (JXUserObject *)doFetchOneGroup:(NSString*)sql
{   JXUserObject *group = [[JXUserObject alloc] init];
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [super checkTableCreatedInDb:db];
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXUserObject *user=[[JXUserObject alloc] init];
        [super userFromDataset:user rs:rs];
        group = user;
    }
    [rs close];
    return group;
}
//获取公众号
- (NSMutableArray *)searchPublic:(NSString *)searchtext limit:(BOOL )limit{
    NSString *sql;
    if (limit) {
        sql = [NSString stringWithFormat:@"select * from friend where userType=2 and userNickname like '%%%@%%' order by timeCreate limit 4",searchtext];
    }else{
        sql = [NSString stringWithFormat:@"select * from friend where userType=2 and userNickname like '%%%@%%' order by timeCreate",searchtext];
    }
    return [self doFetch:sql];
}
//获取查找的消息
- (NSMutableDictionary *)getAllContactsAndGroupHaveChatRecordWithText:(NSString *)text limit:(BOOL)limit{
    NSString *sql = [NSString stringWithFormat:@"select * from friend where content is not null and (((status=2 or status=0) and companyId=0 and roomFlag=0 and isDevice=0) or roomFlag = 1) order by timeSend desc"];
    NSMutableDictionary *allMsg = [NSMutableDictionary dictionary];
        
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [super checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    if (limit) {
        while ([rs next]) {
            NSString *userId=[rs stringForColumn:kUSER_ID];
            NSString *roomId=[rs stringForColumn:kROOM_ID];
            if (roomId) {
                NSMutableArray *array;
                array = [self getSearchMsgWithUserId:roomId withSearchText:text];
                if (array.count > 0) {
                    [allMsg setObject:array forKey:userId];
                }
            }else{
                NSMutableArray *array;
                array = [self getSearchMsgWithUserId:userId withSearchText:text];
                if (array.count > 0) {
                    [allMsg setObject:array forKey:userId];
                }
            }
            
            if (allMsg.allKeys.count >= 4) {
                break;
            }

        }
    }else{
        while ([rs next]) {
            NSString *userId=[rs stringForColumn:kUSER_ID];
            NSString *roomId=[rs stringForColumn:kROOM_ID];
            if (roomId) {
                NSMutableArray *array;
                array = [self getSearchMsgWithUserId:roomId withSearchText:text];
                if (array.count > 0) {
                    [allMsg setObject:array forKey:userId];
                }
            }else{
                NSMutableArray *array;
                array = [self getSearchMsgWithUserId:userId withSearchText:text];
                if (array.count > 0) {
                    [allMsg setObject:array forKey:userId];
                }
            }
            

        }
    }
    [rs close];
    
    return allMsg;
}

- (NSMutableArray *)getSearchMsgWithUserId:(NSString *)userId withSearchText:(NSString *)searchtext{
    NSString *sql;
#ifdef IS_MsgEncrypt
    sql = [NSString stringWithFormat:@"select * from msg_%@ where type=1 and isReadDel!=1 order by timeSend desc",userId];
#else
    sql = [NSString stringWithFormat:@"select * from msg_%@ where content like '%%%@%%' and type=1 and isReadDel!=1 order by timeSend desc",userId,searchtext];
#endif
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    FMResultSet *rs=[db executeQuery:sql];
#ifdef IS_MsgEncrypt
    while ([rs next]) {
        JXMessageObject *p=[[JXMessageObject alloc] init];
        [p fromRs:rs];
        NSString *content = p.content;
        NSMutableArray *contentArray = [NSMutableArray array];
        if ([content containsString:searchtext]) {
            [self getMessageRange:content :contentArray];
            NSMutableArray *stringArray = [NSMutableArray array];
            _num = 0;
            [self splicingString:contentArray inArray:stringArray];
            for (NSString *object in stringArray) {
                if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
                    
                }else{
                    if ([object localizedCaseInsensitiveContainsString:searchtext]) {
                        [array addObject:p];
                        break;
                    }
                }
            }
        }
    }
#else
    while ([rs next]) {
        JXMessageObject *p=[[JXMessageObject alloc] init];
        [p fromRs:rs];
        NSString *content = p.content;
        NSMutableArray *contentArray = [NSMutableArray array];
        [self getMessageRange:content :contentArray];
        NSMutableArray *stringArray = [NSMutableArray array];
        _num = 0;
        [self splicingString:contentArray inArray:stringArray];
        for (NSString *object in stringArray) {
            if ([object hasSuffix:@"]"]&&[object hasPrefix:@"["]) {
                
            }else{
                if ([object localizedCaseInsensitiveContainsString:searchtext]) {
                    [array addObject:p];
                    break;
                }
            }
        }
    }
#endif
    return array;
}

// 更新群组秘钥
- (BOOL)updateChatKeyGroup {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set chatKeyGroup=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.chatKeyGroup,self.userId];
    return worked;
}

// 更新加密type
- (BOOL)updateEncryptType {
    
#ifndef IS_MsgEncrypt
    if ([self.encryptType intValue] == 3 || [self.encryptType intValue] == 2) {
        self.encryptType = [NSNumber numberWithInt:1];
    }
#else
    if (![g_config.isOpenSecureChat boolValue]) {
        if ([self.encryptType intValue] == 3 || [self.encryptType intValue] == 2) {
            self.encryptType = [NSNumber numberWithInt:1];
        }
    }
#endif
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set encryptType=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.encryptType,self.userId];
    return worked;
}

// 更新丢失秘钥状态
- (BOOL)updateLostChatKeyGroup {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set isLostChatKeyGroup=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.isLostChatKeyGroup,self.userId];
    return worked;
}

//排除表情包
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



- (NSMutableArray *)fetchAllSearchRecordWithTable:(NSString *)tableName{
    FMDatabase *db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    NSString *str = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'record' TEXT NOT NULL)",tableName];
    BOOL success = [db executeUpdate:str];
    if (!success) {
        NSLog(@"创建搜索记录表失败");
    }
    NSString *allRecord = [NSString stringWithFormat:@"select * from '%@' order by ID",tableName];
    FMResultSet *rs = [db executeQuery:allRecord];
    NSMutableArray *array = [NSMutableArray array];
    while ([rs next]) {
        NSString *record = [rs stringForColumn:@"record"];
        if (record != nil && record != NULL) {
            [array addObject:record];
        }
    }
    return array;
}

- (BOOL)insertSearchRecord:(NSString *)searchRecord withTable:(NSString *)tableName{
    FMDatabase *db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    NSString *create = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'record' TEXT NOT NULL)",tableName];
    BOOL createSuccess = [db executeUpdate:create];
    if (!createSuccess) {
        NSLog(@"创建搜索记录表失败");
    }
    [self deleteOneSearchRecord:searchRecord withTable:tableName];
    NSString *record = [NSString stringWithFormat:@"INSERT INTO '%@' (record) VALUES (?)",tableName];
    return [db executeUpdate:record,searchRecord];

}

- (BOOL)deleteOneSearchRecord:(NSString *)searchRecord withTable:(NSString *)tableName{
    FMDatabase *db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    NSString *deleteOne = [NSString stringWithFormat:@"delete from '%@' where record = '%@'",tableName,searchRecord];
    return [db executeUpdate:deleteOne];
}

- (BOOL)deleteAllSearchRecordWithTable:(NSString *)tableName{
    FMDatabase *db = [[JXXMPP sharedInstance] openUserDb:MY_USER_ID];
    NSString *deleteAll = [NSString stringWithFormat:@"delete from '%@'",tableName];
    return [db executeUpdate:deleteAll];
}

@end
