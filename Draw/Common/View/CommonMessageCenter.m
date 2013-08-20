//
//  CommonMessageCenter.m
//  Draw
//
//  Created by Orange on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonMessageCenter.h"
#import "LocaleUtils.h"
#import "UILabel+Extend.h"
#import "AutoCreateViewByXib.h"
#import "SynthesizeSingleton.h"
#import "ShareImageManager.h"

typedef enum {
    MessageViewTypeTextOnly = 0,
    MessageViewTypeWithSmallImage,
    MessageViewTypeWithHappyFace,
    MessageViewTypeWithUnhappyFace,
}MessageViewType;

#define MESSAGE_FONT_SIZE ([DeviceDetection isIPAD] ? 24 : 12)
#define MESSAGE_LABEL_WIDTH (ISIPAD ? 500 : 250)


#define MIN_SIZE (ISIPAD ? CGSizeMake(610, 142) : CGSizeMake(280, 65))


@interface CommonMessageView : UIView 

@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UIView *bgView;

@end

#pragma mark -
@implementation CommonMessageView

- (void) dealloc{
    [_image release];
    [_messageLabel release];
    [_bgView release];
	[super dealloc];
}

AUTO_CREATE_VIEW_BY_XIB(CommonMessageView);

- (void)setWithImage:(UIImage *)image
                text:(NSString *)text
{
    [self.messageLabel setTextColor:[GameApp popupMessageDialogFontColor]];
	[self.messageLabel setText:text];
    [self.messageLabel setTextAlignment:UITextAlignmentLeft];
    [self.messageLabel setFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE]];
    if ([LocaleUtils isChinese]) {
        [self.messageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    } else {
        [self.messageLabel setLineBreakMode:UILineBreakModeWordWrap];
    }
    CGSize size = CGSizeMake(MESSAGE_LABEL_WIDTH, 300);
    [self.messageLabel wrapTextWithConstrainedSize:size];
    
    [self updateHeight:MAX(self.messageLabel.frame.size.height, MIN_SIZE.height)];
    
    [self.messageLabel updateCenterX:self.frame.size.width/2];
    [self.messageLabel updateCenterY:self.frame.size.height/2];
        
    self.bgView.backgroundColor = COLOR_WHITE;
    SET_VIEW_ROUND_CORNER(self.bgView);
    self.bgView.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.bgView.layer.borderColor = [COLOR_ORANGE CGColor];
    
    self.backgroundColor = [UIColor clearColor];
}

@end

@interface CommonMessageCenter(){
    BOOL _active;
}

@property (retain, nonatomic) CommonMessageView *view;

@end

@implementation CommonMessageCenter

SINGLETON_DISPATCH_ONE;

- (void) dealloc{
    
    [_view release];
    [super dealloc];
}

+ (CommonMessageCenter*) defaultCenter {
	
    return [self defaultManager];
    
}

- (void)postMessageWithText:(NSString *)text 
                      image:(UIImage *)image
                  delayTime:(float)delayTime{
    
    if (_active) {
        return;
    }
    
    self.view = [CommonMessageView createView];
    [_view setWithImage:image text:text];
    [self postView:_view delay:delayTime];
}

- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime{
    
	[self postMessageWithText:text 
                        image:nil
                    delayTime:delayTime];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime 
                    isHappy:(BOOL)isHappy
{

	[self postMessageWithText:text 
                        image:nil
                    delayTime:delayTime];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime
               isSuccessful:(BOOL)isSuccessful
{
	[self postMessageWithText:text
                        image:nil
                    delayTime:delayTime];
}

- (void)postView:(UIView *)view delay:(int)delay{
    	
    _active = YES;
    
    CGFloat centerX = [[UIScreen mainScreen] applicationFrame].size.width/2;
    CGFloat centerY = [[UIScreen mainScreen] applicationFrame].size.height/2;
    [view updateCenterX:centerX];
    [view updateCenterY:centerY];
    view.alpha = 0;

    [[UIApplication sharedApplication].keyWindow addSubview:view];

    [UIView animateWithDuration:0.15 animations:^{
        view.alpha = 1;
    }];
    
    [self performSelector:@selector(disappear) withObject:nil afterDelay:delay];
}

- (void)disappear{
    
    _active = NO;
    [_view removeFromSuperview];
    self.view = nil;
}

@end
