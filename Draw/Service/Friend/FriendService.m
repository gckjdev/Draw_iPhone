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
#import "TimeUtils.h"
#import "ConfigManager.h"

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


- (void)findFriendsByType:(int)type viewController:(PPViewController<FriendServiceDelegate>*)viewController
{
    NSString *userId = [[UserManager defaultManager] userId];
    [viewController showActivityWithText:NSLS(@"kLoading")];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest findFriends:SERVER_URL 
                                                                appId:[ConfigManager appId] 
                                                               gameId:[ConfigManager gameId]
                                                               userId:userId 
                                                                 type:type
                                                           startIndex:0 
                                                             endIndex:5000];   
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<FriendService> findFriends success!");
                
                NSArray* userList = [output.jsonDataDict objectForKey:PARA_USERS];
                if ([userList count] != 0 || type == FAN) {
                    [[FriendManager defaultManager] deleteAllFriends:type];
                }
                
                [[FriendManager defaultManager] createFriendsByJsonArray:userList];
            }else {
                PPDebug(@"<FriendService> findFriends Failed!");
                return ;
            }
            NSArray * friendList= nil;
            if (type == FOLLOW) {
                friendList = [[FriendManager defaultManager] findAllFollowFriends];
            }else if (type == FAN){
                friendList = [[FriendManager defaultManager] findAllFanFriends];
            }
        
            [viewController hideActivity];
            if ([viewController respondsToSelector:@selector(didfindFriendsByType:friendList:result:)]){
                [viewController didfindFriendsByType:type friendList:friendList result:output.resultCode];
            }            
        }); 
    });
}


- (void)searchUsersByString:(NSString*)searchString viewController:(PPViewController<FriendServiceDelegate>*)viewController
{
    [viewController showActivityWithText:NSLS(@"kSearching")];
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest searchUsers:SERVER_URL 
                                                                appId:[ConfigManager appId] 
                                                               gameId:[ConfigManager gameId]
                                                            keyString:searchString 
                                                           startIndex:0 
                                                             endIndex:100];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            NSArray* userList = nil;
            if (output.resultCode == ERROR_SUCCESS){ 
                PPDebug(@"<FriendService> searchUsers success!");
                userList= [output.jsonDataDict objectForKey:PARA_USERS];
            }else {
                PPDebug(@"<FriendService> searchUsers Failed!");
            }
            
            if ([viewController respondsToSelector:@selector(didSearchUsers:result:)]){
                [viewController didSearchUsers:userList result:output.resultCode];
            }
        }); 
    });
}


- (void)followUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController
{
    [viewController showActivityWithText:NSLS(@"kFollowing")];
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest followUser:SERVER_URL 
                                                               appId:[ConfigManager appId]
                                                              userId:userId 
                                                   targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<FriendService> followUser success!");
                NSArray* userList = [output.jsonDataDict objectForKey:PARA_USERS];
                
                [[FriendManager defaultManager] createFriendsByJsonArray:userList];
            }else {
                if (output.resultCode == ERROR_FOLLOW_USER_NOT_FOUND) {
                    PPDebug(@"<FriendService> followUser Failed: user not found");
                }else {
                    PPDebug(@"<FriendService> followUser Failed!");
                }
            }
            
            if ([viewController respondsToSelector:@selector(didFollowUser:)]){
                [viewController didFollowUser:output.resultCode];
            }
        }); 
    });
}


- (void)unFollowUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController
{
    [viewController showActivityWithText:NSLS(@"kUnfollowing")];
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest unFollowUser:SERVER_URL 
                                                                 appId:[ConfigManager appId]
                                                                userId:userId 
                                                     targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [viewController hideActivity];
            
            if (output.resultCode == ERROR_SUCCESS){
                [[FriendManager defaultManager] deleteFollowFriend:targetUserId];
                PPDebug(@"<FriendService> unFollowUser success!");
            }else {
                PPDebug(@"<FriendService> unFollowUser Failed!");
            }
            
            if ([viewController respondsToSelector:@selector(didUnFollowUser:)]){
                [viewController didUnFollowUser:output.resultCode];
            }
        }); 
    });
}

- (void)followUser:(NSString*)targetUserId 
      withDelegate:(id<FriendServiceDelegate>)aDelegate
{
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest followUser:SERVER_URL 
                                                               appId:[ConfigManager appId]
                                                              userId:userId 
                                                   targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<FriendService> followUser success!");
                NSArray* userList = [output.jsonDataDict objectForKey:PARA_USERS];
                [[FriendManager defaultManager] createFriendsByJsonArray:userList];
            }else {
                if (output.resultCode == ERROR_FOLLOW_USER_NOT_FOUND) {
                    PPDebug(@"<FriendService> followUser Failed: user not found");
                }else {
                    PPDebug(@"<FriendService> followUser Failed!");
                }
            }
            
            if (aDelegate && [aDelegate respondsToSelector:@selector(didFollowUser:)]){
                [aDelegate didFollowUser:output.resultCode];
            }
        }); 
    });
}


@end
