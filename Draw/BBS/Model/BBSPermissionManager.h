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
    PermissionForbidUser = 0x1 << 5, // 封禁用户, Board
    PermissionBlackUserList = 0x1 << 6, // 封禁用户, System black user list
    PermissionCharge = 0x1 << 7, // 充值
    PermissionPutDrawOnCell = 0x1 << 8, //将画加入销售池
    PermissionAll = (0x1<<31)-1,
    
    PermissionDefault = PermissionRead | PermissionWrite,//PermissionAll,//
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
- (BOOL)canCharge;
- (BOOL)canForbidUserIntoBlackUserList;
- (BOOL)canPutDrawOnCell;
@end
