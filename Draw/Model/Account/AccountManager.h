//
//  AccountManager.h
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceService.h"
#import "Account.h"
#import "GameBasic.pb.h"

@class UserAccount;
@interface AccountManager : NSObject<PriceServiceDelegate>
{
    UserAccount *_account;
}


@property(retain, nonatomic) UserAccount *account;

+ (AccountManager *)defaultManager;

- (NSInteger)getBalance;            // for old, coins.
- (NSInteger)getBalanceWithCurrency:(PBGameCurrency)currency;

- (void)updateBalance:(int)balance;         // for old, coins.
- (void)updateBalance:(int)balance currency:(PBGameCurrency)currency;

- (void)increaseBalance:(NSInteger)balance sourceType:(BalanceSourceType)type;  // for old, coins.
- (void)decreaseBalance:(NSInteger)balance sourceType:(BalanceSourceType)type;  // for old, coins.

- (BOOL)hasEnoughBalance:(int)amount;
//- (BOOL)hasEnoughBalance:(int)amount currency:(PBGameCurrency)currency;

@end

extern AccountManager* GlobalGetAccountManager();
