//
//  HomeController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
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
#import "DeviceDetection.h"
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

#import "OfflineDrawViewController.h"
#import "OfflineGuessDrawController.h"
#import "SelectWordController.h"
#import "FeedController.h"

#import "ChatListController.h"
#import "LevelService.h"
#import "LmWallService.h"
#import "AdService.h"
#import "VendingController.h"
#import "RecommendedAppsController.h"

@interface HomeController()

- (void)playBackgroundMusic;
- (void)enterNextControllerWityType:(NotificationType) type;
- (void)updateBadge:(UIButton *)badgeButton value:(int )value;
- (BOOL)isRegistered;
- (void)toRegister;

@end

@implementation HomeController

@synthesize adView = _adView;
@synthesize recommendButton = _recommendButton;
@synthesize startButton = _startButton;
@synthesize shopButton = _shopButton;
@synthesize shareButton = _shareButton;
@synthesize checkinButton = _checkinButton;
@synthesize settingButton = _settingButton;
@synthesize feedbackButton = _feedbackButton;
@synthesize playWithFriendButton = _playWithFriendButton;
//@synthesize hasRemoveNotification = _hasRemoveNotification;
@synthesize guessButton = _guessButton;
@synthesize drawButton = _drawButton;
@synthesize notificationType = _notificationType;
@synthesize settingLabel = _settingLabel;
@synthesize shareLabel = _shareLabel;
@synthesize signLabel = _signLabel;
@synthesize friendLabel = _friendLabel;
@synthesize chatLabel = _chatLabel;
@synthesize feedbackLabel = _feedbackLabel;
@synthesize startLabel = _startLabel;
@synthesize guessLabel = _guessLabel;
@synthesize drawLabel = _drawLabel;
@synthesize friendPlayLabel = _friendPlayLabel;
@synthesize freeCoinLabel = _freeCoinLabel;
@synthesize feedLabel = _feedLabel;
@synthesize versionLabel = _versionLabel;
@synthesize feedBadge = _feedBadge;
@synthesize fanBadge = _fanBadge;
@synthesize messageBadge = _messageBadge;
@synthesize roomBadge = _roomBadge;
@synthesize homeScrollView = _homeScrollView;

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

- (void)viewDidLoad
{        
    self.adView = [[AdService defaultService] createAdInView:self                  
                                                       frame:CGRectMake(0, 0, 320, 50) 
                                                   iPadFrame:CGRectMake(65, 800, 320, 50)
                                                     useLmAd:YES];
    
    [super viewDidLoad];    
    [self playBackgroundMusic];
    
    // set text
    [self.startLabel setText:NSLS(@"kStart")];
    [self.shareLabel setText:NSLS(@"kHomeShare")];
    [self.freeCoinLabel  setText:NSLS(@"kShop")];
    [self.signLabel setText:NSLS(@"kCheckin")];
    [self.friendPlayLabel setText:NSLS(@"kPlayWithFriend")];
    [self.friendLabel setText:NSLS(@"kFriend")];
    [self.chatLabel setText:NSLS(@"kChat")];
    [self.drawLabel setText:NSLS(@"kDrawOnly")];
    [self.guessLabel setText:NSLS(@"kGuessOnly")];
    [self.feedLabel setText:NSLS(@"kFeed")];
    [self.settingLabel setText:NSLS(@"kSettings")];
    [self.feedbackLabel setText:NSLS(@"kFeedback")];
    [self.recommendButton setTitle:NSLS(@"kRecommend") forState:UIControlStateNormal];
    
    self.homeScrollView.contentSize = CGSizeMake(self.homeScrollView.frame.size.width, self.homeScrollView.frame.size.height+1);
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];  
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    [self.versionLabel setText:[NSString stringWithFormat:@"Ver %@", currentVersion]];

    
    int size;
    if ([[LocaleUtils getLanguageCode] isEqualToString:@"zh-Hans"]){
        size = 15;
    }
    else{
        size = 12;
    }

    if ([DeviceDetection isIPAD]){
        self.checkinButton.titleLabel.font = [UIFont boldSystemFontOfSize:size*2];
    }
    else{
        self.checkinButton.titleLabel.font = [UIFont boldSystemFontOfSize:size];        
    }
    
    self.feedbackLabel.text = NSLS(@"kFeedback");
    self.settingLabel.text = NSLS(@"kSettings");

    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
    
    // Start Game Service And Set User Id
    [[DrawGameService defaultService] setHomeDelegate:self];
    [[DrawGameService defaultService] setUserId:[[UserManager defaultManager] userId]];
    [[DrawGameService defaultService] setNickName:[[UserManager defaultManager] nickName]];    
    [[DrawGameService defaultService] setAvatar:[[UserManager defaultManager] avatarURL]];    
    
    if ([ConfigManager isInReviewVersion] == NO && ([LocaleUtils isChina] || [LocaleUtils isOtherChina])){
        //[self.shopButton setTitle:NSLS(@"kFreeGetCoins") forState:UIControlStateNormal];
    }
    [self enterNextControllerWityType:self.notificationType];
    
    UIImage *badgeImage = [[ShareImageManager defaultManager] toolNumberImage];
    [self.feedBadge setBackgroundImage:badgeImage forState:UIControlStateNormal];
    [self.messageBadge setBackgroundImage:badgeImage forState:UIControlStateNormal];
    [self.fanBadge setBackgroundImage:badgeImage forState:UIControlStateNormal];
    [self.roomBadge setBackgroundImage:badgeImage forState:UIControlStateNormal]; 
}

- (void)viewDidAppear:(BOOL)animated
{    
    
    [[UserService defaultService] getStatistic:self];   
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[DrawGameService defaultService] registerObserver:self];
    [super viewDidAppear:animated];

    if (self.adView == nil){    
        self.adView = [[AdService defaultService] createAdInView:self                  
                                                           frame:CGRectMake(0, 0, 320, 50) 
                                                       iPadFrame:CGRectMake(65, 800, 320, 50)
                                                         useLmAd:YES];
    }
    else{
        if ([[AdService defaultService] isShowAd] == NO){
            [_adView removeFromSuperview];
            [self.recommendButton setFrame:CGRectMake(65, 792, 66, 66)];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{

    [self hideActivity];
    [[DrawGameService defaultService] unregisterObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];    
    
    [self setStartButton:nil];
    [self setShopButton:nil];
    [self setShareButton:nil];
    [self setCheckinButton:nil];
    [self setSettingButton:nil];
    [self setFeedbackButton:nil];
    [self setPlayWithFriendButton:nil];
    [self setGuessButton:nil];
    [self setDrawButton:nil];
    [self setSettingLabel:nil];
    [self setShareLabel:nil];
    [self setSignLabel:nil];
    [self setFriendLabel:nil];
    [self setChatLabel:nil];
    [self setFeedbackLabel:nil];
    [self setStartLabel:nil];
    [self setGuessLabel:nil];
    [self setDrawLabel:nil];
    [self setFriendPlayLabel:nil];
    [self setFreeCoinLabel:nil];
    [self setFeedLabel:nil];
    [self setVersionLabel:nil];
    [self setFeedBadge:nil];
    [self setFanBadge:nil];
    [self setMessageBadge:nil];
    [self setRoomBadge:nil];
    [self setHomeScrollView:nil];
    [self setRecommendButton:nil];
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
            [self clickFeedButton:nil];
            break;
        case NotificationTypeRoom:
            [self clickPlayWithFriend:nil];
            break;
        case NotificationTypeMessage:
            [self clickChatButton:nil];
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
- (IBAction)clickStart:(id)sender
{
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        
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
    
}

- (IBAction)clickPlayWithFriend:(id)sender {
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        FriendRoomController *frc = [[FriendRoomController alloc] init];
        [self.navigationController pushViewController:frc animated:YES];
        [frc release];
        [self updateBadge:self.roomBadge value:0];
    }
}

- (IBAction)clickShop:(id)sender {
//    ShopMainController *sc = [[ShopMainController alloc] init];
//    [self.navigationController pushViewController:sc animated:YES];
//    [sc release];
    
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
//        ItemShopController *ic = [ItemShopController instance];
//        [self.navigationController pushViewController:ic animated:YES];
        VendingController* vc = [[VendingController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
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

- (IBAction)clickFeedback:(id)sender
{
    FeedbackController* feedBack = [[FeedbackController alloc] init];
    [self.navigationController pushViewController:feedBack animated:YES];
    [feedBack release];
}

- (IBAction)clickCheckIn:(id)sender
{
    int coins = [[AccountService defaultService] checkIn];
    NSString* message = nil;
    if (coins > 0){        
        message = [NSString stringWithFormat:NSLS(@"kCheckInMessage"), coins];
    }
    else{
        message = NSLS(@"kCheckInAlreadyToday");
    }
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCheckInTitle") 
                                                       message:message
                                                         style:CommonDialogStyleSingleButton 
                                                     delegate:self];    
    
    [dialog showInView:self.view];
}

- (IBAction)clickSettings:(id)sender
{
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        UserSettingController *settings = [[UserSettingController alloc] init];
        [self.navigationController pushViewController:settings animated:YES];
        [settings release];
    }
}

- (IBAction)clickShare:(id)sender
{
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        ShareController* share = [[ShareController alloc] init ];
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
    [_startButton release];
    [_shopButton release];
    [_shareButton release];
    [_checkinButton release];
    [_settingButton release];
    [_feedbackButton release];
    [_playWithFriendButton release];
    [_guessButton release];
    [_drawButton release];
    [_settingLabel release];
    [_shareLabel release];
    [_signLabel release];
    [_friendLabel release];
    [_chatLabel release];
    [_feedbackLabel release];
    [_startLabel release];
    [_guessLabel release];
    [_drawLabel release];
    [_friendPlayLabel release];
    [_freeCoinLabel release];
    [_feedLabel release];
    [_versionLabel release];
    [_feedBadge release];
    [_fanBadge release];
    [_messageBadge release];
    [_roomBadge release];
    [_homeScrollView release];
    [_recommendButton release];
    [super dealloc];
}

- (IBAction)clickDrawButton:(id)sender {
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
        [self.navigationController pushViewController:sc animated:YES];
        [sc release];
    }
}

- (IBAction)clickGuessButton:(id)sender {
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        [self showActivityWithText:NSLS(@"kLoading")];
        [[DrawDataService defaultService] matchDraw:self];
    }
}

- (IBAction)clickFeedButton:(id)sender {
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        FeedController *fc = [[FeedController alloc] init];
        [self.navigationController pushViewController:fc animated:YES];
        [fc release];
        [self updateBadge:_feedBadge value:0];
    }
}

- (IBAction)clickFriendsButton:(id)sender
{
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        MyFriendsController *mfc = [[MyFriendsController alloc] init];
        [self.navigationController pushViewController:mfc animated:YES];
        [mfc release];
        [self updateBadge:_fanBadge value:0];
    }
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
- (void)didMatchDraw:(Feed *)feed result:(int)resultCode
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

- (IBAction)clickChatButton:(id)sender {
    if ([self isRegistered] == NO) {
        [self toRegister];
    } else {
        ChatListController *controller = [[ChatListController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        [self updateBadge:_messageBadge value:0];
    }
}


- (void)updateBadge:(UIButton *)badgeButton value:(int )value
{
    if (value <= 0) {
        badgeButton.hidden = YES;
    }else{
        badgeButton.hidden = NO;
        if (value > 99) {
            [badgeButton setTitle:@"N" forState:UIControlStateNormal];
        }else{
            [badgeButton setTitle:[NSString stringWithInt:value] forState:UIControlStateNormal];
        }
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
        [self updateBadge:self.feedBadge value:feedCount];
        [self updateBadge:self.messageBadge value:messageCount];
        [self updateBadge:self.fanBadge value:fanCount];
        [self updateBadge:self.roomBadge value:roomCount];
    }
}



- (void)updateBadgeWithUserInfo:(NSDictionary *)userInfo;
{
    int badge = [NotificationManager feedBadge:userInfo];
    [self updateBadge:self.feedBadge value:badge];
    
    badge = [NotificationManager fanBadge:userInfo];
    [self updateBadge:self.fanBadge value:badge];
    
    badge = [NotificationManager messageBadge:userInfo];
    [self updateBadge:self.messageBadge value:badge];
    
    badge = [NotificationManager roomBadge:userInfo];
    [self updateBadge:self.roomBadge value:badge];

}
@end
