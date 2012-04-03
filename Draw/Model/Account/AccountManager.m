//
//  AccountManager.m
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountManager.h"
#import "Account.h"
#import "UserManager.h"
#import "PPDebug.h"
AccountManager* staticAccountManager = nil;
AccountManager* GlobalGetAccountManager()
{
    if (staticAccountManager == nil) {
        staticAccountManager = [[AccountManager alloc] init];
    }
    return staticAccountManager;
}

@implementation AccountManager
@synthesize account = _account;


#define ACCOUNT_DICT @"ACCOUNT_DICT"

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [_account release];
    [super dealloc];
}

+ (AccountManager *)defaultManager
{
    return GlobalGetAccountManager();
}

- (void)saveAccount:(UserAccount *)account forUserId:(NSString *)userId
{
    if (account == nil || userId == nil) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *ad = [defaults dictionaryForKey:ACCOUNT_DICT];
    if (ad == nil) {
        ad = [NSDictionary dictionaryWithObject:account.balance forKey:userId];
        [defaults setObject:ad forKey:ACCOUNT_DICT];
    }else{
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:ad];
        [dict setObject:account.balance forKey:userId];
    }
    [defaults synchronize];
}

- (UserAccount *)accountForUserId:(NSString *)userId
{
    if (userId == nil) {
        return nil;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *ad = [defaults dictionaryForKey:ACCOUNT_DICT];
    if (ad == nil) {
        return nil;
    }
    NSNumber *balance = [ad objectForKey:userId];
    if (balance == nil) {
        return nil;
    }
    return [UserAccount accountWithBalance:balance.integerValue];
}

- (UserAccount *)getUserAccount
{
    if (self.account == nil) {
        NSString *userId = [[UserManager defaultManager] userId];
        self.account = [self accountForUserId:userId];
    }
    return self.account;
}

- (NSInteger)getBalance
{
    return [[self getUserAccount] intBalanceValue];
}

- (void)updateAccount:(NSInteger)balance
{
    NSString *userId = [[UserManager defaultManager] userId];
    self.account = [UserAccount accountWithBalance:balance];
    [self saveAccount:self.account forUserId:userId];
    
}

- (void)updateAccountForServer
{
    NSString *userId = [[UserManager defaultManager] userId];
    [[PriceService defaultService] fetchAccountBalanceWithUserId:userId viewController:self];
    
}

- (void)increaseBalance:(NSInteger)balance sourceType:(BalanceSourceType)type
{
    NSInteger result = [self getBalance] + balance;
    [self updateAccount:result];    
    PPDebug(@"<increaseBalance> add %d, blance=%d", balance, [self getBalance]);
}


- (void)decreaseBalance:(NSInteger)balance sourceType:(BalanceSourceType)type
{
    NSInteger result = [self getBalance] - balance;
    if (result < 0){
        result = 0;
    }
    [self updateAccount:result];    
    PPDebug(@"<increaseBalance> add %d, blance=%d", balance, [self getBalance]);    
}

#pragma mark - Price Delegate

- (void)didFinishFetchAccountBalance:(NSInteger)balance resultCode:(int)resultCode
{
    if (resultCode == 0) {
        PPDebug(@"get balance : %d", balance);
        [self updateAccount:balance];
    }
}




@end
