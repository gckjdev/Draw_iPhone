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
        handler:(UserItemResultHandler *)handler
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = [GameNetworkRequest buyItem:TRAFFIC_SERVER_URL appId:[ConfigManager appId] userId:[[UserManager defaultManager] userId] itemId:itemId count:count toUser:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
       
        });
    });
}

- (void)giveItem:(int)itemId
          toUser:(NSString *)userId
           count:(int)count
         handler:(UserItemResultHandler *)handler
{
    
}

- (void)useItem:(int)itemId
         toUser:(NSString *)userId
        handler:(UserItemResultHandler *)handler
{
    
}

@end
