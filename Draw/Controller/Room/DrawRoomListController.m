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
//#import "DrawUserInfoView.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "MyFriend.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "RoomController.h"
#import "FXLabel.h"

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

- (void)initLabels
{
    [self.titleLabel setGradientStartColor:[UIColor colorWithRed:52/255.0 green:30/255.0 blue:10/255.0 alpha:1.0]];
    [self.titleLabel setGradientEndColor:[UIColor colorWithRed:88/255.0 green:56/255.0 blue:22/255.0 alpha:1.0]];
    [self.titleLabel setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.48]];
    [self.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    
    [self.leftTabButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.leftTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.leftTabButton setTitleShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.48] forState:UIControlStateNormal];
    [self.leftTabButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.68] forState:UIControlStateSelected];
    [self.leftTabButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [self.rightTabButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.rightTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.rightTabButton setTitleShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.48] forState:UIControlStateNormal];
    [self.rightTabButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.68] forState:UIControlStateSelected];
    [self.rightTabButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    
    [self.fastEntryButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.fastEntryButton setTitleShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.48] forState:UIControlStateNormal];
    [self.fastEntryButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [self.createRoomButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.createRoomButton setTitleShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.48] forState:UIControlStateNormal];
    [self.createRoomButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    
    [self.emptyListTips setTextColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0]];
    [self.emptyListTips setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [self.emptyListTips setShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.48]];
    
    [self.leftTabButton.titleLabel setShadowColor:[UIColor whiteColor]];
    [self.leftTabButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [self.centerTabButton.titleLabel setShadowColor:[UIColor whiteColor]];
    [self.centerTabButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [self.rightTabButton.titleLabel setShadowColor:[UIColor whiteColor]];
    [self.rightTabButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.rightTabButton setTitle:NSLS(@"kFriend") forState:UIControlStateNormal];
    [self.leftTabButton setTitle:NSLS(@"kAll") forState:UIControlStateNormal];
    [self hideCenterTabButton];
    [self initLabels];
    
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
//    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nil]] autorelease];
//    [self.navigationController pushViewController:uc animated:YES];
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nil] inViewController:self];
}

- (void)handleLeftTabAction
{
    [self refreshRoomsByFilter:CommonRoomFilterAllRoom];
    [self continueRefreshingRooms];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}
- (void)handleRightTabAction
{
    [self refreshRoomsByFilter:CommonRoomFilterFriendRoom];
    [self pauseRefreshingRooms];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
}


@end
