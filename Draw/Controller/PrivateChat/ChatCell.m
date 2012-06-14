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

@implementation ChatCell
@synthesize avatarImage;
@synthesize nickNameLabel;
@synthesize graffiti;
@synthesize textLabel;
@synthesize messageNumberLabel;
@synthesize timeLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
#define CELL_HEIGHT_IPAD    164
+ (CGFloat)getCellHeight
{
    if ([DeviceDetection isIPAD]) {
        return CELL_HEIGHT_IPAD;
    }else {
        return CELL_HEIGHT_IPHONE;
    }
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
    }
    
    //set messageNumberLabel
    NSString *newAndTotal = [NSString stringWithFormat:@"[%@/%@]", messageTotal.totalNewMessage, messageTotal.totalMessage];
    self.messageNumberLabel.text = newAndTotal;
    
    //set timeLabel
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    self.timeLabel.text = [dateFormatter stringFromDate:messageTotal.latestCreateDate];
}


- (void)dealloc {
    [avatarImage release];
    [nickNameLabel release];
    [graffiti release];
    [messageNumberLabel release];
    [timeLabel release];
    [textLabel release];
    [super dealloc];
}
@end
