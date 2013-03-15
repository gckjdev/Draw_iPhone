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
#import "UserManager.h"
#import "BlockUtils.h"
#import "GameItemService.h"
#import "GameMessage.pb.h"
#import "NSDate+TKCategory.h"
#import "FeedService.h"
#import "GameConstants.h"
#import "DrawGameService.h"

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemService()
{
    BuyItemResultHandler _buyItemResultHandler;
    ConsumeItemResultHandler _consumeItemResultHandler;
}

@property (retain, nonatomic) NSArray *itemsList;

@end

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (void)dealloc
{
    [_itemsList release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_ITEM_INFO];
        if (data != nil) {
            self.itemsList = [[PBUserItemList parseFromData:data] userItemsList];
        }
    }
    
    return self;
}

- (void)setUserItemList:(NSArray *)itemsList
{
    self.itemsList = itemsList;
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

- (void)buyItem:(int)itemId
         toUser:(NSString *)toUserId
          count:(int)count
     totalPrice:(int)totalPrice
       currency:(PBGameCurrency)currency
{
    if (count <= 0) {
        EXCUTE_BLOCK(_buyItemResultHandler, UIS_BAD_PARAMETER, itemId, count, toUserId);
        RELEASE_BLOCK(_buyItemResultHandler);
        return;
    }
    
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:currency];
    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        EXCUTE_BLOCK(_buyItemResultHandler, UIS_BALANCE_NOT_ENOUGH, itemId, count, toUserId);
        RELEASE_BLOCK(_buyItemResultHandler);

        return;
    }
    
    __block typeof (self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count price:totalPrice currency:currency toUser:toUserId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
                PBGameUser *user = res.user;
                
                if (user != nil) {
                    [[AccountManager defaultManager] updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
                    
                    [[AccountManager defaultManager] updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
                }
                
                bself.itemsList = user.itemsList;
            }
            
            int result = (output.resultCode == ERROR_SUCCESS) ? UIS_SUCCESS : ERROR_NETWORK;
            EXCUTE_BLOCK(_buyItemResultHandler, result, itemId, count, toUserId);
            RELEASE_BLOCK(_buyItemResultHandler);
        });
    });
}


// for buy color.
- (void)buyItem:(int)itemId
          count:(int)count
     totalPrice:(int)totalPrice
       currency:(PBGameCurrency)currency
        handler:(BuyItemResultHandler)handler
{
    COPY_BLOCK(_buyItemResultHandler, handler);
    
    [self buyItem:itemId
           toUser:[[UserManager defaultManager] userId]
            count:count
       totalPrice:totalPrice
         currency:currency];
}


// new interface for buy item.
- (void)buyItem:(PBGameItem*)item
          count:(int)count
        handler:(BuyItemResultHandler)handler
{
    COPY_BLOCK(_buyItemResultHandler, handler);

    [self buyItem:item.itemId
            count:count
       totalPrice:([item promotionPrice] * count)
         currency:item.priceInfo.currency
          handler:handler];
}


- (void)giveItem:(PBGameItem *)item
          toUser:(NSString *)toUserId
           count:(int)count
         handler:(BuyItemResultHandler)handler
{
    COPY_BLOCK(_buyItemResultHandler, handler);
    
    [self buyItem:item.itemId
           toUser:toUserId
            count:count
       totalPrice:([item promotionPrice] * count)
         currency:item.priceInfo.currency];
}

- (void)consumeItem:(int)itemId
            handler:(ConsumeItemResultHandler)handler;
{
    COPY_BLOCK(_consumeItemResultHandler, handler);
    [self consumeItem:itemId count:1];
}

- (void)consumeItem:(int)itemId
              count:(int)count
{
    PBGameItem *item = [[GameItemService defaultService] itemWithItemId:itemId];
    if (item.consumeType != PBGameItemConsumeTypeAmountConsumable) {
        EXCUTE_BLOCK(_consumeItemResultHandler, UIS_BAD_PARAMETER, itemId);
        RELEASE_BLOCK(_consumeItemResultHandler);
        return;
    }
    
    if (![self hasEnoughItemAmount:itemId amount:count]) {
        EXCUTE_BLOCK(_consumeItemResultHandler, UIS_ITEM_NOT_ENOUGH, itemId);
        RELEASE_BLOCK(_consumeItemResultHandler);
        return;
    }
    
    __block typeof (self) bself = self;
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest useItem:SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == 0) {
                DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
                PBGameUser *user = res.user;
                bself.itemsList = user.itemsList;
            }
            
            int result = (output.resultCode == ERROR_SUCCESS) ? UIS_SUCCESS : ERROR_NETWORK;
            EXCUTE_BLOCK(_consumeItemResultHandler, result, itemId);
            RELEASE_BLOCK(_consumeItemResultHandler);
        });
    });
}

- (void)awardItem:(int)itemId
            count:(int)count
          handler:(BuyItemResultHandler)handler
{
    COPY_BLOCK(_buyItemResultHandler, handler);
    
    [self buyItem:itemId
           toUser:[[UserManager defaultManager] userId]
            count:count
       totalPrice:0
         currency:PBGameCurrencyCoin];
}


//- (void)sendItemAward:(int)itemId
//             toUserId:(NSString*)toUserId
//           feedOpusId:(NSString*)feedOpusId
//            isOffline:(BOOL)isOffline
//              forFree:(BOOL)isFree
//{
//    int awardAmount = 0;
//    int awardExp = 0;
//    NSString* targetUserId = nil;
//    
//    if (isOffline) {
//        
//        // prepare data for consumeItem request
//        targetUserId = toUserId;
//        awardAmount = [ItemManager awardAmountByItem:itemType];
//        awardExp = [ItemManager awardExpByItem:itemType];
//        
//        // send feed action
//        [[FeedService defaultService] throwItem:itemId
//                                         toOpus:feedOpusId
//                                         author:toUserId
//                                       delegate:nil];
//        
//    }else{
//        // send online request for online realtime play
//        int rankResult = (itemId == ItemTypeFlower) ? RANK_FLOWER : RANK_TOMATO;
//        [[DrawGameService defaultService] rankGameResult:rankResult];
//    }
//    
//    [[AccountService defaultService] consumeItem:itemId
//                                          amount:isFree?0:1
//                                    targetUserId:targetUserId
//                                     awardAmount:isFree?0:awardAmount
//                                        awardExp:isFree?0:awardExp];
//    
//}


@end
