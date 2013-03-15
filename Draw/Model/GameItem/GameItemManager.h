//
//  GameItemManager.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>

@class PBGameItem;

#define SHOP_ITEMS_FILE @"shop_item.pb"
#define SHOP_ITEMS_FILE_WITHOUT_SUFFIX @"shop_item"
#define SHOP_ITEMS_FILE_BUNDLE_PATH @"shop_item.pb"
#define SHOP_ITEMS_FILE_VERSION @"1.0"

@interface GameItemManager : NSObject

+ (GameItemManager *)defaultManager;

- (void)setItemsList:(NSArray *)itemsList;
- (NSArray *)itemsList;

- (NSArray *)itemsListWithType:(int)type;
- (NSArray *)promotingItemsList;
- (PBGameItem *)itemWithItemId:(int)itemId;

@end
