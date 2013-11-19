//
//  GroupManager.m
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import "GroupManager.h"


static GroupManager *_staticGroupManager = nil;

@interface GroupManager()

@end

@implementation GroupManager

- (void)dealloc
{
    PPRelease(_followedGroupIds);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.followedGroupIds = [NSMutableArray array];
    }
    return self;
}

+ (id)defaultManager
{
    if (_staticGroupManager == nil) {
        _staticGroupManager = [[GroupManager alloc] init];
    }
    return _staticGroupManager;
}

+ (NSInteger)capacityForLevel:(NSInteger)level
{
    return level * 10;
}

+ (NSInteger)monthlyFeeForLevel:(NSInteger)level
{
    return level * 100;
}

- (BOOL)followedGroup:(NSString *)groupId
{
    return [_followedGroupIds containsObject:groupId];
}

@end
