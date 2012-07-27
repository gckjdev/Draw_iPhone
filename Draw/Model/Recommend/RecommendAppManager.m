//
//  RecommendAppManager.m
//  FootballScore
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendAppManager.h"
static RecommendAppManager* shareManager;

@implementation RecommendAppManager
@synthesize appList;

+ (RecommendAppManager*)defaultManager
{
    if (shareManager == nil) {
        shareManager = [[RecommendAppManager alloc] init];
    }
    return shareManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        appList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [appList release];
    [super dealloc];
}
@end
