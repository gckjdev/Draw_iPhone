//
//  PPMessageManager.m
//  Draw
//
//  Created by  on 12-10-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPMessageManager.h"
//#import "Draw.pb.h"
#import "GameMessage.pb.h"
#import "PPMessage.h"
#import "MessageStat.h"
//#import "FileUtil.h"
#import "StorageManager.h"

@implementation PPMessageManager
#define MESSAGE_DIR @"message"
#define MESSAGESTAT_DIR @"message_stat"
#define MESSAGESTAT_KEY @"message_stat.dat"


#define MESSAGE_MAX_COUNT 20

+ (StorageManager *)messageStorageManager
{
    StorageManager * manager = [StorageManager defaultManager];
    [manager setStorageType:StorageTypeCache];
    [manager setDirectoryName:MESSAGE_DIR];
    return manager;
}

+ (StorageManager *)messageStatStorageManager
{
    StorageManager * manager = [StorageManager defaultManager];
    [manager setStorageType:StorageTypeCache];
    [manager setDirectoryName:MESSAGESTAT_DIR];
    return manager;
}


+ (NSArray *)parseMessageList:(NSArray *)pbMessageList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:pbMessageList.count];
    for (PBMessage *pbMesage in pbMessageList) {
        PPMessage *ppm = [PPMessage messageWithPBMessage:pbMesage];
        [list addObject:ppm];
    }
    return list;
}
+ (NSArray *)parseMessageStatList:(NSArray *)pbMessageStatList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:pbMessageStatList.count];
    for (PBMessageStat *pbMesageStat in pbMessageStatList) {
        MessageStat *ms = [[MessageStat alloc] initWithPBMessageStat:pbMesageStat];
        [list addObject:ms];
        [ms release];
    }
    return list;    
}

+ (NSArray *)subArrayWithArray:(NSArray *)array
                     maxLength:(NSInteger)maxLength 
                     isReverse:(BOOL)isReverse
{
    NSInteger count = [array count];
    NSInteger len = MIN(count, maxLength);
    NSInteger loc = 0;
    if (isReverse) {
        loc = count - len;
    }
    NSRange range = NSMakeRange(loc, len);
    PPDebug(@"<subArrayWithArray> range = %@", NSStringFromRange(range));
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    return [array objectsAtIndexes:indexSet];
}

#pragma mark message list storage.

+ (NSData *)dataFromMessageList:(NSArray *)messageList
{
    if ([messageList count] == 0) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (PPMessage *message in messageList) {
        PBMessage *pbm = [message toPBMessage];
        [array addObject:pbm];
    }
    DataQueryResponse_Builder *builder = [[[DataQueryResponse_Builder alloc] init] autorelease];
    [builder setResultCode:0];
    [builder addAllMessage:array];
    return [[builder build] data];
}

+ (NSArray *)messageListFromData:(NSData *)data
{
    DataQueryResponse* dqr = nil;
    @try {
       dqr = [DataQueryResponse parseFromData:data];
        NSArray *mList = [dqr messageList];
        return [PPMessageManager parseMessageList:mList];

    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        dqr = nil;
    }
}

#define MESSAGE_KEY1(x) [NSString stringWithFormat:@"%@_v1",x]

+ (BOOL)saveFriend:(NSString *)friendId messageList:(NSArray *)messageList
{
    NSArray *list = [PPMessageManager subArrayWithArray:messageList
                                              maxLength:MESSAGE_MAX_COUNT
                                              isReverse:YES];
    for (PPMessage *message in list) {
        PPDebug(@"message type:%d", message.messageType);
    }
    
    StorageManager *manager = [PPMessageManager messageStorageManager];
    NSData *data = [PPMessageManager dataFromMessageList:list];
//    return [manager saveObject:list forKey:MESSAGE_KEY1(friendId)];
    return [manager saveData:data forKey:MESSAGE_KEY1(friendId)];
}
+ (NSArray *)messageListForFriendId:(NSString *)friendId
{
    StorageManager *manager = [PPMessageManager messageStorageManager];
    NSData *data = [manager dataForKey:MESSAGE_KEY1(friendId)];
    NSArray *list = [PPMessageManager messageListFromData:data];
    for (PPMessage *message in list) {
        PPDebug(@"message type:%d", message.messageType);
    }
    
    return list;
}

+ (BOOL)deleteLocalFriendMessageList:(NSString *)friendId
{
    StorageManager *manager = [PPMessageManager messageStorageManager];
    return [manager removeDataForKey:friendId];
}



#pragma mark message stat storage


+ (BOOL)saveMessageStatList:(NSArray *)messageStatList
{
    if (messageStatList == nil) {
        return YES;
    }
    
    NSArray *list = [PPMessageManager subArrayWithArray:messageStatList
                                            maxLength:MESSAGE_STAT_MAX_COUNT
                                            isReverse:NO];
    
    StorageManager *manager = [PPMessageManager messageStatStorageManager];
    return [manager saveObject:list forKey:MESSAGESTAT_KEY];
}
+ (NSArray *)localMessageStatList
{
    StorageManager *manager = [PPMessageManager messageStatStorageManager];
    return [manager objectForKey:MESSAGESTAT_KEY];
}

@end
