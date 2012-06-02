//
//  PickView.m
//  Draw
//
//  Created by  on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PickView.h"
#import "AnimationManager.h"

@implementation PickView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
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

@end
