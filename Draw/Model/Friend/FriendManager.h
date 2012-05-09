//
//  FriendManager.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Friend;

@interface FriendManager : NSObject

+ (FriendManager *)defaultManager;

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
                  onlineStatus:(NSNumber *)onlineStatus;

- (BOOL)updateFriendWithUserId:(NSString *)friendUserId 
                          type:(NSNumber *)type 
                     newFriend:(Friend *)newFriend;

- (NSArray *)findAllFanFriends;
- (NSArray *)findAllFollowFriends;

- (Friend *)findFollowFriendByUserId:(NSString *)friendUserId;
- (BOOL)isFollowFriend:(NSString *)friendUserId;
- (BOOL)deleteFollowFriend:(NSString *)friendUserId;

- (Friend *)findFanFriendByUserId:(NSString *)friendUserId;
- (BOOL)isFanFriend:(NSString *)friendUserId;

@end
