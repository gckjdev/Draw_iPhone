//
//  CommonImageManager.m
//  Draw
//
//  Created by Kira on 12-11-27.
//
//

#import "CommonImageManager.h"
#import "SynthesizeSingleton.h"

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

@end
