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
#import "ConfigManager.h"
#import "AccountManager.h"
#import "PBGameItem+Extend.h"
#import "UserManager.h"
#import "BlockUtils.h"
#import "GameItemService.h"
#import "GameMessage.pb.h"
#import "GameConstants.h"
#import "UserGameItemManager.h"
#import "FlowerItem.h"

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemService()

@property (assign, nonatomic) BuyItemResultHandler buyItemResultHandler;
@property (assign, nonatomic) ConsumeItemResultHandler consumeItemResultHandler;

@end

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (void)dealloc
{
    RELEASE_BLOCK(_buyItemResultHandler);
    RELEASE_BLOCK(_consumeItemResultHandler);
    [super dealloc];
}

- (void)buyItem:(int)itemId
         toUser:(NSString *)toUserId
          count:(int)count
     totalPrice:(int)totalPrice
       currency:(PBGameCurrency)currency
        handler:(BuyItemResultHandler)handler
{
    RELEASE_BLOCK(_buyItemResultHandler);
    COPY_BLOCK(_buyItemResultHandler, handler);
    
    if (count <= 0) {
        EXCUTE_BLOCK(_buyItemResultHandler, ERROR_BAD_PARAMETER, itemId, count, toUserId);
        RELEASE_BLOCK(_buyItemResultHandler);
        return;
    }
    
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:currency];
    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        EXCUTE_BLOCK(_buyItemResultHandler, ERROR_BALANCE_NOT_ENOUGH, itemId, count, toUserId);
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
                
                for (PBUserItem *userItem in user.itemsList) {
                    PPDebug(@"itemId = %d, count = %d", userItem.itemId, userItem.count);
                }
                [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
            }
            
            int result = output.resultCode;
            EXCUTE_BLOCK(bself.buyItemResultHandler, result, itemId, count, toUserId);
            RELEASE_BLOCK(bself.buyItemResultHandler);
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
    [self buyItem:itemId
           toUser:[[UserManager defaultManager] userId]
            count:count
       totalPrice:totalPrice
         currency:currency
          handler:handler];
}


// new interface for buy item.
- (void)buyItem:(PBGameItem*)item
          count:(int)count
        handler:(BuyItemResultHandler)handler
{
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
    [self buyItem:item.itemId
           toUser:toUserId
            count:count
       totalPrice:([item promotionPrice] * count)
         currency:item.priceInfo.currency
          handler:handler];
}

- (void)consumeItem:(int)itemId
            handler:(ConsumeItemResultHandler)handler;
{
    [self consumeItem:itemId count:1 handler:handler];
}

- (void)consumeItem:(int)itemId
              count:(int)count
            handler:(ConsumeItemResultHandler)handler;

{
    RELEASE_BLOCK(_consumeItemResultHandler);
    COPY_BLOCK(_consumeItemResultHandler, handler);
    
    PBGameItem *item = [[GameItemService defaultService] itemWithItemId:itemId];
    if (item.consumeType != PBGameItemConsumeTypeAmountConsumable) {
        EXCUTE_BLOCK(_consumeItemResultHandler, ERROR_BAD_PARAMETER, itemId);
        RELEASE_BLOCK(_consumeItemResultHandler);
        return;
    }
    
    if (![[UserGameItemManager defaultManager] hasEnoughItemAmount:itemId amount:count]) {
        EXCUTE_BLOCK(_consumeItemResultHandler, ERROR_ITEM_NOT_ENOUGH, itemId);
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
                [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
            }
            
            int result = output.resultCode;
            EXCUTE_BLOCK(bself.consumeItemResultHandler, result, itemId);
            RELEASE_BLOCK(bself.consumeItemResultHandler);
        });
    });
}

- (void)awardItem:(int)itemId
            count:(int)count
          handler:(BuyItemResultHandler)handler
{
    RELEASE_BLOCK(_buyItemResultHandler);
    COPY_BLOCK(_buyItemResultHandler, handler);
    
    [self buyItem:itemId
           toUser:[[UserManager defaultManager] userId]
            count:count
       totalPrice:0
         currency:PBGameCurrencyCoin
          handler:handler];
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
//        
//
//    }
//    
//
//    [[AccountService defaultService] consumeItem:itemId
//                                          amount:isFree?0:1
//                                    targetUserId:targetUserId
//                                     awardAmount:isFree?0:awardAmount
//                                        awardExp:isFree?0:awardExp];
//    
//    FlowerItem *flower = [[[FlowerItem alloc] init] autorelease];
//    [flower acionWithParameters:parameters]
//    [self userItem:itemId itemAction:flower];
//}


//- (void)useItem:(int)itemId
//     itemAction:(id<ItemActionProtocol>)itemAction
//{
//    [self consumeItem:itemId handler:NULL];
//    if ([itemAction respondsToSelector:@selector(excuteAction)]) {
//        [itemAction excuteAction];
//    }
//}



@end
