//
//  ContestService.h
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "Contest.h"

typedef void (^ CreateContestBlock) (int resultCode, Contest *contest);


#define NOTIFCATION_CONTEST_DATA_CHANGE     @"NOTIFCATION_CONTEST_DATA_CHANGE"

typedef enum{
    ContestListTypeAll = 0,
    ContestListTypePassed = 1,
    ContestListTypeRunning = 2,
    ContestListTypePending = 3,
}ContestListType;

@protocol ContestServiceDelegate <NSObject>

@optional
- (void)didGetContestList:(NSArray *)contestList 
                     type:(ContestListType)type 
               resultCode:(NSInteger)code;

- (void)didGetMyContestList:(NSArray *)contestList 
               resultCode:(NSInteger)code;

- (void)didGetContestOpusList:(NSArray *)opusList
                   resultCode:(NSInteger)code;

@end

@interface ContestService : CommonService

+ (ContestService *)defaultService;
+ (void)releaseDefaultService;

- (void)getContestListWithType:(ContestListType)type
                        offset:(NSInteger)offset
                         limit:(NSInteger)limit
                      delegate:(id<ContestServiceDelegate>)delegate;

- (void)getGroupContestListWithType:(ContestListType)type
                             offset:(NSInteger)offset
                              limit:(NSInteger)limit
                           delegate:(id<ContestServiceDelegate>)delegate;

- (void)getContestListWithGroupId:(NSString*)groupId
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                         delegate:(id<ContestServiceDelegate>)delegate;

- (void)getMyContestListWithOffset:(NSInteger)offset
                         limit:(NSInteger)limit
                      delegate:(id<ContestServiceDelegate>)delegate;


- (NSArray*)getOngoingContestList;
- (void)syncOngoingContestList;

- (void)acceptContest:(NSString*)contestId;
- (long)newContestCount;



// 家族比赛
- (void)createContest:(Contest *)contest
                image:(UIImage *)image
            completed:(CreateContestBlock)completed;




@end
