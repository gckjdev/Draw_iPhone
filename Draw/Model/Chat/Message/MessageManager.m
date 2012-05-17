//
//  MessageManager.m
//  Draw
//
//  Created by 小涛 王 on 12-5-9.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "MessageManager.h"
#import "LocaleUtils.h"
#import "PPDebug.h"

static MessageManager *_instance = nil;

@interface MessageManager ()
{
    NSMutableArray *messagesInRoom;
    NSMutableArray *messagesInGame;
}

@property (retain, nonatomic) NSMutableArray *messagesInRoom;
@property (retain, nonatomic) NSMutableArray *messagesInGame;

@end

@implementation MessageManager

@synthesize messagesInRoom = _messagesInRoom;
@synthesize messagesInGame = _messagesInGame;

+ (MessageManager *)defaultManager
{
    if (_instance == nil) {
        _instance = [[MessageManager alloc] init];
    }
    
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.messagesInRoom = [NSArray arrayWithObjects:NSLS(@"kPayAttentionToMe"), NSLS(@"kDrawTillDawn"), NSLS(@"kHelloEveryone"), NSLS(@"kDontLeave"), NSLS(@"kFunny"), NSLS(@"kDrawedWhat"), NSLS(@"kHardToGuess"), NSLS(@"kGeiliable"), nil];
        
        self.messagesInGame = [NSArray arrayWithObjects:NSLS(@"kPayAttentionToMe"), NSLS(@"kDrawTillDawn"), NSLS(@"kWellDone"),NSLS(@"kDontLive"), NSLS(@"kDontWriteAnswer"), NSLS(@"kDrawedWhat"), NSLS(@"kHardToGuess"), NSLS(@"kGiveAPrompt"), nil];
    }
    
    return self;
}

- (void)dealloc
{
    [_messagesInRoom release]; 
    [_messagesInGame release];
    [super dealloc];
}

- (NSArray *)messagesForType:(MessagesType)type
{
    if (type == RoomMessages) {
        return _messagesInRoom;
    }else {
        return _messagesInGame;
    }
}

@end
