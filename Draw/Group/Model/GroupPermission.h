//
//  GroupPermission.h
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "GroupConstants.h"

@class PBGroup;
@class PBBBSPost;
@class PBGroupUser;
@class PBBBSAction;

@interface GroupPermissionManager : NSObject

@property(nonatomic, retain)PBGroup *group;
//@property(nonatomic, copy) NSString *userId;

//+ (id)managerWithUserId:(NSString *)userId group:(PBGroup *)group;
+ (id)myManagerWithGroup:(PBGroup *)group;

- (BOOL)hasPermission:(GroupPermission)permission;

//Group
- (BOOL)canJoinGroup;
- (BOOL)canAccessGroup;
- (BOOL)canQuitGroup;
- (BOOL)canGroupChat;

//Topic
- (BOOL)canCreateTopic;
- (BOOL)canReplyTopic;
- (BOOL)canDeleteTopic:(PBBBSPost *)post;
- (BOOL)canDeleteAction:(PBBBSAction *)action;

//admin permission
- (BOOL)canMarkTopic;
- (BOOL)canTopTopic;
- (BOOL)canHandleRequest;
- (BOOL)canExpelUser:(PBGameUser*)user;
- (BOOL)canInviteUser;
- (BOOL)canInviteGuest;
- (BOOL)canCustomTitle;

//Creator permission
- (BOOL)canArrangeAdmin;
- (BOOL)canArrangePermission;
- (BOOL)canUpgradeGroup;
- (BOOL)canDismissalGroup;

//global permission
+ (BOOL)canCreateGroup;

@end
