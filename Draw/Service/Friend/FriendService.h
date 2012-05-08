//
//  FriendService.h
//  Draw
//
//  Created by  on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendService : NSObject
+ (FriendService*)defaultService;

- (void)findFriendsByType:(int)type;
- (void)searchUsersByString:(NSString*)searchString;
- (void)followUser:(NSString*)targetUserId;
- (void)unFollowUser:(NSString*)targetUserId;

@end
