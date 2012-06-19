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

@implementation ChatDetailCell
@synthesize avatarView;
@synthesize bubbleImageView;
@synthesize timeLabel;
@synthesize contentTextView;
@synthesize thumbImageView;

- (void)dealloc {
    [avatarView release];
    [bubbleImageView release];
    [timeLabel release];
    [contentTextView release];
    [thumbImageView release];
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

+ (CGFloat)getCellHeight
{
    
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
    [showDrawView show];
    return showDrawView;
}

#define TEXT_WIDTH_MAX    (([DeviceDetection isIPAD])?(400.0):(200.0))
#define TEXT_HEIGHT_MAX   (([DeviceDetection isIPAD])?(2000.0):(1000.0))
#define TEXT_FONT_SIZE  (([DeviceDetection isIPAD])?(30):(15))
#define SPACE_Y         (([DeviceDetection isIPAD])?(20):(10))
#define SCREEN_WIDTH    (([DeviceDetection isIPAD])?(768):(320))
#define TEXTVIEW_BORDER_X (([DeviceDetection isIPAD])?(10):(8))
#define TEXTVIEW_BORDER_Y (([DeviceDetection isIPAD])?(10):(8))
#define BUBBLE_TIP_WIDTH   (([DeviceDetection isIPAD])?(16):(10))
#define BUBBLE_NOT_TIP_WIDTH    (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_WIDTH_MAX (([DeviceDetection isIPAD])?(200.0):(100.0))
#define IMAGE_BORDER_X (([DeviceDetection isIPAD])?(10):(5))
#define IMAGE_BORDER_Y (([DeviceDetection isIPAD])?(16):(8))
/*
 TEXT_WIDTH_MAX 是消息的最大长度
 TEXT_HEIGHT_MAX  是消息的最大高度
 TEXT_FONT_SIZE  是字体
 SPACE_Y  是上一个气泡图与下一个的距离
 SCREEN_WIDTH    是屏幕宽度
 TEXTVIEW_BORDER_X  是TextView的文字与左或右边界的空隙
 TEXTVIEW_BORDER_Y  是TextView的文字与上或下边界的空隙
 BUBBLE_TIP_WIDTH   是气泡图尖角的宽度
 BUBBLE_NOT_TIP_WIDTH 是气泡图非尖角的宽度
 IMAGE_WIDTH_MAX    是图片的最大宽度
 IMAGE_BORDER_X 是图片与气泡图边界X方向的空隙
 IMAGE_BORDER_Y 是图片与气泡图边界Y方向的空隙
 */
- (void)setCellByChatMessage:(ChatMessage *)message friendAvatar:(NSString *)friendAvatar indexPath:(NSIndexPath *)aIndexPath
{
    BOOL fromSelf = [message.from isEqualToString:[[UserManager defaultManager] userId]];
    
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
    
    UIImage *bubble = [UIImage imageNamed:fromSelf ? @"sent_message.png" : @"receive_message.png"];
    [bubbleImageView setImage:bubble];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yy-MM-dd HH:mm"];
    timeLabel.text = [dateFormatter stringFromDate:message.createDate];
    
    if ([message.text length] > 0) {
        //string的大小
        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
        
        //设置文本
        CGRect contentTextViewFrame = CGRectMake(contentTextView.frame.origin.x, contentTextView.frame.origin.y, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+2*TEXTVIEW_BORDER_Y);
        contentTextView.frame = contentTextViewFrame;
        //contentTextView.backgroundColor = [UIColor clearColor];
        contentTextView.font = font;
        contentTextView.text = message.text;
        
        
        //设置气泡
        CGRect bubbleImageViewFrame = CGRectMake(bubbleImageView.frame.origin.x, bubbleImageView.frame.origin.y, contentTextView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH, contentTextView.frame.size.height);
        bubbleImageView.frame = bubbleImageViewFrame;
    }
        
        
//    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
//	returnView.backgroundColor = [UIColor clearColor];
//    
//    BOOL fromSelf = [message.from isEqualToString:[[UserManager defaultManager] userId]];
//	UIImage *bubble = [UIImage imageNamed:fromSelf ? @"sent_message.png" : @"receive_message.png"];
//	//UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:14 topCapHeight:14]];
//    //bubbleImageView.backgroundColor =[UIColor clearColor];
//    
//    [bubbleImageView setImage:bubble];
//    
//    if ([message.text length] > 0) {
//        //string的大小
//        UIFont *font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
//        CGSize textSize = [message.text sizeWithFont:font constrainedToSize:CGSizeMake(TEXT_WIDTH_MAX, TEXT_HEIGHT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
//        
//        //设置文本
//        CGRect contentTextViewFrame;
//        if (fromSelf){
//            contentTextViewFrame = CGRectMake(BUBBLE_NOT_TIP_WIDTH, 0, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+2*TEXTVIEW_BORDER_Y);
//        }else {
//            contentTextViewFrame = CGRectMake(BUBBLE_TIP_WIDTH, 0, textSize.width+2*TEXTVIEW_BORDER_X, textSize.height+2*TEXTVIEW_BORDER_Y);
//        }
//        UITextView *contentTextView = [[UITextView alloc] initWithFrame:contentTextViewFrame];
//        contentTextView.backgroundColor = [UIColor clearColor];
//        contentTextView.font = font;
//        contentTextView.text = message.text;
//        
//        //设置气泡的frame
//        bubbleImageView.frame = CGRectMake(0.0f, 0.5*SPACE_Y, contentTextView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH, contentTextView.frame.size.height);
//        [bubbleImageView addSubview:contentTextView];
//        [contentTextView release];
//        
//    }else {
//        //设置涂鸦
//        NSArray* drawActionList = [ChatMessageUtil unarchiveDataToDrawActionList:message.drawData];
//        CGFloat scale = IMAGE_WIDTH_MAX / DRAW_VEIW_FRAME.size.width;
//        ShowDrawView *thumbImageView = [self createShowDrawView:drawActionList scale:scale];
//        CGFloat multiple = thumbImageView.frame.size.height / thumbImageView.frame.size.width;
//        if (fromSelf){
//            thumbImageView.frame = CGRectMake(BUBBLE_NOT_TIP_WIDTH+IMAGE_BORDER_X, IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple * IMAGE_WIDTH_MAX );
//        }else {
//            thumbImageView.frame = CGRectMake(BUBBLE_TIP_WIDTH+IMAGE_BORDER_X, IMAGE_BORDER_Y, IMAGE_WIDTH_MAX, multiple *IMAGE_WIDTH_MAX);
//        }
//        
//        //设置气泡的frame
//        bubbleImageView.frame = CGRectMake(0.0f, 0.5*SPACE_Y, thumbImageView.frame.size.width+BUBBLE_TIP_WIDTH+BUBBLE_NOT_TIP_WIDTH+2*IMAGE_BORDER_X, thumbImageView.frame.size.height+2*IMAGE_BORDER_Y);
//        [bubbleImageView addSubview:thumbImageView];
//        
//        UIButton *button = [[UIButton alloc] initWithFrame:thumbImageView.frame];
//        button.tag = indexPath.row;
//        [button addTarget:self action:@selector(replayGraffiti:) forControlEvents:UIControlEventAllEvents];
//        [bubbleImageView addSubview:button];
//        [button release];
//    }
//    
//    
//    
//    //设置returnView的frame
//    if (fromSelf) {
//        returnView.frame = CGRectMake(SCREEN_WIDTH-bubbleImageView.frame.size.width, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height+SPACE_Y);
//    }else{
//        returnView.frame = CGRectMake(0, 0, bubbleImageView.frame.size.width, bubbleImageView.frame.size.height + SPACE_Y);
//    }
//    
//    PPDebug(@"Number %d:%f", indexPath.row, bubbleImageView.frame.size.height);
//    
//    [returnView addSubview:bubbleImageView];
//    [bubbleImageView release];
//    return returnView;
}


@end
