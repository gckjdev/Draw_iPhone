//
//  SearchRoomController.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchRoomController.h"
#import "Room.h"
#import "RoomManager.h"
#import "RoomService.h"
#import "ShareImageManager.h"
#import "RoomCell.h"
#import "ConfigManager.h"
#import "StringUtil.h"
#import "GameMessage.pb.h"
#import "RoomController.h"
#import "PPDebug.h"

@implementation SearchRoomController
@synthesize searchButton;
@synthesize searchFieldBg;
@synthesize searchField;
//@synthesize selectedRoom = _selectedRoom;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        roomService = [RoomService defaultService];
        imageManager = [ShareImageManager defaultManager];

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [searchFieldBg setImage:[imageManager inputImage]];
    [searchField setPlaceholder:NSLS(@"kRoomSearhTips")];
    [searchButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setSearchButton:nil];
    [self setSearchFieldBg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [searchField release];
    [searchButton release];
    [searchFieldBg release];
//    [_selectedRoom release];
    [super dealloc];
}
- (IBAction)clickSearhButton:(id)sender {
    [self.searchField resignFirstResponder];
    NSString *key = [self.searchField text];
    if ([key length] != 0) {
        [self showActivityWithText:@"kRoomSearching"];
        [roomService searchRoomsWithKeyWords:key offset:0 limit:20 delegate:self];        
    }else{
        [self popupMessage:NSLS(@"kTextNull") title:nil];
    }
}



- (void)startGame
{
    if (_isTryJoinGame)
        return;
    
    [[DrawGameService defaultService] setServerAddress:@"192.168.1.198"];
    [[DrawGameService defaultService] setServerPort:8080];    
    [[DrawGameService defaultService] connectServer:self];
    _isTryJoinGame = YES;    
    
}

#pragma mark - delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickSearhButton:searchButton];
    return YES;
}

- (void)didSearhRoomWithKey:(NSString *)key roomList:(NSArray*)roomList resultCode:(int)resultCode
{    
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kSearhRoomListFail") title:nil];
    }else{
        self.dataList = roomList;
        [self.dataTableView reloadData];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [RoomCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = [dataList count];
    if (number == 0) {
        tableView.hidden = YES;
    }else{
        tableView.hidden = NO;
    }
	return [dataList count];			// default implementation
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
    cell.inviteButton.hidden = cell.inviteInfoButton.hidden = YES;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.dataList count])
        return;
    
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    _currentSelectRoom = room;
    if (room == nil)
        return;
    if (room.myStatus == UserUnInvited) {
        InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kNotice") delegate:self];
        dialog.targetTextField.placeholder = NSLS(@"kInputRoomPassword");
        [dialog showInView:self.view];
    }else{
        [self popupMessage:@"invited" title:nil];
        [self startGame];
    }
    
}

- (void)clickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if ([targetText isEqualToString:_currentSelectRoom.password]) {
        [self popupMessage:@"password right" title:nil];
        [self startGame];
    }else{
        [self popupMessage:@"password wrong" title:nil];
    }
}
- (void)clickCancel:(InputDialog *)dialog
{
    
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
