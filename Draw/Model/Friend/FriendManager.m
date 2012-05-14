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



@interface FriendManager()

- (Friend *)findFollowFriendByUserId:(NSString *)friendUserId;
- (Friend *)findFanFriendByUserId:(NSString *)friendUserId;
- (BOOL)hasRecord:(NSString *)userId type:(NSNumber *)type;
- (NSArray *)findAllDeletedFriends;

@end

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
                          type:(NSNumber *)type
                      nickName:(NSString *)nickName 
                        avatar:(NSString *)avatar 
                        gender:(NSString *)gender
                        sinaId:(NSString *)sinaId
                          qqId:(NSString *)qqId
                    facebookId:(NSString *)facebookId
                      sinaNick:(NSString *)sinaNick
                        qqNick:(NSString *)qqNick
                  facebookNick:(NSString *)facebookNick 
                    createDate:(NSDate *)createDate 
              lastModifiedDate:(NSDate *)lastModifiedDate 
{
    if ([self hasRecord:friendUserId type:type]) {
        return [self updateFriendWithUserId:friendUserId 
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
                           lastModifiedDate:lastModifiedDate ];
    }else {
        PPDebug(@"<createFriendWithUserId>");
        
        CoreDataManager *dataManager = [CoreDataManager defaultManager];
        Friend *newFriend = [dataManager insert:@"Friend"];
        [newFriend setFriendUserId:friendUserId];
        [newFriend setType:type];
        [newFriend setNickName:nickName];
        [newFriend setAvatar:avatar];
        [newFriend setGender:gender];
        [newFriend setSinaId:sinaId];
        [newFriend setQqId:qqId];
        [newFriend setFacebookId:facebookId];
        [newFriend setSinaNick:sinaNick];
        [newFriend setQqNick:qqNick];
        [newFriend setFacebookNick:facebookNick];
        [newFriend setCreateDate:createDate];
        [newFriend setLastModifiedDate:lastModifiedDate];
        [newFriend setDeleteFlag:[NSNumber numberWithInt:NOT_DELETED]];
        
        return [dataManager save];
    }
}


- (BOOL)updateFriendWithUserId:(NSString *)friendUserId 
                          type:(NSNumber *)type 
                      nickName:(NSString *)nickName 
                        avatar:(NSString *)avatar 
                        gender:(NSString *)gender
                        sinaId:(NSString *)sinaId
                          qqId:(NSString *)qqId
                    facebookId:(NSString *)facebookId
                      sinaNick:(NSString *)sinaNick
                        qqNick:(NSString *)qqNick
                  facebookNick:(NSString *)facebookNick
              lastModifiedDate:(NSDate *)lastModifiedDate 
{
    Friend *updateFriend = nil;
    if (type.intValue == FOLLOW) {
        updateFriend = [self findFollowFriendByUserId:friendUserId];
    }else if (type.intValue == FAN){
        updateFriend = [self findFanFriendByUserId:friendUserId];
    }
    
    if (updateFriend == nil) {
        return NO;
    }else {
        updateFriend.nickName = nickName;
        updateFriend.avatar = avatar;
        updateFriend.gender = gender;
        updateFriend.sinaId = sinaId;
        updateFriend.qqId = qqId;
        updateFriend.facebookId = facebookId;
        updateFriend.sinaNick = sinaNick;
        updateFriend.qqNick = qqNick;
        updateFriend.facebookNick = facebookNick;
        updateFriend.lastModifiedDate = lastModifiedDate;
        
        return  [[CoreDataManager dataManager] save];
    }
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


- (BOOL)isFollowFriend:(NSString *)friendUserId
{
    Friend *friend = [self findFollowFriendByUserId:friendUserId];
    if (friend != nil) {
        if (friend.deleteFlag.intValue == NOT_DELETED)
            return YES;
    }
    return NO;
}


- (BOOL)deleteFollowFriend:(NSString *)friendUserId
{
    Friend *friend = [self findFollowFriendByUserId:friendUserId];
    [friend setDeleteFlag:[NSNumber numberWithInt:IS_DELETED]];
    return [[CoreDataManager defaultManager] save];
}


- (BOOL)isFanFriend:(NSString *)friendUserId
{
    Friend *friend = [self findFanFriendByUserId:friendUserId];
    if (friend != nil) {
        if (friend.deleteFlag.intValue == NOT_DELETED)
            return YES;
    }
    return NO;
}


- (BOOL)deleteFanFriend:(NSString *)friendUserId
{
    Friend *friend = [self findFanFriendByUserId:friendUserId];
    [friend setDeleteFlag:[NSNumber numberWithInt:IS_DELETED]];
    return [[CoreDataManager defaultManager] save];
}


- (BOOL)deleteAllFriends
{
    NSArray *allFollows = [self findAllFollowFriends];
    for (Friend *followFriend in allFollows) {
       [followFriend setDeleteFlag:[NSNumber numberWithInt:IS_DELETED]];
    }
    
    NSArray *allFans = [self findAllFanFriends];
    for (Friend *fanFriend in allFans) {
        [fanFriend setDeleteFlag:[NSNumber numberWithInt:IS_DELETED]];
    }
    
    return [[CoreDataManager defaultManager] save];
}


- (BOOL)removeAllDeletedFriends;
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    NSArray *deletedFiends = [self findAllDeletedFriends];
    for (Friend *deletedFiend in deletedFiends) {
        [dataManager del:deletedFiend];
    }
    return [dataManager save];
}






- (Friend *)findFollowFriendByUserId:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return (Friend*)[dataManager execute:@"findFollowByFriendUserId" forKey:@"FRIEND_USER_ID" value:friendUserId];
}


- (Friend *)findFanFriendByUserId:(NSString *)friendUserId
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return (Friend*)[dataManager execute:@"findFanByFriendUserId" forKey:@"FRIEND_USER_ID" value:friendUserId];
}


- (BOOL)hasRecord:(NSString *)userId type:(NSNumber *)type
{
    Friend *findFriend = nil;
    if (type.intValue == FOLLOW) {
        findFriend = [self findFollowFriendByUserId:userId];
    }else if (type.intValue == FAN){
        findFriend = [self findFanFriendByUserId:userId];
    }
    
    if (findFriend == nil) {
        return NO;
    }else {
        return YES;
    }
}

- (NSArray *)findAllDeletedFriends
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllDeletedFriends"];
}


@end
