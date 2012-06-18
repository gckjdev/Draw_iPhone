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
- (void)openChatDetail:(NSString *)friendUserId friendNickname:(NSString *)friendNickname;

@end

@implementation ChatListController
@synthesize titleLabel;
@synthesize addChatButton;
@synthesize selectChatFriendController = _selectChatFriendController;


- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(addChatButton);
    PPRelease(_selectChatFriendController);
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [titleLabel setText:NSLS(@"kChatListTitle")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [addChatButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [addChatButton setTitle:NSLS(@"kAddChat") forState:UIControlStateNormal];
    
    self.dataList = [[MessageTotalManager defaultManager] findAllMessageTotals];
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


- (void)openChatDetail:(NSString *)friendUserId friendNickname:(NSString *)friendNickname
{
    ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:friendUserId friendNickname:friendNickname];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


#pragma mark - ChatServiceDelegate methods
- (void)didFindAllMessageTotals:(NSArray *)totalList resultCode:(int)resultCode;
{
    PPDebug(@"ChatListController:didFindAllmessageTotals");
    self.dataList = totalList;
    [dataTableView reloadData];
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
    [self openChatDetail:selectFriendUserId friendNickname:selectFriendNickname];
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
    [self openChatDetail:aFriend.friendUserId friendNickname:nickname];
    [self hideSelectView:NO];
}


- (void)didCancel
{
    [self hideSelectView:YES];
}

@end
