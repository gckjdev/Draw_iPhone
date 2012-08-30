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

+ (MenuPanel *)menuPanelWithController:(UIViewController *)controller
                           gameAppType:(GameAppType)gameAppType
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
#define MENU_PANEL_HEIGHT ([DeviceDetection isIPAD] ? 467 : 224)
static const NSInteger MENU_NUMBER_PER_PAGE = 6;

#define MENU_NUMBER_PER_PAGE ((self.gameAppType == GameAppTypeDraw) ? 6 : 4)
#define MENU_NUMBER_ROW_NUMBER ((self.gameAppType == GameAppTypeDraw) ? 3 : 2)

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
//        [menu setBadgeNumber:number];
        menu.delegate = self;
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
        case MenuButtonTypeOnlinePlay:
        {
            
            UserManager *_userManager = [UserManager defaultManager];
            [_controller showActivityWithText:NSLS(@"kJoiningGame")];
            NSString* userId = [_userManager userId];
            NSString* nickName = [_userManager nickName];
            
            if (userId == nil){
                userId = [NSString GetUUID];
            }
            
            if (nickName == nil){
                nickName = NSLS(@"guest");
            }
            
            if ([[DrawGameService defaultService] isConnected]){        
                [[DrawGameService defaultService] joinGame:userId
                                                  nickName:nickName
                                                    avatar:[_userManager avatarURL]
                                                    gender:[_userManager isUserMale]
                                                  location:[_userManager location]  
                                                 userLevel:[[LevelService defaultService] level]
                                            guessDiffLevel:[ConfigManager guessDifficultLevel]
                                               snsUserData:[_userManager snsUserData]];    
            }
            else{
                
                [_controller showActivityWithText:NSLS(@"kConnectingServer")];        
                [[RouterService defaultService] tryFetchServerList:_controller];        
            }

        }
            
            break;
        case MenuButtonTypeOfflineDraw:
        {
            SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
            [_controller.navigationController pushViewController:sc animated:YES];
            [sc release];
        }
            break;
        case MenuButtonTypeOfflineGuess:
        {
            [_controller showActivityWithText:NSLS(@"kLoading")];
            [[DrawDataService defaultService] matchDraw:_controller];
        }
            break;
        case MenuButtonTypeFriendPlay:
        {
            FriendRoomController *frc = [[FriendRoomController alloc] init];
            [_controller.navigationController pushViewController:frc animated:YES];
            [frc release];
            [self setMenuBadge:0 forMenuType:type];
        }
            break;
        case MenuButtonTypeTimeline:
        {
            FeedController *fc = [[FeedController alloc] init];
            [_controller.navigationController pushViewController:fc animated:YES];
            [fc release];
            [self setMenuBadge:0 forMenuType:type];
        }
            break;
        case MenuButtonTypeShop:
        {
            VendingController* vc = [[VendingController alloc] init];
            [_controller.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
            break;

            
        case MenuButtonTypeDiceShop:
        {
            VendingController* vc = [[VendingController alloc] init];
            [_controller.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
            break;
        case MenuButtonTypeDiceStart:
        {
            if ([_controller respondsToSelector:@selector(connectServer)]){
                [_controller performSelector:@selector(connectServer)];
            }
        }
            break;
        case MenuButtonTypeDiceRoom:
        {
            DiceRoomListController* vc = [[[DiceRoomListController alloc] init] autorelease];
            [_controller.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MenuButtonTypeDiceHelp:
        {
            DiceHelpView *view = [DiceHelpView createDiceHelpView];
            [view showInView:_controller.view];
        }
            break;

            
        default:
            break;
    }
}
/*
#pragma mark scrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
        PPDebug(@"<BoardPanel>scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PPDebug(@"scrollViewDidEndDecelerating, page = %d", self.pageControl.currentPage);    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    PPDebug(@"<BoardPanel>scrollViewDidEndScrollingAnimation");
}
*/

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

