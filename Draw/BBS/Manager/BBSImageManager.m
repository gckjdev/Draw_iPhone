//
//  BBSImageManager.m
//  Draw
//
//  Created by gamy on 12-11-27.
//
//

#import "BBSImageManager.h"
#import "PPResourceService.h"
#import "GameResource.h"


//BBSImageManager *_staticBBSImageManager;

@interface BBSImageManager ()
{
    PPResourceService *_resService;
}

@end

@implementation BBSImageManager

static BBSImageManager* _staticBBSImageManager;


+ (id)defaultManager
{
    if (_staticBBSImageManager == nil) {
        _staticBBSImageManager = [[BBSImageManager alloc] init];
    }
    return _staticBBSImageManager;
}

- (id)init
{
    if (self = [super init]) {
        _resService = [PPResourceService defaultService];
    }
    return self;
}


- (UIImage *)bbsBadgeImage
{
     return [_resService imageByName:@"bbs_badge"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBoardBgImage
{
     return [_resService imageByName:@"bbs_board_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBoardLastBgImage
{
     return [_resService imageByName:@"bbs_board_last_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBoardLineImage
{
     return [_resService imageByName:@"bbs_board_line"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsButtonLeftImage
{
     return [_resService imageByName:@"bbs_button_left"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsButtonRightImage
{
     return [_resService imageByName:@"bbs_button_right"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSectionBgImage
{
     return [_resService imageByName:@"bbs_section_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchBgImage
{
     return [_resService imageByName:@"bbs_switch_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchDownImage
{
     return [_resService imageByName:@"bbs_switch_down"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchRightImage
{
     return [_resService imageByName:@"bbs_switch_right"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBackImage
{
    return [_resService imageByName:@"bbs_back"
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBGImage
{
    return [_resService imageByName:@"bbs_bg"
                  inResourcePackage:RESOURCE_PACKAGE_BBS];   
}

@end
