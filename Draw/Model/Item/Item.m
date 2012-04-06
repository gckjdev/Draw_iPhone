//
//  Item.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@implementation Item
@synthesize amount = _amount;
@synthesize type = _type;

- (id)initWithType:(int)type amount:(NSInteger)amount
{
    self = [super init];
    if (self) {
        self.type = type;
        self.amount = amount;
    }
    return self;
}

#define KEY_TYPE @"KEY_TYPE"
#define KEY_AMOUNT @"KEY_AMOUNT"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_type forKey:KEY_TYPE];
    [aCoder encodeInteger:_amount forKey:KEY_AMOUNT];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.type = [aDecoder decodeIntegerForKey:KEY_TYPE];
        self.amount = [aDecoder decodeIntegerForKey:KEY_AMOUNT];
    }
    return self;
}

+ (Item *)itemWithType:(int)type amount:(NSInteger)amount
{
    return [[[Item alloc] initWithType:type amount:amount]autorelease];
}
@end
