//
//  MessageTotalManager.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "MessageTotalManager.h"
#import "MessageTotal.h"
#import "CoreDataUtil.h"
#import "GameBasic.pb.h"
#import "LogUtil.h"
#import "UserManager.h"
#import "ChatMessageUtil.h"

@interface MessageTotal()

- (BOOL)deleteMessageTotal:(NSString *)friendUserId;
- (MessageTotal *)findMessageTotalByFriendUserId:(NSString *)friendUserId userId:(NSString *)userId;

@end


@implementation MessageTotalManager

static MessageTotalManager *_messageTotalManager = nil;

+ (MessageTotalManager *)defaultManager
{
    if (_messageTotalManager == nil) {
        _messageTotalManager = [[MessageTotalManager alloc] init];
    }
    return _messageTotalManager;
}

- (BOOL)createMessageTotalWithUserId:(NSString *)userId 
                        friendUserId:(NSString *)friendUserId 
                      friendNickName:(NSString *)friendNickName 
                        friendAvatar:(NSString *)friendAvatar 
                          latestFrom:(NSString *)latestFrom 
                            latestTo:(NSString *)latestTo 
                      latestDrawData:(NSData *)latestDrawData 
                          latestText:(NSString *)latestText 
                    latestCreateDate:(NSDate *)latestCreateDate 
                     totalNewMessage:(NSNumber *)totalNewMessage 
                        totalMessage:(NSNumber *)totalMessage
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    MessageTotal *messageTotal = [self findMessageTotalByFriendUserId:friendUserId userId:userId];
    if (messageTotal) {
        [messageTotal setUserId:userId];
        [messageTotal setFriendUserId:friendUserId];
        [messageTotal setFriendNickName:friendNickName];
        [messageTotal setFriendAvatar:friendAvatar];
        [messageTotal setLatestFrom:latestFrom];
        [messageTotal setLatestTo:latestTo];
        [messageTotal setLatestDrawData:latestDrawData];
        [messageTotal setLatestText:latestText];
        [messageTotal setLatestCreateDate:latestCreateDate];
        [messageTotal setTotalNewMessage:totalNewMessage];
        [messageTotal setTotalMessage:totalMessage];
        return [dataManager save];
    }
    
    MessageTotal *newMessageTotal = [dataManager insert:@"MessageTotal"];
    [newMessageTotal setUserId:userId];
    [newMessageTotal setFriendUserId:friendUserId];
    [newMessageTotal setFriendNickName:friendNickName];
    [newMessageTotal setFriendAvatar:friendAvatar];
    [newMessageTotal setLatestFrom:latestFrom];
    [newMessageTotal setLatestTo:latestTo];
    [newMessageTotal setLatestDrawData:latestDrawData];
    [newMessageTotal setLatestText:latestText];
    [newMessageTotal setLatestCreateDate:latestCreateDate];
    [newMessageTotal setTotalNewMessage:totalNewMessage];
    [newMessageTotal setTotalMessage:totalMessage];
    
    return [dataManager save];
}

- (NSArray *)findAllMessageTotals
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllMessageTotals" sortBy:@"latestCreateDate" ascending:NO];
}


- (MessageTotal *)findMessageTotalByFriendUserId:(NSString *)friendUserId userId:(NSString *)userId
{
    //TEST
    NSArray *testArray = [self findAllMessageTotals];
    for (MessageTotal *message in testArray) {
        PPDebug(@"%@ %@",message.friendUserId, message.userId);
    }
    PPDebug(@"%@",[[UserManager defaultManager] userId]);
    
    
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    NSArray *keys = [NSArray arrayWithObjects:@"USER_ID", @"FRIEND_USER_ID", nil];
    NSArray *values = [NSArray arrayWithObjects:userId, friendUserId, nil];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    NSArray *array = [dataManager execute:@"findMessageTotalByFriendUserId" keyValues:dic sortBy:@"latestCreateDate" ascending:NO];
    if ([array count] > 0) {
        return (MessageTotal *)[array objectAtIndex:0];
    }else {
        return nil;
    }
}

- (BOOL)deleteMessageTotal:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    NSArray *array = [self findAllMessageTotals];
    for (MessageTotal *messageTotal in array) {
        if ([messageTotal.friendUserId isEqualToString:friendUserId]) {
            [dataManager del:messageTotal];
            break;
        }
    }
    return [dataManager save];
}

- (BOOL)createByPBMessageStat:(PBMessageStat *)pbMessageStat
{
    NSData* drawActionListData = [ChatMessageUtil archiveDataFromDrawActionList:pbMessageStat.drawDataList];
    return [self createMessageTotalWithUserId:pbMessageStat.userId 
                                 friendUserId:pbMessageStat.friendUserId
                               friendNickName:pbMessageStat.friendNickName
                                 friendAvatar:pbMessageStat.friendAvatar
                                   latestFrom:pbMessageStat.from 
                                     latestTo:pbMessageStat.to 
                               latestDrawData:drawActionListData
                                   latestText:pbMessageStat.text
                             latestCreateDate:[NSDate dateWithTimeIntervalSince1970:pbMessageStat.createDate]
                              totalNewMessage:[NSNumber numberWithInt:pbMessageStat.newMessageCount] 
                                 totalMessage:[NSNumber numberWithInt:pbMessageStat.totalMessageCount]];
}

- (BOOL)readNewMessageWithFriendUserId:(NSString *)friendUserId userId:(NSString *)userId
{
    MessageTotal *messageTotal = [self findMessageTotalByFriendUserId:friendUserId userId:userId];
    if (messageTotal == nil) {
        return NO;
    }else {
        [messageTotal setTotalNewMessage:[NSNumber numberWithInt:0]];
        return [[CoreDataManager defaultManager] save];
    }
}

@end
