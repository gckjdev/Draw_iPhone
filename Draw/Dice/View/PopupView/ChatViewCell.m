//
//  ChatViewCell.m
//  Draw
//
//  Created by 小涛 王 on 12-8-21.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatViewCell.h"

@interface ChatViewCell ()

@property (copy, nonatomic) NSString *message;

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
    return 36;
}

+ (NSString *)getCellIdentifier
{
    return @"ChatViewCell";
}

- (void)setCellData:(NSString *)message
{
    self.message = message;
    
    CGSize withinSize = CGSizeMake(300, 30);
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:withinSize lineBreakMode:UILineBreakModeTailTruncation];
    
    messageButton.frame = CGRectMake(0, 0, size.width, messageButton.frame.size.height);
    
    messageButton.fontLable.text = message;
    messageButton.fontLable.textAlignment = UITextAlignmentLeft;
    [messageButton setImage:nil forState:UIControlStateNormal];
}


- (IBAction)clickMessageButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickMessage:)]) {
        [_delegate didClickMessage:_message];
    }
}

@end



