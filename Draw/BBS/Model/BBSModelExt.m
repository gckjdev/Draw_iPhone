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

@end


@implementation PBBBSAction (ActionExt)

- (NSString *)showText
{
    if (self.type == ActionTypeSupport) {
        return NSLS(@"kSupport");
    }
    if (self.type == ActionTypeComment) {
        if ([self.source isCommet]) {
            return self.content.text;
        }else if([self.source isReply]){
            return [NSString stringWithFormat:@"kReply %@: %@",self.createUser.showNick, self.content.text];
        }
    }
    return nil;
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
- (BOOL)isCommet
{
    return !self.hasActionId;
}
- (BOOL)isReply
{
    return self.hasActionId;    
}


@end
