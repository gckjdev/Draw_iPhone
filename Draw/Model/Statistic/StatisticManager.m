//
//  StatisticManager.m
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StatisticManager.h"

static StatisticManager *_globalStatisticManager;

@implementation StatisticManager

@synthesize feedCount;
@synthesize commentCount;
@synthesize drawToMeCount;
@synthesize messageCount;
@synthesize fanCount;
@synthesize roomCount;

+ (StatisticManager *)defaultManager
{
    if (_globalStatisticManager == nil) {
        _globalStatisticManager = [[StatisticManager alloc] init];
    }
    return _globalStatisticManager;
}

@end
