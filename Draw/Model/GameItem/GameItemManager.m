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
        NSString *path = [bundle pathForResource:SHOP_ITEMS_FILE_WITHOUT_SUFFIX ofType:SHOP_ITEM_FILE_TYPE];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.items = [[PBGameItemList parseFromData:data] itemsList];
    }
    
    return self;
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
