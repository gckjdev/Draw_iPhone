//
//  MessageManager.m
//  Draw
//
//  Created by 小涛 王 on 12-5-9.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "MessageManager.h"
#import "PPDebug.h"

static MessageManager *_instance = nil;

@interface MessageManager ()
{
    NSMutableArray *_privateMessages;
    NSMutableArray *_groupMessages;
}
@end

@implementation MessageManager

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
        _privateMessages = [[NSArray arrayWithObjects:@"延时", @"b",  @"c",  @"d",  @"e",  @"f",  @"g",  @"h",  @"i",  @"j", nil] retain];
        _groupMessages = [[NSArray arrayWithObjects:@"a", @"b",  @"c",  @"d",  @"e",  @"f",  @"g",  @"h",  @"i",  @"j", nil] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_privateMessages release]; 
    [_groupMessages release];
    [super dealloc];
}

- (NSArray *)messagesForChatType:(GameChatType)chatType
{
    if (chatType == GameChatTypeChatPrivate) {
        return _privateMessages;
    }else {
        return _groupMessages;
    }
}

@end
