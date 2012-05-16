//
//  FriendRoomController.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FriendRoomController.h"
#import "ShareImageManager.h"
#import "MyFriendsController.h"
#import "SearchRoomController.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "Room.h"
#import "RoomCell.h"
#import "DrawGameService.h"
#import "ConfigManager.h"
#import "StringUtil.h"
#import "GameMessage.pb.h"
#import "RoomController.h"
#import "MyFriendsController.h"


#define INVITE_LIMIT 12

@implementation FriendRoomController
@synthesize editButton;
@synthesize createButton;
@synthesize searchButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _userManager = [UserManager defaultManager];
        roomService = [RoomService defaultService];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)initButtons
{
    //bg image
    ShareImageManager *manager = [ShareImageManager defaultManager];
    [self.editButton setBackgroundImage:[manager redImage] forState:UIControlStateNormal];
    [self.createButton setBackgroundImage:[manager greenImage] forState:UIControlStateNormal];
    [self.searchButton setBackgroundImage:[manager orangeImage] forState:UIControlStateNormal];
    //text
    [self.editButton setTitle:NSLS(@"kEdit") forState:UIControlStateNormal];
    [self.createButton setTitle:NSLS(@"kCreateRoom") forState:UIControlStateNormal];
    [self.searchButton setTitle:NSLS(@"kSearchRoom") forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataList = [[[NSMutableArray alloc] init]autorelease];
    [self initButtons];
    [self showActivityWithText:NSLS(@"kLoading")];
    [roomService findMyRoomsWithOffset:0 limit:20 delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.dataTableView reloadData];
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
    [self setEditButton:nil];
    [self setCreateButton:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [editButton release];
    [createButton release];
    [searchButton release];
    [super dealloc];
}
- (IBAction)clickEditButton:(id)sender {

}

- (IBAction)clickCreateButton:(id)sender {
    RoomPasswordDialog *rDialog = [RoomPasswordDialog dialogWith:NSLS(@"kCreateRoom") delegate:self];
    NSInteger index = rand() % 97;
    NSString *nick = [[UserManager defaultManager]nickName];
    NSString *string = [NSString stringWithFormat:NSLS(@"kRoomNameNumber"),nick,index];
    
    rDialog.targetTextField.text = string;
    [rDialog showInView:self.view];
}

- (void)clickOk:(InputDialog *)dialog targetText:(NSString *)targetText
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
        MyFriendsController *mfc = [[MyFriendsController alloc] initWithRoom:room];
        [self.navigationController pushViewController:mfc animated:YES];
        [mfc release];
    }
}

- (IBAction)clickSearchButton:(id)sender {
    SearchRoomController *src = [[SearchRoomController alloc] init];
    [self.navigationController pushViewController:src animated:YES];
    [src release];
}

- (IBAction)clickMyFriendButton:(id)sender {
    MyFriendsController *mfc = [[MyFriendsController alloc] init];
    [self.navigationController pushViewController:mfc animated:YES];
    [mfc release];
}

- (void)didCreateRoom:(Room*)room resultCode:(int)resultCode;
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kCreateFail") title:nil];
    }else{
        PPDebug(@"room = %@", [room description]);
        if (room) {
            NSMutableArray *list = (NSMutableArray *)self.dataList;
            [list insertObject:room atIndex:0];
            [dataTableView beginUpdates];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            [self.dataTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            [dataTableView endUpdates];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.dataList count])
        return;
    
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    if (room == nil)
        return;
    
    if (_isTryJoinGame)
        return;
    
    [[DrawGameService defaultService] setServerAddress:@"192.168.1.198"];
    [[DrawGameService defaultService] setServerPort:8080];    
    [[DrawGameService defaultService] connectServer:self];
    _isTryJoinGame = YES;    
    
    _currentSelectRoom = room;    
}

- (void)didFindRoomByUser:(NSString *)userId roomList:(NSArray*)roomList resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kFindRoomListFail") title:nil];
    }else{
        if (roomList == nil) {
            [((NSMutableArray *)self.dataList) removeAllObjects];  ;            
        }else
        {
            self.dataList = roomList;            
        }
        [self.dataTableView reloadData];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [RoomCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [dataList count];
    if (count == 0) {
        tableView.hidden = YES;
    }else{
        tableView.hidden = NO;
    }
    return count;
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [RoomCell getCellIdentifier];
	RoomCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [RoomCell createCell:self];
	}
    cell.accessoryType = UITableViewCellAccessoryNone;
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    [cell setInfo:room];
    cell.indexPath = indexPath;
	return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"commitEditingStyle");
    
}

#pragma mark - Draw Game Service Delegate

- (void)didBroken
{
    _isTryJoinGame = NO;
    PPDebug(@"<didBroken> Friend Room");
    [self hideActivity];
    [self popupUnhappyMessage:NSLS(@"kNetworkFailure") title:@""];
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
                                          guessDiffLevel:[ConfigManager guessDifficultLevel]];
    }
    
    _isTryJoinGame = NO;    
}

- (void)didJoinGame:(GameMessage *)message
{
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

@end
