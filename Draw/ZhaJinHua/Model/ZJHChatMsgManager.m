//
//  DiceChatMsgManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-23.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceChatMsgManager.h"
#import "CommonChatMessage.h"
#import "LocaleUtils.h"


static DiceChatMsgManager *_defaultManager = nil;

@interface DiceChatMsgManager()

@property (retain, nonatomic) NSArray *messages;
//@property (retain, nonatomic) NSArray *contentList;

@end

@implementation DiceChatMsgManager
@synthesize messages = _messages;
//@synthesize contentList = _contentList;

- (void)dealloc
{
    [_messages release];
//    [_contentList release];
    [super dealloc];
}

+ (DiceChatMsgManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceChatMsgManager alloc] init];
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
                                                                content:NSLS(@"kNoMatterWhatYouCallIWillOpen") 
                                                                voiceId:2] autorelease];
        
        CommonChatMessage *message3 = [[[CommonChatMessage alloc] initWithMessageId:3 
                                                                content:NSLS(@"kDoYouDareToOpen") 
                                                                voiceId:3] autorelease];
        
        CommonChatMessage *message4 = [[[CommonChatMessage alloc] initWithMessageId:4 
                                                                content:NSLS(@"kBelieveItOrNotAnywayIBelieved") 
                                                                voiceId:4] autorelease];
        
        CommonChatMessage *message5 = [[[CommonChatMessage alloc] initWithMessageId:5
                                                                content:NSLS(@"kAttentionWilds") 
                                                                voiceId:5] autorelease];
        
        CommonChatMessage *message6 = [[[CommonChatMessage alloc] initWithMessageId:6 
                                                                content:NSLS(@"kDontGoAndPlayMore") 
                                                                voiceId:6] autorelease];
        
        CommonChatMessage *message7 = [[[CommonChatMessage alloc] initWithMessageId:7 
                                                                content:NSLS(@"kCheatMeNotSoEasy") 
                                                                voiceId:7] autorelease];
        
        CommonChatMessage *message8 = [[[CommonChatMessage alloc] initWithMessageId:8 
                                                                content:NSLS(@"kYouAreFooled") 
                                                                voiceId:8] autorelease];
        
        CommonChatMessage *message9 = [[[CommonChatMessage alloc] initWithMessageId:9 
                                                                content:NSLS(@"kIWantToGoSeeUNextTime") 
                                                                voiceId:9] autorelease];
        

        self.messages = [NSArray arrayWithObjects:message1, message2, message3, message4, message5, message6, message7, message8, message9, nil];
        
//        NSMutableArray *array = [NSMutableArray array];
//        for (DiceChatMessage *message in _messages) {
//            [array addObject:message.content];
//        }
//        self.contentList = array;
    }
    
    return self;
}

//- (NSArray *)contentList
//{
//    return _contentList;
//}

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
