//
//  DiceItemManager.h
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceItemManager : NSObject

+ (DiceItemManager*)defaultManager;

- (NSArray *)itemNameList;
- (int)itemIdForName:(NSString *)itemName;

@end
