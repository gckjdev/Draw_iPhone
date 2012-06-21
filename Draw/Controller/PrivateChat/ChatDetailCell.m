//
//  ChatDetailCell.m
//  Draw
//
//  Created by haodong qiu on 12年6月19日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatDetailCell.h"
#import "LogUtil.h"
#import "ChatMessage.h"
#import "UserManager.h"
#import "DeviceDetection.h"
#import "ChatMessageUtil.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "HJManagedImageV.h"
#import "DrawAppDelegate.h"
#import "ShareImageManager.h"

@interface ChatDetailCell()

- (IBAction)clickEnlargeButton:(id)sender;
- (CGRect)reverseByRect:(CGRect)rect;

@end

@implementation ChatDetailCell
@synthesize avatarView;
@synthesize bubbleImageView;
@synthesize timeLabel;
@synthesize contentTextView;
@synthesize graffitiView;
@synthesize chatDetailCellDelegate;
@synthesize enlargeButton;
@synthesize nicknameLabel;

- (void)dealloc {
    [avatarView release];
    [bubbleImageView release];
    [timeLabel release];
    [contentTextView release];
    [graffitiView release];
    [enlargeButton release];
    [nicknameLabel release];
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
    
    ((ChatDetailCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}


+ (NSString*)getCellIdentifier
{
    return @"ChatDetailCell";
}


- (CGRect)reverseByRect:(CGRect)rect
{
    CGRect newRect = CGRectMake(self.frame.size.width-rect.origin.x-rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
    return newRect;
}

#define TEXT_WIDTH_MAX    (([DeviceDetection isIPAD])?(400.0):(200.0))
#define TEXT_HEIGHT_MAX   (([DeviceDetection isIPAD])?(2000.0):(1000.0))
#define TEXT_FONT_SIZE  (([DeviceDetection isIPAD])?(30):(15))
#define SPACE_Y         (([DeviceDetection isIPAD])?(32):(16))
#define SCREEN_WIDTH    (([DeviceDetection isIPAD])?(768):(320))
#define TEXTVIEW_BORDER_X (([DeviceDetection isIPAD])?(10):(8))
#define TEXTVIEW_BORDER_Y (([DeviceDetection isIPAD])?(10):(8))
#define BUBBLE_TIP_WIDTH   (([DeviceDetection isIPAD])?(16):(10))
#define BUBBLE_NOT_TIP_WIDTH    (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_WIDTH_MAX (([DeviceDetection isIPAD])?(200.0):(100.0))
#define IMAGE_BORDER_X (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_BORDER_Y (([DeviceDetection isIPAD])?(16):(8))
#define TIME_AND_CONTENT_SPACE    (([DeviceDetection isIPAD])?(4):(2))
#define TIME_HEIGHT     (([DeviceDetection isIPAD])?(32):(16))
#define NICKNAME_AND_AVATAR_SPACE (([DeviceDetection isIPAD])?(4):(2))
#define NICKNAME_HEIGHT (([DeviceDetection isIPAD])?(32):(16))
/*
 TEXT_WIDTH_MAX 是消息的最大长度
 TEXT_HEIGHT_MAX  是消息的最大高度
 TEXT_FONT_SIZE  是字体
 SPACE_Y  两个CELL之间的空隙
 SCREEN_WIDTH    是屏幕宽度
 TEXTVIEW_BORDER_X  是TextView的文字与左或右边界的空隙
 TEXTVIEW_BORDER_Y  是TextView的文字与上或下边界的空隙
 BUBBLE_TIP_WIDTH   是气泡图尖角的宽度
 BUBBLE_NOT_TIP_WIDTH 是气泡图非尖角的宽度
 IMAGE_WIDTH_MAX    是图片的最大宽度
 IMAGE_BORDER_X 是图片与气泡图边界X方向的空隙
 IMAGE_BORDER_Y 是图片与气泡图边界Y方向的空隙
 TIME_AND_CONTENT_SPACE 时间跟内容的距离
 TIME_HEIGHT 时间高度
 */
+ (CGFloat)getCellHeight:(ChatMessage *)message
{
    CGFloat resultHeight = 0;
    
    if ([message.text length] > 0) {
        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
        
        resultHeight = SPACE_Y + textSize.height+2*TEXTVIEW_BORDER_Y + TIME_HEIGHT + TIME_AND_CONTENT_SPACE - 0.5*TIME_HEIGHT + NICKNAME_AND_AVATAR_SPACE + NICKNAME_HEIGHT;
    }else {
        resultHeight = SPACE_Y + IMAGE_WIDTH_MAX+2*IMAGE_BORDER_Y + TIME_HEIGHT + TIME_AND_CONTENT_SPACE - 0.5*TIME_HEIGHT + NICKNAME_AND_AVATAR_SPACE + NICKNAME_HEIGHT;
    }
    
    return resultHeight;
}

- (void)setCellByChatMessage:(ChatMessage *)message friendNickname:(NSString *)friendNickName friendAvatar:(NSString *)friendAvatar indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    
    UIColor *textColor = [UIColor colorWithRed:81.0/255.0 green:64.0/255.0 blue:34.0/255.0 alpha:1];
    contentTextView.textColor = textColor;
    nicknameLabel.textColor = textColor;
    timeLabel.textColor = textColor;
    
    BOOL fromSelf = [message.from isEqualToString:[[UserManager defaultManager] userId]];
    
    //set avatar
    [avatarView clear];
    [avatarView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    NSString *avatarUrl;
    if (fromSelf) {
        avatarUrl = [[UserManager defaultManager] avatarURL];
    }else {
        avatarUrl = friendAvatar;
    }
    if ([avatarUrl length] > 0) {
        [avatarView setUrl:[NSURL URLWithString:friendAvatar]];
        [GlobalGetImageCache() manage:avatarView];
    }
    
    //set nickname
    if (fromSelf) {
        nicknameLabel.text = NSLS(@"Me");
    }else {
        nicknameLabel.text = friendNickName;
    }
    
    UIImage *bubble = [UIImage imageNamed:fromSelf ? @"sent_message.png" : @"receive_message.png"];
    [bubbleImageView setImage:[bubble stretchableImageWithLeftCapWidth:14 topCapHeight:14]];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    timeLabel.text = [dateFormatter stringFromDate:message.createDate];
    
    if ([message.text length] > 0) {
        contentTextView.hidden = NO;
        graffitiView.hidden = YES;
        enlargeButton.hidden = YES;
        
        //string的大小
        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
        
        //set text
        contentTextView.frame = CGRectMake(contentTextView.frame.origin.x+BUBBLE_TIP_WIDTH, 0.5*SPACE_Y, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+2*TEXTVIEW_BORDER_Y);
        contentTextView.font = font;
        contentTextView.text = message.text;
        contentTextView.backgroundColor = [UIColor clearColor];
        
        //set bubble frame
        bubbleImageView.frame = CGRectMake(bubbleImageView.frame.origin.x, 0.5*SPACE_Y, contentTextView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH, contentTextView.frame.size.height);
        
    }else {
        contentTextView.hidden = YES;
        graffitiView.hidden = NO;
        enlargeButton.hidden = NO;
        
        //set graffitiView
        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:message.drawData];
        CGFloat scale = IMAGE_WIDTH_MAX / DRAW_VEIW_FRAME.size.width;
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
        [graffitiView setDrawActionList:scaleActionList]; 
        [graffitiView setShowPenHidden:YES];
        CGFloat multiple = graffitiView.frame.size.height / graffitiView.frame.size.width;
        graffitiView.frame = CGRectMake(graffitiView.frame.origin.x+BUBBLE_TIP_WIDTH+IMAGE_BORDER_X, 0.5*SPACE_Y+IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple *IMAGE_WIDTH_MAX);
        
        //set button frame
        enlargeButton.frame = graffitiView.frame;
        
        //set bubble frame
        bubbleImageView.frame = CGRectMake(bubbleImageView.frame.origin.x,0.5*SPACE_Y, graffitiView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH+2*IMAGE_BORDER_X, graffitiView.frame.size.height+2*IMAGE_BORDER_Y);
    }
    
    //set time frame
    timeLabel.frame = CGRectMake(timeLabel.frame.origin.x, bubbleImageView.frame.origin.y+bubbleImageView.frame.size.height+TIME_AND_CONTENT_SPACE, timeLabel.frame.size.width, TIME_HEIGHT);
    
    //set avatar frame
    avatarView.frame = CGRectMake(avatarView.frame.origin.x, timeLabel.frame.origin.y+0.5*timeLabel.frame.size.height-avatarView.frame.size.height, avatarView.frame.size.width, avatarView.frame.size.height);
    
    //set nickname frame 
    nicknameLabel.frame = CGRectMake(nicknameLabel.frame.origin.x, avatarView.frame.origin.y+avatarView.frame.size.height+NICKNAME_AND_AVATAR_SPACE, nicknameLabel.frame.size.width, NICKNAME_HEIGHT);
    
    if (fromSelf) {
        avatarView.frame = [self reverseByRect:avatarView.frame];
        contentTextView.frame = [self reverseByRect:contentTextView.frame];
        bubbleImageView.frame = [self reverseByRect:bubbleImageView.frame];
        graffitiView.frame = [self reverseByRect:graffitiView.frame];
        enlargeButton.frame = [self reverseByRect:enlargeButton.frame];
        timeLabel.frame = [self reverseByRect:timeLabel.frame];
        [timeLabel setTextAlignment:UITextAlignmentRight];
        nicknameLabel.frame = [self reverseByRect:nicknameLabel.frame];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, nicknameLabel.frame.origin.y+nicknameLabel.frame.size.height+0.5*SPACE_Y);
}

- (IBAction)clickEnlargeButton:(id)sender
{
    if (chatDetailCellDelegate && [chatDetailCellDelegate respondsToSelector:@selector(didClickEnlargeButton:)]){
        PPDebug(@"%d",[self.indexPath row]);
        [chatDetailCellDelegate didClickEnlargeButton:self.indexPath];
    }
}


@end
