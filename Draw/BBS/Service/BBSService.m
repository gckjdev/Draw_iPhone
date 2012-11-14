//
//  BBSService.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSService.h"
#import "BBSNetwork.h"

#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"

#import "BBSManager.h"
BBSService *_staticBBSService;

@implementation BBSService

+ (id)defaultService
{
    if (_staticBBSService == nil) {
        _staticBBSService = [[BBSService alloc] init];
    }
    return _staticBBSService;
}
- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        CommonNetworkOutput *output = [BBSNetwork getBBSBoardList:TRAFFIC_SERVER_URL
                                                            appId:appId
                                                           userId:userId
                                                       deviceType:1];
        NSInteger resultCode = [output resultCode];
        NSInteger length = [output.responseData length];
        if (output.resultCode == ERROR_SUCCESS && length > 0) {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            NSArray *list = [response bbsBoardList];
            for (PBBBSBoard *board in list) {
                [BBSManager printBBSBoard:board];

            }
        }
    });
}

@end
