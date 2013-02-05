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

@interface PPMessageManager : NSObject

+ (NSArray *)parseMessageList:(NSArray *)pbMessageList;
+ (NSArray *)parseMessageStatList:(NSArray *)pbMessageStatList;

+ (BOOL)saveFriend:(NSString *)friendId messageList:(NSArray *)messageList;
+ (NSArray *)messageListForFriendId:(NSString *)friendId;

+ (BOOL)saveMessageStatList:(NSArray *)messageStatList;
+ (NSArray *)localMessageStatList;

+ (BOOL)deleteLocalFriendMessageList:(NSString *)friendId;

@end
