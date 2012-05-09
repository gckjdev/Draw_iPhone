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

@protocol FriendServiceDelegate <NSObject>

@optional
- (void)didfindFriendsByType:(int)type friendList:(NSArray *)friendList result:(int)resultCode;
- (void)searchUsers:(NSArray *)userList result:(int)resultCode;
- (void)didFollowUser:(int)resultCode;
- (void)didUnFollowUser:(int)resultCode;

@end

@interface FriendService : CommonService
+ (FriendService*)defaultService;

- (void)findFriendsByType:(int)type viewController:(PPViewController<FriendServiceDelegate>*)viewController;
- (void)searchUsersByString:(NSString*)searchString;
- (void)followUser:(NSString*)targetUserId;
- (void)unFollowUser:(NSString*)targetUserId;

@end
