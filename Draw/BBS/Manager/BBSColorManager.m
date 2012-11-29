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

//post list color
- (UIColor *)postNickColor{
    return [UIColor colorWithRed:0x2c/255.0 green:0x4c/255.0 blue:0x6e/255.0 alpha:1];
}
- (UIColor *)postDateColor{
    return [UIColor colorWithRed:0x73/255.0 green:0x8d/255.0 blue:0xa8/255.0 alpha:1];
}
- (UIColor *)postRewardColor{
    return [UIColor colorWithRed:0xc9/255.0 green:0x75/255.0 blue:0x07/255.0 alpha:1];
}
- (UIColor *)postActionColor{
    return [UIColor colorWithRed:0x73/255.0 green:0x8d/255.0 blue:0xa8/255.0 alpha:1];
}
- (UIColor *)postAvatarColor{
    return [UIColor colorWithRed:0x7c/255.0 green:0xb3/255.0 blue:0xde/255.0 alpha:1];
}
@end
