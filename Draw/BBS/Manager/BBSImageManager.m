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
                         leftCapWidthScale:(CGFloat)leftCapWidthScale //0.0-1.0
                         topCapHeightScale:(CGFloat)topCapHeightScale //0.0-1.0
                         inResourcePackage:(NSString *)package
{
    NSString *imageName = [self fixImageName:name];
    UIImage *image = [_resService imageByName:imageName
                            inResourcePackage:package];
    return [image stretchableImageWithLeftCapWidth:image.size.width * leftCapWidthScale
                                      topCapHeight:image.size.height * topCapHeightScale];
}

- (UIImage *)stretchableImageWithImageName:(NSString *)name
                         inResourcePackage:(NSString *)package
{
    return [self stretchableImageWithImageName:name
                             leftCapWidthScale:0.5
                             topCapHeightScale:0.5
                             inResourcePackage:package];
}
//Common image

#pragma mark - Common image

- (UIImage *)optionLeftBGImage
{
    return [self stretchableImageWithImageName:@"bbs_option_bubble"
                             leftCapWidthScale:0.8
                             topCapHeightScale:0.3
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)optionRightBGImage
{
    return [self stretchableImageWithImageName:@"bbs_option_bubble"
                             leftCapWidthScale:0.2
                             topCapHeightScale:0.3
                             inResourcePackage:RESOURCE_PACKAGE_BBS];

}
- (UIImage *)optionButtonBGImage
{
    return [self stretchableImageWithImageName:@"bbs_option_bg" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBackImage
{
    return [self stretchableImageWithImageName:@"bbs_back" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBGImage
{
    return [_resService imageByName:@"bbs_bg"
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsActionSheetBG
{
    return [self stretchableImageWithImageName:@"bbs_action_sheet_bg"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsRefreshImage
{
    return [self stretchableImageWithImageName:@"bbs_refresh" inResourcePackage:RESOURCE_PACKAGE_BBS];
}

//index image
#pragma mark - Index page image
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

- (UIImage *)bbsBoardMineImage
{
    return [self stretchableImageWithImageName:@"bbs_board_mine"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBoardCommentImage
{
    return [self stretchableImageWithImageName:@"bbs_board_comment"
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


#pragma mark - Post List image

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


//bbs post detail
#pragma mark - Post Detail image
- (UIImage*)bbsDetailComment{
    NSString *imageName = [self fixImageName:@"bbs_detail_comment"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailOptionUp{
    NSString *imageName = [self fixImageName:@"bbs_detail_option_up"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];

}
- (UIImage*)bbsDetailReply{
    NSString *imageName = [self fixImageName:@"bbs_detail_reply"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailSupport{
    NSString *imageName = [self fixImageName:@"bbs_detail_support"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailThumb{
    NSString *imageName = [self fixImageName:@"bbs_detail_thumb"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailOption{
     return [self stretchableImageWithImageName:@"bbs_detail_option"
                              inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailOptionBubble{
     return [self stretchableImageWithImageName:@"bbs_detail_option_bubble"
                              inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailSelectedLine{
     return [self stretchableImageWithImageName:@"bbs_detail_selected_line"
                              inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailSplitLine{
    return [self stretchableImageWithImageName:@"bbs_detail_splitLine"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailToolbar{
    return [self stretchableImageWithImageName:@"bbs_detail_toolbar"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}


#pragma mark - Creation Page image
- (UIImage *)bbsCreateDrawDisable{
    return [self stretchableImageWithImageName:@"bbs_create_draw_disable" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateDrawEnable{
     return [self stretchableImageWithImageName:@"bbs_create_draw_enable" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateImageDisable{
     return [self stretchableImageWithImageName:@"bbs_create_image_disable" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateImageEnable{
     return [self stretchableImageWithImageName:@"bbs_create_image_enable" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateInputBg{
     return [self stretchableImageWithImageName:@"bbs_create_input_bg" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateRewardBg{
    NSString *imageName = [self fixImageName:@"bbs_create_reward_bg"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateRewardOptionBG{
    NSString *imageName = [self fixImageName:@"bbs_create_reward_option"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateSubmitBg{
    NSString *imageName = [self fixImageName:@"bbs_create_submit_bg"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}


- (CGSize)image:(UIImage *)image sizeWithConstHeight:(CGFloat)constHeight
       maxWidth:(CGFloat)maxWidth

{
    if (image) {
        CGSize imageSize = image.size;
        CGFloat h = imageSize.height / constHeight;
        CGFloat width = imageSize.width / h;
        if (width > maxWidth) {
            width = maxWidth;
        }
        return CGSizeMake(width, constHeight);
    }
    return CGSizeZero;
}
@end
