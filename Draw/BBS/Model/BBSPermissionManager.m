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

#define PERMISSION_SITE @"PERMISSION_SITE"

@implementation BBSPermissionManager

- (void)dealloc
{
    PPRelease(_privilegeList);
    [super dealloc];
}

SYNTHESIZE_SINGLETON_FOR_CLASS(BBSPermissionManager)


- (void)updatePrivilegeList:(NSArray *)privilegeList
{
    PPDebug(@"<updatePrivilegeList>, privilegeList count = %d", [privilegeList count]);
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
    return [self permissionOnnBoard:PERMISSION_SITE];
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
    return JUDGE_BOARD_PERMISSION(boardId, PermissionDelete)||([post isMyPost]);
}
- (BOOL)canTopPost:(PBBBSPost *)post onBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionToTop);
}
- (BOOL)canTransferPost:(PBBBSPost *)post fromBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionTransfer);
}
- (BOOL)canForbidUser:(PBBBSUser *)user onBBBoard:(NSString *)boardId
{
    return JUDGE_BOARD_PERMISSION(boardId, PermissionForbidUser);
}
- (BOOL)canForbidUser:(PBBBSUser *)user
{
    return (BBS_PERMISSION & PermissionForbidUser) != 0;
}

- (BOOL)canForbidUserIntoBlackUserList
{
    return (BBS_PERMISSION & PermissionBlackUserList) != 0;
}

- (BOOL)canCharge
{
    return (BBS_PERMISSION & PermissionCharge) != 0;
}

- (BOOL)canPutDrawOnCell
{
    return NO;
//    return (BBS_PERMISSION & PermissionPutDrawOnCell) != 0;
}

@end
