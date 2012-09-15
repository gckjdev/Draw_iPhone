//
//  DiceItem.h
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Item (DiceItem)

+ (Item*)rollAgain;
+ (Item*)cut;
+ (Item*)postpone;
+ (Item*)urge;
+ (Item*)doubleKill;
+ (Item*)turtle;
+ (Item*)diceRobot;
@end
