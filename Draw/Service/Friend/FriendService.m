//
//  FriendService.m
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FriendService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"
#import "PPNetworkRequest.h"
#import "LogUtil.h"
#import "FriendManager.h"

static FriendService* friendService;
FriendService* globalGetFriendService() 
{
    if (friendService == nil) {
        friendService = [[FriendService alloc] init];
    }
    return friendService;  
}

@implementation FriendService

+ (FriendService*)defaultService
{
    return globalGetFriendService();
}

- (void)findFriendsByType:(int)type viewController:(PPViewController<FriendServiceDelegate>*)viewController;
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest findFriends:SERVER_URL 
                                                               userId:userId 
                                                                 type:type
                                                           startIndex:0 
                                                             endIndex:5000];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                //to do
                PPDebug(@"%@",[output description]);
//                NSDictionary *dataDict = [[output jsonDataDict] objectForKey:@"dat"];
//                
//                NSString *friendUserId = [dataDict objectForKey:@"uid"];
//                NSString *ncikName = [dataDict objectForKey:@"nn"];
//                NSString *avatar = [dataDict objectForKey:@"av"];
//                NSString *sinaNick = [dataDict objectForKey:@"sn"];
            }
            
            if ([viewController respondsToSelector:@selector(didfindFriendsByType:friendList:result:)]){
                NSArray *friendList = [[FriendManager defaultManager] findAllFanFriends];
                [viewController didfindFriendsByType:type friendList:friendList result:output.resultCode];
            }
        }); 
    });
}

- (void)searchUsersByString:(NSString*)searchString
{
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest searchUsers:SERVER_URL 
                                                            keyString:searchString 
                                                           startIndex:0 
                                                             endIndex:100];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                //to do 
            }
            
        }); 
    });
}

- (void)followUser:(NSString*)targetUserId
{
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest followUser:SERVER_URL 
                                                              userId:userId 
                                                   targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                //to do 
                NSDictionary *dataDict = [[output jsonDataDict] objectForKey:@"dat"];
                NSString *friendUserId = [dataDict objectForKey:@"uid"];
                
                PPDebug(@"%@",[dataDict description]);
                PPDebug(@"%@", friendUserId);
            }
            
        }); 
    });
}

- (void)unFollowUser:(NSString*)targetUserId
{
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest unFollowUser:SERVER_URL 
                                                                userId:userId 
                                                     targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                //to do 
            }
        }); 
    });
}

@end
