//
//  ZJHHomeViewController.m
//  Draw
//
//  Created by gamy on 12-12-10.
//
//

#import "ZJHHomeViewController.h"
#import "StringUtil.h"
#import "UserManager.h"
#import "LevelService.h"
#import "MyFeedController.h"
#import "BBSBoardController.h"
#import "UserSettingController.h"

#import "FriendController.h"
#import "ChatListController.h"
#import "FeedbackController.h"
#import "VendingController.h"

#import "HelpView.h"
#import "ZJHRoomListController.h"
#import "ZJHGameService.h"
#import "NotificationName.h"
#import "ZJHGameController.h"
#import "UserManager+DiceUserManager.h"
#import "RegisterUserController.h"

@interface ZJHHomeViewController ()
{
    ZJHGameService *_gameService;
    BOOL _isConnecting;
}
@end

ZJHHomeViewController *_staticZJHHomeViewController = nil;

@implementation ZJHHomeViewController

+ (id)defaultInstance
{
    if (_staticZJHHomeViewController == nil) {
        _staticZJHHomeViewController = [[ZJHHomeViewController alloc] init];
    }
    return _staticZJHHomeViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _gameService  = [ZJHGameService defaultService];
    PPDebug(@"ZJHHomeViewController view did load");
    // Do any additional setup after loading the view from its nib.
    
    [self registerNetworkDisconnectedNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerJoinGameResponseNotification];
    [self registerNetworkConnectedNotification];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterJoinGameResponseNotification];
    [self unregisterNetworkConnectedNotification];
    [super viewDidDisappear:animated];
}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Panel delegate

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

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    
    switch (type) {
        case HomeMenuTypeZJHHelp: {
            HelpView *view = [HelpView createHelpView:@"ZJHHelpView"];
            [view showInView:self.view];
            break;
        }
        case HomeMenuTypeZJHStart: {
            
            if (_isConnecting) {
                return;
            }
            
            [self showActivityWithText:NSLS(@"kConnectingServer")];
            [[ZJHGameService defaultService] setRule:PBZJHRuleTypeNormal];
            [[ZJHGameService defaultService] connectServer];

            break;
        }
        case HomeMenuTypeDrawBBS: {
            BBSBoardController *bbs = [[BBSBoardController alloc] init];
            [self.navigationController pushViewController:bbs animated:YES
             ];
            PPRelease(bbs);
            break;
        }
        case HomeMenuTypeZJHRichSite: {
            [_gameService setRule:PBZJHRuleTypeRich];
            ZJHRoomListController* vc = [[[ZJHRoomListController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        } 
        case HomeMenuTypeZJHNormalSite: {
            [_gameService setRule:PBZJHRuleTypeNormal];
            ZJHRoomListController* vc = [[[ZJHRoomListController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        } 
        case HomeMenuTypeZJHVSSite: {
            [_gameService setRule:PBZJHRuleTypeDual];
            ZJHRoomListController* vc = [[[ZJHRoomListController alloc] init] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    PPDebug(@"<homeBottomMenuPanel>, click type = %d", type);
    
    switch (type) {
            //For Bottom Menus
        case HomeMenuTypeDrawSetting:
        case HomeMenuTypeDrawMe:
        {
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            
            break;
        case HomeMenuTypeDrawFriend:
        {
            FriendController *mfc = [[FriendController alloc] init];
            [self.navigationController pushViewController:mfc animated:YES];
            [mfc release];
            [menu updateBadge:0];
        }
            break;
        case HomeMenuTypeDrawMessage:
        {
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            [menu updateBadge:0];
            
        }
            break;
        case HomeMenuTypeDrawMore:
        {
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)handleJoinGameResponse
{    
    [self hideActivity];
        
    ZJHGameController* vc = nil;
    NSString *xibName = nil;
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            xibName = (_gameService.rule == PBZJHRuleTypeDual) ? @"ZJHGameController_dual~ipad" : @"ZJHGameController~ipad";
            vc = [[[ZJHGameController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            xibName = (_gameService.rule == PBZJHRuleTypeDual) ? @"ZJHGameController_dual~ip5" : @"ZJHGameController~ip5";
            vc = [[[ZJHGameController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        case DEVICE_SCREEN_IPHONE:
            xibName = (_gameService.rule == PBZJHRuleTypeDual) ? @"ZJHGameController_dual" : @"ZJHGameController";
            vc = [[[ZJHGameController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (void)handleConnectedResponse
{
    PPDebug(@"%@ <didConnected>", [self description]);
    _isConnecting = NO;
    
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kJoiningGame")];
    [_gameService joinGameRequestWithCustomUser:[[UserManager defaultManager] toDicePBGameUser]];
}

- (void)handleDisconnectWithError:(NSError *)error
{
    PPDebug(@"diconnect error: %@", [error description]);
    
    _isConnecting = NO;
    [self hideActivity];
    
    if (error != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    }
}




@end
