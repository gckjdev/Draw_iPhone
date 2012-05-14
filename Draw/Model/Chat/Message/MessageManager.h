//
//  MessageManager.h
//  Draw
//
//  Created by 小涛 王 on 12-5-9.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PRIVATE = 1,
    GROUP = 2,
}ChatType;


@interface MessageManager : NSObject

+ (MessageManager *)defaultManager;
- (NSArray *)messagesForChatType:(ChatType)type;

@end
