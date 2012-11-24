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
@end


@interface PBBBSAction (ActionExt)

- (BOOL)isCommet;
- (BOOL)isReply;
- (BOOL)isSupport;
- (NSString *)contentText;
- (NSString *)showText;
- (NSString *)showSourceText;
@end

@interface PBBBSActionSource (ActionSourceExt)

- (BOOL)commentToMe;
- (BOOL)replyToMe;
- (NSString *)replyNick;

@end


