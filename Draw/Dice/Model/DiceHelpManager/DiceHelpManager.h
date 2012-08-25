//
//  DiceHelpManager.h
//  Draw
//
//  Created by 小涛 王 on 12-8-25.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceHelpManager : NSObject

+ (DiceHelpManager*)defaultManager;

- (NSString *)gameRulesHtmlFilePath;
- (NSString *)itemsUsageHtmlFilePath;

@end
