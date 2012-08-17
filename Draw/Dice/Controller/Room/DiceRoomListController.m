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


#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"
#define ROOMS_COUNT_PER_PAGE  20

#define REFRESH_ROOMS_TIME_INTERVAL 1

@interface DiceRoomListController ()

@end

@implementation DiceRoomListController

#pragma mark - Life cycle
@synthesize titleFontButton;
@synthesize createRoomButton;
@synthesize fastEntryButton;
@synthesize allRoomButton;
@synthesize friendRoomButton;
@synthesize nearByRoomButton;

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
    [super dealloc];
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
    
    //TODO: set server address from config manager
    [[DiceGameService defaultService] setServerAddress:@"192.168.1.198"];
    [[DiceGameService defaultService] setServerPort:8080];
    [[DiceGameService defaultService] connectServer:self];
    [self showActivityWithText:NSLS(@"kConnecting")];
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
    // self.supportRefreshFooter = YES;
    [super viewDidLoad];
   
    _diceGameService = [DiceGameService defaultService];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[DiceImageManager defaultManager] roomListBgImage]];
    
    [createRoomButton setBackgroundImage:[[DiceImageManager defaultManager] createRoomBtnBgImage] forState:UIControlStateNormal];
    
    [fastEntryButton setBackgroundImage:[[DiceImageManager defaultManager] fastGameBtnBgImage] forState:UIControlStateNormal];
    
    [self.titleFontButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.allRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.friendRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.nearByRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    
    [self.allRoomButton.fontLable setText:NSLS(@"kAll")];
    [self.friendRoomButton.fontLable setText:NSLS(@"kFriend")];
    [self.nearByRoomButton.fontLable setText:NSLS(@"kNearBy")];
        
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
    _isJoiningDice = YES;
    PBGameSession* session = [[DiceGameService defaultService] sessionInRoom:indexPath.row];
    
    [[DiceGameService defaultService] joinGameRequest:session.sessionId];
    [self showActivityWithText:NSLS(@"kJoining")];
    
}

#pragma mark - Button action

- (IBAction)clickBack:(id)sender {
    [[DiceGameService defaultService] quitGame];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickFastEntryButton:(id)sender {    
    _isJoiningDice = YES;
    [self showActivityWithText:NSLS(@"kJoiningGame")];
    [_diceGameService joinGameRequest];
}

- (IBAction)creatRoom:(id)sender
{
    InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kCreateRoom") delegate:self];
    inputDialog.targetTextField.text = [[UserManager defaultManager] defaultUserRoomName];
    inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    [inputDialog showInView:self.view];
    
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
    [_diceGameService creatRoomWithName:targetText];
    _isJoiningDice = YES;
}
- (void)didClickCancel:(InputDialog *)dialog
{
    
}

#pragma mark - load more delegate
- (void)loadMoreTableViewDataSource
{
    [_diceGameService getRoomList:_diceGameService.roomList.count count:ROOMS_COUNT_PER_PAGE shouldReloadData:NO];
}

@end
