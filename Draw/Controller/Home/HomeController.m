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
#import "FacebookSNSService.h"
#import "ItemShopController.h"
#import "RouterTrafficServer.h"
#import "StringUtil.h"
#import "ConfigManager.h"
#import "ChatController.h"
#import "FriendRoomController.h"
#import "CommonMessageCenter.h"
#import "SearchRoomController.h"
#import "AudioManager.h"
#import "MusicItemManager.h"
#import "DrawAppDelegate.h"
#import "AnimationManager.h"
#import "WordManager.h"
#import "MyFriendsController.h"
#import "RegisterUserController.h"
#import "FeedController.h"

#import "OfflineGuessDrawController.h"
#import "SelectWordController.h"


#import "ChatListController.h"
#import "LevelService.h"
#import "LmWallService.h"
#import "AdService.h"
#import "VendingController.h"
#import "RecommendedAppsController.h"

#import "FacetimeMainController.h"


#import "BoardPanel.h"
#import "MenuPanel.h"
#import "BottomMenuPanel.h"
#import "BoardManager.h"


#import "ContestController.h"
#import "HotController.h"
#import "MyFeedController.h"

@interface HomeController()
{
    BoardPanel *_boardPanel;
    NSTimeInterval interval;

}
- (void)playBackgroundMusic;
- (void)enterNextControllerWityType:(NotificationType) type;
- (BOOL)isRegistered;
- (void)toRegister;
- (void)updateBoardPanelWithBoards:(NSArray *)boards;
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


- (void)loadBoards
{
    NSArray *borads = [[BoardManager defaultManager] boardList];
    [self updateBoardPanelWithBoards:borads];

}

- (void)loadMainMenu
{
    self.menuPanel = [MenuPanel menuPanelWithController:self 
                                            gameAppType:GameAppTypeDraw];
    
    self.menuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 686) : CGPointMake(160, 306);
    
    [self.view insertSubview:self.menuPanel atIndex:0];

}

- (void)loadBottomMenu
{
    self.bottomMenuPanel = [BottomMenuPanel panelWithController:self
                                                    gameAppType:GameAppTypeDraw];
    
    self.bottomMenuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 961) : CGPointMake(160, 438);
    
    [self.view addSubview:_bottomMenuPanel];
}


- (void)viewDidLoad
{        
    if ([ConfigManager isShowRecommendApp]){
        self.recommendButton.hidden = NO;
    }
    else{
        self.recommendButton.hidden = YES;
    }
    
    [super viewDidLoad];    
    [self loadMainMenu];
    [self loadBottomMenu];
//    [self loadBoards];
    [self playBackgroundMusic];
    
    // set text

    [self initRecommendButton];
    
    
    

    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
    
    // Start Game Service And Set User Id
    [[DrawGameService defaultService] setHomeDelegate:self];
    [[DrawGameService defaultService] setUserId:[[UserManager defaultManager] userId]];
    [[DrawGameService defaultService] setNickName:[[UserManager defaultManager] nickName]];    
    [[DrawGameService defaultService] setAvatar:[[UserManager defaultManager] avatarURL]];    
    
//    if ([ConfigManager isInReviewVersion] == NO && ([LocaleUtils isChina] || [LocaleUtils isOtherChina])){
//        //[self.shopButton setTitle:NSLS(@"kFreeGetCoins") forState:UIControlStateNormal];
//    }

    [self enterNextControllerWityType:self.notificationType];
    

}

- (void)registerDrawGameNotificationWithName:(NSString *)name 
                                  usingBlock:(void (^)(NSNotification *note))block
{
    PPDebug(@"<%@> name", [self description]);         
    
    [self registerNotificationWithName:name 
                                object:nil 
                                 queue:[NSOperationQueue mainQueue] 
                            usingBlock:block];
}

- (void)registerDrawGameNotification
{    
    [self registerNotificationWithName:BOARD_UPDATE_NOTIFICATION // TODO set right name here
                                object:nil
                                 queue:[NSOperationQueue mainQueue]
                            usingBlock:^(NSNotification *note) {
                                
                                [self updateBoardPanelWithBoards:[[BoardManager defaultManager] boardList]];
                                
                            }];  
    
    [self registerNotificationWithName:UIApplicationDidEnterBackgroundNotification
                                object:nil
                                 queue:[NSOperationQueue mainQueue]
                            usingBlock:^(NSNotification *note) {
                                PPDebug(@"enter background and clear ads.");
                                //clear the ad.
                                [_boardPanel clearAds];
                                [_boardPanel stopTimer];                                
                                
                            }]; 
}

- (void)unregisterDrawGameNotification
{        
    [self unregisterAllNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self registerDrawGameNotification];
    
    [[UserService defaultService] getStatistic:self];   
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[DrawGameService defaultService] registerObserver:self];
    [self loadBoards];
    [super viewDidAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterDrawGameNotification];
    [_boardPanel clearAds];
    [_boardPanel stopTimer];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}


- (void)enterNextControllerWityType:(NotificationType) type
{
    switch (type) {
        case NotificationTypeFeed:
            [self didClickMenuButton:[self.menuPanel getMenuButtonByType:MenuButtonTypeTimeline]];
            break;
        case NotificationTypeRoom:
            [self didClickMenuButton:[self.menuPanel getMenuButtonByType:MenuButtonTypeFriendPlay]];
            break;
        case NotificationTypeMessage:
            [self didClickMenuButton:[self.bottomMenuPanel getMenuButtonByType:MenuButtonTypeChat]];
            
            break;
        default:
            break;
    }
}

- (void)playBackgroundMusic
{
    MusicItemManager* musicManager = [MusicItemManager defaultManager];
    NSString* musicURL = musicManager.currentMusicItem.localPath;
    if (musicURL == nil){
        PPDebug(@"<playBackgroundMusic> but music url is nil");
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:musicURL];
    AudioManager *audioManager = [AudioManager defaultManager];
    
    [audioManager setBackGroundMusicWithURL:url];
    [audioManager backgroundMusicStart];

}


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
    
    [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //        // disable this policy at this moment...
//    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable){
//        [[RouterService defaultService] putServerInFailureList:[[DrawGameService defaultService] serverAddress]
//                                                          port:[[DrawGameService defaultService] serverPort]];
//    }
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
    RouterTrafficServer* server = [[RouterService defaultService] assignTrafficServer];
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
    
    
    if (server != nil){        
        address = [server address];
        port = [server.port intValue];            
    }


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


+ (HomeController *)defaultInstance
{
    DrawAppDelegate* app = (DrawAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (app.homeController == nil){    
        app.homeController = [[[HomeController alloc] init] autorelease];
    }
    
    return app.homeController;
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
        SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
        [home.navigationController pushViewController:sc animated:NO];
        [sc release];
    }    
}

+ (void)startOfflineDrawFrom:(UIViewController *)viewController 
                         uid:(NSString *)uid
{
    if (viewController) {        
        HomeController *home = [HomeController defaultInstance];
        [viewController.navigationController popToViewController:home animated:NO];
        SelectWordController *sc = [[SelectWordController alloc] initWithTargetUid:uid];
        [home.navigationController pushViewController:sc animated:NO];
        [sc release];
    }    

}
- (void)dealloc {
    PPRelease(_recommendButton);
    PPRelease(_facetimeButton);
    PPRelease(_menuPanel);
    PPRelease(_bottomMenuPanel);
//    PPRelease(_adView);
    [super dealloc];
}



- (IBAction)clickRecommend:(id)sender
{
    RecommendedAppsController* vc = [[[RecommendedAppsController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
}

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

+ (void)startOfflineGuessDraw:(Feed *)feed from:(UIViewController *)viewController
{
    
    if (viewController) {        
        HomeController *home = [HomeController defaultInstance];
        [viewController.navigationController popToViewController:home animated:NO];
        [OfflineGuessDrawController startOfflineGuess:feed fromController:home];
    }    

}



- (void)didGetStatistic:(int)resultCode 
              feedCount:(long)feedCount 
           messageCount:(long)messageCount 
               fanCount:(long)fanCount 
              roomCount:(long)roomCount
{
    if (resultCode == 0) {
        PPDebug(@"<didGetStatistic>:feedCount = %ld, messageCount = %ld, fanCount = %ld", feedCount,messageCount,fanCount);     
        //update badge

        
        [self.bottomMenuPanel setMenuBadge:messageCount forMenuType:MenuButtonTypeChat];
        [self.bottomMenuPanel setMenuBadge:fanCount 
                               forMenuType:MenuButtonTypeFriend];

    
        [self.menuPanel setMenuBadge:feedCount 
                         forMenuType:MenuButtonTypeTimeline];
        [self.menuPanel setMenuBadge:roomCount
                         forMenuType:MenuButtonTypeFriendPlay];
    }
}



- (void)updateBadgeWithUserInfo:(NSDictionary *)userInfo;
{
    int badge = [NotificationManager feedBadge:userInfo];
    [self.menuPanel setMenuBadge:badge 
                     forMenuType:MenuButtonTypeTimeline];
    
    badge = [NotificationManager roomBadge:userInfo];    
    [self.menuPanel setMenuBadge:badge
                     forMenuType:MenuButtonTypeFriendPlay];
    
    badge = [NotificationManager fanBadge:userInfo];
    [self.bottomMenuPanel setMenuBadge:badge 
                           forMenuType:MenuButtonTypeFriend];
    
    
    badge = [NotificationManager messageBadge:userInfo];
    [self.bottomMenuPanel setMenuBadge:badge
                           forMenuType:MenuButtonTypeChat];
    


}



- (IBAction)clickFacetime:(id)sender
{
    FacetimeMainController* vc = [[[FacetimeMainController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
//    [[DiceGameService defaultService] joinGameRequest];
}


//#define BOARD_PANEL_TAG 201208241
#pragma mark - board service delegate

- (void)cleanBoardPanel
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[BoardPanel class]]) {
            [view removeFromSuperview];
        }
    }
}
- (void)updateBoardPanelWithBoards:(NSArray *)boards
{
    if ([boards count] != 0) {
        [self cleanBoardPanel];
        _boardPanel = [BoardPanel boardPanelWithController:self];
        [_boardPanel setBoardList:boards];
        [self.view addSubview:_boardPanel];  
    }

}


#pragma mark - Button Menu delegate

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
            [self showActivityWithText:NSLS(@"kJoiningGame")];
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
                
                [self showActivityWithText:NSLS(@"kConnectingServer")];        
                [[RouterService defaultService] tryFetchServerList:self];        
            }
            
        }
            
            break;
        case MenuButtonTypeOfflineDraw:
        {
            SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
            [self.navigationController pushViewController:sc animated:YES];
            [sc release];
        }
            break;
        case MenuButtonTypeOfflineGuess:
        {
            [self showActivityWithText:NSLS(@"kLoading")];
            [[DrawDataService defaultService] matchDraw:self];
        }
            break;
        case MenuButtonTypeFriendPlay:
        {
            FriendRoomController *frc = [[FriendRoomController alloc] init];
            [self.navigationController pushViewController:frc animated:YES];
            [frc release];
            [_menuPanel setMenuBadge:0 forMenuType:type];
        }
            break;
        case MenuButtonTypeTimeline:
        {
//            FeedController *fc = [[FeedController alloc] init];
//            [self.navigationController pushViewController:fc animated:YES];
//            [fc release];
//            [_menuPanel setMenuBadge:0 forMenuType:type];
            MyFeedController *myFeedController = [[MyFeedController alloc] init];
            [self.navigationController pushViewController:myFeedController animated:YES];
            [myFeedController release];
            [_menuPanel setMenuBadge:0 forMenuType:type];
        }
            break;
        case MenuButtonTypeShop:
        {
            VendingController* vc = [[VendingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
            break;
        case MenuButtonTypeContest:
        {
            ContestController *cc = [[ContestController alloc] init];
            [self.navigationController pushViewController:cc animated:YES];
            [cc release];
        }
            break;
        case MenuButtonTypeTop:
        {
            HotController *hc = [[HotController alloc] init];
            [self.navigationController pushViewController:hc animated:YES];
            [hc release];
        }
            break;
            
        
        //For Bottom Menus
        case MenuButtonTypeSettings:
        {
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            
            break;
        case MenuButtonTypeOpus:
        {   
            ShareController* share = [[ShareController alloc] init ];
            [self.navigationController pushViewController:share animated:YES];
            [share release];
            
        }
            break;
        case MenuButtonTypeFriend:
        {
            MyFriendsController *mfc = [[MyFriendsController alloc] init];
            [self.navigationController pushViewController:mfc animated:YES];
            [mfc release];
            [_bottomMenuPanel setMenuBadge:0 forMenuType:MenuButtonTypeFriend];
        }
            break;
        case MenuButtonTypeChat:
        {
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            
            [_bottomMenuPanel setMenuBadge:0 forMenuType:type];
            
        }
            break;
        case MenuButtonTypeFeedback:
        {
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
            
        }
            break;
        case MenuButtonTypeCheckIn:

        default:
            break;
    }

}

@end
