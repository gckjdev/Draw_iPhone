//
//  UserGameItemService.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "GameBasic.pb.h"

typedef enum {
    UIS_SUCCESS = 0,
    UIS_ERROR_NETWORK = 1,
    UIS_BALANCE_NOT_ENOUGH = 2,
    UIS_BAD_PARAMETER = 3,
    UIS_ITEM_NOT_ENOUGH = 4,
}BuyItemResultCode;

typedef void (^BuyItemResultHandler)(BuyItemResultCode resultCode,  int itemId, int count, NSString *toUserId);

typedef void (^ConsumeItemResultHandler)(int resultCode, int itemId);

@interface UserGameItemService : CommonService

+ (id)defaultService;

- (void)buyItem:(int)itemId
          count:(int)count
     totalPrice:(int)totalPrice
       currency:(PBGameCurrency)currency
        handler:(BuyItemResultHandler)handler;

- (void)buyItem:(PBGameItem*)item
          count:(int)count
        handler:(BuyItemResultHandler)handler;

- (void)giveItem:(PBGameItem*)itemId
         toUser:(NSString *)userId
          count:(int)count
        handler:(BuyItemResultHandler)handler;

- (void)awardItem:(int)itemId
            count:(int)count
          handler:(BuyItemResultHandler)handler;
        
- (void)consumeItem:(int)itemId
            handler:(ConsumeItemResultHandler)handler;



@end
