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
                                 image:nil
                                  name:NSLS(@"kRollAgain")
                           description:NSLS(@"kRollAgainDescription") 
                      buyAmountForOnce:10 
                                 price:[[ShoppingManager defaultManager] getRollAgainPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeRollAgain]] autorelease];
}


+ (Item*)cut
{
    return [[[Item alloc] initWithType:ItemTypeCut 
                                 image:nil
                                  name:NSLS(@"kCut")
                           description:NSLS(@"kCutDescription") 
                      buyAmountForOnce:10
                                 price:[[ShoppingManager defaultManager] getCutPrice] 
                                amount:[[ItemManager defaultManager] amountForItem:ItemTypeCut]] autorelease];
}



@end
