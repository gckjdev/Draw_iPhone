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
        NSString *appId = [ConfigManager appId];
        NSString *userId =[[UserManager defaultManager] userId];
        int language = [[UserManager defaultManager] getLanguageType];
        
        CommonNetworkOutput *output = [GameNetworkRequest getContests:TRAFFIC_SERVER_URL
                                                                appId:appId
                                                               userId:userId 
                                                                 type:type 
                                                               offset:offset
                                                                limit:limit 
                                                             language:language];
        NSInteger errorCode = output.resultCode;
        NSArray *contestList = nil;

        if (errorCode == ERROR_SUCCESS) {
            contestList = [[ContestManager defaultManager] parseContestList:output.jsonDataArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetContestList:type:resultCode:)]) {
                [delegate didGetContestList:contestList type:type resultCode:errorCode];
            }
        });        
        
    });

}

- (void)getMyContestListWithOffset:(NSInteger)offset
                             limit:(NSInteger)limit
                          delegate:(id<ContestServiceDelegate>)delegate
{
    
}


@end
