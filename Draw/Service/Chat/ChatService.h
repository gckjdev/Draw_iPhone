//
//  ChatService.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

#define NOTIFICATION_MESSAGE_SENT   @"NOTIFICATION_MESSAGE_SENT"
#define KEY_USER_INFO_MESSAGE       @"KEY_USER_INFO_MESSAGE"
#define KEY_USER_INFO_RESULT_CODE   @"KEY_USER_INFO_RESULT_CODE"

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

- (void)getMessageList:(id<ChatServiceDelegate>)delegate 
          friendUserId:(NSString *)friendUserId 
       offsetMessageId:(NSString *)offsetMessageId
               forward:(BOOL)forward
                 limit:(int)limit;


- (void)sendMessage:(PPMessage *)message 
           delegate:(id<ChatServiceDelegate>)delegate;


- (void)sendHasReadMessage:(id<ChatServiceDelegate>)delegate friendUserId:(NSString *)friendUserId;

- (void)deleteMessageStat:(id<ChatServiceDelegate>)delegate 
              friendUserId:(NSString *)friendUserId;

- (void)deleteMessage:(id<ChatServiceDelegate>)delegate 
        messageList:(NSArray *)messageList;

@end
