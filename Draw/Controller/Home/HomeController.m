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

#import "RouterTrafficServer.h"
#import "StringUtil.h"
#import "ConfigManager.h"
#import "ChatController.h"
#import "FriendRoomController.h"
#import "CommonMessageCenter.h"
#import "SearchRoomController.h"
#import "AudioManager.h"
//#import "MusicItemManager.h"
#import "DrawAppDelegate.h"
#import "AnimationManager.h"
#import "WordManager.h"
#import "RegisterUserController.h"

#import "OfflineGuessDrawController.h"
//#import "SelectWordController.h"
#import "UseItemScene.h"

#import "ChatListController.h"
#import "LevelService.h"
#import "LmWallService.h"
#import "AdService.h"
//#import "VendingController.h"
#import "ShowFeedController.h"
#import "BulletinService.h"
#import "AnalyticsManager.h"
#import "DrawRecoveryService.h"
#import "UserDetailViewController.h"
#import "SelfUserDetail.h"

//#import "RecommendedAppsController.h"
//#import "FacetimeMainController.h"



#import "ContestController.h"
#import "HotController.h"
#import "MyFeedController.h"

#import "StatisticManager.h"

#import "FriendController.h"

#import "BBSBoardController.h"

#import "BulletinView.h"
#import "DrawTestViewController.h"

#import "SynthesizeSingleton.h"
#import "SelectHotWordController.h"
#import "NotificationName.h"
#import "CommonGameNetworkService.h"
#import "UFPController.h"
#import "UMGridViewController.h"
#import "DrawRoomListController.h"

//#import "OpusSelectController.h"
//#import "Wall.h"
//#import "OpusWallController.h"

#import "StoreController.h"

#import "CustomInfoView.h"
#import "FreeIngotController.h"

#import "VersionUpdateView.h"
#import "GameAdWallService.h"
#import "ChargeController.h"
#import "ContestManager.h"

#import "GalleryController.h"
#import "GuessModesController.h"

@interface HomeController()
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
    
}

#pragma mark - View lifecycle

- (void)initRecommendButton
{
    [self.recommendButton setBackgroundImage:[ShareImageManager defaultManager].greenImage forState:UIControlStateNormal];
    [self.recommendButton setTitle:NSLS(@"kRecommend") forState:UIControlStateNormal];
    int fontSize = ([DeviceDetection isIPAD]?30:17);
    CGSize size = [self.recommendButton.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:fontSize]];
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
    if ([ConfigManager isShowRecommendApp]){
        self.recommendButton.hidden = NO;
    }
    else{
        self.recommendButton.hidden = YES;
    }
    [[ContestService defaultService] getContestListWithType:ContestListTypeRunning offset:0 limit:HUGE_VAL delegate:self];
    [super viewDidLoad];
    
    [self initRecommendButton];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
    
    // Start Game Service And Set User Id
    [[DrawGameService defaultService] setHomeDelegate:self];
//    [[DrawGameService defaultService] setUserId:[[UserManager defaultManager] userId]];
//    [[DrawGameService defaultService] setNickName:[[UserManager defaultManager] nickName]];    
//    [[DrawGameService defaultService] setAvatar:[[UserManager defaultManager] avatarURL]];    
    
    // sync bulletin
//    [[BulletinService defaultService] syncBulletins:^(int resultCode) {
//        [self updateAllBadge];
//    }];  --do it in superHomeContoller-viewDidLoad
    
    [self enterNextControllerWityType:self.notificationType];

    [self registerUIApplicationNotification];
    
    [self performSelector:@selector(updateRecoveryDrawCount) withObject:nil afterDelay:0.5f];
    
//    [self.view bringSubviewToFront:self.testBulletin];
//    [self.view bringSubviewToFront:self.testCreateWallBtn];
    
#ifdef DEBUG
    [self createBtnForTest];
#endif
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
    InputDialog* dialog = [InputDialog dialogWith:nil clickOK:^(NSString *inputStr) {
        NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setObject:inputStr forKey:@"api_server"];
        [userdefault synchronize];
    } clickCancel:^(NSString *inputStr) {
        //
    }];
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    NSString* str = [userdefault objectForKey:@"api_server"];
    if (str && str.length > 5) {
        [dialog.targetTextField setText:str];
    } else {
        [dialog.targetTextField setText:@"192.168.1.198:8000"];
    }
    
    [dialog showInView:self.view];
}

- (void)clickSetTraffic
{
    InputDialog* dialog = [InputDialog dialogWith:nil clickOK:^(NSString *inputStr) {
        NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setObject:inputStr forKey:@"traffic_server"];
        [userdefault synchronize];
    } clickCancel:^(NSString *inputStr) {
        //
    }];
    NSUserDefaults* userdefault = [NSUserDefaults standardUserDefaults];
    NSString* str = [userdefault objectForKey:@"traffic_server"];
    if (str && str.length > 5) {
        [dialog.targetTextField setText:str];
    } else {
        [dialog.targetTextField setText:@"192.168.1.198:8100"];
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
            [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
        }
        
        [[BulletinService defaultService] syncBulletins:^(int resultCode) {
            [self updateAllBadge];
        }];
        
        [self.homeHeaderPanel updateView];
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

    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[DrawGameService defaultService] registerObserver:self];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self hideActivity];
    [[DrawGameService defaultService] unregisterObserver:self];
    [super viewDidDisappear:animated];
    
}

- (void)viewDidUnload
{
//    [[AdService defaultService] clearAdView:_adView];
//    [self setAdView:nil];    
    
    [self setRecommendButton:nil];
    [self setFacetimeButton:nil];
    [self setMenuPanel:nil];
    [self setTestBulletin:nil];
    [self setTestCreateWallBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

//- (void)playBackgroundMusic
//{
//    MusicItemManager* musicManager = [MusicItemManager defaultManager];
//    NSString* musicURL = musicManager.currentMusicItem.localPath;
//    if (musicURL == nil){
//        PPDebug(@"<playBackgroundMusic> but music url is nil");
//        return;
//    }
//    
//    NSURL *url = [NSURL fileURLWithPath:musicURL];
//    AudioManager *audioManager = [AudioManager defaultManager];
//    
//    [audioManager setBackGroundMusicWithURL:url];
////    [audioManager backgroundMusicStart];
//
//}


- (void)didJoinGame:(GameMessage *)message
{
    [self hideActivity];
    if ([message resultCode] == 0){
        [self popupHappyMessage:NSLS(@"kJoinGameSucc") title:@""];
    }
    else{
        NSString* text = [NSString stringWithFormat:NSLS(@"kJoinGameFailure")];
        [self popupUnhappyMessage:text title:@""];
        [[DrawGameService defaultService] disconnectServer];
//        [[RouterService defaultService] putServerInFailureList:[[DrawGameService defaultService] serverAddress]
//                                                          port:[[DrawGameService defaultService] serverPort]];
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
                                    guessDiffLevel:[ConfigManager guessDifficultLevel]
                                       snsUserData:[_userManager snsUserData]];    
    }
    
    _isTryJoinGame = NO;
    
    
}

- (void)didServerListFetched:(int)result
{
//    RouterTrafficServer* server = [[RouterService defaultService] assignTrafficServer];
    NSString* address = nil;
    int port = 9000;

    // update by Benson, to avoid "server full/busy issue"
    if ([[UserManager defaultManager] getLanguageType] == ChineseType){
        address = [ConfigManager defaultChineseServer];
        port = [ConfigManager defaultChinesePort];
    }
    else{
        address = [ConfigManager defaultEnglishServer];
        port = [ConfigManager defaultEnglishPort];
    }
    
    
//    if (server != nil){        
//        address = [server address];
//        port = [server.port intValue];            
//    }


    [[DrawGameService defaultService] setServerAddress:address];
    [[DrawGameService defaultService] setServerPort:port];    

//    [[DrawGameService defaultService] setServerAddress:@"192.168.1.101"];
//    [[DrawGameService defaultService] setServerPort:8080];   

//    [[DrawGameService defaultService] setServerAddress:@"192.168.1.198"];
//    [[DrawGameService defaultService] setServerPort:8080];   


//    [[DrawGameService defaultService] setServerAddress:@"58.215.188.215"];
//    [[DrawGameService defaultService] setServerPort:8080];    

    [[DrawGameService defaultService] connectServer:self];
    _isTryJoinGame = YES;
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
    
    for(UIViewController *vc in navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[SearchRoomController class]]) {
            viewController = vc;
            break;
        }
        if (viewController == nil && [vc isKindOfClass:[FriendRoomController class]]) {
            viewController = vc;
        }
    }
    
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
//        SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
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
//        SelectWordController *sc = [[SelectWordController alloc] initWithTargetUid:uid];
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
//    PPRelease(_adView);
    [_testBulletin release];
    [_testCreateWallBtn release];
    [super dealloc];
}



- (IBAction)clickRecommend:(id)sender
{
    /* rem by Benson to disable the feature
    RecommendedAppsController* vc = [[[RecommendedAppsController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    */
}




#pragma mark - draw data service delegate
- (void)didMatchDraw:(DrawFeed *)feed result:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0 && feed) {
        [OfflineGuessDrawController startOfflineGuess:feed fromController:self];
    }else{
        CommonMessageCenter *center = [CommonMessageCenter defaultCenter];
        [center postMessageWithText:NSLS(@"kMathOpusFail") delayTime:1.5 isHappy:NO];
    }
}

+ (void)startOfflineGuessDraw:(DrawFeed *)feed from:(UIViewController *)viewController
{
    
    if (viewController) {        
        HomeController *home = [HomeController defaultInstance];
        [viewController.navigationController popToViewController:home animated:NO];
        [OfflineGuessDrawController startOfflineGuess:feed fromController:home];
    }    

}





- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    PPDebug(@"<homeMainMenuPanel>, click type = %d", type);
    if (type != HomeMenuTypeDrawDraw && [self isRegistered] == NO) {
        [self toRegister];
        return;
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
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_DRAW];

            SelectHotWordController *sc = [[SelectHotWordController alloc] init];
            [self.navigationController pushViewController:sc animated:YES];
            sc.superController = self;
            [sc release];
        }
            break;
        case HomeMenuTypeDrawGuess:
        {

#ifdef DEBUG
//            GuessModesController *vc =[[[GuessModesController alloc] init] autorelease];
//            [self.navigationController pushViewController:vc animated:YES];
//            return;
#endif
            
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_GUESS];
            
            [self showActivityWithText:NSLS(@"kLoading")];
            [[DrawDataService defaultService] matchDraw:self];
                                    
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
//        case HomeMenuTypeDrawShop:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_SHOP];
            
            StoreController *vc = [[[StoreController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case HomeMenuTypeDrawContest:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_CONTEST];
            
            ContestController *cc = [[ContestController alloc] init];
            [self.navigationController pushViewController:cc animated:YES];
            [cc release];
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
            HotController *hc = [[HotController alloc] init];
            [self.navigationController pushViewController:hc animated:YES];
            [hc release];
        }
            break;
            
        case HomeMenuTypeDrawApps:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_APPS];
            
            UMGridViewController *vc = [[[UMGridViewController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeDrawFreeCoins:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_FREE_COINS];
            FreeIngotController* fc = [[[FreeIngotController alloc] init] autorelease];
            [self.navigationController pushViewController:fc animated:YES];
            
        }
            break;
            
            case HomeMenuTypeDrawPlayWithFriend:
        {
            [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_PLAY_WITH_FRIEDN];
            
            FriendRoomController *vc = [[[FriendRoomController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
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
    [self.navigationController pushViewController:sf animated:YES];
    [sf release];
}

- (IBAction)clickFacetime:(id)sender
{
//    [[BBSService defaultService] getBBSBoardList:nil];
//    BBSBoardController *bbs = [[BBSBoardController alloc] init];
//    [self.navigationController pushViewController:bbs animated:YES];
//    [bbs release];
//    FacetimeMainController* vc = [[[FacetimeMainController alloc] init] autorelease];
//    [self.navigationController pushViewController:vc animated:YES];
    
//    [[DiceGameService defaultService] joinGameRequest];
}

- (IBAction)clickTestBulletin:(id)sender
{
    UIViewController* rc = [[[DrawRoomListController alloc] init] autorelease];
    [self.navigationController pushViewController:rc animated:YES];
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
        [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    }
}

- (IBAction)clickWallButton:(id)sender {
//    OpusSelectController *vc = [[[OpusSelectController alloc] init] autorelease];
//    [self.navigationController pushViewController:vc animated:YES];
//    [[WallService sharedWallService] getWall:[[UserManager defaultManager] userId] wallId:@"512adcf603640c23106a8479" delegate:self];
    
    
    
//    CustomInfoView *customInfoView = [CustomInfoView createWithTitle:@"test" info:@"test"];
//    UIView *infoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 140)] autorelease];
//    infoView.backgroundColor = [UIColor blueColor];
//    CustomInfoView *customInfoView = [CustomInfoView createWithTitle:@"test" infoView:infoView];
//    CustomInfoView *customInfoView = [CustomInfoView createWithTitle:@"test" infoView:infoView hasCloseButton:YES buttonTitles:@"购买", @"赠送",  nil];
//    [customInfoView setActionBlock:^(UIButton *button, UIView *infoView){
//        PPDebug(@"%@", [button titleForState:UIControlStateNormal]);
//        
//    }];
//    [customInfoView showInView:self.view];
    
    [VersionUpdateView showInView:self.view];
}

/* rem by Benson to disable wall
- (void)didGetWall:(int)resultCode wall:(PBWall *)pbWall
{
    PPDebug(@"resultCode = %d", resultCode);
    Wall *wall = [[[Wall alloc] initWithPBWall:pbWall] autorelease];
    OpusWallController *vc = [[[OpusWallController alloc] initWithWall:wall] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}
*/

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel didClickAvatarButton:(UIButton *)button
{
    [super homeHeaderPanel:headerPanel didClickAvatarButton:button];
    UserDetailViewController* us = [[UserDetailViewController alloc] initWithUserDetail:[SelfUserDetail createDetail]];
    //    UserSettingController *us = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

- (void)didGetContestList:(NSArray *)contestList type:(ContestListType)type resultCode:(NSInteger)code
{
    if (code == 0) {
        [[StatisticManager defaultManager] setNewContestCount:[[ContestManager defaultManager] calNewContestCount:contestList]];
    }
    [self updateAllBadge];
    
}

@end
