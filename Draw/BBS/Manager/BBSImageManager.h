//
//  BBSImageManager.h
//  Draw
//
//  Created by gamy on 12-11-27.
//
//

#import <Foundation/Foundation.h>

@interface BBSImageManager : NSObject
{
    
}

+ (id)defaultManager;

#pragma mark - Common image
- (UIImage *)bbsBackImage;
- (UIImage *)bbsBGImage;
- (UIImage *)optionLeftBGImage;
- (UIImage *)optionRightBGImage;
- (UIImage *)optionButtonBGImage;
- (UIImage *)bbsActionSheetBG;
- (UIImage *)bbsRefreshImage;

#pragma mark - Index Page image
- (UIImage *)bbsBadgeImage;
- (UIImage *)bbsBoardBgImage;
- (UIImage *)bbsBoardLastBgImage;
- (UIImage *)bbsBoardLineImage;

- (UIImage *)bbsBoardMineImage;
- (UIImage *)bbsBoardCommentImage;

- (UIImage *)bbsButtonLeftImage;
- (UIImage *)bbsButtonRightImage;
- (UIImage *)bbsSectionBgImage;
- (UIImage *)bbsSwitchBgImage;
- (UIImage *)bbsSwitchDownImage;
- (UIImage *)bbsSwitchRightImage;


#pragma mark - Post List image
- (UIImage *)bbsPostCommentImage;
- (UIImage *)bbsPostContentBGImage;
- (UIImage *)bbsRewardActionBGImage;
- (UIImage *)bbsPostEditImage;
- (UIImage *)bbsPostHotImage;
- (UIImage *)bbsPostNewImage;
- (UIImage *)bbsPostRewardImage;
- (UIImage *)bbsPostRewardedImage;
- (UIImage *)bbsPostSupportImage;

#pragma mark - Post detail image
- (UIImage*)bbsDetailComment;
- (UIImage*)bbsDetailOptionUp;
- (UIImage*)bbsDetailReply;
- (UIImage*)bbsDetailSupport;
- (UIImage*)bbsDetailThumb;

- (UIImage*)bbsDetailOption;
- (UIImage*)bbsDetailOptionBubble;
- (UIImage*)bbsDetailSelectedLine;
- (UIImage*)bbsDetailSplitLine;
- (UIImage*)bbsDetailToolbar;

- (UIImage *)bbsPostDetailComment;
- (UIImage *)bbsPostDetailDelete;
- (UIImage *)bbsPostDetailSupport;
- (UIImage *)bbsPostDetailToTop;
- (UIImage *)bbsPostDetailTransfer;
- (UIImage *)bbsPostTopBg;

#pragma mark -Creation page image

- (UIImage *)bbsCreateDrawDisable;
- (UIImage *)bbsCreateDrawEnable;
- (UIImage *)bbsCreateImageDisable;
- (UIImage *)bbsCreateImageEnable;
- (UIImage *)bbsCreateInputBg;
- (UIImage *)bbsCreateRewardBg;
- (UIImage *)bbsCreateRewardOptionBG;
- (UIImage *)bbsCreateSubmitBg;

//#pragma mark - User Action actionSheet

- (CGSize)image:(UIImage *)image sizeWithConstHeight:(CGFloat)height maxWidth:(CGFloat)maxWidth;

@end
