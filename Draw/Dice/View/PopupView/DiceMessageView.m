//
//  DiceMessageView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-4.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceMessageView.h"
#import "StringUtil.h"

#define DEFAULT_BG_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]

#define MESSAGE_MAX_WIDTH   ([DeviceDetection isIPAD] ? 400 : 200 )
#define MESSAGE_MIN_WIDTH   ([DeviceDetection isIPAD] ? 50 : 25 )

@interface DiceMessageView ()

@property (retain, nonatomic) CMPopTipView *popTipView;

@end

@implementation DiceMessageView

@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_popTipView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
            message:(NSString *)message
           fontName:(NSString *)fontName 
          pointSize:(CGFloat)pointSize  
{
    return [self initWithFrame:frame
                       message:message
                      fontName:fontName 
                     pointSize:pointSize 
                 textAlignment:UITextAlignmentLeft];
}

- (id)initWithFrame:(CGRect)frame
            message:(NSString *)message
           fontName:(NSString *)fontName 
          pointSize:(CGFloat)pointSize  
      textAlignment:(UITextAlignment)textAlignment
{
    CGSize withSize = CGSizeMake(MESSAGE_MAX_WIDTH, MAXFLOAT);
    UILineBreakMode mode = [LocaleUtils isChinese] ? UILineBreakModeCharacterWrap : UILineBreakModeWordWrap;
    
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:pointSize] constrainedToSize:withSize lineBreakMode:mode];
    size.width = (size.width < MESSAGE_MIN_WIDTH) ? MESSAGE_MIN_WIDTH : size.width;
    size.width = size.width * 1.1;
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height);
    if (self = [self initWithFrame:rect]) {
        self.text = message;
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont systemFontOfSize:pointSize];
        self.lineBreakMode = mode;
        self.textAlignment = textAlignment;
        self.numberOfLines = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)popupAtView:(UIView *)atView
             inView:(UIView *)inView
       aboveSubView:(UIView *)siblingSubview
           duration:(int)duration
    backgroundColor:(UIColor *)backgroundColor
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection
{
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self] autorelease];
    _popTipView.backgroundColor = backgroundColor;
    _popTipView.disableTapToDismiss = YES;
    
    [_popTipView presentPointingAtView:atView
                                inView:inView 
                             aboveView:siblingSubview
                              animated:animated 
                        pointDirection:pointDirection];
    
    if (duration != 0) {
        [self performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:animated] afterDelay:duration];
    }
}

- (void)popupAtView:(UIView *)atView
             inView:(UIView *)inView
       aboveSubView:(UIView *)siblingSubview
    backgroundColor:(UIColor *)backgroundColor
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection
{
    [self popupAtView:atView 
               inView:inView 
         aboveSubView:siblingSubview
             duration:0 
      backgroundColor:backgroundColor 
             animated:animated
       pointDirection:pointDirection];
}


- (void)dismissAnimated:(BOOL)animated
{
    [_popTipView dismissAnimated:animated];
    self.popTipView = nil;
}

@end
