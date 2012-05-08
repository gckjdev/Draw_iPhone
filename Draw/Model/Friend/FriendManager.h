//
//  FriendManager.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendManager : NSObject

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

- (NSArray *)findAllFanFriends;

- (NSArray *)findAllFollowFriends;

- (BOOL)deleteFollowFriend:(NSString *)friendUserId;

@end
