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

@property(nonatomic, retain)NSString *groupId;

+ (id)myManagerWithGroupId:(NSString *)groupId;

+ (NSArray *)groupRoles;
+ (void)syncGroupRoles:(NSArray *)array;
+ (void)clearGroupRoles;
+ (void)removeRole:(NSString *)groupId;



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

//manager permission
- (BOOL)canManageGroup;
- (BOOL)canHoldContest;

//Creator permission
- (BOOL)canArrangeAdmin;
- (BOOL)canArrangePermission;
- (BOOL)canUpgradeGroup;
- (BOOL)canDismissalGroup;




//global permission
+ (BOOL)canCreateGroup;

+ (BOOL)amIGroupTestUser;



@end
