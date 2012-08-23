//
//  DiceChatMsgManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-23.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceChatMsgManager.h"
#import "DiceChatMessage.h"
#import "LocaleUtils.h"

static DiceChatMsgManager *_defaultManager = nil;

@interface DiceChatMsgManager()

@property (retain, nonatomic) NSArray *messages;
@property (retain, nonatomic) NSArray *contentList;

@end

@implementation DiceChatMsgManager
@synthesize messages = _messages;
@synthesize contentList = _contentList;

- (void)dealloc
{
    [_messages release];
    [_contentList release];
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
        DiceChatMessage *message1 = [[[DiceChatMessage alloc] initWithMessageId:1 
                                                                content:NSLS(@"kPayAttentionToMe") 
                                                                voiceId:1] autorelease];
        
        DiceChatMessage *message2 = [[[DiceChatMessage alloc] initWithMessageId:2 
                                                                content:NSLS(@"kNoMatterWhatYouCallIWillOpen") 
                                                                voiceId:2] autorelease];
        
        DiceChatMessage *message3 = [[[DiceChatMessage alloc] initWithMessageId:3 
                                                                content:NSLS(@"kDoYouDareToOpen") 
                                                                voiceId:3] autorelease];
        
        DiceChatMessage *message4 = [[[DiceChatMessage alloc] initWithMessageId:4 
                                                                content:NSLS(@"kBelieveItOrNotAnywayIBelieved") 
                                                                voiceId:4] autorelease];
        
        DiceChatMessage *message5 = [[[DiceChatMessage alloc] initWithMessageId:5
                                                                content:NSLS(@"kAttentionWilds") 
                                                                voiceId:5] autorelease];
        
        DiceChatMessage *message6 = [[[DiceChatMessage alloc] initWithMessageId:6 
                                                                content:NSLS(@"kDontGoAndPlayMore") 
                                                                voiceId:6] autorelease];
        
        DiceChatMessage *message7 = [[[DiceChatMessage alloc] initWithMessageId:7 
                                                                content:NSLS(@"kCheatMeNotSoEasy") 
                                                                voiceId:7] autorelease];
        
        DiceChatMessage *message8 = [[[DiceChatMessage alloc] initWithMessageId:8 
                                                                content:NSLS(@"kYouAreFooled") 
                                                                voiceId:8] autorelease];
        
        DiceChatMessage *message9 = [[[DiceChatMessage alloc] initWithMessageId:9 
                                                                content:NSLS(@"kIWantToGoSeeUNextTime") 
                                                                voiceId:9] autorelease];
        

        self.messages = [NSArray arrayWithObjects:message1, message2, message3, message4, message5, message6, message7, message8, message9, nil];
        
        NSMutableArray *array = [NSMutableArray array];
        for (DiceChatMessage *message in _messages) {
            [array addObject:message.content];
        }
        self.contentList = array;
    }
    
    return self;
}

- (NSArray *)contentList
{
    return _contentList;
}

@end
