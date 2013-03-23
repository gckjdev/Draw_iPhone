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
#import "GameItemManager.h"

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
        EXECUTE_BLOCK(tempHandler, ERROR_BAD_PARAMETER, itemId, count, toUserId);
        [_blockArray releaseBlock:tempHandler];
        return;
    }
    
    if (![[AccountManager defaultManager] hasEnoughBalance:totalPrice currency:currency]) {
        EXECUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, itemId, count, toUserId);
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
            EXECUTE_BLOCK(tempHandler, result, itemId, count, toUserId);
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
- (void)buyItem:(int)itemId
          count:(int)count
        handler:(BuyItemResultHandler)handler
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    [self buyItem:item.itemId
            count:count
       totalPrice:([item promotionPrice] * count)
         currency:item.priceInfo.currency
          handler:handler];
}


- (void)giveItem:(int)itemId
          toUser:(NSString *)toUserId
           count:(int)count
         handler:(BuyItemResultHandler)handler
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
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
    BOOL isBuy = NO;
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[_blockArray copyBlock:handler];
    
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    if (item.consumeType != PBGameItemConsumeTypeAmountConsumable) {
        EXECUTE_BLOCK(tempHandler, ERROR_BAD_PARAMETER, itemId, NO);
        [_blockArray releaseBlock:tempHandler];
        return;
    }
    
    if (![[UserGameItemManager defaultManager] hasEnoughItemAmount:itemId amount:count]) {
        if (!forceBuy) {
            EXECUTE_BLOCK(tempHandler, ERROR_ITEM_NOT_ENOUGH, itemId, NO);
            [_blockArray releaseBlock:tempHandler];
            return;
        }
        
        int totalPrice = [item promotionPrice] * count;
        if (![[AccountManager defaultManager] hasEnoughBalance:totalPrice currency:item.priceInfo.currency]) {
            EXECUTE_BLOCK(tempHandler, ERROR_BALANCE_NOT_ENOUGH, itemId, NO);
            [_blockArray releaseBlock:tempHandler];
            return;
        }
        
        isBuy = YES;
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
            EXECUTE_BLOCK(tempHandler, result, itemId, isBuy);
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


@end
