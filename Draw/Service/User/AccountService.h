//
//  AccountService.h
//  Draw
//
//  Created by  on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import <StoreKit/StoreKit.h>
#import "Account.h"

#define PAYMENT_SUCCESS 0
#define PAYMENT_FAILURE 1
#define PAYMENT_CANCEL  2

#define ERROR_NO_PRODUCT            1000
#define ERROR_COINS_NOT_ENOUGH      1001
#define ERROR_ITEM_NOT_ENOUGH       1002

@class PriceModel;
@class ItemManager;
@class AccountManager;

@protocol AccountServiceDelegate <NSObject>

@optional
- (void)didFinishBuyProduct:(int)resultCode;
- (void)didProcessingBuyProduct;

@end

@interface AccountService : CommonService<SKPaymentTransactionObserver>
{
    ItemManager *_itemManager;
    AccountManager *_accountManager;
}

@property (nonatomic, retain) NSObject<AccountServiceDelegate> *delegate;

+ (AccountService *)defaultService;

- (void)syncAccountAndItem;

- (void)buyCoin:(PriceModel*)price;

- (void)chargeAccount:(int)amount 
               source:(BalanceSourceType)source 
        transactionId:(NSString*)transactionId
   transactionRecepit:(NSString*)transactionRecepit;

- (void)chargeAccount:(int)amount 
               source:(BalanceSourceType)source;

- (void)deductAccount:(int)amount 
               source:(BalanceSourceType)source;

- (int)buyItem:(int)itemType
      itemCount:(int)itemCount
      itemCoins:(int)itemCoins;

- (int)consumeItem:(int)itemType
            amount:(int)amount;

- (BOOL)hasEnoughCoins:(int)amount;
- (BOOL)hasEnoughItemAmount:(int)itemType amount:(int)amount;

- (int)checkIn;

- (void)retryVerifyReceiptAtBackground;

@end
