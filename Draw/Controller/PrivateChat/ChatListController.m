//
//  ChatListController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatListController.h"
#import "ChatCell.h"
#import "ShareImageManager.h"
#import "ChatDetailController.h"
#import "MessageTotal.h"
#import "MessageTotalManager.h"
#import "ChatMessageManager.h"
#import "SelectChatFriendController.h"
#import "Friend.h"
#import "FriendManager.h"

#import "UserManager.h"

@interface ChatListController ()

@property (nonatomic, retain) SelectChatFriendController *selectChatFriendController;

- (IBAction)clickBack:(id)sender;

- (void)findAllMessageTotals;
- (void)hideSelectView:(BOOL)animated;
- (void)openChatDetail:(NSString *)friendUserId friendNickname:(NSString *)friendNickname friendAvatar:(NSString *)friendAvatar;
- (void)showNoDataTips;

@end

@implementation ChatListController

@synthesize titleLabel;
@synthesize addChatButton;
@synthesize tipsLabel;
@synthesize selectChatFriendController = _selectChatFriendController;


- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(addChatButton);
    PPRelease(_selectChatFriendController);
    [tipsLabel release];
    [super dealloc];
}


- (void)viewDidLoad
{
    self.supportRefreshHeader = YES;
    [super viewDidLoad];
    [titleLabel setText:NSLS(@"kChatListTitle")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [addChatButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [addChatButton setTitle:NSLS(@"kAddChat") forState:UIControlStateNormal];
    
    self.dataList = [[MessageTotalManager defaultManager] findAllMessageTotals];
    
    if ([dataList count] == 0) {
        [self showNoDataTips];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    //PPDebug(@"ChatListController viewDidAppear");
}


- (void)viewWillAppear:(BOOL)animated
{
    //PPDebug(@"ChatListController viewWillAppear");
    [self findAllMessageTotals];
    [self hideSelectView:NO];
    [super viewWillAppear:animated];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setAddChatButton:nil];
    [self setTipsLabel:nil];
    [super viewDidUnload];
}


#pragma mark - custom methods
- (void)findAllMessageTotals
{
    [[ChatService defaultService] findAllMessageTotals:self starOffset:0 maxCount:100];
}


- (void)hideSelectView:(BOOL)animated
{
    if (_selectChatFriendController) {
        CGRect frame = _selectChatFriendController.view.frame;
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            _selectChatFriendController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
            [UIImageView commitAnimations];
        }else {
            _selectChatFriendController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
        }
    }
}


- (void)openChatDetail:(NSString *)friendUserId friendNickname:(NSString *)friendNickname friendAvatar:(NSString *)friendAvatar
{
    ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:friendUserId friendNickname:friendNickname friendAvatar:friendAvatar];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


- (void)showNoDataTips
{
    dataTableView.hidden = YES;
    tipsLabel.hidden = NO;
    self.tipsLabel.text = NSLS(@"kNoChatListInfo");
}


#pragma mark - ChatServiceDelegate methods
- (void)didFindAllMessageTotals:(NSArray *)totalList resultCode:(int)resultCode;
{
    [self dataSourceDidFinishLoadingNewData];
    
    PPDebug(@"ChatListController:didFindAllmessageTotals");
    self.dataList = totalList;
    [dataTableView reloadData];
    
    if ([dataList count] == 0) {
        [self showNoDataTips];
    }
    
    PPDebug(@"ChatListController:didFindAllmessageTotals finish");
}


#pragma mark - table methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatCell getCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ChatCell getCellIdentifier];
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ChatCell createCell:self];
    }
    
    MessageTotal *messageTotal = (MessageTotal *)[dataList objectAtIndex:indexPath.row];
    [cell setCellByMessageTotal:messageTotal indexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTotal *messageTotal = (MessageTotal *)[dataList objectAtIndex:indexPath.row];
    NSString *selectFriendUserId = messageTotal.friendUserId;
    NSString *selectFriendNickname = messageTotal.friendNickName;
    NSString *selectFriendAvatar = messageTotal.friendAvatar;
    [self openChatDetail:selectFriendUserId friendNickname:selectFriendNickname friendAvatar:selectFriendAvatar];
}


#pragma mark - button actions
- (IBAction)clickBack:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickAddChatButton:(id)sender 
{
    if (_selectChatFriendController == nil) {
        SelectChatFriendController *scfc = [[SelectChatFriendController alloc] init];
        scfc.delegate = self;
        self.selectChatFriendController = scfc;
        [scfc release];
        [self.view addSubview:_selectChatFriendController.view];
        CGRect frame = _selectChatFriendController.view.frame;
        _selectChatFriendController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
    }
    
    CGRect frame = _selectChatFriendController.view.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    _selectChatFriendController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [UIImageView commitAnimations]; 
}


#pragma mark - SelectChatFriendDelagate 
- (void)didSelectFriend:(Friend *)aFriend;
{
    NSString *nickname = [[FriendManager defaultManager] getFriendNick:aFriend];
    [self openChatDetail:aFriend.friendUserId friendNickname:nickname friendAvatar:aFriend.avatar];
    [self hideSelectView:NO];
}


- (void)didCancel
{
    [self hideSelectView:YES];
}


#pragma mark - pull down to refresh
// When "pull down to refresh" in triggered, this function will be called  
- (void)reloadTableViewDataSource
{
    [self findAllMessageTotals];
}


@end
