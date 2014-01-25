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


+ (UIColor *)colorForStyle:(ColorStyle)style
{
    if (ColorStyleYellow == style) {
        return COLOR_YELLOW;
    }
    return COLOR_RED;
}

#define BORDER (ISIPAD?4:2)
#define CORNER_RADIUS (ISIPAD?15:8)

+ (UIImage *)groupDetailBoundMidImageForStyle:(ColorStyle)style
{
    return [ShareImageManager
            boundImageWithType:BoundImageTypeVertical
            border:BORDER
            cornerRadius:CORNER_RADIUS 
            boundColor:[self colorForStyle:style]
            fillColor:[UIColor whiteColor]];
}
+ (UIImage *)groupDetailBoundHeaderImageForStyle:(ColorStyle)style
{
    return [ShareImageManager
            boundImageWithType:BoundImageTypeTop
            border:BORDER
            cornerRadius:CORNER_RADIUS
            boundColor:[self colorForStyle:style]
            fillColor:[UIColor whiteColor]];
}
+ (UIImage *)groupDetailBoundFooterImageForStyle:(ColorStyle)style
{
    return [ShareImageManager
            boundImageWithType:BoundImageTypeBottom
            border:BORDER
            cornerRadius:CORNER_RADIUS
            boundColor:[self colorForStyle:style]
            fillColor:[UIColor whiteColor]];
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
            return IMAGE_NAME(@"group_footer_create@2x.png");
        case GroupCreateTopic:
            return IMAGE_NAME(@"group_footer_edit@2x.png");
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
        //TODO to be replaced.
        case GroupTimeline:
            return IMAGE_NAME(@"group_footer_timeline@2x.png");

        default:
            return nil;
    }
}

+ (NSArray *)imagesForFooterActionTypes:(NSArray *)types
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:types.count];
    for (NSNumber *type in types) {
        UIImage *image = [self imageForFooterActionType:type.integerValue];
        if(image){
            [images addObject:image];
        }
    }
    return images;
}

+ (UIImage *)addButtonImage
{
    return [UIImage imageNamed:@"group_add@2x.png"];
}

+ (UIImage *)defaultGroupMedal
{
    return [UIImage imageNamed:@"default_group_medal@2x.png"];
}

@end
