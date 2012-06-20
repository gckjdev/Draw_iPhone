//
//  ChatDetailController.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewController.h"
#import "ChatService.h"
#import "OfflineDrawViewController.h"
#import "ChatDetailCell.h"

@interface ChatDetailController : PPTableViewController<ChatServiceDelegate, UITextViewDelegate, OfflineDrawDelegate, ChatDetailCellDelegate>
 
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *graffitiButton;
@property (retain, nonatomic) IBOutlet UIView *inputBackgroundView;
@property (retain, nonatomic) IBOutlet UITextView *inputTextView;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UIImageView *inputTextBackgroundImage;
@property (retain, nonatomic) IBOutlet UIImageView *paperImageView;

- (id)initWithFriendUserId:(NSString *)frindUserId friendNickname:(NSString *)friendNickname friendAvatar:(NSString *)friendAvatar;

- (void)findAllMessages;

@end
