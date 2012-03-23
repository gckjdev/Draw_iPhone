//
//  Account.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Account.h"

@implementation Account
@synthesize balance = _balance;

- (id)initWithBalance:(NSInteger)balance
{
    self = [super init];
    if (self) {
        self.balance = balance;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_balance forKey:@"Balance"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.balance = [aDecoder decodeIntegerForKey:@"Balance"];
    }
    return self;
}

@end
