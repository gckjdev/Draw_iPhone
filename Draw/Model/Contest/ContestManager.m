//
//  ContestManager.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestManager.h"
#import "Contest.h"

#define OLD_CONTEST_LIST @"old_contest_list"

static ContestManager *_staticContestManager;
@implementation ContestManager

+ (ContestManager *)defaultManager
{
    if (_staticContestManager == nil) {
        _staticContestManager = [[ContestManager alloc] init];
    }
    return _staticContestManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
        _oldContestIdList = [[userDefault objectForKey:OLD_CONTEST_LIST] retain];
        if (_oldContestIdList) {
            _oldContestIdList  = [[NSMutableSet alloc] init];
        }
    }
    return self;
}

- (NSArray *)parseContestList:(NSArray *)jsonArray
{
    if ([jsonArray count] != 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *dict in jsonArray) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                Contest *contest = [Contest contestWithDict:dict];
                [list addObject:contest];                
            }
        }        
        return list;
    }
    return nil;
}

- (int)calNewContestCount:(NSArray*)contestList
{
    int result = 0;
    for (Contest* contest in contestList) {
        if (![_oldContestIdList containsObject:contest.contestId]) {
            result++;
        }
    }
    return result;
}
- (void)updateHasReadContestList:(NSArray*)contestList
{
    for (Contest* contest in contestList) {
        [_oldContestIdList addObject:contest.contestId];
    }
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:_oldContestIdList forKey:OLD_CONTEST_LIST];
    [userDefault synchronize];
}
@end
