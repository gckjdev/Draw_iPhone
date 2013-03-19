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
#import "CommonItem.h"
#import "GameNetworkConstants.h"


typedef void (^BuyItemResultHandler)(int resultCode,  int itemId, int count, NSString *toUserId);

typedef void (^ConsumeItemResultHandler)(int resultCode, int itemId, BOOL isBuy);

@interface UserGameItemService : CommonService

+ (id)defaultService;

// for buy color.
- (void)buyItem:(int)itemId
          count:(int)count
     totalPrice:(int)totalPrice
       currency:(PBGameCurrency)currency
        handler:(BuyItemResultHandler)handler;

- (void)buyItem:(int)itemId
          count:(int)count
        handler:(BuyItemResultHandler)handler;

- (void)giveItem:(int)itemId
         toUser:(NSString *)userId
          count:(int)count
        handler:(BuyItemResultHandler)handler;

- (void)awardItem:(int)itemId
            count:(int)count
          handler:(BuyItemResultHandler)handler;

- (void)consumeItem:(int)itemId
              count:(int)count
           forceBuy:(BOOL)forceBuy
            handler:(ConsumeItemResultHandler)handler;

@end
