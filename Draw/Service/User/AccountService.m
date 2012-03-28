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

- (void)buyCoin:(ShoppingModel*)price
{
    // send request to Apple IAP Server and wait for result
    SKProduct *selectedProduct = price.product;
    if (selectedProduct == nil){
        PPDebug(@"<buyCoin> but SKProduct of price is null");
        return;
    }
    PPDebug(@"<buyCoin> on product %@", [selectedProduct productIdentifier]);
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
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
    
    // TODO save data into local user account
    
    // send request to remote server
    
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
