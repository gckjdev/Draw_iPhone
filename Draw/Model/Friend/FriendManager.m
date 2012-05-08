//
//  FriendManager.m
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FriendManager.h"
#import "Friend.h"
#import "CoreDataUtil.h"
#import "LogUtil.h"

enum deleteFlag {
    notDeleted = 0,
    isDeleted = 1
};

@implementation FriendManager

static FriendManager *_defaultFriendManager = nil;

+ (FriendManager *)defaultManager
{
    if (_defaultFriendManager == nil) {
        _defaultFriendManager = [[FriendManager alloc] init];
    }
    return _defaultFriendManager;
}

- (BOOL)createFriendWithUserId:(NSString *)friendUserId 
                      nickName:(NSString *)nickName 
                        avatar:(NSString *)avatar 
                        gender:(NSString *)gender
                        sinaId:(NSString *)sinaId
                          qqId:(NSString *)qqId
                    facebookId:(NSString *)facebookId
                      sinaNick:(NSString *)sinaNick
                        qqNick:(NSString *)qqNick
                  facebookNick:(NSString *)facebookNick
                          type:(NSNumber *)type
                  onlineStatus:(NSNumber *)onlineStatus
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    Friend *newFriend = [dataManager insert:@"Friend"];
    [newFriend setFriendUserId:friendUserId];
    [newFriend setNickName:nickName];
    [newFriend setAvatar:avatar];
    [newFriend setGender:gender];
    [newFriend setSinaId:sinaId];
    [newFriend setQqId:qqId];
    [newFriend setFacebookId:facebookId];
    [newFriend setSinaNick:sinaNick];
    [newFriend setQqNick:qqNick];
    [newFriend setFacebookNick:facebookNick];
    [newFriend setType:type];
    [newFriend setOnlineStatus:onlineStatus];
    [newFriend setCreateDate:[NSDate date]];
    [newFriend setLastModifiedDate:[NSData data]];
    [newFriend setDeleteFlag:[NSNumber numberWithInt:notDeleted]];
    
    PPDebug(@"<createFriendWithUserId> %@", [newFriend description]);
    return [dataManager save];
}

- (NSArray *)findAllFanFriends
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllFanFriends" sortBy:@"createDate" ascending:NO];
}

- (NSArray *)findAllFollowFriends
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllFollowFriends" sortBy:@"createDate" ascending:NO];
}

- (BOOL)deleteFollowFriend:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    Friend *friend = (Friend*)[dataManager execute:@"findFollowByFriendUserId" forKey:@"FRIEND_USER_ID" value:friendUserId];
    [friend setDeleteFlag:[NSNumber numberWithInt:isDeleted]];
    return [dataManager save];
}

@end
