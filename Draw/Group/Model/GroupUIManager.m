//
//  GroupUIManager.m
//  Draw
//
//  Created by Gamy on 13-11-18.
//
//

#import "GroupUIManager.h"
#import "UIImageUtil.h"

@implementation GroupUIManager


#define DETAIL_BOUND_FOR_STYLE(style, redStyleImage, yellowStyleImage)\
if (ColorStyleYellow==style) {\
    return [UIImage strectchableImageName:yellowStyleImage];\
}else{\
    return [UIImage strectchableImageName:redStyleImage];\
}


+ (UIImage *)groupDetailBoundMidImageForStyle:(ColorStyle)style
{
    DETAIL_BOUND_FOR_STYLE(style, @"cell_red_bound_mid@2x.png", @"cell_yellow_bound_mid@2x.png");
}
+ (UIImage *)groupDetailBoundHeaderImageForStyle:(ColorStyle)style
{
    DETAIL_BOUND_FOR_STYLE(style, @"cell_red_bound_header@2x.png", @"cell_yellow_bound_header@2x.png");

}
+ (UIImage *)groupDetailBoundFooterImageForStyle:(ColorStyle)style
{
    DETAIL_BOUND_FOR_STYLE(style, @"cell_red_bound_footer@2x.png", @"cell_yellow_bound_footer@2x.png");
    
}

+ (UIImage *)followedGroupImage
{
    return [UIImage imageNamed:@"group_footer_followed@2x.png"];
}

+ (UIImage *)unfollowingGroupImage
{
    return [UIImage imageNamed:@"group_footer_unfollowing@2x.png"];
}

@end
