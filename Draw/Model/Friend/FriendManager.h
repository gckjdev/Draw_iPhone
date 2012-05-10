//
//  FriendManager.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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
                  onlineStatus:(NSNumber *)onlineStatus 
                    createDate:(NSDate *)createDate 
              lastModifiedDate:(NSDate *)lastModifiedDate 
                    deleteFlag:(NSNumber *)deleteFlag;

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
                  onlineStatus:(NSNumber *)onlineStatus
              lastModifiedDate:(NSDate *)lastModifiedDate 
                    deleteFlag:(NSNumber *)deleteFlag;

- (NSArray *)findAllFanFriends;
- (NSArray *)findAllFollowFriends;

- (BOOL)isFollowFriend:(NSString *)friendUserId;
- (BOOL)deleteFollowFriend:(NSString *)friendUserId;

- (BOOL)isFanFriend:(NSString *)friendUserId;

@end
