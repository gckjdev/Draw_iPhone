//
//  GroupConstants.h
//  Draw
//
//  Created by Gamy on 13-11-22.
//
//

#import <Foundation/Foundation.h>
#import "PPConfigManager.h"

typedef enum{
    GroupRoleNone           = 0,
    GroupRoleCreator        = 1,
    GroupRoleAdmin          = 2,
    GroupRoleMember         = 3,
    GroupRoleGuest          = 4,

    GroupRoleRequester      = 5,
    GroupRoleInvitee        = 6,
    GroupRoleGuestInvitee   = 7,
    
}GroupRole;

#define CUSTOM_TITLE_START 11

//notification
#define REFRESH_FOLLOW_TOPIC_TAB @"REFRESH_FOLLOW_TOPIC_TAB"

typedef enum {
    
    NONE                    = (0),      //无权限
    
    //GROUP
    ACCESS_GROUP            =    (0x1 << 1),     //进入家族
    JOIN_GROUP              =    (0x1 << 2),     //申请加入家族
    QUIT_GROUP              =    (0x1 << 3),     //退出家族
    CHAT_GROUP              =    (0x1 << 4),     //群聊
    
    //TOPIC
    READ_TOPIC              =    (0x1 << 10),     //读贴
    CREATE_TOPIC            =    (0x1 << 11),     //发帖
    DELETE_TOPIC            =    (0x1 << 12),     //删帖
    REPLY_TOPIC             =    (0x1 << 13),     //回复
    MARK_TOPIC              =    (0x1 << 14),     //加精
    TOP_TOPIC               =    (0x1 << 15),     //置顶话题
    
    //USER
    HANDLE_REQUEST          =    (0x1 << 20),     //通过或者拒绝加入请求
    INVITE_USER             =    (0x1 << 21),     // 邀请用户
    INVITE_GUEST            =    (0x1 << 22),     // 邀请嘉宾
    EXPEL_USER              =    (0x1 << 23),     // T人
    CUSTOM_TITLE            =    (0x1 << 24),     // 自定义title
    ARRANGE_ADMIN           =    (0x1 << 25),     //管理管理员
    ARRANGE_PERMISSION      =    (0x1 << 26),     //分配权限
    UPGRADE_GROUP           =    (0x1 << 27),     //升级群
    DISMISSAL_GROUP         =    (0x1 << 28),     //解散群
    EDIT_GROUP              =    (0x1 << 30),     //编辑群
    HOLD_CONTEST            =    (0x1 << 31),     //举办比赛
    
    GROUP_DEFAULT_PERMISSION = JOIN_GROUP|ACCESS_GROUP|READ_TOPIC,
    
    
}GroupPermission;


typedef enum{
    InviteUserTypeMember = 1,
    InviteUserTypeGuest = 2,
}InviteUserType;


typedef enum{
    GetGroupListTypeFollow = 1,
    GetGroupListTypeNew = 2,
    GetGroupListTypeBalance = 3,
    GetGroupListTypeActive = 4,
    GetGroupListTypeFame = 5,
}GetGroupListType;


typedef enum{
    GroupNoticeTypeNotice = 1,
    GroupNoticeTypeRequest = 2,
}GroupNoticeType;


typedef enum{
    GroupTabGroup = 100,
    GroupTabTopic = 101,
    GroupTabFollow = 102,
    
    GroupTabGroupFollow = GetGroupListTypeFollow,
    GroupTabGroupNew = GetGroupListTypeNew,
    GroupTabGroupBalance = GetGroupListTypeBalance,
    GroupTabGroupActive = GetGroupListTypeActive,
    GroupTabGroupFame = GetGroupListTypeFame,
    
}GroupTab;



#define  MAX_LENGTH_NAME [PPConfigManager getGroupNameMaxLength]
#define  MAX_LENGTH_TITLE [PPConfigManager getGroupTitleNameMaxLength]
#define  MAX_LENGTH_SIGNATURE [PPConfigManager getGroupSignatureMaxLength]
#define  MAX_LENGTH_DESCRIPTION [PPConfigManager getGroupIntroduceMaxLength]



