//
//  WallService.m
//  Draw
//
//  Created by 王 小涛 on 13-1-30.
//
//

#import "WallService.h"
#import "SynthesizeSingleton.h"
#import "UserManager.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"
#import "UIImageExt.h"

@implementation WallService

SYNTHESIZE_SINGLETON_FOR_CLASS(WallService);

- (void)createWall:(PBWall *)wall
           bgImage:(UIImage *)bgImage
          delegate:(PPViewController<WallServiceDelegate>*)viewController
{    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest createWall:TRAFFIC_SERVER_URL
                                                               appId:[ConfigManager appId]
                                                              userId:[[UserManager defaultManager] userId]
                                                                data:wall.data
                                                           imageData:[bgImage data]];
        PBWall *pbWall;
        NSInteger resultCode = output.resultCode;

        if (resultCode == 0) {
            @try {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                pbWall = response.wall;
                resultCode = response.resultCode;
            }
            @catch (NSException *exception) {
                PPDebug(@"<%s>exception = %@", __FUNCTION__, [exception debugDescription]);
            }
            @finally {
                
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didCreateWall:wall:)]){
                [viewController didCreateWall:resultCode wall:pbWall];
            }
        });
    });
}

- (void)updateWall:(PBWall *)wall
           bgImage:(UIImage *)bgImage
          delegate:(PPViewController<WallServiceDelegate>*)viewController
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest updateWall:TRAFFIC_SERVER_URL
                                                               appId:[ConfigManager appId]
                                                              userId:[[UserManager defaultManager] userId]
                                                              wallId:wall.wallId
                                                                data:wall.data
                                                           imageData:[bgImage data]];
        
        PBWall *pbWall;
        NSInteger resultCode = output.resultCode;

        if (resultCode == 0) {
            @try {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                pbWall = response.wall;
                resultCode = response.resultCode;
            }
            @catch (NSException *exception) {
                PPDebug(@"<%s>exception = %@", __FUNCTION__, [exception debugDescription]);
            }
            @finally {
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didUpdateWall:wall:)]){
                [viewController didUpdateWall:resultCode wall:pbWall];
            }
        });
    });
}

- (void)getWallList:(NSString *)userId
           wallType:(PBWallType)wallType
           delegate:(PPViewController<WallServiceDelegate>*)viewController;
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getWalls:TRAFFIC_SERVER_URL
                                                             appId:[ConfigManager appId]
                                                            userId:[[UserManager defaultManager] userId]
                                                          wallType:wallType];
        
        NSArray *wallList;
        NSInteger resultCode = output.resultCode;

        if (resultCode == 0) {
            @try {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                wallList = response.wallListList;
                resultCode = response.resultCode;
            }
            @catch (NSException *exception) {
                PPDebug(@"<%s>exception = %@", __FUNCTION__, [exception debugDescription]);
            }
            @finally {
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didGetWallList:wallList:)]){
                [viewController didGetWallList:resultCode wallList:wallList];
            }
        });
    });
}

- (void)getWall:(NSString *)userId
         wallId:(NSString *)wallId
       delegate:(PPViewController<WallServiceDelegate>*)viewController
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getWall:TRAFFIC_SERVER_URL
                                                            appId:[ConfigManager appId]
                                                           userId:userId
                                                           wallId:wallId];
        
        PBWall *wall = nil;
        NSInteger resultCode = output.resultCode;
        if (resultCode == 0) {
            @try {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                wall = response.wall;
                resultCode = response.resultCode;
            }
            @catch (NSException *exception) {
                PPDebug(@"<%s>exception = %@", __FUNCTION__, [exception debugDescription]);
            }
            @finally {
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didGetWall:wall:)]){
                [viewController didGetWall:resultCode wall:wall];
            }
        });
    });
}

@end
