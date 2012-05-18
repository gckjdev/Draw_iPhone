//
//  ChatController.h
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "PPTableViewController.h"
#import "MessageCell.h"
#import "StableView.h"
#import "MessageManager.h"
#import "FriendService.h"
#import "InputDialog.h"

@class AvatarView;

@protocol ChatControllerDelegate <NSObject>
@optional
- (void)didSelectMessage:(NSString*)message;
- (void)didSelectExpression:(UIImage*)expression;

@end

@interface ChatController : PPTableViewController <MessageCellDelegate, AvatarViewDelegate, FriendServiceDelegate, InputDialogDelegate>

@property (assign, nonatomic) id<ChatControllerDelegate> chatControllerDelegate;
@property (retain, nonatomic) IBOutlet UIImageView *viewBgImageView;
@property (retain, nonatomic) IBOutlet UIView *userView;
@property (retain, nonatomic) IBOutlet UIView *chatInfoView;
@property (retain, nonatomic) IBOutlet UIImageView *chatInfoViewBgImageView;
@property (retain, nonatomic) IBOutlet UIView *avatarHolderView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *microBlogImageView;
@property (retain, nonatomic) IBOutlet UILabel *sexLabel;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (retain, nonatomic) IBOutlet UIButton *payAttentionButton;
@property (retain, nonatomic) IBOutlet UIScrollView *expressionScrollView;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

- (id)initWithChatType:(GameChatType)type;
- (void)showInView:(UIView*)superView messagesType:(MessagesType)type selectedUserId:(NSString*)selectedUserId;
- (void)dismiss;

@end
