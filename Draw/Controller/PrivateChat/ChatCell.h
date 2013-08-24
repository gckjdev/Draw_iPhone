//
//  ChatCell.h
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "PPTableViewCell.h"
#import "StableView.h"

@protocol ChatCellDelegate <NSObject>

- (void)didClickAvatar:(NSIndexPath *)aIndexPath;

@end


@class MessageStat;
@interface ChatCell : PPTableViewCell <AvatarViewDelegate>
{
    MessageStat *_messageStat;
}

@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;
@property (retain, nonatomic) IBOutlet UIImageView *countBackground;
@property (assign, nonatomic) id<ChatCellDelegate> chatCellDelegate;
@property (retain, nonatomic) MessageStat *messageStat;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;

- (void)setCellByMessageStat:(MessageStat *)messageStat indexPath:(NSIndexPath *)aIndexPath;


@end
