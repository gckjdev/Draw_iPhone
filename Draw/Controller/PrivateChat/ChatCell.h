//
//  ChatCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"
#import "UIImageView+WebCache.h"

@protocol ChatCellDelegate <NSObject>

- (void)didClickAvatar:(NSIndexPath *)aIndexPath;

@end


@class MessageStat;
@interface ChatCell : PPTableViewCell
{
    MessageStat *_messageStat;
}

@property (retain, nonatomic) IBOutlet UIImageView *avatarImage;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UIImageView *countBackground;
@property (assign, nonatomic) id<ChatCellDelegate> chatCellDelegate;
@property (retain, nonatomic) MessageStat *messageStat;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
- (void)setCellByMessageStat:(MessageStat *)messageStat indexPath:(NSIndexPath *)aIndexPath;


@end
