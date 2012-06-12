//
//  ChatListController.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "ChatService.h"

@interface ChatListController : PPTableViewController<ChatServiceDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *addChatButton;

@end
