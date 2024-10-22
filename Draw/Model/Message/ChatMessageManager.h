//
//  ChatMessageManager.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    MessageStatusNotRead = 0,
    MessageStatusRead = 1,
    MessageStatusSendSuccess = 20,
    MessageStatusSendFailed = 21
};

@class PBMessage;
@interface ChatMessageManager : NSObject

+ (ChatMessageManager *)defaultManager;

- (BOOL)createMessageWithMessageId:(NSString *)messageId 
                              from:(NSString *)from 
                                to:(NSString *)to 
                          drawData:(NSData *)drawData 
                        createDate:(NSDate *)createDate 
                              text:(NSString *)text 
                            status:(NSNumber *)status;

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
                      reqMessageId:(NSString *)reqMessageId;

- (BOOL)createByPBMessage:(PBMessage *)pbMessage;

- (NSArray *)findMessagesByFriendUserId:(NSString *)friendUserId;

- (BOOL)deleteMessageByMessageId:(NSString *)messageId;

- (BOOL)deleteMessagesByFriendUserId:(NSString *)friendUserId;

@end
