//
//  ContestService.h
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"

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

@end

@interface ContestService : CommonService

+ (ContestService *)defaultService;
+ (void)releaseDefaultService;

- (void)getContestListWithType:(ContestListType)type
                        offset:(NSInteger)offset
                         limit:(NSInteger)limit
                      delegate:(id<ContestServiceDelegate>)delegate;

- (void)getMyContestListWithOffset:(NSInteger)offset
                         limit:(NSInteger)limit
                      delegate:(id<ContestServiceDelegate>)delegate;


- (NSArray*)getOngoingContestList;
- (void)syncOngoingContestList;

@end
