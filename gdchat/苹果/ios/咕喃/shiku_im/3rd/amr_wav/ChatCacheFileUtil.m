//
//  ChatCacheFileUtil.m
//  NewMC
//
//  Created by 话语科技 on 12-10-25.
//
//

#import "ChatCacheFileUtil.h"
NSString *const myUSERID=@"myUSERID";

@implementation ChatCacheFileUtil

static ChatCacheFileUtil *sharedInstance;

+ (ChatCacheFileUtil*)sharedInstance
{
    if (sharedInstance==nil) {
        sharedInstance = [[ChatCacheFileUtil alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    return [super init];
}

- (NSString*)userDocPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *userFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",MY_USER_ID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFolderPath]) {
        [fileManager createDirectoryAtPath:userFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return userFolderPath;
}

- (BOOL) deleteWithContentPath:(NSString *)thePath{
    NSError *error=nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:thePath]) {
        [fileManager removeItemAtPath:thePath error:&error];
    }
    if (error) {
        NSLog(@"删除文件时出现问题:%@",[error localizedDescription]);
        return NO;
    }
    return YES;
}

- (NSString*)chatCachePathWithFriendId:(NSString*)theFriendId andType:(NSInteger)theType
{
    NSString *userChatFolderPath = [[self userDocPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"chatLog/%@/",theFriendId]];
    switch (theType) {
        case 1:
            userChatFolderPath = [userChatFolderPath stringByAppendingPathComponent:@"voice/"];
            break;
        case 2:
            userChatFolderPath = [userChatFolderPath stringByAppendingPathComponent:@"image/"];
            break;
        default:
            break;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userChatFolderPath]) {
        [fileManager createDirectoryAtPath:userChatFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return userChatFolderPath;
}

- (void)deleteFriendChatCacheWithFriendId:(NSString*)theFriendId
{
    NSString *userChatFolderPath = [[self userDocPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"chatLog/%@/",theFriendId]];
    
    [[NSFileManager defaultManager] removeItemAtPath:userChatFolderPath error:nil];
}

- (void)deleteAllFriendChatDoc
{
    NSString *userChatFolderPath = [[self userDocPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"chatLog/"]];
    
    [[NSFileManager defaultManager] removeItemAtPath:userChatFolderPath error:nil];
    
}

@end
