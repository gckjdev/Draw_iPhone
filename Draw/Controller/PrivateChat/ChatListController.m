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
#import "ChatMessage.h"
#import "CommonUserInfoView.h"
#import "DiceUserInfoView.h"

#import "UserManager.h"

@interface ChatListController ()
{
    dispatch_once_t onceToken;
}
@property (nonatomic, retain) SelectChatFriendController *selectChatFriendController;

- (IBAction)clickBack:(id)sender;

- (void)findAllMessageTotals;
- (void)hideSelectView:(BOOL)animated;
- (void)openChatDetail:(NSString *)friendUserId 
        friendNickname:(NSString *)friendNickname 
          friendAvatar:(NSString *)friendAvatar 
          friendGender:(NSString *)friendGender;
- (void)updateNoDataTips;

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

- (void)setEmptyTableCanScroll
{
    CGRect frame = dataTableView.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height-0.0001);
    dataTableView.frame = frame;
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
    
    [self updateNoDataTips];
    
    [self setEmptyTableCanScroll];
}


- (void)viewDidAppear:(BOOL)animated
{
    //PPDebug(@"ChatListController viewDidAppear");
}


- (void)viewWillAppear:(BOOL)animated
{
    //PPDebug(@"ChatListController viewWillAppear");
    
    dispatch_once(&onceToken, ^{
        [self findAllMessageTotals];
    });
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
    [self showActivityWithText:NSLS(@"kLoading")];
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


- (void)openChatDetail:(NSString *)friendUserId 
        friendNickname:(NSString *)friendNickname 
          friendAvatar:(NSString *)friendAvatar 
          friendGender:(NSString *)friendGender
{
//    ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:friendUserId friendNickname:friendNickname friendAvatar:friendAvatar];
    ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:friendUserId 
                                                                           friendNickname:friendNickname 
                                                                             friendAvatar:friendAvatar 
                                                                             friendGender:friendGender];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


#define NODATA_LABEL_TAG  90
#define NODATA_LABEL_FONT  (([DeviceDetection isIPAD])?(28.0):(14.0))
- (void)updateNoDataTips
{
    UILabel *noDataLabel = (UILabel *)[dataTableView viewWithTag:NODATA_LABEL_TAG];
    if (noDataLabel == nil) {
        noDataLabel = [[UILabel alloc] init];
        noDataLabel.frame = CGRectMake(0, 20, dataTableView.frame.size.width, 60);
        noDataLabel.tag = NODATA_LABEL_TAG;
        noDataLabel.font = [UIFont systemFontOfSize:NODATA_LABEL_FONT];
        noDataLabel.text = NSLS(@"kNoChatListInfo");
        noDataLabel.backgroundColor = [UIColor clearColor];
        //noDataLabel.backgroundColor = [UIColor grayColor];
        noDataLabel.textAlignment = UITextAlignmentCenter;
        noDataLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1];
        [dataTableView addSubview:noDataLabel];
        [noDataLabel release];
    }
    
    if ([dataList count] == 0) {
        noDataLabel.hidden = NO;
    }else {
        noDataLabel.hidden = YES;
    }
}


#pragma mark - ChatServiceDelegate methods
- (void)didFindAllMessageTotals:(NSArray *)totalList resultCode:(int)resultCode;
{
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];
    
    //PPDebug(@"ChatListController:didFindAllmessageTotals");
    self.dataList = totalList;
    [dataTableView reloadData];
    
    [self updateNoDataTips];
    
    //PPDebug(@"ChatListController:didFindAllmessageTotals finish");
}


- (void)didDeleteMessageTotal:(NSString *)friendUserId resultCode:(int)resultCode
{

}


- (void)didDeleteMessage:(int)resultCode
{
    
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
    cell.chatCellDelegate = self;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTotal *messageTotal = (MessageTotal *)[dataList objectAtIndex:indexPath.row];
    NSString *selectFriendUserId = messageTotal.friendUserId;
    NSString *selectFriendNickname = messageTotal.friendNickName;
    NSString *selectFriendAvatar = messageTotal.friendAvatar;
    NSString *selectFriendGender = messageTotal.friendGender;
    
    [self openChatDetail:selectFriendUserId 
          friendNickname:selectFriendNickname 
            friendAvatar:selectFriendAvatar 
            friendGender:selectFriendGender];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MessageTotal *messageTotal = [dataList objectAtIndex:indexPath.row];
        NSString *friendUserId = messageTotal.friendUserId;
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:dataList];
        [mutableArray removeObjectAtIndex:indexPath.row];
        self.dataList = mutableArray;
        [mutableArray release];
        [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        //delete message total
        [[ChatService defaultService] deleteMessageTotal:self friendUserId:friendUserId];
        
        //delete all messages about this friend
        
        NSArray *localMessageList = [[ChatMessageManager defaultManager] findMessagesByFriendUserId:friendUserId];
        NSMutableArray *mutableIdList = [[NSMutableArray alloc] init];
        for (ChatMessage *chatMessage in localMessageList) {
            [mutableIdList addObject:chatMessage.messageId] ;
        }
        [[ChatService defaultService] deleteMessage:self messageIdList:mutableIdList];
        [mutableIdList release];
    }
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
//        CGRect frame = _selectChatFriendController.view.frame;
//        _selectChatFriendController.view.frame = CGRectMake(0, self.view.frame.size.height, frame.size.width, frame.size.height);
    }
    

//    CGRect frame = _selectChatFriendController.view.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
//    _selectChatFriendController.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _selectChatFriendController.view.frame = [[UIScreen mainScreen] bounds];
    [UIImageView commitAnimations];
    
    [self.view addSubview:_selectChatFriendController.view];
}


#pragma mark - SelectChatFriendDelagate
- (void)didSelectFriend:(Friend *)aFriend;
{
    NSString *nickname = [[FriendManager defaultManager] getFriendNick:aFriend];
    [self openChatDetail:aFriend.friendUserId 
          friendNickname:nickname 
            friendAvatar:aFriend.avatar 
            friendGender:aFriend.gender];
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


#pragma mark - ChatCellDelegate method
- (void)didClickAvatar:(NSIndexPath *)aIndexPath
{
    MessageTotal *messageTotal = [dataList objectAtIndex:aIndexPath.row];
    
    if (isDrawApp()) {
        [CommonUserInfoView showUser:messageTotal.friendUserId 
                            nickName:messageTotal.friendNickName 
                              avatar:messageTotal.friendAvatar 
                              gender:messageTotal.friendGender 
                            location:nil 
                               level:1
                             hasSina:NO 
                               hasQQ:NO 
                         hasFacebook:NO 
                          infoInView:self];
    }
    if (isDiceApp()) {
        [DiceUserInfoView showUser:messageTotal.friendUserId 
                            nickName:messageTotal.friendNickName 
                              avatar:messageTotal.friendAvatar 
                              gender:messageTotal.friendGender 
                            location:nil 
                               level:1
                             hasSina:NO 
                               hasQQ:NO 
                         hasFacebook:NO 
                          infoInView:self];
    }
}



@end
