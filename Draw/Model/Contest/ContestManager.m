//
//  ContestManager.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012骞�__MyCompanyName__. All rights reserved.
//

#import "ContestManager.h"
#import "Contest.h"

#define OLD_CONTEST_LIST @"old_contest_list"

@interface ContestManager ()
@property (retain, nonatomic) NSMutableArray* oldContestIdList;

@end

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
        self.oldContestIdList = [userDefault objectForKey:OLD_CONTEST_LIST];
        if (_oldContestIdList == nil) {
            self.oldContestIdList  = [[[NSMutableArray alloc] init] autorelease];
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
        if (![self.oldContestIdList containsObject:contest.contestId]) {
            result++;
        }
    }
    return result;
}
- (void)updateHasReadContestList:(NSArray*)contestList
{
    for (Contest* contest in contestList) {
        [self.oldContestIdList addObject:contest.contestId];
    }
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.oldContestIdList forKey:OLD_CONTEST_LIST];
    [userDefault synchronize];
}
@end
