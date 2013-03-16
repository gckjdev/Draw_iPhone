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
#import "PBGameItem+Extend.h"
#import "UserManager.h"
#import "BlockUtils.h"
#import "GameItemService.h"
#import "GameMessage.pb.h"
#import "NSDate+TKCategory.h"
#import "FeedService.h"
#import "GameConstants.h"
#import "DrawGameService.h"
#import "UserGameItemManager.h"

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemService()
{
    BuyItemResultHandler _buyItemResultHandler;
    ConsumeItemResultHandler _consumeItemResultHandler;
}
@property (retain, nonatomic) UserGameItemManager *userItemManager;

@end

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (void)dealloc
{
    RELEASE_BLOCK(_buyItemResultHandler);
    RELEASE_BLOCK(_consumeItemResultHandler);
    [_userItemManager release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        self.userItemManager = [UserGameItemManager defaultManager];
    }
    
    return self;
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
                
                [bself.userItemManager setUserItemList:user.itemsList];
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
    
    if (![_userItemManager hasEnoughItemAmount:itemId amount:count]) {
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
                [bself.userItemManager setUserItemList:user.itemsList];
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
