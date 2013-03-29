//
//  GameItemManager.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "PBGameItem+Extend.h"

@class PBGameItem;


@interface GameItemManager : NSObject

+ (GameItemManager *)defaultManager;
+ (NSString *)shopItemsFileName;
+ (NSString *)shopItemsFileBundlePath;
+ (NSString *)shopItemsFileVersion;

- (void)setItemsList:(NSArray *)itemsList;
- (NSArray *)itemsList;

- (NSArray *)itemsListWithType:(int)type;
- (NSArray *)promotingItemsList;
- (PBGameItem *)itemWithItemId:(int)itemId;

- (int)priceWithItemId:(int)itemId;
- (PBGameCurrency)currencyWithItemId:(int)itemId;

@end
