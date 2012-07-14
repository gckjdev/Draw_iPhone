//
//  DrawGameAnimationManager.m
//  Draw
//
//  Created by Orange on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameAnimationManager.h"
#import "AnimationManager.h"
#import "DeviceDetection.h"

#define THROW_ITEM_TAG  20120713
#define RECIEVE_ITEM_TAG    120120713

#define THROWING_TIME   2
#define ROATE_RATE      10

#define RADIUS  ([DeviceDetection isIPAD]?240:120)

#define ANIM_GROUP @"AnimationGroup"

@implementation DrawGameAnimationManager

+ (void)showSendItem:(UIImageView*)ItemImageView 
    animInController:(UIViewController*)viewController
{
    [ItemImageView setFrame:CGRectMake(0, 0, ItemImageView.frame.size.width*2, ItemImageView.frame.size.height*2)];
    CGPoint startPoint = CGPointMake(viewController.view.frame.size.width/2, viewController.view.frame.size.height);
    CGPoint endPoint = CGPointMake(viewController.view.center.x-RADIUS+(rand()%(2*RADIUS)), viewController.view.center.y-RADIUS+(rand()%(2*RADIUS)));
    [ItemImageView setCenter:endPoint];
    
    CAAnimation* rolling = [AnimationManager rotationAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* throw = [AnimationManager translationAnimationFrom:startPoint to:endPoint duration:THROWING_TIME];
    throw.removedOnCompletion = NO;
    CAAnimation* zoom = [AnimationManager scaleAnimationWithScale:0.01 duration:THROWING_TIME delegate:viewController removeCompeleted:NO];
    
    CAAnimation* enlarge = [AnimationManager scaleAnimationWithFromScale:0.01 toScale:1 duration:1 delegate:viewController removeCompeleted:NO];
    enlarge.beginTime = THROWING_TIME;
    CAAnimation* miss = [AnimationManager missingAnimationWithDuration:1];
    miss.beginTime = THROWING_TIME;
    
    //method2:放入动画数组，统一处理！
    CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
    
    //设置动画代理
    animGroup.delegate = viewController;
    
    animGroup.removedOnCompletion = NO;
    animGroup.duration             = THROWING_TIME+1;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations             = [NSArray arrayWithObjects:rolling, throw, zoom, enlarge, miss,nil];
    //对视图自身的层添加组动画
    [ItemImageView.layer addAnimation:animGroup forKey:ANIM_GROUP];
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
