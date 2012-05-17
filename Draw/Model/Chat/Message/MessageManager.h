//
//  MessageManager.h
//  Draw
//
//  Created by 小涛 王 on 12-5-9.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameConstants.pb.h"

typedef enum{
    RoomMessages = 1,
    GameMessages = 2
} MessagesType;

@interface MessageManager : NSObject

+ (MessageManager *)defaultManager;
- (NSArray *)messagesForType:(MessagesType)type;

@end
