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

@interface ChatCell()

- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList scale:(CGFloat)scale;

@end


@implementation ChatCell
@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize graffiti;
@synthesize textLabel;
@synthesize messageNumberLabel;
@synthesize timeLabel;


- (void)dealloc {
    PPRelease(avatarImage);
    PPRelease(nickNameLabel);
    PPRelease(graffiti);
    PPRelease(messageNumberLabel);
    PPRelease(timeLabel);
    PPRelease(textLabel);
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


#define CELL_HEIGHT_IPHONE  68
#define CELL_HEIGHT_IPAD    136
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
    showDrawView.frame = CGRectMake(0, 0, scale * DRAW_VEIW_FRAME.size.width, scale * DRAW_VEIW_FRAME.size.height);
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
    //set avatar
    [avatarImage clear];
    [avatarImage setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
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
        self.textLabel.hidden = YES;
        self.graffiti.hidden = NO;
        
        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:messageTotal.latestDrawData];
        CGFloat scale = graffiti.frame.size.height / DRAW_VEIW_FRAME.size.height;
        ShowDrawView *thumbImageView = [self createShowDrawView:drawActionList scale:scale];
        [thumbImageView show];
        [graffiti addSubview:thumbImageView];
    }
    
    //set messageNumberLabel
    NSString *newAndTotal = [NSString stringWithFormat:@"[%@/%@]", messageTotal.totalNewMessage, messageTotal.totalMessage];
    self.messageNumberLabel.text = newAndTotal;
    
    //set timeLabel
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    self.timeLabel.text = [dateFormatter stringFromDate:messageTotal.latestCreateDate];
}

@end
