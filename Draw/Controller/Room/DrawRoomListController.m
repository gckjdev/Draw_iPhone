//
//  DrawRoomListController.m
//  Draw
//
//  Created by Kira on 13-1-22.
//
//

#import "DrawRoomListController.h"
#import "DrawGameService.h"
#import "DrawRoomListCell.h"
#import "DrawUserInfoView.h"
#import "MyFriend.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "RoomController.h"

@interface DrawRoomListController ()

@property  (retain, nonatomic) PBGameSession*currentSession;

@end

@implementation DrawRoomListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CommonRoomListController" bundle:nibBundleOrNil];
    if (self) {
        _gameService = [DrawGameService defaultService];

//        [[DrawGameService defaultService] setServerAddress:@"192.168.1.198"];
//        [[DrawGameService defaultService] setServerPort:8080];
        
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DrawRoomListCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DrawRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:[DrawRoomListCell getCellIdentifier]];
    if (cell == nil) {
        cell = [DrawRoomListCell createCell:[DrawRoomListCell getCellIdentifier]];
    }
    PBGameSession* session = [[_gameService roomList] objectAtIndex:indexPath.row];
    [cell setCellInfo:session roomListTitile:@""];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_gameService roomList] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.currentSession = [_gameService sessionInRoom:indexPath.row];
    if (self.currentSession.password == nil
        || self.currentSession.password.length <= 0
        || [[UserManager defaultManager] isMe:self.currentSession.createBy])
    {
        [self checkAndJoinGame:self.currentSession.sessionId];
    } else {
        [self showPasswordDialog];
    }
    
    
}

- (CGPoint)getSearchViewPosition
{
    return CGPointMake(self.view.center.x, self.rightTabButton.center.y);
}

- (void)handleDidJoinGame
{
    [self hideActivity];
//    if ([message resultCode] == 0){
//        [self popupHappyMessage:NSLS(@"kJoinGameSucc") title:@""];
//    }
//    else{
//        NSString* text = [NSString stringWithFormat:NSLS(@"kJoinGameFailure")];
//        [self popupUnhappyMessage:text title:@""];
//        [[DrawGameService defaultService] disconnectServer];
//        //        [[RouterService defaultService] putServerInFailureList:[[DrawGameService defaultService] serverAddress]
//        //                                                          port:[[DrawGameService defaultService] serverPort]];
//        return;
//    }
    [RoomController enterRoom:self isFriendRoom:YES];
}
- (PrejoinGameErrorCode)handlePrejoinGameCheck
{
    return canJoinGame;
}
- (PrejoinGameErrorCode)handlePrejoinGameCheckBySessionId:(int)sessionId
{
    return canJoinGame;
}
- (void)handleJoinGameError:(PrejoinGameErrorCode)errorCode
{
    
}
- (void)handleUpdateRoomList
{
    self.emptyListTips.hidden = YES;
}
- (void)handleDidConnectServer
{
    self.fastEntryButton.enabled = YES;
    self.createRoomButton.enabled = YES;
}

- (void)handleNoRoomMessage
{
    self.emptyListTips.hidden = NO;
    if (_currentRoomType == CommonRoomFilterFriendRoom) {
        [self.emptyListTips setText:NSLS(@"kNoFriendRoom")];
    }
    if (_searchView) {
        [self.emptyListTips setText:NSLS(@"kSearchEmpty")];
    }
}


- (void)didQueryUser:(NSString *)userId
{
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];
    return;
}

- (void)handleLeftTabAction
{
    [self refreshRoomsByFilter:CommonRoomFilterAllRoom];
    [self continueRefreshingRooms];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}
- (void)handleCenterTabAction
{
    [self refreshRoomsByFilter:CommonRoomFilterFriendRoom];
    [self pauseRefreshingRooms];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
}


@end
