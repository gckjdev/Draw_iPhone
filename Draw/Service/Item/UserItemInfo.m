//
//  UserItemInfo.m
//  Draw
//
//  Created by 王 小涛 on 13-3-9.
//
//

#import "UserItemInfo.h"

@implementation UserItemInfo

- (void)dealloc
{
    [_pbUserItem release];
    [super dealloc];
}

- (id)initWithPBUserItem:(PBUserItem *)pbUserItem
{
    if (self = [super init]) {
        self.pbUserItem = pbUserItem;
    }
    
    return self;
}

+ (id)userItemInfoFromPBUserItem:(PBUserItem *)pbUserItem
{
    return [[[self alloc] initWithPBUserItem:pbUserItem] autorelease];
}

- (void)setCount:(int)count
{
    self.pbUserItem = [[[PBUserItem builderWithPrototype:self.pbUserItem] setCount:count] build];
}


@end
