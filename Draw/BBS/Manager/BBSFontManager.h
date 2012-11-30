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
//common
- (UIFont *)bbsTitleFont;

//index page font
- (UIFont *)indexTabFont;
- (UIFont *)indexCountFont;
- (UIFont *)indexBadgeFont;

- (UIFont *)indexLastPostTextFont;
- (UIFont *)indexLastPostNickFont;
- (UIFont *)indexLastPostDateFont;

- (UIFont *)indexBoardNameFont;
- (UIFont *)indexSectionNameFont;

//post list font
- (UIFont *)postNickFont;
- (UIFont *)postContentFont;
- (UIFont *)postDateFont;
- (UIFont *)postRewardFont;
- (UIFont *)postActionFont;

//post detail font
- (UIFont *)detailHeaderFont;
- (UIFont *)detailActionFont;
- (UIFont *)detailRewardActionFont;

@end
