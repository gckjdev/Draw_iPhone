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
                                                                appId:APP_ID
                                                               userId:userId 
                                                                 type:type
                                                           startIndex:0 
                                                             endIndex:5000];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                NSArray* userList = [output.jsonDataDict objectForKey:@"users"];
                for (NSDictionary* user in userList){
                    NSString* friendUserId = [user objectForKey:@"uid"];
                    NSString* nickName = [user objectForKey:@"nn"];
                    NSString* avatar = [user objectForKey:@"av"];     
                    NSString* gender = [user objectForKey:@"ge"];
                    NSString* sinaId = [user objectForKey:@"siid"];
                    NSString* qqId = [user objectForKey:@"qid"];
                    NSString* facebookId = [user objectForKey:@"fid"];
                    NSString* sinaNick = [user objectForKey:@"sn"];
                    NSString* qqNick = [user objectForKey:@"qn"];
                    NSString* facebookNick = [user objectForKey:@"fn"];
                    
                    NSString* typeStr =[user objectForKey:@"ft"];
                    NSString* onlineStatusStr = [user objectForKey:@"ols"];
                    NSString* deleteFlagStr = [user objectForKey:@"fl"];
                    NSString* lastModifiedDateStr = [user objectForKey:@"lsmd"];
                    NSNumber* type = [NSNumber numberWithInt:[typeStr intValue]];
                    NSNumber* onlineStatus = [NSNumber numberWithInt:[onlineStatusStr intValue]];
                    NSNumber* deleteFlag = [NSNumber numberWithInt:[deleteFlagStr intValue]];;
                    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                    NSDate* lastModifiedDate = nil;//[dateFormatter dateFromString:lastModifiedDateStr];
                    
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
                                                              onlineStatus:onlineStatus 
                                                                createDate:[NSDate date]
                                                          lastModifiedDate:lastModifiedDate 
                                                                deleteFlag:deleteFlag];
                }

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
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest searchUsers:SERVER_URL 
                                                                appId:APP_ID
                                                            keyString:searchString 
                                                           startIndex:0 
                                                             endIndex:100];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray* userList = nil;
            
            if (output.resultCode == ERROR_SUCCESS){ 
                userList= [output.jsonDataDict objectForKey:@"users"];
            }
            
            if ([viewController respondsToSelector:@selector(didSearchUsers:result:)]){
                [viewController didSearchUsers:userList result:output.resultCode];
            }
        }); 
    });
}

- (void)followUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController;
{
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest followUser:SERVER_URL 
                                                               appId:APP_ID
                                                              userId:userId 
                                                   targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == ERROR_SUCCESS){
                
            }
            
            if ([viewController respondsToSelector:@selector(didFollowUser:)]){
                [viewController didFollowUser:output.resultCode];
            }
        }); 
    });
}

- (void)unFollowUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController;
{
    NSString *userId = [[UserManager defaultManager] userId];
    NSArray *targetList = [NSArray arrayWithObject:targetUserId];
    
    [[FriendManager defaultManager] deleteFollowFriend:targetUserId];
    
    dispatch_async(workingQueue, ^{            
        CommonNetworkOutput* output = [GameNetworkRequest unFollowUser:SERVER_URL 
                                                                 appId:APP_ID
                                                                userId:userId 
                                                     targetUserIdArray:targetList];             
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS){
                //to do 
  
            }
            if ([viewController respondsToSelector:@selector(didUnFollowUser:)]){
                [viewController didUnFollowUser:output.resultCode];
            }
        }); 
    });
}

@end
