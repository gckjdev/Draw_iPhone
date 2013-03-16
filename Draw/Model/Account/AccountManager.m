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
#import "SFHFKeychainUtils.h"

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


#define ACCOUNT_DICT        @"ACCOUNT_DICT"
#define KEY_BALANCE         @"KEY_BALANCE"
#define KEY_INGOT_BALANCE   @"KEY_INGOT_BALANCE"

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

- (NSInteger)getBalanceWithCurrency:(PBGameCurrency)currency
{
    switch (currency) {
        case PBGameCurrencyCoin:
            return [self getBalance];
            break;
            
        case PBGameCurrencyIngot:
            return [self getIngotBalance];
            break;
            
        default:
            break;
    }
}


- (NSInteger)getIngotBalance
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* balance = [defaults objectForKey:KEY_INGOT_BALANCE];
    return [balance intValue];
}

- (void)setIngotBalance:(int)balance
{
    PPDebug(@"<setIngotBalance> set balance to %d", balance);
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (balance < 0){
        PPDebug(@"<setIngotBalance> but balance < 0, set to 0");
        balance = 0;
    }
    [defaults setObject:[NSNumber numberWithInt:balance] forKey:KEY_INGOT_BALANCE];
    [defaults synchronize];
}


- (NSInteger)getBalance
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* balance = [defaults objectForKey:KEY_BALANCE];
    return [balance intValue];
}

- (void)updateAccount:(NSInteger)balance
{
    PPDebug(@"<updateAccount> set balance to %d", balance);
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (balance < 0){
        PPDebug(@"<updateAccount> but balance < 0, set to 0");
        balance = 0;
    }
    [defaults setObject:[NSNumber numberWithInt:balance] forKey:KEY_BALANCE];
    [defaults synchronize];
}


- (void)updateBalance:(int)balance
{
    PPDebug(@"<updateBalance> balance=%d", balance);
    [self updateAccount:balance];    
}

- (void)updateIngotBalance:(int)balance
{
    PPDebug(@"<updateIngotBalance> set balance to %d", balance);
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (balance < 0){
        PPDebug(@"<updateIngotBalance> but balance < 0, set to 0");
        balance = 0;
    }
    [defaults setObject:[NSNumber numberWithInt:balance] forKey:KEY_INGOT_BALANCE];
    [defaults synchronize];
}

- (void)updateBalance:(int)balance currency:(PBGameCurrency)currency
{
    switch (currency) {
        case PBGameCurrencyCoin:
            [self updateBalance:balance];
            break;

        case PBGameCurrencyIngot:
            [self updateIngotBalance:balance];
            break;
            
        default:
            break;
    }
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
    PPDebug(@"<decreaseBalance> minus %d, blance=%d", balance, [self getBalance]);    
}

- (BOOL)hasEnoughBalance:(int)amount
{
    if ([self getBalance] < amount){
        return NO;
    }
    else{
        return YES;
    }
}

- (BOOL)hasEnoughBalance:(int)amount currency:(PBGameCurrency)currency
{
    switch (currency) {
        case PBGameCurrencyCoin:
            return [self hasEnoughBalance:amount];
            break;
            
        case PBGameCurrencyIngot:
            return [self hasEnoughIngots:amount];
            break;
            
        default:
            break;
    }
}

- (BOOL)hasEnoughIngots:(int)amount
{
    if ([self getIngotBalance] < amount) {
        return NO;
    }else{
        return YES;
    }
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
