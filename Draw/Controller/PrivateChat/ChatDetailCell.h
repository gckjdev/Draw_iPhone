//
//  ChatDetailCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月19日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"

@protocol ChatDetailCellDelegate <NSObject>

@optional
- (void)didClickEnlargeButton:(NSIndexPath *)aIndexPath;
- (void)didClickAvatarButton:(NSIndexPath *)aIndexPath;
@end


@class HJManagedImageV;
@class ChatMessage;
@class ShowDrawView;
@interface ChatDetailCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *avatarBackgroundImageView;
@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarView;
@property (retain, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (retain, nonatomic) IBOutlet ShowDrawView *graffitiView;
@property (assign, nonatomic) id<ChatDetailCellDelegate> chatDetailCellDelegate;
@property (retain, nonatomic) IBOutlet UIButton *enlargeButton;
@property (retain, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;


+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight:(ChatMessage *)message;
- (void)setCellByChatMessage:(ChatMessage *)message 
              friendNickname:(NSString *)friendNickName 
                friendAvatar:(NSString *)friendAvatar 
                friendGender:(NSString *)friendGender
                   indexPath:(NSIndexPath *)aIndexPath;

@end
