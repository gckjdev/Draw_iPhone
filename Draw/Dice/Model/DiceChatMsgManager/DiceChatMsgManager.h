//
//  DiceChatMsgManager.h
//  Draw
//
//  Created by 小涛 王 on 12-8-23.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceChatMsgManager : NSObject

+ (DiceChatMsgManager*)defaultManager;
- (NSArray *)contentList;

@end
