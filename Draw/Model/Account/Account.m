//
//  UserAccount.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Account.h"

@implementation UserAccount
@synthesize balance = _balance;

- (id)initWithBalance:(NSInteger)balance
{
    self = [super init];
    if (self) {
        self.balance = [NSNumber numberWithInt:balance];
    }
    return self;
}

#define KEY_BALANCE @"KEY_BALANCE"

//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:_balance forKey:KEY_BALANCE];
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        self.balance = [aDecoder decodeObjectForKey:KEY_BALANCE];
//    }
//    return self;
//}

//+ (UserAccount *)defaultAccount
//{
//    return [UserAccount accountWithBalance:3];
//}

//+ (UserAccount *)accountWithBalance:(NSInteger)balance
//{
//    return [[[UserAccount alloc] initWithBalance:balance] autorelease];
//}

//- (NSInteger)intBalanceValue
//{
//    return [self.balance intValue];
//}
@end
