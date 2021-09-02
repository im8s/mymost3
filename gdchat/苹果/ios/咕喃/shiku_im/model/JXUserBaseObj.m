//
//  JXUserBaseObj.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXUserBaseObj.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "JXMessageObject.h"

@implementation JXUserBaseObj
@synthesize userDescription,userHead,userId,userNickname,roomFlag,msgsNew,timeCreate,status,companyId,timeSend,type,content,isMySend,roomId;

static JXUserBaseObj *sharedUser;

+(JXUserBaseObj*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUser=[[JXUserBaseObj alloc]init];
    });
    return sharedUser;
}

-(id)init{
    self = [super init];
    if(self){
        _tableName = @"friend";
        self.userId = nil;
        self.userNickname = nil;
        self.remarkName = nil;
        self.describe = nil;
        self.role = nil;
        self.createUserId = nil;
        self.userDescription = nil;
        self.userHead = nil;
        self.roomId = nil;
        self.type = nil;
        self.content = nil;
        self.timeSend = nil;
        self.downloadTime = [NSDate dateWithTimeIntervalSince1970:0];
        self.timeCreate = nil;
        self.roomFlag = nil;
        self.category = nil;
        self.msgsNew = [NSNumber numberWithInt:0];
        self.status = [NSNumber numberWithInt:friend_status_none];
        self.userType = [NSNumber numberWithInt:0];
        self.companyId = [NSNumber numberWithInt:0];
        self.isMySend = nil;
        self.lastInput = nil;
        self.showRead = nil;
        self.showMember = nil;
        self.allowSendCard = nil;
        self.allowInviteFriend = nil;
        self.allowUploadFile = nil;
        self.allowConference = nil;
        self.allowSpeakCourse = nil;
        self.isNeedVerify = nil;
        self.talkTime = [NSNumber numberWithLong:0];
        self.topTime = nil;
        self.encryptType = nil;
        self.groupStatus = [NSNumber numberWithInt:0];
        self.isOnLine = nil;
        self.isOpenReadDel = nil;
        self.offlineNoPushMsg = nil;
        self.isAtMe = nil;
        self.isSendRecipt = nil;
        self.isDevice = [NSNumber numberWithInt:0];
        self.joinTime = nil;
        self.publicKeyDH = nil;
        self.publicKeyRSARoom = nil;
        self.chatKeyGroup = nil;
        self.isSecretGroup = [NSNumber numberWithInt:0];
        self.isLostChatKeyGroup = nil;
    }
    return self;
}

-(void)dealloc{
//    NSLog(@"JXUserBaseObj.dealloc");
    self.userId = nil;
    self.userNickname = nil;
    self.remarkName = nil;
    self.describe = nil;
    self.role = nil;
    self.createUserId = nil;
    self.userDescription = nil;
    self.userHead = nil;
    self.roomId = nil;
    self.type = nil;
    self.content = nil;
    self.timeSend = nil;
    self.downloadTime = nil;
    self.timeCreate = nil;
    self.roomFlag = nil;
    self.category = nil;
    self.msgsNew = nil;
    self.status = nil;
    self.userType = nil;
    self.companyId = nil;
    self.isMySend = nil;
    self.isOnLine = nil;
    self.isOpenReadDel = nil;
    self.offlineNoPushMsg = nil;
    self.isAtMe = nil;
    self.isSendRecipt = nil;
    self.isDevice = nil;
    self.joinTime = nil;
    self.publicKeyDH = nil;
    self.publicKeyRSARoom = nil;
    self.chatKeyGroup = nil;
    self.isSecretGroup = nil;
    self.isLostChatKeyGroup = nil;
//    [super dealloc];
}

-(BOOL)insert
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    if(!timeCreate){
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        self.timeCreate = [NSDate dateWithTimeIntervalSince1970:(time *1000 + g_server.timeDifference)/1000];
    }
    if(!timeSend)
        self.timeSend   = [NSDate date];
    if ([userId intValue] == [SHIKU_TRANSFER intValue]) {
        self.userNickname = Localized(@"JX_PaymentNo.");
        self.status = @(8);
        self.userType = [NSNumber numberWithInt:2];
    }
    self.downloadTime = [NSDate dateWithTimeIntervalSince1970:0];
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('userId','userNickname','remarkName','describe','role','createUserId','userDescription','userHead','roomFlag','category','timeCreate','newMsgs','status','userType','companyId','type','content','isMySend','roomId','timeSend','downloadTime','lastInput','showRead','showMember','allowSendCard','allowInviteFriend','allowUploadFile','allowConference','allowSpeakCourse','isNeedVerify','topTime','encryptType','groupStatus','isOnLine','isOpenReadDel','isSendRecipt','isDevice','chatRecordTimeOut','offlineNoPushMsg','isAtMe','talkTime','joinTime','publicKeyDH','publicKeyRSARoom','chatKeyGroup','isSecretGroup','isLostChatKeyGroup') VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",_tableName];
    BOOL worked = [db executeUpdate:insertStr,self.userId,self.userNickname,self.remarkName,self.describe,self.role,self.createUserId,self.userDescription,nil,self.roomFlag,self.category,self.timeCreate,self.msgsNew,self.status,self.userType,self.companyId,self.type,self.content,self.isMySend,self.roomId,self.timeSend,self.downloadTime,self.lastInput,self.showRead,self.showMember,self.allowSendCard,self.allowInviteFriend, self.allowUploadFile,self.allowConference,self.allowSpeakCourse,self.isNeedVerify,self.topTime,self.encryptType,self.groupStatus,self.isOnLine,self.isOpenReadDel,self.isSendRecipt,self.isDevice,self.chatRecordTimeOut,self.offlineNoPushMsg,self.isAtMe,self.talkTime,self.joinTime,self.publicKeyDH,self.publicKeyRSARoom,self.chatKeyGroup,self.isSecretGroup,self.isLostChatKeyGroup];
    //    FMDBQuickCheck(worked);
    
    if(!worked)
        worked = [self update];
    
    [g_App copyDbWithUserId:MY_USER_ID];
    return worked;
}

-(BOOL)update
{
    
    if (self.roomId.length > 0) {
        self.roomFlag= [NSNumber numberWithInt:1];
        self.companyId= [NSNumber numberWithInt:0];
        if (!self.status) {
            self.status= [NSNumber numberWithInt:2];
        }
    }
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    if(!timeSend)
        self.timeSend = [NSDate date];
    if (!self.companyId) {
        self.companyId = [NSNumber numberWithInt:0];
    }
    if ([userId intValue] == [SHIKU_TRANSFER intValue]) {
        self.userNickname = Localized(@"JX_PaymentNo.");
        self.status = @(8);
        self.userType = [NSNumber numberWithInt:2];
        
    }
    if ([self.topTime timeIntervalSince1970] > 0) {
        self.topTime = self.topTime;
    }else {
        self.topTime = nil;
    }
    NSString* sql = [NSString stringWithFormat:@"update %@ set userNickname=?,remarkName=?,describe=?,role=?,userDescription=?,userHead=?,roomFlag=?,type=?,companyId=?,content=?,timeCreate=?,status=?,userType=?,isMySend=?,newMsgs=?,timeSend=?,downloadTime=?,roomId=?,showRead=?,showMember=?,allowSendCard=?,allowInviteFriend=?,allowUploadFile=?,allowConference=?,allowSpeakCourse=?,isNeedVerify=?,topTime=?,encryptType=?,groupStatus=?,isOnLine=?,isOpenReadDel=?,isSendRecipt=?,isDevice=?,chatRecordTimeOut=?,offlineNoPushMsg=?,isAtMe=?,talkTime=?,joinTime=?,publicKeyDH=?,publicKeyRSARoom=?,chatKeyGroup=?,isSecretGroup=?,isLostChatKeyGroup=? where userId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.userNickname,self.remarkName,self.describe,self.role,self.userDescription,self.userHead,self.roomFlag,self.type,self.companyId,self.content,self.timeCreate,self.status,self.userType,self.isMySend,self.msgsNew,self.timeSend,self.downloadTime,self.roomId,self.showRead,self.showMember,self.allowSendCard,self.allowInviteFriend,self.allowUploadFile,self.allowConference,self.allowSpeakCourse,self.isNeedVerify,self.topTime,self.encryptType,self.groupStatus,self.isOnLine,self.isOpenReadDel,self.isSendRecipt,self.isDevice,self.chatRecordTimeOut,self.offlineNoPushMsg,self.isAtMe,self.talkTime,self.joinTime,self.publicKeyDH,self.publicKeyRSARoom,self.chatKeyGroup,self.isSecretGroup,self.isLostChatKeyGroup,self.userId];
    
    [g_App copyDbWithUserId:MY_USER_ID];

    return worked;
}

-(BOOL)haveTheUser
{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where userId=?",_tableName],self.userId];
    BOOL b = [rs next];
    [rs close];
    return b;
}

-(BOOL)delete
{
    if([self.userId intValue]<10100 && [self.userId length]<=15)
        return NO;
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where userId=?",_tableName];
    BOOL worked=[db executeUpdate:sql,self.userId];
    
    [g_App copyDbWithUserId:MY_USER_ID];
    
    return worked;
}

-(BOOL)reset{
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update friend set newMsgs=0,content=null,type=null,timeSend=null where userId=?"];
    BOOL worked=[db executeUpdate:sql,self.userId];
    return worked;
}

-(void)loadFromObject:(JXUserBaseObj*)user{
    self.userId=user.userId;
    self.userNickname=user.userNickname;
    self.remarkName=user.remarkName;
    self.describe=user.describe;
    self.role=user.role;
    self.createUserId = user.createUserId;
    self.userHead=user.userHead;
    self.userDescription=user.userDescription;
    self.roomFlag=user.roomFlag;
    self.category = user.category;
    self.timeCreate=user.timeCreate;
    self.msgsNew=user.msgsNew;
    self.status=user.status;
    self.userType=user.userType;
    self.companyId=user.companyId;
    self.type=user.type;
    self.content=user.content;
    self.timeSend=user.timeSend;
    self.downloadTime = user.downloadTime;
    self.chatRecordTimeOut = user.chatRecordTimeOut;
    self.talkTime = user.talkTime;
    self.isMySend=user.isMySend;
    self.roomId=user.roomId;
    self.showRead = user.showRead;
    self.showMember = user.showMember;
    self.allowSendCard = user.allowSendCard;
    self.allowInviteFriend = user.allowInviteFriend;
    self.allowUploadFile = user.allowUploadFile;
    self.allowConference = user.allowConference;
    self.allowSpeakCourse = user.allowSpeakCourse;
    self.isNeedVerify = user.isNeedVerify;
    self.groupStatus = user.groupStatus;
    self.isOnLine = user.isOnLine;
    self.isOpenReadDel = user.isOpenReadDel;
    self.offlineNoPushMsg = user.offlineNoPushMsg;
    self.isAtMe = user.isAtMe;
    self.isSendRecipt = user.isSendRecipt;
    self.isDevice = user.isDevice;
    self.joinTime = user.joinTime;
    self.publicKeyDH = user.publicKeyDH;
    self.publicKeyRSARoom = user.publicKeyRSARoom;
    self.chatKeyGroup = user.chatKeyGroup;
    self.isSecretGroup = user.isSecretGroup;
    self.isLostChatKeyGroup = user.isLostChatKeyGroup;
}

-(void)userFromDataset:(JXUserBaseObj*)obj rs:(FMResultSet*)rs{
    obj.userId=[rs stringForColumn:kUSER_ID];
    obj.roomId=[rs stringForColumn:kROOM_ID];
    obj.userNickname=[rs stringForColumn:kUSER_NICKNAME];
    obj.remarkName=[rs stringForColumn:kUSER_REMARKNAME];
    obj.describe=[rs stringForColumn:kUSER_DESCRIBE];
    obj.role=[rs objectForColumnName:kUSER_ROLE];
    obj.createUserId = [rs stringForColumn:kUSER_CREATEUSER_ID];
    obj.userHead=[rs stringForColumn:kUSER_USERHEAD];
    obj.userDescription=[rs stringForColumn:kUSER_DESCRIPTION];
    obj.roomFlag=[rs objectForColumnName:kUSER_ROOM_FLAG];
    obj.category = [rs objectForColumnName:kUSER_ROOM_CATEGORY];
    obj.timeCreate=[rs dateForColumn:kUSER_TIME_CREATE];
    obj.msgsNew=[rs objectForColumnName:kUSER_NEW_MSGS];
    obj.status=[rs objectForColumnName:kUSER_STATUS];
    obj.userType=[rs objectForColumnName:kUSER_USERTYPE];
    obj.companyId=[rs objectForColumnName:kUSER_COMPANY_ID];
    obj.type=[rs objectForColumnName:kUSER_TYPE];
    obj.content=[rs objectForColumnName:kUSER_CONTENT];
    obj.timeSend=[rs dateForColumn:kUSER_TIME_SEND];
    obj.downloadTime = [rs dateForColumn:kUSER_DownloadTime];
    obj.chatRecordTimeOut = [rs stringForColumn:kUSER_CHATRECORDTIMEOUT];
    obj.talkTime = [rs objectForColumnName:kUSER_TALKTIME];
    obj.isMySend=[rs objectForColumnName:kUSER_isMySend];
    obj.lastInput = [rs stringForColumn:kUSER_lastInput];
    obj.showRead = [rs objectForColumnName:kUSER_showRead];
    obj.showMember = [rs objectForColumnName:kUSER_showMember];
    obj.allowSendCard = [rs objectForColumnName:kUSER_allowSendCard];
    obj.allowInviteFriend = [rs objectForColumnName:kUSER_allowInviteFriend];
    obj.allowUploadFile = [rs objectForColumnName:kUSER_allowUploadFile];
    obj.allowConference = [rs objectForColumnName:kUSER_allowConference];
    obj.allowSpeakCourse = [rs objectForColumnName:kUSER_allowSpeakCourse];
    obj.isNeedVerify = [rs objectForColumnName:kUSER_isNeedVerify];
    obj.topTime = [rs dateForColumn:kUSER_TOPTIME];
    obj.encryptType = [rs objectForColumnName:kUSER_encryptType];
    obj.groupStatus = [rs objectForColumnName:kUSER_GROUPSTATUS];
    obj.isOnLine = [rs objectForColumnName:kUSER_isOnLine];
    obj.isOpenReadDel = [rs objectForColumnName:kUSER_isOpenReadDel];
    obj.offlineNoPushMsg = [rs objectForColumnName:kUSER_offlineNoPushMsg];
    obj.isAtMe = [rs objectForColumnName:kUSER_isAtMe];
    obj.isSendRecipt = [rs objectForColumnName:kUSER_isSendRecipt];
    obj.isDevice = [rs objectForColumnName:kUSER_isDevice];
    obj.joinTime = [rs dateForColumn:kUSER_joinTime];
    obj.publicKeyDH = [rs stringForColumn:kUSER_publicKeyDH];
    obj.publicKeyRSARoom = [rs stringForColumn:kUSER_publicKeyRSARoom];
    obj.chatKeyGroup = [rs stringForColumn:kUSER_chatKeyGroup];
    obj.isSecretGroup = [rs objectForColumnName:kUSER_isSecretGroup];
    obj.isLostChatKeyGroup = [rs objectForColumnName:kUSER_isLostChatKeyGroup];
}

-(void)userFromDictionary:(JXUserBaseObj*)obj dict:(NSDictionary*)aDic
{
    if([aDic count]<=0)
        return;
    if([aDic objectForKey:kUSER_ID] == nil)
        return;
    obj.userId = [aDic objectForKey:kUSER_ID];
    obj.roomId = [aDic objectForKey:kROOM_ID];
    obj.userHead = [aDic objectForKey:kUSER_USERHEAD];
    obj.userDescription = [aDic objectForKey:kUSER_DESCRIPTION];
    obj.userNickname = [aDic objectForKey:kUSER_NICKNAME];
    obj.remarkName = [aDic objectForKey:kUSER_REMARKNAME];
    obj.describe = [aDic objectForKey:kUSER_DESCRIBE];
    obj.role = [aDic objectForKey:kUSER_ROLE];
    obj.createUserId = [aDic objectForKey:kUSER_CREATEUSER_ID];
    obj.msgsNew = [aDic objectForKey:kUSER_NEW_MSGS];
    obj.timeCreate = [aDic objectForKey:kUSER_TIME_CREATE];
    obj.roomFlag = [aDic objectForKey:kUSER_ROOM_FLAG];
    obj.category = [aDic objectForKey:kUSER_ROOM_CATEGORY];
    obj.status = [aDic objectForKey:kUSER_STATUS];
    obj.userType = [aDic objectForKey:kUSER_USERTYPE];
    obj.companyId = [aDic objectForKey:kUSER_COMPANY_ID];
    obj.type = [aDic objectForKey:kUSER_TYPE];
    obj.timeSend = [aDic objectForKey:kUSER_TIME_SEND];
    obj.downloadTime = [aDic objectForKey:kUSER_DownloadTime];
    obj.chatRecordTimeOut = [aDic objectForKey:kUSER_CHATRECORDTIMEOUT];
    obj.talkTime = [aDic objectForKey:kUSER_TALKTIME];
    obj.isMySend=[aDic objectForKey:kUSER_isMySend];
    obj.showRead=[aDic objectForKey:kUSER_showRead];
    obj.showMember = [aDic objectForKey:kUSER_showMember];
    obj.allowSendCard = [aDic objectForKey:kUSER_allowSendCard];
    obj.allowInviteFriend = [aDic objectForKey:kUSER_allowInviteFriend];
    obj.allowUploadFile = [aDic objectForKey:kUSER_allowUploadFile];
    obj.allowConference = [aDic objectForKey:kUSER_allowConference];
    obj.allowSpeakCourse = [aDic objectForKey:kUSER_allowSpeakCourse];
    obj.isNeedVerify = [aDic objectForKey:kUSER_isNeedVerify];
    obj.groupStatus=[aDic objectForKey:kUSER_GROUPSTATUS];
    obj.isOnLine = [aDic objectForKey:kUSER_isOnLine];
    obj.isOpenReadDel = [aDic objectForKey:kUSER_isOpenReadDel];
    obj.offlineNoPushMsg = [aDic objectForKey:kUSER_offlineNoPushMsg];
    obj.isAtMe = [aDic objectForKey:kUSER_isAtMe];
    obj.isSendRecipt = [aDic objectForKey:kUSER_isSendRecipt];
    obj.isDevice = [aDic objectForKey:kUSER_isDevice];
    obj.joinTime = [aDic objectForKey:kUSER_joinTime];
    obj.publicKeyDH = [aDic objectForKey:kUSER_publicKeyDH];
    obj.publicKeyRSARoom = [aDic objectForKey:kUSER_publicKeyRSARoom];
    obj.chatKeyGroup = [aDic objectForKey:kUSER_chatKeyGroup];
    obj.isSecretGroup = [aDic objectForKey:kUSER_isSecretGroup];
    obj.isLostChatKeyGroup = [aDic objectForKey:kUSER_isLostChatKeyGroup];
}

-(NSDictionary*)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if(userId)
        [dic setObject:userId forKey:kUSER_ID];
    if(userNickname)
        [dic setObject:userNickname forKey:kUSER_NICKNAME];
    if(self.remarkName)
        [dic setObject:self.remarkName forKey:kUSER_REMARKNAME];
    if (self.describe) {
        [dic setObject:self.describe forKey:kUSER_DESCRIBE];
    }
    if(self.role)
        [dic setObject:self.role forKey:kUSER_ROLE];
    if (self.createUserId) {
        [dic setObject:self.createUserId forKey:kUSER_CREATEUSER_ID];
    }
    if(userDescription)
        [dic setObject:userDescription forKey:kUSER_DESCRIPTION];
    if(userHead)
        [dic setObject:userHead forKey:kUSER_USERHEAD];
    if(roomFlag)
        [dic setObject:roomFlag forKey:kUSER_ROOM_FLAG];
    if (self.category) {
        [dic setObject:self.category forKey:kUSER_ROOM_CATEGORY];
    }
    if(msgsNew)
        [dic setObject:msgsNew forKey:kUSER_NEW_MSGS];
    if(timeSend)
        [dic setObject:timeSend forKey:kUSER_TIME_SEND];
    if (self.downloadTime) {
        [dic setObject:self.downloadTime forKey:kUSER_DownloadTime];
    }
    if (self.chatRecordTimeOut) {
        [dic setObject:self.chatRecordTimeOut forKey:kUSER_CHATRECORDTIMEOUT];
    }
    if (self.talkTime) {
        [dic setObject:self.talkTime forKey:kUSER_TALKTIME];
    }
    if(status)
        [dic setObject:status forKey:kUSER_STATUS];
    if(self.userType)
        [dic setObject:self.userType forKey:kUSER_USERTYPE];
    if(content)
        [dic setObject:content forKey:kUSER_CONTENT];
    if(type)
        [dic setObject:type forKey:kUSER_TYPE];
    if(timeCreate)
        [dic setObject:timeCreate forKey:kUSER_TIME_CREATE];
    if(isMySend)
        [dic setObject:isMySend forKey:kUSER_isMySend];
    if(roomId)
        [dic setObject:roomId forKey:kROOM_ID];
    if(self.showRead)
        [dic setObject:self.showRead forKey:kUSER_showRead];
    if(self.showMember)
        [dic setObject:self.showMember forKey:kUSER_showMember];
    if(self.allowSendCard)
        [dic setObject:self.allowSendCard forKey:kUSER_allowSendCard];
    if(self.allowInviteFriend)
        [dic setObject:self.allowInviteFriend forKey:kUSER_allowInviteFriend];
    if(self.allowUploadFile)
        [dic setObject:self.allowUploadFile forKey:kUSER_allowUploadFile];
    if(self.allowConference)
        [dic setObject:self.allowConference forKey:kUSER_allowConference];
    if(self.allowSpeakCourse)
        [dic setObject:self.allowSpeakCourse forKey:kUSER_allowSpeakCourse];
    if (self.isNeedVerify) {
        [dic setObject:self.isNeedVerify forKey:kUSER_isNeedVerify];
    }
    if(self.groupStatus)
        [dic setObject:self.groupStatus forKey:kUSER_GROUPSTATUS];
    if (self.isOnLine)
        [dic setObject:self.isOnLine forKey:kUSER_isOnLine];
    if (self.isOpenReadDel) {
        [dic setObject:self.isOpenReadDel forKey:kUSER_isOpenReadDel];
    }
    if (self.offlineNoPushMsg) {
        [dic setObject:self.offlineNoPushMsg forKey:kUSER_offlineNoPushMsg];
    }
    if (self.isAtMe) {
        [dic setObject:self.isAtMe forKey:kUSER_isAtMe];
    }
    if (self.isSendRecipt)
        [dic setObject:self.isSendRecipt forKey:kUSER_isSendRecipt];
    if (self.isDevice)
        [dic setObject:self.isDevice forKey:kUSER_isDevice];
    if (self.joinTime) {
        [dic setObject:self.joinTime forKey:kUSER_joinTime];
    }
    if (self.publicKeyDH) {
        [dic setObject:self.publicKeyDH forKey:kUSER_publicKeyDH];
    }
    if (self.publicKeyRSARoom) {
        [dic setObject:self.publicKeyRSARoom forKey:kUSER_publicKeyRSARoom];
    }
    if (self.chatKeyGroup) {
        [dic setObject:self.chatKeyGroup forKey:kUSER_chatKeyGroup];
    }
    if (self.isSecretGroup) {
        [dic setObject:self.isSecretGroup forKey:kUSER_isSecretGroup];
    }
    if (self.isLostChatKeyGroup) {
        [dic setObject:self.isLostChatKeyGroup forKey:kUSER_isLostChatKeyGroup];
    }
    
    return dic;
}

-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('userId' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE , 'userNickname' VARCHAR, 'remarkName' VARCHAR, 'describe' VARCHAR, 'role' VARCHAR,'createUserId' VARCHAR, 'userDescription' VARCHAR, 'userHead' VARCHAR,'roomFlag' INTEGER DEFAULT 0,'category' INTEGER DEFAULT 0, 'content' VARCHAR,'type' INTEGER,'timeSend' DATETIME,'downloadTime' DATETIME,'timeCreate' DATETIME,'newMsgs' INTEGER, 'status' INTEGER DEFAULT 1, 'userType' INTEGER DEFAULT 0, 'companyId' INTEGER, 'isMySend' INTEGER,'roomId' VARCHAR,'showRead' INTEGER,'showMember' INTEGER,'allowSendCard' INTEGER,'allowInviteFriend' INTEGER,'allowUploadFile' INTEGER,'allowConference' INTEGER,'allowSpeakCourse' INTEGER,'isNeedVerify' INTEGER,'lastInput' VARCHAR,'topTime' DATETIME,'encryptType' INTEGER,'groupStatus' INTEGER DEFAULT 0,'isOnLine' INTEGER,'isOpenReadDel' INTEGER,'isSendRecipt' INTEGER,'isDevice' INTEGER,'chatRecordTimeOut' VARCHAR,'offlineNoPushMsg' INTEGER,'isAtMe' INTEGER,'talkTime' VARCHAR,'joinTime' DATETIME,'publicKeyDH' VARCHAR,'publicKeyRSARoom' VARCHAR,'chatKeyGroup' VARCHAR,'isSecretGroup' INTEGER,'isLostChatKeyGroup' INTEGER)",_tableName];

    BOOL worked = [db executeUpdate:createStr];
    //    FMDBQuickCheck(worked);
    return worked;
}

-(NSString*)doSendMsg:(int)aType content:(NSString*)aContent{
    JXMessageObject* p = [[JXMessageObject alloc] init];
    p.fromUserId   = MY_USER_ID;
    p.fromUserName = MY_USER_NAME;
    p.toUserId     = self.userId;
    p.toUserName   = self.userNickname;
    p.content      = aContent;
    p.fileName     = self.userHead;
    p.type         = [NSNumber numberWithInt:aType];
    p.timeSend     = [NSDate date];
    p.isSend       = [NSNumber numberWithInt:transfer_status_ing];
    [p setMsgId];
//    [p insert:nil];
    [[JXXMPP sharedInstance] sendMessage:p roomName:nil];//发送消息
    return p.messageId;
}

-(void)notifyDelFriend{
    [g_notify postNotificationName:kDeleteUserNotifaction object:self userInfo:nil];
}

-(void)notifyNewFriend{
    [g_notify postNotificationName:kXMPPNewFriendNotifaction object:self userInfo:nil];
}

@end
