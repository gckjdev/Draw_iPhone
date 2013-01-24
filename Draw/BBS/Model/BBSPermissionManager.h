//
//  BBSPermissionManager.h
//  Draw
//
//  Created by gamy on 13-1-23.
//
//

#import <Foundation/Foundation.h>
#import "BBSModelExt.h"

typedef enum{
    PermissionRead = 0x1, // 读
    PermissionWrite = 0x1 << 1, // 写
    PermissionDelete = 0x1 << 2, // 删帖
    PermissionTransfer = 0x1 << 3, // 转移
    PermissionToTop = 0x1 << 4, // 置顶
    PermissionForbidUser = 0x1 << 5, // 封禁用户
    PermissionAll = (0x1<<7)-1,
    PermissionDefault = PermissionAll//PermissionRead | PermissionWrite,
}BBSUserPermission;

@interface BBSPermissionManager : NSObject

+ (BBSPermissionManager *)defaultManager;
- (void)updatePrivilegeList:(NSArray *)privilegeList;
- (BOOL)canWriteOnBBBoard:(NSString *)boardId;
- (BOOL)canDeletePost:(PBBBSPost *)post onBBBoard:(NSString *)boardId;
- (BOOL)canTransferPost:(PBBBSPost *)post fromBBBoard:(NSString *)boardId;
- (BOOL)canTopPost:(PBBBSPost *)post onBBBoard:(NSString *)boardId;
- (BOOL)canForbidUser:(PBBBSUser *)user onBBBoard:(NSString *)boardId;
- (BOOL)canForbidUser:(PBBBSUser *)user;

@end
