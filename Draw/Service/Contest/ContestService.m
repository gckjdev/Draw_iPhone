//
//  ContestService.m
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestService.h"
#import "PPNetworkRequest.h"
#import "ContestManager.h"
#import "PPConfigManager.h"
#import "GameNetworkRequest.h"
#import "UserManager.h"
#import "UIImageExt.h"

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

//- (void)getContestListWithType:(ContestListType)type
//                        offset:(NSInteger)offset
//                         limit:(NSInteger)limit
//                      delegate:(id<ContestServiceDelegate>)delegate
//{
//    
//    dispatch_async(workingQueue, ^{
//        
//        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
//                                PARA_TYPE : @(type),
//                                PARA_OFFSET : @(offset),
//                                PARA_COUNT : @(limit)
//                                };
//        
//        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
//                                                                                parameters:para];        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//             NSArray *contestList = nil;
//            if (output.resultCode == 0 && output.pbResponse.contestListList){
//                 contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
//                if (type == ContestListTypeAll) {
//                    [[ContestManager defaultManager] setAllContestList:output.pbResponse.contestListList];
//                }
//            }
//            
//            if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
//                [delegate didGetContestList:contestList type:type resultCode:output.resultCode];
//            }
//            
//        });
//        
//    });
//}

- (void)getContestListWithType:(ContestListType)type
                        offset:(NSInteger)offset
                         limit:(NSInteger)limit
                     completed:(GetContestListBlock)completed
{
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
                                PARA_TYPE : @(type),
                                PARA_OFFSET : @(offset),
                                PARA_COUNT : @(limit)
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
                                                                                parameters:para];
        
        NSArray *contestList = nil;
        if (output.resultCode == 0 && output.pbResponse.contestListList){
            contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
            if (type == ContestListTypeAll) {
                [[ContestManager defaultManager] setAllContestList:output.pbResponse.contestListList];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            EXECUTE_BLOCK(completed, output.resultCode, type, contestList);
        });
    });
}

//- (void)getContestListWithGroupId:(NSString*)groupId
//                           offset:(NSInteger)offset
//                            limit:(NSInteger)limit
//                         delegate:(id<ContestServiceDelegate>)delegate
//{
//    
//    PPDebug(@"<getContestListWithGroupId> groupId=%@", groupId);
//
//    if (groupId == nil){
//        
//        if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
//            [delegate didGetContestList:nil type:ContestListTypeAll resultCode:0];
//        }
//        
//        return;
//    }
//    
//    dispatch_async(workingQueue, ^{
//        
//        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
//                                PARA_GROUPID : groupId,
//                                PARA_OFFSET : @(offset),
//                                PARA_COUNT : @(limit),
//                                };
//        
//        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
//                                                                                parameters:para];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSArray *contestList = nil;
//            if (output.resultCode == 0 && output.pbResponse.contestListList){
//                contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
//            }
//            
//            if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
//                [delegate didGetContestList:contestList type:ContestListTypeAll resultCode:output.resultCode];
//            }
//            
//        });
//    });
//}

- (void)getContestListWithGroupId:(NSString*)groupId
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                        completed:(GetContestListBlock)completed{
    
    PPDebug(@"<getContestListWithGroupId> groupId=%@", groupId);
    
    if (groupId == nil){
        EXECUTE_BLOCK(completed, 0, 0, nil);
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
                                PARA_GROUPID : groupId,
                                PARA_OFFSET : @(offset),
                                PARA_COUNT : @(limit),
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
                                                                                parameters:para];
        
        
        NSArray *contestList = nil;
        if (output.resultCode == 0 && output.pbResponse.contestListList){
            contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            
            EXECUTE_BLOCK(completed, output.resultCode, 0, contestList);
            
        });
    });
}

//- (void)getGroupContestListWithType:(ContestListType)type
//                             offset:(NSInteger)offset
//                              limit:(NSInteger)limit
//                           delegate:(id<ContestServiceDelegate>)delegate{
//    
//    dispatch_async(workingQueue, ^{
//        
//        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
//                                PARA_TYPE : @(type),
//                                PARA_OFFSET : @(offset),
//                                PARA_COUNT : @(limit),
//                                PARA_IS_GROUP : @(YES)
//                                };
//        
//        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
//                                                                                parameters:para];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSArray *contestList = nil;
//            if (output.resultCode == 0 && output.pbResponse.contestListList){
//                contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
//            }
//            
//            if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
//                [delegate didGetContestList:contestList type:ContestListTypeAll resultCode:output.resultCode];
//            }
//            
//        });
//    });
//}

- (void)getGroupContestListWithType:(ContestListType)type
                             offset:(NSInteger)offset
                              limit:(NSInteger)limit
                          completed:(GetContestListBlock)completed{
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_LANGUAGE : @(ChineseType),
                                PARA_TYPE : @(type),
                                PARA_OFFSET : @(offset),
                                PARA_COUNT : @(limit),
                                PARA_IS_GROUP : @(YES)
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_GET_CONTEST_LIST
                                                                                parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray *contestList = nil;
            if (output.resultCode == 0 && output.pbResponse.contestListList){
                contestList = [[ContestManager defaultManager] parseContestList:output.pbResponse.contestListList];
            }
            
            EXECUTE_BLOCK(completed, output.resultCode, type, contestList);            
        });
    });
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

- (void)createContest:(Contest *)contest
                image:(UIImage *)image
            completed:(CreateContestBlock)completed{
    
    NSData *data = [contest data];
    if ([data length] <= 0) {
        PPDebug(@"<createContest> data length can not less than zero");
        return;
    }
    
    if (image == nil) {
        PPDebug(@"<createContest> image can not be nil");
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerUploadAndResponsePB:METHOD_CREATE_CONTEST parameters:nil imageDataDict:@{PARA_IMAGE:[image data]} postDataDict:@{PARA_META_DATA : data} progressDelegate:nil];
        
        Contest *contest = [[[Contest alloc] initWithPBContest:output.pbResponse.contest] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            EXECUTE_BLOCK(completed, output.resultCode, contest);
        });
    });
}

@end
