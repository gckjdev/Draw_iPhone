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

//- (UIView *)itemViewItemName:(NSString *)itemName
//{
//    CGRect frame = CGRectMake(0, 0, 34, 38);
//    UIImageView *view = [[[UIImageView alloc] initWithFrame:frame] autorelease];
//    view.image = [[DiceImageManager defaultManager] toolsItemBgImage];
//    HKGirlFontLabel *label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(0, 0, 22, 24)] autorelease];
//    label.center = view.center;
//    label.text = itemName;
//    
//    [view addSubview:label];
//    return view;
//}

@end
