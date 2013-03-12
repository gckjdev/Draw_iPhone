//
//  ItemManager.m
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemManager.h"
#import "UserManager.h"
#import "UserItem.h"
#import "CoreDataUtil.h"
#import "PPDebug.h"
#import "ConfigManager.h"

#define CUSTOM_DICE_TIPS    @"CustomDiceTips"

ItemManager *staticItemManager = nil;

ItemManager *GlobalGetItemManager()
{
    if (staticItemManager == nil) {
        staticItemManager = [[ItemManager alloc] init];
    }
    return staticItemManager;
}
@implementation ItemManager

#define ITEM_DICT @"ITEM_DICT"

+ (ItemManager *)defaultManager
{
    return GlobalGetItemManager();
}

- (UserItem*)findUserItemByType:(int)type
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    return (UserItem*)[dataManager execute:@"findUserItemByType" 
                                    forKey:@"ITEM_TYPE" 
                                     value:[NSNumber numberWithInt:type]];
}

- (int)tipsItemAmount
{
    UserItem* item = [self findUserItemByType:ItemTypeTips];
    return [[item amount] intValue];
}

- (BOOL)hasEnoughItem:(int)itemType
{
    return [self amountForItem:itemType] > 0;
}

- (int)amountForItem:(int)itemType
{
    UserItem* item = [self findUserItemByType:itemType];
    return [[item amount] intValue];    
}

- (BOOL)isUserOwnItem:(int)itemType
{
    return ([self findUserItemByType:itemType] != nil);
}

- (BOOL)addNewItem:(int)itemType amount:(int)amount
{
    
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    UserItem* item = [self findUserItemByType:itemType];
    if (item == nil){
        item = [dataManager insert:@"UserItem"];
        [item setItemType:[NSNumber numberWithInt:itemType]];
        PPDebug(@"<addNewItem> insert item=%@", [item description]);
    }
    
    [item setAmount:[NSNumber numberWithInt:amount]];
    PPDebug(@"<addNewItem> update item=%@", [item description]);        
    return [dataManager save];
}

- (BOOL)increaseItem:(int)itemType amount:(int)amount
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    UserItem* item = [self findUserItemByType:itemType];
    int currentAmount = 0;
    if (item == nil){
        item = [dataManager insert:@"UserItem"];
        [item setItemType:[NSNumber numberWithInt:itemType]];
        PPDebug(@"<increaseItem> insert item=%@", [item description]);
    }
    else{
        currentAmount = [[item amount] intValue];
    }
    
    [item setAmount:[NSNumber numberWithInt:(currentAmount + amount)]];
    PPDebug(@"<increaseItem> update item=%@", [item description]);        
    return [dataManager save];
}

- (BOOL)decreaseItem:(int)itemType amount:(int)amount
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    UserItem* item = [self findUserItemByType:itemType];
    int currentAmount = 0;
    if (item == nil){
        item = [dataManager insert:@"UserItem"];
        [item setItemType:[NSNumber numberWithInt:itemType]];
        PPDebug(@"<decreaseItem> insert item=%@", [item description]);
    }
    else{
        currentAmount = [[item amount] intValue];
    }
    
    int newAmount = (currentAmount - amount);
    if (newAmount < 0)
        newAmount = 0;
    
    [item setAmount:[NSNumber numberWithInt:newAmount]];
    PPDebug(@"<decreaseItem> update item=%@", [item description]);        
    return [dataManager save];    
}

- (UserItem*)itemWithType:(int)itemType
{
    return [self findUserItemByType:itemType];
}

+ (int)awardAmountByItem:(int)itemType
{
    switch (itemType) {
        case ItemTypeTomato:
            return [ConfigManager getTomatoAwardAmount];

        case ItemTypeFlower:
            return [ConfigManager getFlowerAwardAmount];

        default:
            return 0;
    }
}

+ (int)awardExpByItem:(int)itemType
{
    switch (itemType) {
        case ItemTypeTomato:
            return [ConfigManager getTomatoAwardExp];
            
        case ItemTypeFlower:
            return [ConfigManager getFlowerAwardExp];
            
        default:
            return 0;
    }    
}

- (BOOL)hasShownItemTips:(ItemType)type
{
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    if (type > ItemTypeCustomDiceStart && type < ItemTypeCustomDiceEnd) {
        if ([userdefault objectForKey:CUSTOM_DICE_TIPS] == nil) {
            return NO;
        }
    }
    return YES;
}

- (void)didShowItemTips:(ItemType)type
{
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    if (type > ItemTypeCustomDiceStart && type < ItemTypeCustomDiceEnd) {
        [userdefault setValue:[NSNumber numberWithBool:YES] forKey:CUSTOM_DICE_TIPS];
    }
    [userdefault synchronize];
}

- (void)clearAllItems
{
    //TODO: clear all items here.
}


@end
