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
#import "MyFriendsController.h"
#import "ChatController.h"
#import "FriendRoomController.h"
#import "CommonMessageCenter.h"
#import "SearchRoomController.h"
#import "AudioManager.h"
#import "MusicItemManager.h"

@implementation HomeController
@synthesize startButton = _startButton;
@synthesize shopButton = _shopButton;
@synthesize shareButton = _shareButton;
@synthesize checkinButton = _checkinButton;
@synthesize settingButton = _settingButton;
@synthesize feedbackButton = _feedbackButton;
@synthesize settingsLabel = _settingsLabel;
@synthesize feedbackLabel = _feedbackLabel;
@synthesize playWithFriendButton = _playWithFriendButton;

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
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
//    [self setBackgroundImageName:@"home.png"];

    [super viewDidLoad];
    //init background music    
    [self playBackgroundMusic];

    // setup button images
    UIImage* buttonImage = [[ShareImageManager defaultManager] woodImage];
    [self.startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.shopButton  setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.playWithFriendButton  setBackgroundImage:buttonImage forState:UIControlStateNormal];
    // set text
    [self.startButton setTitle:NSLS(@"kStart") forState:UIControlStateNormal];
    [self.shareButton setTitle:NSLS(@"kHomeShare") forState:UIControlStateNormal];
    [self.shopButton  setTitle:NSLS(@"kShop") forState:UIControlStateNormal];
    [self.checkinButton setTitle:NSLS(@"kCheckin") forState:UIControlStateNormal];
    [self.playWithFriendButton setTitle:NSLS(@"kPlayWithFriend") forState:UIControlStateNormal];

    
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
    self.settingsLabel.text = NSLS(@"kSettings");

    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
    
    // Start Game Service And Set User Id
    [[DrawGameService defaultService] setHomeDelegate:self];
    [[DrawGameService defaultService] setUserId:[[UserManager defaultManager] userId]];
    [[DrawGameService defaultService] setNickName:[[UserManager defaultManager] nickName]];    
    [[DrawGameService defaultService] setAvatar:[[UserManager defaultManager] avatarURL]];    
    
//    [[DrawGameService defaultService] connectServer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [[RouterService defaultService] fetchServerListAtBackground];
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
    [self setStartButton:nil];
    [self setShopButton:nil];
    [self setShareButton:nil];
    [self setCheckinButton:nil];
    [self setSettingButton:nil];
    [self setFeedbackButton:nil];
    [self setSettingsLabel:nil];
    [self setFeedbackLabel:nil];
    [self setPlayWithFriendButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)playBackgroundMusic
{
    MusicItemManager* musicManager = [MusicItemManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:musicManager.currentMusicItem.localPath];
    AudioManager *audioManager = [AudioManager defaultManager];
    
    //stop old music
    [audioManager backgroundMusicStop];
    //start new music
    [audioManager setBackGroundMusicWithURL:url];
    [audioManager backgroundMusicStart];

}
- (IBAction)clickStart:(id)sender
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
                                    guessDiffLevel:[ConfigManager guessDifficultLevel]];    
    }
    else{
        
        [self showActivityWithText:NSLS(@"kConnectingServer")];        
        [[RouterService defaultService] tryFetchServerList:self];        
    }
}

- (IBAction)clickPlayWithFriend:(id)sender {
    FriendRoomController *frc = [[FriendRoomController alloc] init];
    [self.navigationController pushViewController:frc animated:YES];
    [frc release];
}

- (IBAction)clickShop:(id)sender {
//    ShopMainController *sc = [[ShopMainController alloc] init];
//    [self.navigationController pushViewController:sc animated:YES];
//    [sc release];
    
    ItemShopController *ic = [ItemShopController instance];
    [self.navigationController pushViewController:ic animated:YES];

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
                                                     deelegate:self];    
    
    [dialog showInView:self.view];
}

- (IBAction)clickSettings:(id)sender
{
    UserSettingController *settings = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}

- (IBAction)clickShare:(id)sender
{
    ShareController* share = [[ShareController alloc] init ];
    [self.navigationController pushViewController:share animated:YES];
    [share release];
}


- (void)didBroken
{
    _isTryJoinGame = NO;
    PPDebug(@"<didBroken>");
    [self hideActivity];
    [self popupUnhappyMessage:NSLS(@"kNetworkFailure") title:@""];
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
                                    guessDiffLevel:[ConfigManager guessDifficultLevel]];    
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
//        [self hideActivity];
//        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"Message") message:NSLS(@"kNoServerAvailable") style:CommonDialogStyleSingleButton deelegate:nil];
//        [dialog showInView:self.view];
//        return;
        
        address = [server address];
        port = [server.port intValue];            
    }

    [[DrawGameService defaultService] setServerAddress:address];
    [[DrawGameService defaultService] setServerPort:port];    
//    [[DrawGameService defaultService] setServerAddress:@"192.168.1.101"];
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
    for(UIViewController *vc in superController.navigationController.childViewControllers)
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
        [superController.navigationController popToViewController:viewController animated:YES];        
        return;
    }
    [superController.navigationController popToViewController:[HomeController defaultInstance] animated:YES];
}

- (void)dealloc {
    [_startButton release];
    [_shopButton release];
    [_shareButton release];
    [_checkinButton release];
    [_settingButton release];
    [_feedbackButton release];
    [_settingsLabel release];
    [_feedbackLabel release];
    [_playWithFriendButton release];
    [super dealloc];
}

- (IBAction)clickFriend:(id)sender
{
    MyFriendsController *myFriends = [[MyFriendsController alloc] init];
    [self.navigationController pushViewController:myFriends animated:YES];
    [myFriends release];
//    [[CommonMessageCenter defaultCenter] postMessageWithText:@"" delayTime:rand()%4];
}

@end
