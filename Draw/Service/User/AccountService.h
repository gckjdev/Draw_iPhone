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
#import "GameBasic.pb.h"
#import "GameNetworkConstants.h"
#import "Order.h"
#import "AliPayManager.h"

@class AlixPayOrder;

#define VIP_BUY_TYPE_MONTH 1
#define VIP_BUY_TYPE_YEAR  2

#define PAYMENT_SUCCESS 0
#define PAYMENT_FAILURE 1
#define PAYMENT_CANCEL  2

#define NOTIFICATION_SYNC_ACCOUNT       @"NOTIFICATION_SYNC_ACCOUNT"

@class AccountManager;

typedef void (^SyncAccountResultHandler)(int resultCode);


@protocol AccountServiceDelegate <NSObject>

@optional
- (void)didFinishBuyProduct:(int)resultCode;
- (void)didProcessingBuyProduct;
- (void)didSyncFinish;
- (void)didFinishChargeCurrency:(PBGameCurrency)currency
                     resultCode:(int)resultCode;

@end

@interface AccountService : CommonService<SKPaymentTransactionObserver>
{
    AccountManager *_accountManager;
}

@property (nonatomic, retain) NSObject<AccountServiceDelegate> *delegate;

+ (AccountService *)defaultService;

- (void)syncAccount:(id<AccountServiceDelegate>)delegate;
- (void)syncAccountWithResultHandler:(SyncAccountResultHandler)resultHandler;

- (BOOL)hasEnoughBalance:(int)amount
                currency:(PBGameCurrency)currency;

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               source:(BalanceSourceType)source;

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               toUser:(NSString *)toUserId
               source:(BalanceSourceType)source;

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               source:(BalanceSourceType)source
                order:(AlixPayOrder *)order;

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               toUser:(NSString *)toUserId
               source:(BalanceSourceType)source
                order:(AlixPayOrder *)order;

- (void)chargeCoin:(int)amount 
            source:(BalanceSourceType)source;

- (void)chargeCoin:(int)amount
            toUser:(NSString*)userId
            source:(BalanceSourceType)source;

- (void)deductCoin:(int)amount
            source:(BalanceSourceType)source;

- (void)chargeIngot:(int)amount
             source:(BalanceSourceType)source;

- (void)chargeIngot:(int)amount
             toUser:(NSString*)userId
             source:(BalanceSourceType)source;

- (void)buyProduct:(PBIAPProduct*)product;

// remove?

- (int)checkIn;

- (void)retryVerifyReceiptAtBackground;

- (int)rewardForShareWeibo;

- (void)restoreIAPPurchase;

- (void)checkAndAskTakeCoins:(PPViewController*)viewController;

@end
