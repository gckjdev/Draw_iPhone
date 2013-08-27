//
//  ContestManager.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contest;

@interface ContestManager : NSObject {
}

@property (nonatomic, retain) NSMutableArray* ongoingContestList;

+ (ContestManager *)defaultManager;
- (NSArray *)parseContestList:(NSArray *)jsonArray;

- (int)calNewContestCount:(NSArray*)contestList;
- (void)updateHasReadContestList:(NSArray*)contestList;

- (void)saveOngoingContestList:(NSArray*)newList;

- (BOOL)isUser:(NSString *)userId judgeAtContest:(NSString *)contestId;
- (BOOL)isUser:(NSString *)userId reporterAtContest:(NSString *)contestId;

// 比赛是否匿名显示
- (BOOL)displayContestAnonymous:(NSString*)contestId;

// 根据contestId返回正在进行中的contest
- (Contest*)ongoingContestById:(NSString*)contestId;

@end
