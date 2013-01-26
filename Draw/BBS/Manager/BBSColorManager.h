//
//  BBSColorManager.h
//  Draw
//
//  Created by gamy on 12-11-27.
//
//

#import <Foundation/Foundation.h>

@interface BBSColorManager : NSObject

+ (id)defaultManager;
- (UIColor *)bbsTitleColor;
- (UIColor *)badgeColor;
- (UIColor *)tabTitleColor;
- (UIColor *)sectionTitleColor;
- (UIColor *)boardTitleColor;
- (UIColor *)pinkTitleColor;
- (UIColor *)postNumberColor;
- (UIColor *)normalTextColor;

#pragma mark - post list color
- (UIColor *)postNickColor;
- (UIColor *)postDateColor;
- (UIColor *)postRewardColor;
- (UIColor *)postActionColor;
- (UIColor *)postAvatarColor;
- (UIColor *)postRewardedColor;

#pragma mark - post detail color
- (UIColor *)detailDefaultColor;
- (UIColor *)detailHeaderSelectedColor;

#pragma mark - bbs board admin
- (UIColor *)bbsAdminTitleColor;
- (UIColor *)bbsAdminNickColor;
- (UIColor *)bbsAdminLineColor;
- (UIColor *)bbsTopPostFlagColor;

#pragma mark - bbs user action
- (UIColor *)userActionSplitColor;//758ba2
- (UIColor *)userActionSourceColor;

#pragma mark - creation color
- (UIColor *)creationDefaultColor;
@end
