//
//  DrawMainMenuPanel.m
//  Draw
//
//  Created by Gamy on 13-9-15.
//
//

#import "DrawMainMenuPanel.h"
#import "HomeMenuView.h"
@implementation DrawMainMenuPanel

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    DrawMainMenuPanel *panel = [self createViewWithXibIdentifier:[self getViewIdentifier]];
    panel.delegate = delegate;
    [panel updateView];
    return panel;
}
+ (NSString *)getViewIdentifier
{
    return @"DrawMainMenuPanel";
}

- (void)updateView
{
    
}

- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge
{
    HomeMenuView *menu = [self getMenuViewWithType:type];
    [menu updateBadge:badge];
}
- (void)animatePageButtons
{
    
}
- (HomeMenuView *)getMenuViewWithType:(HomeMenuType)type
{
    
}


@end
