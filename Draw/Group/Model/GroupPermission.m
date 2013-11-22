//
//  GroupPermission.m
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "GroupPermission.h"
#import "Group.pb.h"
#import "BBSModelExt.h"

@implementation GroupPermissionManager

- (void)dealloc
{
    PPRelease(_group);
    [super dealloc];
}
- (BOOL)hasPermission:(GroupPermission)permission
{
    return _group.relation.permission & permission;    
}

#define PERMIT(x) [self hasPermission:x]

+ (id)myManagerWithGroup:(PBGroup *)group
{
    GroupPermissionManager *manager = [[GroupPermissionManager alloc] init];
    manager.group = group;
    return [manager autorelease];
}


//Group
- (BOOL)canJoinGroup
{
    return PERMIT(JOIN_GROUP) && ![[UserManager defaultManager] hasJoinedAGroup];
}

- (BOOL)canQuitGroup
{
    return PERMIT(QUIT_GROUP);
}
- (BOOL)canAccessGroup
{
    return PERMIT(ACCESS_GROUP);
}

//Topic
- (BOOL)canCreateTopic
{
    return PERMIT(CREATE_TOPIC);
}
- (BOOL)canReplyTopic
{
    return PERMIT(REPLY_TOPIC);
}
- (BOOL)canDeleteTopic:(PBBBSPost *)post
{
    return PERMIT(DELETE_TOPIC) || [post isMyPost];
}

//admin permission
- (BOOL)canMarkTopic
{
    return PERMIT(MARK_TOPIC);
}
- (BOOL)canTopTopic
{
    return PERMIT(TOP_TOPIC);
}
- (BOOL)canHandleRequest
{
    return PERMIT(HANDLE_REQUEST);
}
- (BOOL)canExpelUser:(PBGroupUser*)user
{
    return PERMIT(EXPEL_USER) && user.type != GroupRoleCreator;
}
- (BOOL)canInviteUser
{
    return PERMIT(INVITE_USER);
}
- (BOOL)canInviteGuest
{
    return PERMIT(INVITE_GUEST);
}

- (BOOL)canCustomTitle
{
    return PERMIT(CUSTOM_TITLE);
}

//Creator permission
- (BOOL)canArrangeAdmin
{
    return PERMIT(ARRANGE_ADMIN);
}
- (BOOL)canArrangePermission
{
    return PERMIT(ARRANGE_PERMISSION);
}
- (BOOL)canUpgradeGroup
{
    return PERMIT(UPGRADE_GROUP);
}


+ (BOOL)canCreateGroup
{
    return ![[UserManager defaultManager] hasJoinedAGroup];
}
@end
