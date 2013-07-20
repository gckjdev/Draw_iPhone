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
#import "UIImageExt.h"
#import "StringUtil.h"
#import "PPGameNetworkRequest.h"

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

- (void)postNotification:(NSString*)name
                 message:(PPMessage*)message
              resultCode:(int)resultCode
            insertMiddle:(BOOL)insertMiddle
                 forward:(BOOL)forward
{
    NSDictionary* dict = @{
//                                 KEY_USER_INFO_MESSAGE : [[message toPBMessage] data],
                                 KEY_USER_INFO_RESULT_CODE : @(resultCode),
                                 KEY_USER_INFO_FORWARD : @(forward),
                                 KEY_USER_INFO_INSERTMIDDLE : @(insertMiddle),
                                };
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name
     object:self
     userInfo:dict];
    
    PPDebug(@"post notification %@", name);
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
        
        //image 
        __block NSString *imageUrl = nil;
        __block NSString *thumbImageUrl = nil;
        
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
                                                            isCompressed:NO];
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
                reqMessageId = laMessage.reqMessageId;
                break;
            }
            case MessageTypeImage:
            {
                ImageMessage *imageMessage = (ImageMessage *)message;
                 data = [imageMessage.image data];
                
                if ([text length] == 0){
                    text = NSLS(@"kImageMessage");
                }
                
                thumbImageUrl = [imageMessage thumbImageUrl];
                imageUrl = [imageMessage imageUrl];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                NSString *messageId = [output.jsonDataDict objectForKey:PARA_MESSAGE_ID];
                message.messageId = messageId;
                
                NSInteger timeValue = [[output.jsonDataDict objectForKey:PARA_CREATE_DATE] intValue];
                if (timeValue != 0) {
                    message.createDate = [NSDate dateWithTimeIntervalSince1970:timeValue];
                    PPDebug(@"return date = %@", message.createDate);
                }
                
                if (type == MessageTypeImage) {
                    imageUrl = [output.jsonDataDict objectForKey:PARA_IMAGE];
                    thumbImageUrl = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
                }
                
                message.status = MessageStatusSent;
                PPDebug(@"<ChatService>sendMessage success");
            }else {
                
                message.status = MessageStatusFail;
                PPDebug(@"<ChatService>sendMessage failed");
            }
            
            if (type == MessageTypeImage) {
                ImageMessage *imageMessage = (ImageMessage *)message;
                if (output.resultCode == ERROR_SUCCESS) {
                    [PPMessageManager removeLocalImage:[imageMessage thumbImageUrl]];
                }
                imageMessage.imageUrl = imageUrl;
                imageMessage.thumbImageUrl = thumbImageUrl;
            }
            
            // post notification
//            [self postNotification:NOTIFICATION_MESSAGE_SENT message:message resultCode:output.resultCode];
            
            if (delegate && [delegate respondsToSelector:@selector(didSendMessage:resultCode:)]){
                [delegate didSendMessage:message resultCode:output.resultCode];
            }
            
            [message release];
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

/*
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
                [delegate didDeleteMessages:nil resultCode:output.resultCode];
            }
            [messageList release];
        }); 
    });
    
}
*/

#pragma mark new message methods

- (void)loadMessageList:(NSString *)friendUserId
        offsetMessageId:(NSString *)offsetMessageId
                forward:(BOOL)forward
                  limit:(int)limit
{
    [self loadMessageList:friendUserId offsetMessageId:offsetMessageId forward:forward insertMiddle:NO limit:limit];
}

- (void)loadMessageList:(NSString *)friendUserId
        offsetMessageId:(NSString *)offsetMessageId
                forward:(BOOL)forward
           insertMiddle:(BOOL)insertMiddle
                  limit:(int)limit
{
    PPDebug(@"<loadMessageList> offsetMessgeId=%@, forward=%d, limit=%d", offsetMessageId, forward, limit);
    
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
                                                            friendUserId:friendUserId
                                                         offsetMessageId:offsetMessageId
                                                                maxCount:limit
                                                                 forward:forward];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *messageList = nil;
            if (output.resultCode == ERROR_SUCCESS){
                
                @try{
                    DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                    NSArray *mList = [travelResponse messageList];
                    messageList = [PPMessageManager parseMessageListAndReverse:mList];
                    
                }@catch (NSException *exception){
                    PPDebug (@"<ChatService>findAllMessages try catch:%@%@", [exception name], [exception reason]);
                }
                
                PPDebug(@"<ChatService>findAllMessages success");
            }else {
                PPDebug(@"<ChatService>findAllMessages failed");
            }

            if (output.resultCode == 0){
                
                if ([messageList count] > 0){
                    if (insertMiddle){
                        [[PPMessageManager defaultManager] addMessageList:messageList friendUserId:friendUserId offsetMessageId:offsetMessageId];
                    }
                    else{
                        if (forward){
                            [[PPMessageManager defaultManager] addMessageListTail:messageList friendUserId:friendUserId];
                        }
                        else{
                            [[PPMessageManager defaultManager] addMessageListHead:messageList friendUserId:friendUserId];
                        }
                    }
                }
                
            }
            
            // post notification here
            [self postNotification:NOTIFICATION_MESSAGE_LOAD
                           message:nil
                        resultCode:output.resultCode
                 insertMiddle:insertMiddle
                           forward:forward];
            
        });
    }];
    
}

#pragma mark sendMessage

- (void)constructMessage:(PPMessage *)message friendUserId:(NSString*)friendUserId
{
    [message setFriendId:friendUserId];
    [message setMessageId:[NSString GetUUID]];  // create a temp message ID
    [message setStatus:MessageStatusSending];
    [message setSourceType:SourceTypeSend];
    [message setCreateDate:[NSDate date]];
}

- (void)sendTextMessage:(NSString *)text friendUserId:(NSString*)friendUserId
{
    TextMessage *message = [[TextMessage alloc] init];
    [self constructMessage:message friendUserId:friendUserId];
    [message setText:text];
    [message setMessageType:MessageTypeText];
    
    [self sendMessage:message];
    [message release];
}


- (void)sendDrawMessage:(NSMutableArray *)drawActionList canvasSize:(CGSize)size friendUserId:(NSString*)friendUserId
{
    // TODO check
    // load new message to avoid missing new message while staying in send message mode
//    [self loadNewMessage:NO];
    
    DrawMessage *message = [[DrawMessage alloc] init];
    [self constructMessage:message friendUserId:friendUserId];
    [message setMessageType:MessageTypeDraw];
    [message setDrawActionList:drawActionList];
    [message setCanvasSize:size];
    
    [self sendMessage:message];
    [message release];
}


- (void)sendImage:(UIImage *)image friendUserId:(NSString*)friendUserId
{
    ImageMessage *message = [[ImageMessage alloc] init];
    [self constructMessage:message friendUserId:friendUserId];
    [message setMessageType:MessageTypeImage];
    [message setText:NSLS(@"kImageMessage")];
    [message setImage:image];
    
    // when fail or sending, url save local path, thumburl save key
    [message setThumbImageUrl:[NSString stringWithFormat:@"%@.png", [NSString GetUUID]]];
    [PPMessageManager saveImageToLocal:message.image key:message.thumbImageUrl];
    [message setImageUrl:[PPMessageManager path:message.thumbImageUrl]];
    
    [self sendMessage:message];
    [message release];
    
}


- (void)sendAskLocationMessage:(double)latitude
                     longitude:(double)longitude
                  friendUserId:(NSString*)friendUserId
{
    LocationAskMessage *message = [[LocationAskMessage alloc] init];
    [message setText:NSLS(@"kAskLocationMessage")];
    [message setLatitude:latitude];
    [message setLongitude:longitude];
    [message setMessageType:MessageTypeLocationRequest];
    [self constructMessage:message friendUserId:friendUserId];

    [self sendMessage:message];
    [message release];
    
}

- (void)sendReplyLocationMessage:(double)latitude
                       longitude:(double)longitude
                    reqMessageId:(NSString *)reqMessageId
                     replyResult:(NSInteger)replyResult
                    friendUserId:(NSString*)friendUserId
{
    LocationReplyMessage *message = [[LocationReplyMessage alloc] init];
    [message setMessageType:MessageTypeLocationResponse];
    [message setReqMessageId:reqMessageId];
    [message setReplyResult:replyResult];
    
    if (replyResult == ACCEPT_ASK_LOCATION) {
        [message setText:NSLS(@"kReplyLocationMessage")];
        [(LocationReplyMessage*)message setLatitude:latitude];
        [(LocationReplyMessage*)message setLongitude:longitude];
    } else {
        [message setText:NSLS(@"kRejectLocationMessage")];
    }
    
    [self constructMessage:message friendUserId:friendUserId];
    [self sendMessage:message];
    [message release];
    
}

- (void)sendMessage:(PPMessage *)message
{
    // set status and date
    [message setCreateDate:[NSDate date]];
    [message setStatus:MessageStatusSending];
    
    [[PPMessageManager defaultManager] addOrUpdateMessage:message];
    
    // post notification
    [self postNotification:NOTIFICATION_MESSAGE_SENDING
                   message:message
                resultCode:0
              insertMiddle:NO
                   forward:YES];
    
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
        
        //image
        __block NSString *imageUrl = nil;
        __block NSString *thumbImageUrl = nil;
        
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
                                                                    isCompressed:NO];
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
                reqMessageId = laMessage.reqMessageId;
                break;
            }
            case MessageTypeImage:
            {
                ImageMessage *imageMessage = (ImageMessage *)message;
                data = [imageMessage.image data];
                
                if ([text length] == 0){
                    text = NSLS(@"kImageMessage");
                }
                
                thumbImageUrl = [imageMessage thumbImageUrl];
                imageUrl = [imageMessage imageUrl];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                NSString *messageId = [output.jsonDataDict objectForKey:PARA_MESSAGE_ID];
                message.messageId = messageId;
                
                NSInteger timeValue = [[output.jsonDataDict objectForKey:PARA_CREATE_DATE] intValue];
                if (timeValue != 0) {
                    message.createDate = [NSDate dateWithTimeIntervalSince1970:timeValue];
                    PPDebug(@"return date = %@", message.createDate);
                }
                
                if (type == MessageTypeImage) {
                    imageUrl = [output.jsonDataDict objectForKey:PARA_IMAGE];
                    thumbImageUrl = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
                }
                
                message.status = MessageStatusSent;
                PPDebug(@"<ChatService> sendMessage success");
                
                [self loadMessageList:message.friendId offsetMessageId:message.messageId forward:NO insertMiddle:YES limit:20];
                
            }else {
                
                message.status = MessageStatusFail;
                PPDebug(@"<ChatService> sendMessage failed");
            }
            
            if (type == MessageTypeImage) {
                ImageMessage *imageMessage = (ImageMessage *)message;
                if (output.resultCode == ERROR_SUCCESS) {
                    [PPMessageManager removeLocalImage:[imageMessage thumbImageUrl]];
                }
                imageMessage.imageUrl = imageUrl;
                imageMessage.thumbImageUrl = thumbImageUrl;
            }
            
            // post notification
            [self postNotification:NOTIFICATION_MESSAGE_SENT
                           message:message
                        resultCode:output.resultCode
                      insertMiddle:NO
                           forward:YES];
            
            [[PPMessageManager defaultManager] updateMessage:message friendUserId:friendId];
        });
    });
    
}

- (void)deleteMessage:(PPMessage*)message
{
    NSString *messageId = [message messageId];
    NSString *userId = [[UserManager defaultManager] userId];
    NSString *friendId = message.friendId;
    if (userId == nil || messageId == nil || friendId == nil)
        return;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_USERID : userId,
                                PARA_MESSAGE_ID : messageId,
                                PARA_TARGETUSERID : friendId,
                               };
        
        CommonNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponseJSON:METHOD_DELETE_SINGLE_MESSAGE
                                                                                    parameters:para
                                                                                 isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<ChatService> deleteMessage success, id=%@", messageId);
                
                if (message.messageType == MessageTypeImage){
                    if (message.status == MessageStatusSending || message.status == MessageStatusFail) {
                        [PPMessageManager removeLocalImage:[(ImageMessage *)message thumbImageUrl]];
                    }
                }
                
                [[PPMessageManager defaultManager] deleteMessage:message];
                
            }else {
                PPDebug(@"<ChatService> deleteMessage failed, id=%@", messageId);
            }
            
            [self postNotification:NOTIFICATION_MESSAGE_DELETE
                           message:message
                        resultCode:output.resultCode
                      insertMiddle:NO
                           forward:YES];
            
        });
        
        /* old interface, now use new interface
        CommonNetworkOutput* output = [GameNetworkRequest deleteMessage:TRAFFIC_SERVER_URL
                                                                  appId:[ConfigManager appId]
                                                                 userId:userId
                                                   targetMessageIdArray:messageIdList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<ChatService> deleteMessage success, id=%@", messageId);
                
                if (message.messageType == MessageTypeImage){
                    if (message.status == MessageStatusSending || message.status == MessageStatusFail) {
                        [PPMessageManager removeLocalImage:[(ImageMessage *)message thumbImageUrl]];
                    }
                }
                
                [[PPMessageManager defaultManager] deleteMessage:message];
                
            }else {
                PPDebug(@"<ChatService> deleteMessage failed, id=%@", messageId);
            }

            [self postNotification:NOTIFICATION_MESSAGE_DELETE
                           message:message
                        resultCode:output.resultCode
                      insertMiddle:NO
                           forward:YES];
            
        });
         */
    });    
}

@end
