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

@interface SelectChatFriendController ()

@property (retain, nonatomic) NSArray *myFollowList;
@property (retain, nonatomic) NSArray *myFanList;

- (IBAction)clickCancel:(id)sender;
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
    [tipsLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [titleLabel setText:NSLS(@"kSelectContacts")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [followButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [followButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [fanButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [fanButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    
    self.myFollowList = [[FriendManager defaultManager] findAllFollowFriends];
    self.myFanList = [[FriendManager defaultManager] findAllFanFriends];
    
    followButton.selected = YES;
    [self setAndReloadData:_myFollowList];
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
    
    Friend *friend = [dataList objectAtIndex:[indexPath row]];
    [cell setCellWithFriend:friend indexPath:indexPath fromType:FromFriendList];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *aFriend = [dataList objectAtIndex:indexPath.row];
    if (delegate && [delegate respondsToSelector:@selector(didSelectFriend:)]) {
        [delegate didSelectFriend:aFriend];
    }
}


- (IBAction)clickCancel:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didCancel)]) {
        [delegate didCancel];
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
        self.tipsLabel.text = NSLS(@"kNoFollow");
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
