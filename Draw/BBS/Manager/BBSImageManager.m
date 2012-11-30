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
#import "ShareImageManager.h"

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


- (NSString *)fixImageName:(NSString *)imageName
{
    if([DeviceDetection isIPAD]){
        return [NSString stringWithFormat:@"%@@2x",imageName];
    }
    return imageName;
}

- (UIImage *)stretchableImageWithImageName:(NSString *)name
                         inResourcePackage:(NSString *)package
{
    NSString *imageName = [self fixImageName:name];
    UIImage *image = [_resService imageByName:imageName
                            inResourcePackage:package];
    return [image stretchableImageWithLeftCapWidth:image.size.width/2.0 topCapHeight:image.size.height/2.0];
}


- (UIImage *)bbsBadgeImage
{
     return [self stretchableImageWithImageName:@"bbs_badge"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBoardBgImage
{
    return [self stretchableImageWithImageName:@"bbs_board_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBoardLastBgImage
{
     return [self stretchableImageWithImageName:@"bbs_board_last_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
    
}
- (UIImage *)bbsBoardLineImage
{
     return [self stretchableImageWithImageName:@"bbs_board_line"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsButtonLeftImage
{
     return [self stretchableImageWithImageName:@"bbs_button_left"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsButtonRightImage
{
     return [self stretchableImageWithImageName:@"bbs_button_right"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSectionBgImage
{
     return [self stretchableImageWithImageName:@"bbs_section_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchBgImage
{
     return [self stretchableImageWithImageName:@"bbs_switch_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchDownImage
{
     return [self stretchableImageWithImageName:@"bbs_switch_down"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchRightImage
{
    return [self stretchableImageWithImageName:@"bbs_switch_right"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBackImage
{
    return [self stretchableImageWithImageName:@"bbs_back"
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBGImage
{
    return [_resService imageByName:@"bbs_bg"
                  inResourcePackage:RESOURCE_PACKAGE_BBS];   
}



//Post list
- (UIImage *)bbsPostContentBGImage{
    return [self stretchableImageWithImageName:@"bbs_post_content_bg"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];

}
- (UIImage *)bbsPostEditImage{
    NSString *imageName = [self fixImageName:@"bbs_post_edit"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostHotImage{
    NSString *imageName = [self fixImageName:@"bbs_post_hot"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostNewImage{
    NSString *imageName = [self fixImageName:@"bbs_post_new"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostRewardImage{
    NSString *imageName = [self fixImageName:@"bbs_post_reward"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostRewardedImage{
    NSString *imageName = [self fixImageName:@"bbs_post_rewarded"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostSupportImage{
    NSString *imageName = [self fixImageName:@"bbs_post_support"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostCommentImage{
    NSString *imageName = [self fixImageName:@"bbs_post_comment"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
    
}

@end
