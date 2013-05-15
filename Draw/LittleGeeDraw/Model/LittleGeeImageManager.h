//
//  LittleGeeImageManager.h
//  Draw
//
//  Created by Kira on 13-5-10.
//
//

#import <Foundation/Foundation.h>

@interface LittleGeeImageManager : NSObject

- (UIImage*)drawToBtnBackgroundImage;
- (UIImage*)draftBtnBackgroundImage;
- (UIImage*)beginBtnBackgroundImage;
- (UIImage*)contestBtnBackgroundImage;

- (UIImage*)popOptionsBackgroundImage;
- (UIImage*)popOptionsBbsImage;
- (UIImage*)popOptionsContestImage;
- (UIImage*)popOptionsGameImage;
- (UIImage*)popOptionsIngotImage;
- (UIImage*)popOptionsMoreImage;
- (UIImage*)popOptionsNoticeImage;
- (UIImage*)popOptionsSearchImage;
- (UIImage*)popOptionsShopImage;
- (UIImage*)popOptionsSelfImage;

+ (LittleGeeImageManager*)defaultManager;

@end
