//
//  SelfUserDetail.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import "UserDetailProtocol.h"
#import "FriendService.h"
#import "FeedService.h"



@interface SelfUserDetail : NSObject<UserDetailProtocol, FriendServiceDelegate, FeedServiceDelegate>

@property (assign, nonatomic) RelationType relation;

@end
