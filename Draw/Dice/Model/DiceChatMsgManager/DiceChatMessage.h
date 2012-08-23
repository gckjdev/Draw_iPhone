//
//  DiceChatMessage.h
//  Draw
//
//  Created by 小涛 王 on 12-8-23.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceChatMessage : NSObject

- (id)initWithMessageId:(int)messageId 
                content:(NSString *)content
                voiceId:(int)voiceId;

- (NSString *)content;
- (int)messageId;
- (int)voiceId;

@end
