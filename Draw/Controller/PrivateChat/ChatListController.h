//
//  ChatListController.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "ChatService.h"
#import "ChatCell.h"
#import "FriendController.h"
#import "CommonTabController.h"
#import "ChatDetailController.h"

@interface ChatListController : CommonTabController<ChatServiceDelegate, FriendControllerDelegate, ChatCellDelegate, ChatDetailControllerDelegate>


@property (retain, nonatomic) IBOutlet UIButton *addChatButton;
- (IBAction)clickAddChatButton:(id)sender;
@end
