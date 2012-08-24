//
//  ChatViewCell.m
//  Draw
//
//  Created by 小涛 王 on 12-8-21.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatViewCell.h"
#import "DiceImageManager.h"

@interface ChatViewCell ()

@property (retain, nonatomic) DiceChatMessage *message;

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
    return 38;
}

+ (NSString *)getCellIdentifier
{
    return @"ChatViewCell";
}

- (void)setCellData:(DiceChatMessage *)message
{
    self.message = message;
    
    CGSize withinSize = CGSizeMake(230, 36);
    CGSize size = [message.content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:withinSize lineBreakMode:UILineBreakModeTailTruncation];
    
    messageButton.frame = CGRectMake(0, 0, size.width + 30, messageButton.frame.size.height);
    [messageButton setBackgroundImage:[[DiceImageManager defaultManager] diceChatMsgBgImage] forState:UIControlStateNormal];
    
    messageButton.fontLable.text = message.content;
    
    CGRect fontLabelFrame = messageButton.fontLable.frame;
    messageButton.fontLable.frame = CGRectMake(13, 3, fontLabelFrame.size.width, fontLabelFrame.size.height);
    messageButton.fontLable.textAlignment = UITextAlignmentLeft;
    [messageButton setImage:nil forState:UIControlStateNormal];
}


- (IBAction)clickMessageButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMessage:)]) {
        [_delegate didClickMessage:_message];
    }
}

@end



