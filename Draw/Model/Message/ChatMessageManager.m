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
#import "ChatMessageUtil.h"
#import "LogUtil.h"

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
    //PPDebug(@"createMessageWithMessageId:%@ from:%@ to:%@ drawDataLen:%d createDate:%@ text:%@ status:%@",messageId,from,to,[drawData length], createDate, text, status);
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    
    ChatMessage *chatMessage = [self findMessageByMessageId:messageId];
    if (chatMessage) {
        [chatMessage :messageId];
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

- (BOOL)createMessageWithMessageId:(NSString *)messageId 
                              from:(NSString *)from 
                                to:(NSString *)to 
                          drawData:(NSData *)drawData 
                        createDate:(NSDate *)createDate 
                              text:(NSString *)text 
                            status:(NSNumber *)status 
                              type:(NSNumber *)type  
                          latitude:(NSNumber *)latitude 
                         longitude:(NSNumber *)longitude 
                       replyResult:(NSNumber *)replyResult
                      reqMessageId:(NSString *)reqMessageId
{
    //PPDebug(@"createMessageWithMessageId:%@ from:%@ to:%@ drawDataLen:%d createDate:%@ text:%@ status:%@",messageId,from,to,[drawData length], createDate, text, status);
    
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
        [chatMessage setType:type];
        [chatMessage setLatitude:latitude];
        [chatMessage setLongitude:longitude];
        [chatMessage setReplyResult:replyResult];
        [chatMessage setReqMessageId:reqMessageId];        
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
    [newMessage setType:type];
    [newMessage setLatitude:latitude];
    [newMessage setLongitude:longitude];
    [newMessage setReplyResult:replyResult];
    [newMessage setReqMessageId:reqMessageId]; 
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

- (BOOL)createByPBMessage:(PBMessage *)pbMessage
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in pbMessage.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [mutableArray addObject:drawAction];
        [drawAction release];
    }
    NSData *data = [ChatMessageUtil archiveDataFromDrawActionList:mutableArray];
    [mutableArray release];
    
//    return  [self createMessageWithMessageId:pbMessage.messageId 
//                                        from:pbMessage.from 
//                                          to:pbMessage.to 
//                                    drawData:data
//                                  createDate:[NSDate dateWithTimeIntervalSince1970:pbMessage.createDate]
//                                        text:pbMessage.text
//                                      status:[NSNumber numberWithInt:pbMessage.status]];
    
    
    return  [self createMessageWithMessageId:pbMessage.messageId
                                        from:pbMessage.from
                                          to:pbMessage.to
                                    drawData:data
                                  createDate:[NSDate dateWithTimeIntervalSince1970:pbMessage.createDate]
                                        text:pbMessage.text
                                      status:[NSNumber numberWithInt:pbMessage.status]
                                        type:[NSNumber numberWithInt:pbMessage.type]
                                    latitude:[NSNumber numberWithDouble:pbMessage.latitude]
                                   longitude:[NSNumber numberWithDouble:pbMessage.longitude]
                                 replyResult:[NSNumber numberWithInt:pbMessage.replyResult]
                                reqMessageId:pbMessage.reqMessageId];
}


- (BOOL)deleteMessageByMessageId:(NSString *)messageId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    ChatMessage *chatMessage = [self findMessageByMessageId:messageId];
    [dataManager del:chatMessage];
    return [dataManager save];
}

- (BOOL)deleteMessagesByFriendUserId:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    NSArray *list = [self findMessagesByFriendUserId:friendUserId];
    for (ChatMessage *chatMessage in list) {
        [dataManager del:chatMessage];
    }
    return [dataManager save];
}

@end
