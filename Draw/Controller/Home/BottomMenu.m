//
//  BottomMenu.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BottomMenu.h"
#import "ShareImageManager.h"

@implementation BottomMenu


+ (BottomMenu *)bottomMenuWithImage:(UIImage *)image 
                              title:(NSString *)title
                              badge:(NSInteger)badge
{
    
    static NSString *identifier = @"BottomMenu";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BottomMenu *menuButton = [topLevelObjects objectAtIndex:0];
    [menuButton updateImage:image tilte:title badge:badge];
    return  menuButton;
    
}



+ (NSString *)titleForMenuButtonType:(MenuButtonType)type
{
    
    switch (type) {
            
        case MenuButtonTypeSettings:
            return NSLS(@"kSettings");
        case MenuButtonTypeOpus:
            return NSLS(@"kHomeShare");
        case MenuButtonTypeFriend:
            return NSLS(@"kFriend");
        case MenuButtonTypeChat:
            return NSLS(@"kChat");
        case MenuButtonTypeFeedback:
            return NSLS(@"kFeedback");
        case MenuButtonTypeCheckIn:
            return NSLS(@"kCheckin");            
        default:
            return nil;
    }
    
}

            
+ (UIImage *)imageForMenuButtonType:(MenuButtonType)type
{
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    switch (type) {
        case MenuButtonTypeSettings:
            return [imageManager settingsMenuImage];
        case MenuButtonTypeOpus:
            return [imageManager opusMenuImage];
        case MenuButtonTypeFriend:
            return [imageManager friendMenuImage];
        case MenuButtonTypeChat:
            return [imageManager chatMenuImage];
        case MenuButtonTypeFeedback:
            return [imageManager feedbackMenuImage];
        case MenuButtonTypeCheckIn:
            return [imageManager checkInMenuImage];
        default:
            return nil;
    }
    
}

+ (BottomMenu *)bottomMenuWithType:(MenuButtonType)type
{
    UIImage *image = [BottomMenu imageForMenuButtonType:type];
    NSString *title = nil;//[BottomMenu titleForMenuButtonType:type];
    
    BottomMenu *menu = [BottomMenu bottomMenuWithImage:image 
                                                 title:title 
                                                 badge:0];
    [menu setType:type];
    menu.button.tag = type;
    [menu.button addTarget:menu action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    return menu;
}


- (void)dealloc
{
    [super dealloc];
}

@end
