//
//  CommonRoomListController.m
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "CommonRoomListController.h"
#import "CommonGameNetworkClient.h"
#import "NotificationName.h"
#import "GameMessage.pb.h"
#import "GameConstants.pb.h"
#import "CommonMessageCenter.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "CoinShopController.h"
#import "LmWallService.h"
#import "CommonRoomListCell.h"
#import "UserManager.h"
#import "CommonUserInfoView.h"
#import "MyFriend.h"
#import "PPViewController+StarryLoadingView.h"
#import "CommonDialog.h"
#import "GameApp.h"


#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"
#define ROOMS_COUNT_PER_PAGE  20

#define REFRESH_ROOMS_TIME_INTERVAL 2

#define CREATE_ROOM_DIALOG_TAG  120120824
#define ENTER_ROOM_DIALOG_TAG   220120824

@interface CommonRoomListController ()

@end

@implementation CommonRoomListController
@synthesize currentSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _searchView.disappearDelegate = nil;
    [_backgroundImageView release];
    [self clearRefreshRoomsTimer];
    PPRelease(_currentSession);
    [super dealloc];
}

- (PrejoinGameErrorCode)handlePrejoinGameCheck
{
    PPDebug(@"<CommonRoomListController> handlePrejoinGameCheck method not implement");
    return canJoinGame;
}
- (PrejoinGameErrorCode)handlePrejoinGameCheckBySessionId:(int)sessionId
{
    PPDebug(@"<CommonRoomListController> handlePrejoinGameCheck method not implement");
    return canJoinGame;
}

- (void)handleJoinGameError:(PrejoinGameErrorCode)errorCode
{
    PPDebug(@"<CommonRoomListController> didJoinGameError: method not implement");
}

- (void)handleUpdateRoomList
{
    PPDebug(@"<CommonRoomListController> updateRoomList method not implement");
}

- (void)handleDidJoinGame
{
    PPDebug(@"<CommonRoomListController> handleDidJoinGame method not implement");
}

- (CGPoint)getSearchViewPosition
{
    PPDebug(@"<CommonRoomListController> getSearchViewPosition method not implement");
    return CGPointMake(0, 0);
}

- (void)handleUpdateOnlineUserCount
{
    PPDebug(@"<CommonRoomListController> handleUpdateOnlineUserCount method not implement");
}

- (void)handleDidConnectServer
{
    PPDebug(@"<CommonRoomListController> handleDidConnectServer method not implement");
}

- (void)handleNoRoomMessage
{
    PPDebug(@"<CommonRoomListController> handleNoRoomMessage method not implement");

}

- (void)checkAndJoinGame:(int)sessionId
{
    if ([self handlePrejoinGameCheckBySessionId:sessionId] == canJoinGame) {
        _isJoiningGame = YES;
        [_gameService joinGameRequest:sessionId];
    } else {
        [self handleJoinGameError:[self handlePrejoinGameCheck]];
    }
}

- (void)checkAndJoinGame
{
    if ([self handlePrejoinGameCheck] == canJoinGame) {
        [_gameService joinGameRequest];
        [self showActivityWithText:NSLS(@"kJoiningGame")];
    } else {
        [self handleJoinGameError:[self handlePrejoinGameCheck]];
    }
}

- (void)createRoomWithName:(NSString*)targetText
                  password:(NSString*)password
{
    _isJoiningGame = YES;
    [self showActivityWithText:NSLS(@"kCreatingRoom")];
    [_gameService createRoomWithName:targetText password:password];
}

- (void)refreshRooms:(id)sender
{
    [_gameService getRoomList:0 count:ROOMS_COUNT_PER_PAGE];
//    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}

- (void)clearRefreshRoomsTimer
{
    if (_refreshRoomTimer) {
        if ([_refreshRoomTimer isValid]) {
            [_refreshRoomTimer invalidate];
        }
        [_refreshRoomTimer release];
        _refreshRoomTimer = nil;
    }
}

- (void)startRefreshRoomsTimer
{
    [self clearRefreshRoomsTimer];
    _refreshRoomTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_ROOMS_TIME_INTERVAL
                                                         target:self
                                                       selector:@selector(refreshRooms:)
                                                       userInfo:nil
                                                        repeats:NO];
    [_refreshRoomTimer retain];
}

- (void)pauseRefreshingRooms
{
    _isRefreshing = NO;
    [self clearRefreshRoomsTimer];
}

- (void)continueRefreshingRooms
{
    _isRefreshing = YES;
    [self startRefreshRoomsTimer];
}


- (void)getRoomsFinished
{
    [self hideActivity];
    self.dataList = [NSArray arrayWithArray:_gameService.roomList];
    [self.dataTableView reloadData];
    //[[DiceGameService defaultService] registerRoomsNotification:service.roomList]; //don register room notification here
    //self.noMoreData = YES;
    //[self dataSourceDidFinishLoadingMoreData];
    if (_isRefreshing) {
        [self startRefreshRoomsTimer];
    }
    if (self.dataList.count > 0) {
        [self handleUpdateRoomList];
    } else {
        [self handleNoRoomMessage];
    }
    [self handleUpdateOnlineUserCount];
}



- (void)didJoinGame
{
    [self hideActivity];
    if (_isJoiningGame) {
        [self handleDidJoinGame];
        _isJoiningGame = NO;
    }
    
}

- (void)connectServer
{
    if (![_gameService isConnected]) {
        [_gameService connectServer];
        [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
    } else {
        [self didConnected];
    }
}

- (void)registerDiceRoomNotification
{
    
    [self registerNotificationWithName:NOTIFICAIION_CREATE_ROOM_RESPONSE
                            usingBlock:^(NSNotification *note) {
                                PPDebug(@"<DiceRoomListController> NOTIFICAIION_CREATE_ROOM_RESPONSE");
                                [self hideActivity];
                                GameMessage* message = [CommonGameNetworkService userInfoToMessage:note.userInfo];
                                if (message.resultCode == GameResultCodeSuccess) {
                                    [self didJoinGame];
                                } else if (message.resultCode == GameResultCodeErrorSessionNameDuplicated) {
                                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kRoomNameDuplicated") delayTime:2 isHappy:NO];
                                }else {
                                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kJoinGameFailure") delayTime:1.5 isHappy:NO];
                                }
                            }];
    
    [self registerNotificationWithName:NOTIFICAIION_GET_ROOMS_RESPONSE
                            usingBlock:^(NSNotification *note) {
                                PPDebug(@"<DiceRoomListController> NOTIFICAIION_GET_ROOMS_RESPONSE");
                                GameMessage* message = [CommonGameNetworkService userInfoToMessage:note.userInfo];
                                if (message.resultCode == GameResultCodeSuccess) {
                                    [self getRoomsFinished];
                                }
                            }];
    [self registerNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE
                            usingBlock:^(NSNotification *note) {
                                PPDebug(@"<DiceRoomListController> NOTIFICATION_JOIN_GAME_RESPONSE");
                                [self hideActivity];
                                GameMessage* message = [CommonGameNetworkService userInfoToMessage:note.userInfo];
                                if (message.resultCode == GameResultCodeSuccess) {
                                    [self didJoinGame];
                                } else if (message.resultCode == GameResultCodeErrorSessionidFull) {
                                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSessionFull") delayTime:1.5 isHappy:NO];
                                } else {
                                    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kJoinGameFailure") delayTime:1.5 isHappy:NO];
                                }
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_NETWORK_CONNECTED
                            usingBlock:^(NSNotification *note) {
                                [self didConnected];
                            }];
    
    //    [self registerNotificationWithName:UIApplicationWillEnterForegroundNotification
    //                            usingBlock:^(NSNotification *note) {
    //        PPDebug(@"<DiceRoomListController> Disconnected from server");
    //        if (![[DiceGameService defaultService] isConnected]) {
    //            [self didBroken];
    //        }
    //    }];
    
}

- (void)unregisterRoomNotification
{
    [self unregisterAllNotifications];
}

- (void)initView
{
    [self.backgroundImageView setImage:[[GameApp getImageManager] roomListBgImage]];
    [self.backButton setBackgroundImage:[[GameApp getImageManager] roomListBackBtnImage] forState:UIControlStateNormal];
    [self.allRoomButton setBackgroundImage:[[GameApp getImageManager] roomListLeftBtnSelectedImage] forState:UIControlStateSelected];
    [self.allRoomButton setBackgroundImage:[[GameApp getImageManager] roomListLeftBtnUnselectedImage] forState:UIControlStateNormal];
    [self.friendRoomButton setBackgroundImage:[[GameApp getImageManager] roomListRightBtnSelectedImage] forState:UIControlStateSelected];
    [self.friendRoomButton setBackgroundImage:[[GameApp getImageManager] roomListRightBtnUnselectedImage] forState:UIControlStateNormal];
    [self.createRoomButton setBackgroundImage:[[GameApp getImageManager] roomListCreateRoomBtnBgImage] forState:UIControlStateNormal];
    [self.fastEntryButton setBackgroundImage:[[GameApp getImageManager] roomListFastEntryBtnBgImage] forState:UIControlStateNormal];
    
    [self.allRoomButton setTitle:NSLS(@"kAll") forState:UIControlStateNormal];
    [self.friendRoomButton setTitle:NSLS(@"kFriend") forState:UIControlStateNormal];
    [self.nearByRoomButton setTitle:NSLS(@"kNearBy") forState:UIControlStateNormal];
    [self.createRoomButton setTitle:NSLS(@"kCreateRoom") forState:UIControlStateNormal];
    [self.fastEntryButton setTitle:NSLS(@"kFastEntry") forState:UIControlStateNormal];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isRefreshing = YES;
    [self handleUpdateOnlineUserCount];
    
    [self initView];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(roomsDidUpdate:)
    //                                                 name:ROOMS_DID_UPDATE
    //                                               object:nil];
}

- (void)viewDidUnload
{

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerDiceRoomNotification];
    [super viewDidAppear:animated];
    [self connectServer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterRoomNotification];
    [_searchView disappear];
    [self clearRefreshRoomsTimer];
    [super viewDidDisappear:animated];
}



#pragma mark - Button action

- (IBAction)clickBackButton:(id)sender {
//    CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:@"确定退出游戏吗？确定退出游戏吗？确定退出游戏吗？" style:CommonDialogStyleDoubleButton delegate:nil theme:CommonDialogThemeStarry
//                            ];
//    [dialog setClickOkBlock:^{
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
//    [dialog showInView:self.view];
    [_gameService quitGame];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickFastEntryButton:(id)sender {
    _isJoiningGame = YES;
    [self checkAndJoinGame];
}

- (IBAction)createRoom:(id)sender
{
    if ([self handlePrejoinGameCheck] == canJoinGame) {
        [self showCreateRoomView];
    }else {
        [self handleJoinGameError:[self handlePrejoinGameCheck]];
    }
}

- (void)showCreateRoomView
{ 
    RoomPasswordDialog *inputDialog = [RoomPasswordDialog dialogWith:NSLS(@"kCreateRoom")
                                                            delegate:self];
    inputDialog.targetTextField.text = [[UserManager defaultManager] defaultUserRoomName];
    inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    inputDialog.passwordField.placeholder = NSLS(@"kDiceEnterPassword");
    [inputDialog showInView:self.view];
    inputDialog.tag = CREATE_ROOM_DIALOG_TAG;
}



- (void)refreshRoomsByFilter:(CommonRoomFilter)filter
{
    [_gameService getRoomList:0
                                            count:ROOMS_COUNT_PER_PAGE
                                         roomType:filter
                                          keyword:nil
                                           gameId:[ConfigManager gameId]];
    _currentRoomType = filter;
}




#pragma mark - CommonGameServiceDelegate
- (void)didConnected
{
    [self hideActivity];
    [_gameService getRoomList:0 count:ROOMS_COUNT_PER_PAGE];
    firstLoad = NO;
    [self handleDidConnectServer];
}

- (void)didBroken
{
    PPDebug(@"%@ <didBroken>", [self description]);
    [self hideActivity];
    
    //    [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

- (void)showPasswordDialog
{
    InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kPassword")
                                              delegate:self
                                                 ];
    inputDialog.targetTextField.text = nil;
    inputDialog.targetTextField.placeholder = NSLS(@"kEnterPassword");
    [inputDialog showInView:self.view];
    inputDialog.tag = ENTER_ROOM_DIALOG_TAG;
}

#pragma makr - inputDialog delegate
- (void)didClickOk:(InputDialog *)dialog
        targetText:(NSString *)targetText
{
    if (dialog.tag == CREATE_ROOM_DIALOG_TAG) {
        NSString *password = ((RoomPasswordDialog *)dialog).passwordField.text;
        [self createRoomWithName:targetText
                        password:password];
    }
    
    if (dialog.tag == ENTER_ROOM_DIALOG_TAG) {
        if ([self.currentSession.password isEqualToString:targetText]) {
            [self checkAndJoinGame:self.currentSession.sessionId];
        } else {
            [self popupMessage:NSLS(@"kPsdNotMatch") title:nil];
        }
    }
}
- (void)didClickCancel:(InputDialog *)dialog
{
    
}

#pragma mark - load more delegate
- (void)loadMoreTableViewDataSource
{
    [_gameService getRoomList:_gameService.roomList.count count:ROOMS_COUNT_PER_PAGE];
}

#pragma mark - common dialog delegate
- (void)clickOk:(CommonDialog *)dialog
{
    if ([ConfigManager wallEnabled]) {
        [self showWall];
    }else {
        CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

- (void)showWall
{
    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    [[LmWallService defaultService] show:self];
}

#pragma mark - common info view delegate
- (void)infoViewDidDisappear:(CommonInfoView*)view
{
    _searchView = nil;
    if (_currentRoomType == CommonRoomFilterAllRoom) {
        [self continueRefreshingRooms];
    }
    if (_currentRoomType == CommonRoomFilterFriendRoom) {
//        [self clickFriendRoom:nil];
    }
    
}

#pragma mark - CommonSearchViewDelegate

- (void)willSearch:(NSString *)keywords byView:(CommonSearchView *)view
{
    [_gameService getRoomList:0
                                            count:ROOMS_COUNT_PER_PAGE
                                         roomType:_currentRoomType
                                          keyword:keywords
                                           gameId:[ConfigManager gameId]];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
    [self pauseRefreshingRooms];
}



- (IBAction)clickSearch:(id)sender
{
    if (_searchView) {
        [_searchView disappear];
    } else {
        _searchView = [CommonSearchView showInView:self.view
                                           byTheme:CommonSearchViewThemeDice
                                           atPoint:[self getSearchViewPosition]
                                          delegate:self];
    }
}

#pragma mark - dice room list delegate
- (void)didQueryUser:(NSString *)userId
{
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    [CommonUserInfoView showFriend:friend inController:self needUpdate:YES canChat:YES];
}


@end
