//
//  PPMessageManager.h
//  Draw
//
//  Created by  on 12-10-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigManager.h"

#define MESSAGE_STAT_MAX_COUNT ([ConfigManager getMessageStatMaxCount])

@class PPMessage;

@interface PPMessageManager : NSObject

@property (nonatomic, retain) NSMutableDictionary* friendMessageDict;

+ (NSArray *)parseMessageList:(NSArray *)pbMessageList;
+ (NSArray *)parseMessageListAndReverse:(NSArray *)pbMessageList;
+ (NSArray *)parseMessageStatList:(NSArray *)pbMessageStatList;

+ (BOOL)saveFriend:(NSString *)friendId messageList:(NSArray *)messageList;
+ (NSArray *)messageListForFriendId:(NSString *)friendId;

+ (BOOL)saveMessageStatList:(NSArray *)messageStatList;
+ (NSArray *)localMessageStatList;

+ (BOOL)deleteLocalFriendMessageList:(NSString *)friendId;

+ (BOOL)saveImageToLocal:(UIImage *)image key:(NSString *)key;
+ (NSString *)path:(NSString *)key;
+ (BOOL)removeLocalImage:(NSString *)key;

// add by Benson for new message model, message stat not included since it's stable and looks OK
+ (PPMessageManager*)defaultManager;
- (NSArray*)getMessageList:(NSString*)friendUserId;
- (void)deleteMessage:(PPMessage*)message;
- (void)addMessage:(PPMessage*)message;
- (void)addOrUpdateMessage:(PPMessage*)message;
- (void)addMessageListHead:(NSArray*)messageList friendUserId:(NSString*)friendUserId;
- (void)addMessageListTail:(NSArray*)messageList friendUserId:(NSString*)friendUserId;
- (void)addMessageList:(NSArray*)messageList friendUserId:(NSString*)friendUserId offsetMessageId:(NSString*)offsetMessageId;
- (void)removeAllMessages;
- (void)clearMemoryCache;
- (void)save:(NSArray*)messageList friendUserId:(NSString*)friendUserId;
- (void)updateMessage:(PPMessage*)message friendUserId:(NSString*)friendUserId;

@end
