//
//  ChatService.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@protocol ChatServiceDelegate <NSObject>

- (void)didFindAllMessageTotals:(NSArray *)totalList;
- (void)didFindAllMessagesByFriendUserId:(NSArray *)totalList;
- (void)didSendMessage:(int)resultCode;
- (void)didSendHasReadMessage:(int)resultCode;

@end

@interface ChatService : CommonService

+ (ChatService*)defaultService;

- (void)findAllMessageTotals:(id<ChatServiceDelegate>)delegate;
- (void)findAllMessagesByFriendUserId:(NSString *)friendUserId delegate:(id<ChatServiceDelegate>)delegate;
- (void)sendMessage:(NSString *)friendUserId 
               text:(NSString *)text 
               data:(NSData *)data 
           delegate:(id<ChatServiceDelegate>)delegate;
- (void)sendHasReadMessage:(NSArray*)messageIdArray delegate:(id<ChatServiceDelegate>)delegate;

@end
