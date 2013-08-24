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
@synthesize countLabel;
@synthesize countBackground;
@synthesize chatCellDelegate;
@synthesize messageStat = _messageStat;

- (void)dealloc {
    PPRelease(_messageStat);
    PPRelease(nickNameLabel);
    PPRelease(timeLabel);
    PPRelease(textLabel);
    PPRelease(countLabel);
    PPRelease(countBackground);
    [_avatarView release];
    [super dealloc];
}


+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((ChatCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}


+ (NSString*)getCellIdentifier
{
    return @"ChatCell";
}


#define CELL_HEIGHT_IPHONE  71
#define CELL_HEIGHT_IPAD    142
+ (CGFloat)getCellHeight
{
    if ([DeviceDetection isIPAD]) {
        return CELL_HEIGHT_IPAD;
    }else {
        return CELL_HEIGHT_IPHONE;
    }
}


- (void)updateAvatar
{
//    NSString *avatar = self.messageStat.friendAvatar;
//    BOOL isMale = self.messageStat.friendGender;
//    UIImage *defaultImage = [[ShareImageManager defaultManager] avatarImageByGender:isMale];
//    NSURL *url = [NSURL URLWithString:avatar];
    
    [self.avatarView setAvatarUrl:self.messageStat.friendAvatar gender:self.messageStat.friendGender];
    self.avatarView.delegate = self;

}

- (void)updateBadge
{
    NSInteger count = [self.messageStat numberOfNewMessage];
    countBackground.hidden = countLabel.hidden = (count <= 0);
    if (count > 0) {
        if (count > 99) {
            countLabel.text = @"N";
        } else {
            countLabel.text = [NSString stringWithFormat:@"%d",count];
        }
    } 
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
    self.timeLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1];

}

- (void)setCellByMessageStat:(MessageStat *)messageStat indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    self.messageStat = messageStat;
    //set avatar
    [self updateAvatar];
    
    //set nickname
    self.nickNameLabel.text = messageStat.friendNickName;
    
    
    //set text
    [self.textLabel setText:self.messageStat.desc];
    
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
