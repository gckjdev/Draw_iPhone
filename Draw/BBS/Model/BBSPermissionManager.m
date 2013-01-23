//
//  BBSPermissionManager.m
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import "BBSPermissionManager.h"
#import "SynthesizeSingleton.h"


@interface BBSPermissionManager()
{
    
}
@property(nonatomic, retain)NSArray *privilegeList;

@end

#define BBS_PERMISSION_KEY @"BBS_PERMISSION"

@implementation BBSPermissionManager

- (void)dealloc
{
    PPRelease(_privilegeList);
    [super dealloc];
}

+ (BBSPermissionManager *)defaultManager
{
    return [BBSPermissionManager sharedBBSPermissionManager];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(BBSPermissionManager)


- (void)updatePrivilegeList:(NSArray *)privilegeList
{
    self.privilegeList = privilegeList;
}

- (BBSUserPermission)permissionOnnBoard:(NSString *)boardId
{
    for (PBBBSPrivilege *privilege in _privilegeList) {
        if ([[privilege boardId] isEqualToString:boardId]) {
            return [privilege permission];
        }
    }
    return PermissionDefault;
}

- (BBSUserPermission)permissionOnBBS
{
    return [self permissionOnnBoard:BBS_PERMISSION_KEY];
}

#define BBS_PERMISSION ([self permissionOnBBS])
#define BOARD_PERMISSION(x) ([self permissionOnnBoard:x])
#define JUDGE_BOARD_PERMISSION(x,y) (((BBS_PERMISSION | BOARD_PERMISSION(x)) & y) != 0)


- (BOOL)canWriteOnBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionWrite);
}
- (BOOL)canDeletePost:(PBBBSPost *)post onBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionDelete)||([post.createUser isMe]);
}
- (BOOL)canTransferPost:(PBBBSPost *)post fromBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionTransfer)||([post.createUser isMe]);
}
- (BOOL)canForbidUser:(PBBBSUser *)user onBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionForbidUser);
}
- (BOOL)canForbidUser:(PBBBSUser *)user
{
    return (BBS_PERMISSION & PermissionForbidUser) != 0;
}

@end
