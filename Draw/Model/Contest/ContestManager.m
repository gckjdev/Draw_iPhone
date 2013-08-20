//
//  ContestManager.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012骞�__MyCompanyName__. All rights reserved.
//

#import "ContestManager.h"
#import "Contest.h"

#define OLD_CONTEST_LIST            @"old_contest_list"
#define KEY_ONGOING_CONTEST_LIST    @"KEY_ONGOING_CONTEST_LIST"

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
        
        _ongoingContestList = [[NSMutableArray alloc] init];
        [self loadOngoingContestList];
    }
    return self;
}

- (void)loadOngoingContestList
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSData* data = [userDefault objectForKey:KEY_ONGOING_CONTEST_LIST];
    
    if (data == nil){
        PPDebug(@"<loadOngoingContestList> no contest data");
        return;
    }
    
    @try {
        PBContestList* list = [PBContestList parseFromData:data];
        [self.ongoingContestList addObjectsFromArray:[list contestsList]];
        PPDebug(@"<loadOngoingContestList> total %d contest loaded", [self.ongoingContestList count]);
    }
    @catch (NSException *exception) {
        PPDebug(@"<loadOngoingContestList> catch exception (%@)", [exception description]);
    }
    @finally {
        
    }    
}

- (void)saveOngoingContestList:(NSArray*)newList
{
    [self.ongoingContestList removeAllObjects];
    if (newList){
        [self.ongoingContestList addObjectsFromArray:newList];
    }
    
    PBContestList_Builder* builder = [PBContestList builder];
    for (PBContest* contest in self.ongoingContestList){
        [builder addContests:contest];
    }
    
    NSData* data = [[builder build] data];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:data forKey:KEY_ONGOING_CONTEST_LIST];
    [userDefault synchronize];
    
    PPDebug(@"<saveOngoingContestList> total %d contest added", [newList count]);
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
