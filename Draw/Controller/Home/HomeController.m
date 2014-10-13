//
//  HomeController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012Âπ?__MyCompanyName__. All rights reserved.
//

#import "HomeController.h"
#import "RoomController.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "DrawGameService.h"
#import "DrawAppDelegate.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "GameMessage.pb.h"
#import "CommonDialog.h"
#import "FeedbackController.h"
#import "UserSettingController.h"
#import "ShareController.h"
#import "Reachability.h"
#import "ShareImageManager.h"
#import "AccountService.h"
#import "CommonDialog.h"

#import "StringUtil.h"
#import "PPConfigManager.h"
#import "ChatController.h"
#import "CommonMessageCenter.h"
#import "AudioManager.h"
#import "DrawAppDelegate.h"
#import "AnimationManager.h"
#import "WordManager.h"

//#import "OfflineGuessDrawController.h"
#import "UseItemScene.h"

#import "ChatListController.h"
#import "LevelService.h"
#import "AdService.h"
#import "ShowFeedController.h"
#import "BulletinService.h"
#import "AnalyticsManager.h"
#import "DrawRecoveryService.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"

#import "ContestController.h"
#import "HotController.h"
#import "MyFeedController.h"

#import "StatisticManager.h"

#import "FriendController.h"

#import "BBSBoardController.h"

#import "BulletinView.h"

#import "SynthesizeSingleton.h"
#import "SelectHotWordController.h"
#import "NotificationName.h"
#import "CommonGameNetworkService.h"

#import "DrawRoomListController.h"
#import "UserManager.h"
#import "ContestService.h"

#import "StoreController.h"

#import "CustomInfoView.h"
#import "FreeIngotController.h"

#import "VersionUpdateView.h"
#import "GameAdWallService.h"
#import "ChargeController.h"
#import "ContestManager.h"

#import "GalleryController.h"
#import "GuessModesController.h"
#import "SelectWordController.h"
#import "DrawHomeHeaderPanel.h"
#import "DrawMainMenuPanel.h"
#import "GuessManager.h"

#import "SDWebImageManager.h"
#import "PainterController.h"

//test
#import "CreateGroupController.h"
#import "GroupHomeController.h"
#import "DrawImageManager.h"
#import "StringUtil.h"
#import "ShowOpusClassListController.h"

static NSDictionary* DRAW_MENU_TITLE_DICT = nil;
static NSDictionary* DRAW_MENU_IMAGE_DICT = nil;

@interface HomeController()<GuessServiceDelegate>
{

}
- (void)enterNextControllerWityType:(NotificationType) type;
@end

@implementation HomeController
@synthesize facetimeButton = _facetimeButton;

//@synthesize adView = _adView;
@synthesize recommendButton = _recommendButton;
@synthesize notificationType = _notificationType;
@synthesize menuPanel = _menuPanel;
@synthesize bottomMenuPanel = _bottomMenuPanel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userManager = [UserManager defaultManager];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [[WordManager defaultManager] clearWordBaseDictionary];
    
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    
}

#pragma mark - View lifecycle

- (void)initRecommendButton
{
    [self.recommendButton setBackgroundImage:[ShareImageManager defaultManager].greenImage forState:UIControlStateNormal];
    [self.recommendButton setTitle:NSLS(@"kRecommend") forState:UIControlStateNormal];
    int fontSize = ([DeviceDetection isIPAD]?30:17);
    CGSize size = [self.recommendButton.titleLabel.text sizeWithMyFont:[UIFont systemFontOfSize:fontSize]];
    if (size.width >= self.recommendButton.frame.size.width) {
        [self.recommendButton setFrame:CGRectMake(self.recommendButton.frame.origin.x, 
                                                  self.recommendButton.frame.origin.y, 
                                                  self.recommendButton.frame.size.width*2, 
                                                  self.recommendButton.frame.size.height)];
    }
    if (![[AdService defaultService] isShowAd]) {
        if ([DeviceDetection isIPAD]){
            [self.recommendButton setFrame:CGRectMake(65, self.recommendButton.frame.origin.y, self.recommendButton.frame.size.width, self.recommendButton.frame.size.height)];
        }
    }
}

- (void)viewDidLoad
{        
    [super viewDidLoad];
    
    // Start Game Service And Set User Id
    [[DrawGameService defaultService] setHomeDelegate:self];
    
    [self enterNextControllerWityType:self.notificationType];

    [self registerUIApplicationNotification];
    
//    [self performSelector:@selector(updateRecoveryDrawCount) withObject:nil afterDelay:0.5f];
    
    
    [[GuessService defaultService] getTodayGuessContestInfoWithDelegate:self];
    
    [self showGuidePage];
}

- (void)didGetGuessContest:(PBGuessContest *)contest resultCode:(int)resultCode{
    
    if ([GuessManager isContestBeing:contest]
        && [GuessManager getGuessStateWithMode:PBUserGuessModeGuessModeContest contestId:contest.contestId] == GuessStateNotStart) {
        [[StatisticManager defaultManager] setGuessContestNotif:1];
    }else{
        [[StatisticManager defaultManager] setGuessContestNotif:0];
    }
    
    [self updateAllBadge];
}

#ifdef DEBUG
// the 3 methods below work for creating set api server url and traffic server url
//---by kira
- (void)createBtnForTest
{
    UIButton* btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn1 setTitle:@"api" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(clickSetAPI) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setFrame:CGRectMake(self.view.bounds.size.width/2-80, 0, 80, 40)];
    
    UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setTitle:@"traffic" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(clickSetTraffic) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setFrame:CGRectMake(self.view.bounds.size.width/2, 0, 80, 40)];
    [btn1 setBackgroundColor:[UIColor clearColor]];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
}

- (void)clickSetAPI
{
    CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:nil];
    [dialog setClickOkBlock:^(UITextField *tf) {
        NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setObject:tf.text forKey:@"api_server"];
        [userdefault synchronize];
    }];
    
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    NSString* str = [userdefault objectForKey:@"api_server"];
    if (str && str.length > 5) {
        [dialog.inputTextField setText:str];
    } else {
        [dialog.inputTextField setText:@"192.168.1.198:8000"];
    }
    
    [dialog showInView:self.view];
}

- (void)clickSetTraffic
{
    CommonDialog* dialog = [CommonDialog createInputFieldDialogWith:nil];
    [dialog setClickOkBlock:^(UITextField *tf) {
        NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setObject:tf.text forKey:@"traffic_server"];
        [userdefault synchronize];
    }];
    
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    NSString* str = [userdefault objectForKey:@"traffic_server"];
    if (str && str.length > 5) {
        [dialog.inputTextField setText:str];
    } else {
        [dialog.inputTextField setText:@"192.168.1.198:8100"];
    }
    [dialog showInView:self.view];
}
#endif

- (void)registerUIApplicationNotification
{
    
    [self registerNotificationWithName:UIApplicationDidEnterBackgroundNotification usingBlock:^(NSNotification *note) {
        _connectState = [[DrawGameService defaultService] isConnected];
    }];
    
    [self registerNotificationWithName:UIApplicationWillEnterForegroundNotification usingBlock:^(NSNotification *note) {
        
        if (_connectState && [[DrawGameService defaultService] isConnected] == NO) {
            [[DrawGameService defaultService] setSession:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
            POSTMSG(NSLS(@"kNetworkBroken"));
        }
        
        [[BulletinService defaultService] syncBulletins:^(int resultCode) {
            PPDebug(@"sync bulletin done, update header view panel");
            StatisticManager *manager = [StatisticManager defaultManager];
            [self.homeHeaderPanel updateBulletinBadge:[manager bulletinCount]];
        }];
        
        [self.homeHeaderPanel updateView];
    }];
    
    [self registerNotificationWithName:NOTIFCATION_CONTEST_DATA_CHANGE usingBlock:^(NSNotification *note) {
        PPDebug(@"recv NOTIFCATION_CONTEST_DATA_CHANGE, update header view panel");
        [self updateAllBadge];
    }];
}

- (void)updateRecoveryDrawCount
{
    NSUInteger count = [[DrawRecoveryService defaultService] recoveryDrawCount];
    [self.homeBottomMenuPanel updateMenu:HomeMenuTypeDrawOpus badge:count];
    [[StatisticManager defaultManager] setRecoveryCount:count];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.homeHeaderPanel viewDidAppear];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[DrawGameService defaultService] registerObserver:self];
    [[GuessService defaultService] getTodayGuessContestInfoWithDelegate:self];

    [super viewDidAppear:animated];
    
    if ([[UserManager defaultManager] hasXiaojiNumber] == NO){
        [self showGuidePage];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.homeHeaderPanel viewDidDisappear];
    
    [self hideActivity];
    [[DrawGameService defaultService] unregisterObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setRecommendButton:nil];
    [self setFacetimeButton:nil];
    [self setMenuPanel:nil];
    [self setTestBulletin:nil];
    [self setTestCreateWallBtn:nil];
    [super viewDidUnload];
}


- (void)enterNextControllerWityType:(NotificationType) type
{
    switch (type) {
        case NotificationTypeFeed:
        {
            HomeMenuView *menu = [self.homeMainMenuPanel getMenuViewWithType:HomeMenuTypeDrawTimeline];
            [self homeMainMenuPanel:self.homeMainMenuPanel didClickMenu:menu menuType:menu.type];
            break;
        }
            
        case NotificationTypeRoom:{
            //no friend room menu in 5.2 version
            break;
        }

        case NotificationTypeMessage:
        {
            HomeMenuView *menu = [self.homeBottomMenuPanel getMenuViewWithType:HomeMenuTypeDrawMessage];
            [self homeBottomMenuPanel:self.homeBottomMenuPanel didClickMenu:menu menuType:menu.type];
            break;            
        }

        case NotificationTypeComment:
        case NotificationTypeFlower:
        case NotificationTypeReply:
        case NotificationTypeTomato:
            [MyFeedController enterControllerWithIndex:1 fromController:self animated:YES];
            break;
        case NotificationTypeDrawToMe:            
            [MyFeedController enterControllerWithIndex:2 fromController:self animated:YES];
            break;            
        default:
            break;
    }
}

- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    if ([message resultCode] == 0){
        POSTMSG(NSLS(@"kJoinGameSucc"));
    }
    else{
        POSTMSG(NSLS(@"kJoinGameFailure"));
        [[DrawGameService defaultService] disconnectServer];
        return;
    }

    [RoomController enterRoom:self isFriendRoom:NO];
}

- (void)enterShareFromWeixin
{
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        ShareController* share = [[ShareController alloc] init ];
        [share setFromWeiXin:YES];
        [self.navigationController pushViewController:share animated:YES];
        [share release];
    }    
}


- (void)didBroken
{
    _isTryJoinGame = NO;
    PPDebug(@"<didBroken>");
    [self hideActivity];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didConnected
{
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kJoiningGame")];
    
    
    NSString* userId = [_userManager userId];
    NSString* nickName = [_userManager nickName];
    
    if (userId == nil){
        userId = [NSString GetUUID];
    }
    
    if (nickName == nil){
        nickName = NSLS(@"guest");
    }

    
    if (_isTryJoinGame){
        [[DrawGameService defaultService] joinGame:userId
                                          nickName:nickName
                                            avatar:[_userManager avatarURL]
                                            gender:[_userManager isUserMale]
                                          location:[_userManager location] 
                                         userLevel:[[LevelService defaultService] level]
                                    guessDiffLevel:[PPConfigManager guessDifficultLevel]
                                       snsUserData:[_userManager snsUserData]];    
    }
    
    _isTryJoinGame = NO;
    
    
}

+ (HomeController*)defaultInstance
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.homeController == nil){    
        app.homeController = [[[HomeController alloc] init] autorelease];
    }
    
    return (HomeController*)app.homeController;
}

+ (void)returnRoom:(UIViewController*)superController
{
    
    UIViewController *viewController = nil;
    
    UINavigationController* navigationController = [[HomeController defaultInstance] navigationController];
    
    if (viewController != nil) {
        [navigationController popToViewController:viewController animated:YES];        
        return;
    }
    
    [navigationController popToViewController:[HomeController defaultInstance] 
                                                     animated:YES];
}

+ (void)startOfflineDrawFrom:(UIViewController *)viewController
{
    if (viewController) {        
        HomeController *home = [HomeController defaultInstance];
        [viewController.navigationController popToViewController:home animated:NO];
        SelectHotWordController *sc = [[SelectHotWordController alloc] init];
        [home.navigationController pushViewController:sc animated:NO];
        [sc release];
        sc.superController = home;
    }    
}

+ (void)startOfflineDrawFrom:(UIViewController *)viewController 
                         uid:(NSString *)uid
{
    if (viewController) {        
        HomeController *home = [HomeController defaultInstance];
        [viewController.navigationController popToViewController:home animated:NO];
        SelectHotWordController *sc = [[SelectHotWordController alloc] initWithTargetUid:uid];
        [home.navigationController pushViewController:sc animated:NO];
        sc.superController = home;
        [sc release];
    }    

}
- (void)dealloc {
    
    PPRelease(_recommendButton);
    PPRelease(_facetimeButton);
    PPRelease(_menuPanel);
    PPRelease(_bottomMenuPanel);
    [self.timer invalidate];
    [_testBulletin release];
    [_testCreateWallBtn release];
    [super dealloc];
}


- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    
    NSArray *noCheckedTypes = @[@(HomeMenuTypeDrawDraw),
                                @(HomeMenuTypeDrawContest),
                                @(HomeMenuTypeDrawBBS),
                                @(HomeMenuTypeDrawRank),
                                @(HomeMenuTypeDrawGuess),
                                @(HomeMenuTypeDrawMore),
                                ];
    
    if (![noCheckedTypes containsObject:@(type)]) {
        CHECK_AND_LOGIN(self.view);
    }
    
    switch (type) {
        case HomeMenuTypeDrawGame:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_ONLINE];
            UIViewController* rc = [[[DrawRoomListController alloc] init] autorelease];
            [self.navigationController pushViewController:rc animated:YES];
            
        }
            
            break;
        case HomeMenuTypeDrawDraw:
        {
#ifdef DEBUG
            [self enterOfflineDrawWithMenu];
            break;
#endif
            
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_DRAW];
            [OfflineDrawViewController startDraw:[Word cusWordWithText:@""] fromController:self startController:self targetUid:nil];
        }
            break;
        case HomeMenuTypeDrawGuess:
        {
            
#ifdef DEBUG
//            CreateGroupController *cg = [[CreateGroupController alloc] init];
//            [self.navigationController pushViewController:cg animated:YES];
//            [cg release];
//            break;
#endif
          
            GuessModesController *vc =[[[GuessModesController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeDrawTimeline:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TIMELINE];
            
            [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
            [[StatisticManager defaultManager] setTimelineOpusCount:0];
        }
            break;
        case HomeMenuTypeDrawBigShop:
        {
//#ifdef DEBUG
//            [[UserService defaultService] showXiaojiNumberView:self.view];
//            return;
//#endif
            
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_SHOP];
            
            StoreController *vc = [[[StoreController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case HomeMenuTypeDrawContest:
#ifdef DEBUG
//        {
//            GroupHomeController *gc = [[GroupHomeController alloc] init];
//            [self.navigationController pushViewController:gc animated:YES];
//            [gc release];
//            break;
//        }

#endif
            
        {
            [self enterContest];
//            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_CONTEST];
//            
//            ContestController *cc = [[ContestController alloc] init];
//            [self.navigationController pushViewController:cc animated:YES];
//            [cc release];
        }
            break;
        case HomeMenuTypeDrawBBS:{
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_BBS];
            
            BBSBoardController *bbs = [[BBSBoardController alloc] init];
            [self.navigationController pushViewController:bbs animated:YES];
            [bbs release];
            
        }
            break;
            
        case HomeMenuTypeDrawRank:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TOP];
            [self enterOpusClass];
            
//            HotController *hc = [[HotController alloc] init];
//            [self.navigationController pushViewController:hc animated:YES];
//            [hc release];
        }
            break;
            
        case HomeMenuTypeDrawApps:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_APPS];
            
//            UMGridViewController *vc = [[[UMGridViewController alloc] init] autorelease];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeDrawFreeCoins:
        {
            [self enterCheckIn];
        }
            break;
            
            case HomeMenuTypeDrawPlayWithFriend:
        {
//            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_PLAY_WITH_FRIEDN];
//            
//            FriendRoomController *vc = [[[FriendRoomController alloc] init] autorelease];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            
        case HomeMenuTypeDrawMore:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_MORE];
            
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
        }
            break;
        case HomeMenuTypeDrawCharge: {
            ChargeController *vc = [[[ChargeController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case HomeMenuTypeDrawPhoto: {
            GalleryController* gallery = [[[GalleryController alloc] init] autorelease];
            [self.navigationController pushViewController:gallery animated:YES];

            
        } break;
        case HomeMenuTypeDrawPainter:{
            PainterController *pc = [[PainterController alloc] init];
            [self.navigationController pushViewController:pc animated:YES];
            [pc release];
            break;
        }
        case HomeMenuTypeOpusClass:{
            [self enterOpusClass];
            break;
        }
        
        case HomeMenuTypeTask:
        case HomeMenuTypeBottomTask:
        {
            [self enterTask];
            break;
        }
        case HomeMenuTypeGroup:
        {
            [self enterGroup];
            break;
        }
            
        case HomeMenuTypeLearnDraw:
        {
            [self enterLearnDraw];
        }
            break;
            
            
        default:
            break;
    }
    [menu updateBadge:0];
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
    switch (type) {
        
        //For Bottom Menus
        case HomeMenuTypeDrawMe:
        case HomeMenuTypeDrawSetting:
        {
            if (type == HomeMenuTypeDrawSetting){
                [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_USER];
            }
            else{
                [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_TOP_AVATAR];
            }
            
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            
            break;
        case HomeMenuTypeDrawOpus:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_OPUS];
            ShareController* share = [[ShareController alloc] init];
            int count = [[StatisticManager defaultManager] recoveryCount];
            if (count > 0) {
                [share setDefaultTabIndex:2];
                [[StatisticManager defaultManager] setRecoveryCount:0];
            }
            [self.navigationController pushViewController:share animated:YES];
            [share release];
            
        }
            break;
        case HomeMenuTypeDrawFriend:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_FRIEND];

            FriendController *mfc = [[FriendController alloc] init];
            if ([[StatisticManager defaultManager] fanCount] > 0) {
                [mfc setDefaultTabIndex:FriendTabIndexFan];
            }
            [self.navigationController pushViewController:mfc animated:YES];
            [mfc release];
        }
            break;
        case HomeMenuTypeDrawMessage:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_CHAT];
            
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            
        }
            break;
            
        case HomeMenuTypeBottomTask:
        {
            [self enterTask];
        }
            break;

        case HomeMenuTypeDrawMore:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_BOTTOM_MORE];
            
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
        }
            break;
            
        case HomeMenuTypeDrawTimeline:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_TIMELINE];
            
            [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
            [[StatisticManager defaultManager] setTimelineOpusCount:0];
        }
            break;
            
        case HomeMenuTypeLearnDraw:
        {
            [self enterLearnDraw];
        }
            break;
            
        case HomeMenuTypeDrawShop:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_SHOP];
            
            StoreController *vc = [[[StoreController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;

        default:
            break;
    }
    [menu updateBadge:0];
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
      didClickDrawImage:(DrawFeed *)drawFeed
{
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeElements:HOME_HOT_DRAW];
    
    if ([self isRegistered] == NO) {
        [self toRegister];
        return;
    }
    UseItemScene *scene = [UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:drawFeed];
    ShowFeedController *sf = [[ShowFeedController alloc] initWithFeed:drawFeed
                                                                scene:scene];
    [sf showOpusImageBrower];
    [self.navigationController pushViewController:sf animated:YES];
    [sf release];
}

#pragma mark - handle network listen

- (void)handleJoinGameResponse
{
    [self hideActivity];

}

- (void)handleConnectedResponse
{
    [self hideActivity];
}

- (void)handleDisconnectWithError:(NSError *)error
{
    PPDebug(@"diconnect error: %@", [error description]);
    
    _isTryJoinGame = NO;
    [self hideActivity];
    
    if (error != nil) {
        [[DrawGameService defaultService] setSession:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        POSTMSG(NSLS(@"kNetworkBroken"));
    }
}

- (IBAction)clickWallButton:(id)sender {
    
    [VersionUpdateView showInView:self.view];
}

#pragma mark - menu methods

int *getDrawMainMenuTypeListHasNewContest()
{
    int static list[] = {
        HomeMenuTypeDrawDraw,
        HomeMenuTypeGroup,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawRank,
        HomeMenuTypeLearnDraw,
//        HomeMenuTypeDrawFreeCoins,
//        HomeMenuTypeOpusClass,
        HomeMenuTypeDrawContest,
        
        HomeMenuTypeDrawBigShop,
        HomeMenuTypeDrawFreeCoins,
//        HomeMenuTypeDrawPhoto,
        HomeMenuTypeDrawMore,
        HomeMenuTypeDrawPainter,
        HomeMenuTypeDrawGame,
        HomeMenuTypeDrawGuess,
        
        HomeMenuTypeEnd
    };
    return list;
}


int *getDrawMainMenuTypeListWithoutFreeCoins()
{
    int static list[] = {
        HomeMenuTypeDrawDraw,
        HomeMenuTypeGroup,
        HomeMenuTypeDrawBBS,
        HomeMenuTypeDrawRank,
        HomeMenuTypeLearnDraw,
//        HomeMenuTypeDrawNewHot,
        HomeMenuTypeDrawContest,
        
        HomeMenuTypeDrawBigShop,
//        HomeMenuTypeDrawFreeCoins,
        HomeMenuTypeDrawFreeCoins,
//        HomeMenuTypeDrawPhoto,
        HomeMenuTypeDrawMore,
        HomeMenuTypeDrawPainter,
        HomeMenuTypeDrawGuess,
        
        HomeMenuTypeEnd
//        HomeMenuTypeDrawDraw,
//        HomeMenuTypeGroup,        
//        HomeMenuTypeDrawBBS,
//        HomeMenuTypeDrawRank,
//        HomeMenuTypeDrawPainter,
//        HomeMenuTypeDrawContest,
//        
//        HomeMenuTypeDrawBigShop,
//        HomeMenuTypeTask,
//        HomeMenuTypeDrawMore,
//        HomeMenuTypeDrawPhoto,
//
//        HomeMenuTypeDrawGame,
//        HomeMenuTypeDrawGuess,
//        
//        HomeMenuTypeEnd
    };
    return list;
}

int *getDrawMainMenuTypeList()
{
    if ([PPConfigManager freeCoinsEnabled]) {
        return getDrawMainMenuTypeListHasNewContest();
    } else {
        return getDrawMainMenuTypeListWithoutFreeCoins();
    }
}


int *getDrawBottomMenuTypeList()
{
    int static list[] = {
        HomeMenuTypeDrawTimeline,
        HomeMenuTypeDrawOpus,
        HomeMenuTypeDrawFriend,
        HomeMenuTypeDrawMessage,
//        HomeMenuTypeDrawShop,
        HomeMenuTypeBottomTask,
        HomeMenuTypeEnd
    };
    return list;
}

+ (int *)getMainMenuList
{
    return getDrawMainMenuTypeList();
}

+ (int *)getBottomMenuList
{
    return getDrawBottomMenuTypeList();
}

+ (NSDictionary*)menuTitleDictionary
{
    static dispatch_once_t drawMenuTitleOnceToken;
    dispatch_once(&drawMenuTitleOnceToken, ^{
        DRAW_MENU_TITLE_DICT = @{
                                 @(HomeMenuTypeDrawDraw) : NSLS(@"kHomeMenuTypeDrawDraw"),
                                 @(HomeMenuTypeDrawGuess) : NSLS(@"kHomeMenuTypeDrawGuess"),
                                 @(HomeMenuTypeDrawGame) : NSLS(@"kHomeMenuTypeDrawGame"),
                                 @(HomeMenuTypeDrawRank) : NSLS(@"kHomeMenuTypeDrawRank"),
                                 };
        
        [DRAW_MENU_TITLE_DICT retain];  // make sure you retain the dictionary here for futher usage
    });
    
    return DRAW_MENU_TITLE_DICT;
}

+ (NSDictionary*)menuImageDictionary
{
    static dispatch_once_t drawMenuImageOnceToken;
    dispatch_once(&drawMenuImageOnceToken, ^{
        DrawImageManager *imageManager = [DrawImageManager defaultManager];
        
        DRAW_MENU_IMAGE_DICT = @{
                                    // draw
                                    @(HomeMenuTypeDrawGame) : [imageManager drawHomeOnlineGuess],
                                    @(HomeMenuTypeDrawDraw) : [imageManager drawHomeDraw],
                                    @(HomeMenuTypeDrawGuess) : [imageManager drawHomeGuess],
                                    };
        
        [DRAW_MENU_IMAGE_DICT retain];  // make sure you retain the dictionary here for futher usage
        
    });
    
    return DRAW_MENU_IMAGE_DICT;
}

+ (int)homeDefaultMenuType
{
    return HomeMenuTypeDrawDraw;
}

@end
