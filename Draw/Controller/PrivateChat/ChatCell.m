//
//  ChatCell.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatCell.h"
#import "LogUtil.h"
#import "DeviceDetection.h"
#import "MessageTotal.h"
#import "ShareImageManager.h"
#import "PPApplication.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "ChatMessageUtil.h"
#import "FriendManager.h"
#import "TimeUtils.h"

@interface ChatCell()

- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList scale:(CGFloat)scale;
- (IBAction)clickAvatar:(id)sender;

@end


@implementation ChatCell

@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize graffiti;
@synthesize textLabel;
@synthesize timeLabel;
@synthesize countLabel;
@synthesize countBackground;
@synthesize chatCellDelegate;

- (void)dealloc {
    PPRelease(avatarImage);
    PPRelease(nickNameLabel);
    PPRelease(graffiti);
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


- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList scale:(CGFloat)scale
{
    ShowDrawView *showDrawView = [[[ShowDrawView alloc] init] autorelease];
    showDrawView.frame = CGRectMake(0, 0, scale * DRAW_VIEW_FRAME.size.width, scale * DRAW_VIEW_FRAME.size.height);
    NSMutableArray *scaleActionList = nil;
    if ([DeviceDetection isIPAD]) {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:IPAD_WIDTH_SCALE*scale 
                                               yScale:IPAD_HEIGHT_SCALE*scale];
    } else {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:scale 
                                               yScale:scale];
    }
    [showDrawView setDrawActionList:scaleActionList]; 
    [showDrawView setShowPenHidden:YES];
    
    return showDrawView;
}


- (void)setCellByMessageTotal:(MessageTotal *)messageTotal indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    
    //set avatar
    [avatarImage clear];
    if ([messageTotal.friendGender isEqualToString:MALE]) {
        [avatarImage setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    } else {
        [avatarImage setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    }
    if ([messageTotal.friendAvatar length] > 0) {
        [avatarImage setUrl:[NSURL URLWithString:messageTotal.friendAvatar]];
        [GlobalGetImageCache() manage:avatarImage];
    }
    
    //set nickname
    self.nickNameLabel.text = messageTotal.friendNickName;
    
    //set text or graffiti 
    if ([messageTotal.latestText length] > 0) {
        self.textLabel.hidden = NO;
        self.graffiti.hidden = YES;
        self.textLabel.text = messageTotal.latestText;
    }else {
        self.textLabel.hidden = NO;
        self.graffiti.hidden = YES;
        self.textLabel.text = [NSString stringWithFormat:@"[%@]",NSLS(@"kGraffitiMessage")] ;

    }
    
    //set countLabel
    if ([messageTotal.totalNewMessage intValue] > 0) {
        countBackground.hidden = NO;
        countLabel.hidden = NO;
        
        if ([messageTotal.totalNewMessage intValue] > 99) {
            countLabel.text = @"N";
        } else {
            countLabel.text = [NSString stringWithFormat:@"%@",messageTotal.totalNewMessage];
        }
        
    } else {
        countBackground.hidden = YES;
        countLabel.hidden = YES;
    }
    
    
    
    //set timeLabel
    NSString *timeString = nil;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(messageTotal.latestCreateDate);
    } else {
        timeString = englishBeforeTime(messageTotal.latestCreateDate);
    }
    if (timeString) {
        self.timeLabel.text = timeString;
    } else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
        self.timeLabel.text = [dateFormatter stringFromDate:messageTotal.latestCreateDate];
    }
    self.timeLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1];
}

- (IBAction)clickAvatar:(id)sender
{
    if (chatCellDelegate && [chatCellDelegate respondsToSelector:@selector(didClickAvatar:)]){
        //PPDebug(@"%d",[self.indexPath row]);
        [chatCellDelegate didClickAvatar:self.indexPath];
    }
}

@end
