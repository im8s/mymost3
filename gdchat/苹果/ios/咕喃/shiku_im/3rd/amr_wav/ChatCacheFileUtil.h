//
//  ChatCacheFileUtil.h
//  NewMC
//
//  Created by 话语科技 on 12-10-25.
//
//

#import <Foundation/Foundation.h>

@interface ChatCacheFileUtil : NSObject

+ (ChatCacheFileUtil*)sharedInstance;

- (NSString*)userDocPath;
- (BOOL) deleteWithContentPath:(NSString *)thePath;
- (NSString*)chatCachePathWithFriendId:(NSString*)theFriendId andType:(NSInteger)theType;
- (void)deleteFriendChatCacheWithFriendId:(NSString*)theFriendId;
- (void)deleteAllFriendChatDoc;
@end
