//
//  CustomDiceManager.m
//  Draw
//
//  Created by Orange on 12-9-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomDiceManager.h"
#import "UserGameItemManager.h"
#import "DiceImageManager.h"
#import "DiceItem.h"
#import "GameBasic.pb.h"


#define SHOW_DICE_FLAG  @"a"
#define OPEN_DICE_FLAG  @"b"

#define IMAGE_PREFIX_PATRIOT    @"ag"
#define IMAGE_PREFIX_WOOD   @"wood"
#define IMAGE_PREFIX_GOLDEN @"golden"
#define IMAGE_PREFIX_BLUE_CRYSTAL   @"blueCrystal"
#define IMAGE_PREFIX_PINK_CRYSTAL   @"pinkCrystal"
#define IMAGE_PREFIX_PURPLE_CRYSTAL @"purpleCrystal"
#define IMAGE_PREFIX_GREEN_CRYSTAL  @"greenCrystal"
#define IMAGE_PREFIX_BLUE_DIAMOND   @"blueDiamond"
#define IMAGE_PREFIX_PINK_DIAMOND   @"pinkDiamond"
#define IMAGE_PREFIX_GREEN_DIAMOND  @"greenDiamond"
#define IMAGE_PREFIX_PURPLE_DIAMOND @"purpleDiamond"


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
    return CustomDiceTypeDefault + (type - ItemTypeCustomDiceStart);
}

+ (CustomDiceType)getUserDiceTypeByPBGameUser:(PBGameUser*)pbUser
{
    for (PBKeyValue* kValue in pbUser.attributesList) {
        if ([kValue.name isEqualToString:CUSTOM_DICE]) {
            return kValue.value.intValue;
        }
    }
    return CustomDiceTypeDefault;
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
        case CustomDiceTypeWood:
            return IMAGE_PREFIX_WOOD;
        case CustomDiceTypeGolden:
            return IMAGE_PREFIX_GOLDEN;
        case CustomDiceTypeBlueCrystal:
            return IMAGE_PREFIX_BLUE_CRYSTAL;
        case CustomDiceTypePinkCrystal:
            return IMAGE_PREFIX_PINK_CRYSTAL;
        case CustomDiceTypeGreenCrystal:
            return IMAGE_PREFIX_GREEN_CRYSTAL;
        case CustomDiceTypePurpleCrystal:
            return IMAGE_PREFIX_PURPLE_CRYSTAL;
        case CustomDiceTypeBlueDiamond:
            return IMAGE_PREFIX_BLUE_DIAMOND;
        case CustomDiceTypePinkDiamond:
            return IMAGE_PREFIX_PINK_DIAMOND;
        case CustomDiceTypeGreenDiamond:
            return IMAGE_PREFIX_GREEN_DIAMOND;
        case CustomDiceTypePurpleDiamond:
            return IMAGE_PREFIX_PURPLE_DIAMOND;
        default:
            return nil;
    }
}

- (NSArray*)myCustomDiceList
{
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = ItemTypeCustomDiceStart + 1; i < ItemTypeCustomDiceEnd; i ++) {
        if ([[UserGameItemManager defaultManager] hasItem:i]) {
            [array addObject:[Item diceItemForItemType:i]];
        }
    }
    
    return array;
}


@end
