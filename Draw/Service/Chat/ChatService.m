//
//  ChatService.m
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "PPNetworkRequest.h"
#import "LogUtil.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
//#import "ChatMessageManager.h"
//#import "MessageTotalManager.h"
#import "DrawDataService.h"
//#import "ChatMessageUtil.h"
//#import "ChatMessage.h"

#import "CanvasRect.h"
#import "ConfigManager.h"

#import "PPMessage.h"
#import "PPMessageManager.h"
#import "MessageStat.h"
#import "DrawUtils.h"

static ChatService *_chatService = nil;

@implementation ChatService

+ (ChatService*)defaultService
{
    if (_chatService == nil) {
        _chatService = [[ChatService alloc] init];
    }
    return _chatService;
}


- (void)getMessageStats:(id<ChatServiceDelegate>)delegate 
                  offset:(int)starOffset 
                    limit:(int)maxCount
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest getMessageStatList:TRAFFIC_SERVER_URL 
                                                                       appId:[ConfigManager appId] 
                                                                      userId:userId 
                                                                      offset:starOffset 
                                                                    maxCount:maxCount];
        NSArray *messageStatList = nil;
        if (output.resultCode == ERROR_SUCCESS){
            @try{
                DataQueryResponse *drawResponse = [DataQueryResponse parseFromData:output.responseData];
                NSArray *stats = [drawResponse messageStatList];
                messageStatList = [PPMessageManager parseMessageStatList:stats];
                
            }@catch (NSException *exception){
                PPDebug (@"<ChatService>findAllMessageTotals try catch:%@%@", [exception name], [exception reason]);
            }            
            PPDebug(@"<ChatService>findAllMessageTotals success");
        }else {
            PPDebug(@"<ChatService>findAllMessageTotals failed");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (delegate && [delegate respondsToSelector:@selector(didGetMessageStats:resultCode:)]){
            
                [delegate didGetMessageStats:messageStatList resultCode:output.resultCode];
            }
        }); 
    });
}

#define GET_MESSAGELIST_QUEUE @"GET_MESSAGELIST_QUEUE"

- (void)getMessageList:(id<ChatServiceDelegate>)delegate 
          friendUserId:(NSString *)friendUserId 
       offsetMessageId:(NSString *)offsetMessageId
               forward:(BOOL)forward
                 limit:(int)limit
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    NSOperationQueue *queue = [self getOperationQueue:GET_MESSAGELIST_QUEUE];
    [queue cancelAllOperations];
    if ([queue operationCount] != 0) {
        PPDebug(@"GET_MESSAGELIST_QUEUE is working... return without fecth remote message list");
        return;
    }
    
    [queue addOperationWithBlock: ^{
        CommonNetworkOutput* output = [GameNetworkRequest getMessageList:TRAFFIC_SERVER_URL 
                                                                   appId:[ConfigManager appId] 
                                                                  userId:userId 
                                                            friendUserId:friendUserId offsetMessageId:offsetMessageId maxCount:limit
                                                                 forward:forward];
        NSArray *messageList = nil;
        if (output.resultCode == ERROR_SUCCESS){
            
            @try{
                DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                NSArray *mList = [travelResponse messageList];
                messageList = [PPMessageManager parseMessageList:mList];
                
            }@catch (NSException *exception){
                PPDebug (@"<ChatService>findAllMessages try catch:%@%@", [exception name], [exception reason]);
            }
            
            PPDebug(@"<ChatService>findAllMessages success");
        }else {
            PPDebug(@"<ChatService>findAllMessages failed");
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetMessages:forward:resultCode:)]){
                [delegate didGetMessages:messageList forward:forward resultCode:output.resultCode];
            }
        }); 
    }];
}


- (void)sendMessage:(PPMessage *)message 
           delegate:(id<ChatServiceDelegate>)delegate
{
    [message retain];
    dispatch_async(workingQueue, ^{            
        
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *friendId = message.friendId;
        MessageType type  = message.messageType;
        
        //text
        NSString *text = nil;
        
        //draw
        NSArray *drawActionList = nil;        
        NSData *data = nil;
        
        //location request
        BOOL hasLocation = NO;
        double latitude = 0.0f, longitude = 0.0f;
        
        //location response
        NSInteger replyResult = ACCEPT_ASK_LOCATION;
        NSString *reqMessageId = nil;

        switch (type) {
            case MessageTypeText:
            {
                text = [(TextMessage *)message text];
                break;
            }
            case MessageTypeDraw:
            {
                drawActionList = [(DrawMessage *)message drawActionList];
                if (drawActionList != nil) {
                    
                    PBDraw *draw = [[DrawDataService defaultService] buildPBDraw:nil 
                                                                    nick:nil 
                                                                  avatar:nil
                                                          drawActionList:drawActionList
                                                                drawWord:nil 
                                                                language:ChineseType
                                                                    size:[(DrawMessage *)message canvasSize]
                                                                    isCompressed:YES];
                    data = [draw data];
                }
                break;
            }
            case MessageTypeLocationRequest:
            {
                LocationAskMessage *laMessage = (LocationAskMessage *)message;
                longitude = [laMessage longitude];
                latitude = [laMessage latitude];
                hasLocation = YES;
                text = laMessage.text;
                break;
            }
            case MessageTypeLocationResponse:
            {
                LocationReplyMessage *laMessage = (LocationReplyMessage *)message;
                longitude = [laMessage longitude];
                latitude = [laMessage latitude];
                text = laMessage.text;
                replyResult = laMessage.replyResult;
                hasLocation = (replyResult == ACCEPT_ASK_LOCATION);
                break;
            }

            default:
                break;
        }

        
        
        CommonNetworkOutput* output = [GameNetworkRequest sendMessage:TRAFFIC_SERVER_URL 
                                                                appId:[ConfigManager appId] 
                                                               userId:userId 
                                                         targetUserId:friendId 
                                                                 text:text
                                                                 data:data
                                                                 type:type
                                                          hasLocation:hasLocation
                                                            longitude:longitude
                                                             latitude:latitude
                                                         reqMessageId:reqMessageId
                                                          replyResult:replyResult];
        if (output.resultCode == ERROR_SUCCESS){
            NSString *messageId = [output.jsonDataDict objectForKey:PARA_MESSAGE_ID];
            message.messageId = messageId;
            message.status = MessageStatusSent;  
            
            NSInteger timeValue = [[output.jsonDataDict objectForKey:PARA_CREATE_DATE] intValue];
            if (timeValue != 0) {
                message.createDate = [NSDate dateWithTimeIntervalSince1970:timeValue];
                PPDebug(@"return date = %@", message.createDate);
            }
            
            PPDebug(@"<ChatService>sendMessage success");
        }else {
            PPDebug(@"<ChatService>sendMessage failed");
            message.status = MessageStatusFail;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [message release];
            if (delegate && [delegate respondsToSelector:@selector(didSendMessage:resultCode:)]){
                [delegate didSendMessage:message resultCode:output.resultCode];
            }
        }); 
    });
}



- (void)sendHasReadMessage:(id<ChatServiceDelegate>)delegate friendUserId:(NSString *)friendUserId 
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest userHasReadMessage:TRAFFIC_SERVER_URL 
                                                                       appId:[ConfigManager appId] 
                                                                      userId:userId 
                                                                friendUserId:friendUserId];
        if (output.resultCode == ERROR_SUCCESS){
            PPDebug(@"<ChatService>sendHasReadMessage success");
        }else {
            PPDebug(@"<ChatService>sendHasReadMessage failed");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (delegate && [delegate respondsToSelector:@selector(didSendHasReadMessage:resultCode:)]){
                [delegate didSendHasReadMessage:friendUserId resultCode:output.resultCode];
            }
        }); 
    });
}


- (void)deleteMessageStat:(id<ChatServiceDelegate>)delegate friendUserId:(NSString *)friendUserId
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest deleteMessageStat:TRAFFIC_SERVER_URL 
                                                                      appId:[ConfigManager appId] 
                                                                     userId:userId 
                                                               targetUserId:friendUserId];
        if (output.resultCode == ERROR_SUCCESS){
            PPDebug(@"<ChatService>deleteMessageTotal success");
            [PPMessageManager deleteLocalFriendMessageList:friendUserId];
        }else {
            PPDebug(@"<ChatService>deleteMessageTotal failed");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (delegate && [delegate respondsToSelector:@selector(didDeleteMessageStat:resultCode:)]){
                [delegate didDeleteMessageStat:friendUserId resultCode:output.resultCode];
            }
        }); 
    });
}


- (void)deleteMessage:(id<ChatServiceDelegate>)delegate 
        messageList:(NSArray *)messageList
{
    NSString *userId = [[UserManager defaultManager] userId];
    [messageList retain];
    
    dispatch_async(workingQueue, ^{
        
        NSMutableArray *messageIdList = [NSMutableArray array];
        for (PPMessage *message in messageList) {
            [messageIdList addObject:message.messageId];
        }
        CommonNetworkOutput* output = [GameNetworkRequest deleteMessage:TRAFFIC_SERVER_URL 
                                                                  appId:[ConfigManager appId] 
                                                                 userId:userId 
                                                   targetMessageIdArray:messageIdList];
        messageIdList = nil;
        if (output.resultCode == ERROR_SUCCESS){
            PPDebug(@"<ChatService>deleteMessage success");
        }else {
            PPDebug(@"<ChatService>deleteMessage failed");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (delegate && [delegate respondsToSelector:
                             @selector(didDeleteMessages:resultCode:)]){
                [delegate didDeleteMessages:messageList resultCode:output.resultCode];
            }
            [messageList release];
        }); 
    });
    
}


@end
