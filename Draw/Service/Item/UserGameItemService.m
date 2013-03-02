//
//  UserGameItemService.m
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import "UserGameItemService.h"
#import "SynthesizeSingleton.h"
#import "GameNetworkRequest.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "ConfigManager.h"

@implementation UserGameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(UserGameItemService);

- (void)buyItem:(int)itemId
          count:(int)count
        handler:(BuyItemResultHandler )handler
{
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count toUser:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(output.resultCode, itemId, count, nil);
        });
    });
}

- (void)giveItem:(int)itemId
          toUser:(NSString *)toUserId
           count:(int)count
         handler:(BuyItemResultHandler)handler
{
    CommonNetworkOutput *output = [GameNetworkRequest buyItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count toUser:toUserId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(output.resultCode, itemId, count, toUserId);
    });
}

- (void)useItem:(int)itemId
         toOpus:(NSString *)toOpusId
        handler:(UseItemResultHandler)handler
{
    CommonNetworkOutput *output = [GameNetworkRequest useItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId toOpusId:toOpusId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(output.resultCode, itemId, toOpusId);
    });
}

@end
