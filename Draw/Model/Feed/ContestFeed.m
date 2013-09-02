//
//  ContestFeed.m
//  Draw
//
//  Created by  on 12-9-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestFeed.h"
#import "ConfigManager.h"
#import "ContestManager.h"

@implementation ContestFeed
@synthesize contestId = _contestId;
@synthesize contestScore = _contestScore;

- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super initWithPBFeed:pbFeed];
    if (self) {
        self.contestScore = [pbFeed contestScore];
        self.contestId = [pbFeed contestId];
        self.wordText = NSLS(@"kContestOpus");
        self.rankInfoList = pbFeed.rankInfoList;
    }
    return self;
}

#define KEY_CONTEST_ID @"CONTEST_ID"
#define KEY_CONTEST_SCORE @"CONTEST_SCORE"
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contestId = [aDecoder decodeObjectForKey:KEY_CONTEST_ID];
        self.contestScore = [aDecoder decodeIntegerForKey:KEY_CONTEST_SCORE];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.contestId forKey:KEY_CONTEST_ID];
    [aCoder encodeInteger:self.contestScore forKey:KEY_CONTEST_SCORE];
}

- (void)dealloc
{
    PPRelease(_contestId);
    PPRelease(_rankInfoList);
    [super dealloc];
}

- (NSInteger)itemLimit
{
    Contest* contest = [[ContestManager defaultManager] ongoingContestById:self.contestId];    
    if (contest == nil){
        return 0;
    }
    else{
        return [contest maxFlowerPerOpus];
    }
}


@end
