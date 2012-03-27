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

AccountManager* staticAccountManager = nil;
AccountManager* GlobalGetAccountManager()
{
    if (staticAccountManager == nil) {
        staticAccountManager = [[AccountManager alloc] init];
    }
    return staticAccountManager;
}

@implementation AccountManager



#define ACCOUNT_DICT @"ACCOUNT_DICT"

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
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

- (UserAccount *)getAccount
{
    NSString *userId = [[UserManager defaultManager] userId];
    return [self accountForUserId:userId];
}

- (void)updateAccount:(NSInteger)balance
{
    NSString *userId = [[UserManager defaultManager] userId];
    [self saveAccount:[UserAccount accountWithBalance:balance] forUserId:userId];
}

@end
