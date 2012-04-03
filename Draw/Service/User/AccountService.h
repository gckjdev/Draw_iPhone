//
//  AccountService.h
//  Draw
//
//  Created by  on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import <StoreKit/StoreKit.h>

#define PAYMENT_SUCCESS 0
#define PAYMENT_FAILURE 1
#define PAYMENT_CANCEL  2

#define ERROR_NO_PRODUCT    1000

@class ShoppingModel;

@protocol AccountServiceDelegate <NSObject>

@optional
- (void)didFinishBuyProduct:(int)resultCode;

@end

@interface AccountService : CommonService<SKPaymentTransactionObserver>

@property (nonatomic, retain) NSObject<AccountServiceDelegate> *delegate;

+ (AccountService *)defaultService;

- (void)buyCoin:(ShoppingModel*)price;

@end
