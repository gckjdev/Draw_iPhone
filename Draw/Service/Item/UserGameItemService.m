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
#import "BlockArray.h"

#define KEY_USER_ITEM_INFO @"KEY_USER_ITEM_INFO"

@interface UserGameItemService()

@property (assign, nonatomic) BuyItemResultHandler buyItemResultHandler;
@property (copy, nonatomic) ConsumeItemResultHandler consumeItemResultHandler;
@property (retain, nonatomic) BlockArray *blockArray;

@end

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (id)init
{
    self = [super init];
    _blockArray = [[BlockArray alloc] init];
    return self;
}

- (void)dealloc
{
    PPRelease(_blockArray);
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
    BuyItemResultHandler tempHandler = (BuyItemResultHandler)[_blockArray copyBlock:handler];
        
    if (count <= 0) {
        EXCUTE_BLOCK(tempHandler, ERROR_BAD_PARAMETER, itemId, count, toUserId);
        [_blockArray releaseBlock:tempHandler];
        return;
    }
    
    if (![[AccountManager defaultManager] hasEnoughBalance:totalPrice currency:currency]) {
        EXCUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, itemId, count, toUserId);
        [_blockArray releaseBlock:tempHandler];
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
                
                [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
            }
            
            int result = output.resultCode;
            EXCUTE_BLOCK(tempHandler, result, itemId, count, toUserId);
            [bself.blockArray releaseBlock:tempHandler];
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
              count:(int)count
           forceBuy:(BOOL)forceBuy
            handler:(ConsumeItemResultHandler)handler;

{
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[_blockArray copyBlock:handler];
    
    PBGameItem *item = [[GameItemService defaultService] itemWithItemId:itemId];
    if (item.consumeType != PBGameItemConsumeTypeAmountConsumable) {
        EXCUTE_BLOCK(tempHandler, ERROR_BAD_PARAMETER, itemId);
        [_blockArray releaseBlock:tempHandler];
        return;
    }
    
    if (![[UserGameItemManager defaultManager] hasEnoughItemAmount:itemId amount:count]) {
        if (!forceBuy) {
            EXCUTE_BLOCK(tempHandler, ERROR_ITEM_NOT_ENOUGH, itemId);
            [_blockArray releaseBlock:tempHandler];
            return;
        }
        
        int totalPrice = [item promotionPrice] * count;
        if (![[AccountManager defaultManager] hasEnoughBalance:totalPrice currency:item.priceInfo.currency]) {
            EXCUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, itemId);
            [_blockArray releaseBlock:tempHandler];
            return;
        }
    }
    
    __block typeof (self) bself = self;
    
    int totalPrice = [item promotionPrice] * count;

    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest consumeItem:SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count forceBuy:forceBuy price:totalPrice currency:item.priceInfo.currency];
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            
            if (output.resultCode == 0) {
                @try {
                    if ([output.responseData length] > 0){
                        DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
                        PBGameUser *user = res.user;
                        
                        if (user != nil) {
                            [[AccountManager defaultManager] updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
                            [[AccountManager defaultManager] updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
                        }
                        
                        [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
                    }
                    else{
                        PPDebug(@"<consumeItem> response data nil");                        
                    }
                }
                @catch (NSException *exception) {
                    PPDebug(@"<consumeItem> catch exception=%@", [exception description]);
                }
                @finally {
                }
            }
            
            int result = output.resultCode;
            
            PPDebug(@"<execBlock> block=0x%X", tempHandler);
            EXCUTE_BLOCK(tempHandler, result, itemId);
            [bself.blockArray releaseBlock:tempHandler];
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
