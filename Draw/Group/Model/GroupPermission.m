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
#import "GroupModelExt.h"

static NSMutableArray *_roles;

@implementation GroupPermissionManager


#define GROUP_ROLES_KEY @"GROUP_ROLES"

+ (NSMutableArray *)groupRoles
{
    if (!_roles) {
        _roles = [[NSMutableArray array] retain];
        NSArray *array = [[[UserManager defaultManager] userDefaults] arrayForKey:GROUP_ROLES_KEY];
        if ([array count] > 0) {
            [_roles addObjectsFromArray:array];
        }
    }
    return _roles;
}

+ (void)clearGroupRoles
{
    [_roles release];
    _roles = nil;
}

+ (PBGroupUserRole *)roleForGroupId:(NSString *)groupId
{
    NSArray *roles = [self groupRoles];
    for (PBGroupUserRole *role in roles) {
        if ([role.groupId isEqualToString:groupId]) {
            return role;
        }
    }
    return nil;
}

+ (void)removeRole:(NSString *)groupId
{
    PBGroupUserRole *role = [self roleForGroupId:groupId];
    if (role) {
        [_roles removeObject:role];
        [self syncGroupRoles:_roles];
    }
}

+ (void)syncGroupRoles:(NSArray *)roles
{
    NSMutableArray *dataList = [NSMutableArray array];
    for (PBGroupUserRole *role in roles) {
        NSData *data = [role data];
        if (data) {
            [dataList addObject:data];
        }
    }
    if (_roles != roles) {
        [_roles release];
        _roles = [NSMutableArray arrayWithArray:roles];
        [_roles retain];
    }
    
    [[[UserManager defaultManager] userDefaults] setArray:dataList forKey:GROUP_ROLES_KEY];
    [[[UserManager defaultManager] userDefaults] synchronize];
}


- (void)dealloc
{
    PPRelease(_groupId);
    [super dealloc];
}

+ (PBGroupUserRole *)defaultGroupRole
{
    static dispatch_once_t onceToken;
    static PBGroupUserRole * _defaultRole;
    dispatch_once(&onceToken, ^{
        PBGroupUserRole_Builder *builder = [[PBGroupUserRole_Builder alloc] init];
        [builder setGroupId:@"NONE"];
        [builder setRole:GroupRoleNone];
        [builder setPermission:GROUP_DEFAULT_PERMISSION];
        _defaultRole = [builder build];
        [builder release];
    });
    return _defaultRole;
}

- (BOOL)hasPermission:(GroupPermission)permission
{
    PBGroupUserRole *role = [GroupPermissionManager roleForGroupId:self.groupId];
    if (role == nil) {
        role = [GroupPermissionManager defaultGroupRole];
    }
    return (role.permission & permission) != 0;
}

#define PERMIT(x) [self hasPermission:x]



+ (id)myManagerWithGroupId:(NSString *)groupId
{
    GroupPermissionManager *manager = [[GroupPermissionManager alloc] init];
    manager.groupId = groupId;
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

- (BOOL)canGroupChat
{
    return PERMIT(CHAT_GROUP);
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

- (BOOL)canDeleteAction:(PBBBSAction *)action
{
    return PERMIT(DELETE_TOPIC) || [action isMyAction];
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
- (BOOL)canExpelUser:(PBGameUser*)user
{
    return PERMIT(EXPEL_USER);
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


- (BOOL)canManageGroup
{
    return PERMIT(EDIT_GROUP);
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

- (BOOL)canDismissalGroup
{
    return PERMIT(DISMISSAL_GROUP);
}

+ (BOOL)canCreateGroup
{
    return ![[UserManager defaultManager] hasJoinedAGroup];
}
@end
