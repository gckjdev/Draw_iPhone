//
//  AccountService.m
//  Draw
//
//  Created by  on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountService.h"
#import "PPDebug.h"
//#import "ShoppingManager.h"
#import "AccountManager.h"
#import "GameNetworkConstants.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "UserManager.h"
#import "GTMBase64.h"
#import "ItemManager.h"
#import "UserItem.h"
#import "TimeUtils.h"
#import "StoreKitUtils.h"
#import "TransactionReceiptManager.h"
#import "MobClick.h"
#import "UIDevice+IdentifierAddition.h"
#import "ConfigManager.h"
#import "UserService.h"
#import "LevelService.h"
#import "AdService.h"
#import "GameBasic.pb.h"
#import "IAPProductManager.h"
#import "UserGameItemManager.h"
#import "GameMessage.pb.h"
#import "UserGameItemService.h"
#import "CommonMessageCenter.h"
#import "BlockArray.h"
#import "UIUtils.h"
#import "SKProductManager.h"

#define DRAW_IAP_PRODUCT_ID_PREFIX @"com.orange."

@interface AccountService()
@property (nonatomic, retain) BlockArray *blockArray;


@end

@implementation AccountService

static AccountService* _defaultAccountService;

@synthesize delegate = _delegate;

- (void)dealloc
{
    [_delegate release];
    [_blockArray releaseAllBlock];
    [super dealloc];
}

+ (AccountService*)defaultService
{
    if (_defaultAccountService == nil)
        _defaultAccountService = [[AccountService alloc] init];
    
    return _defaultAccountService;
}

- (id)init
{
    self = [super init];
    
    self.blockArray = [[[BlockArray alloc] init] autorelease];
    _accountManager = [AccountManager defaultManager];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return self;
}


- (void)syncAccount:(id<AccountServiceDelegate>)delegate
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (userId == nil){
        return;
    }
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest syncUserAccontAndItem:SERVER_URL
                                                                         userId:userId
                                                                       deviceId:deviceId];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
<<<<<<< HEAD
                output.resultCode = res.resultCode;
                PBGameUser *user = res.user;
                
                if (res.resultCode == ERROR_SUCCESS && user != nil) {
=======
                
                if (res.resultCode == 0){
                    PBGameUser *user = res.user;
                    
>>>>>>> 6b9d702046c34aef158e1f309954c5124114b9d0
                    // sync balance from server
                    [_accountManager updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
                    [_accountManager updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
                    
                    // sync user item from server
                    [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
                    
                    // sync user level and exp
                    if ([user hasLevel] && [user hasExperience]){
                        [[LevelService defaultService] setLevel:user.level];
                        [[LevelService defaultService] setExperience:user.experience];
                    }
                    
                    // sync other user information, add by Benson 2013-04-02
                    [[UserManager defaultManager] storeUserData:user];
<<<<<<< HEAD
=======
                }
                else{
                    output.resultCode = res.resultCode;
>>>>>>> 6b9d702046c34aef158e1f309954c5124114b9d0
                }
            }
            
            if (output.resultCode == ERROR_SUCCESS) {
                if ([delegate respondsToSelector:@selector(didSyncFinish)]){
                    [delegate didSyncFinish];
                }
            }
            else{
                PPDebug(@"<syncAccountAndItem> FAIL, resultCode = %d", output.resultCode);
            }
        });
    });
    
}

- (void)syncAccountWithResultHandler:(SyncAccountResultHandler)resultHandler
{
    SyncAccountResultHandler tempHandler = (SyncAccountResultHandler)[_blockArray copyBlock:resultHandler];
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (userId == nil){
        EXECUTE_BLOCK(tempHandler, ERROR_BAD_PARAMETER);
        [_blockArray releaseBlock:tempHandler];
        return;
    }
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest syncUserAccontAndItem:SERVER_URL
                                                                         userId:userId
                                                                       deviceId:deviceId];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                DataQueryResponse *res = [DataQueryResponse parseFromData:output.responseData];
<<<<<<< HEAD
                output.resultCode = res.resultCode;
                PBGameUser *user = res.user;
                
                if (res.resultCode == ERROR_SUCCESS && user != nil) {
=======
                
                if (res.resultCode == 0){
                    PBGameUser *user = res.user;
                    
>>>>>>> 6b9d702046c34aef158e1f309954c5124114b9d0
                    // sync balance from server
                    [_accountManager updateBalance:user.coinBalance currency:PBGameCurrencyCoin];
                    [_accountManager updateBalance:user.ingotBalance currency:PBGameCurrencyIngot];
                    
                    // sync user item from server
                    [[UserGameItemManager defaultManager] setUserItemList:user.itemsList];
                }
<<<<<<< HEAD
=======
                else{
                    output.resultCode = res.resultCode;
                }
>>>>>>> 6b9d702046c34aef158e1f309954c5124114b9d0
            }
            
            EXECUTE_BLOCK(tempHandler, output.resultCode);
            [_blockArray releaseBlock:tempHandler];
        });
    });
}

#pragma mark - methods for buy coins and items

- (BOOL)hasEnoughBalance:(int)amount currency:(PBGameCurrency)currency
{
    return [[AccountManager defaultManager] hasEnoughBalance:amount currency:currency];
}

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               source:(BalanceSourceType)source
{
    switch (currency) {
        case PBGameCurrencyCoin:
            [self chargeCoin:count
                      source:source
                      toUser:[[UserManager defaultManager] userId]
                      byUser:[[UserManager defaultManager] userId]
               transactionId:nil
          transactionRecepit:nil
                   alixOrder:nil];
            break;
            
        case PBGameCurrencyIngot:
            [self chargeIngot:count
                       source:source
                       toUser:[[UserManager defaultManager] userId]
                       byUser:[[UserManager defaultManager] userId]
                transactionId:nil
           transactionRecepit:nil
                    alixOrder:nil];
            break;
            
        default:
            break;
    }
}

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               toUser:(NSString *)toUserId
               source:(BalanceSourceType)source
{
    switch (currency) {
        case PBGameCurrencyCoin:
            [self chargeCoin:count
                      source:source
                      toUser:toUserId
                      byUser:[[UserManager defaultManager] userId]
               transactionId:nil
          transactionRecepit:nil
                   alixOrder:nil];
            break;
            
        case PBGameCurrencyIngot:
            [self chargeIngot:count
                       source:source
                       toUser:toUserId
                       byUser:[[UserManager defaultManager] userId]
                transactionId:nil
           transactionRecepit:nil
             
                    alixOrder:nil];
            break;
            
        default:
            break;
    }
}

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               source:(BalanceSourceType)source
                order:(AlixPayOrder *)order
{
    [self chargeBalance:currency
                  count:count
                 toUser:[[UserManager defaultManager] userId]
                 source:source
                  order:order];
}

- (void)chargeBalance:(PBGameCurrency)currency
                count:(int)count
               toUser:(NSString *)toUserId
               source:(BalanceSourceType)source
                order:(AlixPayOrder *)order
{
    NSString *alixOrder = order.description;
    
    switch (currency) {
        case PBGameCurrencyCoin:
            [self chargeCoin:count
                      source:source
                      toUser:toUserId
                      byUser:[[UserManager defaultManager] userId]
               transactionId:nil
          transactionRecepit:nil
                   alixOrder:alixOrder];
            break;
            
        case PBGameCurrencyIngot:
            [self chargeIngot:count
                       source:source
                       toUser:toUserId
                       byUser:[[UserManager defaultManager] userId]
                transactionId:nil
           transactionRecepit:nil
                    alixOrder:order.description];
            break;
            
        default:
            break;
    }
}

- (void)chargeCoin:(int)amount
            source:(BalanceSourceType)source
{
    [self chargeCoin:amount
              source:source
       transactionId:nil
        transactionRecepit:nil];
}

- (void)chargeCoin:(int)amount
            toUser:(NSString *)userId
            source:(BalanceSourceType)source
{
    
    [self chargeCoin:amount
              source:source
              toUser:userId
              byUser:[[UserManager defaultManager] userId]
       transactionId:nil
  transactionRecepit:nil
           alixOrder:nil];
}

- (void)chargeCoin:(int)amount
            source:(BalanceSourceType)source
     transactionId:(NSString*)transactionId
transactionRecepit:(NSString*)transactionRecepit
{
    [self chargeCoin:amount
              source:source
              toUser:[[UserManager defaultManager] userId]
              byUser:[[UserManager defaultManager] userId]
       transactionId:transactionId
  transactionRecepit:transactionRecepit
           alixOrder:nil];
}

- (void)chargeCoin:(int)amount
            source:(BalanceSourceType)source
            toUser:(NSString*)toUserId
            byUser:(NSString*)byUserId
     transactionId:(NSString*)transactionId
transactionRecepit:(NSString*)transactionRecepit
         alixOrder:(NSString*)alixOrder
{
    if (amount <= 0) {
        return;
    }
    dispatch_async(workingQueue, ^{
        
        if ([self checkIAPReceiptBeforeCharge:transactionId
                           transactionRecepit:transactionRecepit
                                       source:source] == NO){
            return;
        }
        
        CommonNetworkOutput* output = nil;
        output = [GameNetworkRequest chargeCoin:SERVER_URL
                                         userId:toUserId
                                         amount:amount
                                         source:source
                                  transactionId:transactionId
                             transactionReceipt:transactionRecepit
                                         byUser:byUserId
                                      alixOrder:alixOrder];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                // update balance from server
                int coinBalance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:coinBalance currency:PBGameCurrencyCoin];
            }
            else{
                PPDebug(@"<chargeAccount> failure, result=%d", output.resultCode);
                if (output.resultCode == 70003 || output.resultCode == 70004){
                    PPDebug(@"<chargeAccount> fake IAP, refund money");
                }
            }
            
            if ([_delegate respondsToSelector:@selector(didFinishChargeCurrency:resultCode:)]) {
                [_delegate didFinishChargeCurrency:PBGameCurrencyCoin resultCode:output.resultCode];
            }
        });
    });    
}

- (void)deductCoin:(int)amount
               source:(BalanceSourceType)source
{
    if (amount <= 0) {
        return;
    }
    NSString* userId = [[UserManager defaultManager] userId];
        
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest deductCoin:SERVER_URL
                                            userId:userId 
                                            amount:amount 
                                            source:source];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                // update balance from server
                int coinBalance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:coinBalance currency:PBGameCurrencyCoin];
            }
            else{
                PPDebug(@"<deductCoin> failure, result=%d", output.resultCode);
            }
        });
    });    
}


- (void)chargeIngot:(int)amount
             source:(BalanceSourceType)source
{
    [self chargeIngot:amount
               toUser:[[UserManager defaultManager] userId]
               source:source];
}

- (void)chargeIngot:(int)amount
             toUser:(NSString*)userId
             source:(BalanceSourceType)source
{
    [self chargeIngot:amount
               source:source
               toUser:userId
               byUser:[[UserManager defaultManager] userId]
        transactionId:nil
   transactionRecepit:nil
            alixOrder:nil];
}

- (void)chargeIngot:(int)amount
             source:(BalanceSourceType)source
      transactionId:(NSString*)transactionId
 transactionRecepit:(NSString*)transactionRecepit
{
    [self chargeIngot:amount
               source:source
               toUser:[[UserManager defaultManager] userId]
               byUser:[[UserManager defaultManager] userId]
        transactionId:transactionId
   transactionRecepit:transactionRecepit
            alixOrder:nil];
}

- (void)chargeIngot:(int)amount
             source:(BalanceSourceType)source
             toUser:(NSString*)toUserId
             byUser:(NSString*)byUserId
      transactionId:(NSString*)transactionId
 transactionRecepit:(NSString*)transactionRecepit
          alixOrder:(NSString *)alixOrder
{
    dispatch_async(workingQueue, ^{
        
        if ([self checkIAPReceiptBeforeCharge:transactionId transactionRecepit:transactionRecepit source:source] == NO){
            return;
        }
        
        CommonNetworkOutput* output = nil;
        output = [GameNetworkRequest chargeIngot:SERVER_URL
                                          userId:toUserId
                                          amount:amount
                                          source:source
                                   transactionId:transactionId
                              transactionReceipt:transactionRecepit
                                          byUser:byUserId
                                       alixOrder:alixOrder];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                int ingotBalance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_INGOT_BALANCE] intValue];
                [[AccountManager defaultManager] updateBalance:ingotBalance currency:PBGameCurrencyIngot];
            }
            else{
                PPDebug(@"<chargeIngot> failure, result=%d", output.resultCode);
                if (output.resultCode == 70003 || output.resultCode == 70004){
                    PPDebug(@"<chargeAccount> fake IAP");
                }
            }
            
            if ([_delegate respondsToSelector:@selector(didFinishChargeCurrency:resultCode:)]) {
                [_delegate didFinishChargeCurrency:PBGameCurrencyIngot resultCode:output.resultCode];
            }
        });
    });
    
}

- (void)restoreIAPPurchase
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - Charge/Deduct Service to Server

- (void)retryVerifyReceiptAtBackground
{
    NSArray* retryList = [[TransactionReceiptManager defaultManager] findAllUnverfiedReceipts];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    if (queue == NULL)
        return;
    
    
    for (TransactionReceipt* receipt in retryList){
        NSString* receiptString = [NSString stringWithFormat:@"%@",receipt.transactionReceipt];
        dispatch_async(queue, ^{
            TransactionVerifyResult result = [StoreKitUtils verifyReceipt:receipt.transactionId
                                                       transactionReceipt:receiptString
                                                          productIdPrefix:DRAW_IAP_PRODUCT_ID_PREFIX];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == VERIFY_UNKNOWN){
                    PPDebug(@"<verifyReceiptWithAmount> UNKNOWN, Maybe Network Failure");
                    [[TransactionReceiptManager defaultManager] verifyUnknown:receipt];
                }
                else if (result == VERIFY_OK){
                    PPDebug(@"<verifyReceiptWithAmount> OK");
                    [[TransactionReceiptManager defaultManager] verifySuccess:receipt];
                }
                else{
                    PPDebug(@"<verifyReceiptWithAmount> FAIL, code=%d", result);
                    [[TransactionReceiptManager defaultManager] verifyFailure:receipt errorCode:result];
                }
            });
        });
    }
}

- (void)verifyReceiptWithAmount:(int)amount
                  transactionId:(NSString*)transactionId
             transactionRecepit:(NSString*)transactionRecepit
{
    dispatch_async(workingQueue, ^{
        
        TransactionVerifyResult result = VERIFY_UNKNOWN;
        result = [StoreKitUtils verifyReceipt:transactionId
                           transactionReceipt:transactionRecepit
                              productIdPrefix:DRAW_IAP_PRODUCT_ID_PREFIX];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == VERIFY_UNKNOWN){
                PPDebug(@"<verifyReceiptWithAmount> UNKNOWN, Maybe Network Failure");
                
                [[TransactionReceiptManager defaultManager] createReceipt:transactionId
                                                                productId:nil
                                                                   amount:amount
                                                       transactionReceipt:transactionRecepit];
            }
            else if (result == VERIFY_OK){
                PPDebug(@"<verifyReceiptWithAmount> OK");
            }
            else{
                PPDebug(@"<verifyReceiptWithAmount> FAIL, code=%d", result);
                
                [UIUtils alert:NSLS(@"kFakeIAPPurchase")];
            }
        });
    });
    
}



#define KEY_LAST_CHECKIN_DATE   @"KEY_LAST_CHECKIN_DATE"
#define MAX_CHECKIN_COINS       5

- (int)getCheckInMaxReward
{
    NSString* value = [MobClick getConfigParams:@"REWARD_CHECKIN"];
    int maxReward = 0;
    if ([value length] > 0){
        maxReward = [value intValue];
    }
    
    if (maxReward <= 0){
        maxReward = MAX_CHECKIN_COINS;
    }
    
    return maxReward;
}

- (int)checkIn
{
    
    int maxReward = [self getCheckInMaxReward];    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate* lastCheckInDate = [userDefaults objectForKey:KEY_LAST_CHECKIN_DATE];
    if (lastCheckInDate != nil && isLocalToday(lastCheckInDate)){
        // already check in, return -1
        PPDebug(@"<checkIn> but already do it today... come tomorrow :-)");
        return -1;
    }

    // random get some coins
    int coins = rand() % maxReward + 1;
    PPDebug(@"<checkIn> got %d coins", coins);
    [self chargeCoin:coins source:CheckInType];
    
    // update check in today flag
    [userDefaults setObject:[NSDate date] forKey:KEY_LAST_CHECKIN_DATE];
    [userDefaults synchronize];    
    return coins;
}

- (int)getBalanceWithCurrency:(PBGameCurrency)currency
{
    return [_accountManager getBalanceWithCurrency:currency];
}

#define SHARE_WEIBO_REWARD_COUNTER  @"SHARE_WEIBO_REWARD_COUNTER"
#define MAX_REWARD_FOR_SHARE_WEIBO  10

- (int)rewardForShareWeibo
{
    int counter = [[NSUserDefaults standardUserDefaults] integerForKey:SHARE_WEIBO_REWARD_COUNTER];
    if (counter >= MAX_REWARD_FOR_SHARE_WEIBO){
        return 0;
    }
    
    // award user
    [self chargeCoin:[ConfigManager getShareWeiboReward] source:ShareWeiboReward];
    
    // update counter
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:counter+1] forKey:SHARE_WEIBO_REWARD_COUNTER];

    // return award amount
    return [ConfigManager getShareWeiboReward];
}

#define SHARE_APP_REWARD_COUNTER  @"SHARE_APP_REWARD_COUNTER"
#define MAX_REWARD_FOR_SHARE_APP    10

- (void)rewardForShareApp
{
    int counter = [[NSUserDefaults standardUserDefaults] integerForKey:SHARE_APP_REWARD_COUNTER];
    if (counter >= MAX_REWARD_FOR_SHARE_APP){
        return;
    }
    
    [self chargeCoin:[ConfigManager getShareFriendReward] source:ShareAppReward];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:counter+1] forKey:SHARE_APP_REWARD_COUNTER];
}

#pragma mark - Charge Ingot

- (void)buyProduct:(PBIAPProduct*)product
{
    // send request to Apple IAP Server and wait for result
    
    SKProduct *selectedProduct = [[SKProductManager defaultManager] productWithId:product.appleProductId];

    
    PPDebug(@"<buyProduct> on product %@ price productId=%@",
            selectedProduct == nil ? product.appleProductId : [selectedProduct productIdentifier],
            product.appleProductId);
    
    SKPayment *payment = nil;
    if (selectedProduct == nil){
        payment = [SKPayment paymentWithProductIdentifier:product.appleProductId];
    }
    else{
        payment = [SKPayment paymentWithProduct:selectedProduct];
    }
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



- (BOOL)checkIAPReceiptBeforeCharge:(NSString*)transactionId
                 transactionRecepit:(NSString*)transactionRecepit
                             source:(BalanceSourceType)source
{
    if (source == PurchaseType){
        TransactionVerifyResult result = VERIFY_UNKNOWN;
        result = [StoreKitUtils verifyReceipt:transactionId
                           transactionReceipt:transactionRecepit
                              productIdPrefix:DRAW_IAP_PRODUCT_ID_PREFIX];
        
        if (result == VERIFY_FAKE_IAP){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDetectFakeIAP") delayTime:0];
            });
            return NO;
        }
        else if (result != VERIFY_OK){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kVerifyIAPFail") delayTime:0];
            });
            return NO;
        }
        
        return YES;
    }
    else{
        return YES;
    }

}





#pragma mark - IAP transaction handling

- (void)makeChargeCoinRequest:(int)amount transaction:(SKPaymentTransaction*)transaction
{
    NSString *base64receipt = [GTMBase64 stringByEncodingData:transaction.transactionReceipt];
    [self chargeCoin:amount
              source:PurchaseType
       transactionId:transaction.transactionIdentifier
  transactionRecepit:base64receipt];
}

- (void)makeChargeIngotRequest:(int)amount transaction:(SKPaymentTransaction*)transaction
{
    NSString *base64receipt = [GTMBase64 stringByEncodingData:transaction.transactionReceipt];
    [self chargeIngot:amount
               source:PurchaseType
        transactionId:transaction.transactionIdentifier
   transactionRecepit:base64receipt];
}


- (void)recordTransaction:(SKPaymentTransaction*)transaction
{
    PPDebug(@"<recordTransaction> transaction = %@ [%@]",
            transaction.transactionIdentifier,
            [transaction.transactionReceipt description]);
    
    NSString* productId  = transaction.payment.productIdentifier;
    PBIAPProduct* product = [[IAPProductManager defaultManager] productWithAppleProductId:productId];
    if (product.type == PBIAPProductTypeIapcoin){
        [self makeChargeCoinRequest:product.count transaction:transaction];
    }
    else if(product.type == PBIAPProductTypeIapingot) {
        [self makeChargeIngotRequest:product.count transaction:transaction];
    }else{
        
    }
}

- (void)provideContent:(NSString*)productId
{
    PPDebug(@"<provideContent> productId = %@", productId);
    
    if ([productId isEqualToString:[GameApp removeAdProductId]]){
        // Remove Ad IAP
        [[AdService defaultService] setAdDisable];
    }
    
    // update UI here
    int resultCode = PAYMENT_SUCCESS;
    if ([_delegate respondsToSelector:@selector(didFinishBuyProduct:)]){
        [_delegate didFinishBuyProduct:resultCode];
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    PPDebug(@"<completeTransaction> transaction = %@", transaction.transactionIdentifier);
    
    // Your application should implement these two methods.
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    PPDebug(@"<restoreTransaction> transaction = %@", transaction.transactionIdentifier);
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    PPDebug(@"<failedTransaction> error code = %d", transaction.error.code);
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // TODO display an error here to UI
        int resultCode = PAYMENT_FAILURE;
        if ([_delegate respondsToSelector:@selector(didFinishBuyProduct:)]){
            [_delegate didFinishBuyProduct:resultCode];
        }
    }
    else{
        int resultCode = PAYMENT_CANCEL;
        if ([_delegate respondsToSelector:@selector(didFinishBuyProduct:)]){
            [_delegate didFinishBuyProduct:resultCode];
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - IAP delegate methods

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        PPDebug(@"<updatedTransactions> productId=%@, transactionState=%d",
                transaction.payment.productIdentifier, transaction.transactionState);
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                if ([_delegate respondsToSelector:@selector(didProcessingBuyProduct:)]){
                    [_delegate didProcessingBuyProduct];
                }
                break;
            default:
                break;
        }
    }
}




// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    PPDebug(@"<removedTransactions> %@", [transactions description]);
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    PPDebug(@"<restoreCompletedTransactionsFailedWithError> %@", [error description]);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    PPDebug(@"<paymentQueueRestoreCompletedTransactionsFinished>");
}

@end
