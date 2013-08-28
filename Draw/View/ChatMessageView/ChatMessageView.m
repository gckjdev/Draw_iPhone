//
//  StableView.m
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatMessageView.h"
#import "ShareImageManager.h"
#import "CMPopTipView.h"


#define TEXT_COLOR COLOR_WHITE
#define VALUE(X) (ISIPAD ? 2*(X): (X))
#define WIDTH_EXPRESSION_VIEW VALUE(24)
#define FONT_MESSAGE [UIFont systemFontOfSize:VALUE(14)]
#define SHOW_TIME (5)

#define MSG_SPACE VALUE(4)

@interface ChatMessageView ()

@property(nonatomic, retain)CMPopTipView *popView;

@end

@implementation ChatMessageView

- (void)dealloc
{
    [super dealloc];
}

- (void)showAtView:(UIView *)atView
            inView:(UIView *)inView
{
    if (!self.popView) {
        self.popView = [[[CMPopTipView alloc] initWithCustomView:self] autorelease];
    }
    self.popView.delegate = self;
    [self.popView presentPointingAtView:atView inView:inView animated:YES];
    [self performSelector:@selector(hide) withObject:@(YES) afterDelay:SHOW_TIME];
}
- (void)hide
{
    [self.popView dismissAnimated:YES];
}

#define LABEL_TAG 123
#define IMAGE_TAG 124
- (UILabel *)createLabelWithText:(NSString *)txt
{
    UILabel *label = [self reuseLabelWithTag:LABEL_TAG frame:CGRectMake(0, 0, 1, 1) font:FONT_MESSAGE text:txt];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:TEXT_COLOR];
    [label setNumberOfLines:0];
    [label sizeToFit];
    [label updateHeight:MSG_SPACE+(CGRectGetHeight(label.frame))];
    return label;
}

+ (void)showMessage:(NSString*)chatMessage
              title:(NSString*)title
             atView:(UIView *)atView
             inView:(UIView *)inView
{
    ChatMessageView *cv = [[[ChatMessageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)] autorelease];
    NSString *msg = (title == nil) ? chatMessage : [NSString stringWithFormat:@"%@ \n%@", title, chatMessage];
    UILabel *label = [cv createLabelWithText:msg];
    //update cv frame
    cv.frame = label.frame;
    [cv showAtView:atView inView:inView];    
}

+ (void)showExpression:(UIImage*)expression
                 title:(NSString*)title
                atView:(UIView *)atView
                inView:(UIView *)inView
{
    ChatMessageView *cv = [[[ChatMessageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)] autorelease];
    
    UILabel *label = [cv createLabelWithText:title];
    UIImageView *iv = (id)[cv reuseViewWithTag:IMAGE_TAG
               viewClass:[UIImageView class]
                   frame:CGRectMake(CGRectGetMinX(label.frame), CGRectGetMaxY(label.frame), WIDTH_EXPRESSION_VIEW, WIDTH_EXPRESSION_VIEW)];
    [iv setImage:expression];
    CGFloat width = MAX(CGRectGetWidth(iv.frame), CGRectGetWidth(label.frame));
    CGFloat height = CGRectGetMaxY(iv.frame);    
    cv.frame = CGRectMake(0, 0, width, height);
    [cv showAtView:atView inView:inView];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    self.popView = nil;
}
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    self.popView = nil;    
}
@end
