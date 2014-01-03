//
//  Contest.m
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Contest.h"
#import "GameNetworkConstants.h"
#import "TimeUtils.h"

@interface Contest()

@property (retain, nonatomic) PBContest_Builder *pbContestBuilder;

@end

@implementation Contest

#define DEFAULT_CAN_SUMMIT_COUNT 1

- (NSString *)contestId
{
    return _pbContestBuilder.contestId;

}

- (NSDate *)startDate
{
    return [NSDate dateWithTimeIntervalSince1970:_pbContestBuilder.startDate];
}

- (void)setStartDate:(NSDate *)startDate{
    
    NSTimeInterval interval = [startDate timeIntervalSince1970];
    [_pbContestBuilder setStartDate:interval];
}

- (NSDate *)endDate
{
    return [NSDate dateWithTimeIntervalSince1970:_pbContestBuilder.endDate];
}

- (void)setEndDate:(NSDate *)endDate{
    
    NSTimeInterval interval = [endDate timeIntervalSince1970];
    [_pbContestBuilder setEndDate:interval];
}

- (NSDate *)voteStartDate
{
    if (_pbContestBuilder.voteStartDate > 0){
        return [NSDate dateWithTimeIntervalSince1970:_pbContestBuilder.voteStartDate];
    }
    else{
        return self.startDate;
    }
}

- (NSDate *)voteEndDate
{
    if (_pbContestBuilder.voteEndDate > 0){
        return [NSDate dateWithTimeIntervalSince1970:_pbContestBuilder.voteEndDate];
    }
    else{
        return self.endDate;
    }
}

- (ContestStatus)status
{
    return _pbContestBuilder.status;
}

- (NSInteger)participantCount
{
    return _pbContestBuilder.participantCount;
}

- (NSInteger)opusCount
{
    return _pbContestBuilder.opusCount;
}

- (NSString *)title
{
    return _pbContestBuilder.title;
}

- (void)setTitle:(NSString *)title{
    
    [_pbContestBuilder setTitle:title];
}

- (NSString *)contestUrl
{
    return _pbContestBuilder.contestUrl;
}

- (NSString *)statementUrl
{
    return _pbContestBuilder.statementUrl;
}

- (NSInteger)canSubmitCount
{
    int value = _pbContestBuilder.canSubmitCount;
    if (value <= 0) {
        return DEFAULT_CAN_SUMMIT_COUNT;
    }
    
    return value;
}

#define DEFAULT_MAX_FLOWER_PER_OPUS         3
#define DEFAULT_MAX_FLOWER_PER_CONTEST      10000

- (NSInteger)maxFlowerPerOpus
{
    int value = _pbContestBuilder.maxFlowerPerOpus;
    if (value <= 0) {
        return DEFAULT_MAX_FLOWER_PER_OPUS;
    }
    
    return value;
}

- (NSInteger)maxFlowerPerContest
{
    int value = _pbContestBuilder.maxFlowerPerContest;
    if (value <= 0) {
        return DEFAULT_MAX_FLOWER_PER_CONTEST;
    }
    
    return value;
}

- (void)setRule:(NSString *)rule{
    
    [_pbContestBuilder setRule:rule];
}

- (BOOL)canSubmit
{
    if (_pbContestBuilder == nil){
        return NO;
    }
    
    if ([_pbContestBuilder canSubmit] == NO){
        return NO;
    }
    
    if (nowInDateRange(self.startDate, self.endDate) == 0){
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)canUserJoined:(NSString*)userId
{
    if (_pbContestBuilder == nil){
        return YES;
    }
    
    if (_pbContestBuilder.contestantsOnly == NO){
        return YES;
    }
    
    for (PBGameUser* contestant in _pbContestBuilder.contestantsList){
        if ([contestant.userId isEqualToString:userId]){
            return YES;
        }
    }

    return NO;
}

- (BOOL)canVote
{
    if (_pbContestBuilder == nil){
        return NO;
    }
    
    if ([_pbContestBuilder canVote] == NO){
        return NO;
    }

    if (nowInDateRange(self.voteStartDate, self.voteEndDate) == 0){
        return YES;
    }
    else{
        return NO;
    }
    
}

- (void)dealloc
{
    PPRelease(_pbContestBuilder);
    PPRelease(awardDict);
    
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
    self.pbContestBuilder = [PBContest builderWithPrototype:pbContest];
    return self;
}

- (PBContest *)pbContest{
    
    PBContest *pbContest = [_pbContestBuilder build];
    self.pbContestBuilder = [PBContest builderWithPrototype:pbContest];
    return pbContest;
}

- (NSString *)canSubmitCountKey
{
    return [NSString stringWithFormat:@"CAN_SUBMIT_%@",self.contestId];
}

- (NSString *)endDateKey
{
    return [NSString stringWithFormat:@"ENDATE_%@",self.contestId];
}

- (BOOL)isPassed
{
    return (_pbContestBuilder.status == ContestStatusPassed);

}

- (BOOL)isPending
{
    return (_pbContestBuilder.status == ContestStatusPending || _pbContestBuilder.status == ContestStatusDeleted);
}

- (BOOL)isRunning
{
    return (_pbContestBuilder.status == ContestStatusRunning);
}


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
    NSArray *awards = [self.pbContest awardUsersList];
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

- (NSData *)data{
    
    return [[self pbContest] data];
}

- (NSString *)leftTime{
 
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (_pbContestBuilder.startDate < now) {
        return NSLS(@"kContestNotStart");
    }else if (now >= _pbContestBuilder.startDate
              && now < _pbContestBuilder.endDate){
        
        NSTimeInterval left = _pbContestBuilder.endDate - now;
        return [self leftTimeStringWithLeftTime:left];
    }else{
        return NSLS(@"kContestIsOver");
    }
}

- (NSString *)leftTimeStringWithLeftTime:(NSTimeInterval)leftTime{
    
    if (leftTime >= 3600 * 24) {
        
        int days = leftTime / (3600 *24);
        return [NSString stringWithFormat:NSLS(@"kLeftDays"), days];
    }else if (leftTime >= 3600){
        
        int hours = leftTime / 3600;
        return [NSString stringWithFormat:NSLS(@"kLeftHours"), hours];
    }else{
        
        int mins = MAX(1, leftTime/60);
        return [NSString stringWithFormat:NSLS(@"kLeftMins"), mins];
    }
}

+ (Contest *)createGroupContestWithGroupId:(NSString *)groupId{
    
    Contest *contest = [[[Contest alloc] init] autorelease];
    contest.pbContestBuilder = [[[PBContest_Builder alloc] init] autorelease];
    [contest.pbContestBuilder setContestId:@""];
    [contest.pbContestBuilder setJoinersType:0];
    [contest.pbContestBuilder setCategory:[GameApp getCategory]];
    [contest.pbContestBuilder setCanSubmitCount:1];         // by default
    [contest.pbContestBuilder setMaxFlowerPerOpus:3];       // by default
    [contest.pbContestBuilder setMaxFlowerPerContest:6000]; // by default
    
    
    PBGroup_Builder *pbGroupBuilder = [[[PBGroup_Builder alloc] init] autorelease];
    [pbGroupBuilder setGroupId:groupId];
    [pbGroupBuilder setName:@""];

    [contest.pbContestBuilder setGroup:[pbGroupBuilder build]];
    
    NSDate *startDate = nextDate([NSDate date]);
    [contest.pbContestBuilder setStartDate:[startDate timeIntervalSince1970]];
    
    NSDate *endDate = [[[NSDate alloc] initWithTimeInterval:24*3600*7 sinceDate:startDate] autorelease];
    [contest.pbContestBuilder setEndDate:[endDate timeIntervalSince1970]];
    
    [contest.pbContestBuilder setVoteStartDate:startDate];          // by default
    [contest.pbContestBuilder setVoteEndDate:nextDate(endDate)];    // by default
    [contest.pbContestBuilder setIsAnounymous:YES];
    [contest.pbContestBuilder setContestantsOnly:NO];

    contest.pbContestBuilder = [PBContest builderWithPrototype:contest.pbContest];
    
    return contest;
}

- (void)setJoinersType:(int)type{
    
    [_pbContestBuilder setJoinersType:type];
}

- (NSString *)joinersTypeString{
    
    return [self getJoinersTypeString:[_pbContestBuilder joinersType]];
}

- (NSString *)getJoinersTypeString:(int)type{
    
    if (type <= 2) {
        
        return [[self joinersTypeStringArray] objectAtIndex:type];
    }else{
        
        return nil;
    }
}

- (NSArray *)joinersTypeStringArray{
    
    return @[NSLS(@"kEveryone"), NSLS(@"kGroupMember"), NSLS(@"kGroupMemberAndGuest")];
}

@end
