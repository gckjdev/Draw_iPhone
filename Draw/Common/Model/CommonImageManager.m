//
//  CommonImageManager.m
//  Draw
//
//  Created by Kira on 12-11-27.
//
//

#import "CommonImageManager.h"
#import "SynthesizeSingleton.h"
#import "UIImageUtil.h"

#import "PPResourceService.h"

@implementation CommonImageManager 

SYNTHESIZE_SINGLETON_FOR_CLASS(CommonImageManager)

- (id)init
{
    if (self = [super init]) {
        _resService = [PPResourceService defaultService];
    }
    
    return self;
}

- (UIImage*)starryBackgroundImage
{
    return [_resService imageByName:@"starryBg" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage*)planetImage
{
    return [_resService imageByName:@"loading_planet" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage*)starryDialogClickImage
{
    return [_resService imageByName:@"dialog_yes" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage*)starryDialogCrossImage
{
    return [_resService imageByName:@"dialog_no" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage*)starryDialogButtonBackgroundImage
{
    return [_resService imageByName:@"dialog_frame" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage*)starryDialogBackgroundImage
{
    return [_resService imageByName:@"dialog_bg" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage*)starryDialogBackgroundSideImage
{
    return [UIImage strectchableImageName:@"dialog_smallbg"];
}

- (UIImage*)starryLoadingLight
{
    return [_resService imageByName:@"light" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage*)starryLoadingStar
{
    return [_resService imageByName:@"star" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)maleImage
{
    return [_resService imageByName:@"maleImage" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)femaleImage
{
    return [_resService imageByName:@"femaleImage" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)albumImage
{
    return [_resService imageByName:@"gallery" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)emailImage
{
    return [_resService imageByName:@"email" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)sinaImage
{
    return [_resService imageByName:@"sina" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)qqWeiboImage
{
    return [_resService imageByName:@"qq" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)facebookImage
{
    return [_resService imageByName:@"facebook" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)favoriteImage
{
    return [_resService imageByName:@"favorite" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)wechatImage
{
    return [_resService imageByName:@"wechat" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)wechatFriendsImage
{
    return [_resService imageByName:@"wechat_friend" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage*)commonMessageCenterHappyFace
{
    return [UIImage imageNamed:@"super_face_smile.png"];
}
- (UIImage*)commonMessageCenterUnhappyFace
{
    return [UIImage imageNamed:@"super_face_cry.png"];
}

- (UIImage*)photoTagTitleBackground
{
    return [UIImage imageNamed:@"photo_tag_title_bg.png"];
}
- (UIImage*)photoTagUnselectedBackground
{
    return [UIImage imageNamed:@"photo_tag_unselect.png"];
}
- (UIImage*)photoTagSelectedBackground
{
    return [UIImage imageNamed:@"photo_tag_select.png"];
}

@end
