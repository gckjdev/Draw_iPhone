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
#import "StringUtil.h"

static PPMessageManager* globalDefaultMessageManager;

@implementation PPMessageManager

#define MESSAGE_DIR @"message"
#define MESSAGESTAT_DIR @"message_stat"
#define MESSAGESTAT_KEY @"message_stat.dat"

+ (PPMessageManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalDefaultMessageManager = [[PPMessageManager alloc] init];
    });
    
    return globalDefaultMessageManager;
}


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

+ (NSArray *)parseMessageListAndReverse:(NSArray *)pbMessageList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:pbMessageList.count];
    
    if (pbMessageList.count > 0){
        for (int i=pbMessageList.count-1; i>=0; i--){
            PBMessage* pbMessage = [pbMessageList objectAtIndex:i];
            PPMessage *ppm = [PPMessage messageWithPBMessage:pbMessage];
            [list addObject:ppm];
        }
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
//    PPDebug(@"<subArrayWithArray> range = %@", NSStringFromRange(range));
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

    // save the whole list
//    NSArray *list = messageList;
    
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
    return list;
}

+ (BOOL)deleteLocalFriendMessageList:(NSString *)friendId
{
    StorageManager *manager = [PPMessageManager messageStorageManager];
    return [manager removeDataForKey:friendId];
}

+ (BOOL)saveImageToLocal:(UIImage *)image key:(NSString *)key
{
    StorageManager *manager = [PPMessageManager messageStorageManager];
    return [manager saveImage:image forKey:key];
}

+ (NSString *)path:(NSString *)key
{
    StorageManager *manager = [PPMessageManager messageStorageManager];
    return [manager pathWithKey:key];
}

+ (BOOL)removeLocalImage:(NSString *)key
{
    StorageManager *manager = [PPMessageManager messageStorageManager];
    return [manager removeDataForKey:key];
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

#pragma mark message new model

- (id)init
{
    self = [super init];
    _friendMessageDict = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc
{
    PPRelease(_friendMessageDict);
    [super dealloc];
}

- (NSArray*)getMessageList:(NSString*)friendUserId
{
    if (friendUserId == nil)
        return nil;
    
    NSArray* list = [_friendMessageDict objectForKey:friendUserId];
    if (list == nil){
        // try to load from local cache
        list = [PPMessageManager messageListForFriendId:friendUserId];
        
        // sort list
        list = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PPMessage* m1 = (PPMessage*)obj1;
            PPMessage* m2 = (PPMessage*)obj2;
            return [m1.createDate compare:m2.createDate];
        }];
        
        // make sure list is NOT null
        if (list == nil){
            list = [NSMutableArray array];
        }
        
        [_friendMessageDict setObject:list forKey:friendUserId];
    }
    
    return list;
}

- (void)deleteMessage:(PPMessage*)message
{
    NSString* friendId = [message friendId];
    if (friendId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendId];
    if (oldList == nil){
        return;
    }
    
    NSMutableArray* list = [NSMutableArray arrayWithArray:oldList];
    PPMessage* foundMessage = nil;
    for (PPMessage* m in list){
        if ([[m messageId] isEqualToString:[message messageId]]){
            foundMessage = message;
            break;
        }
    }
    
    if (foundMessage){
        [list removeObject:foundMessage];
    }
    
    [self save:list friendUserId:[message friendId]];
}

- (void)addMessage:(PPMessage*)message
{
    NSString* friendId = [message friendId];
    if (friendId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendId];
    NSMutableArray* list = nil;
    if (oldList != nil){
        list = [NSMutableArray arrayWithArray:oldList];
    }
    else{
        list = [NSMutableArray array];
    }
    
    [list addObject:message];
    [self save:list friendUserId:friendId];
}

- (void)addOrUpdateMessage:(PPMessage*)message
{
    NSString* friendId = [message friendId];
    if (friendId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendId];
    if (oldList == nil){
        return;
    }
    
    NSMutableArray* list = [NSMutableArray arrayWithArray:oldList];
    BOOL foundMessage = NO;
    int foundIndex = 0;
    for (PPMessage* m in list){
        if ([[m messageId] isEqualToString:[message messageId]]){
            foundMessage = YES;
            break;
        }
        
        foundIndex ++;
    }
    
    if (foundMessage){
        // update
        PPDebug(@"<addOrUpdateMessage> message(%@) updated", [message description]);
        [list replaceObjectAtIndex:foundIndex withObject:message];
    }
    else{
        // add
        PPDebug(@"<addOrUpdateMessage> message(%@) added", [message description]);
        [list addObject:message];
    }
    
    [self save:list friendUserId:[message friendId]];
}

- (void)updateMessage:(PPMessage*)message friendUserId:(NSString*)friendUserId
{
    NSString* friendId = [message friendId];
    if (friendId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendId];
    if (oldList == nil){
        return;
    }
    
    NSMutableArray* list = [NSMutableArray arrayWithArray:oldList];
    BOOL foundMessage = NO;
    int foundIndex = 0;
    for (PPMessage* m in list){
        if ([[m messageId] isEqualToString:[message messageId]]){
            foundMessage = YES;
            break;
        }
        
        foundIndex ++;
    }
    
    if (foundMessage){
        [list replaceObjectAtIndex:foundIndex withObject:message];
    }
    
    [self save:list friendUserId:[message friendId]];
}

- (BOOL)isMessageInList:(PPMessage*)message list:(NSArray*)list
{
    for (PPMessage* m in list){
        if ([message.messageId isEqualToString:m.messageId]){
            return YES;
        }
    }

    return NO;
}

- (NSArray*)listWithoutDuplicateMessage:(NSArray*)inputList oldList:(NSArray*)oldList
{
    NSMutableArray* array = [NSMutableArray array];
    
    for (PPMessage* message in inputList){
        if ([self isMessageInList:message list:oldList] == NO){
            [array addObject:message];
        }
        else{
            PPDebug(@"<listWithoutDuplicateMessage> message(%@, %@) already in old list", message.messageId, message.text);
        }
    }
    
    return array;
}

- (void)addMessageListHead:(NSArray*)messageList friendUserId:(NSString*)friendUserId
{
    if (messageList == nil || friendUserId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendUserId];
    NSMutableArray* list = nil;
    if (oldList != nil){
        list = [NSMutableArray arrayWithArray:oldList];
    }
    else{
        list = [NSMutableArray array];
    }
    
    NSArray* filterList = [self listWithoutDuplicateMessage:messageList oldList:oldList];
    
    list = [NSMutableArray arrayWithArray:filterList];
    [list addObjectsFromArray:oldList];
    
    [self save:list friendUserId:friendUserId];
}

- (void)addMessageListTail:(NSArray*)messageList friendUserId:(NSString*)friendUserId
{
    if (messageList == nil || friendUserId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendUserId];
    NSMutableArray* list = nil;
    if (oldList != nil){
        list = [NSMutableArray arrayWithArray:oldList];
    }
    else{
        list = [NSMutableArray array];
    }
    
    NSArray* filterList = [self listWithoutDuplicateMessage:messageList oldList:oldList];
    
    [list addObjectsFromArray:filterList];
    [self save:list friendUserId:friendUserId];
}

- (void)addMessageList:(NSArray*)messageList friendUserId:(NSString*)friendUserId offsetMessageId:(NSString*)offsetMessageId
{
    if (messageList == nil || friendUserId == nil)
        return;
    
    NSArray* oldList = [self getMessageList:friendUserId];
    NSMutableArray* list = nil;
    if (oldList != nil){
        list = [NSMutableArray arrayWithArray:oldList];
    }
    else{
        list = [NSMutableArray array];
    }
    
    NSArray* filterList = [self listWithoutDuplicateMessage:messageList oldList:oldList];
    
    int offsetIndex = -1;
    for (int i=list.count-1; i>=0; i--){
        PPMessage* indexMessage = [list objectAtIndex:i];
        if ([[indexMessage messageId] isEqualToString:offsetMessageId]){
            offsetIndex = i;
            break;
        }
    }
    
    if (offsetIndex == -1){
        // add into tail directly
        [list addObjectsFromArray:filterList];
    }
    else{
        NSRange range;
        range.location = offsetIndex;
        range.length = [filterList count];
        
        [list insertObjects:filterList atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    }
    
    [self save:list friendUserId:friendUserId];
}

- (void)removeAllMessages:(NSString*)friendUserId
{
    // TODO
}

- (void)save:(NSArray*)messageList friendUserId:(NSString*)friendUserId
{
    if (friendUserId == nil || messageList == nil){
        return;
    }

    [_friendMessageDict setObject:messageList forKey:friendUserId];
    [PPMessageManager saveFriend:friendUserId messageList:messageList];
}

- (void)clearMemoryCache
{
    [_friendMessageDict removeAllObjects];
}

@end
