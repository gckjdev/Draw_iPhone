//
//  ChatViewCell.m
//  Draw
//
//  Created by 小涛 王 on 12-8-21.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatViewCell.h"
#import "DiceImageManager.h"


#define HEIGHT_CHATVIEWCELL ([DeviceDetection isIPAD] ? 76: 38)
#define SIZE_FONT_CHATVIEWCEL   ([DeviceDetection isIPAD] ? 28: 14)
#define MAX_SIZE_MESSAGE    ([DeviceDetection isIPAD] ? CGSizeMake(460, 72) : CGSizeMake(230, 36))


@interface ChatViewCell ()

@property (retain, nonatomic) CommonChatMessage *message;

@end

@implementation ChatViewCell

@synthesize delegate = _delegate;
@synthesize message = _message;
@synthesize messageButton;

- (void)dealloc {
    [_message release];
    [messageButton release];
    [super dealloc];
}

+ (CGFloat)getCellHeight
{
    return HEIGHT_CHATVIEWCELL;
}

+ (NSString *)getCellIdentifier
{
    return @"ChatViewCell";
}

- (void)setCellData:(CommonChatMessage *)message
{
    self.message = message;
    
    CGSize withinSize = MAX_SIZE_MESSAGE;
    CGSize size = [message.content sizeWithFont:[UIFont systemFontOfSize:SIZE_FONT_CHATVIEWCEL] constrainedToSize:withinSize lineBreakMode:UILineBreakModeTailTruncation];
    
    messageButton.frame = CGRectMake(0, 0, size.width + 30, messageButton.frame.size.height);
    [messageButton setBackgroundImage:[[DiceImageManager defaultManager] diceChatMsgBgImage] forState:UIControlStateNormal];
    
    messageButton.fontLable.text = message.content;
    
    CGRect fontLabelFrame = messageButton.fontLable.frame;
    messageButton.fontLable.frame = CGRectMake(10, 3, fontLabelFrame.size.width, fontLabelFrame.size.height);

    messageButton.fontLable.textAlignment = UITextAlignmentLeft;
    [messageButton setImage:nil forState:UIControlStateNormal];
}


- (IBAction)clickMessageButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMessage:)]) {
        [_delegate didClickMessage:_message];
    }
}

@end



