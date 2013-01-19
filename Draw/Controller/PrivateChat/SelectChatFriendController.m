//
//  SelectChatFriendController.m
//  Draw
//
//  Created by haodong qiu on 12年6月13日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "SelectChatFriendController.h"
#import "Friend.h"
#import "FriendCell.h"
#import "FriendManager.h"
#import "ChatDetailController.h"
#import "ShareImageManager.h"
#import "FriendService.h"

@interface SelectChatFriendController ()

@property (retain, nonatomic) NSArray *myFollowList;
@property (retain, nonatomic) NSArray *myFanList;

- (IBAction)clickCancel:(id)sender;
//- (void)loadMyFollow;
//- (void)loadMyFans;
- (void)updateFriendsCount;
- (void)updateFriendsListFromLocal;
- (void)setAndReloadData:(NSArray *)newDataList;

@end

@implementation SelectChatFriendController
@synthesize delegate;
@synthesize cancelButton;
@synthesize titleLabel;
@synthesize followButton;
@synthesize fanButton;
@synthesize tipsLabel;
@synthesize myFollowList = _myFollowList;
@synthesize myFanList = _myFanList;


- (void)dealloc {
    PPRelease(_myFollowList);
    PPRelease(_myFanList);
    PPRelease(cancelButton);
    PPRelease(titleLabel);
    PPRelease(followButton);
    PPRelease(fanButton);
    PPRelease(tipsLabel);
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [titleLabel setText:NSLS(@"kSelectContacts")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [followButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [followButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [fanButton setBackgroundImage:[imageManager focusMeImage] forState:UIControlStateNormal];
    [fanButton setBackgroundImage:[imageManager focusMeSelectedImage] forState:UIControlStateSelected];
    [dataTableView setSeparatorColor:[UIColor clearColor]];
    
    followButton.selected = YES;
    
//    [self loadMyFollow];
//    [self loadMyFans];

    self.myFollowList = [[FriendManager defaultManager] findAllFollowFriends];
    self.myFanList = [[FriendManager defaultManager] findAllFanFriends];

    [self updateFriendsCount];
    if (followButton.selected) {
        [self setAndReloadData:_myFollowList];
    }else {
        [self setAndReloadData:_myFanList];
    }
    
}

/*
- (void)loadMyFollow
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[FriendService defaultService] findFriendsByType:FOLLOW viewController:self];
    });

    
}


- (void)loadMyFans
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[FriendService defaultService] findFriendsByType:FAN viewController:self];
    });
    
    
    

}
*/


- (void)didfindFriendsByType:(int)type friendList:(NSArray *)friendList result:(int)resultCode
{
    
    if (type == FOLLOW) {
        self.myFollowList = friendList;
    }else if(type == FAN)
    {
        self.myFanList = friendList;
    }
    
    [self updateFriendsCount];
    if (followButton.selected) {
        [self setAndReloadData:_myFollowList];
    }else {
        [self setAndReloadData:_myFanList];
    }
}


- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setTitleLabel:nil];
    [self setFollowButton:nil];
    [self setFanButton:nil];
    [self setTipsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    PPDebug(@"<SelectChatFriendController> viewWillAppear");
    
    [self updateFriendsListFromLocal];
}

#pragma mark - table view delegate
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
//    MyFriend *myFriend = []
//    Friend *friend = [dataList objectAtIndex:[indexPath row]];
//    [cell setCellWithFriend:friend indexPath:indexPath fromType:FromFriendList];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFriend *aFriend = [dataList objectAtIndex:indexPath.row];
//    [self.navigationController popViewControllerAnimated:NO];
    if (delegate && [delegate respondsToSelector:@selector(didSelectFriend:)]) {
        [delegate didSelectFriend:aFriend];
    }
}


- (IBAction)clickCancel:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didCancel)]) {
        [delegate didCancel];
    }
}

- (void)updateFriendsListFromLocal
{
    self.myFollowList = [[FriendManager defaultManager] findAllFollowFriends];
    self.myFanList = [[FriendManager defaultManager] findAllFanFriends];
    
    if (followButton.selected) {
        [self setAndReloadData:_myFollowList];
    }else if (fanButton.selected){
        [self setAndReloadData:_myFanList];
    } 
}

- (void)updateFriendsCount
{
    NSString *followTitle = NSLS(@"kFollow");
    NSString *fanTitle = NSLS(@"kFans") ;
    [followButton setTitle:[NSString stringWithFormat:@"%@ (%d)",followTitle,[_myFollowList count]] forState:UIControlStateNormal];
    [fanButton setTitle:[NSString stringWithFormat:@"%@ (%d)",fanTitle,[_myFanList count]] forState:UIControlStateNormal];
}

- (void)showNoDataTips
{
    dataTableView.hidden = YES;
    tipsLabel.hidden = NO;
    if (followButton.selected) {
        self.tipsLabel.text = NSLS(@"KNoFollowContacts");
    }else if (fanButton.selected){
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
}


- (IBAction)clickMyFollow:(id)sender
{
    followButton.selected = YES;
    fanButton.selected = NO;
    [self setAndReloadData:_myFollowList];
}


- (IBAction)clickMyFan:(id)sender
{
    followButton.selected = NO;
    fanButton.selected = YES;
    [self setAndReloadData:_myFanList];
}


@end
