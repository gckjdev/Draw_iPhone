//
//  MenuPanel.m
//  Draw
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuPanel.h"
#import "MenuButton.h"
#import "RegisterUserController.h"
#import "UserManager.h"
#import "SelectWordController.h"
#import "OfflineGuessDrawController.h"
#import "RoomController.h"
#import "HomeController.h"
#import "FeedController.h"
#import "VendingController.h"
#import "FriendRoomController.h"
#import "DrawGameService.h"
#import "StringUtil.h"
#import "LevelService.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"


//dice
#import "DiceRoomListController.h"

@implementation MenuPanel
@synthesize versionLabel = _versionLabel;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize controller = _controller;
@synthesize gameAppType = _gameAppType;
@synthesize bgImageView = _bgImageView;

+ (MenuPanel *)menuPanelWithController:(UIViewController<MenuButtonDelegate> *)controller gameAppType:(GameAppType)gameAppType
{
    static NSString *identifier = @"MenuPanel";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    MenuPanel *panel = [topLevelObjects objectAtIndex:0];
    panel.controller = controller;
    panel.gameAppType = gameAppType;
    
    panel.scrollView.delegate = panel;
    [panel loadMenu];
    return  panel;
}


#pragma mark load menu

#define MENU_PANEL_WIDTH ([DeviceDetection isIPAD] ? 768 : 320)
#define MENU_PANEL_HEIGHT ([DeviceDetection isIPAD] ? 468 : 226)
static const NSInteger MENU_NUMBER_PER_PAGE = 6;

#define MENU_NUMBER_PER_PAGE ((self.gameAppType == GameAppTypeDraw) ? 6 : 6)
#define MENU_NUMBER_ROW_NUMBER ((self.gameAppType == GameAppTypeDraw) ? 3 : 3)

- (CGRect)frameForMenuIndex:(NSInteger)index
{

    BOOL isIPAD = [DeviceDetection isIPAD];

    CGFloat xStart = isIPAD ? 32 : 15;
    CGFloat yStart = isIPAD ? 30 : 22;

    NSInteger page = index / MENU_NUMBER_PER_PAGE;   
    
    NSInteger row = (index % MENU_NUMBER_PER_PAGE) / MENU_NUMBER_ROW_NUMBER;
    NSInteger numberInRow = index % MENU_NUMBER_ROW_NUMBER;
    
    CGFloat xSpace = ((MENU_PANEL_WIDTH - 2 *xStart) - MENU_NUMBER_ROW_NUMBER * MENU_BUTTON_WIDTH)/ (MENU_NUMBER_ROW_NUMBER - 1);    
    CGFloat ySpace = (MENU_PANEL_HEIGHT - 2 *yStart - 2 * MENU_BUTTON_HEIGHT);
    
    CGFloat y = row * (ySpace + MENU_BUTTON_HEIGHT) + yStart;
    CGFloat x = page * self.frame.size.width;
    x += numberInRow *(xSpace + MENU_BUTTON_WIDTH) + xStart;
    
    return CGRectMake(x, y, MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT);
}


- (void)updateFrameForMenu:(MenuButton *)menu atIndex:(NSInteger)index
{
    CGFloat width = menu.frame.size.width;
    CGFloat height = menu.frame.size.height;
    NSInteger row = (index % MENU_NUMBER_PER_PAGE) / MENU_NUMBER_ROW_NUMBER;
    NSInteger numberInRow = index % MENU_NUMBER_ROW_NUMBER;
    NSInteger page = index / MENU_NUMBER_PER_PAGE;   
    
    CGFloat y = row *  height;
    
    CGFloat x = page * self.frame.size.width;
    x += numberInRow * width;
    menu.frame = CGRectMake(x, y, width, height);

}

- (void)loadMenu
{
    int number = 0;
    UIImage * bgImage = [[ShareImageManager defaultManager]
                         mainMenuPanelBGForGameAppType:self.gameAppType];
    [self.bgImageView setImage:bgImage];
    
    int *list = getMainMenuTypeListByGameAppType(self.gameAppType);
    while (list != NULL && (*list) != MenuButtonTypeEnd) {
        MenuButton *menu = [MenuButton menuButtonWithType:(*list) gameAppType:self.gameAppType];
        [self updateFrameForMenu:menu atIndex:number++];
        [self.scrollView addSubview:menu];
        menu.delegate = self.controller;
        list++;
    }
    [self.scrollView setContentSize:CGSizeMake((number / MENU_NUMBER_PER_PAGE)  * MENU_PANEL_WIDTH, MENU_PANEL_HEIGHT)];
    
    if (self.gameAppType == GameAppTypeDraw) {
        [self.versionLabel setText:[NSString stringWithFormat:@"Ver %@", 
                                    [ConfigManager currentVersion]]];        
    }else{
        [self.versionLabel setHidden:YES];
    }

}

- (MenuButton *)getMenuButtonByType:(MenuButtonType)type
{
    for (MenuButton *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[MenuButton class]] && view.type == type) {
            return view;
        }
    }
    return nil;
}


- (void)setMenuBadge:(NSInteger)badge forMenuType:(MenuButtonType)type
{
    [[self getMenuButtonByType:type] setBadgeNumber:badge];
}


#pragma mark page control
- (IBAction)changePage:(id)sender {
    
}


- (void)dealloc
{
    PPRelease(_versionLabel);
    PPRelease(_scrollView);
    PPRelease(_pageControl);
    PPRelease(_controller);
    [_bgImageView release];
    [super dealloc];
}
@end

