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
#import "CommonDialog.h"

@class AvatarView;

@protocol ChatControllerDelegate <NSObject>
@optional
- (void)didSelectMessage:(NSString*)message toUser:(NSString*)userNickName;
- (void)didSelectExpression:(UIImage*)expression toUser:(NSString*)userNickName;

@end

@interface ChatController : PPTableViewController <MessageCellDelegate, AvatarViewDelegate, FriendServiceDelegate, CommonDialogDelegate>

@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (assign, nonatomic) id<ChatControllerDelegate> chatControllerDelegate;
@property (retain, nonatomic) IBOutlet UIImageView *viewBgImageView;
@property (retain, nonatomic) IBOutlet UIView *userView;
@property (retain, nonatomic) IBOutlet UIView *chatInfoView;
@property (retain, nonatomic) IBOutlet UIImageView *chatInfoViewBgImageView;
@property (retain, nonatomic) IBOutlet UIView *avatarHolderView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *microBlogImageView;
@property (retain, nonatomic) IBOutlet UILabel *alreadPayAttentionLabel;

@property (retain, nonatomic) IBOutlet UILabel *sexLabel;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (retain, nonatomic) IBOutlet UIButton *payAttentionButton;
@property (retain, nonatomic) IBOutlet UIScrollView *expressionScrollView;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UILabel *chatTitleLabel;

- (id)initWithChatType:(GameChatType)type;
- (void)showInView:(UIView*)superView messagesType:(MessagesType)type selectedUserId:(NSString*)selectedUserId needAnimation:(BOOL)needAnimation;
- (void)dismiss:(BOOL)needAnimation;

@end
