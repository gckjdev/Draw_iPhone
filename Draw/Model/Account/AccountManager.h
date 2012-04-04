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

@class UserAccount;
@interface AccountManager : NSObject<PriceServiceDelegate>
{
    UserAccount *_account;
}


@property(retain, nonatomic) UserAccount *account;
- (NSInteger)getBalance;
- (void)updateBalanceFromServer:(int)balance;
- (void)increaseBalance:(NSInteger)balance sourceType:(BalanceSourceType)type;
- (void)decreaseBalance:(NSInteger)balance sourceType:(BalanceSourceType)type;
- (NSInteger)getBalance;
+ (AccountManager *)defaultManager;
- (BOOL)hasEnoughBalance:(int)amount;

@end

extern AccountManager* GlobalGetAccountManager();
