//
//  AnimationManager.m
//  Draw
//
//  Created by  on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AnimationManager.h"

@implementation AnimationManager

+ (void)popUpView:(UIView *)view 
  fromPosition:(CGPoint)fromPosition 
    toPosition:(CGPoint)toPosition
         interval:(NSTimeInterval)interval 
         delegate:(id)delegate
{
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    [translation setDuration:interval];
    [translation setFromValue:[NSValue valueWithCGPoint:fromPosition]];
    [translation setToValue:[NSValue valueWithCGPoint:toPosition]];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    translation.fillMode = kCAFillModeForwards;
    translation.removedOnCompletion = NO;

    
    CABasicAnimation * opacityAnimation = [CABasicAnimation 
                                    animationWithKeyPath:@"opacity"]; 
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    opacityAnimation.toValue = [NSNumber numberWithInt:0];
    opacityAnimation.duration = interval;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:translation forKey:@"translation"];
    [view.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}


@end
