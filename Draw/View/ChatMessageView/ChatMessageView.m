//
//  StableView.m
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatMessageView.h"
#import "ShareImageManager.h"
#import "AnimationManager.h"

#import "LocaleUtils.h"
#import "DeviceDetection.h"
#import "PPDebug.h"


#define MAX_WIDTH_CHAT_MESSAGE_VIEW 200
#define MIN_WIDTH_CHAT_MESSAGE_VIEW 80

#define WIDTH_EXPRESSION_VIEW 30
#define HEIGHT_EXPRESSION_VIEW WIDTH_EXPRESSION_VIEW

#define FONT_CHAT_MESSAGE_TEXT [UIFont systemFontOfSize:15]
#define MAX_MESSAGE_LINES 5
#define WIDTH_EDGE 5
#define HEIGHT_EDGE 5

#define RATE (20.0/60.0)

@implementation ChatMessageView

- (void)dealloc
{
    [super dealloc];
}

- (ChatMessageView*)initWithChatMessage:(NSString*)chatMessage
{
    CGSize messageSize = [self getStringSize:chatMessage font:FONT_CHAT_MESSAGE_TEXT];    
    self = [super initWithFrame:CGRectMake(0, 0, messageSize.width+WIDTH_EDGE*2, messageSize.height*2)];
    
    PPDebug(@"view.width = %f", self.frame.size.width);
    
    if (self) {        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [bgImageView setImage:[[ShareImageManager defaultManager] popupImage]];
        [self addSubview:bgImageView];
        [bgImageView release];
        
//        CGRect rect =  CGRectMake(WIDTH_EDGE, self.frame.size.height-messageSize.height-messageSize.height/3, self.frame.size.width, messageSize.height);
        CGRect rect =  CGRectMake(WIDTH_EDGE, self.frame.size.height*RATE, self.frame.size.width, messageSize.height);
        UILabel *messageLable = [[UILabel alloc] initWithFrame:rect];
        messageLable.text = chatMessage;
        messageLable.font = FONT_CHAT_MESSAGE_TEXT;
        messageLable.backgroundColor = [UIColor clearColor];
        messageLable.numberOfLines = 5;
        [self addSubview:messageLable];
        
        [messageLable release];
        
        self.hidden = YES;
    }
    
    return self;
}

- (ChatMessageView*)initWithChatTitle:(NSString*)title expression:(UIImage*)expression
{    
    CGSize titleSize = [self getStringSize:title font:FONT_CHAT_MESSAGE_TEXT];
    
    titleSize.width = (titleSize.width < WIDTH_EXPRESSION_VIEW) ? WIDTH_EXPRESSION_VIEW : titleSize.width;
    
    titleSize.height = (titleSize.height < 15) ? 15 : titleSize.height;
    
    self = [super initWithFrame:CGRectMake(0, 0, titleSize.width+WIDTH_EDGE*2, (titleSize.height+HEIGHT_EXPRESSION_VIEW+HEIGHT_EDGE*3)/2*3)];
    
    PPDebug(@"view.width = %f", self.frame.size.width);
    PPDebug(@"view.height = %f", self.frame.size.height);
    
    if (self) {        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [bgImageView setImage:[[ShareImageManager defaultManager] popupImage]];
        [self addSubview:bgImageView];
        [bgImageView release];
        
        if (title != nil) {
            CGRect titleRect =  CGRectMake(WIDTH_EDGE, self.frame.size.height*RATE, self.frame.size.width, titleSize.height);
            UILabel *titleLable = [[UILabel alloc] initWithFrame:titleRect];
            titleLable.text = title;
            titleLable.font = FONT_CHAT_MESSAGE_TEXT;
            titleLable.backgroundColor = [UIColor clearColor];
            titleLable.numberOfLines = 5;
            [self addSubview:titleLable];
            [titleLable release];
            
            CGRect expressionViewRect = CGRectMake(WIDTH_EDGE, titleLable.frame.origin.y+titleLable.frame.size.height+HEIGHT_EDGE, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW);

            UIImageView *expressionView = [[UIImageView alloc] initWithFrame:expressionViewRect];
            [expressionView setImage:expression];
            [self addSubview:expressionView];
            [self bringSubviewToFront:expressionView];
            [expressionView release];
        }
        else {
            CGRect expressionViewRect = CGRectMake(WIDTH_EDGE, self.frame.size.height*RATE, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW);
            UIImageView *expressionView = [[UIImageView alloc] initWithFrame:expressionViewRect];
            [expressionView setImage:expression];
            [self addSubview:expressionView];
            [expressionView release];
        }
        
        self.hidden = YES;
    }
    
    return self;
}

+ (void)showMessage:(NSString*)chatMessage origin:(CGPoint)origin superView:(UIView*)superView
{
    ChatMessageView *view = [[ChatMessageView alloc] initWithChatMessage:chatMessage];
    [view showInSuperView:superView origin:origin];
}

+ (void)showExpression:(UIImage*)expression title:(NSString*)title origin:(CGPoint)origin superView:(UIView*)superView
{
    ChatMessageView *view = [[ChatMessageView alloc] initWithChatTitle:title expression:expression];
    [view showInSuperView:superView origin:origin];
}

- (void)showInSuperView:(UIView*)superView origin:(CGPoint)origin
{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);    
    [superView addSubview:self];
    self.hidden = NO;
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:5];
    [self.layer addAnimation:animation forKey:@"DismissAnimation"];
    [superView bringSubviewToFront:self];
    
    [self release];
}
            
- (CGSize)getStringSize:(NSString*)string font:(UIFont*)font
{
    CGSize withinSize = CGSizeMake(MAX_WIDTH_CHAT_MESSAGE_VIEW, CGFLOAT_MAX);
    CGSize size = [string sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
    
    return size;
}

@end
