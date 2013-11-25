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

#define IMAGE_NAME(x) [UIImage imageNamed:x]

+ (UIImage *)imageForFooterActionType:(GroupFooterActionType)type
{
    switch(type){
        case GroupCreateGroup:
        case GroupCreateTopic:
            return IMAGE_NAME(@"group_footer_create@2x.png");
        case GroupSearchGroup:
            return IMAGE_NAME(@"group_footer_search@2x.png");
        case GroupSearchTopic:
            return IMAGE_NAME(@"group_footer_search@2x.png");
        case GroupChat:
            return IMAGE_NAME(@"group_footer_chat@2x.png");
        case GroupAtMe:
            return IMAGE_NAME(@"group_footer_at@2x.png");
        case GroupContest:
            return IMAGE_NAME(@"group_footer_contest@2x.png");
        default:
            return nil;
    }
}

+ (NSArray *)imagesForFooterActionTypes:(NSArray *)types
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:types.count];
    for (NSNumber *type in types) {
        UIImage *image = [self imageForFooterActionType:type.integerValue];
        [images addObject:image];
    }
    return images;
}

@end
