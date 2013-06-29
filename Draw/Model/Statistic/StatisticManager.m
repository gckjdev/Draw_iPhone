//
//  StatisticManager.m
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StatisticManager.h"
#import "BulletinManager.h"

static StatisticManager *_globalStatisticManager;

@implementation StatisticManager

@synthesize feedCount;
@synthesize commentCount;
@synthesize drawToMeCount;
@synthesize messageCount;
@synthesize fanCount;
@synthesize roomCount;
@synthesize bbsActionCount;
//@synthesize bulletinCount;
@synthesize newContestCount;
@synthesize timelineOpusCount;
@synthesize timelineGuessCount;

+ (StatisticManager *)defaultManager
{
    if (_globalStatisticManager == nil) {
        _globalStatisticManager = [[StatisticManager alloc] init];
    }
    return _globalStatisticManager;
}

+ (NSString *)badgeStringFromIntValue:(int)badge
{
    if(badge <= 0){
        return nil;
    }
    if (badge < 100) {
        return [NSString stringWithFormat:@"%d",badge];
    }
    return @"N";
}

+ (NSString *)badgeStringFromLongValue:(long)badge
{
    if(badge <= 0){
        return nil;
    }
    if (badge < 100) {
        return [NSString stringWithFormat:@"%ld",badge];
    }
    return @"N";
}

- (int)bulletinCount
{
    return [[BulletinManager defaultManager] unreadBulletinCount];
}

@end
