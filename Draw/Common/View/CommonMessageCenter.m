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

#define MESSAGE_LABEL_WIDTH (ISIPAD ? 450 : 185)

#define MESSAGE_LABEL_MIN_HEIGHT (ISIPAD ? 120 : 55)

#define GAP_X (ISIPAD ? 30 : 30)
#define GAP_Y (ISIPAD ? 30 : 30)

@interface CommonMessageView : UIView 

@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@end

#pragma mark -
@implementation CommonMessageView

- (void) dealloc{
    [_image release];
    [_messageLabel release];
    [_bgView release];
    [_imageView release];
	[super dealloc];
}

//AUTO_CREATE_VIEW_BY_XIB(CommonMessageView);
AUTO_CREATE_VIEW_BY_XIB_N(CommonMessageView);

- (void)setWithText:(NSString *)text
{
    [self.messageLabel setText:text];
    SET_MESSAGE_LABEL_STYLE(self.messageLabel);
    
    CGSize size = CGSizeMake(MESSAGE_LABEL_WIDTH, (ISIPAD ? 600 : 300));
    [self.messageLabel wrapTextWithConstrainedSize:size];
    
    if (_messageLabel.frame.size.height < MESSAGE_LABEL_MIN_HEIGHT) {
        [_messageLabel updateHeight:MESSAGE_LABEL_MIN_HEIGHT];
    }
    
    [self updateWidth:(2 * GAP_X + MESSAGE_LABEL_WIDTH)];
    [self updateHeight:(2 * GAP_Y + MESSAGE_LABEL_MIN_HEIGHT)];
    
    [self.messageLabel updateCenterX:self.frame.size.width/2];
    [self.messageLabel updateCenterY:self.frame.size.height/2];
    
    self.bgView.backgroundColor = COLOR_WHITE;
    SET_VIEW_ROUND_CORNER(self.bgView);
    self.bgView.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.bgView.layer.borderColor = [COLOR_ORANGE CGColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setWithImage:(UIImage *)image text:(NSString *)text
{
    self.imageView.image = image;
    
    [self.messageLabel setText:text];
    SET_MESSAGE_LABEL_STYLE(self.messageLabel);
    
    self.bgView.backgroundColor = COLOR_WHITE;
    SET_VIEW_ROUND_CORNER(self.bgView);
    self.bgView.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.bgView.layer.borderColor = [COLOR_ORANGE CGColor];
    self.backgroundColor = [UIColor clearColor];
    
    CGSize originSize = self.messageLabel.frame.size;
    CGSize constrainedSize = CGSizeMake((ISIPAD?456:210), (ISIPAD ? 600 : 300));
    [self.messageLabel wrapTextWithConstrainedSize:constrainedSize];
    
    
    [self updateWidth:(self.frame.size.width + self.messageLabel.frame.size.width - originSize.width)];
    
    if (self.messageLabel.frame.size.height > originSize.height) {

        [self.imageView updateCenterY:self.messageLabel.center.y];
        [self updateHeight:(self.frame.size.height + self.messageLabel.frame.size.height - originSize.height)];
    }else{
        
        [self.messageLabel updateCenterY:self.imageView.center.y];
    }
    
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
    
    if (image == nil) {
        
        self.view = [CommonMessageView createViewWithIndex:0];
        [_view setWithText:text];
        
    }else{
        
        self.view = [CommonMessageView createViewWithIndex:1];
        [_view setWithImage:image text:text];
    }
    

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
    UIImage *image = nil;
    if (isHappy) {
        image = [ShareImageManager happyLogo];
    }else{
        image = [ShareImageManager unhappyLogo];
    }
	[self postMessageWithText:text 
                        image:image
                    delayTime:delayTime];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime
               isSuccessful:(BOOL)isSuccessful
{
    UIImage *image = nil;
    if (isSuccessful) {
        image = [ShareImageManager happyLogo];
    }else{
        image = [ShareImageManager unhappyLogo];
    }
	[self postMessageWithText:text
                        image:image
                    delayTime:delayTime];
}

- (void)postWithCustomView:(UIView *)view
                 delayTime:(float)delayTime{
    
    if (_active) {
        return;
    }
    
    self.view = [CommonMessageView createViewWithIndex:0];
    [_view setWithText:nil];
    self.view.messageLabel.hidden = YES;
    
    CGSize size = CGSizeMake(view.frame.size.width + 2 * GAP_X, view.frame.size.height + 2 * GAP_Y);
    [self.view updateWidth:size.width];
    [self.view updateHeight:size.height];
    
    [self.view.bgView updateWidth:size.width];
    [self.view.bgView updateHeight:size.height];
    
    [view updateOriginX:GAP_X];
    [view updateOriginY:GAP_Y];
    [self.view.bgView addSubview:view];
    
    [self postView:_view delay:delayTime];
}


- (void)postView:(UIView *)view delay:(int)delay{
    	
    _active = YES;
    
    CGFloat centerX = [[UIScreen mainScreen] applicationFrame].size.width/2;
    CGFloat centerY = [[UIScreen mainScreen] applicationFrame].size.height/2;
    [view updateCenterX:centerX];
    [view updateCenterY:centerY];
    view.alpha = 0;
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        view.transform = CGAffineTransformMakeRotation(M_PI);
    }else{
        view.transform = CGAffineTransformIdentity;
    }

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
