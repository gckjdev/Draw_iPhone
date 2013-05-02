//
//  UserGameItemManager.m
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import "UserGameItemManager.h"
#import "SynthesizeSingleton.h"
#import "NSDate+TKCategory.h"
#import "GameItemManager.h"
#import "ItemType.h"



static int *getDefaultItemTypeList()
{
    static int list[] = {
        ItemTypeNo,
        Pencil,
        Eraser,
        CanvasRectiPadDefault,
        CanvasRectiPhoneDefault,
        
        ItemTypeCustomDiceDefaultDice,
        
        ItemTypeListEndFlag
    };
    
    return list;
}

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemManager()

@property (retain, atomic) NSMutableArray *itemsList;

@end

@implementation UserGameItemManager

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemManager);

- (void)dealloc
{
    [_itemsList release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        _itemsList = [[NSMutableArray alloc] init];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ITEM_INFO];
        if (data != nil) {
            @try {
                [self.itemsList addObjectsFromArray:[[PBUserItemList parseFromData:data] userItemsList]];
            }
            @catch (NSException *exception) {
                PPDebug(@"catch exception while init item, exception = %@", [exception description]);
            }
            @finally {
            }
        }
    }
    
    return self;
}

- (void)setUserItemList:(NSArray *)itemsList
{
    PPDebug(@"<setUserItemList>");
    [_itemsList removeAllObjects];
    if (itemsList != nil){
        [_itemsList addObjectsFromArray:itemsList];
    }
//    self.itemsList = itemsList;
}

- (NSArray *)userItemsList
{
    return _itemsList;
}

- (void)save
{
    PBUserItemList_Builder *builder = [[[PBUserItemList_Builder alloc] init] autorelease];
    if (self.itemsList != nil){
        [builder addAllUserItems:self.itemsList];
    }
    PBUserItemList *itemList = [builder build];
    [[NSUserDefaults standardUserDefaults] setObject:[itemList data] forKey:KEY_USER_ITEM_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (PBUserItem *)userItemWithItemId:(int)itemId
{
    for (PBUserItem *userItem in self.itemsList) {
        if (userItem.itemId == itemId) {
            return userItem;
        }
    }
    
    return nil;
}

- (int)countOfItem:(int)itemId
{
    return [[self userItemWithItemId:itemId] count];
}

- (BOOL)hasEnoughItem:(int)itemId amount:(int)amount
{
    if ([self isDefaultItem:itemId]) {
        return YES;
    }
    return [self countOfItem:itemId] >= amount;
}

- (BOOL)isItemExpire:(PBUserItem *)userItem
{
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:userItem.expireDate];
    
    if ([[NSDate date] isBeforeDay:expireDate]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isDefaultItem:(int)itemType
{
    int *list = getDefaultItemTypeList();
    while (list != NULL && *list != ItemTypeListEndFlag) {
        if (*list == itemType) {
            return YES;
        }
        list ++;
    }
    return NO;
}

- (BOOL)hasItem:(int)itemId
{
    if (![self hasEnoughItem:itemId amount:1]) {
        return NO;
    }
    
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    
    switch (item.consumeType) {
        case PBGameItemConsumeTypeNonConsumable:
        case PBGameItemConsumeTypeAmountConsumable:
            return YES;
            break;
            
        case PBGameItemConsumeTypeTimeConsumable:
            return ![self isItemExpire:[self userItemWithItemId:itemId]];
            break;
            
        default:
            return YES;
            break;
    }
    
    return NO;
}

- (BOOL)canBuyItemNow:(PBGameItem *)item
{
    if (![self hasEnoughItem:item.itemId amount:1]) {
        return YES;
    }
    
    switch (item.consumeType) {
        case PBGameItemConsumeTypeNonConsumable:
            return NO;
            break;
            
        case PBGameItemConsumeTypeAmountConsumable:
        case PBGameItemConsumeTypeTimeConsumable:
            return YES;
            break;
            
        default:
            break;
    }
    
    return NO;
}


- (ItemType *)boughtPenTypeList
{
    
    static ItemType typeList[10] = {Pencil,ItemTypeListEndFlag};
    int i = Pencil+1, j = 1;
    for (; i < PenCount; i ++) {
        ItemType type = i;
        if ([self hasItem:type]) {
            typeList[j++] = type;
        }
    }
    typeList[j] = ItemTypeListEndFlag;
    return typeList;
}

@end
