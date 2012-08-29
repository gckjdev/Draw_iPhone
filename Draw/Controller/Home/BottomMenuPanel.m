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
#import "MyFriendsController.h"
#import "ChatListController.h"
#import "ShareController.h"
#import "FeedbackController.h"
#import "AccountService.h"
#import "ShareImageManager.h"

@implementation BottomMenuPanel
@synthesize controller = _controller;
@synthesize panelBgImage = _panelBgImage;
@synthesize gameAppType = _gameAppType;

+ (BottomMenuPanel *)panelWithController:(UIViewController *)controller 
                             gameAppType:(GameAppType)gameAppType
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
    int index = 0;
    for (int i = BottomMenuTypeBase; i < BottomMenuTypeEnd; ++ i) {
        BottomMenu *menu = [BottomMenu bottomMenuWithType:i gameAppType:_gameAppType];
        
        if (_gameAppType != GameAppTypeDraw && i == MenuButtonTypeOpus) {
            continue;
        }
        [menu setBadgeNumber:index];
        menu.frame = [self frameForMenuIndex:index number:[self menuNumber]];
        [self addSubview:menu];
        menu.delegate = self;
        ++ index;
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


#pragma mark handle the register

- (BOOL)isRegistered
{
    return [[UserManager defaultManager] hasUser];
}

- (void)toRegister
{
    RegisterUserController *ruc = [[RegisterUserController alloc] init];
    [_controller.navigationController pushViewController:ruc animated:YES];
    [ruc release];
}


#pragma menu button delegate

- (void)didClickMenuButton:(MenuButton *)menuButton
{
    PPDebug(@"menu button type = %d", menuButton.type);
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    
    MenuButtonType type = menuButton.type;
    switch (type) {
        case MenuButtonTypeSettings:
        {
            UserSettingController *settings = [[UserSettingController alloc] init];
            [_controller.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            
            break;
        case MenuButtonTypeOpus:
        {   
            ShareController* share = [[ShareController alloc] init ];
            [_controller.navigationController pushViewController:share animated:YES];
            [share release];

        }
            break;
        case MenuButtonTypeFriend:
        {
            MyFriendsController *mfc = [[MyFriendsController alloc] init];
            [_controller.navigationController pushViewController:mfc animated:YES];
            [mfc release];
            [self setMenuBadge:0 forMenuType:MenuButtonTypeFriend];
        }
            break;
        case MenuButtonTypeChat:
        {
            ChatListController *controller = [[ChatListController alloc] init];
            [_controller.navigationController pushViewController:controller animated:YES];
            [controller release];
            
            [self setMenuBadge:0 forMenuType:type];

        }
            break;
        case MenuButtonTypeFeedback:
        {
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [_controller.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];

        }
            break;
        case MenuButtonTypeCheckIn:
        {
//            int coins = [[AccountService defaultService] checkIn];
//            NSString* message = nil;
//            if (coins > 0){        
//                message = [NSString stringWithFormat:NSLS(@"kCheckInMessage"), coins];
//            }
//            else{
//                message = NSLS(@"kCheckInAlreadyToday");
//            }
//            CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCheckInTitle") 
//                                                               message:message
//                                                                 style:CommonDialogStyleSingleButton 
//                                                              delegate:_controller];    
//            
//            [dialog showInView:_controller.view];

        }
            break;
        default:
            break;
    }
}


@end
