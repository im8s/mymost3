//
//  JXAddressBook.m
//  shiku_im
//
//  Created by p on 2017/4/14.
//  Copyright © 2017年 Reese. All rights reserved.
//

#import "JXAddressBook.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "JSONKit.h"

#define kPhoneNumPath [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/phoneNum_%@.plist",MY_USER_ID]]

@interface JXAddressBook ()

@property (nonatomic, strong) NSArray *locPhoneNums;

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) NSDictionary *addressBookDic;

@end

@implementation JXAddressBook
static JXAddressBook *shared;

+(JXAddressBook*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared=[[JXAddressBook alloc]init];
    });
    return shared;
}

- (instancetype)init {
    if ([super init]) {
        _tableName = @"addressBook";
        
    }
    
    return self;
}

// 上传手机通讯录联系人
- (void) uploadAddressBookContacts {
    self.locPhoneNums = nil;
    // 判断通讯录是否授权
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    ABAddressBookRef addressBookRef = ABAddressBookCreate();
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        // 请求授权
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) { // 授权成功
                [shared upLoadAddressBook];
                NSLog(@"授权成功！");
            } else {  // 授权失败
                NSLog(@"授权失败！");
            }
        });
    }
    
    _addressBookRef = ABAddressBookCreate();
    // 注册通讯录回调
    ABAddressBookRegisterExternalChangeCallback(_addressBookRef, ContactsChangeCallback, nil);
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [self upLoadAddressBook];
    });
    
    if (addressBookRef) {
        CFRelease(addressBookRef);
    }
}

// 获取通讯录
- (NSDictionary *) getMyAddressBook {
    // 1. 判读授权
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    if (authorizationStatus != kABAuthorizationStatusAuthorized) {
        
        NSLog(@"没有授权");
        return nil;
    }
    
    //获取当前联系人的数组
    //    NSMutableArray *peopleArray = [[NSMutableArray alloc]init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    long count = CFArrayGetCount(arrayRef);
    for (int i = 0; i < count; i++) {
        //获取联系人对象的引用
        ABRecordRef people = CFArrayGetValueAtIndex(arrayRef, i);
        //        名
        NSString * oldFirstName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonFirstNameProperty);
        if (!oldFirstName) {
            oldFirstName = @"";
        }
        //        姓
        NSString * oldLastName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonLastNameProperty);
        if (!oldLastName) {
            oldLastName = @"";
        }
        
        NSString *name;
        NSString *lang = [g_default stringForKey:kLocalLanguage];
        
        if ([JXMyTools isChineseLanguage:lang]) {
            name = [NSString stringWithFormat:@"%@%@",oldLastName, oldFirstName];
        }else {
            name = [NSString stringWithFormat:@"%@ %@",oldFirstName, oldLastName];
        }
        
        ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
        for (NSInteger j=0; j<ABMultiValueGetCount(phones); j++) {
            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
            phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
            phone = [self phoneNumberFormat:phone];
            __block NSString *areaCode;
            dispatch_async(dispatch_get_main_queue(), ^{
                areaCode = g_myself.areaCode;
            });
            if (!areaCode) {
                areaCode = @"86";
            }
            
            if (phone.length > 0) {
                if ([[phone substringToIndex:1] isEqualToString:@"+"]) {
                    phone = [phone substringFromIndex:1];
                }
                
                if (phone.length > areaCode.length) {
                    if (![[phone substringToIndex:areaCode.length] isEqualToString:areaCode]) {
                        phone = [areaCode stringByAppendingString:phone];
                    }
                    if (phone) {
                        [dict setObject:name forKey:phone];
                    }
                }
            }
            
        }
        
        CFRelease(phones);
    }
    
    CFRelease(arrayRef);
    return [dict copy];
}
- (NSString *)phoneNumberFormat:(NSString *)phoneNum{
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[^\\d]" options:0 error:NULL];
    phoneNum = [regular stringByReplacingMatchesInString:phoneNum options:0 range:NSMakeRange(0, [phoneNum length]) withTemplate:@""];
    return phoneNum;
}


/*
 回调函数，实现自己的逻辑。
 */
void ContactsChangeCallback (ABAddressBookRef addressBook,
                             CFDictionaryRef info,
                             void *context){
    [shared upLoadAddressBook];
    
    NSLog(@"ContactsChangeCallback");
}

- (void) upLoadAddressBook {
    self.addressBookDic = [self getMyAddressBook];
    NSArray *addressPhoneNums = self.addressBookDic.allKeys;
    if (!addressPhoneNums || addressPhoneNums.count <= 0)
        return;
    
    if ([NSArray arrayWithContentsOfFile:kPhoneNumPath].count > 0) {
        
        self.locPhoneNums = [NSArray arrayWithContentsOfFile:kPhoneNumPath];
    }
    if (!self.locPhoneNums || self.locPhoneNums.count <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_server getAddressBookAll:self];
        });
        
    }
    NSArray *addArray = [NSArray array];
//    NSArray *deleArray = [NSArray array];
    
    // 谓词查询两个数组中不相同的
    // 添加
    NSPredicate * filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",self.locPhoneNums];
    addArray = [addressPhoneNums filteredArrayUsingPredicate:filterPredicate1];
    
    [addressPhoneNums writeToFile:kPhoneNumPath atomically:YES];
    if (addArray.count > 0) {
        NSMutableArray *uploadArr = [NSMutableArray array];
        for (NSInteger i = 0; i < addArray.count; i ++) {
            NSString *phone = addArray[i];
            NSString *name = self.addressBookDic[phone];
            NSDictionary *dic = @{
                                  @"toTelephone":phone,
                                  @"toRemarkName":name
                                  };
            [uploadArr addObject:dic];
//            if (i == 0) {
//                [uploadStr appendString:phone];
//            }else {
//                [uploadStr appendFormat:@",%@",phone];
//            }
        }
        SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
        NSString *uploadStr = [OderJsonwriter stringWithObject:uploadArr];
        // 更新电话号
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_server uploadAddressBookUploadStr:uploadStr toView:self];
        });
        
    }
}

- (void)didServerResultSucces:(JXConnection *)aDownload dict:(NSDictionary *)dict array:(NSArray *)array1{
    if ([aDownload.action isEqualToString:act_AddressBookGetAll]) {
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            JXAddressBook *addressBook = [[JXAddressBook alloc] init];
            addressBook.toUserId = [NSString stringWithFormat:@"%@",dict[@"toUserId"]];
            addressBook.toUserName = dict[@"toUserName"];
            addressBook.toTelephone = dict[@"toTelephone"];
            addressBook.telephone = dict[@"telephone"];
            addressBook.registerEd = dict[@"registerEd"];
            addressBook.registerTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"registerTime"] longLongValue]];
            addressBook.isRead = [NSNumber numberWithBool:1];
            addressBook.addressBookName = self.addressBookDic[addressBook.toTelephone];
            [addressBook insert];
        }
    }
    
    if ([aDownload.action isEqualToString:act_AddressBookUpload]) {
        for (NSInteger i = 0; i < array1.count; i ++) {
            NSDictionary *dict = array1[i];
            JXAddressBook *addressBook = [[JXAddressBook alloc] init];
            addressBook.toUserId = [NSString stringWithFormat:@"%@",dict[@"toUserId"]];
            addressBook.toUserName = dict[@"toUserName"];
            addressBook.toTelephone = dict[@"toTelephone"];
            addressBook.telephone = dict[@"telephone"];
            addressBook.registerEd = dict[@"registerEd"];
            addressBook.registerTime = [NSDate dateWithTimeIntervalSince1970:[dict[@"registerTime"] longLongValue]];
            addressBook.isRead = [NSNumber numberWithBool:0];
            addressBook.addressBookName = self.addressBookDic[addressBook.toTelephone];
            [addressBook insert];
            
            int status = [dict[@"status"] intValue];
            if (status == 1) {
                JXUserObject *user = [[JXUserObject alloc] init];
                user.remarkName = dict[@"toRemarkName"];
                user.userId = [NSString stringWithFormat:@"%@",dict[@"toUserId"]];
                if (dict[@"toRemarkName"]) {
                    user.userNickname = dict[@"toRemarkName"];
                }
                user.timeCreate = [NSDate dateWithTimeIntervalSince1970:[dict[@"registerTime"] longLongValue]];
                user.status = [NSNumber numberWithInt:2];
                user.roomFlag = [NSNumber numberWithInt:0];
                [user insertFriend];
            }
        }
        
        [g_notify postNotificationName:kRefreshAddressBookNotif object:nil];
    }
}

- (int)didServerResultFailed:(JXConnection *)aDownload dict:(NSDictionary *)dict{
    
    return hide_error;
}

- (int)didServerConnectError:(JXConnection *)aDownload error:(NSError *)error{
    
    return hide_error;
}


-(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE  IF NOT EXISTS '%@' ('toUserId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE ,'toUserName' VARCHAR,'addressBookName' VARCHAR,'registerEd' INTEGER,'registerTime' DATETIME,'toTelephone' VARCHAR,'telephone' VARCHAR,'isRead' INTEGER)",_tableName];
    
    BOOL worked = [db executeUpdate:createStr];
    return worked;
}

//数据库增删改查
-(BOOL)insert {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO '%@' ('toUserId','toUserName','addressBookName','registerEd','registerTime','toTelephone','telephone','isRead') VALUES (?,?,?,?,?,?,?,?)",_tableName];
    BOOL worked = [db executeUpdate:insertStr,self.toUserId,self.toUserName,self.addressBookName,self.registerEd,self.registerTime,self.toTelephone,self.telephone,self.isRead];
    
    return worked;
}

-(BOOL)delete {
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where toUserId=?",_tableName];
    BOOL worked=[db executeUpdate:sql,self.toUserId];
    return worked;
}

-(BOOL)update {
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set toUserName=?,addressBookName=?,registerEd=?,registerTime=?,toTelephone=?,telephone=?,isRead=? where toUserId=?",_tableName];
    BOOL worked = [db executeUpdate:sql,self.toUserName,self.addressBookName,self.registerEd,self.registerTime,self.toTelephone,self.telephone,self.isRead,self.toUserId];
    return worked;
}

// 获取所有手机联系人用户
- (NSMutableArray *)fetchAllAddressBook {
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@", _tableName]
    ;
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXAddressBook *task=[[JXAddressBook alloc] init];
        [self addressBookFromDataset:task rs:rs];
        [resultArr addObject:task];
    }
    
    return resultArr;
}



-(void)addressBookFromDataset:(JXAddressBook*)obj rs:(FMResultSet*)rs{
    obj.toUserId = [rs stringForColumn:@"toUserId"];
    obj.toUserName = [rs stringForColumn:@"toUserName"];
    obj.addressBookName = [rs stringForColumn:@"addressBookName"];
    obj.registerEd = [rs objectForColumnName:@"registerEd"];
    obj.registerTime = [rs dateForColumn:@"registerTime"];
    obj.toTelephone = [rs stringForColumn:@"toTelephone"];
    obj.telephone = [rs stringForColumn:@"telephone"];
    obj.isRead = [rs objectForColumnName:@"isRead"];
}

// 将未读消息设置为已读
- (BOOL)updateUnread {
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set isRead = ? where isRead = 0", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    BOOL worked = [db executeUpdate:sql,[NSNumber numberWithInt:1]];
    
    return worked;
}
// 查询未读消息
-(NSMutableArray *)doFetchUnread {
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where isRead = 0", _tableName];
    
    NSString* myUserId = MY_USER_ID;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    [self checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:sql];
    while ([rs next]) {
        JXAddressBook *obj=[[JXAddressBook alloc] init];
        [self addressBookFromDataset:obj rs:rs];
        [resultArr addObject:obj];
    }

    return resultArr;
}

-(void)dealloc{
    // 移除通讯录回调
    ABAddressBookUnregisterExternalChangeCallback(_addressBookRef, ContactsChangeCallback, nil);
    //    [_location release];
    //    [_arrayConnections release];
    //    [_dictWaitViews release];
    //    [myself release];
    //
    //    [super dealloc];
}

@end
