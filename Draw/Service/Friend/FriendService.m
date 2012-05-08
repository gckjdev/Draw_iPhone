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

- (void)findFriendsByType:(int)type
{
    
}
- (void)searchUsersByString:(NSString*)searchString
{
    
}
- (void)followUser:(NSString*)targetUserId
{
    
}
- (void)unFollowUser:(NSString*)targetUserId
{
    
}

@end
