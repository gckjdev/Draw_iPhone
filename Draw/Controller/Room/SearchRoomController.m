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
#import "DeviceDetection.h"
#import "LevelService.h"

@interface SearchRoomController ()

@end


#define SEARCH_ROOM_LIMIT 50

@implementation SearchRoomController
@synthesize searchButton;
@synthesize searchFieldBg;
@synthesize titleLabel;
@synthesize tipsLabel;
@synthesize searchField;

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

- (void)updateRoomList
{
    [roomService searchRoomsWithKeyWords:_keyword offset:_currentStartIndex limit:SEARCH_ROOM_LIMIT delegate:self];
    [self showActivityWithText:NSLS(@"kRoomSearching")];
}


- (void)viewDidLoad
{
    [self setSupportRefreshFooter:YES];
    [super viewDidLoad];
    [searchFieldBg setImage:[imageManager inputImage]];
    [searchField setPlaceholder:NSLS(@"kRoomSearhTips")];
    [searchButton setTitle:NSLS(@"kSearch") forState:UIControlStateNormal];
    [searchButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [titleLabel setText:NSLS(@"kSearchRoom")];
    [self.tipsLabel setText:NSLS(@"kSearchNoResult")];
    [self.tipsLabel setHidden:YES];
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
    [self setSearchButton:nil];
    [self setSearchFieldBg:nil];
    [self setTitleLabel:nil];
    [self setTipsLabel:nil];
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

- (void)dealloc {
        
    PPRelease(searchField);
    PPRelease(searchButton);
    PPRelease(searchFieldBg);
    PPRelease(titleLabel);
    PPRelease(tipsLabel);
    [super dealloc];
}
- (IBAction)clickSearhButton:(id)sender {
    [self.searchField resignFirstResponder];
    _keyword = [self.searchField text];
    if ([_keyword length] != 0) {
        _currentStartIndex = 0;
        [self updateRoomList];
    }else{
        [self popupMessage:NSLS(@"kContentNull") title:nil];
    }
}



- (void)startGame
{
    if (_isTryJoinGame || _currentSelectRoom == nil)
        return;
    [self showActivityWithText:NSLS(@"kConnectingServer")];

    [[DrawGameService defaultService] setServerAddress:_currentSelectRoom.gameServerAddress];
    [[DrawGameService defaultService] setServerPort:_currentSelectRoom.gameServerPort];    
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
    [self dataSourceDidFinishLoadingMoreData];
    
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kSearhRoomListFail") title:nil];
    }else{
        if (_currentStartIndex == 0) {
                self.dataList = roomList;
        }else{
            NSMutableArray *array = [NSMutableArray array];
            if ([self.dataList count] != 0) {
                [array addObjectsFromArray:self.dataList];
            }
            if ([roomList count] != 0) {
                [array addObjectsFromArray:roomList];
            }
            self.dataList = array;
        }
        _currentStartIndex += [roomList count];
        
        if ([roomList count] == SEARCH_ROOM_LIMIT) {
            self.noMoreData = NO;
        }else{
            self.noMoreData = YES;
        }

        self.tipsLabel.hidden = ([self.dataList count] != 0);
        [self.dataTableView reloadData];
    }
    
    // I don't know why, but Xiaotao Wang tells me to deal with it likes this. He will check it later.
    [self dataSourceDidFinishLoadingMoreData];
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
        cell.roomCellType = RoomCellTypeSearchRoom;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    [cell setInfo:room];
    return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [self.dataList count])
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
        [self startGame];
    }
    
}

- (void)loadMoreTableViewDataSource
{
    [self updateRoomList];
}


- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if ([targetText isEqualToString:_currentSelectRoom.password]) {
        if (_currentSelectRoom) {
            [roomService joinNewRoom:_currentSelectRoom delegate:self];           
            [self showActivityWithText:NSLS(@"kConnectingServer")];
        }

    }else{
        [self popupMessage:NSLS(@"kPsdNotMatch") title:nil];
    }
}
- (void)didClickCancel:(InputDialog *)dialog
{
    
}

- (void)didJoinNewRoom:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self startGame];
    }else{
        [self popupMessage:NSLS(@"kJoinGameFailure") title:nil];
    }
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
                                                location:[_userManager location]     
                                               userLevel:[[LevelService defaultService] level]         
                                          guessDiffLevel:[ConfigManager guessDifficultLevel]
                                             snsUserData:[_userManager snsUserData]];
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
