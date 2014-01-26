//
//  ChatCell.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatCell.h"
#import "LogUtil.h"

#import "ShareImageManager.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "FriendManager.h"
#import "TimeUtils.h"
#import "MessageStat.h"
#import "UIImageView+Extend.h"
#import "CanvasRect.h"

@interface ChatCell()

@end


@implementation ChatCell

@synthesize nickNameLabel;
@synthesize textLabel;
@synthesize timeLabel;
@synthesize chatCellDelegate;
@synthesize messageStat = _messageStat;

- (void)dealloc {
    PPRelease(_messageStat);
    PPRelease(nickNameLabel);
    PPRelease(timeLabel);
    PPRelease(textLabel);
    [_avatarView release];
    [_badgeView release];
    [super dealloc];
}

- (void)updateView
{
    [self.nickNameLabel setFont:CELL_NICK_FONT];
    [self.textLabel setFont:CELL_CONTENT_FONT];
    [self.timeLabel setFont:CELL_SMALLTEXT_FONT];    
}


+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    ChatCell *cell = [self createViewWithXibIdentifier:cellId];
    cell.delegate = delegate;
    [cell updateView];
    return cell;
}


+ (NSString*)getCellIdentifier
{
    return @"ChatCell";
}


//#define CELL_HEIGHT_IPHONE  71
//#define CELL_HEIGHT_IPAD    142
+ (CGFloat)getCellHeight
{
    return CELL_CONST_HEIGHT;
}


- (void)updateAvatar
{
//    NSString *avatar = self.messageStat.friendAvatar;
//    BOOL isMale = self.messageStat.friendGender;
//    UIImage *defaultImage = [[ShareImageManager defaultManager] avatarImageByGender:isMale];
//    NSURL *url = [NSURL URLWithString:avatar];
    
    [self.avatarView setAvatarUrl:self.messageStat.friendAvatar gender:self.messageStat.friendGender];
    [self.avatarView setIsVIP:self.messageStat.vip];
    self.avatarView.delegate = self;


}

- (void)updateBadge
{
    NSInteger count = [self.messageStat numberOfNewMessage];
    [self.badgeView setNumber:count];
}


- (void)updateTime
{
    NSString *timeString = nil;
    NSDate *date = [self.messageStat latestCreateDate];
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(date);
    } else {
        timeString = englishBeforeTime(date);
    }
    if (timeString) {
        self.timeLabel.text = timeString;
    } else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
        self.timeLabel.text = [dateFormatter stringFromDate:date];
    }
    
    self.timeLabel.textColor = COLOR_GRAY_TEXT;

}

- (void)setCellByMessageStat:(MessageStat *)messageStat indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    self.messageStat = messageStat;
    //set avatar
    [self updateAvatar];
    
    //set nickname
    self.nickNameLabel.text = messageStat.friendNickName;
    self.nickNameLabel.textColor = COLOR_BROWN;
    
    //set text
    [self.textLabel setText:self.messageStat.desc];
    self.textLabel.textColor = COLOR_BROWN;
    
    //set countLabel
    [self updateBadge];
    
    
    //set timeLabel
    [self updateTime];
}



- (void)didClickOnAvatar:(NSString*)userId{
    if (chatCellDelegate && [chatCellDelegate respondsToSelector:@selector(didClickAvatar:)]){
        [chatCellDelegate didClickAvatar:self.indexPath];
    }
}

@end
