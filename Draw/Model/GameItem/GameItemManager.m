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


#define SHOP_ITEMS_FILE_WITHOUT_SUFFIX @"shop_item"
#define SHOP_ITEM_FILE_TYPE @"pb"
#define SHOP_ITEMS_FILE_VERSION @"1.0"

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
        NSString *path = [bundle pathForResource:[GameItemManager shopItemsFileName] ofType:SHOP_ITEM_FILE_TYPE];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.items = [[PBGameItemList parseFromData:data] itemsList];
    }
    
    return self;
}

+ (NSString *)shopItemsFileName
{
    return [[[[SHOP_ITEMS_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp gameId]] stringByAppendingString:@"."] stringByAppendingString:[self shopItemsFileType]];
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
    return SHOP_ITEMS_FILE_VERSION;
}

- (void)setItemsList:(NSArray *)itemsList
{
    self.items = itemsList;
}

- (NSArray *)itemsList
{
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
    
    return array;
}

- (PBGameItem *)itemWithItemId:(int)itemId
{
    for (PBGameItem *item in _items) {
        if (item.itemId == itemId) {
            return [[PBGameItem builderWithPrototype:item] build];
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
