//
//  ViewUserDetail.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import "UserDetailProtocol.h"
#import "FeedService.h"
#import "FriendService.h"
#import "MWPhotoBrowser.h"

typedef enum {
    UserDetailActionFollowCount = 0,
    UserDetailActionDrawTo,
    UserDetailActionFollow,
    UserDetailActionChatTo,
    UserDetailActionFanCount,
}UserDetailAction;

@interface ViewUserDetail : NSObject<UserDetailProtocol, FeedServiceDelegate, FriendServiceDelegate, MWPhotoBrowserDelegate>


@property (assign, nonatomic) RelationType relation;

+ (ViewUserDetail*)viewUserDetailWithUserId:(NSString*)userId
                                     avatar:(NSString*)avatar
                                   nickName:(NSString*)nickName;


@end
