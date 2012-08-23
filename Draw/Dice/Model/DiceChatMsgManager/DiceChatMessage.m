//
//  DiceChatMessage.m
//  Draw
//
//  Created by 小涛 王 on 12-8-23.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceChatMessage.h"

@interface DiceChatMessage()

@property (assign, nonatomic) int messageId;
@property (copy, nonatomic) NSString *content;
@property (assign, nonatomic) int voiceId;

@end

@implementation DiceChatMessage

@synthesize messageId = _messageId;
@synthesize content = _content;
@synthesize voiceId = _voiceId;

- (void)dealloc
{
    [_content release];
    [super dealloc];
}

- (id)initWithMessageId:(int)messageId 
                content:(NSString *)content
                voiceId:(int)voiceId
{
    if (self = [super init]) {
        self.messageId = messageId;
        self.content = content;
        self.voiceId = voiceId;
    }
    
    return self;
}

- (NSString *)content
{
    return _content;
}




@end
