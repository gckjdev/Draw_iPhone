//
//  BBSModelExt.h
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import <Foundation/Foundation.h>
#import "Bbs.pb.h"

enum BBSBoardType {
    BBSBoardTypeParent = 1,
    BBSBoardTypeSub = 2
};

typedef enum {
    RewardStatusNo = 0,
    RewardStatusOn = 1,
    RewardStatusOff = 2
}BBSRewardStatus;


typedef enum {
    ContentTypeNo = 0,
    ContentTypeText = 1,
    ContentTypeImage = 2,
    ContentTypeDraw = 4
}BBSPostContentType;

typedef enum {
    ActionTypeNO = 0,
    ActionTypeComment, //comment and reply
    ActionTypeSupport,
}BBSActionType;

typedef enum{
    BBSPostStatusNormal = 0,
    BBSPostStatusDelete = 1,
    BBSPostStatusMark = 0x1 << 1,
    BBSPostStatusTop = 0x1 << 2
}BBSPostStatus;

typedef enum{
    BBSUserRoleNormal = 0,
    BBSUserRoleForbided = 0x1,
    BBSUserRoleBoardAdmin = 0x1 << 1,
    BBSUserRoleBBSAdmin = 0x1 << 2,
}BBSUserRole;


@interface PBBBSContent (ContentExt)

- (BOOL)hasThumbImage;
- (BOOL)hasLargeImage;
- (NSURL *)thumbImageURL;
- (NSURL *)largeImageURL;

@end

@interface PBBBSUser (UserExt)

- (NSString *)showNick;
- (BOOL)isMe;
- (UIImage *)defaultAvatar;
- (NSURL *)avatarURL;
- (NSString *)genderString;
@end


@interface PBBBSPost (PostExt)

- (BOOL)canDelete;
- (BOOL)isMyPost;
- (BOOL)canPay;
- (BOOL)isTopPost;
- (NSString *)postUid;
- (NSString *)postText;
- (NSDate *)cDate;
- (NSInteger)rewardBonus;

- (void)setPay:(BOOL)pay;
- (BOOL)hasPay;
- (NSString *)createDateString;

@end

@interface PBBBSAction (ActionExt)

- (BOOL)isCommet;
- (BOOL)isReply;
- (BOOL)isSupport;
- (NSString *)contentText;
- (NSString *)showText;
- (NSString *)showSourceText;
- (BOOL)canDelete;
- (BOOL)isMyAction;
- (NSDate *)cDate;
- (NSString *)createDateString;
@end

@interface PBBBSActionSource (ActionSourceExt)

- (BOOL)commentToMe;
- (BOOL)replyToMe;
- (NSString *)replyNick;

@end

@interface PBBBSBoard (BoardExt)
- (NSURL *)iconURL;
- (PBBBSBoard *)parentBoard;
- (NSString *)fullName;
@end

