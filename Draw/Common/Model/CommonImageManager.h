//
//  CommonImageManager.h
//  Draw
//
//  Created by Kira on 12-11-27.
//
//

#import <Foundation/Foundation.h>
#import "ImageManagerProtocol.h"
@class PPResourceService;

@interface CommonImageManager : NSObject {
    PPResourceService*  _resService;
}

+(CommonImageManager*)defaultManager;

- (UIImage*)starryBackgroundImage;
- (UIImage*)planetImage;

- (UIImage*)starryDialogClickImage;
- (UIImage*)starryDialogCrossImage;
- (UIImage*)starryDialogButtonBackgroundImage;
- (UIImage*)starryDialogBackgroundImage;
- (UIImage*)starryDialogBackgroundSideImage;

- (UIImage*)starryLoadingLight;
- (UIImage*)starryLoadingStar;

- (UIImage *)maleImage;
- (UIImage *)femaleImage;

- (UIImage *)albumImage;
- (UIImage *)emailImage;
- (UIImage *)sinaImage;
- (UIImage *)qqWeiboImage;
- (UIImage *)facebookImage;
- (UIImage *)favoriteImage;
- (UIImage *)wechatImage;
- (UIImage *)wechatFriendsImage;

- (UIImage*)commonMessageCenterHappyFace;
- (UIImage*)commonMessageCenterUnhappyFace;

- (UIImage*)photoTagTitleBackground;
- (UIImage*)photoTagUnselectedBackground;
- (UIImage*)photoTagSelectedBackground;

@end
