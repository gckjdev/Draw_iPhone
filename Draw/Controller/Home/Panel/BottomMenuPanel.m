//
//  BottomMenuPanel.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BottomMenuPanel.h"
#import "RegisterUserController.h"
#import "UserSettingController.h"
#import "ChatListController.h"
#import "ShareController.h"
#import "FeedbackController.h"
#import "AccountService.h"
#import "ShareImageManager.h"

@implementation BottomMenuPanel
@synthesize controller = _controller;
@synthesize panelBgImage = _panelBgImage;
@synthesize gameAppType = _gameAppType;

+ (BottomMenuPanel *)panelWithController:(UIViewController<MenuButtonDelegate> *)controller gameAppType:(GameAppType)gameAppType
{
    static NSString *identifier = @"BottomMenuPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BottomMenuPanel *panel = [topLevelObjects objectAtIndex:0];
    panel.gameAppType = gameAppType;
    panel.controller = controller;
    [panel loadMenu];
    return  panel;

}

- (void)dealloc
{
    PPRelease(_controller);
    [_panelBgImage release];
    [super dealloc];
}

#define BOTTOM_MENU_PANEL_WIDTH ([DeviceDetection isIPAD] ? 768 : 320)


- (CGRect)frameForMenuIndex:(NSInteger)index number:(NSInteger)number
{
    BOOL isIPAD = [DeviceDetection isIPAD];
    CGFloat xStart = isIPAD ? 12 : 6;
    CGFloat y = 0;//isIPAD ? 0 : 2;
    CGFloat xSpace = ((BOTTOM_MENU_PANEL_WIDTH - 2 *xStart) - number * BOTTOM_MENU_WIDTH)/ (number - 1);   
    CGFloat x = index *(xSpace + BOTTOM_MENU_WIDTH) + xStart;
    
    return CGRectMake(x, y, BOTTOM_MENU_WIDTH, BOTTOM_MENU_HEIGHT);
}

- (NSInteger)menuNumber
{
    if (_gameAppType == GameAppTypeDraw) {
        return 5;
    }
    return 4;
}

- (void)loadMenu
{
    [self.panelBgImage setImage:[[ShareImageManager defaultManager]
                                 bottomPanelBGForGameAppType:_gameAppType]];
    
    int *list = getBottomMenuTypeListByGameAppType(self.gameAppType);
    int index = 0;
    while (list != NULL && (*list) != MenuButtonTypeEnd) {
        MenuButtonType type = *list;
        BottomMenu *menu = [BottomMenu bottomMenuWithType:type gameAppType:self.gameAppType];
        menu.frame = [self frameForMenuIndex:index number:[self menuNumber]];
        [self addSubview:menu];
        menu.delegate = _controller;
        ++ index;        
        ++ list;
    }
    

}
- (BottomMenu *)getMenuButtonByType:(MenuButtonType)type
{
    for (BottomMenu *view in self.subviews) {
        if ([view isKindOfClass:[BottomMenu class]] && view.type == type) {
            return view;
        }
    }
    return nil;

}
- (void)setMenuBadge:(NSInteger)badge forMenuType:(MenuButtonType)type
{
    [[self getMenuButtonByType:type] setBadgeNumber:badge];
}



@end
