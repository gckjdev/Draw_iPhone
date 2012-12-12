//
//  RoomListController.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceRoomListController.h"
#import "DiceImageManager.h"
#import "DiceRoomListCell.h"
#import "CommonGameNetworkClient.h"
#import "UserManager+DiceUserManager.h"
#import "NotificationName.h"
#import "DiceGameService.h"
#import "DiceNotification.h"
#import "GameMessage.pb.h"
#import "DiceGamePlayController.h"
#import "FontButton.h"
#import "GameConstants.pb.h"
#import "CommonMessageCenter.h"
#import "DiceColorManager.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "CoinShopController.h"
#import "LmWallService.h"
#import "DiceUserInfoView.h"
#import "PPResourceService.h"

#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"
#define ROOMS_COUNT_PER_PAGE  20

#define REFRESH_ROOMS_TIME_INTERVAL 2

#define CREATE_ROOM_DIALOG_TAG  120120824
#define ENTER_ROOM_DIALOG_TAG   220120824



@interface DiceRoomListController ()
{
    AccountService *_accountService;
    DiceGameRuleType _ruleType;
}

@end

@implementation DiceRoomListController

#pragma mark - Life cycle
@synthesize titleFontButton;
@synthesize helpButton;
@synthesize createRoomButton;
@synthesize fastEntryButton;
@synthesize allRoomButton;
@synthesize friendRoomButton;
@synthesize nearByRoomButton;
@synthesize currentSession = _currentSession;
@synthesize emptyListTips;

- (id)initWithRuleType:(DiceGameRuleType)ruleType
{
    self = [super init];
    if (self) {
        firstLoad = YES;
        _ruleType = ruleType;
    }
    
    return self;
}

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        firstLoad = YES;
//    }
//    
//    return self;
//}

- (void)dealloc {
    _searchView.disappearDelegate = nil;
    [self clearRefreshRoomsTimer];
    [createRoomButton release];
    [fastEntryButton release];
    [titleFontButton release];
    [allRoomButton release];
    [friendRoomButton release];
    [nearByRoomButton release];
    PPRelease(_currentSession);
    [helpButton release];
    [emptyListTips release];
    [super dealloc];
}

- (void)checkAndJoinGame:(int)sessionId
{
    _isJoiningDice = YES;
    if ([DiceConfigManager meetJoinGameCondictionWithRuleType:_diceGameService.ruleType]) {
        [self showActivityWithText:NSLS(@"kJoiningGame")];
        [[DiceGameService defaultService] joinGameRequest:sessionId customSelfUser:[[UserManager defaultManager] toDicePBGameUser]];
    }else {
        [self showCoinsNotEnoughView];
    }
}

- (void)checkAndJoinGame
{
    _isJoiningDice = YES;
    if ([DiceConfigManager meetJoinGameCondictionWithRuleType:_diceGameService.ruleType]) {
        [self showActivityWithText:NSLS(@"kJoiningGame")];
        [_diceGameService joinGameRequestWithCustomUser:[[UserManager defaultManager] toDicePBGameUser]];
    }else {
        [self showCoinsNotEnoughView];
    }
}

- (void)createRoomWithName:(NSString*)targetText 
                  password:(NSString*)password
{
    _isJoiningDice = YES;
    [_diceGameService createRoomWithName:targetText password:password];
    [self showActivityWithText:NSLS(@"kCreatingRoom")];
}

- (void)refreshRooms:(id)sender
{
    [[DiceGameService defaultService] getRoomList:0 count:ROOMS_COUNT_PER_PAGE];
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

- (void)updateRoomList
{
    self.emptyListTips.hidden = YES;
    if (self.dataList.count < 1) {
        self.emptyListTips.hidden = NO;
        if (_currentRoomType == friendRoom) {
            [self.emptyListTips setText:NSLS(@"kNoFriendRoom")];
        }
        if (_searchView) {
            [self.emptyListTips setText:NSLS(@"kSearchEmpty")];
        }
    }
}


- (void)getRoomsFinished
{
    [self hideActivity];
    CommonGameNetworkService* service = [DiceGameService defaultService];
    self.dataList = [NSArray arrayWithArray:service.roomList];
    [self.dataTableView reloadData];
    //[[DiceGameService defaultService] registerRoomsNotification:service.roomList]; //don register room notification here
    //self.noMoreData = YES;
    //[self dataSourceDidFinishLoadingMoreData];
    if (_isRefreshing) {
        [self startRefreshRoomsTimer];
    }
    [self updateRoomList];
    [self updateOnlineUserCount];
}

- (void)joinGame
{
    [self hideActivity];
    if(_isJoiningDice) {
        DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES];
        _isJoiningDice = NO; 
    }
}

- (void)connectServer
{
    // Internet Test Server
    [[DiceGameService defaultService] setRuleType:_ruleType];
//    [[DiceGameService defaultService] connectServer:self];
    [[DiceGameService defaultService] connectServer];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
    _isJoiningDice = NO;    
}

- (void)registerDiceRoomNotification
{
    
    [self registerNotificationWithName:NOTIFICAIION_CREATE_ROOM_RESPONSE
                            usingBlock:^(NSNotification *note) {
        PPDebug(@"<DiceRoomListController> NOTIFICAIION_CREATE_ROOM_RESPONSE"); 
        [self hideActivity];
        GameMessage* message = [CommonGameNetworkService userInfoToMessage:note.userInfo];
        if (message.resultCode == GameResultCodeSuccess) {
            [self joinGame];
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
            [self joinGame];
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

- (void)unregisterDiceRoomNotification
{
    [self unregisterAllNotifications];                                               
}

- (NSString *)title
{
    NSString *title = nil;
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            title = NSLS(@"kDiceMenuHappyRoom");
            break;
            
        case DiceGameRuleTypeRuleHigh:
            title = NSLS(@"kDiceMenuHighRoom");
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            title = NSLS(@"kDiceMenuSuperHighRoom");
            break;     
            
        default:
            break;
    }
    
    return title;
}

- (UIImage *)bgImage
{
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            return [[DiceImageManager defaultManager] diceNormalRoomListBgImage];
            break;
            
        case DiceGameRuleTypeRuleHigh:
            return [[DiceImageManager defaultManager] diceHighRoomListBgImage];
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            return [[DiceImageManager defaultManager] diceSuperHighRoomListBgImage];
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _accountService = [AccountService defaultService];
   
    _diceGameService = [DiceGameService defaultService];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[self bgImage]];
    
    [createRoomButton setRoyButtonWithColor:[DiceColorManager dialoggreenColor]];
    
    [fastEntryButton setRoyButtonWithColor:[DiceColorManager dialogYellowColor]];
    
    [self.titleFontButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.allRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.friendRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.nearByRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    
//    [self.titleFontButton.fontLable setText:[self title]];
    [self.allRoomButton.fontLable setText:NSLS(@"kAll")];
    [self.friendRoomButton.fontLable setText:NSLS(@"kFriend")];
    [self.nearByRoomButton.fontLable setText:NSLS(@"kNearBy")];
    [self.createRoomButton.fontLable setText:NSLS(@"kCreateRoom")];
    [self.fastEntryButton.fontLable setText:NSLS(@"kFastEntry")];
    
    _isRefreshing = YES;
    self.emptyListTips.hidden = YES;
    [self updateOnlineUserCount];    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(roomsDidUpdate:)
//                                                 name:ROOMS_DID_UPDATE
//                                               object:nil];
}

- (void)viewDidUnload
{
    [self setCreateRoomButton:nil];
    [self setFastEntryButton:nil];
    [self setTitleFontButton:nil];
    [self setAllRoomButton:nil];
    [self setFriendRoomButton:nil];
    [self setNearByRoomButton:nil];
    [self setHelpButton:nil];
    [self setEmptyListTips:nil];
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
    [self unregisterDiceRoomNotification];
    [_searchView disappear];
    [self clearRefreshRoomsTimer];
    [super viewDidDisappear:animated];
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DiceRoomListCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiceRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:[DiceRoomListCell getCellIdentifier]];
    if (cell == nil) {
        cell = [DiceRoomListCell createCell:[DiceRoomListCell getCellIdentifier]];
    }
    PBGameSession* session = [[DiceGameService defaultService].roomList objectAtIndex:indexPath.row];
    [cell setCellInfo:session ruleType:_ruleType];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DiceGameService defaultService].roomList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.currentSession = [[DiceGameService defaultService] sessionInRoom:indexPath.row];
    if (self.currentSession.password == nil 
        || self.currentSession.password.length <= 0 
        || [[UserManager defaultManager] isMe:self.currentSession.createBy]) 
    {
        [self checkAndJoinGame:self.currentSession.sessionId];
    } else {
        InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kPassword") 
                                                  delegate:self 
                                                     theme:CommonDialogThemeDice];
        inputDialog.targetTextField.text = nil;
        inputDialog.targetTextField.placeholder = NSLS(@"kEnterPassword");
        [inputDialog showInView:self.view]; 
        inputDialog.tag = ENTER_ROOM_DIALOG_TAG;
    }
    
    
}

#pragma mark - Button action

- (IBAction)clickBackButton:(id)sender {
    [[DiceGameService defaultService] quitGame];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickFastEntryButton:(id)sender {    
    [self checkAndJoinGame];
}

- (IBAction)creatRoom:(id)sender
{
    if ([DiceConfigManager meetJoinGameCondictionWithRuleType:_diceGameService.ruleType]) {
        [self showCreateRoomView];
    }else {
        [self showCoinsNotEnoughView];
    }
}

- (void)showCreateRoomView
{
    RoomPasswordDialog *inputDialog = [RoomPasswordDialog dialogWith:NSLS(@"kCreateRoom") 
                                                            delegate:self 
                                                               theme:CommonDialogThemeDice];
    inputDialog.targetTextField.text = [[UserManager defaultManager] defaultUserRoomName];
    inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    inputDialog.passwordField.placeholder = NSLS(@"kDiceEnterPassword");
    [inputDialog showInView:self.view];
    inputDialog.tag = CREATE_ROOM_DIALOG_TAG;
}

- (void)showCoinsNotEnoughView
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin") message:[DiceConfigManager coinsNotEnoughNoteWithRuleType:_diceGameService.ruleType] style:CommonDialogStyleDoubleButton delegate:self theme:CommonDialogThemeDice];
    [dialog showInView:self.view];
}

- (void)refreshRoomsByFilter:(RoomFilter)filter
{
    [[DiceGameService defaultService] getRoomList:0
                                            count:ROOMS_COUNT_PER_PAGE
                                         roomType:filter
                                          keyword:nil
                                           gameId:[ConfigManager gameId]];
}


- (IBAction)clickAll:(id)sender
{
    [self.allRoomButton setSelected:YES];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:NO];
    [self refreshRoomsByFilter:(RoomFilter)allRoom];
    _currentRoomType = allRoom;
    [self continueRefreshingRooms];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}
- (IBAction)clickFriendRoom:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:YES];
    [self.nearByRoomButton setSelected:NO];
    [self refreshRoomsByFilter:(RoomFilter)friendRoom];
    _currentRoomType = friendRoom;
    [self pauseRefreshingRooms];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
}
- (IBAction)clickNearBy:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:YES];
    [self refreshRoomsByFilter:(RoomFilter)nearByRoom];
    _currentRoomType = nearByRoom;
}

- (void)updateOnlineUserCount
{
    NSString* userCount = [NSString stringWithFormat:NSLS(@"kOnlineUser"),[[DiceGameService defaultService] onlineUserCount]];
    [self.titleFontButton.fontLable setText:[NSString stringWithFormat:@"%@(%@)",[self title], userCount]];
}

#pragma mark - CommonGameServiceDelegate
- (void)didConnected
{
    [self hideActivity];
    [[DiceGameService defaultService] getRoomList:0 count:ROOMS_COUNT_PER_PAGE];
    [self.createRoomButton setEnabled:YES];
    [self.fastEntryButton setEnabled:YES];
    firstLoad = NO;
}

- (void)didBroken
{
    PPDebug(@"%@ <didBroken>", [self description]);
    [self hideActivity];
    
//    [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
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
    [_diceGameService getRoomList:_diceGameService.roomList.count count:ROOMS_COUNT_PER_PAGE];
}

- (IBAction)clickHelpButton:(id)sender {
    if (!helpButton.selected) {
        helpButton.selected = YES;
        HelpView *view = [HelpView createHelpView:@"DiceHelpView"];
        view.delegate = self;
        [view showInView:self.view];
    }
}

- (void)didHelpViewHide
{
    helpButton.selected = NO;
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
    if (_currentRoomType == allRoom) {
        [self continueRefreshingRooms];
    }
    if (_currentRoomType == friendRoom) {
        [self clickFriendRoom:nil];
    }
    
}

#pragma mark - CommonSearchViewDelegate

- (void)willSearch:(NSString *)keywords byView:(CommonSearchView *)view
{
    [[DiceGameService defaultService] getRoomList:0
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
                                           atPoint:CGPointMake(self.view.center.x, self.friendRoomButton.center.y) 
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
    [DiceUserInfoView showFriend:friend 
                      infoInView:self
                         canChat:NO
                      needUpdate:YES];
}

@end
