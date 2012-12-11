//
//  ChatMsgManagerProtocol.h
//  Draw
//
//  Created by 王 小涛 on 12-12-11.
//
//

#import <Foundation/Foundation.h>

@protocol ChatMsgManagerProtocol <NSObject>

@required

- (NSArray *)messages;
- (int)voiceIdForMessageId:(int)messageId;
- (NSString *)contentForMessageId:(int)messageId;

@end