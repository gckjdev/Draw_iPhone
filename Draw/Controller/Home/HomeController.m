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


#import "OfflineGuessDrawController.h"
#import "SelectWordController.h"


#import "ChatListController.h"
#import "LevelService.h"
#import "LmWallService.h"
#import "AdService.h"
#import "VendingController.h"
#import "RecommendedAppsController.h"

#import "FacetimeMainController.h"
#import "DiceRoomListController.h"
#import "DiceGamePlayController.h"

#import "DiceGameService.h"
#import "DiceNotification.h"

#import "EntryController.h"
//#import "BoardView.h"
#import "BoardPanel.h"
#import "MenuPanel.h"
#import "BottomMenuPanel.h"
#import "BoardManager.h"

@interface HomeController()

- (void)playBackgroundMusic;
- (void)enterNextControllerWityType:(NotificationType) type;
- (BOOL)isRegistered;
- (void)toRegister;

@end

@implementation HomeController
@synthesize facetimeButton = _facetimeButton;
@synthesize diceButton = _diceButton;

@synthesize adView = _adView;
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
    
    
    
    [[BoardService defaultService] getBoardsWithDelegate:self];
    
//    self.facetimeButton.hidden = YES;
//    self.diceButton.hidden = YES;
    if ([ConfigManager isShowRecommendApp]){
        self.recommendButton.hidden = NO;
    }
    else{
        self.recommendButton.hidden = YES;
    }
    
    
//    self.adView = [[AdService defaultService] createAdInView:self                  
//                                                       frame:CGRectMake(0, 0, 320, 50) 
//                                                   iPadFrame:CGRectMake(43, 60, 320, 50)
//                                                     useLmAd:YES];
    
    
    
    [super viewDidLoad];    
    
    self.menuPanel = [MenuPanel menuPanelWithController:self];
    
    self.menuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 686) : CGPointMake(160, 306);
    
    [self.view insertSubview:self.menuPanel atIndex:0];

    
    self.bottomMenuPanel = [BottomMenuPanel panelWithController:self];
    
    self.bottomMenuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 961) : CGPointMake(160, 438);
    
    [self.view addSubview:_bottomMenuPanel];

    
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

- (void)registerDiceGameNotificationWithName:(NSString *)name 
                                  usingBlock:(void (^)(NSNotification *note))block
{
    PPDebug(@"<%@> name", [self description]);         
    
    [self registerNotificationWithName:name 
                                object:nil 
                                 queue:[NSOperationQueue mainQueue] 
                            usingBlock:block];
}

- (void)registerDiceGameNotification
{
    [self registerDiceGameNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE usingBlock:^(NSNotification *note) {
        PPDebug(@"<HomeController> NOTIFICATION_JOIN_GAME_RESPONSE"); 
        if(_isJoiningDice) {
            DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
            [self.navigationController pushViewController:controller animated:YES];
            _isJoiningDice = NO; 
        }
    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_ROOM usingBlock:^(NSNotification *note) {
        PPDebug(@"<HomeController> NOTIFICATION_ROOM");
    }];
    
}

- (void)unregisterDiceGameNotification
{        
    [self unregisterAllNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self registerDiceGameNotification];
    
    [[UserService defaultService] getStatistic:self];   
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[DrawGameService defaultService] registerObserver:self];
    [super viewDidAppear:animated];

//    if (self.adView == nil){    
//        self.adView = [[AdService defaultService] createAdInView:self                  
//                                                           frame:CGRectMake(0, 0, 320, 50) 
//                                                       iPadFrame:CGRectMake(65, 800, 320, 50)
//                                                         useLmAd:YES];
//    }
//    else{
//        if ([[AdService defaultService] isShowAd] == NO){
//            [_adView removeFromSuperview];
//            
//            if ([DeviceDetection isIPAD]){
//                [self.recommendButton setFrame:CGRectMake(65, self.recommendButton.frame.origin.y, self.recommendButton.frame.size.width, self.recommendButton.frame.size.height)];
//            }
//        }
//    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterDiceGameNotification];
    
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
    [self setDiceButton:nil];
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
            [self.menuPanel didClickMenuButton:[self.menuPanel getMenuButtonByType:MenuButtonTypeTimeline]];
            break;
        case NotificationTypeRoom:
            [self.menuPanel didClickMenuButton:[self.menuPanel getMenuButtonByType:MenuButtonTypeFriendPlay]];
            break;
        case NotificationTypeMessage:
            [self.bottomMenuPanel didClickMenuButton:[self.bottomMenuPanel getMenuButtonByType:MenuButtonTypeChat]];
            
            break;
        default:
            break;
    }
}

- (void)playBackgroundMusic
{
    MusicItemManager* musicManager = [MusicItemManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:musicManager.currentMusicItem.localPath];
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
    PPRelease(_diceButton);
    PPRelease(_menuPanel);
    PPRelease(_bottomMenuPanel);
    PPRelease(_adView);
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

- (IBAction)clickAnnounce:(id)sender {
    EntryController  *ec = [[EntryController alloc] init];
    [self.navigationController pushViewController:ec animated:YES];
    [ec release];
}

- (IBAction)clickDice:(id)sender
{
//    DiceRoomListController *controller = [[[DiceRoomListController alloc] init] autorelease];
//    DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
//    [self.navigationController pushViewController:controller animated:YES];
    
    _isTryJoinGame = YES;
    
//    [[DiceGameService defaultService] setServerAddress:@"192.168.1.198"];

//    [[DiceGameService defaultService] setServerAddress:@"192.168.1.7"];
//    [[DiceGameService defaultService] setServerPort:8018];
    
    [[DiceGameService defaultService] setServerAddress:@"106.187.89.232"];
//    [[DiceGameService defaultService] setServerPort:8080];
    [[DiceGameService defaultService] setServerPort:8018];
    
    [[DiceGameService defaultService] connectServer:self];
    _isJoiningDice = YES;
}
- (IBAction)room:(id)sender
{
    DiceRoomListController* vc = [[[DiceRoomListController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickFacetime:(id)sender
{
    FacetimeMainController* vc = [[[FacetimeMainController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
    
    [[DiceGameService defaultService] joinGameRequest];
}


#define BOARD_PANEL_TAG 201208241
#pragma mark - board service delegate

NSTimeInterval interval = 1;
BOOL hasGetLocalBoardList = NO;
- (void)updateBoardList:(NSTimer *)theTimer
{
    interval *= 2;
    if (interval < NSTimeIntervalSince1970) {
        PPDebug(@"<updateBoardList> timeinterval = %f", interval);
        [[BoardService defaultService] getBoardsWithDelegate:self];        
    }
}

- (void)didGetBoards:(NSArray *)boards 
          resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        if ([boards count] != 0) {
            [[self.view viewWithTag:BOARD_PANEL_TAG] removeFromSuperview];
            BoardPanel *boardPanel = [BoardPanel boardPanelWithController:self];
            [boardPanel setBoardList:boards];
            boardPanel.tag = BOARD_PANEL_TAG;
            [self.view addSubview:boardPanel];
            [[BoardManager defaultManager] saveBoardList:boards];
        }
    }else {
        //start timer to fetch. use the local
        if(!hasGetLocalBoardList){
            NSArray * boardList = [[BoardManager defaultManager] getLocalBoardList];
            hasGetLocalBoardList = YES;
            if ([boardList count] != 0) {
                [[self.view viewWithTag:BOARD_PANEL_TAG] removeFromSuperview];
                BoardPanel *boardPanel = [BoardPanel boardPanelWithController:self];
                boardPanel.tag = BOARD_PANEL_TAG;
                [boardPanel setBoardList:boardList];
                [self.view addSubview:boardPanel];            
            }
        }
        [NSTimer scheduledTimerWithTimeInterval:interval target:self 
                                       selector:@selector(updateBoardList:)
                                       userInfo:nil
                                        repeats:NO];
        //start timer to fetch. use the local
    }
}


@end
