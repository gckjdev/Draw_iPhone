//
//  UserGameItemManager.h
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"
#import "ItemType.h"

@interface UserGameItemManager : NSObject

+ (UserGameItemManager *)defaultManager;

- (void)setUserItemList:(NSArray *)itemsList;

- (int)countOfItem:(int)itemId;
- (BOOL)hasItem:(int)itemId;
- (BOOL)canBuyItemNow:(PBGameItem *)item;
- (BOOL)hasEnoughItem:(int)itemId amount:(int)amount;

- (ItemType *)boughtPenTypeList;

@end
