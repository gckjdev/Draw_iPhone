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

@class AvatarView;

@interface ChatController : PPTableViewController <MessageCellDelegate, AvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *chatView;
@property (retain, nonatomic) IBOutlet UIView *avatarHolderView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *microBlogImageView;
@property (retain, nonatomic) IBOutlet UILabel *sexLabel;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *expressionScrollView;

- (void)showInView:(UIView*)superView;

@end
