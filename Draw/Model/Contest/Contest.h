//
//  Contest.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContestFeed.h"

typedef enum{
    
    ContestStatusPending = PBContestStatusPending,
    ContestStatusRunning = PBContestStatusRunning,
    ContestStatusPassed = PBContestStatusPassed,
    ContestStatusDeleted = PBContestStatusDeleted
}ContestStatus;

typedef enum{    
    ContestTypeFree = 1,
    ContestTypesTopic = 2,
    ContestTypeusWord = 3,    
    ContestTypeusWordList = 4,        
}ContestType;

@interface Contest : NSObject
{
//    NSString *_contestId;
//    NSDate *_startDate;
//    NSDate *_endDate;
//    NSString *_version;
//    ContestType _type;
//    ContestStatus _status;
//    NSInteger _participantCount;
//    NSInteger _opusCount;
//
//    NSString *_title;
//    NSString *_contestUrl;
//    NSString *_statementUrl;
//    NSInteger _canSummitCount;
    NSMutableDictionary *awardDict;
}

//basic info
@property(nonatomic, retain) PBContest *pbContest;

@property(nonatomic, readonly) NSString *contestId;
@property(nonatomic, readonly) NSDate *startDate;
@property(nonatomic, readonly) NSDate *endDate;
@property(nonatomic, readonly) NSDate *voteStartDate;
@property(nonatomic, readonly) NSDate *voteEndDate;
//@property(nonatomic, readonly, retain) NSString *version;
//@property(nonatomic, readonly, assign) ContestType type;
@property(nonatomic, readonly) ContestStatus status;
@property(nonatomic, readonly) NSInteger participantCount;
@property(nonatomic, readonly) NSInteger opusCount;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *contestUrl;
@property(nonatomic, readonly) NSString *statementUrl;
@property(nonatomic, readonly) NSInteger canSubmitCount;
@property(nonatomic, readonly) NSInteger maxFlowerPerOpus;
@property(nonatomic, readonly) NSInteger maxFlowerPerContest;

@property(nonatomic, readonly) BOOL canSubmit;
@property(nonatomic, readonly) BOOL canVote;

//- (id)initWithDict:(NSDictionary *)dict;
//+ (Contest *)contestWithDict:(NSDictionary *)dict;

- (id)initWithPBContest:(PBContest*)pbContest;

- (void)incCommitCount;
- (BOOL)commitCountEnough;
- (NSInteger)retainCommitChance;
- (BOOL)joined;
- (BOOL)isPassed;
- (BOOL)isPending;
- (BOOL)isRunning;
- (NSArray *)awardList;
- (NSArray *)awardOpusIdList;
- (void)setAwardOpusList:(NSArray *)opusList;
- (ContestFeed *)getOpusWithAwardType:(NSInteger)type rank:(NSInteger)rank;
@end
