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

- (IBAction)clickAvatar:(id)sender;

@end


@implementation ChatCell

@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize textLabel;
@synthesize timeLabel;
@synthesize countLabel;
@synthesize countBackground;
@synthesize chatCellDelegate;
@synthesize messageStat = _messageStat;

- (void)dealloc {
    PPRelease(_messageStat);
    PPRelease(avatarImage);
    PPRelease(nickNameLabel);
    PPRelease(timeLabel);
    PPRelease(textLabel);
    PPRelease(countLabel);
    PPRelease(countBackground);
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
    NSString *avatar = self.messageStat.friendAvatar;
    BOOL isMale = self.messageStat.friendGender;
    UIImage *defaultImage = nil;
    if (isMale) {
        defaultImage = [[ShareImageManager defaultManager] maleDefaultAvatarImage];
    }else{
        defaultImage = [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
    }
    
    NSURL *url = [NSURL URLWithString:avatar];
    [self.avatarImage setImageWithUrl:url placeholderImage:defaultImage showLoading:YES animated:YES];

    
//    if([avatar length] != 0){
//        NSURL *url = [NSURL URLWithString:avatar];
//        
//        self.avatarImage.alpha = 0;
//        [self.avatarImage setImageWithURL:url placeholderImage:defaultImage success:^(UIImage *image, BOOL cached) {
//            if (!cached) {
//                [UIView animateWithDuration:1 animations:^{
//                    self.avatarImage.alpha = 1.0;
//                }];
//            }else{
//                self.avatarImage.alpha = 1.0;
//            }
//        } failure:^(NSError *error) {
//            self.avatarImage.alpha = 1;
//            [self.avatarImage setImage:defaultImage];
//        }];
//    } else{
//        [self.avatarImage setImage:defaultImage];
//    }


    
    
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

- (IBAction)clickAvatar:(id)sender
{
    if (chatCellDelegate && [chatCellDelegate respondsToSelector:@selector(didClickAvatar:)]){
        //PPDebug(@"%d",[self.indexPath row]);
        [chatCellDelegate didClickAvatar:self.indexPath];
    }
}

@end
