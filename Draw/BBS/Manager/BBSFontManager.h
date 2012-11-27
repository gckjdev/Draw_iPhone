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

- (UIFont *)indexTabFont;
- (UIFont *)indexTitleFont;
- (UIFont *)indexCountFont;
- (UIFont *)indexBadgeFont;

- (UIFont *)indexLastPostTextFont;
- (UIFont *)indexLastPostNickFont;
- (UIFont *)indexLastPostDateFont;

- (UIFont *)indexBoardNameFont;
- (UIFont *)indexSectionNameFont;


@end
