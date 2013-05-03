//
//  SuperHomeController.m
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import "SuperHomeController.h"
#import "HomeMenuView.h"
#import "ChargeController.h"
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
#import "AudioManager.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"
#import "HomeMenuView.h"
#import "DrawImageManager.h"


@interface SuperHomeController ()
{
    
}

@end


#define MAIN_MENU_ORIGIN_Y ISIPAD ? 365 : 170
#define BOTTOM_MENU_ORIGIN_Y ISIPAD ? (1004-97) : 422

@implementation SuperHomeController

-(void)dealloc
{
    PPRelease(_adView);
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
    [self updateView:self.homeMainMenuPanel originY:[self getMainMenuOriginY]];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self updateView:self.homeBottomMenuPanel originY:[self getBottomMenuOriginY]];
}

- (void)adjustView
{
    CGRect mainMenuFrame = self.homeMainMenuPanel.frame;
    mainMenuFrame.size.height = [self getBottomMenuOriginY] - [self getMainMenuOriginY] + 2; //2 for blur height, without this ,a white line will appear
}

- (void)viewDidLoad
{
    PPDebug(@"SuperHomeController view did load");
    [super viewDidLoad];
    

    if (!ISIPAD) {
        self.view.frame = CGRectMake(0, 0, 320, 460);
    }

    if (isLearnDrawApp()) {
        [self addBottomMenuView];
    }else{
        [self addMainMenuView];
        [self addHeaderView];
        [self addBottomMenuView];
        [self adjustView];
        
        [[BulletinService defaultService] syncBulletins:^(int resultCode) {
            [self updateAllBadge];
        }];

        
        [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];
        
        
        [[AudioManager defaultManager] setBackGroundMusicWithName:[GameApp getBackgroundMusicName]];
        [[AudioManager defaultManager] setVolume:[ConfigManager getBGMVolume]];
        if ([[AudioManager defaultManager] isMusicOn]) {
            [[AudioManager defaultManager] backgroundMusicPlay];
        }        
    }
    
    if (!ISIPAD) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
    [self registerNetworkDisconnectedNotification];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeMainMenuPanel animatePageButtons];
    [self.homeHeaderPanel updateView];
    [[UserService defaultService] getStatistic:self];
    
    [self registerJoinGameResponseNotification];
    [self registerNetworkConnectedNotification];
    
    if (self.adView){
        [self.view bringSubviewToFront:self.adView];
    }    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterJoinGameResponseNotification];
    [self unregisterNetworkConnectedNotification];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.adView = nil;
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


- (HomeCommonView *)panelForType:(HomeMenuType)type
{
    if(isMainMenuButton(type)){
        return self.homeMainMenuPanel;
    }
    return self.homeBottomMenuPanel;
}

- (void)updateBadgeWithType:(HomeMenuType)type badge:(NSInteger)badge
{
    HomeCommonView *panel = [self panelForType:type];
    [panel updateMenu:type badge:badge];
}

- (void)updateAllBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];

    [self updateBadgeWithType:HomeMenuTypeDrawMessage badge:manager.messageCount];
    [self updateBadgeWithType:HomeMenuTypeDrawFriend badge:manager.fanCount];
    [self updateBadgeWithType:HomeMenuTypeDrawBBS badge:manager.bbsActionCount];

    long timelineCount = manager.feedCount + manager.commentCount + manager.drawToMeCount;
    
    [self updateBadgeWithType:HomeMenuTypeDrawTimeline badge:timelineCount];
    
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

    ChargeController* controller = [[[ChargeController alloc] init] autorelease];
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

- (float)getMainMenuOriginY
{
    return MAIN_MENU_ORIGIN_Y;
}
- (float)getBottomMenuOriginY
{
    return BOTTOM_MENU_ORIGIN_Y;
}

@end
