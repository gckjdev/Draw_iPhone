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

@optional
- (void)didFindAllMessageTotals:(NSArray *)totalList resultCode:(int)resultCode;
- (void)didFindAllMessages:(NSArray *)list resultCode:(int)resultCode;
- (void)didSendMessage:(int)resultCode;
- (void)didSendHasReadMessage:(int)resultCode;

@end

@interface ChatService : CommonService

+ (ChatService*)defaultService;

- (void)findAllMessageTotals:(id<ChatServiceDelegate>)delegate 
                  starOffset:(int)starOffset 
                    maxCount:(int)maxCount;

- (void)findAllMessages:(id<ChatServiceDelegate>)delegate 
           friendUserId:(NSString *)friendUserId 
             starOffset:(int)starOffset 
               maxCount:(int)maxCount;

- (void)sendMessage:(id<ChatServiceDelegate>)delegate
       friendUserId:(NSString *)friendUserId
               text:(NSString *)text 
     drawActionList:(NSArray*)drawActionList;

- (void)sendHasReadMessage:(id<ChatServiceDelegate>)delegate friendUserId:(NSString *)friendUserId;

@end
