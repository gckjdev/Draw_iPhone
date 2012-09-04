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
#import "FriendManager.h"
#import "TimeUtils.h"
#import "LocaleUtils.h"

@interface ChatDetailCell()

- (IBAction)clickEnlargeButton:(id)sender;
- (IBAction)clcikAvatarButton:(id)sender;
- (CGRect)reverseByRect:(CGRect)rect;

@end

@implementation ChatDetailCell
@synthesize avatarBackgroundImageView;
@synthesize avatarView;
@synthesize bubbleImageView;
@synthesize timeLabel;
@synthesize contentTextView;
@synthesize graffitiView;
@synthesize chatDetailCellDelegate;
@synthesize enlargeButton;
@synthesize nicknameLabel;
@synthesize avatarButton;

- (void)dealloc {
    
    [graffitiView stop];
    PPRelease(avatarView);
    PPRelease(bubbleImageView);
    PPRelease(timeLabel);
    PPRelease(contentTextView);
    PPRelease(graffitiView);
    PPRelease(enlargeButton);
    PPRelease(nicknameLabel);
    PPRelease(avatarBackgroundImageView);
    PPRelease(avatarButton);
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
    
    ChatDetailCell *cell = (ChatDetailCell*)[topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    
    UIColor *textColor = [UIColor colorWithRed:79.0/255.0 green:62.0/255.0 blue:32.0/255.0 alpha:1];
    cell.contentTextView.textColor = textColor;
    cell.nicknameLabel.textColor = textColor;
    
    cell.timeLabel.textColor = [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1];
    
    return cell;
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
#define BUBBLE_NOT_TIP_WIDTH    (([DeviceDetection isIPAD])?(9):(4.5))
#define IMAGE_WIDTH_MAX (([DeviceDetection isIPAD])?(200.0):(100.0))
#define IMAGE_BORDER_X (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_BORDER_Y (([DeviceDetection isIPAD])?(16):(8))
#define TIME_AND_CONTENT_SPACE    (([DeviceDetection isIPAD])?(2):(1))
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
 NICKNAME_AND_AVATAR_SPACE  名字与头像距离
 NICKNAME_HEIGHT  名字高度
 */
+ (CGFloat)getCellHeight:(ChatMessage *)message
{
    CGFloat resultHeight = 0;
    
    if ([message.text length] > 0) {
        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        resultHeight = SPACE_Y + textSize.height+2*TEXTVIEW_BORDER_Y + TIME_AND_CONTENT_SPACE + TIME_HEIGHT;
    }else {
        resultHeight = SPACE_Y + IMAGE_WIDTH_MAX+2*IMAGE_BORDER_Y + TIME_AND_CONTENT_SPACE + TIME_HEIGHT;
    }
    
    return resultHeight;
}



- (void)setCellByChatMessage:(ChatMessage *)message 
              friendNickname:(NSString *)friendNickName 
                friendAvatar:(NSString *)friendAvatar 
                friendGender:(NSString *)friendGender
                   indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    
    BOOL fromSelf = [message.from isEqualToString:[[UserManager defaultManager] userId]];
    
    //set avatar
    [avatarView clear];
    NSString *gender;
    NSString *avatarUrl;
    if (fromSelf) {
        gender = [[UserManager defaultManager] gender];
        avatarUrl = [[UserManager defaultManager] avatarURL];
    }else {
        gender = friendGender;
        avatarUrl = friendAvatar;
    }
    
    if ([gender isEqualToString:MALE]) {
        [avatarView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    } else {
        [avatarView setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    }
    
    if ([avatarUrl length] > 0) {
        [avatarView setUrl:[NSURL URLWithString:avatarUrl]];
        [GlobalGetImageCache() manage:avatarView];
    }
    
    //set nickname
    if (fromSelf) {
        nicknameLabel.text = NSLS(@"Me");
    }else {
        nicknameLabel.text = friendNickName;
    }
    nicknameLabel.hidden = YES;
    
    UIImage *bubble = [UIImage imageNamed:fromSelf ? @"sent_message.png" : @"receive_message.png"];
    [bubbleImageView setImage:[bubble stretchableImageWithLeftCapWidth:14 topCapHeight:14]];
    
    
    //set time
    NSString *timeString ;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(message.createDate);
    } else {
        timeString = englishBeforeTime(message.createDate);
    }
    
    if (timeString) {
        self.timeLabel.text = timeString;
    } else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
        self.timeLabel.text = [dateFormatter stringFromDate:message.createDate];
    }
    
    
    
    /*注意要保证xib里面contentTextView,bubbleImageView,graffitiView,timeLabel的x位置一样*/
    if ([message.text length] > 0) {
        contentTextView.hidden = NO;
        graffitiView.hidden = YES;
        enlargeButton.hidden = YES;
        
        //get string size
        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
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
        CGFloat scale = IMAGE_WIDTH_MAX / DRAW_VIEW_FRAME.size.width;
        NSMutableArray *scaleActionList = nil;
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:scale 
                                               yScale:scale];

        [graffitiView setDrawActionList:scaleActionList]; 
        [graffitiView setShowPenHidden:YES];
        CGFloat multiple = graffitiView.frame.size.height / graffitiView.frame.size.width;
        graffitiView.frame = CGRectMake(graffitiView.frame.origin.x+BUBBLE_TIP_WIDTH+IMAGE_BORDER_X, 0.5*SPACE_Y+IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple *IMAGE_WIDTH_MAX);
        graffitiView.layer.cornerRadius = 4;
        graffitiView.layer.masksToBounds = YES;
        [graffitiView show];
        
        //set button frame
        enlargeButton.frame = graffitiView.frame;
        
        //set bubble frame
        bubbleImageView.frame = CGRectMake(bubbleImageView.frame.origin.x,0.5*SPACE_Y, graffitiView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH+2*IMAGE_BORDER_X, graffitiView.frame.size.height+2*IMAGE_BORDER_Y);
    }
    
    //set time frame
    timeLabel.frame = CGRectMake(timeLabel.frame.origin.x, bubbleImageView.frame.origin.y+bubbleImageView.frame.size.height+TIME_AND_CONTENT_SPACE, timeLabel.frame.size.width, TIME_HEIGHT);
    
    //set avatar frame
    avatarView.frame = CGRectMake(avatarView.frame.origin.x, bubbleImageView.frame.origin.y+bubbleImageView.frame.size.height-avatarView.frame.size.height-2, avatarView.frame.size.width, avatarView.frame.size.height);
    avatarBackgroundImageView.center = CGPointMake(avatarView.center.x, avatarView.center.y+2);
    avatarButton.frame = avatarBackgroundImageView.frame;
    
    //set nickname frame 
    //nicknameLabel.frame = CGRectMake(nicknameLabel.frame.origin.x, avatarView.frame.origin.y+avatarView.frame.size.height+NICKNAME_AND_AVATAR_SPACE, nicknameLabel.frame.size.width, NICKNAME_HEIGHT);
    
    if (fromSelf) {
        avatarBackgroundImageView.frame = [self reverseByRect:avatarBackgroundImageView.frame];
        avatarView.frame = [self reverseByRect:avatarView.frame];
        contentTextView.frame = [self reverseByRect:contentTextView.frame];
        bubbleImageView.frame = [self reverseByRect:bubbleImageView.frame];
        graffitiView.frame = [self reverseByRect:graffitiView.frame];
        enlargeButton.frame = [self reverseByRect:enlargeButton.frame];
        timeLabel.frame = [self reverseByRect:timeLabel.frame];
        [timeLabel setTextAlignment:UITextAlignmentRight];
        nicknameLabel.frame = [self reverseByRect:nicknameLabel.frame];
        avatarButton.frame = [self reverseByRect:avatarButton.frame];
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, timeLabel.frame.origin.y+timeLabel.frame.size.height+0.5*SPACE_Y);
}

- (IBAction)clickEnlargeButton:(id)sender
{
    if (chatDetailCellDelegate && [chatDetailCellDelegate respondsToSelector:@selector(didClickEnlargeButton:)]){
        [chatDetailCellDelegate didClickEnlargeButton:self.indexPath];
    }
}

- (IBAction)clcikAvatarButton:(id)sender
{
    if (chatDetailCellDelegate && [chatDetailCellDelegate respondsToSelector:@selector(didClickAvatarButton:)]){
        [chatDetailCellDelegate didClickAvatarButton:self.indexPath];
    }
}

@end
