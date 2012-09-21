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

#define IMAGE_PREFIX_PATRIOT    @"ag"

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

+ (CustomDiceType)itemTypeToCustomDiceType:(ItemType)type
{
    switch (type) {
        case ItemTypeCustomDicePatriotDice:
            return CustomDiceTypePatriot;
        default:
            return CustomDiceTypeDefault;
    }
}

- (CustomDiceType)getMyDiceType
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber* type = (NSNumber*)[userDefault objectForKey:MY_DICE_TYPE];
    if (type) {
        return type.intValue;
    }
    return ItemTypeCustomDiceStart;
}

- (void)setMyDiceType:(CustomDiceType)type
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber* aType = [NSNumber numberWithInt:type];
    [userDefault setObject:aType forKey:MY_DICE_TYPE];
    [userDefault synchronize];
}

- (void)setMyDiceTypeByItemType:(ItemType)type
{
    [self setMyDiceType:[CustomDiceManager itemTypeToCustomDiceType:type]];
}

- (UIImage*)diceImageForType:(CustomDiceType)type 
                        dice:(int)dice
{
    NSString* prefix = [self getImagePrefixByType:type];
    if (prefix) {
        return [[DiceImageManager defaultManager] customDiceImageWithDiceName:prefix 
                                                                         dice:dice];
    } else {
        return [[DiceImageManager defaultManager] diceImageWithDice:dice];
    }
}

- (UIImage*)openDiceImageForType:(CustomDiceType)type 
                            dice:(int)dice
{
    NSString* prefix = [self getImagePrefixByType:type];
    if (prefix) {
        return [[DiceImageManager defaultManager] customOpenDiceImageWithDiceName:prefix 
                                                                             dice:dice];
    } else {
        return [[DiceImageManager defaultManager] openDiceImageWithDice:dice];
    }
}

- (UIImage*)myDiceImage:(int)dice
{
    return [self diceImageForType:[self getMyDiceType] dice:dice];
}
- (UIImage*)myOpenDiceImage:(int)dice
{
    return [self openDiceImageForType:[self getMyDiceType] dice:dice];
}

- (NSString*)getImagePrefixByType:(CustomDiceType)type
{
    switch (type) {
        case CustomDiceTypePatriot:
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
