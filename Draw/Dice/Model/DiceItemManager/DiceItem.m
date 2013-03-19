//
//  DiceItem.m
//  Draw
//
//  Created by 小涛 王 on 12-8-17.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceItem.h"
#import "ShoppingManager.h"
#import "ItemManager.h"
#import "DiceImageManager.h"
#import "LocaleUtils.h"

@implementation Item (DiceItem)

+ (Item*)rollAgain
{
    return [[[Item alloc] initWithType:ItemTypeRollAgain 
                                 image:[[DiceImageManager defaultManager] diceToolRollAgainImage]
                                  name:NSLS(@"kItemRollAgain")
                             shortName:NSLS(@"kRollAgain")
                           description:NSLS(@"kRollAgainDescription") 
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getRollAgainPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeRollAgain]] autorelease];
}


+ (Item*)cut
{
    return [[[Item alloc] initWithType:ItemTypeCut 
                                 image:[[DiceImageManager defaultManager] diceToolCutImage]
                                  name:NSLS(@"kItemCut")
                             shortName:NSLS(@"kCut")
                           description:NSLS(@"kCutDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getCutPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCut]] autorelease];
}

+ (Item *)peek
{
    return [[[Item alloc] initWithType:ItemTypePeek
                                 image:[[DiceImageManager defaultManager] peekImage]
                                  name:NSLS(@"kItemPeek")
                             shortName:NSLS(@"kPeek")
                           description:NSLS(@"kPeekDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getPeekPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypePeek]] autorelease];
}

+ (Item*)postpone
{
    return [[[Item alloc] initWithType:ItemTypeIncTime 
                                 image:[[DiceImageManager defaultManager] postponeImage]
                                  name:NSLS(@"kItemPostpone")
                             shortName:NSLS(@"kPostpone")
                           description:NSLS(@"kPostponeDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getPostPonePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeIncTime]] autorelease];
}

+ (Item*)urge
{
    return [[[Item alloc] initWithType:ItemTypeDecTime 
                                 image:[[DiceImageManager defaultManager] urgeImage]
                                  name:NSLS(@"kItemUrge")
                             shortName:NSLS(@"kUrge")
                           description:NSLS(@"kUrgeDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getUrgePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeDecTime]] autorelease];
}

+ (Item*)turtle
{
    return [[[Item alloc] initWithType:ItemTypeSkip 
                                 image:[[DiceImageManager defaultManager] turtleImage]
                                  name:NSLS(@"kItemTurtle")
                             shortName:NSLS(@"kTurtle")
                           description:NSLS(@"kTurtleDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getTurtlePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeSkip]] autorelease];
}

+ (Item*)diceRobot
{
    return [[[Item alloc] initWithType:ItemTypeDiceRobot 
                                 image:[[DiceImageManager defaultManager] diceRobotImage]
                                  name:NSLS(@"kItemDiceRobot")
                             shortName:NSLS(@"kDiceRobot")
                           description:NSLS(@"kDiceRobotDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getDiceRobotPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeDiceRobot]] autorelease];
}


+ (Item*)reverse
{
    return [[[Item alloc] initWithType:ItemTypeReverse
                                 image:[[DiceImageManager defaultManager] reverseImage]
                                  name:NSLS(@"kItemReverse")
                             shortName:NSLS(@"kReverse")
                           description:NSLS(@"kReverseDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getReversePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeReverse]] autorelease];
}

+ (Item*)patriotDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDicePatriotDice 
                                 image:[[DiceImageManager defaultManager] patriotDiceImage]
                                  name:NSLS(@"kItemPatriotDice")
                             shortName:NSLS(@"kPatriotDice")
                           description:NSLS(@"kPatriotDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getPatriotDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDicePatriotDice]] autorelease];
}

+ (Item*)goldenDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDiceGoldenDice 
                                 image:[[DiceImageManager defaultManager] goldenDiceImage]
                                  name:NSLS(@"kItemGoldenDice")
                             shortName:NSLS(@"kGoldenDice")
                           description:NSLS(@"kGoldenDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getGoldenDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDiceGoldenDice]] autorelease];
}

+ (Item*)woodDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDiceWoodDice 
                                 image:[[DiceImageManager defaultManager] woodDiceImage]
                                  name:NSLS(@"kItemWoodDice")
                             shortName:NSLS(@"kWoodDice")
                           description:NSLS(@"kWoodDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getWoodDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDiceWoodDice]] autorelease];
}

+ (Item*)blueCrystalDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDiceBlueCrystalDice
                                 image:[[DiceImageManager defaultManager] blueCrystalDiceImage]
                                  name:NSLS(@"kItemBlueCrystalDice")
                             shortName:NSLS(@"kBlueCrystalDice")
                           description:NSLS(@"kBlueCrystalDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getCrystalDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDiceBlueCrystalDice]] autorelease];
}

+ (Item*)pinkCrystalDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDicePinkCrystalDice
                                 image:[[DiceImageManager defaultManager] pinkCrystalDiceImage]
                                  name:NSLS(@"kItemPinkCrystalDice")
                             shortName:NSLS(@"kPinkCrystalDice")
                           description:NSLS(@"kPinkCrystalDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getCrystalDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDicePinkCrystalDice]] autorelease];
}

+ (Item*)greenCrystalDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDiceGreenCrystalDice
                                 image:[[DiceImageManager defaultManager] greenCrystalDiceImage]
                                  name:NSLS(@"kItemGreenCrystalDice")
                             shortName:NSLS(@"kGreenCrystalDice")
                           description:NSLS(@"kGreenCrystalDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getCrystalDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDiceGreenCrystalDice]] autorelease];
}

+ (Item*)purpleCrystalDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDicePurpleCrystalDice
                                 image:[[DiceImageManager defaultManager] purpleCrystalDiceImage]
                                  name:NSLS(@"kItemPurpleCrystalDice")
                             shortName:NSLS(@"kPurpleCrystalDice")
                           description:NSLS(@"kPurpleCrystalDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getCrystalDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDicePurpleCrystalDice]] autorelease];
}

+ (Item*)blueDiamondDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDiceBlueDiamondDice
                                 image:[[DiceImageManager defaultManager] blueDiamondDiceImage]
                                  name:NSLS(@"kItemBlueDiamondDice")
                             shortName:NSLS(@"kBlueDiamondDice")
                           description:NSLS(@"kBlueDiamondDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getDiamondDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDiceBlueDiamondDice]] autorelease];
}

+ (Item*)pinkDiamondDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDicePinkDiamondDice
                                 image:[[DiceImageManager defaultManager] pinkDiamondDiceImage]
                                  name:NSLS(@"kItemPinkDiamondDice")
                             shortName:NSLS(@"kPinkDiamondDice")
                           description:NSLS(@"kPinkDiamondDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getDiamondDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDicePinkDiamondDice]] autorelease];
}

+ (Item*)greenDiamondDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDiceGreenDiamondDice
                                 image:[[DiceImageManager defaultManager] greenDiamondDiceImage]
                                  name:NSLS(@"kItemGreenDiamondDice")
                             shortName:NSLS(@"kGreenDiamondDice")
                           description:NSLS(@"kGreenDiamondDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getDiamondDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDiceGreenDiamondDice]] autorelease];
}

+ (Item*)purpleDiamondDice
{
    return [[[Item alloc] initWithType:ItemTypeCustomDicePurpleDiamondDice
                                 image:[[DiceImageManager defaultManager] purpleDiamondDiceImage]
                                  name:NSLS(@"kItemPurpleDiamondDice")
                             shortName:NSLS(@"kPurpleDiamondDice")
                           description:NSLS(@"kPurpleDiamondDiceDescription") 
                      buyAmountForOnce:1
                                 price:[[ShoppingManager defaultManager] getDiamondDicePrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCustomDicePurpleDiamondDice]] autorelease];
}
        

+ (Item*)diceItemForItemType:(ItemType)type
{
    switch (type) {
        case ItemTypeCustomDicePatriotDice:
            return [Item patriotDice];
        case ItemTypeCustomDiceGoldenDice:
            return [Item goldenDice];
        case ItemTypeCustomDiceWoodDice:
            return [Item woodDice];
        case ItemTypeCustomDiceBlueCrystalDice:
            return [Item blueCrystalDice];
        case ItemTypeCustomDicePinkCrystalDice:
            return [Item pinkCrystalDice];
        case ItemTypeCustomDiceGreenCrystalDice:
            return [Item greenCrystalDice];
        case ItemTypeCustomDicePurpleCrystalDice:
            return [Item purpleCrystalDice];
        case ItemTypeCustomDiceBlueDiamondDice:
            return [Item blueDiamondDice];
        case ItemTypeCustomDicePinkDiamondDice:
            return [Item pinkDiamondDice];
        case ItemTypeCustomDiceGreenDiamondDice:
            return [Item greenDiamondDice];
        case ItemTypeCustomDicePurpleDiamondDice:
            return [Item purpleDiamondDice];
        default:
            break;
    }
    return nil;
}

@end
