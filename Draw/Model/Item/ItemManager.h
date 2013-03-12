//
//  ItemManager.h
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserItem.h"
#import "ItemType.h"



@interface ItemManager : NSObject
{
    
}

+ (ItemManager *)defaultManager;

- (UserItem*)findUserItemByType:(int)type;
- (int)amountForItem:(int)itemType;
- (int)tipsItemAmount;
- (BOOL)isUserOwnItem:(int)itemType;
- (BOOL)addNewItem:(int)itemType amount:(int)amount;
- (BOOL)increaseItem:(int)itemType amount:(int)amount;
- (BOOL)decreaseItem:(int)itemType amount:(int)amount;
- (BOOL)hasEnoughItem:(int)itemType;
+ (int)awardAmountByItem:(int)itemType;
+ (int)awardExpByItem:(int)itemType;

- (BOOL)hasShownItemTips:(ItemType)type;
- (void)didShowItemTips:(ItemType)type;
- (void)clearAllItems;

@end

