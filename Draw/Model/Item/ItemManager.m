//
//  ItemManager.m
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemManager.h"
#import "UserManager.h"
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

- (NSArray *)itemListForUserId:(NSString *)userId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:ITEM_DICT];
    if (data) {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (dict) {
            return [dict objectForKey:userId];
        }
    }
    return nil;
}

- (NSArray *)itemList
{
    NSString *userId = [[UserManager defaultManager] userId];
    return [self itemListForUserId:userId];
}

- (NSInteger)findItemInItemList:(NSArray *)list withType:(ItemType)type
{
    if ([list count] != 0) {
        int i = 0;
        for (Item *item in list) {
            if (item.type == type) {
                return i;
            }
            i ++;
        }
    }
    return -1;
}

- (void)updateItemWithType:(ItemType)type amount:(NSInteger)amount
{
    NSString *userId = [[UserManager defaultManager] userId];
    if (userId == nil) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:ITEM_DICT];
    NSMutableDictionary *mDict = nil; 
    if (data) {
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSArray *list = [mDict objectForKey:userId];
        if (list) {
            NSMutableArray *mList = [NSMutableArray arrayWithArray:list];
            NSInteger index = [self findItemInItemList:mList withType:type];
            if (index != -1) {
                Item *item = [mList objectAtIndex:index];
                [item setAmount:amount];
            }else{
                [mList addObject:[Item itemWithType:type amount:amount]];
            }
            [mDict setObject:mList forKey:userId];
        }
    }else{
        mDict = [[[NSMutableDictionary alloc] init]autorelease];
        NSMutableArray *mList = [[[NSMutableArray alloc] init] autorelease];
        Item *item = [Item itemWithType:type amount:amount];
        [mList addObject:item];
        [mDict setObject:mList forKey:userId];
    }
    NSData *archviedData = [NSKeyedArchiver archivedDataWithRootObject:mDict];
    [defaults setObject:archviedData forKey:ITEM_DICT];
}

@end
