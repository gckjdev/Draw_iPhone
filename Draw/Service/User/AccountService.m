//
//  AccountService.m
//  Draw
//
//  Created by  on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountService.h"
#import "ShoppingModel.h"
#import "PPDebug.h"
#import "ShoppingManager.h"
#import "AccountManager.h"
#import "GameNetworkConstants.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "UserManager.h"
#import "GTMBase64.h"
#import "ItemManager.h"
#import "UserItem.h"

@implementation AccountService

static AccountService* _defaultAccountService;

@synthesize delegate = _delegate;

- (void)dealloc
{
    [_delegate release];
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
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return self;
}

#pragma mark - methods for buy coins and items

- (void)buyCoin:(ShoppingModel*)price
{
    // send request to Apple IAP Server and wait for result
    SKProduct *selectedProduct = price.product;
    if (selectedProduct == nil){
        PPDebug(@"<buyCoin> but SKProduct of price is null");
        if ([self.delegate respondsToSelector:@selector(didFinishBuyProduct:)]){
            [self.delegate didFinishBuyProduct:ERROR_NO_PRODUCT];
        }
        return;
    }
    PPDebug(@"<buyCoin> on product %@", [selectedProduct productIdentifier]);
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - IAP transaction handling

- (void)makeBuyCoinsRequest:(ShoppingModel*)price transaction:(SKPaymentTransaction*)transaction
{
    int amount = [price count];
    NSString *base64receipt = [GTMBase64 stringByEncodingData:transaction.transactionReceipt];
    [self chargeAccount:amount 
                 source:PurchaseType 
          transactionId:transaction.transactionIdentifier
     transactionRecepit:base64receipt];
}

- (void)recordTransaction:(SKPaymentTransaction*)transaction
{
    PPDebug(@"<recordTransaction> transaction = %@ [%@]", 
            transaction.transactionIdentifier,
            [transaction.transactionReceipt description]);
    
    // TODO Must Record transactionIdentifier & transactionReceipt in server
    
    NSString* productId  = transaction.payment.productIdentifier;
    ShoppingModel* price = [[ShoppingManager defaultManager] findCoinPriceByProductId:productId];
    if (price == nil){
        PPDebug(@"<recordTransaction> but coin price is nil");
        return;
    }
        
    [self makeBuyCoinsRequest:price transaction:transaction];
}

- (void)provideContent:(NSString*)productId
{
    PPDebug(@"<provideContent> productId = %@", productId);    
    
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

#pragma mark - Charge/Deduct Service to Server

- (void)chargeAccount:(int)amount 
               source:(BalanceSourceType)source 
        transactionId:(NSString*)transactionId
   transactionRecepit:(NSString*)transactionRecepit
{
    NSString* userId = [[UserManager defaultManager] userId];
    
    // update balance locally
    [[AccountManager defaultManager] increaseBalance:amount sourceType:source]; 
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest chargeAccount:SERVER_URL 
                                            userId:userId 
                                            amount:amount 
                                            source:source 
                                     transactionId:transactionId 
                                transactionReceipt:transactionRecepit];
                
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                // update balance from server
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                if (balance != [[AccountManager defaultManager] getBalance]){
                    PPDebug(@"<deductAccount> balance not the same, local=%d, remote=%d", 
                            [[AccountManager defaultManager] getBalance], balance);
                }

            }
            else{
                PPDebug(@"<chargeAccount> failure, result=%d", output.resultCode);
            }
        });        
    });
}

- (void)chargeAccount:(int)amount 
               source:(BalanceSourceType)source
{
    [self chargeAccount:amount source:source transactionId:nil transactionRecepit:nil];
}

- (void)deductAccount:(int)amount 
               source:(BalanceSourceType)source
{
    NSString* userId = [[UserManager defaultManager] userId];
    
    // update balance locally
    [[AccountManager defaultManager] decreaseBalance:amount sourceType:source]; 
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest deductAccount:SERVER_URL 
                                            userId:userId 
                                            amount:amount 
                                            source:source];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                // update balance from server
                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
                if (balance != [[AccountManager defaultManager] getBalance]){
                    PPDebug(@"<deductAccount> balance not the same, local=%d, remote=%d", 
                            [[AccountManager defaultManager] getBalance], balance);
                }
            }
            else{
                PPDebug(@"<deductAccount> failure, result=%d", output.resultCode);
            }
        });        
    });    
}

- (void)syncItemRequest:(UserItem*)userItem
{
    
}

- (int)buyItem:(int)itemType
      itemCount:(int)itemCount
      itemCoins:(int)itemCoins
{
    
    if ([self hasEnoughCoins:itemCoins] == NO){
        PPDebug(@"<buyItem> but balance(%d) not enough, item cost(%d)", 
                [[AccountManager defaultManager] getBalance], itemCoins);
        return ERROR_COINS_NOT_ENOUGH;
    }
    
    // save item locally and synchronize remotely
    [[ItemManager defaultManager] increaseItem:itemType amount:itemCount];
    UserItem* userItem = [[ItemManager defaultManager] findUserItemByType:itemType];
    [self syncItemRequest:userItem];

    // deduct account
    [self deductAccount:itemCoins source:BuyItemType];    
    
    return 0;
}

- (int)consumeItem:(int)itemType
             amount:(int)amount
{
    if ([self hasEnoughItemAmount:itemType amount:amount] == NO){
        PPDebug(@"<consumeItem> but item amount(%d) not enough, consume count(%d)", 
                [[[[ItemManager defaultManager] findUserItemByType:itemType] amount] intValue], amount);
        return ERROR_ITEM_NOT_ENOUGH;
    }

    // TODO
    
    return 0;
}

- (BOOL)hasEnoughCoins:(int)amount
{
    return [[AccountManager defaultManager] hasEnoughBalance:amount];
}

- (BOOL)hasEnoughItemAmount:(int)itemType amount:(int)amount
{
    UserItem* userItem = [[ItemManager defaultManager] findUserItemByType:itemType];
    if (userItem == nil)
        return NO;
    
    return [[userItem amount] intValue] >= amount;
}

@end
