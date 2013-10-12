//
//  ContestService.m
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestService.h"
//#import "BoardNetworkConstant.h"
#import "PPNetworkRequest.h"
#import "ContestManager.h"
#import "ConfigManager.h"
#import "GameNetworkRequest.h"
#import "UserManager.h"

static ContestService *_staticContestService;

@implementation ContestService

+ (ContestService *)defaultService
{
    if (_staticContestService == nil) {
        _staticContestService  = [[ContestService alloc] init];
    }
    return _staticContestService;
}
+ (void)releaseDefaultService
{
    PPRelease(_staticContestService);
}

- (void)getContestListWithType:(ContestListType)type
                        offset:(NSInteger)offset
                         limit:(NSInteger)limit
                      delegate:(id<ContestServiceDelegate>)delegate
{
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
                                PARA_TYPE : @(type),
                                PARA_OFFSET : @(offset),
                                PARA_COUNT : @(limit)
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
                                                                                parameters:para];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
             NSArray *contestList = nil;
            if (output.resultCode == 0 && output.pbResponse.contestListList){
                 contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
            }
            
            if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
                [delegate didGetContestList:contestList type:type resultCode:output.resultCode];
            }
            
        });
        
    });
    
//    dispatch_async(workingQueue, ^{
//        NSString *appId = [ConfigManager appId];
//        NSString *userId =[[UserManager defaultManager] userId];
//        int language = [[UserManager defaultManager] getLanguageType];
//        
//        CommonNetworkOutput *output = [GameNetworkRequest getContests:TRAFFIC_SERVER_URL
//                                                                appId:appId
//                                                               userId:userId 
//                                                                 type:type 
//                                                               offset:offset
//                                                                limit:limit 
//                                                             language:language];
//        NSInteger errorCode = output.resultCode;
//        NSArray *contestList = nil;
//
//        if (errorCode == ERROR_SUCCESS) {
//            contestList = [[ContestManager defaultManager] parseContestList:output.jsonDataArray];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
//                [delegate didGetContestList:contestList type:type resultCode:errorCode];
//            }
//        });        
//        
//    });

}

- (void)getMyContestListWithOffset:(NSInteger)offset
                             limit:(NSInteger)limit
                          delegate:(id<ContestServiceDelegate>)delegate
{
    
}

- (NSArray*)getOngoingContestList
{
    return [[ContestManager defaultManager] ongoingContestList];
}

- (void)syncOngoingContestList
{
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
                                PARA_TYPE : @(ContestListTypeRunning),
                                PARA_OFFSET : @(0),
                                PARA_COUNT : @(0)
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
                                                                                parameters:para];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == 0){
                [[ContestManager defaultManager] saveOngoingContestList:output.pbResponse.contestListList];                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFCATION_CONTEST_DATA_CHANGE object:nil];
            }
            
        });
        
    });
}

- (NSString*)getAccpetContestsKey
{
    return [NSString stringWithFormat:@"KEY_ACCEPT_CONTEST_LIST_%@", [[UserManager defaultManager] userId]];
}

- (BOOL)hasContestAccept:(NSString*)contestId
{
    if ([contestId length] == 0){
        return NO;
    }
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSArray* acceptContestArray = [ud objectForKey:[self getAccpetContestsKey]];
    if (acceptContestArray == nil){
        return NO;
    }
    
    NSUInteger index = [acceptContestArray indexOfObject:contestId];
    if (index == NSNotFound){
        return NO;
    }
    
    return YES;
}

- (void)acceptContest:(NSString*)contestId
{
    if (contestId == nil){
        return;
    }
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSArray* acceptContestArray = [ud objectForKey:[self getAccpetContestsKey]];
    
    NSMutableArray* newArray = [NSMutableArray array];
    [newArray addObject:contestId];
    if (acceptContestArray != nil){
        [newArray addObjectsFromArray:acceptContestArray];
    }

    PPDebug(@"<acceptContest> save %@", [newArray description]);
    [ud setObject:newArray forKey:[self getAccpetContestsKey]];
    [ud synchronize];
}

- (long)newContestCount
{
    long count = 0;
    
    NSArray* ongoingContestList = [[ContestManager defaultManager] ongoingContestList];
    for (PBContest* contest in ongoingContestList){
        if ([self hasContestAccept:contest.contestId] == NO){
            count ++;
        }
    }
    
    return count;
}


@end
