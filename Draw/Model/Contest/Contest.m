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
@synthesize contestId = _contestId;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize version = _version;
@synthesize type = _type;
@synthesize status = _status;
@synthesize participantCount = _participantCount;
@synthesize opusCount = _opusCount;
@synthesize contestUrl = _contestUrl;
@synthesize title = _title;
@synthesize statementUrl = _statementUrl;
@synthesize canSubmitCount = _canSummitCount;

#define DEFAULT_CAN_SUMMIT_COUNT 3

- (void)dealloc
{
    PPRelease(_contestId);
    PPRelease(_startDate);
    PPRelease(_endDate);
    PPRelease(_version);
    PPRelease(_title);
    PPRelease(_contestUrl);
    PPRelease(_statementUrl);
    
    [super dealloc];
}

/*
 
 {"dat":[{"tp":3,"tt":"猜猜画画11月赛","cid":"505835e6036496eb500bb46d","sd":1348390246,"ed":1348822246,"cu":"http://www.drawlively.com","su":"http://www.drawlively.com","oc":376,"pc":227,"lm":{"lvl":5,"oc":0}}],"ret":0}
 
 */



- (NSInteger)intValueForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    NSString *obj = [dict objectForKey:key];
    return [obj integerValue];
}

- (id)initWithDict:(NSDictionary *)dict
{       
    self = [super init];
    if (self) {
        self.contestId = [dict objectForKey:PARA_CONTESTID];

//        if ([DeviceDetection isIPAD]) {
        self.contestUrl = [dict objectForKey:PARA_CONTEST_IPAD_URL];
        self.statementUrl = [dict objectForKey:PARA_STATEMENT_IPAD_URL];            
//        }else{
//            self.contestUrl = [dict objectForKey:PARA_CONTEST_URL];
//            self.statementUrl = [dict objectForKey:PARA_STATEMENT_URL];
//        }
        self.title = [dict objectForKey:PARA_TITLE];
        
        self.opusCount = [self intValueForKey:PARA_OPUS_COUNT inDict:dict];
        self.participantCount = [self intValueForKey:PARA_PARTICIPANT_COUNT inDict:dict];        
        self.type = [self intValueForKey:PARA_TYPE inDict:dict];
        
        NSInteger startDate = [self intValueForKey:PARA_START_DATE inDict:dict];
        NSInteger endDate = [self intValueForKey:PARA_END_DATE inDict:dict];
        self.startDate = [NSDate dateWithTimeIntervalSince1970:startDate];
        self.endDate = [NSDate dateWithTimeIntervalSince1970:endDate];
        
        if ([self.startDate timeIntervalSinceNow] > 0) {
            self.status = ContestStatusPending;
        }else if([self.endDate timeIntervalSinceNow] < 0){
            self.status = ContestStatusPassed;
        }else {
            self.status = ContestStatusRunning;
        }
        self.canSubmitCount = DEFAULT_CAN_SUMMIT_COUNT;
        NSNumber *number = [dict objectForKey:PARA_CAN_SUBMIT_COUNT];
        if (number) {
            self.canSubmitCount = number.integerValue;
        }
    }
    return  self;
}

+ (Contest *)contestWithDict:(NSDictionary *)dict
{
    Contest *contest = [[[Contest alloc] initWithDict:dict] autorelease];
    return contest;
}
- (BOOL)isPassed
{
    return ([self.endDate timeIntervalSinceNow] < 0);
}
- (BOOL)isPending
{
    return ([self.startDate timeIntervalSinceNow] > 0);
}
- (BOOL)isRunning
{
    return ![self isPassed] && ![self isPending];
}

- (ContestStatus)status
{
    if ([self.startDate timeIntervalSinceNow] > 0) {
        _status = ContestStatusPending;
    }else if([self.endDate timeIntervalSinceNow] < 0){
        _status = ContestStatusPassed;
    }else {
        _status = ContestStatusRunning;
    }
    return _status;
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

- (BOOL)commintCountEnough
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

@end
