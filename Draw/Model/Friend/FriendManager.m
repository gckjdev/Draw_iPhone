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
#import "GameNetworkConstants.h"
#import "TimeUtils.h"
#import "Friend.h"

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


- (BOOL)createFriendByDictionary:(NSDictionary *)userDic
{
    NSString* friendUserId = [userDic objectForKey:PARA_USERID];
    NSString* nickName = [userDic objectForKey:PARA_NICKNAME];
    NSString* avatar = [userDic objectForKey:PARA_AVATAR];     
    NSString* gender = [userDic objectForKey:PARA_GENDER];
    NSString* sinaId = [userDic objectForKey:PARA_SINA_ID];
    NSString* qqId = [userDic objectForKey:PARA_QQ_ID];
    NSString* facebookId = [userDic objectForKey:PARA_FACEBOOKID];
    NSString* sinaNick = [userDic objectForKey:PARA_SINA_NICKNAME];
    NSString* qqNick = [userDic objectForKey:PARA_QQ_NICKNAME];
    NSString* facebookNick = [userDic objectForKey:PARA_FACEBOOK_NICKNAME];
    NSString* typeStr =[userDic objectForKey:PARA_FRIENDSTYPE];
    NSString* lastModifiedDateStr = [userDic objectForKey:PARA_LASTMODIFIEDDATE];
    NSString* location = [userDic objectForKey:PARA_LOCATION];
    NSNumber* type = [NSNumber numberWithInt:[typeStr intValue]];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:DEFAULT_DATE_FORMAT];
    NSDate* lastModifiedDate = [dateFormatter dateFromString:lastModifiedDateStr];
    NSString* levelStr = [userDic objectForKey:PARA_LEVEL];
    NSNumber* level;
    if (levelStr) {
        level = [NSNumber numberWithInt:[levelStr intValue]];
    } else {
        level = [NSNumber numberWithInt:1];
    }
    
    
    return [self createFriendWithUserId:friendUserId 
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
                       lastModifiedDate:lastModifiedDate 
                               location:location 
                                  level:level];
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
                      location:(NSString *)location 
                         level:(NSNumber *)level
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
                           lastModifiedDate:lastModifiedDate 
                                   location:location 
                                      level:level];
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
        [newFriend setLocation:location];
        [newFriend setLevel:level];
        
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
                      location:(NSString *)location 
                         level:(NSNumber *)level
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
        updateFriend.location = location;
        updateFriend.level = level;
        
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


- (BOOL)deleteAllFriends:(int)type
{
    CoreDataManager* dataManager =[CoreDataManager defaultManager];
    if (type == FOLLOW) {
        NSArray *allFollows = [self findAllFollowFriends];
        for (Friend *followFriend in allFollows) {
            [self deleteFollowFriend:followFriend.friendUserId];
        }
        return [dataManager save];
    }else if (type == FAN) {
        NSArray *allFans = [self findAllFanFriends];
        for (Friend *fanFriend in allFans) {
            [self deleteFanFriend:fanFriend.friendUserId];
        }
        return [dataManager save];
    }
    return YES;
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

- (NSString *)getFriendNick:(Friend *)aFriend
{
    
    if ([aFriend.nickName length] != 0) {
        return [aFriend nickName];
    }
    if ([aFriend.sinaNick length] != 0) {
        return [aFriend sinaNick];
    }

    if ([aFriend.qqNick length] != 0) {
        return [aFriend qqNick];
    }

    if ([aFriend.facebookNick length] != 0) {
        return [aFriend facebookNick];
    }
    return @"";
}
@end
