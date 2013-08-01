//
//  FriendService.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "PPViewController.h"


@class MyFriend;

@protocol FriendServiceDelegate <NSObject>

@optional

#pragma mark - old friend protocal
- (void)didfindFriendsByType:(int)type friendList:(NSArray *)friendList result:(int)resultCode;
- (void)didSearchUsers:(NSArray *)userList result:(int)resultCode;
- (void)didFollowUser:(int)resultCode;
- (void)didUnFollowUser:(int)resultCode;

#pragma mark - new friend protocal
- (void)didFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode;
- (void)didUnFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode;
- (void)didRemoveFan:(MyFriend *)fan resultCode:(NSInteger)resultCode;
- (void)didGetFanCount:(NSInteger)fanCount
           followCount:(NSInteger)followCount
            blackCount:(NSInteger)blackCount
            resultCode:(NSInteger)resultCode;

@end

typedef enum{
    FriendTypeFan = 2,
    FriendTypeFollow = 1,
    FriendTypeFriend = 3,
    FriendTypeBlack = 4,
}FriendType;



@interface FriendService : CommonService

+ (FriendService*)defaultService;

#pragma mark - old friend methods 
- (void)findFriendsByType:(int)type viewController:(PPViewController<FriendServiceDelegate>*)viewController;
- (void)searchUsersByString:(NSString*)searchString viewController:(PPViewController<FriendServiceDelegate>*)viewController;
- (void)followUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController;
- (void)unFollowUser:(NSString*)targetUserId viewController:(PPViewController<FriendServiceDelegate>*)viewController;
- (void)followUser:(NSString*)targetUserId
      withDelegate:(id<FriendServiceDelegate>)aDelegate;

#pragma mark - new friend methods 

- (void)searchUsersWithKey:(NSString*)key
                    offset:(NSInteger)offset 
                     limit:(NSInteger)limit
                  delegate:(id<FriendServiceDelegate>)delegate;

- (void)followUser:(MyFriend *)myFriend 
          delegate:(id<FriendServiceDelegate>)delegate;

- (void)unFollowUser:(MyFriend *)myFriend 
            delegate:(id<FriendServiceDelegate>)delegate;

- (void)removeFan:(MyFriend *)fan 
         delegate:(id<FriendServiceDelegate>)delegate;

- (void)getFriendList:(FriendType)type 
            offset:(NSInteger)offset 
             limit:(NSInteger)limit
          delegate:(id<FriendServiceDelegate>)delegate;

- (void)followUser:(NSString*)targetUserId 
      withDelegate:(id<FriendServiceDelegate>)aDelegate;

- (void)getRelationCount:(id<FriendServiceDelegate>)delegate;
- (void)blackFriend:(NSString*)targetUserId
       successBlock:(void (^)(void))successBlock;
- (void)unblackFriend:(NSString*)targetUserId
         successBlock:(void (^)(void))successBlock;

- (void)setFriendMemo:(NSString*)targetUserId
                 memo:(NSString*)memo
         successBlock:(void (^)(int resultCode))successBlock;



@end
