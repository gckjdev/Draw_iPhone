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

enum type {
    FOLLOW = 0,
    FAN = 1
};

enum deleteFlag {
    NOT_DELETED = 0,
    IS_DELETED = 1
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
    [newFriend setDeleteFlag:[NSNumber numberWithInt:NOT_DELETED]];
    
    PPDebug(@"<createFriendWithUserId> %@", [newFriend description]);
    return [dataManager save];
}

- (BOOL)updateFriendWithUserId:(NSString *)friendUserId 
                          type:(NSNumber *)type 
                        newFriend:(Friend *)newFriend
{
    Friend *updateFriend = nil;
    if (type.intValue == FOLLOW) {
        updateFriend = [self findFollowFriendByUserId:friendUserId];
    }else if (type.intValue == FAN){
        updateFriend = [self findFanFriendByUserId:friendUserId];
    }
    
    if (updateFriend == nil) {
        return NO;
    }
    
    updateFriend.nickName = newFriend.nickName;
    updateFriend.avatar = newFriend.avatar;
    updateFriend.gender = newFriend.gender;
    updateFriend.sinaId = newFriend.sinaId;
    updateFriend.qqId = newFriend.qqId;
    updateFriend.facebookId = newFriend.facebookId;
    updateFriend.sinaNick = newFriend.sinaNick;
    updateFriend.qqNick = newFriend.qqNick;
    updateFriend.facebookNick = newFriend.facebookNick;
    updateFriend.onlineStatus = newFriend.onlineStatus;
    updateFriend.lastModifiedDate = [NSDate date];
    
    return  [[CoreDataManager dataManager] save];
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

- (Friend *)findFollowFriendByUserId:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return (Friend*)[dataManager execute:@"findFollowByFriendUserId" forKey:@"FRIEND_USER_ID" value:friendUserId];
}

- (BOOL)isFollowFriend:(NSString *)friendUserId
{
    return ([self findFollowFriendByUserId:friendUserId] != nil);
}

- (BOOL)deleteFollowFriend:(NSString *)friendUserId
{
    Friend *friend = [self findFollowFriendByUserId:friendUserId];
    [friend setDeleteFlag:[NSNumber numberWithInt:IS_DELETED]];
    return [[CoreDataManager defaultManager] save];
}

- (Friend *)findFanFriendByUserId:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return (Friend*)[dataManager execute:@"findFanByFriendUserId" forKey:@"FRIEND_USER_ID" value:friendUserId];
}

- (BOOL)isFanFriend:(NSString *)friendUserId
{
    return ([self findFanFriendByUserId:friendUserId] != nil);
}

@end
