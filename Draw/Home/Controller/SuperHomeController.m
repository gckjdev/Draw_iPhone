//
//  SuperHomeController.m
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import "SuperHomeController.h"
#import "HomeMenuView.h"
#import "CoinShopController.h"
#import "StatisticManager.h"
#import "UserManager.h"
#import "RegisterUserController.h"
#import "UserSettingController.h"
#import "LmWallService.h"
#import "UIUtils.h"
#import "BulletinView.h"
#import "AnalyticsManager.h"
#import "BulletinService.h"
#import "NotificationName.h"
#import "CommonGameNetworkService.h"

@interface SuperHomeController ()
{
    
}

@end


#define MAIN_MENU_ORIGIN_Y ISIPAD ? 365 : 170
#define BOTTOM_MENU_ORIGIN_Y ISIPAD ? (1004-97) : 422

@implementation SuperHomeController

-(void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_homeHeaderPanel);
    PPRelease(_homeMainMenuPanel);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateView:(UIView *)view originY:(CGFloat)y
{
    CGRect frame = view.frame;
    CGPoint origin = frame.origin;
    origin.y = y;
    frame.origin = origin;
    view.frame = frame;
}

- (void)addHeaderView
{
    self.homeHeaderPanel = [HomeHeaderPanel createView:self];
    [self.view addSubview:self.homeHeaderPanel];
    [self updateView:self.homeHeaderPanel originY:0];
}



- (void)addMainMenuView
{
    self.homeMainMenuPanel = [HomeMainMenuPanel createView:self];
    [self.view addSubview:self.homeMainMenuPanel];
//    self.mainMenuPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;

    //TODO update frame
    [self updateView:self.homeMainMenuPanel originY:MAIN_MENU_ORIGIN_Y];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self updateView:self.homeBottomMenuPanel originY:BOTTOM_MENU_ORIGIN_Y];
}

- (void)viewDidLoad
{
    PPDebug(@"SuperHomeController view did load");
    [super viewDidLoad];
    if (!ISIPAD) {
        self.view.frame = CGRectMake(0, 0, 320, 460);
    }
    [self addMainMenuView];
    [self addHeaderView];
    [self addBottomMenuView];
    
    if (!ISIPAD) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];
    
    [self updateAllBadge];//for bulletins
    [self registerNetworkDisconnectedNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeMainMenuPanel animatePageButtons];
    [self.homeHeaderPanel updateView];
    [[BulletinService defaultService] syncBulletins:^(int resultCode) {
        [self updateAllBadge];
    }];
    [[UserService defaultService] getStatistic:self];
    
    [self registerJoinGameResponseNotification];
    [self registerNetworkConnectedNotification];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterJoinGameResponseNotification];
    [self unregisterNetworkConnectedNotification];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.homeHeaderPanel = nil;
    self.homeMainMenuPanel = nil;
    self.homeBottomMenuPanel = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get && update statistic
- (void)handleStaticTimer:(NSTimer *)theTimer
{
    PPDebug(@"<handleStaticTimer>: get static");
    [[UserService defaultService] getStatistic:self];
}

- (void)updateAllBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];
    
    [self.homeBottomMenuPanel updateMenu:HomeMenuTypeDrawMessage badge:manager.messageCount];
    [self.homeBottomMenuPanel updateMenu:HomeMenuTypeDrawFriend badge:manager.fanCount];
    [self.homeMainMenuPanel updateMenu:HomeMenuTypeDrawBBS badge:manager.bbsActionCount];
    
    long timelineCount = manager.feedCount + manager.commentCount + manager.drawToMeCount;
    [self.homeMainMenuPanel updateMenu:HomeMenuTypeDrawTimeline badge:timelineCount];
    
    [self.homeHeaderPanel updateBulletinBadge:[manager bulletinCount]];
    
}
- (void)didSyncStatisticWithResultCode:(int)resultCode
{
    if (resultCode == 0) {        
        [self updateAllBadge];
    }
}

#pragma mark - Panels Delegate

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickChargeButton:(UIButton *)button
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_COINS];
    
    if ([self isRegistered] == NO) {
        [self toRegister];
        return;
    }

    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
 didClickFreeCoinButton:(UIButton *)button
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_FREE_COINS];

    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    [[LmWallService defaultService] show:self];

}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickAvatarButton:(UIButton *)button
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_AVATAR];
    
    if ([self isRegistered] == NO) {
        [self toRegister];
        return;
    }

    UserSettingController *us = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickBulletinButton:(UIButton *)button
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_BULLETIN];
    
    [BulletinView showBulletinInController:self];
}

#pragma mark register

- (BOOL)isRegistered
{
    return [[UserManager defaultManager] hasUser];
}

- (void)toRegister
{
    RegisterUserController *ruc = [[RegisterUserController alloc] init];
    [self.navigationController pushViewController:ruc animated:YES];
    [ruc release];
}

#pragma mark - network listen

- (void)registerJoinGameResponseNotification
{
    [self registerNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE
                            usingBlock:^(NSNotification *note) {
                                [self handleJoinGameResponse];
                            }];
}

- (void)unregisterJoinGameResponseNotification
{
    [self unregisterNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE];
}


- (void)registerNetworkConnectedNotification
{
    [self registerNotificationWithName:NOTIFICATION_NETWORK_CONNECTED
                            usingBlock:^(NSNotification *note) {
                                [self handleConnectedResponse];
                            }];
}

- (void)unregisterNetworkConnectedNotification
{
    [self unregisterNotificationWithName:NOTIFICATION_NETWORK_CONNECTED];
}


- (void)registerNetworkDisconnectedNotification
{
    [self registerNotificationWithName:NOTIFICATION_NETWORK_DISCONNECTED
                            usingBlock:^(NSNotification *note) {
                                [self handleDisconnectWithError:[CommonGameNetworkService userInfoToError:note.userInfo]];
                            }];
}

- (void)unregisterNetworkDisconnectedNotification
{
    [self unregisterNotificationWithName:NOTIFICATION_NETWORK_DISCONNECTED];
}

#pragma mark - should be impletement by subClass

- (void)handleJoinGameResponse
{
    PPDebug(@"<SuperHomeController> handleJoinGameResponse not impletement yet");
}
- (void)handleConnectedResponse
{
    PPDebug(@"<SuperHomeController> handleConnectedResponse not impletement yet");
}
- (void)handleDisconnectWithError:(NSError*)error
{
    PPDebug(@"<SuperHomeController> handleDisconnectWithError not impletement yet");
}

@end
