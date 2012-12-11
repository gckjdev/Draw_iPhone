//
//  DrawHomeViewController.m
//  Draw
//
//  Created by gamy on 12-12-10.
//
//

#import "DrawHomeViewController.h"
#import "StringUtil.h"
#import "SelectWordController.h"
#import "ContestController.h"
#import "UserManager.h"
#import "LevelService.h"
#import "MyFeedController.h"
#import "BBSBoardController.h"
#import "HotController.h"
#import "UserSettingController.h"
#import "ShareController.h"
#import "FriendController.h"
#import "ChatListController.h"
#import "FeedbackController.h"
#import "VendingController.h"


@interface DrawHomeViewController ()
{
    BOOL _isTryJoinGame;
}
@end

DrawHomeViewController *_staticDrawHomeViewController = nil;

@implementation DrawHomeViewController

+ (id)defaultInstance
{
    if (_staticDrawHomeViewController == nil) {
        _staticDrawHomeViewController = [[DrawHomeViewController alloc] init];
    }
    return _staticDrawHomeViewController;
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
    PPDebug(@"DrawHomeViewController view did load");
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Panel delegate

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    UserManager *_userManager = [UserManager defaultManager];
    PPDebug(@"<homeMainMenuPanel>, click type = %d", type);
    switch (type) {
        case HomeMenuTypeDrawGame:
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
        case HomeMenuTypeDrawDraw:
        {
            SelectWordController *sc = [[SelectWordController alloc] initWithType:OfflineDraw];
            [self.navigationController pushViewController:sc animated:YES];
            [sc release];
        }
            break;
        case HomeMenuTypeDrawGuess:
        {
            [self showActivityWithText:NSLS(@"kLoading")];
            [[DrawDataService defaultService] matchDraw:self];
        }
            break;
            
        case HomeMenuTypeDrawTimeline:
        {
            
            //            MyFeedController *frc = [[MyFeedController alloc] init];
            //            [self.navigationController pushViewController:frc animated:YES];
            //            [frc release];
            
            [MyFeedController enterControllerWithIndex:0 fromController:self animated:YES];
            [menu updateBadge:0];
        }
            break;
        case HomeMenuTypeDrawShop:
        {
            VendingController* vc = [[VendingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
            break;
        case HomeMenuTypeDrawContest:
        {
            ContestController *cc = [[ContestController alloc] init];
            [self.navigationController pushViewController:cc animated:YES];
            [cc release];
        }
            break;
        case HomeMenuTypeDrawBBS:{
            BBSBoardController *bbs = [[BBSBoardController alloc] init];
            [self.navigationController pushViewController:bbs animated:YES];
            [bbs release];

        }
            break;
        case HomeMenuTypeDrawRank:
        {
            HotController *hc = [[HotController alloc] init];
            [self.navigationController pushViewController:hc animated:YES];
            [hc release];
        }
            break;
            
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
        {
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            
            break;
        case HomeMenuTypeDrawOpus:
        {
            ShareController* share = [[ShareController alloc] init ];
            [self.navigationController pushViewController:share animated:YES];
            [share release];
            
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

#pragma mark Router Service Delegate

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
    
    [[DrawGameService defaultService] connectServer:self];
    _isTryJoinGame = YES;
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
        DrawHomeViewController *drawHome = [DrawHomeViewController defaultInstance];
        [viewController.navigationController popToViewController:drawHome animated:NO];
        [OfflineGuessDrawController startOfflineGuess:feed fromController:drawHome];
    }
    
}
@end
