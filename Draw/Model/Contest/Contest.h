//
//  Contest.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    
    ContestStatusPending = 1,
    ContestStatusRunning = 2,
    ContestStatusPassed = 3,    
}ContestStatus;

typedef enum{    
    ContestTypeFree = 1,
    ContestTypesTopic = 2,
    ContestTypeusWord = 3,    
    ContestTypeusWordList = 4,        
}ContestType;

@interface Contest : NSObject
{
    NSString *_contestId;
    NSDate *_startDate;
    NSDate *_endDate;
    NSString *_version;
    ContestType _type;
    ContestStatus _status;
    NSInteger _participantCount;
    NSInteger _opusCount;

    NSString *_title;
    NSString *_contestUrl;
    NSString *_statementUrl;
    NSInteger _canSummitCount;
}

//basic info
@property(nonatomic, retain) NSString *contestId;
@property(nonatomic, retain) NSDate *startDate;
@property(nonatomic, retain) NSDate *endDate;
@property(nonatomic, retain) NSString *version;
@property(nonatomic, assign) ContestType type;
@property(nonatomic, assign) ContestStatus status;
@property(nonatomic, assign) NSInteger participantCount;
@property(nonatomic, assign) NSInteger opusCount;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *contestUrl;
@property(nonatomic, retain) NSString *statementUrl;
@property(nonatomic, assign) NSInteger canSubmitCount;
- (id)initWithDict:(NSDictionary *)dict;
+ (Contest *)contestWithDict:(NSDictionary *)dict;
- (void)incCommitCount;
- (BOOL)commitCountEnough;
- (NSInteger)retainCommitChance;
- (BOOL)joined;
- (BOOL)isPassed;
- (BOOL)isPending;
- (BOOL)isRunning;
@end
