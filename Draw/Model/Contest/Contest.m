//
//  Contest.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Contest.h"
#import "GameNetworkConstants.h"

@implementation Contest
//@synthesize contestId = _contestId;
//@synthesize startDate = _startDate;
//@synthesize endDate = _endDate;
//@synthesize version = _version;
//@synthesize type = _type;
//@synthesize status = _status;
//@synthesize participantCount = _participantCount;
//@synthesize opusCount = _opusCount;
//@synthesize contestUrl = _contestUrl;
//@synthesize title = _title;
//@synthesize statementUrl = _statementUrl;
//@synthesize canSubmitCount = _canSummitCount;

#define DEFAULT_CAN_SUMMIT_COUNT 1

- (NSString *)contestId
{
    return _pbContest.contestId;
}

- (NSDate *)startDate
{
    return [NSDate dateWithTimeIntervalSince1970:_pbContest.startDate];
}

- (NSDate *)endDate
{
    return [NSDate dateWithTimeIntervalSince1970:_pbContest.endDate];
}

- (NSDate *)voteStartDate
{
    return [NSDate dateWithTimeIntervalSince1970:_pbContest.voteStartDate];
}

- (NSDate *)voteEndDate
{
    return [NSDate dateWithTimeIntervalSince1970:_pbContest.voteEndDate];
}

//- (NSString *)version
//{
//    return _pbContest.;
//}
//
//- (ContestType)type
//{
//    return _pbContest.contestId;
//}

- (ContestStatus)status
{
    /*
     
     if ([self.startDate timeIntervalSinceNow] > 0) {
     self.status = ContestStatusPending;
     }else if([self.endDate timeIntervalSinceNow] < 0){
     self.status = ContestStatusPassed;
     }else {
     self.status = ContestStatusRunning;
     }
     
     */
    return _pbContest.status;
}

- (NSInteger)participantCount
{
    return _pbContest.participantCount;
}

- (NSInteger)opusCount
{
    return _pbContest.opusCount;
}

- (NSString *)title
{
    return _pbContest.title;
}

- (NSString *)contestUrl
{
    return _pbContest.contestUrl;
}

- (NSString *)statementUrl
{
    return _pbContest.statementUrl;
}

- (NSInteger)canSubmitCount
{
    int value = _pbContest.canSubmitCount;
    if (value <= 0) {
        return DEFAULT_CAN_SUMMIT_COUNT;
    }
    
    return value;
}


- (void)dealloc
{
    PPRelease(_pbContest);
    PPRelease(awardDict);
//    PPRelease(_contestId);
//    PPRelease(_startDate);
//    PPRelease(_endDate);
//    PPRelease(_version);
//    PPRelease(_title);
//    PPRelease(_contestUrl);
//    PPRelease(_statementUrl);
    
    [super dealloc];
}



- (NSInteger)intValueForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    NSString *obj = [dict objectForKey:key];
    return [obj integerValue];
}

- (id)initWithPBContest:(PBContest *)pbContest
{
    self = [super init];
    self.pbContest = pbContest;
    return self;
}

//- (id)initWithDict:(NSDictionary *)dict
//{       
//    self = [super init];
//    if (self) {
//        self.contestId = [dict objectForKey:PARA_CONTESTID];
//
//        if ([DeviceDetection isIPAD]) {
//        self.contestUrl = [dict objectForKey:PARA_CONTEST_IPAD_URL];
//        self.statementUrl = [dict objectForKey:PARA_STATEMENT_IPAD_URL];            
//        }else{
//            self.contestUrl = [dict objectForKey:PARA_CONTEST_URL];
//            self.statementUrl = [dict objectForKey:PARA_STATEMENT_URL];
//        }
//        self.title = [dict objectForKey:PARA_TITLE];
//        
//        self.opusCount = [self intValueForKey:PARA_OPUS_COUNT inDict:dict];
//        self.participantCount = [self intValueForKey:PARA_PARTICIPANT_COUNT inDict:dict];        
//        self.type = [self intValueForKey:PARA_TYPE inDict:dict];
//        
//        NSInteger startDate = [self intValueForKey:PARA_START_DATE inDict:dict];
//        NSInteger endDate = [self intValueForKey:PARA_END_DATE inDict:dict];
//        self.startDate = [NSDate dateWithTimeIntervalSince1970:startDate];
//        self.endDate = [NSDate dateWithTimeIntervalSince1970:endDate];
//        
//        if ([self.startDate timeIntervalSinceNow] > 0) {
//            self.status = ContestStatusPending;
//        }else if([self.endDate timeIntervalSinceNow] < 0){
//            self.status = ContestStatusPassed;
//        }else {
//            self.status = ContestStatusRunning;
//        }
//        
//        // init canSubmitCount for contest opus
//        self.canSubmitCount = DEFAULT_CAN_SUMMIT_COUNT;
//        NSNumber *number = [dict objectForKey:PARA_CAN_SUBMIT_COUNT];
//        if (number && number.integerValue > 0) {
//            self.canSubmitCount = number.integerValue;
//        }
//    }
//    return  self;
//}

- (NSString *)canSubmitCountKey
{
    return [NSString stringWithFormat:@"CAN_SUBMIT_%@",self.contestId];
}

- (NSString *)endDateKey
{
    return [NSString stringWithFormat:@"ENDATE_%@",self.contestId];
}


//- (void)setCanSubmitCount:(NSInteger)value
//{
//    _userCurrentCanSubmitCount = value;
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setInteger:_userCurrentCanSubmitCount forKey:[self canSubmitCountKey]];
//    [defaults synchronize];
//}

//- (NSInteger)userCurrentCanSubmitCount
//{
//    if (_userCurrentCanSubmitCount == 0) {
//        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//        _userCurrentCanSubmitCount = [defaults integerForKey:[self canSubmitCountKey]];
//        if(_userCurrentCanSubmitCount == 0){
//            return DEFAULT_CAN_SUMMIT_COUNT;
//        }
//    }
//    return _userCurrentCanSubmitCount;
//}

//- (void)setEndDate:(NSDate *)endDate
//{
//    if (_endDate != endDate) {
//        [_endDate release];
//        _endDate = [endDate retain];
//        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:endDate forKey:[self endDateKey]];
//        [defaults synchronize];
//    }
//}

//- (NSDate *)endDate
//{
//    if (_endDate == nil) {
//        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//        _endDate = [[defaults objectForKey:[self endDateKey]] retain];
//    }
//    return _endDate;
//
//}

//+ (Contest *)contestWithDict:(NSDictionary *)dict
//{
//    Contest *contest = [[[Contest alloc] initWithDict:dict] autorelease];
//    return contest;
//}

- (BOOL)isPassed
{
    return ([self.endDate timeIntervalSinceNow] <= 0 && [self.voteEndDate timeIntervalSinceNow] <= 0);
}

- (BOOL)isPending
{
    return ([self.startDate timeIntervalSinceNow] > 0);
}

- (BOOL)isRunning
{
    return ![self isPassed] && ![self isPending];
}
//
//- (ContestStatus)status
//{
//    if ([self.startDate timeIntervalSinceNow] > 0) {
//        _status = ContestStatusPending;
//    }else if([self.endDate timeIntervalSinceNow] < 0){
//        _status = ContestStatusPassed;
//    }else {
//        _status = ContestStatusRunning;
//    }
//    return _status;
//}

#define COMMIT_COUNT_PREFIX @"CommitCount"
- (void)incCommitCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@",COMMIT_COUNT_PREFIX,self.contestId];
    NSNumber *number = [defaults objectForKey:key];
    number = [NSNumber numberWithInt:number.intValue+1];
    [defaults setObject:number forKey:key];
    [defaults synchronize];
}

- (NSInteger)commitCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@",COMMIT_COUNT_PREFIX,self.contestId];
    NSNumber *number = [defaults objectForKey:key];
    NSInteger times = number.integerValue;
    return times;
}

- (BOOL)commitCountEnough
{
    NSInteger times = [self commitCount];
    return times >= self.canSubmitCount;
}

- (NSInteger)retainCommitChance
{
    NSInteger retainTimes = self.canSubmitCount - [self commitCount];
    return retainTimes > 0 ? retainTimes : 0;
}

- (BOOL)joined
{
    return [self commitCount] > 0;
}

- (NSArray *)awardList
{
    NSArray *winners = [self.pbContest winnerUsersList];
    NSArray *awards = [self.pbContest awardUsersList];
    NSMutableArray *was = [NSMutableArray array];
    [was addObjectsFromArray:winners];
    [was addObjectsFromArray:awards];
    return was;
}

- (NSArray *)awardOpusIdList
{
    NSArray *winners = [self.pbContest winnerUsersList];
    NSArray *awards = [self.pbContest winnerUsersList];
    NSMutableArray *was = [NSMutableArray array];
    [was addObjectsFromArray:winners];
    [was addObjectsFromArray:awards];
    NSMutableArray *ret = [NSMutableArray array];
    for (PBUserAward *awd in was) {
        if ([awd.opusId length] != 0) {
            [ret addObject:[[awd.opusId copy] autorelease]];
        }
    }
    return ret;
}

#define KEY(x,y) [NSString stringWithFormat:@"key_%d_%d",x,y]

- (ContestFeed *)findFeedById:(NSArray *)opusList opusId:(NSString *)opusId
{
    for (ContestFeed *feed in opusList) {
        if ([feed.feedId isEqualToString:opusId]) {
            return feed;
        }
    }
    return nil;
}

- (void)setAwardOpusList:(NSArray *)opusList
{
    if (awardDict == nil) {
        awardDict = [[NSMutableDictionary dictionary] retain];
    }else{
        [awardDict removeAllObjects];
    }
    NSArray *was = [self awardList];
    for (PBUserAward *awd in was) {
        NSString *key = KEY(awd.awardType.key, awd.rank);
        ContestFeed *opus = [self findFeedById:opusList opusId:awd.opusId];
        if (opus) {
            [awardDict setObject:opus forKey:key];
        }
    }
}

- (ContestFeed *)getOpusWithAwardType:(NSInteger)type rank:(NSInteger)rank
{
    return [awardDict objectForKey:KEY(type, rank)];
}

@end
