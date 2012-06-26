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
#import "DrawAction.h"
#import "FriendManager.h"

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
                        friendGender:(NSString *)friendGender
                          latestFrom:(NSString *)latestFrom 
                            latestTo:(NSString *)latestTo 
                      latestDrawData:(NSData *)latestDrawData 
                          latestText:(NSString *)latestText 
                    latestCreateDate:(NSDate *)latestCreateDate 
                     totalNewMessage:(NSNumber *)totalNewMessage 
                        totalMessage:(NSNumber *)totalMessage
{
    //PPDebug(@"createMessageTotalWithUserId:%@ fid:%@ fn:%@ fa:%@ fg:%@ lfrom:%@ lto:%@ drawDataLen:%d ltext:%@ lcreDate:%@ new:%@ total:%@",userId,friendUserId,friendNickName,friendAvatar, friendGender, latestFrom, latestTo, [latestDrawData length], latestText, latestCreateDate, totalNewMessage, totalMessage);
    
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    MessageTotal *messageTotal = [self findMessageTotalByFriendUserId:friendUserId userId:userId];
    if (messageTotal) {
        [messageTotal setUserId:userId];
        [messageTotal setFriendUserId:friendUserId];
        [messageTotal setFriendNickName:friendNickName];
        [messageTotal setFriendAvatar:friendAvatar];
        [messageTotal setFriendGender:friendGender];
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
    [newMessageTotal setFriendGender:friendGender];
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
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in pbMessageStat.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [mutableArray addObject:drawAction];
        [drawAction release];
    }
    NSData *data = [ChatMessageUtil archiveDataFromDrawActionList:mutableArray];
    [mutableArray release];
    
    BOOL isMale = pbMessageStat.friendGender;
    NSString *genderString = nil;
    if (isMale) {
        genderString = MALE;
    }else {
        genderString = FEMALE;
    }
    
    return [self createMessageTotalWithUserId:pbMessageStat.userId 
                                 friendUserId:pbMessageStat.friendUserId
                               friendNickName:pbMessageStat.friendNickName
                                 friendAvatar:pbMessageStat.friendAvatar 
                                 friendGender:genderString
                                   latestFrom:pbMessageStat.from 
                                     latestTo:pbMessageStat.to 
                               latestDrawData:data
                                   latestText:pbMessageStat.text
                             latestCreateDate:[NSDate dateWithTimeIntervalSince1970:pbMessageStat.modifiedDate]
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
