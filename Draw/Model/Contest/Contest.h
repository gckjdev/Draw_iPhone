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
    NSMutableDictionary *awardDict;
}

@property(nonatomic, readonly) NSString *contestId;
@property(nonatomic, assign) NSDate *startDate;
@property(nonatomic, assign) NSDate *endDate;
@property(nonatomic, readonly) NSDate *voteStartDate;
@property(nonatomic, readonly) NSDate *voteEndDate;
@property(nonatomic, readonly) ContestStatus status;
@property(nonatomic, readonly) NSInteger participantCount;
@property(nonatomic, readonly) NSInteger opusCount;
@property(nonatomic, assign) NSString *title;
@property(nonatomic, readonly) NSString *contestUrl;
@property(nonatomic, readonly) NSString *statementUrl;
@property(nonatomic, readonly) NSInteger canSubmitCount;
@property(nonatomic, readonly) NSInteger maxFlowerPerOpus;
@property(nonatomic, readonly) NSInteger maxFlowerPerContest;
@property(nonatomic, assign) NSString *rule;

@property(nonatomic, readonly) BOOL canSubmit;
@property(nonatomic, readonly) BOOL canVote;

- (id)initWithPBContest:(PBContest*)pbContest;

- (PBContest *)pbContest;

- (void)incCommitCount;
- (BOOL)commitCountEnough;
- (NSInteger)retainCommitChance;
- (BOOL)canUserJoined:(NSString*)userId;
- (BOOL)joined;
- (BOOL)isPassed;
- (BOOL)isPending;
- (BOOL)isRunning;
- (NSArray *)awardList;
- (NSArray *)awardOpusIdList;
- (void)setAwardOpusList:(NSArray *)opusList;
- (ContestFeed *)getOpusWithAwardType:(NSInteger)type rank:(NSInteger)rank;

- (NSData *)data;
- (NSString *)leftTime;

+ (Contest *)createGroupContestWithGroupId:(NSString *)groupId;

- (void)setJoinersType:(int)type;
- (NSString *)joinersTypeString;
- (NSArray *)joinersTypeStringArray;

@end
