//
//  FriendRoomController.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FriendRoomController.h"
#import "ShareImageManager.h"
#import "SearchRoomController.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "Room.h"
#import "RoomCell.h"
#import "ConfigManager.h"
#import "StringUtil.h"
#import "GameMessage.pb.h"
#import "RoomController.h"
#import "FriendController.h"
#import "RoomManager.h"
#import "DeviceDetection.h"
#import "WordManager.h"
#import "LevelService.h"
//#import "DrawUserInfoView.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "NotificationManager.h"
#import "MyFriend.h"
#import "NotificationName.h"
#import "CustomUITextField.h"

@interface FriendRoomController ()

- (void)updateNoRoomTip;
- (void)updateRoomList;
@end

#define INVITE_LIMIT 20
#define FIND_ROOM_LIMIT 50


@implementation FriendRoomController
@synthesize titleLabel;
@synthesize myFriendButton;
@synthesize noRoomTips;
@synthesize createButton;
@synthesize searchButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userManager = [UserManager defaultManager];
        roomService = [RoomService defaultService];
        _currentStartIndex = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [[WordManager defaultManager] clearWordBaseDictionary];
    
}

#pragma mark - View lifecycle


- (void)updateRoomList
{
    [roomService findMyRoomsWithOffset:_currentStartIndex limit:FIND_ROOM_LIMIT delegate:self];
    [self showActivityWithText:NSLS(@"kLoading")];
}



- (void)initButtons
{
    //bg image
    ShareImageManager *manager = [ShareImageManager defaultManager];
    
    [self.createButton setBackgroundImage:[manager greenImage] forState:UIControlStateNormal];
    [self.searchButton setBackgroundImage:[manager orangeImage] forState:UIControlStateNormal];
    //text
    [self.myFriendButton setTitle:NSLS(@"kFriendControl") forState:UIControlStateNormal];
    [self.createButton setTitle:NSLS(@"kCreateRoom") forState:UIControlStateNormal];
    [self.searchButton setTitle:NSLS(@"kSearchRoom") forState:UIControlStateNormal];
    [self.titleLabel setText:NSLS(@"kFriendPlayTitle")];
    [self.noRoomTips setText:NSLS(@"kNoRoomTips")];
}

- (void)viewDidLoad
{
    [self setSupportRefreshHeader:YES];
    [self setSupportRefreshFooter:YES];
    [super viewDidLoad];
    self.dataList = [[[NSMutableArray alloc] init]autorelease];
    [self initButtons];
    
    self.noRoomTips.hidden = YES;
    self.dataTableView.hidden = YES;
    
    [self updateRoomList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NotificationManager defaultManager]hideNotificationForType:NotificationTypeRoom];
    [[DrawGameService defaultService] registerObserver:self];
    [super viewDidDisappear:animated];    
}


- (void)viewDidDisappear:(BOOL)animated
{
    [[DrawGameService defaultService] unregisterObserver:self];
    [super viewDidDisappear:animated];    
}

- (void)viewDidUnload
{
    [self setCreateButton:nil];
    [self setSearchButton:nil];
    [self setMyFriendButton:nil];
    [self setTitleLabel:nil];
    [self setNoRoomTips:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [createButton release];
    [searchButton release];
    [myFriendButton release];
    [titleLabel release];
    [noRoomTips release];
    [super dealloc];
}

- (IBAction)clickCreateButton:(id)sender {
    RoomPasswordDialog *rDialog = [RoomPasswordDialog dialogWith:NSLS(@"kCreateRoom") delegate:self];
    NSInteger index = [[UserManager defaultManager] roomCount] + 1;
    NSString *nick = [[UserManager defaultManager]nickName];
    NSString *string = [NSString stringWithFormat:NSLS(@"kRoomNameNumber"),nick,index];
    rDialog.targetTextField.text = string;
    [rDialog showInView:self.view];
}

- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{

    NSString *roomName = targetText;
    NSString *password = ((RoomPasswordDialog *)dialog).passwordField.text;
    [self showActivityWithText:NSLS(@"kRoomCreating")];
    [roomService createRoom:roomName password:password delegate:self];    
}

- (void)passwordIsIllegal:(NSString *)password
{
    [self popupMessage:NSLS(@"kRoomPasswordIllegal") title:nil];
}
- (void)roomNameIsIllegal:(NSString *)password
{
    [self popupMessage:NSLS(@"kRoomNameIllegal") title:nil];
}

- (void)didClickInvite:(NSIndexPath *)indexPath
{
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    if (room) {
        _currentSelectRoom = room;
        NSString *invitedText = [NSString stringWithFormat:NSLS(@"kInvitationInfoInRoom"), room.roomName, room.password, [UIUtils getAppLink:[ConfigManager appId]]];
        
        
        NSMutableSet *fSet = nil;
        if ([room.userList count] != 0) {
            fSet = [NSMutableSet setWithCapacity:[room.userList count]];
            for (RoomUser *user in room.userList) {
                if ([user.userId length] != 0) {
                    [fSet addObject:user.userId];                    
                }
            }
        }
        
        NSInteger capacity = [[RoomManager defaultManager] roomFriendCapacity];
        
        FriendController *mfc = [[FriendController alloc] initWithInviteText:invitedText invitedFriendIdSet:fSet capacity:capacity delegate:self];
        [self.navigationController pushViewController:mfc animated:YES];
        [mfc release];
    }
}

- (void)friendController:(FriendController *)controller 
      didInviteFriendSet:(NSSet *)friendSet
{
    PPDebug(@"<didInviteFriendSet> set count = %d", [friendSet count]);

    [controller.navigationController popViewControllerAnimated:YES];
    [roomService inviteUsers:friendSet toRoom:_currentSelectRoom delegate:self];
}

//#pragma mark -  Room Service Delegate Method
- (void)updateRoom:(Room *)room users:(NSSet *)friendSet
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:room.userList];
    for (MyFriend *friend in friendSet) {
        RoomUser *user = [[RoomUser alloc] initWithFriend:friend
                                                   status:UserUnInvited];
        [array addObject:user];
        [user release];
        room.userList = array;
    }
    [self.dataTableView reloadData];
}


- (void)didRoom:(Room *)room 
  inviteFriends:(NSSet *)friendSet 
     resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kInviteFriendFail") title:nil];
    }else{
        [self popupMessage:NSLS(@"kInviteFriendSucc") title:nil];
        [self updateRoom:room users:friendSet];
    }
}
//

- (void)didClickAvatar:(NSIndexPath *)indexPath
{
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    RoomUser *roomUser = room.creator;

//    MyFriend *friend = [MyFriend friendWithFid:roomUser.userId nickName:roomUser.nickName avatar:roomUser.avatar gender:roomUser.gender level:1];
//    [DrawUserInfoView showFriend:friend infoInView:self needUpdate:YES];
    
    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:roomUser.userId avatar:roomUser.avatar nickName:roomUser.nickName]] autorelease];
    [self.navigationController pushViewController:uc animated:YES];
}


- (IBAction)clickSearchButton:(id)sender {
    SearchRoomController *src = [[SearchRoomController alloc] init];
    [self.navigationController pushViewController:src animated:YES];
    [src release];
}

- (IBAction)clickMyFriendButton:(id)sender {
    FriendController *mfc = [[FriendController alloc] init];
    [self.navigationController pushViewController:mfc animated:YES];
    [mfc release];
}

- (void)didCreateRoom:(Room*)room resultCode:(int)resultCode;
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kCreateRoomFail") title:nil];
    }else{
        [self popupMessage:NSLS(@"kCreateRoomSucc") title:nil];
        if (room) {
            NSMutableArray *list = (NSMutableArray *)self.dataList;
            [list insertObject:room atIndex:0];
            [dataTableView beginUpdates];
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
            NSArray *paths = [NSArray arrayWithObject: path];
            [self.dataTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            [dataTableView endUpdates];
            [self didClickInvite:path];
        }
        [[UserManager defaultManager] increaseRoomCount];
    }
    [self updateNoRoomTip];
}


- (void)didRemoveRoom:(Room *)room resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self popupMessage:NSLS(@"kRemoveRoomSucc") title:nil];
        NSInteger row = [self.dataList indexOfObject:room];
        if (row >= 0 && row < [self.dataList count]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
            [(NSMutableArray *)self.dataList removeObject:room];
            [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
        }
    }else{
        [self popupMessage:NSLS(@"kRemoveRoomFail") title:nil];        
    }
    [self updateNoRoomTip];
}


- (void)didFindRoomByUser:(NSString *)userId roomList:(NSArray*)roomList resultCode:(int)resultCode
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];
    
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kFindRoomListFail") title:nil];
    }else{
        NSMutableArray *array = nil;
        if (_currentStartIndex == 0) {
            //if load new data
            array = [NSMutableArray array];                

            
        }else{            
            array = [NSMutableArray arrayWithArray:self.dataList];
            //if load more data
   
        }
        if ([roomList count] != 0) {
            [array addObjectsFromArray:[[RoomManager defaultManager] sortRoomList:roomList]];            
        }
        self.dataList = array;
        _currentStartIndex += [roomList count];
        
        if ([roomList count] == FIND_ROOM_LIMIT) {
            self.noMoreData = NO;
        }else{
            self.noMoreData = YES;
        }
        
        [self.dataTableView reloadData];
        
    }
    
    [self updateNoRoomTip];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [RoomCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [dataList count];
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [RoomCell getCellIdentifier];
    RoomCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [RoomCell createCell:self];
        cell.roomCellType = RoomCellTypeMyRoom;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    [cell setInfo:room];
    cell.indexPath = indexPath;
    cell.roomCellDelegate = self;
    return cell;
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    [roomService removeRoom:room delegate:self];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row > [self.dataList count])
        return;

    
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    if (room == nil)
        return;
    
    if (_isTryJoinGame)
        return;
    
    
    [self showActivityWithText:NSLS(@"kConnectingServer")];
    [[DrawGameService defaultService] setServerAddress:room.gameServerAddress];
    [[DrawGameService defaultService] setServerPort:room.gameServerPort];    
    [[DrawGameService defaultService] connectServer:self];
    _isTryJoinGame = YES;    
    
    _currentSelectRoom = room;    
}

#pragma mark - Draw Game Service Delegate

- (void)didBroken
{
    _isTryJoinGame = NO;
    PPDebug(@"<didBroken> Friend Room");
    [self hideActivity];
//    [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    
    if (self.navigationController.topViewController != self){
        [self.navigationController popToViewController:self animated:YES];
    }
}

- (void)didConnected
{
    [self hideActivity];
    [self showActivityWithText:NSLS(@"kJoiningGame")];
        
    NSString* userId = [_userManager userId];    
    if (userId == nil){
        _isTryJoinGame = NO;
        PPDebug(@"<didConnected> Friend Room, but user Id nil???");
        [[DrawGameService defaultService] disconnectServer];
        return;
    }
    
    if (_isTryJoinGame){
        [[DrawGameService defaultService] registerObserver:self];
        [[DrawGameService defaultService] joinFriendRoom:[_userManager userId] 
                                                  roomId:[_currentSelectRoom roomId]
                                                roomName:[_currentSelectRoom roomName]
                                                nickName:[_userManager nickName]
                                                  avatar:[_userManager avatarURL]
                                                  gender:[_userManager isUserMale]
                                                location:[_userManager location]  
                                               userLevel:[[LevelService defaultService] level]         
                                          guessDiffLevel:[ConfigManager guessDifficultLevel]
                                             snsUserData:[_userManager snsUserData]];
    }
    
    _isTryJoinGame = NO;    
}

- (void)didJoinGame:(GameMessage *)message
{
    _currentSelectRoom.myStatus = UserJoined;
    
    [[DrawGameService defaultService] unregisterObserver:self];
    
    [self hideActivity];
    if ([message resultCode] == 0){
        [self popupHappyMessage:NSLS(@"kJoinGameSucc") title:@""];
    }
    else{
        NSString* text = [NSString stringWithFormat:NSLS(@"kJoinGameFailure")];
        [self popupUnhappyMessage:text title:@""];
        [[DrawGameService defaultService] disconnectServer];
        return;
    }
    
    [RoomController enterRoom:self isFriendRoom:YES];
}

- (void)reloadTableViewDataSource
{
    _currentStartIndex = 0;
    [self updateRoomList];
}

- (void)loadMoreTableViewDataSource
{
    [self updateRoomList];
}


- (void)updateNoRoomTip
{
    if ([dataList count] == 0) {
        self.dataTableView.hidden = YES;
        self.noRoomTips.hidden = NO;
    }else{
        self.dataTableView.hidden = NO;
        self.noRoomTips.hidden = YES;
    }
}


@end
