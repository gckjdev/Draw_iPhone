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

+(CommonImageManager*)defaultManager
{
    return [CommonImageManager sharedCommonImageManager];
}

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

@end
