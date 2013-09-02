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

- (NSArray *)parseContestList:(NSArray *)pbContestArray
{
    if ([pbContestArray count] != 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (PBContest* pbContest in pbContestArray) {
            if ([pbContest isKindOfClass:[PBContest class]]) {
                Contest *contest = [[Contest alloc] initWithPBContest:pbContest];
                [list addObject:contest];
                [contest release];
            }
        }
        return list;
    }
    return nil;
}

//- (NSArray *)parseContestList:(NSArray *)jsonArray
//{
//    if ([jsonArray count] != 0) {
//        NSMutableArray *list = [NSMutableArray array];
//        for (NSDictionary *dict in jsonArray) {
//            if ([dict isKindOfClass:[NSDictionary class]]) {
//                Contest *contest = [Contest contestWithDict:dict];
//                [list addObject:contest];
//            }
//        }
//        return list;
//    }
//    return nil;
//}

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

- (BOOL)isUser:(NSString *)userId judgeAtContest:(NSString *)contestId
{
    for (PBContest *contest in _ongoingContestList) {
        if ([contest.contestId isEqualToString:contestId]) {
            for (PBGameUser *user in contest.judgesList) {
                if ([user.userId isEqualToString:userId]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}
- (BOOL)isUser:(NSString *)userId reporterAtContest:(NSString *)contestId
{
    for (PBContest *contest in _ongoingContestList) {
        if ([contest.contestId isEqualToString:contestId]) {
            for (PBGameUser *user in contest.reportersList) {
                if ([user.userId isEqualToString:userId]) {
                    return YES;
                }
            }
        }
    }
    return NO;    
}

- (PBContest*)ongoingPBContestById:(NSString*)contestId
{
    if (contestId == nil)
        return nil;
    
    for (PBContest* contest in _ongoingContestList){
        if ([contestId isEqualToString:contest.contestId]){
            return contest;
        }
    }
    
    return nil;
}

- (Contest*)ongoingContestById:(NSString*)contestId
{
    PBContest* pbContest = [self ongoingPBContestById:contestId];
    if (pbContest == nil)
        return nil;
    
    return [[[Contest alloc] initWithPBContest:pbContest] autorelease];
}



- (BOOL)displayContestAnonymous:(NSString*)contestId
{
    if ([contestId length] == 0)
        return NO;
    
    for (PBContest* contest in _ongoingContestList){
        if ([contest.contestId isEqualToString:contestId]){
            return contest.isAnounymous;
        }
    }
    
    return NO;
}

- (BOOL)displayContestAnonymousForFeed:(DrawFeed*)drawFeed
{
    return [self displayContestAnonymous:drawFeed.contestId];
}

- (BOOL)canThrowFlower:(Contest*)contest defaultValue:(BOOL)defaultValue
{
    if (contest == nil){
        return defaultValue;
    }
    
    if ([contest canVote] == NO){
        PPDebug(@"contest cannot vote(send flower), time exceed");
        return NO;
    }
    
    int flowerUsed = [[UserManager defaultManager] flowersUsed:contest.contestId];
    if ([contest maxFlowerPerContest] <= flowerUsed){
        PPDebug(@"used flower times (%d) reach max flower per contest (%d) for contest (%@)",
                flowerUsed, [contest maxFlowerPerContest], contest.contestId);
        return NO;
    }
    
    return YES;    
}

@end
