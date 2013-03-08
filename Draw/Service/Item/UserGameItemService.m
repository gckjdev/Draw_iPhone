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
#import "AccountService.h"
#import "PBGameItemUtils.h"

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);



- (void)buyItem:(PBGameItem*)item
          count:(int)count
        handler:(BuyItemResultHandler)handler
{
    if (count <= 0) {
        return;
    }
    
    int balance = [[AccountService defaultService] getBalanceWithCurrency:item.priceInfo.currency];
    int totalPrice = [item promotionPrice] * count;
    
    if (balance < totalPrice) {
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", balance, totalPrice);
        return;
    }

    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:item.itemId count:count price:totalPrice currency:item.priceInfo.currency toUser:nil];
        
        if (output.resultCode == 0) {
            NSDictionary *dict = [output jsonDataDict];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // if success, add user item locally
            [self addItem:item.itemId count:count];
            
            // if success update user ingot balance locally
            
            handler(output.resultCode, item.itemId, count, nil);
        });
    });
}

- (void)giveItem:(int)itemId
          toUser:(NSString *)toUserId
           count:(int)count
         handler:(BuyItemResultHandler)handler
{
    return ;
}

- (void)useItem:(int)itemId
         toOpus:(NSString *)toOpusId
        handler:(UseItemResultHandler)handler
{
    return;
}

- (void)clearAllUserItems
{
    
}

- (void)addItem:(int)itemId count:(int)count
{
    
}

@end
