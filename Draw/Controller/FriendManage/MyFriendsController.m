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

- (void)dealloc {
    [titleLabel release];
    [editButton release];
    [myFollowButton release];
    [myFanButton release];
    [searchUserButton release];
    [_myFollowList release];
    [_myFanList release];
    [tipsLabel release];
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
    
    [searchUserButton setTitle:NSLS(@"kAddFriend") forState:UIControlStateNormal];
    [searchUserButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    
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
    NSString *indentifier = [FriendCell getCellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [FriendCell createCell:self];
    }
    
    Friend *friend = [dataList objectAtIndex:[indexPath row]];
    [cell setCellByFriend:friend indexPath:indexPath];
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
}


- (IBAction)clickMyFan:(id)sender
{
    myFollowButton.selected = NO;
    myFanButton.selected = YES;
    [self setAndReloadData:_myFanList];
    
    editButton.selected = NO;
    [dataTableView setEditing:NO animated:YES];
    editButton.hidden = YES;
}


- (IBAction)clickEdit:(id)sender
{
    editButton.selected = !editButton.selected;
    [dataTableView setEditing:editButton.selected animated:YES];
}


- (IBAction)clickSearchUser:(id)sender
{
    SearchUserController *searchUser  = [[SearchUserController alloc] init];
    [self.navigationController pushViewController:searchUser animated:YES];
    [searchUser release];
}


#pragma -mark Custom methods
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
    if ([_myFollowList count] == 0) {
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


#pragma -mark FriendServiceDelegate Method
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

@end
