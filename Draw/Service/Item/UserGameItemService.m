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
#import "PPConfigManager.h"
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
#import "UserService.h"
#import "UserManager.h"

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
    if(self = [super init])
    {
        self.blockArray = [[[BlockArray alloc] init] autorelease];
    }
    
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
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:SERVER_URL appId:[PPConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count price:totalPrice currency:currency toUser:toUserId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS && output.responseData) {
                DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
                output.resultCode = res.resultCode;
                PBGameUser *user = res.user;

                if (res.resultCode == ERROR_SUCCESS && user != nil) {
                    [[AccountManager defaultManager] updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
                    [[AccountManager defaultManager] updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
                    [[UserGameItemManager defaultManager] setUserItemList:user.items];
                }
            }
            
            EXECUTE_BLOCK(tempHandler, output.resultCode, itemId, count, toUserId);
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

- (BOOL)hasEnoughBalanceToBuyItem:(int)itemId count:(int)count
{
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    int totalPrice = [item promotionPrice] * count;
    int balance = [[AccountManager defaultManager] getBalanceWithCurrency:item.priceInfo.currency];
    if (balance >= totalPrice) {
        return YES;
    }else{
        return NO;
    }
}

- (void)consumeItem:(int)itemId
              count:(int)count
{
    [self consumeItem:itemId count:count forceBuy:NO handler:NULL];
}

- (void)consumeItem:(int)itemId
              count:(int)count
           forceBuy:(BOOL)forceBuy
            handler:(ConsumeItemResultHandler)handler;
{

    if ([[UserManager defaultManager] hasUser] == NO){
        EXECUTE_BLOCK(handler, ERROR_USERID_NOT_FOUND, itemId, NO);
        return;
    }
    
    BOOL isBuy = NO;
    
    ConsumeItemResultHandler tempHandler = (ConsumeItemResultHandler)[_blockArray copyBlock:handler];
    
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemId];
    if (item.consumeType != PBGameItemConsumeTypeAmountConsumable) {
        EXECUTE_BLOCK(tempHandler, ERROR_BAD_PARAMETER, itemId, NO);
        [_blockArray releaseBlock:tempHandler];
        return;
    }
    
    if (![[UserGameItemManager defaultManager] hasEnoughItem:itemId amount:count]) {
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
        
        CommonNetworkOutput* output = [GameNetworkRequest consumeItem:SERVER_URL appId:[PPConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count forceBuy:forceBuy price:totalPrice currency:item.priceInfo.currency];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS && output.responseData) {
                DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
                output.resultCode = res.resultCode;
                PBGameUser *user = res.user;

                if (res.resultCode==ERROR_SUCCESS && user != nil){
                    [[AccountManager defaultManager] updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
                    [[AccountManager defaultManager] updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
                    [[UserGameItemManager defaultManager] setUserItemList:user.items];
                }else{
                    PPDebug(@"<consumeItem> response resultCode is not ERROR_SUCCESS");
                }
            }
            
            PPDebug(@"<execBlock> block=0x%X", tempHandler);
            EXECUTE_BLOCK(tempHandler, output.resultCode, itemId, isBuy);
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
