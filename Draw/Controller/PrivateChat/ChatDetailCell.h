//
//  ChatDetailCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月19日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"

@class HJManagedImageV;
@class ChatMessage;
@interface ChatDetailCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet HJManagedImageV *avatarView;
@property (retain, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (retain, nonatomic) IBOutlet UIImageView *thumbImageView;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
- (void)setCellByChatMessage:(ChatMessage *)messageTotal indexPath:(NSIndexPath *)aIndexPath;

@end
