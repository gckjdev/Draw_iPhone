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



+ (id)defaultManager
{
    if (_staticBBSColorManager == nil) {
        _staticBBSColorManager = [[BBSColorManager alloc] init];
    }
    return _staticBBSColorManager;
}
- (UIColor *)bbsTitleColor
{
    return [UIColor whiteColor];
}
- (UIColor *)badgeColor
{
    return [UIColor whiteColor];
}
- (UIColor *)tabTitleColor
{
    return [UIColor colorWithRed:0x2c/255.0 green:0x4c/255.0 blue:0x6e/255.0 alpha:1];
}
- (UIColor *)sectionTitleColor
{
    return [UIColor colorWithRed:0xee/255.0 green:0xf6/255.0 blue:0xfd/255.0 alpha:1];
}
- (UIColor *)boardTitleColor
{
    return [UIColor colorWithRed:0x2b/255.0 green:0x33/255.0 blue:0x3e/255.0 alpha:1];
}
- (UIColor *)pinkTitleColor
{
    return [UIColor colorWithRed:0xea/255.0 green:0x68/255.0 blue:0xa2/255.0 alpha:1];
}
- (UIColor *)postNumberColor
{
    return [UIColor colorWithRed:0x00/255.0 green:0x49/255.0 blue:0x86/255.0 alpha:1];
}
- (UIColor *)normalTextColor
{
    return [UIColor colorWithRed:0x44/255.0 green:0x65/255.0 blue:0x87/255.0 alpha:1];
}

#pragma mark - post list color
- (UIColor *)postNickColor{
    return [UIColor colorWithRed:0x2c/255.0 green:0x4c/255.0 blue:0x6e/255.0 alpha:1];
}
- (UIColor *)postDateColor{
    return [UIColor colorWithRed:0x73/255.0 green:0x8d/255.0 blue:0xa8/255.0 alpha:1];
}
- (UIColor *)postRewardColor{
    return [UIColor colorWithRed:0xc9/255.0 green:0x75/255.0 blue:0x07/255.0 alpha:1];
}
- (UIColor *)postRewardedColor{
    return [UIColor colorWithRed:0x70/255.0 green:0x70/255.0 blue:0x70/255.0 alpha:1];
}
- (UIColor *)postActionColor{
    return [UIColor colorWithRed:0x73/255.0 green:0x8d/255.0 blue:0xa8/255.0 alpha:1];
}
- (UIColor *)postAvatarColor{
    return [UIColor colorWithRed:0x7c/255.0 green:0xb3/255.0 blue:0xde/255.0 alpha:1];
}

#pragma mark - bbs board admin

- (UIColor *)bbsAdminTitleColor{
    return [UIColor colorWithRed:0xce/255.0 green:0xd7/255.0 blue:0xe1/255.0 alpha:1];
}
- (UIColor *)bbsAdminNickColor{
    return [UIColor colorWithRed:0x6d/255.0 green:0x98/255.0 blue:0xb8/255.0 alpha:1];
}
- (UIColor *)bbsAdminLineColor{
    return [UIColor colorWithRed:0x54/255.0 green:0x78/255.0 blue:0x9d/255.0 alpha:1];
}
- (UIColor *)bbsTopPostFlagColor{
    return [UIColor colorWithRed:0xe6/255.0 green:0xec/255.0 blue:0xf2/255.0 alpha:1];
}


#pragma mark - post detail color
- (UIColor *)detailDefaultColor{
    return [UIColor colorWithRed:0x61/255.0 green:0x8d/255.0 blue:0xb4/255.0 alpha:1];
}
- (UIColor *)detailHeaderSelectedColor{
    return [UIColor colorWithRed:0xce/255.0 green:0xd7/255.0 blue:0xe1/255.0 alpha:1];
}

#pragma - mark user action
- (UIColor *)userActionSplitColor{
    return [UIColor colorWithRed:0x75/255.0 green:0x8b/255.0 blue:0xa2/255.0 alpha:1];
}

- (UIColor *)userActionSourceColor{
    return [UIColor grayColor];
}


#pragma mark - creation color
- (UIColor *)creationDefaultColor{
    return [UIColor colorWithRed:0x2c/255.0 green:0x4c/255.0 blue:0x6e/255.0 alpha:1];
}
@end
