//
//  GameItemManager.m
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import "GameItemManager.h"
#import "SynthesizeSingleton.h"
#import "GameBasic.pb.h"
#import "PPSmartUpdateDataUtils.h"
#import "ItemType.h"
#import "ConfigManager.h"

#define SHOP_ITEMS_FILE_WITHOUT_SUFFIX @"shop_item"
#define SHOP_ITEM_FILE_TYPE @"pb"

// change for each item bundle file upgrade
#define SHOP_ITEMS_FILE_VERSION @"2.98"

@interface GameItemManager()

@property (retain, nonatomic) NSArray *items;

@end

@implementation GameItemManager

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemManager);

- (void)dealloc
{
    [_items release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:[GameItemManager shopItemsFileNameWithoutSuffix] ofType:SHOP_ITEM_FILE_TYPE];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.items = [[PBGameItemList parseFromData:data] itemsList];
    }
    
    return self;
}

+ (NSString *)shopItemsFileNameWithoutSuffix
{
    return [[SHOP_ITEMS_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp iapResourceFileName]];
}

+ (NSString *)shopItemsFileName
{
    return [[[[SHOP_ITEMS_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp iapResourceFileName]] stringByAppendingString:@"."] stringByAppendingString:[self shopItemsFileType]];
}

+ (NSString *)shopItemsFileBundlePath
{
    return [self shopItemsFileName];
}

+ (NSString *)shopItemsFileType
{
    return SHOP_ITEM_FILE_TYPE;
}

+ (NSString *)shopItemsFileVersion
{
#ifdef DEBUG
    return @"2.90";
#endif
    return SHOP_ITEMS_FILE_VERSION;
}

- (void)setItemsList:(NSArray *)itemsList
{
    self.items = itemsList;
}

- (NSArray *)removeAdAndPurseItemInItems:(NSArray *)items
{
    NSMutableArray *itemList = [NSMutableArray array];
    for (PBGameItem *item in items) {
        if (item.itemId != ItemTypeRemoveAd
            && item.itemId != ItemTypePurse
            && item.itemId != ItemTypePurseOneThousand) {
            [itemList addObject:item];
        }
    }
    
    return itemList;
}

- (NSArray *)itemsList
{
    if ([ConfigManager isInReviewVersion]) {
        return [self removeAdAndPurseItemInItems:_items];
    }
    
    return _items;
}

- (NSArray *)itemsListWithType:(int)type
{
    NSMutableArray *array = [NSMutableArray array];
    for (PBGameItem *item in _items) {
        if (item.type == type) {
            [array addObject:item];
        }
    }
    
    if ([ConfigManager isInReviewVersion]) {
        return [self removeAdAndPurseItemInItems:array];
    }
    
    return array;
}

- (NSArray *)promotingItemsList
{
    NSMutableArray *array = [NSMutableArray array];
    for (PBGameItem *item in _items) {
        if ([item isPromoting]) {
            [array addObject:item];
        }
    }
    
    if ([ConfigManager isInReviewVersion]) {
        return [self removeAdAndPurseItemInItems:array];
    }
    
    return array;
}

- (PBGameItem *)itemWithItemId:(int)itemId
{
    
    for (PBGameItem *item in _items) {
        if (item.itemId == itemId) {
            return item;
        }
    }
    
    return nil;
}

- (int)priceWithItemId:(int)itemId
{
    return [[self itemWithItemId:itemId] promotionPrice];
}

- (PBGameCurrency)currencyWithItemId:(int)itemId
{
    return [[[self itemWithItemId:itemId] priceInfo] currency];
}

@end
