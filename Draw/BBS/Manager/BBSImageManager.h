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

- (UIImage *)bbsBackImage;
- (UIImage *)bbsBGImage;

//Post List
- (UIImage *)bbsPostCommentImage;
- (UIImage *)bbsPostContentBGImage;
- (UIImage *)bbsPostEditImage;
- (UIImage *)bbsPostHotImage;
- (UIImage *)bbsPostNewImage;
- (UIImage *)bbsPostRewardImage;
- (UIImage *)bbsPostRewardedImage;
- (UIImage *)bbsPostSupportImage;

//post detail
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
