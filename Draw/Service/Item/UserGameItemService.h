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
}UserGameItemServiceResultCode;

typedef void (^BuyItemResultHandler)(UserGameItemServiceResultCode resultCode,  PBGameItem *item, int count, NSString *toUserId);

typedef void (^UseItemResultHandler)(int resultCode, PBGameItem *item, NSString *toOpusId);


@interface UserGameItemService : CommonService

+ (id)defaultService;

- (void)setItem:(int)itemId count:(int)count;
- (void)increaseItem:(int)itemId count:(int)count;
- (void)decreaseItem:(int)itemId count:(int)count;

- (int)countOfItem:(int)itemId;

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

- (void)useItem:(PBGameItem*)itemId
         toOpus:(NSString *)opusId
        handler:(UseItemResultHandler)handler;

- (void)clearAllUserItems;

@end
