//
//  DiceConfigManager.h
//  Draw
//
//  Created by 小涛 王 on 12-9-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceConfigManager : NSObject

+ (BOOL)meetJoinGameCondictionWithRuleType:(int)ruleType;
+ (NSString *)coinsNotEnoughNoteWithRuleType:(int)ruleType;

@end
