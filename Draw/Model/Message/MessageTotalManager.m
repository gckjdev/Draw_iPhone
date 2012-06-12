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

@interface MessageTotal()
- (NSArray *)findAllMessageTotals;
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
    [self deleteMessageTotal:friendUserId];
    
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
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
    NSData* drawActionListData = [NSKeyedArchiver archivedDataWithRootObject:pbMessageStat.drawDataList];
    return [self createMessageTotalWithUserId:pbMessageStat.userId 
                                 friendUserId:pbMessageStat.friendUserId
                               friendNickName:pbMessageStat.friendNickName
                                 friendAvatar:pbMessageStat.friendAvatar
                                   latestFrom:pbMessageStat.from 
                                     latestTo:pbMessageStat.to 
                               latestDrawData:drawActionListData
                                   latestText:pbMessageStat.text
                             latestCreateDate:nil //待PBMessageSta增加此字段
                              totalNewMessage:[NSNumber numberWithInt:pbMessageStat.newMessageCount] 
                                 totalMessage:[NSNumber numberWithInt:pbMessageStat.totalMessageCount]];
}

@end
