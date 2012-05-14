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
    [viewController showActivity];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest findFriends:SERVER_URL 
                                                                appId:APP_ID
                                                               userId:userId 
                                                                 type:type
                                                           startIndex:0 
                                                             endIndex:5000];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<FriendService> findFriends success!");
                NSArray* userList = [output.jsonDataDict objectForKey:PARA_USERS];
                
                if ([userList count] != 0) {
                    [[FriendManager defaultManager] deleteAllFriends];
                }
                
                for (NSDictionary* user in userList){
                    NSString* friendUserId = [user objectForKey:PARA_USERID];
                    NSString* nickName = [user objectForKey:PARA_NICKNAME];
                    NSString* avatar = [user objectForKey:PARA_AVATAR];     
                    NSString* gender = [user objectForKey:PARA_GENDER];
                    NSString* sinaId = [user objectForKey:PARA_SINA_ID];
                    NSString* qqId = [user objectForKey:PARA_QQ_ID];
                    NSString* facebookId = [user objectForKey:PARA_FACEBOOKID];
                    NSString* sinaNick = [user objectForKey:PARA_SINA_NICKNAME];
                    NSString* qqNick = [user objectForKey:PARA_QQ_NICKNAME];
                    NSString* facebookNick = [user objectForKey:PARA_FACEBOOK_NICKNAME];
                    NSString* typeStr =[user objectForKey:PARA_FRIENDSTYPE];
                    NSString* lastModifiedDateStr = [user objectForKey:PARA_LASTMODIFIEDDATE];
                    NSNumber* type = [NSNumber numberWithInt:[typeStr intValue]];
                    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                    [dateFormatter setDateFormat:DEFAULT_DATE_FORMAT];
                    NSDate* lastModifiedDate = [dateFormatter dateFromString:lastModifiedDateStr];
                    
                    [[FriendManager defaultManager] createFriendWithUserId:friendUserId 
                                                                      type:type 
                                                                  nickName:nickName 
                                                                    avatar:avatar 
                                                                    gender:gender 
                                                                    sinaId:sinaId 
                                                                      qqId:qqId 
                                                                facebookId:facebookId 
                                                                  sinaNick:sinaNick 
                                                                    qqNick:qqNick 
                                                              facebookNick:facebookNick 
                                                                createDate:[NSDate date]
                                                          lastModifiedDate:lastModifiedDate];
                }
            }else {
                PPDebug(@"<FriendService> findFriends Failed!");
            }
            
            if ([viewController respondsToSelector:@selector(didfindFriendsByType:friendList:result:)]){
                NSArray * friendList= nil;
                if (type == FOLLOW) {
                    friendList = [[FriendManager defaultManager] findAllFollowFriends];
                }else if (type == FAN){
                    friendList = [[FriendManager defaultManager] findAllFanFriends];
                }
                [viewController didfindFriendsByType:type friendList:friendList result:output.resultCode];
            }
        }); 
    });
}


- (void)searchUsersByString:(NSString*)searchString viewController:(PPViewController<FriendServiceDelegate>*)viewController;
{
    [viewController showActivity];
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest searchUsers:SERVER_URL 
                                                                appId:APP_ID
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


- (void)followUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController;
{
    [viewController showActivity];
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest followUser:SERVER_URL 
                                                               appId:APP_ID
                                                              userId:userId 
                                                   targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS){
                PPDebug(@"<FriendService> unFollowUser success!");
                NSArray* userList = [output.jsonDataDict objectForKey:PARA_USERS];
                for (NSDictionary* user in userList){
                    NSString* friendUserId = [user objectForKey:PARA_USERID];
                    NSString* nickName = [user objectForKey:PARA_NICKNAME];
                    NSString* avatar = [user objectForKey:PARA_AVATAR];     
                    NSString* gender = [user objectForKey:PARA_GENDER];
                    NSString* sinaId = [user objectForKey:PARA_SINA_ID];
                    NSString* qqId = [user objectForKey:PARA_QQ_ID];
                    NSString* facebookId = [user objectForKey:PARA_FACEBOOKID];
                    NSString* sinaNick = [user objectForKey:PARA_SINA_NICKNAME];
                    NSString* qqNick = [user objectForKey:PARA_QQ_NICKNAME];
                    NSString* facebookNick = [user objectForKey:PARA_FACEBOOK_NICKNAME];
                    NSString* typeStr =[user objectForKey:PARA_FRIENDSTYPE];
                    NSString* lastModifiedDateStr = [user objectForKey:PARA_LASTMODIFIEDDATE];
                    NSNumber* type = [NSNumber numberWithInt:[typeStr intValue]];
                    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                    [dateFormatter setDateFormat:DEFAULT_DATE_FORMAT];
                    NSDate* lastModifiedDate = [dateFormatter dateFromString:lastModifiedDateStr];
                    
                    [[FriendManager defaultManager] updateFriendWithUserId:friendUserId 
                                                                      type:type 
                                                                  nickName:nickName 
                                                                    avatar:avatar 
                                                                    gender:gender 
                                                                    sinaId:sinaId 
                                                                      qqId:qqId 
                                                                facebookId:facebookId 
                                                                  sinaNick:sinaNick 
                                                                    qqNick:qqNick 
                                                              facebookNick:facebookNick 
                                                          lastModifiedDate:lastModifiedDate];
                }
            }else {
                PPDebug(@"<FriendService> unFollowUser Failed!");
            }
            
            if ([viewController respondsToSelector:@selector(didFollowUser:)]){
                [viewController didFollowUser:output.resultCode];
            }
        }); 
    });
}


- (void)unFollowUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController;
{
    [viewController showActivity];
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest unFollowUser:SERVER_URL 
                                                                 appId:APP_ID
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

@end
