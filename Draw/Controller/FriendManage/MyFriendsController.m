//
//  MyFriendsController.m
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "MyFriendsController.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"
#import "SearchUserController.h"
#import "DeviceDetection.h"
#import "FriendService.h"
#import "LogUtil.h"
#import "FriendManager.h"
#import "Friend.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "GameNetworkConstants.h"
#import "Room.h"
#import "RoomManager.h"
#import "RoomService.h"


@interface MyFriendsController ()

- (void)updateFriendsCount;
- (void)setAndReloadData:(NSArray *)newDataList;
- (void)showNoDataTips;
- (void)loadMyFollow;
- (void)loadMyFans;

@end

@implementation MyFriendsController
@synthesize titleLabel;
@synthesize editButton;
@synthesize myFollowButton;
@synthesize myFanButton;
@synthesize searchUserButton;
@synthesize myFollowList = _myFollowList;
@synthesize myFanList = _myFanList;
@synthesize tipsLabel;
@synthesize room = _room;

- (void)dealloc {
    [titleLabel release];
    [editButton release];
    [myFollowButton release];
    [myFanButton release];
    [searchUserButton release];
    [_myFollowList release];
    [_myFanList release];
    [tipsLabel release];
    [_room release];
    [_selectedSet release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isInviteFriend = NO;
    }
    return self;
}

- (id)initWithRoom:(Room *)room
{
    self = [super init];
    if (self) {
        self.room = room;
        _isInviteFriend = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [titleLabel setText:NSLS(@"kMyFriends")];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [editButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    [editButton setTitle:NSLS(@"kEdit") forState:UIControlStateNormal];
    [editButton setTitle:NSLS(@"kDone") forState:UIControlStateSelected];
    
    NSString *followTitle = NSLS(@"kFollow");
    NSString *fanTitle = NSLS(@"kFans") ;
    [myFollowButton setTitle:followTitle forState:UIControlStateNormal];
    [myFanButton setTitle:fanTitle forState:UIControlStateNormal];
    [myFollowButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [myFollowButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [myFanButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [myFanButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    myFollowButton.selected = YES;
    
    if (_isInviteFriend) {
        searchUserButton.hidden = YES;
        editButton.hidden = YES;
        [editButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
        [editButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
        _selectedSet = [[NSMutableSet alloc] init];
        CGPoint origin = dataTableView.frame.origin;
        CGSize size = dataTableView.frame.size;
        dataTableView.frame = CGRectMake(origin.x, origin.y, size.width, size.height + 40);
    }else{
        [searchUserButton setTitle:NSLS(@"kAddFriend") forState:UIControlStateNormal];
        [searchUserButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    }
    dataTableView.separatorColor = [UIColor clearColor];
    
    tipsLabel.hidden = YES;
    dataTableView.hidden = YES;
    
    [self loadMyFollow];
    [self loadMyFans];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setEditButton:nil];
    [self setMyFollowButton:nil];
    [self setMyFanButton:nil];
    [self setSearchUserButton:nil];
    [self setTipsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    PPDebug(@"<MyFriendsController> viewWillAppear");
    self.myFollowList = [[FriendManager defaultManager] findAllFollowFriends];
    self.myFanList = [[FriendManager defaultManager] findAllFanFriends];
    
    if (myFollowButton.selected) {
        [self setAndReloadData:_myFollowList];
    }else if (myFanButton.selected){
        [self setAndReloadData:_myFanList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FriendCell getCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == nil) {
        return nil;
    }
    NSString *indentifier = [FriendCell getCellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [FriendCell createCell:self];
    }
    
    Friend *friend = [dataList objectAtIndex:[indexPath row]];
    if (_isInviteFriend) {
        cell.inviteDelegate = self;
        [cell setCellWithFriend:friend indexPath:indexPath fromType:FromInviteList];        
        RoomUserStatus stat = [[RoomManager defaultManager] aFriend:friend statusAtRoom:self.room];
        cell.followButton.hidden = YES;
        if ([_selectedSet containsObject:friend]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.statusLabel.hidden = YES;
        }else{        
            cell.statusLabel.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (stat == UserInvited) {
                [cell.statusLabel setText:NSLS(@"kInvited")];
            }else if(stat == UserJoined || stat == UserPlaying)
            {
                [cell.statusLabel setText:NSLS(@"kJoined")];
            }else{
                cell.followButton.hidden = NO;
                cell.statusLabel.hidden = YES;
                [cell.followButton setTitle:NSLS(@"kInvite") forState:UIControlStateNormal];
            }
        }
        
    }else{
        cell.inviteDelegate = nil;
        [cell setCellWithFriend:friend indexPath:indexPath fromType:FromFriendList];        
    }
//    cell.indexPath = indexPath;
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing)
        return UITableViewCellEditingStyleNone;
    else {
        return UITableViewCellEditingStyleDelete;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend = (Friend *)[dataList objectAtIndex:indexPath.row];
    [[FriendService defaultService] unFollowUser:friend.friendUserId viewController:self];
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma -mark Button Action
- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickMyFollow:(id)sender
{
    editButton.hidden = NO;
    myFollowButton.selected = YES;
    myFanButton.selected = NO;
    [self setAndReloadData:_myFollowList];

    if (_isInviteFriend) {
        editButton.hidden = ([_selectedSet count] == 0);
    }
}


- (IBAction)clickMyFan:(id)sender
{
    myFollowButton.selected = NO;
    myFanButton.selected = YES;
    [self setAndReloadData:_myFanList];
    
    editButton.selected = NO;
    [dataTableView setEditing:NO animated:YES];
    editButton.hidden = YES;
    
    if (_isInviteFriend) {
        editButton.hidden = ([_selectedSet count] == 0);
    }

}


- (IBAction)clickEdit:(id)sender
{
    if (_isInviteFriend) {
        //invite users
        [self showActivityWithText:NSLS(@"kInviting")];
        [[RoomService defaultService] inviteUsers:_selectedSet toRoom:self.room delegate:self];
    }else{
        editButton.selected = !editButton.selected;
        [dataTableView setEditing:editButton.selected animated:YES];
    }
}


- (IBAction)clickSearchUser:(id)sender
{
    SearchUserController *searchUser  = [[SearchUserController alloc] init];
    [self.navigationController pushViewController:searchUser animated:YES];
    [searchUser release];
}



#pragma mark - Custom methods
- (void)showNoDataTips
{
    dataTableView.hidden = YES;
    tipsLabel.hidden = NO;
    if (myFollowButton.selected) {
        self.tipsLabel.text = NSLS(@"kNoFollow");
    }else if (myFanButton.selected){
        self.tipsLabel.text = NSLS(@"kNoFans");
    }
}


- (void)setAndReloadData:(NSArray *)newDataList
{
    self.dataList = newDataList;
    [self updateFriendsCount];
    
    if ([dataList count] == 0) {
        [self showNoDataTips];
    }
    else {
        dataTableView.hidden = NO;
        tipsLabel.hidden = YES;
        [dataTableView reloadData];
    }
    
    //if follow count is 0, hide the editButton
    if ([_myFollowList count] == 0 || _isInviteFriend) {
        editButton.hidden = YES;
    }else {
        editButton.hidden = NO;
    }
}


- (void)updateFriendsCount
{
    NSString *followTitle = NSLS(@"kFollow");
    NSString *fanTitle = NSLS(@"kFans") ;
    [myFollowButton setTitle:[NSString stringWithFormat:@"%@ (%d)",followTitle,[_myFollowList count]] forState:UIControlStateNormal];
    [myFanButton setTitle:[NSString stringWithFormat:@"%@ (%d)",fanTitle,[_myFanList count]] forState:UIControlStateNormal];
}


- (void)loadMyFollow
{
    [[FriendService defaultService] findFriendsByType:FOLLOW viewController:self];
}


- (void)loadMyFans
{
    [[FriendService defaultService] findFriendsByType:FAN viewController:self];
}


#pragma mark - FriendServiceDelegate Method
- (void)didfindFriendsByType:(int)type friendList:(NSArray *)friendList result:(int)resultCode
{
    //    if (resultCode != 0) {
    //        if (type == FOLLOW) {
    //            [self popupMessage:NSLS(@"kUpdateFollowFailed") title:nil];
    //        }else if(type == FAN) {
    //            [self popupMessage:NSLS(@"kUpdateFansFailed") title:nil];
    //        }
    //    }
    
    if (type == FOLLOW) {
        self.myFollowList = friendList;
    }else if(type == FAN)
    {
        self.myFanList = friendList;
    }
    
    [self updateFriendsCount];
    if (myFollowButton.selected) {
        [self setAndReloadData:_myFollowList];
    }else {
        [self setAndReloadData:_myFanList];
    }
}


- (void)didUnFollowUser:(int)resultCode
{
    if (resultCode == 0) {
        self.myFollowList = [[FriendManager defaultManager] findAllFollowFriends];
        [self setAndReloadData:_myFollowList];
    }else {
        [self popupMessage:NSLS(@"kUnfollowFailed") title:nil];
    }
}

#pragma mark -  FriendDelegate Method

- (void)didInviteFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath) {
        Friend *friend = nil;
        if (myFollowButton.selected) {
            friend = [self.myFollowList objectAtIndex:indexPath.row];
        }else{
            friend = [self.myFanList objectAtIndex:indexPath.row];
        }
        if (friend) {
            [_selectedSet addObject:friend];
            [self.dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                      withRowAnimation:UITableViewRowAnimationFade];
            editButton.hidden = NO;
        }
    }
}

#pragma mark -  Room Service Delegate Method
- (void)updateRoomUsers:(NSSet *)friendSet
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.room.userList];
    for (Friend *friend in friendSet) {
        RoomUser *user = [[RoomUser alloc] init];
        user.userId = friend.friendUserId;
        user.nickName = friend.nickName;
        user.avatar = friend.avatar;
        user.gender = friend.gender;
        user.status = UserInvited;
        [array addObject:user];
    }
    self.room.userList = array;
    [self.dataTableView reloadData];
}
- (void)didInviteFriends:(NSSet *)friendSet resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kInviteFail") title:nil];
    }else{
        [self popupMessage:NSLS(@"kInviteSuccess") title:nil];
//        [self.navigationController popViewControllerAnimated:YES];
        [self updateRoomUsers:friendSet];
    }
}
@end
