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
#import "MyFriend.h"
#import "UserService.h"
#import "PPGameNetworkRequest.h"

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
                [viewController hideActivity];
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
        NSString *userId = [[UserManager defaultManager] userId];
        CommonNetworkOutput* output = [GameNetworkRequest searchUsers:SERVER_URL 
                                                                appId:[ConfigManager appId] 
                                                               gameId:[ConfigManager gameId]
                                                               userId:userId
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

#pragma mark - new getting friend list methods 

- (void)followUser:(MyFriend *)myFriend 
          delegate:(id<FriendServiceDelegate>)delegate
{

    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:[myFriend friendUserId]];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest followUser:SERVER_URL 
                                                               appId:[ConfigManager appId]
                                                              userId:userId 
                                                   targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<FriendService> followUser success!");
            }else {
                if (output.resultCode == ERROR_FOLLOW_USER_NOT_FOUND) {
                    PPDebug(@"<FriendService> followUser Failed: user not found");
                }else {
                    PPDebug(@"<FriendService> followUser Failed!");
                }
            }
            if (delegate && [delegate respondsToSelector:@selector(didFollowFriend:resultCode:)]) {
                [delegate didFollowFriend:myFriend resultCode:output.resultCode];
            }
        }); 
    });
}

- (void)unFollowUser:(MyFriend *)myFriend 
            delegate:(id<FriendServiceDelegate>)delegate
{

    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:[myFriend friendUserId]];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest unFollowUser:SERVER_URL 
                                                                 appId:[ConfigManager appId]
                                                                userId:userId 
                                                     targetUserIdArray:targetList];             
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == ERROR_SUCCESS){
            }else {
                PPDebug(@"<FriendService> unFollowUser Failed!");
            }
            if (delegate && [delegate respondsToSelector:
                             @selector(didUnFollowFriend:resultCode:)]) {
                [delegate didUnFollowFriend:myFriend resultCode:output.resultCode];
            }
        }); 
    });
}

- (void)removeFan:(MyFriend *)fan 
         delegate:(id<FriendServiceDelegate>)delegate
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    NSArray *targetList = [NSArray arrayWithObject:userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest unFollowUser:SERVER_URL 
                                                                 appId:[ConfigManager appId]
                                                                userId:fan.friendUserId 
                                                     targetUserIdArray:targetList];             
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == ERROR_SUCCESS){
            }else {
                PPDebug(@"<FriendService> unFollowUser Failed!");
            }
            if (delegate && [delegate respondsToSelector:
                             @selector(didRemoveFan:resultCode:)]) {
                [delegate didRemoveFan:fan resultCode:output.resultCode];
            }
        }); 
    });
}

- (void)getFriendList:(FriendType)type 
               offset:(NSInteger)offset 
                limit:(NSInteger)limit
             delegate:(id<FriendServiceDelegate>)delegate
{
    NSString *userId = [[UserManager defaultManager] userId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest getFriendList:SERVER_URL
                                                                  appId:[ConfigManager appId] 
                                                                 gameId:[ConfigManager gameId] 
                                                                 userId:userId 
                                                                   type:type 
                                                                 offset:offset
                                                                  limit:limit];   
        NSInteger resultCode = output.resultCode;
        NSArray* friendList = nil;
        if (resultCode == ERROR_SUCCESS) {
            NSArray* userList = [output.jsonDataDict objectForKey:PARA_USERS];
            friendList = [[FriendManager defaultManager] parseFriendList:userList];
        }else{
            PPDebug(@"warning:<getFriendList> error code = %d", resultCode);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didfindFriendsByType:friendList:result:)]) {
                [delegate didfindFriendsByType:type friendList:friendList result:resultCode];
            }
        }); 
    });
}

- (void)getRelationCount:(id<FriendServiceDelegate>)delegate
{
    
    dispatch_async(workingQueue, ^{
        
        NSString *userId = [[UserManager defaultManager] userId];
        CommonNetworkOutput* output = [GameNetworkRequest getRelationCount:SERVER_URL
                                                                     appId:[ConfigManager appId]
                                                                    gameId:[ConfigManager gameId]
                                                                    userId:userId];
        NSInteger resultCode = output.resultCode;
        NSInteger fanCount = 0;
        NSInteger followCount = 0;
        NSInteger blackCount = 0;
        if (resultCode == ERROR_SUCCESS) {
            fanCount = [[output.jsonDataDict objectForKey:PARA_RELATION_FAN_COUNT] integerValue];
            followCount = [[output.jsonDataDict objectForKey:PARA_RELATION_FOLLOW_COUNT] integerValue];
            blackCount = [[output.jsonDataDict objectForKey:PARA_RELATION_BLACK_COUNT] integerValue];
        }else{
            PPDebug(@"warning:<getFriendList> error code = %d", resultCode);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetFanCount:followCount:blackCount:resultCode:)]) {
                [delegate didGetFanCount:fanCount
                             followCount:followCount
                              blackCount:blackCount
                              resultCode:resultCode];
                [[UserManager defaultManager] setFollowCount:followCount];
                [[UserManager defaultManager] setFanCount:fanCount];
            }
        });
    });
}

- (void)searchUsersWithKey:(NSString*)key
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit
                  delegate:(id<FriendServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{         
        NSString *userId = [[UserManager defaultManager] userId];
        CommonNetworkOutput* output = [GameNetworkRequest searchUsers:SERVER_URL 
                                                                appId:[ConfigManager appId] 
                                                               gameId:[ConfigManager gameId]
                                                               userId:userId
                                                            keyString:key 
                                                           startIndex:offset 
                                                             endIndex:limit];             
        
        NSArray* userList = nil;
        NSArray *retList = nil;
        if (output.resultCode == ERROR_SUCCESS){ 
            PPDebug(@"<FriendService> searchUsers success!");
            userList= [output.jsonDataDict objectForKey:PARA_USERS];
            retList = [[FriendManager defaultManager] parseFriendList:userList];
        }else {
            PPDebug(@"<FriendService> searchUsers Failed!");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([delegate respondsToSelector:@selector(didSearchUsers:result:)]){
                [delegate didSearchUsers:retList result:output.resultCode];
            }
        }); 
    });
    
}

- (void)blackFriend:(NSString*)targetUserId
       successBlock:(void (^)(void))successBlock
{
    dispatch_async(workingQueue, ^{
        NSString *appId = [ConfigManager appId];
        //        NSString *gameId = [ConfigManager gameId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput* output = [GameNetworkRequest blackFriend:SERVER_URL
                                                                appId:appId
                                                         targetUserId:targetUserId
                                                               userId:userId
                                                           actionType:BLACK_ACTION_TYPE_BLACK];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS && successBlock != NULL) {
                successBlock();
            }
        });
    });
}
- (void)unblackFriend:(NSString*)targetUserId
         successBlock:(void (^)(void))successBlock
{
    dispatch_async(workingQueue, ^{
        NSString *appId = [ConfigManager appId];
        //        NSString *gameId = [ConfigManager gameId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput* output = [GameNetworkRequest blackFriend:SERVER_URL
                                                                appId:appId
                                                         targetUserId:targetUserId
                                                               userId:userId
                                                           actionType:BLACK_ACTION_TYPE_UNBLACK];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS && successBlock != NULL) {
                successBlock();
            }
        });
    });
}


- (void)setFriendMemo:(NSString*)targetUserId
                 memo:(NSString*)memo
         successBlock:(void (^)(int resultCode))successBlock
{
    if (targetUserId == nil || memo == nil){
        return;
    }
    
    dispatch_async(workingQueue, ^{

        NSDictionary* para = @{ PARA_TARGETUSERID : targetUserId,
                                PARA_MEMO : memo
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_SET_FRIEND_MEMO parameters:para isReturnArray:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            EXECUTE_BLOCK(successBlock, output.resultCode);
        });
    });
}


@end
