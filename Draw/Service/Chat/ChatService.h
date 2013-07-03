//
//  ChatService.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

#define NOTIFICATION_MESSAGE_SENT       @"NOTIFICATION_MESSAGE_SENT"
#define NOTIFICATION_MESSAGE_SENDING    @"NOTIFICATION_MESSAGE_SENDING"
#define NOTIFICATION_MESSAGE_DELETE     @"NOTIFICATION_MESSAGE_DELETE"
#define NOTIFICATION_MESSAGE_LOAD       @"NOTIFICATION_MESSAGE_LOAD"

#define KEY_USER_INFO_MESSAGE       @"KEY_USER_INFO_MESSAGE"
#define KEY_USER_INFO_RESULT_CODE   @"KEY_USER_INFO_RESULT_CODE"
#define KEY_USER_INFO_FORWARD       @"KEY_USER_INFO_FORWARD"
#define KEY_USER_INFO_INSERTMIDDLE  @"KEY_USER_INFO_INSERTMIDDLE"

@class PPMessage;
@protocol ChatServiceDelegate <NSObject>

@optional
- (void)didGetMessageStats:(NSArray *)statList
                resultCode:(int)resultCode;

- (void)didGetMessages:(NSArray *)list 
               forward:(BOOL)forward
            resultCode:(int)resultCode;


- (void)didSendMessage:(PPMessage *)message 
            resultCode:(int)resultCode;

- (void)didSendHasReadMessage:(NSString *)friendId resultCode:(int)resultCode;

- (void)didDeleteMessageStat:(NSString *)friendUserId
                   resultCode:(int)resultCode;

- (void)didDeleteMessages:(NSArray *)messages
               resultCode:(int)resultCode;

@end

@interface ChatService : CommonService

+ (ChatService*)defaultService;

- (void)getMessageStats:(id<ChatServiceDelegate>)delegate 
                  offset:(int)starOffset 
                    limit:(int)maxCount;

//- (void)getMessageList:(id<ChatServiceDelegate>)delegate 
//          friendUserId:(NSString *)friendUserId 
//       offsetMessageId:(NSString *)offsetMessageId
//               forward:(BOOL)forward
//                 limit:(int)limit;


//- (void)sendMessage:(PPMessage *)message 
//           delegate:(id<ChatServiceDelegate>)delegate;


- (void)sendHasReadMessage:(id<ChatServiceDelegate>)delegate friendUserId:(NSString *)friendUserId;

- (void)deleteMessageStat:(id<ChatServiceDelegate>)delegate
              friendUserId:(NSString *)friendUserId;

//- (void)deleteMessage:(id<ChatServiceDelegate>)delegate 
//        messageList:(NSArray *)messageList;


// new message method, use notification after load/sent complete
- (void)loadMessageList:(NSString *)friendUserId
        offsetMessageId:(NSString *)offsetMessageId
                forward:(BOOL)forward
                  limit:(int)limit;

- (void)sendTextMessage:(NSString *)text friendUserId:(NSString*)friendUserId;
- (void)sendDrawMessage:(NSMutableArray *)drawActionList canvasSize:(CGSize)size friendUserId:(NSString*)friendUserId;
- (void)sendImage:(UIImage *)image friendUserId:(NSString*)friendUserId;
- (void)sendAskLocationMessage:(double)latitude
                     longitude:(double)longitude
                  friendUserId:(NSString*)friendUserId;
- (void)sendReplyLocationMessage:(double)latitude
                       longitude:(double)longitude
                    reqMessageId:(NSString *)reqMessageId
                     replyResult:(NSInteger)replyResult
                    friendUserId:(NSString*)friendUserId;

- (void)sendMessage:(PPMessage *)message;
- (void)deleteMessage:(PPMessage*)message;


@end
