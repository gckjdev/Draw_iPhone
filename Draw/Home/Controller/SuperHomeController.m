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
#import "DrawHomeHeaderPanel.h"
#import "DrawMainMenuPanel.h"
#import "MyFeedController.h"
#import "StoreController.h"
#import "BBSBoardController.h"
#import "FeedbackController.h"
#import "HotController.h"
#import "ChatListController.h"
#import "FriendController.h"
#import "TaskController.h"
#import "DrawImageManager.h"
#import "ContestController.h"
#import "PainterController.h"
#import "GroupHomeController.h"
#import "FreeIngotController.h"
#import "ShowOpusClassListController.h"
#import "UserTutorialMainController.h"
#import "FeedListController.h"
#import "NewHotController.h"
#import "MetroHomeController.h"


static NSDictionary* DEFAULT_MENU_TITLE_DICT = nil;
static NSDictionary* DEFAULT_MENU_IMAGE_DICT = nil;

@interface SuperHomeController ()
{
    
}

@end


#define MAIN_MENU_ORIGIN_Y (ISIPAD ? 200 : 100+(ISIPHONE5?10:0))
#define BOTTOM_MENU_ORIGIN_Y (CGRectGetHeight([[UIScreen mainScreen] bounds]) - 20 - (ISIPAD ? 76 : 38))

@implementation SuperHomeController

-(void)dealloc
{
    PPRelease(_adView);
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_homeHeaderPanel);
    PPRelease(_homeMainMenuPanel);
    
    [self stopStatisticTimer];
    PPRelease(_statisTimer);
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
    self.homeHeaderPanel = [DrawHomeHeaderPanel createView:self];
    [self.view addSubview:self.homeHeaderPanel];
    [self updateView:self.homeHeaderPanel originY:0];
}



- (void)addMainMenuView
{
    self.homeMainMenuPanel = ([DrawMainMenuPanel createView:self]);
    [self.view addSubview:self.homeMainMenuPanel];

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
//    [self.homeBottomMenuPanel updateHeight:[self getBottomMenuOriginY]+1];
}

- (void)viewDidLoad
{
    PPDebug(@"SuperHomeController view did load");
    [super viewDidLoad];
    
    if (!ISIPAD) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }    

    [self addMainMenuView];
    [self addHeaderView];
    [self addBottomMenuView];
    [self adjustView];
    
    [[BulletinService defaultService] syncBulletins:^(int resultCode) {
        [self updateAllBadge];
    }];
    
    // update avatar view
    [self registerNotificationWithName:NOTIFCATION_USER_DATA_CHANGE usingBlock:^(NSNotification *note) {
        PPDebug(@"recv NOTIFCATION_USER_DATA_CHANGE, update header view panel");
        [self.homeMainMenuPanel updateView];
        [self updateAllBadge];
    }];
    
    // update background view
    [self registerNotificationWithName:UPDATE_HOME_BG_NOTIFICATION_KEY usingBlock:^(NSNotification *note) {
        [self updateBGImageView];
        [self.homeMainMenuPanel updateView];
    }];
    [self updateBGImageView];

    
    [[AudioManager defaultManager] setBackGroundMusicWithName:[GameApp getBackgroundMusicName]];
    [[AudioManager defaultManager] setVolume:[PPConfigManager getBGMVolume]];
    if ([[AudioManager defaultManager] isMusicOn]) {
        [[AudioManager defaultManager] backgroundMusicPlay];
    }        
    
    [self registerNetworkDisconnectedNotification];
    
    // manage rope animation
    [self updateAnimation];
}

- (void)startStatisticTimer
{
    if (self.statisTimer == nil){
        PPDebug(@"<startStatisticTimer>");
        self.statisTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];
    }
}

- (void)stopStatisticTimer
{
    if (self.statisTimer){
        PPDebug(@"<stopStatisticTimer>");
        if ([self.statisTimer isValid]){
            [self.statisTimer invalidate];
        }
        self.statisTimer = nil;
    }
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
    
    [self startStatisticTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopStatisticTimer];
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
    [self updateBadgeWithType:HomeMenuTypeTask badge:manager.taskCount];
    [self updateBadgeWithType:HomeMenuTypeBottomTask badge:manager.taskCount];
    [self updateBadgeWithType:HomeMenuTypeDrawGuess badge:manager.guessContestNotif];
    
    [self updateBadgeWithType:HomeMenuTypeDrawFreeCoins badge:[[CheckInManager defaultManager] isCheckInToday] ? 0:1];
    
    long timelineCount = manager.timelineOpusCount + manager.timelineGuessCount + manager.commentCount + manager.drawToMeCount;
    
    [self updateBadgeWithType:HomeMenuTypeDrawTimeline badge:timelineCount];
    [self updateBadgeWithType:HomeMenuTypeDrawContest badge:[manager newContestCount]];
    [self updateBadgeWithType:HomeMenuTypeGroup badge:[manager groupNoticeCount]];
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

    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励！"];
    [[LmWallService defaultService] show:self];

}

//- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
//   didClickAvatarButton:(UIButton *)button
//{
//    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_AVATAR];
//}



- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickBulletinButton:(UIButton *)button
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_BULLETIN];
    
    BulletinView *v = [BulletinView createWithSuperController:self];
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kBulletin") customView:v style:CommonDialogStyleCross];
    [dialog showInView:self.view];
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
    return MAIN_MENU_ORIGIN_Y + STATUSBAR_DELTA;
}
- (float)getBottomMenuOriginY
{
    return BOTTOM_MENU_ORIGIN_Y+2 + STATUSBAR_DELTA;
}

#pragma mark - Click User Avatar, User Login and Enter Detail 

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
       didClickAvatarView:(AvatarView *)avatarView
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_AVATAR];
    [self enterUserDetail];
}



/*
 1）点击【签到】，根据连续N天签到，显示当天获得的金币，以及下一天可以获得的签到金币
 
 2）如果当天已经签到，则告知已经签到了，询问是否要进入免费金币获取免费金币
 
 3）如果未签到，启动时候显示一个数字【1】
 
 */

- (void)askCheckIn
{
    
    if ([[CheckInManager defaultManager] isContinousCheckIn] == NO){
        [[CheckInManager defaultManager] clearAllCheckInBefore];
    }
    
    int awardToday = [[CheckInManager defaultManager] getTodayCheckInAward];
    [[CheckInManager defaultManager] checkIn];
    [self updateAllBadge];
    [[AccountService defaultService] chargeCoin:awardToday source:CheckInType];

    int days = [[CheckInManager defaultManager] continuousCheckInDays];
    int awardTomorrow = [[CheckInManager defaultManager] getTomorrowCheckInAward];

    NSString* msg = [NSString stringWithFormat:NSLS(@"kCheckInSucc"), awardToday, days, awardTomorrow];
    POSTMSG2(msg, 3.5);
}

- (void)askEnterFreeCoin
{
    if ([PPConfigManager wallEnabled] && [PPConfigManager isInReviewVersion] == NO){
        POSTMSG2(NSLS(@"kAlreadyCheckInWithFreeCoin"), 3.5);
        [self enterFreeCoins];
    }
    else{
        POSTMSG2(NSLS(@"kAlreadyCheckIn"), 3.5);
    }
}

- (void)enterCheckIn
{
//    [[CheckInManager defaultManager] clearAllCheckInBefore];
    
    if ([[CheckInManager defaultManager] isCheckInToday] == NO){
        [self askCheckIn];
    }
    else{
        [self askEnterFreeCoin];
    }
}



#pragma mark - Home Background Image Handling

#define HOME_BG_IMAGE_VIEW_TAG 123687

- (void)updateBGImageView
{
    CGRect imageFrame = [UIScreen mainScreen].bounds;
    
    PPDebug(@"<update bg image view>");
    UIImage *homeImage = [[UserManager defaultManager] pageBgForKey:HOME_BG_KEY];
    if (homeImage) {
        [self.view setBackgroundColor:[UIColor clearColor]];
        UIImageView *imageView = (id)[self.view reuseViewWithTag:HOME_BG_IMAGE_VIEW_TAG viewClass:[UIImageView class] frame:imageFrame];
        [imageView setImage:homeImage];
        [self.view insertSubview:imageView atIndex:0];
    }else{
        [self.view setBackgroundColor:[self getMainBackgroundColor]]; // OPAQUE_COLOR(0, 191, 178)];
        UIImageView *imageView = (id)[self.view reuseViewWithTag:HOME_BG_IMAGE_VIEW_TAG viewClass:[UIImageView class] frame:imageFrame];
        [imageView removeFromSuperview];
    }
    [(DrawHomeHeaderPanel *)self.homeHeaderPanel updateBG];
}

- (void)clearBGImageView
{
    [self.view setBackgroundColor:[self getMainBackgroundColor]];  //OPAQUE_COLOR(0, 191, 178)];
    UIImageView *imageView = (id)[self.view reuseViewWithTag:HOME_BG_IMAGE_VIEW_TAG viewClass:[UIImageView class] frame:self.view.bounds];
    [imageView setImage:nil];
    [imageView removeFromSuperview];
}

#pragma mark - manage rope view

- (void)updateAnimation
{
    DrawHomeHeaderPanel *header = (id)self.homeHeaderPanel;
    DrawMainMenuPanel *mainPanel = (id)self.homeMainMenuPanel;
    HomeBottomMenuPanel *footer = (id)self.homeBottomMenuPanel;
    
    [header setClickRopeHandler:^(BOOL open)
     {
         if (open) {
             [mainPanel closeAnimated:YES completion:^(BOOL finished) {
                 [mainPanel moveMenuTypeToBottom:[mainPanel getMainType] Animated:YES completion:NULL];
                 [header openAnimated:YES completion:NULL];
                 [footer hideAnimated:YES];
             }];
         }else{
             [mainPanel centerMenu:[mainPanel getMainType] Animated:YES completion:NULL];
             [footer showAnimated:YES];
             [header closeAnimated:YES completion:^(BOOL finished) {
                 [mainPanel openAnimated:YES completion:NULL];
             }];
             
         }
         
         // TODO Benson later
     }];
    
    //#if DEBUG
    //    if (YES) {
    //#else
    if ([[UserManager defaultManager] hasXiaojiNumber] == NO && [[UserManager defaultManager] isOldUserWithoutXiaoji] == NO) {
        //#endif
        [mainPanel closeAnimated:NO completion:^(BOOL finished) {
            [mainPanel moveMenuTypeToBottom:[[self class] homeDefaultMenuType]
                                   Animated:NO
                                 completion:NULL];
            [header openAnimated:NO completion:NULL];
            [footer hideAnimated:NO];
        }];
    }
}



#pragma mark - menu methods

- (BOOL)handleClickMenu:(HomeMainMenuPanel *)mainMenuPanel
                   menu:(HomeMenuView *)menu
               menuType:(HomeMenuType)type
{
    // default impelmentation, to be implemented by sub class
    return NO;
}

- (NSArray*)noCheckedMenuTypes
{
    // default impelmentation, to be implemented by sub class
    return [NSArray array];
}

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    PPDebug(@"<homeMainMenuPanel>, click type = %d", type);    
    NSArray* noCheckedTypes = [self noCheckedMenuTypes];
    
    if (![noCheckedTypes containsObject:@(type)]) {
        CHECK_AND_LOGIN(self.view);
    }

    BOOL isProcessed = [self handleClickMenu:mainMenuPanel menu:menu menuType:type];
    if (isProcessed == NO){            
        switch (type) {
                
            case HomeMenuTypeDrawTimeline:
            {
                [self enterUserTimeline];
                break;
            }

            case HomeMenuTypeDrawBigShop:
            {
                [self enterShop];
                break;
            }

            case HomeMenuTypeDrawBBS:
            {
                [self enterBBS];
                break;
            }
                
            case HomeMenuTypeTask:
            case HomeMenuTypeBottomTask:
            {
                [self enterTask];
                break;
            }
                
            case HomeMenuTypeDrawMore:
            {
                [self enterMore];
                break;
            }
                
            case HomeMenuTypeDrawRank:
            {
                [self enterTopOpus];
                break;
            }
                
            case HomeMenuTypeDrawContest:
            {
                [self enterContest];
                break;
            }
                
            case HomeMenuTypeDrawPainter:
            {
                [self enterPainter];
                break;
            }
                
            case HomeMenuTypeGroup:
            {
                [self enterGroup];
                break;
            }
                
            default:
                break;
        }
    }

    [menu updateBadge:0];
}

- (BOOL)handleClickBottomMenu:(HomeBottomMenuPanel *)bottomMenuPanel
                         menu:(HomeMenuView *)menu
                     menuType:(HomeMenuType)type
{
    // default implementation, need to implement by sub class
    return NO;
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    PPDebug(@"<homeBottomMenuPanel>, click type = %d", type);
    if ([self isRegistered] == NO) {
        [self toRegister];
        return;
    }
    
    BOOL isProcessed = [self handleClickBottomMenu:bottomMenuPanel menu:menu menuType:type];
    if (isProcessed == NO){    
        switch (type) {
                
            case HomeMenuTypeDrawMe:
            case HomeMenuTypeDrawSetting:
            {
                [self enterUserSetting];
                break;
            }

            case HomeMenuTypeDrawFriend:
            {
                [self enterFriend];
                break;
            }
                
            case HomeMenuTypeDrawMessage:
            {
                [self enterChat];
                break;
            }
                
            case HomeMenuTypeDrawMore:
            {
                [self enterMore];
                break;
            }
                
            case HomeMenuTypeDrawTimeline:
            {
                [self enterUserTimeline];
                break;
            }
                
            case HomeMenuTypeDrawShop:
            {
                [self enterShop];
                break;
            }

            case HomeMenuTypeTask:
            case HomeMenuTypeBottomTask:
            {
                [self enterTask];
                break;
            }
                
            default:
                break;
        }
    }

    [menu updateBadge:0];
}

+ (int*)getMainMenuList
{
    // to be implemented by sub class
    return NULL;
}

+ (int *)getBottomMenuList
{
    // to be implemented by sub class
    return NULL;    
}

+ (NSDictionary*)menuTitleDictionary
{
    // to be implemented by sub class
    return nil;
}

+ (NSDictionary*)menuImageDictionary
{
    // to be implemented by sub class
    return nil;
}

+ (NSDictionary*)defaultMenuTitleDictionary
{
    static dispatch_once_t deafaultMenuOnceToken;
    dispatch_once(&deafaultMenuOnceToken, ^{
        DEFAULT_MENU_TITLE_DICT = @{
                                 @(HomeMenuTypeDrawContest) : NSLS(@"kHomeMenuTypeDrawContest"),
                                 @(HomeMenuTypeTask) : NSLS(@"kHomeMenuTypeTask"),
                                 @(HomeMenuTypeDrawBBS) : NSLS(@"kHomeMenuTypeDrawBBS"),
                                 @(HomeMenuTypeDrawBigShop) : NSLS(@"kHomeMenuTypeDrawShop"),
                                 @(HomeMenuTypeDrawShop) : NSLS(@"kHomeMenuTypeDrawShop"),
                                 @(HomeMenuTypeDrawPainter) : NSLS(@"kPainter"),
                                 @(HomeMenuTypeDrawPhoto) : NSLS(@"kGallery"),
                                 @(HomeMenuTypeOpusClass) : NSLS(@"kHomeMenuOpusClass"),
                                 @(HomeMenuTypeDrawApps) : NSLS(@"kMore_apps"),
                                 @(HomeMenuTypeDrawCharge) : NSLS(@"kChargeTitle"),
                                 @(HomeMenuTypeDrawFreeCoins) : NSLS(@"kCheckIn"), //NSLS(@"kFreeIngots"),
                                 @(HomeMenuTypeDrawApps) : NSLS(@"kMore_apps"),
                                 @(HomeMenuTypeDrawMore) : NSLS(@"kHomeMenuTypeDrawMore"),
                                 @(HomeMenuTypeGroup) : NSLS(@"kGroup"),
                                 };
        
        [DEFAULT_MENU_TITLE_DICT retain];  // make sure you retain the dictionary here for futher usage

    });
    
    return DEFAULT_MENU_TITLE_DICT;
}


+ (NSDictionary*)defaultMenuImageDictionary
{
    static dispatch_once_t defaultMenuImageOnceToken;
    dispatch_once(&defaultMenuImageOnceToken, ^{
        DrawImageManager *imageManager = [DrawImageManager defaultManager];
        
        DEFAULT_MENU_IMAGE_DICT = @{
                                 // main
                                 @(HomeMenuTypeDrawRank) : [imageManager drawHomeTop],
                                 @(HomeMenuTypeDrawBBS) : [imageManager drawHomeBbs],
                                 @(HomeMenuTypeTask) : [imageManager drawHomeTask],

                                 // draw
                                 @(HomeMenuTypeDrawGame) : [imageManager drawHomeOnlineGuess],
                                 @(HomeMenuTypeDrawContest) : [imageManager drawHomeContest],
                                 @(HomeMenuTypeDrawDraw) : [imageManager drawHomeDraw],
                                 @(HomeMenuTypeDrawGuess) : [imageManager drawHomeGuess],

                                 @(HomeMenuTypeDrawMore) : [imageManager drawHomeMore],
                                 @(HomeMenuTypeDrawBigShop) : [imageManager drawHomeBigShop],
                                 @(HomeMenuTypeDrawPainter) : [imageManager drawHomePainter],
                                 @(HomeMenuTypeDrawPhoto) : [imageManager userPhoto],
                                 @(HomeMenuTypeOpusClass) : [imageManager userPhoto],
                                 @(HomeMenuTypeDrawFreeCoins) : [imageManager drawFreeCoins],
                                 
                                 // bottom
                                 @(HomeMenuTypeDrawTimeline) : [imageManager drawHomeTimeline],
                                 @(HomeMenuTypeDrawHome) : [imageManager drawHomeHome],
                                 @(HomeMenuTypeDrawOpus) : [imageManager drawHomeOpus],
                                 @(HomeMenuTypeDrawMessage) : [imageManager drawHomeMessage],
                                 @(HomeMenuTypeDrawFriend) : [imageManager drawHomeFriend],
                                 @(HomeMenuTypeDrawMore) : [imageManager drawHomeMore],
                                 @(HomeMenuTypeDrawMe) : [imageManager drawHomeMe],
                                 @(HomeMenuTypeDrawSetting) : [imageManager drawHomeSetting],
                                 @(HomeMenuTypeDrawShop) : [imageManager drawHomeShop],
                                 @(HomeMenuTypeBottomTask) : [imageManager homeBottomTask],
                                 @(HomeMenuTypeGroup) : [imageManager drawHomeGroup],
                                 };
        
        [DEFAULT_MENU_IMAGE_DICT retain];  // make sure you retain the dictionary here for futher usage
        
    });
    
    return DEFAULT_MENU_IMAGE_DICT;
}

+ (int)homeDefaultMenuType
{
    return HomeMenuTypeDrawDraw;
}

+ (UIColor*)getHeaderBackgroundColor
{
    return OPAQUE_COLOR(236, 84, 46); // default
}

- (UIColor*)getMainBackgroundColor
{
    return OPAQUE_COLOR(0, 191, 178); // default
}

@end
