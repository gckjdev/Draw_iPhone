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
+ (Item *)peek;
+ (Item*)postpone;
+ (Item*)urge;
+ (Item*)turtle;
+ (Item*)diceRobot;
+ (Item*)patriotDice;
+ (Item*)reverse;

+ (Item*)diceItemForItemType:(ItemType)type;

+ (Item*)goldenDice;
+ (Item*)woodDice;
+ (Item*)blueCrystalDice;
+ (Item*)pinkCrystalDice;
+ (Item*)greenCrystalDice;
+ (Item*)purpleCrystalDice;
+ (Item*)blueDiamondDice;
+ (Item*)pinkDiamondDice;
+ (Item*)greenDiamondDice;
+ (Item*)purpleDiamondDice;

@end
