//
//  CustomDiceManager.m
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomDiceManager.h"
#import "ItemManager.h"
#import "DiceImageManager.h"
#import "DiceItem.h"

#define SHOW_DICE_FLAG  @"a"
#define OPEN_DICE_FLAG  @"b"

#define IMAGE_PREFIX_PATRIOT    @"ag_"

#define MY_DICE_TYPE @"MY_DICE_TYPE"

static CustomDiceManager* shareInstance;


@implementation CustomDiceManager

+ (CustomDiceManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[CustomDiceManager alloc] init];
    }
    return shareInstance;
}

- (ItemType)getMyDiceType
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber* type = (NSNumber*)[userDefault objectForKey:MY_DICE_TYPE];
    if (type) {
        return type.intValue;
    }
    return ItemTypeCustomDiceStart;
}

- (void)setMyDiceType:(ItemType)type
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber* aType = [NSNumber numberWithInt:type];
    [userDefault setObject:aType forKey:MY_DICE_TYPE];
    [userDefault synchronize];
}

- (UIImage*)diceImageForType:(ItemType)type 
                        dice:(int)dice
{
    NSString* prefix = [self getImagePrefixByType:type];
    if (prefix) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@%@%d", prefix, SHOW_DICE_FLAG, dice]];
    } else {
        return [[DiceImageManager defaultManager] diceImageWithDice:dice];
    }
}

- (UIImage*)openDiceImageForType:(ItemType)type 
                            dice:(int)dice
{
    NSString* prefix = [self getImagePrefixByType:type];
    if (prefix) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"%@%@%d", prefix, OPEN_DICE_FLAG, dice]];
    } else {
        return [[DiceImageManager defaultManager] diceImageWithDice:dice];
    }
}

- (NSString*)getImagePrefixByType:(ItemType)type
{
    switch (type) {
        case ItemTypeCustomDicePatriotDice:
            return IMAGE_PREFIX_PATRIOT;
        default:
            return nil;
    }
}

- (NSArray*)myCustomDiceList
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:(ItemTypeCustomDiceEnd-ItemTypeCustomDiceStart)] autorelease];
    for (int i = ItemTypeCustomDiceStart+1; i < ItemTypeCustomDiceEnd; i ++) {
        if ([[ItemManager defaultManager] amountForItem:i] >= 1) {
            [array addObject:[Item diceItemForItemType:i]];
        }
    }
    return array;
}


@end
