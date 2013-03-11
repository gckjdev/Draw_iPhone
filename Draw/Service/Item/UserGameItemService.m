//
//  UserGameItemService.m
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import "UserGameItemService.h"
#import "SynthesizeSingleton.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "AccountManager.h"
#import "PBGameItemUtils.h"
#import "UserItemInfo.h"
#import "UserManager.h"

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemService()

@property (retain, nonatomic) NSMutableArray *itemArr;

@end

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (void)dealloc
{
    [_itemArr release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        self.itemArr = [NSMutableArray array];

        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ITEM_INFO];
        if (data != nil) {
            for (PBUserItem *item in [[PBUserItemList parseFromData:data] userItemsList]) {
                [self.itemArr addObject:[UserItemInfo userItemInfoFromPBUserItem:item]];
            }
        }
    }
    
    return self;
}

- (void)clearAllUserItems
{
    [self.itemArr removeAllObjects];
}

- (void)save
{
    PBUserItemList_Builder *builder = [[[PBUserItemList_Builder alloc] init] autorelease];
    [builder setUserId:[[UserManager defaultManager] userId]];
    NSMutableArray *arr = [NSMutableArray array];
    for (UserItemInfo *userItem in self.itemArr) {
        [arr addObject:userItem.pbUserItem];
    }
    [builder addAllUserItems:arr];
    PBUserItemList *itemList = [builder build];
    [[NSUserDefaults standardUserDefaults] setObject:[itemList data] forKey:KEY_USER_ITEM_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UserItemInfo *)userItemWithItemId:(int)itemId
{
    for (UserItemInfo *userItem in self.itemArr) {
        if (userItem.pbUserItem.itemId == itemId) {
            return userItem;
        }
    }
    
    return nil;
}

- (int)countOfItem:(int)itemId
{
    return [[[self userItemWithItemId:itemId] pbUserItem] count];
}

- (PBUserItem *)pbUserItemWithItemId:(int)itemId
{
    PBUserItem_Builder *builder = [[[PBUserItem_Builder alloc] init] autorelease];
    [builder setItemId:itemId];
    [builder setCount:0];
    return [builder build];
}

- (void)setItem:(int)itemId count:(int)count
{
    UserItemInfo *userItem = [self userItemWithItemId:itemId];
    if (userItem == nil) {
        userItem = [UserItemInfo userItemInfoFromPBUserItem:[self pbUserItemWithItemId:itemId]];
        [self.itemArr addObject:userItem];
    }
    
    [userItem setCount:count];
    [self save];
}

- (void)increaseItem:(int)itemId count:(int)count
{
    [self setItem:itemId count:([self countOfItem:itemId] + count)];
}

- (void)decreaseItem:(int)itemId count:(int)count
{
    [self setItem:itemId count:MAX([self countOfItem:itemId]-count, 0)];
}

- (void)buyItem:(int)itemId
          count:(int)count
     totalPrice:(int)totalPrice
       currency:(PBGameCurrency)currency
        handler:(BuyItemResultHandler)handler
{
    if (count <= 0) {
        handler(UIS_BAD_PARAMETER, nil, count, [[UserManager defaultManager] userId]);
        return;
    }
    
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:currency];
    
    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        handler(UIS_BALANCE_NOT_ENOUGH, nil, count, [[UserManager defaultManager] userId]);
        return;
    }
    
    __block typeof (self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count price:totalPrice currency:currency toUser:[[UserManager defaultManager] userId]];
        
        if (output.resultCode == 0) {
            int coinsCount = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
            int ingotsCount = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_INGOT_BALANCE] intValue];
            [[AccountManager defaultManager] updateBalance:coinsCount currency:PBGameCurrencyCoin];
            [[AccountManager defaultManager] updateBalance:ingotsCount currency:PBGameCurrencyIngot];
            
            [bself increaseItem:itemId count:count];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UserGameItemServiceResultCode resultCode = 0;
            if (output.resultCode != 0) {
                resultCode = ERROR_NETWORK;
            }
            
            if (handler) {
                handler(output.resultCode, nil, count, [[UserManager defaultManager] userId]);
            }
        });
    });
}

- (void)buyItem:(PBGameItem*)item
          count:(int)count
        handler:(BuyItemResultHandler)handler
{
    
    if (count <= 0) {
        handler(UIS_BAD_PARAMETER, item, count, [[UserManager defaultManager] userId]);
        return;
    }
    
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:item.priceInfo.currency];
    int totalPrice = [item promotionPrice] * count;

    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        handler(UIS_BALANCE_NOT_ENOUGH, item, count, [[UserManager defaultManager] userId]);
        return;
    }
    
    __block typeof (self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:item.itemId count:count price:totalPrice currency:item.priceInfo.currency toUser:[[UserManager defaultManager] userId]];
        
        if (output.resultCode == 0) {
            int coinsCount = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
            int ingotsCount = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_INGOT_BALANCE] intValue];
            [[AccountManager defaultManager] updateBalance:coinsCount currency:PBGameCurrencyCoin];
            [[AccountManager defaultManager] updateBalance:ingotsCount currency:PBGameCurrencyIngot];
            
            [bself increaseItem:item.itemId count:count];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UserGameItemServiceResultCode resultCode = 0;
            if (output.resultCode != 0) {
                resultCode = ERROR_NETWORK;
            }
            
            if (handler) {
                handler(output.resultCode, item, count, [[UserManager defaultManager] userId]);
            }
        });
    });
}

- (void)giveItem:(PBGameItem *)item
          toUser:(NSString *)toUserId
           count:(int)count
         handler:(BuyItemResultHandler)handler
{
    if (count <= 0) {
        if (handler) {
            handler(UIS_BAD_PARAMETER, item, count, toUserId);
        }
        return;
    }
    
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:item.priceInfo.currency];
    int totalPrice = [item promotionPrice] * count;
    
    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        if (handler) {
            handler(UIS_BALANCE_NOT_ENOUGH, item, count, toUserId);
        }
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:item.itemId count:count price:totalPrice currency:item.priceInfo.currency toUser:toUserId];
        
        if (output.resultCode == 0) {
            int coinsCount = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
            int ingotsCount = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_INGOT_BALANCE] intValue];
            [[AccountManager defaultManager] updateBalance:coinsCount currency:PBGameCurrencyCoin];
            [[AccountManager defaultManager] updateBalance:ingotsCount currency:PBGameCurrencyIngot];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UserGameItemServiceResultCode resultCode = 0;
            if (output.resultCode != 0) {
                resultCode = ERROR_NETWORK;
            }
            if (handler) {
                handler(output.resultCode, item, count, toUserId);
            }
        });
    });
}

- (void)useItem:(PBGameItem *)item
         toOpus:(NSString *)toOpusId
        handler:(UseItemResultHandler)handler
{
    return;
}





@end
