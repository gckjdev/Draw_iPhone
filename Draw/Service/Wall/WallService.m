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

@implementation WallService

SYNTHESIZE_SINGLETON_FOR_CLASS(WallService);

- (void)createWall:(PBWall *)wall delegate:(PPViewController<WallServiceDelegate>*)viewController;

{    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest createWall:TRAFFIC_SERVER_URL
                                                               appId:[ConfigManager appId]
                                                              userId:[[UserManager defaultManager] userId]
                                                                data:wall.data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didCreateWall:)]){
                [viewController didCreateWall:output.resultCode];
            }
        });
    });
}


@end
