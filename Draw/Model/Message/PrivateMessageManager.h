//
//  PrivateMessageManager.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    MessageStatusRead = 1,
    MessageStatusNotRead = 2
};

@class PBMessage;
@interface PrivateMessageManager : NSObject

+ (PrivateMessageManager *)defaultManager;

- (BOOL)createMessageWithMessageId:(NSString *)messageId 
                              from:(NSString *)from 
                                to:(NSString *)to 
                          drawData:(NSData *)drawData 
                        createDate:(NSDate *)createDate 
                              text:(NSString *)text 
                            status:(NSNumber *)status;

- (BOOL)createByPBMessage:(PBMessage *)pbMessage;

- (NSArray *)findMessagesByFriendUserId:(NSString *)friendUserId;


@end
