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
#import "UIImageUtil.h"

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

//Common image

#pragma mark - Common image

- (UIImage *)optionLeftBGImage
{
    
    
    return [_resService stretchableImageWithImageName:@"bbs_option_bubble"
                             leftCapWidthScale:0.8
                             topCapHeightScale:0.3
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)optionRightBGImage
{
    return [_resService stretchableImageWithImageName:@"bbs_option_bubble"
                             leftCapWidthScale:0.2
                             topCapHeightScale:0.3
                             inResourcePackage:RESOURCE_PACKAGE_BBS];

}
- (UIImage *)optionButtonBGImage
{
    return [_resService stretchableImageWithImageName:@"bbs_option_bg" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBackImage
{
    return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_back"];

    
//    return [_resService stretchableImageWithImageName:@"bbs_back" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsBGImage
{
    return [[ShareImageManager defaultManager] drawBGImage];
//    return [_resService imageByName:@"bbs_bg"
//                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsActionSheetBG
{
    return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_action_sheet_bg"];

//    return [_resService stretchableImageWithImageName:@"bbs_action_sheet_bg"
//                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsRefreshImage
{
    return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_refresh"];

    
//    return [_resService stretchableImageWithImageName:@"bbs_refresh" inResourcePackage:RESOURCE_PACKAGE_BBS];
}

//index image
#pragma mark - Index page image
- (UIImage *)bbsBadgeImage
{
    return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_badge"];

    
//     return [_resService stretchableImageWithImageName:@"bbs_badge"
//                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
#define BBS_BOARD_BORDER (ISIPAD?4:2)
#define BBS_BOARD_RADIUS (ISIPAD?15:8)

#define BOARD_BOUND_COLOR OPAQUE_COLOR(249, 116, 104)

- (UIImage *)bbsBoardBgImage
{
    return [ShareImageManager boundImageWithType:BoundImageTypeVertical
                                          border:BBS_BOARD_BORDER
                                    cornerRadius:BBS_BOARD_RADIUS
                                      boundColor:BOARD_BOUND_COLOR
                                       fillColor:[UIColor whiteColor]];
}
- (UIImage *)bbsBoardLastBgImage
{
    return [ShareImageManager boundImageWithType:BoundImageTypeBottom
                                          border:BBS_BOARD_BORDER
                                    cornerRadius:BBS_BOARD_RADIUS
                                      boundColor:BOARD_BOUND_COLOR
                                       fillColor:[UIColor whiteColor]];
}
- (UIImage *)bbsBoardLineImage
{
    return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_board_line"];

    
//     return [_resService stretchableImageWithImageName:@"bbs_board_line"
//                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsBoardMineImage
{
            return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_board_mine"];
    
//    return [_resService stretchableImageWithImageName:@"bbs_board_mine"
//                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsBoardSearchImage
{
        return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_board_search"];
    
//    return [_resService stretchableImageWithImageName:@"bbs_board_search"
//                                    inResourcePackage:RESOURCE_PACKAGE_BBS];
}


- (UIImage *)bbsBoardCommentImage
{
    return [[ShareImageManager defaultManager] fixedImageNamed:@"bbs_board_comment"];
    
//    return [_resService stretchableImageWithImageName:@"bbs_board_comment"
//                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsSectionBgImage
{
     return [_resService stretchableImageWithImageName:@"bbs_section_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchBgImage
{
     return [_resService stretchableImageWithImageName:@"bbs_switch_bg"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchDownImage
{
     return [_resService stretchableImageWithImageName:@"bbs_switch_down"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsSwitchRightImage
{
    return [_resService stretchableImageWithImageName:@"bbs_switch_right"
                   inResourcePackage:RESOURCE_PACKAGE_BBS];
}


#pragma mark - Post List image

//Post list
- (UIImage *)bbsPostContentBGImage{
    return [_resService stretchableImageWithImageName:@"bbs_post_content_bg"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];

}

- (UIImage *)bbsRewardActionBGImage{
    return [_resService stretchableImageWithImageName:@"bbs_reward_action_content_bg"
                                    inResourcePackage:RESOURCE_PACKAGE_BBS];
    
}


- (UIImage *)bbsPostEditImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_edit"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostHotImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_hot"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostNewImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_new"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostMarkImage
{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_mark"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostRewardImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_reward"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostRewardedImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_rewarded"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostSupportImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_support"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsPostCommentImage{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_comment"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_DRAW];
    
}


//bbs post detail
#pragma mark - Post Detail image
- (UIImage*)bbsDetailOptionUp{
    NSString *imageName = [UIImage fixImageName:@"bbs_detail_option_up"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];

}
- (UIImage*)bbsDetailReply{
    NSString *imageName = [UIImage fixImageName:@"bbs_detail_reply"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailSupport{
    NSString *imageName = [UIImage fixImageName:@"bbs_detail_support"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage*)bbsDetailOption{
     return [_resService stretchableImageWithImageName:@"bbs_detail_option"
                              inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailOptionBubble{
     return [_resService stretchableImageWithImageName:@"bbs_detail_option_bubble"
                              inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailSelectedLine{
     return [_resService stretchableImageWithImageName:@"bbs_detail_selected_line"
                              inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailSplitLine{
    return [_resService stretchableImageWithImageName:@"bbs_detail_splitLine"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage*)bbsDetailToolbar{
    return [_resService stretchableImageWithImageName:@"bbs_detail_toolbar"
                             inResourcePackage:RESOURCE_PACKAGE_BBS];
}


- (UIImage *)bbsPostDetailComment{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_comment"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostDetailDelete{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_delete"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostDetailSupport{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_support"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostDetailToTop{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_totop"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostDetailUnTop{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_untop"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostDetailFavor
{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_favor"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
    
}
- (UIImage *)bbsPostDetailUnfavor
{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_unfavor"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];    
}

- (UIImage *)bbsPostDetailMark
{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_mark"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
    
}
- (UIImage *)bbsPostDetailUnmark
{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_unmark"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
    
}


- (UIImage *)bbsPostDetailTransfer{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_detail_transfer"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

- (UIImage *)bbsPostTopBg{
    NSString *imageName = [UIImage fixImageName:@"bbs_post_top_bg"];
    return [_resService imageByName:imageName inResourcePackage:RESOURCE_PACKAGE_BBS];
}

#pragma mark - Creation Page image
- (UIImage *)bbsCreateDrawEnable{
     return [_resService stretchableImageWithImageName:@"bbs_create_draw_enable" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateImageEnable{
     return [_resService stretchableImageWithImageName:@"bbs_create_image_enable" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateInputBg{
     return [_resService stretchableImageWithImageName:@"bbs_create_input_bg" inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateRewardBg{
    NSString *imageName = [UIImage fixImageName:@"bbs_create_reward_bg"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateRewardOptionBG{
    NSString *imageName = [UIImage fixImageName:@"bbs_create_reward_option"];
    return [_resService imageByName:imageName
                  inResourcePackage:RESOURCE_PACKAGE_BBS];
}
- (UIImage *)bbsCreateSubmitBg{
    NSString *imageName = [UIImage fixImageName:@"bbs_create_submit_bg"];
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
