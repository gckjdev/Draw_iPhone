//
//  ContestFeed.m
//  Draw
//
//  Created by  on 12-9-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestFeed.h"

@implementation ContestFeed
@synthesize contestId = _contestId;
@synthesize contestScore = _contestScore;

- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super initWithPBFeed:pbFeed];
    if (self) {
        self.contestScore = [pbFeed contestScore];
        self.contestId = [pbFeed contestId];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_contestId);
    [super dealloc];
}

#define ITEM_TIME_LIMIT 1

- (NSInteger)itemLimit
{
    return 1;
}


@end
