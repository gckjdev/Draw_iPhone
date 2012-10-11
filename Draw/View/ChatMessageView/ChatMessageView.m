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

#define WIDTH_SCREEN ([DeviceDetection isIPAD] ? (768):(320))

#define TEXT_COLOR [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:61.0/255.0 alpha:1];


#define MAX_WIDTH_CHAT_MESSAGE_VIEW_IPHONE 90
#define MAX_WIDTH_CHAT_MESSAGE_VIEW_IPAD MAX_WIDTH_CHAT_MESSAGE_VIEW_IPHONE*2
#define MAX_WIDTH_CHAT_MESSAGE_VIEW ([DeviceDetection isIPAD] ? (MAX_WIDTH_CHAT_MESSAGE_VIEW_IPAD):(MAX_WIDTH_CHAT_MESSAGE_VIEW_IPHONE))

#define MIN_WIDTH_CHAT_MESSAGE_VIEW_IPHONE 60
#define MIN_WIDTH_CHAT_MESSAGE_VIEW_IPAD MIN_WIDTH_CHAT_MESSAGE_VIEW_IPHONE*2
#define MIN_WIDTH_CHAT_MESSAGE_VIEW ([DeviceDetection isIPAD] ? (MIN_WIDTH_CHAT_MESSAGE_VIEW_IPAD):(MIN_WIDTH_CHAT_MESSAGE_VIEW_IPHONE))

#define WIDTH_EXPRESSION_VIEW_IPHONE 24
#define WIDTH_EXPRESSION_VIEW_IPAD WIDTH_EXPRESSION_VIEW_IPHONE*2
#define WIDTH_EXPRESSION_VIEW ([DeviceDetection isIPAD] ? (WIDTH_EXPRESSION_VIEW_IPAD):(WIDTH_EXPRESSION_VIEW_IPHONE))

#define HEIGHT_EXPRESSION_VIEW WIDTH_EXPRESSION_VIEW

#define FONT_MESSAGE_TITLE_IPHONE [UIFont systemFontOfSize:14]
#define FONT_MESSAGE_TITLE_IPAD [UIFont systemFontOfSize:14*2]
#define FONT_MESSAGE_TITLE ([DeviceDetection isIPAD] ? (FONT_MESSAGE_TITLE_IPAD):(FONT_MESSAGE_TITLE_IPHONE))


#define FONT_CHAT_MESSAGE_TEXT_IPHONE [UIFont systemFontOfSize:13]
#define FONT_CHAT_MESSAGE_TEXT_IPAD [UIFont systemFontOfSize:13*2]
#define FONT_CHAT_MESSAGE_TEXT ([DeviceDetection isIPAD] ? (FONT_CHAT_MESSAGE_TEXT_IPAD):(FONT_CHAT_MESSAGE_TEXT_IPHONE))

#define WIDTH_EDGE_IPHONE 5
#define WIDTH_EDGE_IPAD WIDTH_EDGE_IPHONE*2
#define WIDTH_EDGE ([DeviceDetection isIPAD] ? (WIDTH_EDGE_IPAD):(WIDTH_EDGE_IPHONE))

#define HEIGHT_EDGE_IPHONE 2
#define HEIGHT_EDGE_IPAD HEIGHT_EDGE_IPHONE*2
#define HEIGHT_EDGE ([DeviceDetection isIPAD] ? (HEIGHT_EDGE_IPAD):(HEIGHT_EDGE_IPHONE))

#define HEIGHT_ONE_LINE_TITLE ([DeviceDetection isIPAD] ? (19 * 2):(19))


#define RATE (18.0/60.0)

@interface ChatMessageView ()

- (void)showInSuperView:(UIView*)superView origin:(CGPoint)origin;
- (void)addBgImage:(UIImage*)image;

- (UILabel *)genLabelWithText:(NSString*)text 
                         font:(UIFont*)font 
                   withinSize:(CGSize)withinSize 
                lineBreakMode:(UILineBreakMode)lineBreakMode;

@end

@implementation ChatMessageView

- (void)dealloc
{
    [super dealloc];
}

- (ChatMessageView*)initWithChatMessage:(NSString*)chatMessage 
                                  title:(NSString*)title
//                                 origin:(CGPoint)origin
{
    CGSize withinSize = CGSizeMake(MAX_WIDTH_CHAT_MESSAGE_VIEW, CGFLOAT_MAX);
    UILabel *titleLabel = [self genLabelWithText:title font:FONT_MESSAGE_TITLE withinSize:withinSize lineBreakMode:UILineBreakModeMiddleTruncation];
    titleLabel.numberOfLines = 1;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.frame = CGRectMake(0, 0, titleLabel.frame.size.width, HEIGHT_ONE_LINE_TITLE);
    titleLabel.textColor = TEXT_COLOR;
    
    UILabel *messageLable = [self genLabelWithText:chatMessage 
                                              font:FONT_CHAT_MESSAGE_TEXT 
                                        withinSize:withinSize 
                                     lineBreakMode:UILineBreakModeWordWrap];
    messageLable.backgroundColor = [UIColor clearColor];    
    messageLable.textColor = TEXT_COLOR;
    
    float width = MAX(titleLabel.frame.size.width, messageLable.frame.size.width) + WIDTH_EDGE*2;
    float height = (titleLabel == nil) ? (messageLable.frame.size.height+HEIGHT_EDGE*2) : (titleLabel.frame.size.height+messageLable.frame.size.height+HEIGHT_EDGE*3);
    
    self = [super initWithFrame:CGRectMake(0, 0, width, height/2*3)];
    if (self) {
//        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        UIImage *bgImage = ((origin.x+self.frame.size.width+WIDTH_EDGE) > WIDTH_SCREEN) ? [[ShareImageManager defaultManager] popupChatImageLeft] : [[ShareImageManager defaultManager] popupChatImageRight];
//        [bgImageView setImage:bgImage];
//        [self addSubview:bgImageView];
//        [bgImageView release];
        
        titleLabel.frame = CGRectMake(WIDTH_EDGE, 
                                      self.frame.size.height*RATE, 
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [self addSubview:titleLabel];
    
        float originY = (titleLabel == nil) ? (self.frame.size.height*RATE) : (titleLabel.frame.origin.y + titleLabel.frame.size.height + HEIGHT_EDGE);
        messageLable.frame = CGRectMake(WIDTH_EDGE,
                                        originY,
                                        messageLable.frame.size.width, 
                                        messageLable.frame.size.height);
        [self addSubview:messageLable];
        
        self.hidden = YES;
    }
    
    return self;
}


- (ChatMessageView*)initWithChatExpression:(UIImage*)expression
                                     title:(NSString*)title
//                                    origin:(CGPoint)origin
{    
    CGSize withinSize = CGSizeMake(MAX_WIDTH_CHAT_MESSAGE_VIEW, CGFLOAT_MAX);
    UILabel *titleLabel = [self genLabelWithText:title font:FONT_MESSAGE_TITLE withinSize:withinSize lineBreakMode:UILineBreakModeMiddleTruncation];
    titleLabel.numberOfLines = 1;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.frame = CGRectMake(0, 0, titleLabel.frame.size.width, 19);
    titleLabel.textColor = TEXT_COLOR;

    CGRect expressionViewRect = CGRectMake(0, 0, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW);
    UIImageView *expressionView = [[[UIImageView alloc] initWithFrame:expressionViewRect] autorelease];
    [expressionView setImage:expression];
    
    float width = MAX(titleLabel.frame.size.width, expressionView.frame.size.width) + WIDTH_EDGE*2;
    float height = (titleLabel == nil) ? (expressionView.frame.size.height+HEIGHT_EDGE*2) : (titleLabel.frame.size.height+expressionView.frame.size.height+HEIGHT_EDGE*3);
    
    self = [super initWithFrame:CGRectMake(0, 0, width, height/2*3)];
    if (self) {        
//        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        UIImage *bgImage = ((origin.x+self.frame.size.width+WIDTH_EDGE) > WIDTH_SCREEN) ? [[ShareImageManager defaultManager] popupChatImageLeft] : [[ShareImageManager defaultManager] popupChatImageRight];
//        [bgImageView setImage:bgImage];
//        [self addSubview:bgImageView];
//        [bgImageView release];
        
        titleLabel.frame = CGRectMake(WIDTH_EDGE, 
                                      self.frame.size.height*RATE, 
                                      titleLabel.frame.size.width,
                                      titleLabel.frame.size.height);
        [self addSubview:titleLabel];
        
        float originY = (titleLabel == nil) ? (self.frame.size.height*RATE) : (titleLabel.frame.origin.y + titleLabel.frame.size.height + HEIGHT_EDGE);
        expressionView.frame = CGRectMake(WIDTH_EDGE,
                                        originY,
                                        expressionView.frame.size.width, 
                                        expressionView.frame.size.height);
        [self addSubview:expressionView];
        
        self.hidden = YES;
    }
    
    return self;
}

- (UILabel *)genLabelWithText:(NSString*)text 
                         font:(UIFont*)font 
                   withinSize:(CGSize)withinSize 
                lineBreakMode:(UILineBreakMode)lineBreakMode
{
    if (text == nil) {
        return nil;
    }
    
    CGSize size = [text sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = CGRectMake(0, 0, size.width/0.8, size.height);
    
    [text drawInRect:rect withFont:font lineBreakMode:UILineBreakModeCharacterWrap];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:rect] autorelease];
    label.text = text;
    label.font = font;
    label.lineBreakMode = lineBreakMode;
    label.numberOfLines = 0;
    
    return label;
}

- (void)addBgImage:(UIImage*)image
{
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [bgImageView setImage:image];
    [self addSubview:bgImageView];
    [self sendSubviewToBack:bgImageView];
    [bgImageView release];
}

+ (void)showMessage:(NSString*)chatMessage title:(NSString*)title origin:(CGPoint)origin superView:(UIView*)superView
{
    ChatMessageView *view = [[ChatMessageView alloc] initWithChatMessage:chatMessage title:title];
    
    UIImage *bgImage = ((origin.x+view.frame.size.width+WIDTH_EDGE) > WIDTH_SCREEN) ? [[ShareImageManager defaultManager] popupChatImageLeft] : [[ShareImageManager defaultManager] popupChatImageRight];
    [view addBgImage:bgImage];
    
    origin = ((origin.x+view.frame.size.width+WIDTH_EDGE) > WIDTH_SCREEN) ? CGPointMake(origin.x-view.frame.size.width*3/4, origin.y) : origin;
    
    [view showInSuperView:superView origin:origin];
    [superView bringSubviewToFront:view];
    [view release];
}



+ (void)showExpression:(UIImage*)expression title:(NSString*)title origin:(CGPoint)origin superView:(UIView*)superView
{
    ChatMessageView *view = [[ChatMessageView alloc] initWithChatExpression:expression title:title];
    
    UIImage *bgImage = ((origin.x+view.frame.size.width+WIDTH_EDGE) > WIDTH_SCREEN) ? [[ShareImageManager defaultManager] popupChatImageLeft] : [[ShareImageManager defaultManager] popupChatImageRight];
    [view addBgImage:bgImage];
    
    origin = ((origin.x+view.frame.size.width+WIDTH_EDGE) > WIDTH_SCREEN) ? CGPointMake(origin.x-view.frame.size.width*3/4, origin.y) : origin;
    
    [view showInSuperView:superView origin:origin];
    [superView bringSubviewToFront:view];
    [view release];
}

- (void)showInSuperView:(UIView*)superView origin:(CGPoint)origin
{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);    
    [superView addSubview:self];
    self.alpha = 0;
    self.hidden = NO;
//    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:5];
//    [self.layer addAnimation:animation forKey:@"DismissAnimation"];
//    [superView bringSubviewToFront:self];
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:3 options:UIViewAnimationCurveEaseInOut animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [self removeFromSuperview];
        }];
    }];
}
            

@end
