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

#define PAYMENT_SUCCESS 0
#define PAYMENT_FAILURE 1
#define PAYMENT_CANCEL  2

@class PriceModel;
@class ItemManager;
@class AccountManager;

typedef void (^SyncAccountResultHandler)(int resultCode);


@protocol AccountServiceDelegate <NSObject>

@optional
- (void)didFinishBuyProduct:(int)resultCode;
- (void)didProcessingBuyProduct;
- (void)didSyncFinish;

@end

@interface AccountService : CommonService<SKPaymentTransactionObserver>
{
    ItemManager *_itemManager;
    AccountManager *_accountManager;
}

@property (nonatomic, retain) NSObject<AccountServiceDelegate> *delegate;

+ (AccountService *)defaultService;

- (void)syncAccount:(id<AccountServiceDelegate>)delegate;

- (void)buyCoin:(PriceModel*)price;

// remove?
- (void)buyRemoveAd;

- (void)chargeAccount:(int)amount 
               source:(BalanceSourceType)source;

- (void)chargeAccount:(int)amount
               toUser:(NSString*)userId
               source:(BalanceSourceType)source;

- (void)deductAccount:(int)amount 
               source:(BalanceSourceType)source;

- (int)buyItem:(int)itemType
      itemCount:(int)itemCount
      itemCoins:(int)itemCoins;

- (int)consumeItem:(int)itemType
            amount:(int)amount;

- (int)consumeItem:(int)itemType
            amount:(int)amount
      targetUserId:(NSString*)targetUserId
       awardAmount:(int)awardAmount
          awardExp:(int)awardAmount;

- (BOOL)hasEnoughCoins:(int)amount;
- (BOOL)hasEnoughBalance:(int)amount currency:(PBGameCurrency)currency;

- (int)checkIn;

- (void)retryVerifyReceiptAtBackground;

- (int)rewardForShareWeibo;

- (void)awardAccount:(int)amount 
              source:(BalanceSourceType)source;

#pragma mark - Charge Ingot

- (void)buyIngot:(PBSaleIngot*)price;

- (void)chargeIngot:(int)amount
             source:(BalanceSourceType)source;

- (void)chargeIngot:(int)amount
             toUser:(NSString*)userId
             source:(BalanceSourceType)source;

@end
