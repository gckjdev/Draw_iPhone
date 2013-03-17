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
#import "GameItemService.h"

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
            [self.itemsList addObjectsFromArray:[[PBUserItemList parseFromData:data] userItemsList]];
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

- (void)save
{
    PBUserItemList_Builder *builder = [[[PBUserItemList_Builder alloc] init] autorelease];
    [builder addAllUserItems:self.itemsList];
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

- (BOOL)hasEnoughItemAmount:(int)itemId amount:(int)amount
{
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

- (BOOL)hasItem:(int)itemId
{
    if (![self hasEnoughItemAmount:itemId amount:1]) {
        return NO;
    }
    
    PBGameItem *item = [[GameItemService defaultService] itemWithItemId:itemId];
    
    switch (item.consumeType) {
        case PBGameItemConsumeTypeNonConsumable:
        case PBGameItemConsumeTypeAmountConsumable:
            return YES;
            break;
            
        case PBGameItemConsumeTypeTimeConsumable:
            return ![self isItemExpire:[self userItemWithItemId:itemId]];
            break;
            
        default:
            break;
    }
    
    return NO;
}

- (BOOL)canBuyItemNow:(PBGameItem *)item
{
    if (![self hasEnoughItemAmount:item.itemId amount:1]) {
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


@end
