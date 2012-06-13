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
- (void)openChatDetail:(NSString *)friendUserId friendNickname:(NSString *)friendNickname;
- (void)hideSelectView:(BOOL)animated;

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
    [titleLabel setText:NSLS(@"kChatListTitle")];
    
    
    //test data
//    [[MessageTotalManager defaultManager] createMessageTotalWithUserId:[[UserManager defaultManager] userId]
//                                                          friendUserId:@"123" 
//                                                        friendNickName:@"张三" 
//                                                          friendAvatar:@"http://www.xiaake.cn/uploads/120606/9_094247_8.jpg" 
//                                                            latestFrom:@"123"
//                                                              latestTo:[[UserManager defaultManager] userId]
//                                                        latestDrawData:nil 
//                                                            latestText:@"早上好啊" 
//                                                      latestCreateDate:[NSDate date] 
//                                                       totalNewMessage:[NSNumber numberWithInt:1] 
//                                                          totalMessage:[NSNumber numberWithInt:10]];
//    
//    [[MessageTotalManager defaultManager] createMessageTotalWithUserId:[[UserManager defaultManager] userId]
//                                                          friendUserId:@"456" 
//                                                        friendNickName:@"李四" 
//                                                          friendAvatar:@"http://www.xiaake.cn/uploads/120606/9_094247_2.jpg" 
//                                                            latestFrom:[[UserManager defaultManager] userId]
//                                                              latestTo:@"456" 
//                                                        latestDrawData:nil 
//                                                            latestText:@"问那么多问为什么干嘛" 
//                                                      latestCreateDate:[NSDate date] 
//                                                       totalNewMessage:[NSNumber numberWithInt:1] 
//                                                          totalMessage:[NSNumber numberWithInt:3]];
//    
//    [[ChatMessageManager defaultManager] createMessageWithMessageId:@"991" 
//                                                                  from:@"123" 
//                                                                    to:[[UserManager defaultManager] userId]
//                                                              drawData:nil 
//                                                            createDate:[NSDate date] 
//                                                                  text:@"早上好啊"  
//                                                                status:[NSNumber numberWithInt:MessageStatusNotRead]];
//    
//    [[ChatMessageManager defaultManager] createMessageWithMessageId:@"992" 
//                                                               from:@"456"
//                                                                 to:[[UserManager defaultManager] userId]
//                                                           drawData:nil 
//                                                         createDate:[NSDate date] 
//                                                               text:@"为什么"  
//                                                             status:[NSNumber numberWithInt:MessageStatusNotRead]];
//    
//    [[ChatMessageManager defaultManager] createMessageWithMessageId:@"993" 
//                                                               from:[[UserManager defaultManager] userId]
//                                                                 to:@"456" 
//                                                           drawData:nil 
//                                                         createDate:[NSDate date] 
//                                                               text:@"问那么多问什么干嘛"  
//                                                             status:[NSNumber numberWithInt:MessageStatusNotRead]];
    

    
    
    self.dataList = [[MessageTotalManager defaultManager] findAllMessageTotals];
    PPDebug(@"%d",[dataList count]);
    
    [self findAllMessageTotals];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self hideSelectView:NO];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setAddChatButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)findAllMessageTotals
{
    [[ChatService defaultService] findAllMessageTotals:self starOffset:0 maxCount:100];
}

- (void)didFindAllMessageTotals:(NSArray *)totalList
{
    self.dataList = totalList;
}


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

- (void)openChatDetail:(NSString *)friendUserId friendNickname:(NSString *)friendNickname
{
    ChatDetailController *controller = [[ChatDetailController alloc] initWithFriendUserId:friendUserId friendNickname:friendNickname];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSelectFriend:(id)sender {
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
