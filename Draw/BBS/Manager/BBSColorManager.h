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

//post list color
- (UIColor *)postNickColor;
- (UIColor *)postDateColor;
- (UIColor *)postRewardColor;
- (UIColor *)postActionColor;
- (UIColor *)postAvatarColor;
- (UIColor *)postRewardedColor;
@end
