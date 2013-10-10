//
//  BBSColorManager.m
//  Draw
//
//  Created by gamy on 12-11-27.
//
//

#import "BBSColorManager.h"

static BBSColorManager* _staticBBSColorManager;
@implementation BBSColorManager

#define BBS_COLOR_GREEN OPAQUE_COLOR(130, 228, 205)

+ (id)defaultManager
{
    if (_staticBBSColorManager == nil) {
        _staticBBSColorManager = [[BBSColorManager alloc] init];
    }
    return _staticBBSColorManager;
}
- (UIColor *)bbsTitleColor
{
    return COLOR_BROWN;
}
- (UIColor *)badgeColor
{
    return [UIColor whiteColor];
}
- (UIColor *)sectionTitleColor
{
    return COLOR_WHITE;//[UIColor colorWithRed:0xee/255.0 green:0xf6/255.0 blue:0xfd/255.0 alpha:1];
}
- (UIColor *)boardTitleColor
{
    return COLOR_BROWN;//[UIColor colorWithRed:0x2b/255.0 green:0x33/255.0 blue:0x3e/255.0 alpha:1];
}
- (UIColor *)postNumberColor
{
    return COLOR_BROWN;//[UIColor colorWithRed:0x00/255.0 green:0x49/255.0 blue:0x86/255.0 alpha:1];
}
- (UIColor *)normalTextColor
{
    return COLOR_BROWN;//[UIColor colorWithRed:0x44/255.0 green:0x65/255.0 blue:0x87/255.0 alpha:1];
}

#pragma mark - post list color
- (UIColor *)postNickColor{
    return COLOR_BROWN;//[UIColor colorWithRed:0x2c/255.0 green:0x4c/255.0 blue:0x6e/255.0 alpha:1];
}
- (UIColor *)postDateColor{
    return COLOR_GRAY_TEXT;//[UIColor colorWithRed:0x73/255.0 green:0x8d/255.0 blue:0xa8/255.0 alpha:1];
}
- (UIColor *)postRewardColor{
    return COLOR_BROWN;//[UIColor colorWithRed:0xc9/255.0 green:0x75/255.0 blue:0x07/255.0 alpha:1];
}
- (UIColor *)postRewardedColor{
    return COLOR_GRAY_TEXT;//[UIColor colorWithRed:0x70/255.0 green:0x70/255.0 blue:0x70/255.0 alpha:1];
}
- (UIColor *)postActionColor{
    return BBS_COLOR_GREEN;//[UIColor colorWithRed:0x73/255.0 green:0x8d/255.0 blue:0xa8/255.0 alpha:1];
}
- (UIColor *)postAvatarColor{
    return COLOR_WHITE;//[UIColor colorWithRed:0x7c/255.0 green:0xb3/255.0 blue:0xde/255.0 alpha:1];
}

#pragma mark - bbs board admin

- (UIColor *)bbsAdminTitleColor{
    return COLOR_BROWN;//[UIColor colorWithRed:0xce/255.0 green:0xd7/255.0 blue:0xe1/255.0 alpha:1];
}
- (UIColor *)bbsAdminNickColor{
    return COLOR_BROWN;//[UIColor colorWithRed:0x6d/255.0 green:0x98/255.0 blue:0xb8/255.0 alpha:1];
}
- (UIColor *)bbsAdminLineColor{
    return BBS_COLOR_GREEN;//[UIColor colorWithRed:0x54/255.0 green:0x78/255.0 blue:0x9d/255.0 alpha:1];
}
- (UIColor *)bbsTopPostFlagColor{
    return COLOR_ORANGE;//[UIColor colorWithRed:0xe6/255.0 green:0xec/255.0 blue:0xf2/255.0 alpha:1];
}


#pragma mark - post detail color
- (UIColor *)detailDefaultColor{
    return COLOR_GRAY_TEXT;//[UIColor colorWithRed:0x61/255.0 green:0x8d/255.0 blue:0xb4/255.0 alpha:1];
}
- (UIColor *)detailHeaderSelectedColor{
    return COLOR_BROWN;//[UIColor colorWithRed:0xce/255.0 green:0xd7/255.0 blue:0xe1/255.0 alpha:1];
}

#pragma - mark user action
- (UIColor *)userActionSplitColor{
    return BBS_COLOR_GREEN;//[UIColor colorWithRed:0x75/255.0 green:0x8b/255.0 blue:0xa2/255.0 alpha:1];
}

- (UIColor *)userActionSourceColor{
    return COLOR_BROWN;//[UIColor grayColor];
}


#pragma mark - creation color
- (UIColor *)creationDefaultColor{
    return COLOR_WHITE;//[UIColor colorWithRed:0x2c/255.0 green:0x4c/255.0 blue:0x6e/255.0 alpha:1];
}
@end
