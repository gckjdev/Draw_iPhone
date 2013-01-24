//
//  BBSFontManager.h
//  Draw
//
//  Created by gamy on 12-11-27.
//
//

#import <Foundation/Foundation.h>

@interface BBSFontManager : NSObject

+ (id)defaultManager;
#pragma mark common
- (UIFont *)bbsTitleFont;
- (UIFont *)bbsOptionTitleFont;

#pragma mark index page font
- (UIFont *)indexTabFont;
- (UIFont *)indexCountFont;
- (UIFont *)indexBadgeFont;

- (UIFont *)indexLastPostTextFont;
- (UIFont *)indexLastPostNickFont;
- (UIFont *)indexLastPostDateFont;

- (UIFont *)indexBoardNameFont;
- (UIFont *)indexSectionNameFont;

#pragma markpost list font
- (UIFont *)postNickFont;
- (UIFont *)postContentFont;
- (UIFont *)postDateFont;
- (UIFont *)postRewardFont;
- (UIFont *)postActionFont;
- (UIFont *)postTopFont;

#pragma mark post detail font
- (UIFont *)detailHeaderFont;
- (UIFont *)detailActionFont;
- (UIFont *)actionSourceFont;

#pragma mark creation font
- (UIFont *)creationDefaulFont;
@end
