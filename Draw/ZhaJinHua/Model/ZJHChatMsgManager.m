//
//  ZJHChatMsgManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-23.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ZJHChatMsgManager.h"
#import "CommonChatMessage.h"
#import "LocaleUtils.h"


static ZJHChatMsgManager *_defaultManager = nil;

@interface ZJHChatMsgManager()

@property (retain, nonatomic) NSArray *messages;

@end

@implementation ZJHChatMsgManager
@synthesize messages = _messages;

- (void)dealloc
{
    [_messages release];
    [super dealloc];
}

+ (ZJHChatMsgManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[ZJHChatMsgManager alloc] init];
    }

    return _defaultManager;
}

- (id)init
{    
    if (self = [super init]) {
        CommonChatMessage *message1 = [[[CommonChatMessage alloc] initWithMessageId:1
                                                                content:NSLS(@"kPayAttentionToMe") 
                                                                voiceId:1] autorelease];
        
        CommonChatMessage *message2 = [[[CommonChatMessage alloc] initWithMessageId:2 
                                                                content:NSLS(@"kHurryUp") 
                                                                voiceId:2] autorelease];
        
        CommonChatMessage *message3 = [[[CommonChatMessage alloc] initWithMessageId:3 
                                                                content:NSLS(@"kNiceToSeeYou") 
                                                                voiceId:3] autorelease];
        
        CommonChatMessage *message4 = [[[CommonChatMessage alloc] initWithMessageId:4 
                                                                content:NSLS(@"kDareToBetToDie") 
                                                                voiceId:4] autorelease];
        
        CommonChatMessage *message5 = [[[CommonChatMessage alloc] initWithMessageId:5
                                                                content:NSLS(@"kIWillFollowAnyWay") 
                                                                voiceId:5] autorelease];
        
        CommonChatMessage *message6 = [[[CommonChatMessage alloc] initWithMessageId:6 
                                                                content:NSLS(@"kBadLuck") 
                                                                voiceId:6] autorelease];
        
        CommonChatMessage *message7 = [[[CommonChatMessage alloc] initWithMessageId:7 
                                                                content:NSLS(@"kILeaveForAMoment") 
                                                                voiceId:7] autorelease];
        
        CommonChatMessage *message8 = [[[CommonChatMessage alloc] initWithMessageId:8 
                                                                content:NSLS(@"kIWantToGoNow") 
                                                                voiceId:8] autorelease];
        
        CommonChatMessage *message9 = [[[CommonChatMessage alloc] initWithMessageId:9 
                                                                content:NSLS(@"kShutUp") 
                                                                voiceId:9] autorelease];
        

        self.messages = [NSArray arrayWithObjects:message1, message2, message3, message4, message5, message6, message7, message8, message9, nil];
        
    }
    
    return self;
}

- (int)voiceIdForMessageId:(int)messageId
{
    for (CommonChatMessage *message in _messages) {
        if (messageId == message.messageId) {
            return message.voiceId;
        }
    }
    
    return 0;
}

- (NSString *)contentForMessageId:(int)messageId
{
    for (CommonChatMessage *message in _messages) {
        if (messageId == message.messageId) {
            return message.content;
        }
    }
    
    return nil;
}

- (NSArray *)messages
{
    return _messages;
}

@end
