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

#pragma mark - Index Page image
- (UIImage *)bbsBadgeImage;
- (UIImage *)bbsBoardBgImage;
- (UIImage *)bbsBoardLastBgImage;
- (UIImage *)bbsBoardLineImage;
- (UIImage *)bbsButtonLeftImage;
- (UIImage *)bbsButtonRightImage;
- (UIImage *)bbsSectionBgImage;
- (UIImage *)bbsSwitchBgImage;
- (UIImage *)bbsSwitchDownImage;
- (UIImage *)bbsSwitchRightImage;

#pragma mark - Common image
- (UIImage *)bbsBackImage;
- (UIImage *)bbsBGImage;
- (UIImage *)optionLeftBGImage;
- (UIImage *)optionRightBGImage;
- (UIImage *)optionButtonBGImage;

#pragma mark - Post List image
- (UIImage *)bbsPostCommentImage;
- (UIImage *)bbsPostContentBGImage;
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
@end
