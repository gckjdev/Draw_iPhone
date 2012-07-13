//
//  DrawGameAnimationManager.m
//  Draw
//
//  Created by Orange on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameAnimationManager.h"
#import "AnimationManager.h"

#define THROW_ITEM_TAG  20120713
#define RECIEVE_ITEM_TAG    120120713

#define THROWING_TIME   2
#define ROATE_RATE      10

@implementation DrawGameAnimationManager

+ (void)showSendItem:(UIImageView*)ItemImageView 
    animInController:(UIViewController*)viewController
{
    [ItemImageView setCenter:CGPointMake(viewController.view.frame.size.width/2, viewController.view.frame.size.height)];
    
    CAAnimation* rolling = [AnimationManager rotationAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* throw = [AnimationManager translationAnimationTo:CGPointMake(viewController.view.frame.size.width/2, 0) duration:THROWING_TIME];
    CAAnimation* zoom = [AnimationManager scaleAnimationWithScale:0.01 duration:THROWING_TIME delegate:viewController removeCompeleted:NO];
    
    [ItemImageView.layer addAnimation:rolling forKey:@"rolling"];
    [ItemImageView.layer addAnimation:throw forKey:@"throw"];
    [ItemImageView.layer addAnimation:zoom forKey:@"zoom"];
}
+ (void)showReceiveFlower:(UIImageView*)flowerImageView 
    animationInController:(UIViewController*)viewController
{
    [flowerImageView setCenter:viewController.view.center];

    
    CAAnimation* rolling = [AnimationManager rotationAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* disMiss = [AnimationManager missingAnimationWithDuration:THROWING_TIME];
    CAAnimation* zoom = [AnimationManager scaleAnimationWithScale:20 duration:THROWING_TIME delegate:viewController removeCompeleted:NO];
    
    [flowerImageView.layer addAnimation:rolling forKey:@"rolling"];
    [flowerImageView.layer addAnimation:disMiss forKey:@"disMiss"];
    [flowerImageView.layer addAnimation:zoom forKey:@"zoom"];
}
+ (void)showReceiveTomato:(UIImageView*)tomatoImageView  
    animaitonInController:(UIViewController*)viewController
{
    [tomatoImageView setCenter:viewController.view.center];
    
    
    CAAnimation* rolling = [AnimationManager rotationAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* disMiss = [AnimationManager missingAnimationWithDuration:THROWING_TIME];
    CAAnimation* zoom = [AnimationManager scaleAnimationWithScale:20 duration:THROWING_TIME delegate:viewController removeCompeleted:NO];
    
    [tomatoImageView.layer addAnimation:rolling forKey:@"rolling"];
    [tomatoImageView.layer addAnimation:disMiss forKey:@"disMiss"];
    [tomatoImageView.layer addAnimation:zoom forKey:@"zoom"];
}
+ (void)showBuyItem:(UIImageView*)itemImageView  
   animInController:(UIViewController*)viewController
{
    
}

@end
