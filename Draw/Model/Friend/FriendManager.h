//
//  FriendManager.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MALE    @"m"
#define FEMALE  @"f"

enum type {
    FOLLOW = 1,
    FAN = 2
};

enum deleteFlag {
    NOT_DELETED = 0,
    IS_DELETED = 1
};

@class Friend;

@interface FriendManager : NSObject

+ (FriendManager *)defaultManager;

- (BOOL)createFriendByDictionary:(NSDictionary *)userDic;
- (BOOL)updateFriendByDictionary:(NSDictionary *)userDic;

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
                      location:(NSString *)location;

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
                      location:(NSString *)location;

- (NSArray *)findAllFanFriends;
- (NSArray *)findAllFollowFriends;

- (BOOL)isFollowFriend:(NSString *)friendUserId;
- (BOOL)deleteFollowFriend:(NSString *)friendUserId;

- (BOOL)isFanFriend:(NSString *)friendUserId;
- (BOOL)deleteFanFriend:(NSString *)friendUserId;

- (BOOL)deleteAllFriends;

- (BOOL)removeAllDeletedFriends;

- (NSString *)getFriendNick:(Friend *)aFriend;

@end
