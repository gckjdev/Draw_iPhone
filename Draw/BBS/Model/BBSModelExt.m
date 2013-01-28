//
//  BBSModelExt.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSModelExt.h"
#import "UserManager.h"
#import "ShareImageManager.h"
#import "BBSManager.h"
#import "TimeUtils.h"
#import "BBSPermissionManager.h"

@implementation PBBBSContent (ContentExt)
- (BOOL)hasThumbImage
{
    if (self.type == ContentTypeImage && self.hasThumbImageUrl) {
        return YES;
    }else if (self.type == ContentTypeDraw && self.hasDrawThumbUrl) {
        return YES;
    }
    return NO;
}
- (BOOL)hasLargeImage
{
    if (self.type == ContentTypeImage && self.hasImageUrl) {
        return YES;
    }else if(self.type == ContentTypeDraw && self.hasDrawImageUrl) {
        return YES;
    }
    return NO;    
}
- (NSURL *)thumbImageURL
{
    if (self.type == ContentTypeImage && self.hasThumbImageUrl) {
        return [NSURL URLWithString:self.thumbImageUrl];
    }else if(self.type == ContentTypeDraw && self.hasDrawThumbUrl){
        return [NSURL URLWithString:self.drawThumbUrl];
    }
    return nil;
    
}
- (NSURL *)largeImageURL
{
    if (self.type == ContentTypeImage && self.hasImageUrl) {
        return [NSURL URLWithString:self.imageUrl];;
    }else if(self.type == ContentTypeDraw && self.hasDrawImageUrl) {
        return [NSURL URLWithString:self.drawImageUrl];;
    }
    return nil;
}

@end


@implementation PBBBSUser (UserExt)

- (BOOL)isMe
{
    return [[UserManager defaultManager] isMe:self.userId];
}
- (NSString *)showNick
{
    if ([self isMe]) {
        return NSLS(@"kMe");
    }
    return self.nickName;
}

- (UIImage *)defaultAvatar
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    return self.gender ? [imageManager maleDefaultAvatarImage] : [imageManager femaleDefaultAvatarImage];
}
- (NSURL *)avatarURL
{
    if ([self.avatar length] != 0) {
        return [NSURL URLWithString:self.avatar];
    }
    return nil;
}
- (NSString *)genderString
{
    return [self gender] ? @"m" : @"f";
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"[uid = %@, nick = %@, avatar = %@, gender = %d]", self.userId, self.nickName, self.avatar, self.gender];
    return desc;
}

@end


@implementation PBBBSPost (PostExt)

- (BOOL)canDelete
{
//    return [self isMyPost];
    return [[BBSPermissionManager defaultManager] canDeletePost:self onBBBoard:self.boardId];
}
- (BOOL)isMyPost
{
    return [[UserManager defaultManager] isMe:self.createUser.userId];
}

- (BOOL)canPay
{
   return [self isMyPost] && [self hasReward] && ![self hasPay];
}

- (BOOL)isTopPost
{
    return self.status == BBSPostStatusTop;
}

- (NSString *)postUid
{
    return self.createUser.userId;
}
- (NSString *)postText
{
    return self.content.text;
}

- (NSDate *)cDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.createDate];
}

- (NSInteger)rewardBonus
{
    return self.reward.bonus;
}

#define POST_PAY_KEY_PRE @"POST_PAY"

- (void)setPay:(BOOL)pay
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",POST_PAY_KEY_PRE,self.postId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:pay forKey:key];
}

- (BOOL)hasPay
{
    if([self.reward hasWinner]) return YES;
    NSString *key = [NSString stringWithFormat:@"%@_%@",POST_PAY_KEY_PRE,self.postId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}
- (NSString *)createDateString
{
    return dateToTimeLineString(self.cDate);
}

@end

@implementation PBBBSAction (ActionExt)

- (NSString *)showText
{
    if (self.type == ActionTypeSupport) {
        return NSLS(@"kBBSSupport");
    }
    if (self.type == ActionTypeComment) {
        if ([self isCommet]) {
            return self.content.text;
        }else if([self isReply]){
            
            return [NSString stringWithFormat:NSLS(@"kReplyUserPost"),
                    self.source.replyNick,
                    self.content.text];
        }
    }
    return nil;
}

- (NSString *)contentText
{
    if (self.type == ActionTypeSupport) {
        return NSLS(@"kBBSSupport");
    }
    if (self.type == ActionTypeComment) {
        return self.content.text;
    }
    return nil;
}

- (NSString *)showSourceText
{
    //回复我的评论
    //回复我的帖子
    NSString *srcText = self.source.briefText;
    if ([self isSupport]) {
        //如果是顶贴
        return [NSString stringWithFormat:NSLS(@"kSupportMyPost"),srcText];
    }else if([self isCommet]){
        return [NSString stringWithFormat:NSLS(@"kCommentMyPost"),srcText];
    }else if([self isReply]){
        return [NSString stringWithFormat:NSLS(@"kReplyMyComment"),srcText];
    }
    return nil;
//    self.source
}

- (BOOL)isCommet
{
    return !self.source.hasActionId;
}
- (BOOL)isReply
{
    return self.source.hasActionId;
}
- (BOOL)isSupport
{
    return self.type == ActionTypeSupport;
}

- (BOOL)canDelete
{
    return [self isMyAction];
}

- (BOOL)isMyAction
{
    return [[UserManager defaultManager] isMe:self.createUser.userId];
}

- (NSDate *)cDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.createDate];
}

- (NSString *)createDateString
{
    return dateToTimeLineString(self.cDate);
}
@end

@implementation PBBBSActionSource (ActionSourceExt)

- (BOOL)commentToMe
{
    if (!self.hasActionId && [[UserManager defaultManager] isMe:self.postUid]) {
        return YES;
    }
    return NO;
}
- (BOOL)replyToMe
{
    if (self.hasActionId && [[UserManager defaultManager] isMe:self.actionUid]) {
        return YES;
    }
    return NO;
}
- (NSString *)replyNick
{
    if ([self commentToMe] || [self replyToMe]) {
        return NSLS(@"kMe");
    }
    return self.actionNick;
}

@end


@implementation PBBBSBoard (BoardExt)

- (NSURL *)iconURL
{
    if (self.icon) {
        return [NSURL URLWithString:self.icon];
    }
    return nil;
}
- (PBBBSBoard *)parentBoard
{
    return [[BBSManager defaultManager] parentBoardOfsubBoard:self];
}
- (NSString *)fullName
{
    PBBBSBoard *pBoard = [self parentBoard];
    if (pBoard) {
        return [NSString stringWithFormat:@"%@/%@",pBoard.name,self.name];
    }
    return self.name;
}

@end