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
#import "UserManager.h"
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

#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"
#define ROOMS_COUNT_PER_PAGE  20

#define REFRESH_ROOMS_TIME_INTERVAL 2

#define CREATE_ROOM_DIALOG_TAG  120120824
#define ENTER_ROOM_DIALOG_TAG   220120824



@interface DiceRoomListController ()
{
    AccountService *_accountService;
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

- (id)init
{
    self = [super init];
    firstLoad = YES;
    return self;
}

- (void)dealloc {
    [self clearRefreshRoomsTimer];
    [createRoomButton release];
    [fastEntryButton release];
    [titleFontButton release];
    [allRoomButton release];
    [friendRoomButton release];
    [nearByRoomButton release];
    PPRelease(_currentSession);
    [helpButton release];
    [super dealloc];
}

- (BOOL)meetJoinGameCondiction
{
    if ([_accountService getBalance] <= DICE_THRESHOLD_COIN) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin") message:NSLS(@"kCoinsNotEnough") style:CommonDialogStyleDoubleButton delegate:self theme:CommonDialogThemeDice];
        [dialog showInView:self.view];
        return NO;
    }
    return YES;
}

- (void)refreshRooms:(id)sender
{
    [[DiceGameService defaultService] getRoomList:0 count:ROOMS_COUNT_PER_PAGE shouldReloadData:YES];
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



- (void)getRoomsFinished
{
    [self hideActivity];
    CommonGameNetworkService* service = [DiceGameService defaultService];
    self.dataList = [NSArray arrayWithArray:service.roomList];
    [self.dataTableView reloadData];
    //[[DiceGameService defaultService] registerRoomsNotification:service.roomList]; //don register room notification here
    //self.noMoreData = YES;
    //[self dataSourceDidFinishLoadingMoreData];
    [self startRefreshRoomsTimer];
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
    NSString* address = [ConfigManager defaultDiceServer];
    int port = [ConfigManager defaultDicePort];
    
    [[DiceGameService defaultService] setServerAddress:address];
    [[DiceGameService defaultService] setServerPort:port];
    

    // Internet Test Server
//    [[DiceGameService defaultService] setServerAddress:@"106.187.89.232"];
//    [[DiceGameService defaultService] setServerPort:8018];

//    [[DiceGameService defaultService] setServerAddress:@"192.168.1.198"];
//    [[DiceGameService defaultService] setServerPort:8080];

    [[DiceGameService defaultService] connectServer:self];
    [self showActivityWithText:NSLS(@"kConnectingServer")];
    _isJoiningDice = NO;    
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

- (void)registerDiceRoomNotification
{
    
    [self registerDiceGameNotificationWithName:NOTIFICAIION_CREATE_ROOM_RESPONSE usingBlock:^(NSNotification *note) {
        PPDebug(@"<DiceRoomListController> NOTIFICAIION_CREATE_ROOM_RESPONSE"); 
        [self joinGame];
    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICAIION_GET_ROOMS_RESPONSE usingBlock:^(NSNotification *note) {
        PPDebug(@"<DiceRoomListController> NOTIFICAIION_GET_ROOMS_RESPONSE"); 
        [self getRoomsFinished];
    }];
    [self registerDiceGameNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE usingBlock:^(NSNotification *note) {
        PPDebug(@"<DiceRoomListController> NOTIFICATION_JOIN_GAME_RESPONSE");  
        [self hideActivity];
        GameMessage* message = [CommonGameNetworkService userInfoToMessage:note.userInfo];
        if (message.resultCode == 0) {
            [self joinGame];
        } else if (message.resultCode == GameResultCodeErrorSessionidFull) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSessionFull") delayTime:1.5 isHappy:NO];
        } else {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kJoinGameFailure") delayTime:1.5 isHappy:NO];
        }
    }];
//    [self registerDiceGameNotificationWithName:NOTIFICATION_ROOM usingBlock:^(NSNotification *note) {
//        PPDebug(@"<DiceRoomListController> NOTIFICATION_ROOM"); 
//        [[DiceGameService defaultService] getRoomList:0 count:_diceGameService.roomList.count shouldReloadData:YES];
//
//    }];

}

- (void)unregisterDiceRoomNotification
{
    [self unregisterAllNotifications];                                               
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _accountService = [AccountService defaultService];
   
    _diceGameService = [DiceGameService defaultService];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[DiceImageManager defaultManager] roomListBgImage]];
    
    [createRoomButton setRoyButtonWithColor:[DiceColorManager dialoggreenColor]];
    
    [fastEntryButton setRoyButtonWithColor:[DiceColorManager dialogYellowColor]];
    
    [self.titleFontButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.allRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.friendRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.nearByRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    
    [self.titleFontButton.fontLable setText:NSLS(@"kDiceRoomListTitle")];
    [self.allRoomButton.fontLable setText:NSLS(@"kAll")];
    [self.friendRoomButton.fontLable setText:NSLS(@"kFriend")];
    [self.nearByRoomButton.fontLable setText:NSLS(@"kNearBy")];
    [self.createRoomButton.fontLable setText:NSLS(@"kCreateRoom")];
    [self.fastEntryButton.fontLable setText:NSLS(@"kFastEntry")];
        
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerDiceRoomNotification];    
    
    [self connectServer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterDiceRoomNotification];
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
    [cell setCellInfo:session];
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
        _isJoiningDice = YES;
        [[DiceGameService defaultService] joinGameRequest:self.currentSession.sessionId condiction:^BOOL{
            return [self meetJoinGameCondiction];
        }];
        [self showActivityWithText:NSLS(@"kJoining")];
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
    _isJoiningDice = YES;
    [self showActivityWithText:NSLS(@"kJoiningGame")];
    [_diceGameService joinGameRequestWithCondiction:^BOOL{
        return [self meetJoinGameCondiction];
    }];
}

- (IBAction)creatRoom:(id)sender
{
    if ([self meetJoinGameCondiction]) {
        RoomPasswordDialog *inputDialog = [RoomPasswordDialog dialogWith:NSLS(@"kCreateRoom") 
                                                                delegate:self 
                                                                   theme:CommonDialogThemeDice];
        inputDialog.targetTextField.text = [[UserManager defaultManager] defaultUserRoomName];
        inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
        inputDialog.passwordField.placeholder = NSLS(@"kDiceEnterPassword");
        [inputDialog showInView:self.view];
        inputDialog.tag = CREATE_ROOM_DIALOG_TAG;
    }
    
}
- (IBAction)clickAll:(id)sender
{
    [self.allRoomButton setSelected:YES];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:NO];
}
- (IBAction)clickFriendRoom:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:YES];
    [self.nearByRoomButton setSelected:NO];
}
- (IBAction)clickNearBy:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:YES];
}

#pragma mark - CommonGameServiceDelegate
- (void)didConnected
{
    [self hideActivity];
    [[DiceGameService defaultService] getRoomList:0 count:ROOMS_COUNT_PER_PAGE shouldReloadData:YES];
    [self.createRoomButton setEnabled:YES];
    [self.fastEntryButton setEnabled:YES];
    firstLoad = NO;
}

- (void)didBroken
{
    //TODO: handle network broken here
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma makr - inputDialog delegate
- (void)didClickOk:(InputDialog *)dialog 
        targetText:(NSString *)targetText
{
    if (dialog.tag == CREATE_ROOM_DIALOG_TAG) {
        NSString *password = ((RoomPasswordDialog *)dialog).passwordField.text;
        [_diceGameService createRoomWithName:targetText password:password];
        _isJoiningDice = YES;
        [self showActivityWithText:NSLS(@"kCreatingRoom")];
    }
    
    if (dialog.tag == ENTER_ROOM_DIALOG_TAG) {
        if ([self.currentSession.password isEqualToString:targetText]) {
            _isJoiningDice = YES;
            [[DiceGameService defaultService] joinGameRequest:_currentSession.sessionId];
            [self showActivityWithText:NSLS(@"kJoining")];
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
    [_diceGameService getRoomList:_diceGameService.roomList.count count:ROOMS_COUNT_PER_PAGE shouldReloadData:NO];
}

- (IBAction)clickHelpButton:(id)sender {
    if (!helpButton.selected) {
        helpButton.selected = YES;
        DiceHelpView *view = [DiceHelpView createDiceHelpView];
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
    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES]; 
}
- (void)clickBack:(CommonDialog *)dialog
{
    
}

@end
