//
//  PickView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickView.h"
#import "AnimationManager.h"
#import "CMPopTipView.h"

@implementation PickView
@synthesize delegate = _delegate;
@synthesize popTipView = _popTipView;
@synthesize dismiss = _dismiss;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.dismiss = YES;
    }
    return self;
}

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.2

- (void)startRunOutAnimation
{
    if (self.hidden) {
        return;
    }
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.00001 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.layer addAnimation:runOut forKey:@"runOut"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [super setHidden:YES];
    }
}


- (void)startRunInAnimation
{
    [super setHidden:NO];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:NO];
    [self.layer addAnimation:runIn forKey:@"runIn"];
    
}


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (hidden == self.hidden) {
        return;
    }
    
    if (!animated) {
        [super setHidden:hidden];
        return;
    }
    if (hidden == YES) {
        [self startRunOutAnimation];
    }else{    
        [self startRunInAnimation];
    }
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated withTag:(NSInteger)tag
{
    [self setHidden:hidden animated:animated];
    self.tag = tag;
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated
{
    [self.popTipView dismissAnimated:YES];
    self.dismiss = NO;
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self] autorelease];
    _popTipView.backgroundColor = [UIColor colorWithRed:168./255. green:168./255. blue:168./255. alpha:0.4];
//    _popTipView.backgroundColor = [UIColor clearColor];

    _popTipView.delegate = self;
    [_popTipView presentPointingAtView:view inView:inView animated:animated];
//    [_popTipView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (!self.dismiss) {
        [_popTipView dismissAnimated:YES];        
        self.dismiss = YES;
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    self.dismiss = YES;
}   
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    self.dismiss = YES;    
}


@end
