//
//  ChatMessageManager.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatMessageManager.h"
#import "ChatMessage.h"
#import "CoreDataUtil.h"
#import "GameBasic.pb.h"
#import "DrawAction.h"
#import "UserManager.h"

@interface ChatMessageManager ()

- (ChatMessage *)findMessageByMessageId:(NSString *)messageId;

@end


@implementation ChatMessageManager

static ChatMessageManager *_chatMessageManager = nil;

+ (ChatMessageManager *)defaultManager
{
    if (_chatMessageManager == nil) {
        _chatMessageManager = [[ChatMessageManager alloc] init];
    }
    return _chatMessageManager;
}


- (BOOL)createMessageWithMessageId:(NSString *)messageId 
                              from:(NSString *)from 
                                to:(NSString *)to 
                          drawData:(NSData *)drawData 
                        createDate:(NSDate *)createDate 
                              text:(NSString *)text 
                            status:(NSNumber *)status
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    
    ChatMessage *chatMessage = [self findMessageByMessageId:messageId];
    if (chatMessage) {
        [chatMessage setMessageId:messageId];
        [chatMessage setFrom:from];
        [chatMessage setTo:to];
        [chatMessage setDrawData:drawData];
        [chatMessage setCreateDate:createDate];
        [chatMessage setText:text];
        [chatMessage setStatus:status];
        return [dataManager save];
    }
    
    ChatMessage *newMessage = [dataManager insert:@"ChatMessage"];
    [newMessage setMessageId:messageId];
    [newMessage setFrom:from];
    [newMessage setTo:to];
    [newMessage setDrawData:drawData];
    [newMessage setCreateDate:createDate];
    [newMessage setText:text];
    [newMessage setStatus:status];
    return [dataManager save];
}


- (NSArray *)findMessagesByFriendUserId:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findMessagesByFriend" forKey:@"FRIEND_USER_ID" value:friendUserId sortBy:@"createDate" ascending:YES];
}


- (ChatMessage *)findMessageByMessageId:(NSString *)messageId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return  (ChatMessage *)[dataManager execute:@"findMessageByMessageId" forKey:@"MESSAGE_ID" value:messageId];
}

//压缩
- (NSData *)archiveDataFromDrawActionList:(NSArray *)aDrawActionList
{    
    NSData* reData = [NSKeyedArchiver archivedDataWithRootObject:aDrawActionList];
    return reData;
}

//解压
- (NSArray *)unarchiveDataToDrawActionList:(NSData *)aData
{
    NSData* temp = [NSKeyedUnarchiver unarchiveObjectWithData:aData];
    NSArray* drawDataList = (NSArray*)temp;
    return drawDataList;
}


- (BOOL)createByPBMessage:(PBMessage *)pbMessage
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in pbMessage.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [mutableArray addObject:drawAction];
        [drawAction release];
    }
    NSData *data = [self archiveDataFromDrawActionList:mutableArray];
    [mutableArray release];
    
    return  [self createMessageWithMessageId:pbMessage.messageId 
                                        from:pbMessage.from 
                                          to:pbMessage.to 
                                    drawData:data
                                  createDate:[NSDate dateWithTimeIntervalSince1970:pbMessage.createDate]
                                        text:pbMessage.text
                                      status:[NSNumber numberWithInt:pbMessage.status]];
}


@end
