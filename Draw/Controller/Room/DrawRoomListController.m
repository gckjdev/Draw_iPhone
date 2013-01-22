//
//  DrawRoomListController.m
//  Draw
//
//  Created by Kira on 13-1-22.
//
//

#import "DrawRoomListController.h"
#import "RoomService.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "CommonUserInfoView.h"

@interface DrawRoomListController () {
    RoomService* _roomService;
}

@end

@implementation DrawRoomListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init
{
    self = [super init];
    if (self) {
        _roomService = [RoomService defaultService];
    }
    return self;
}

- (void)initButtons
{
    [self.allRoomButton setTitle:NSLS(@"kAll") forState:UIControlStateNormal];
    [self.friendRoomButton setTitle:NSLS(@"kFriend") forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initButtons];
    
    [self handleUpdateOnlineUserCount];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (NSString*)title
{
    return @"kDrawRoomTitle";
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
    PBGameSession* session = [_gameService.roomList objectAtIndex:indexPath.row];
    [cell setCellInfo:session roomListTitile:NSLS(@"kDrawRoomTitle")];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _gameService.roomList.count;
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
    return CGPointMake(self.view.center.x, self.friendRoomButton.center.y);
}
- (void)handleUpdateOnlineUserCount
{
    NSString* userCount = [NSString stringWithFormat:NSLS(@"kOnlineUser"),[_gameService onlineUserCount]];
    [self.titleFontButton setTitle:[NSString stringWithFormat:@"%@(%@)",[self title], userCount] forState:UIControlStateNormal];
}
- (void)handleDidJoinGame
{
    
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

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

- (void)didQueryUser:(NSString *)userId
{
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    [CommonUserInfoView showFriend:friend inController:self needUpdate:YES canChat:YES];
    return;
}

- (IBAction)clickAll:(id)sender
{
    [self.allRoomButton setSelected:YES];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:NO];
    [self refreshRoomsByFilter:CommonRoomFilterAllRoom];
    [self continueRefreshingRooms];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}
- (IBAction)clickFriendRoom:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:YES];
    [self.nearByRoomButton setSelected:NO];
    [self refreshRoomsByFilter:CommonRoomFilterFriendRoom];
    [self pauseRefreshingRooms];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
}
- (IBAction)clickNearBy:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:YES];
    [self refreshRoomsByFilter:CommonRoomFilterNearByRoom];
}


@end
