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
#import "CommonMessageCenter.h"
#import "LocaleUtils.h"
#import "AnimationPlayer.h"
#import "ConfigManager.h"
#import "ItemType.h"
#import "GameItemManager.h"

#define THROW_ITEM_TAG  20120713
#define RECIEVE_ITEM_TAG    120120713

#define THROWING_TIME   1.5
#define MISSING_TIME   1.5
#define ROATE_RATE      6

#define REWARD_EXP 5
#define REWARD_COINS 3

#define RADIUS  ([DeviceDetection isIPAD]?240:120)

#define ANIM_KEY_RECEIVE_TOMATO  @"ReceiveTomato"
#define ANIM_KEY_RECEIVE_FLOWER  @"ReceiveFlower"
#define ANIM_KEY_THROW_TOMATO   @"ThrowTomato"
#define ANIM_KEY_SEND_FLOWER    @"SendFlower"

#define POP_MESSAGE_HORIZON_OFFSET  (0)

#define ANIM_GROUP @"AnimationGroup"

@implementation DrawGameAnimationManager



+ (CAAnimationGroup*)createThrowItemAnimation:(UIImageView*)ItemImageView inViewController:(UIViewController*)viewController
{
    CGPoint startPoint = ItemImageView.center;
    CGPoint endPoint = viewController.view.center;
    [ItemImageView setCenter:endPoint];
    CAMediaTimingFunction *timming = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    CAAnimation* rolling = [AnimationManager rotateAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* throw = [AnimationManager translationAnimationFrom:startPoint to:endPoint duration:THROWING_TIME];

    throw.removedOnCompletion = NO;
    
    CAAnimation* enlarge = [AnimationManager scaleAnimationWithFromScale:1 toScale:5 duration:MISSING_TIME delegate:viewController removeCompeleted:YES];
    
    CAAnimation* miss = [AnimationManager disappearAnimationWithDuration:MISSING_TIME];
    
    enlarge.beginTime =  miss.beginTime = THROWING_TIME;
    
    enlarge.timingFunction = miss.timingFunction = throw.timingFunction = rolling.timingFunction = timming;
    
    //method2:放入动画数组，统一处理！
    CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
    
    //设置动画代理
//    animGroup.delegate = viewController;
    
    animGroup.removedOnCompletion = YES;
    animGroup.duration             = THROWING_TIME+MISSING_TIME;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations             = [NSArray arrayWithObjects:rolling, throw, enlarge, miss,nil];
    return animGroup;
    //[animGroup setValue:key forKey:DRAW_ANIM];
    //对视图自身的层添加组动画
//    ItemImageView.layer.opacity = 0;
//    [ItemImageView.layer addAnimation:animGroup forKey:ANIM_GROUP];
}


+ (void)showThrowTomato:(UIImageView*)tomatoImageView
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling
             itemEnough:(BOOL)enough
         shouldShowTips:(BOOL)shouldShowTips
             completion:(void (^)(BOOL))completion
{
    NSString* msg;
    if (enough) {
        msg = [NSString stringWithFormat:NSLS(@"kThrowTomatoMessage"),[ConfigManager getFlowerAwardExp], [ConfigManager getFlowerAwardAmount]];
    } else {
        int price = [[GameItemManager defaultManager] priceWithItemId:ItemTypeFlower];
        msg = [NSString stringWithFormat:NSLS(@"kThrowTomatoWithCoinsMessage"), price, [ConfigManager getFlowerAwardExp], [ConfigManager getFlowerAwardAmount]];
    }
    CAAnimationGroup* animationGroup = nil;
    if (rolling) {
        animationGroup =  [DrawGameAnimationManager createThrowItemAnimation:tomatoImageView inViewController:superController];
        
    }else{
        animationGroup = [AnimationManager scaleMissAnimation:MISSING_TIME scale:4 delegate:superController];
    }
    [AnimationPlayer showView:tomatoImageView inView:superController.view animation:animationGroup completion:^(BOOL finished) {
        completion(finished);
        if (shouldShowTips) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:msg delayTime:2 isHappy:YES atHorizon:POP_MESSAGE_HORIZON_OFFSET];
        }
    }];
}

+ (void)showThrowFlower:(UIImageView*)flowerImageView
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling
             itemEnough:(BOOL)enough
         shouldShowTips:(BOOL)shouldShowTips
             completion:(void (^)(BOOL))completion
{
    NSString* msg;
    if (enough) {
        msg = [NSString stringWithFormat:NSLS(@"kSendFlowerMessage"),[ConfigManager getFlowerAwardExp], [ConfigManager getFlowerAwardAmount]];
    } else {
        PBGameItem* flower = [[GameItemManager defaultManager] itemWithItemId:ItemTypeFlower];
        int price = [flower promotionPrice];
        msg = [NSString stringWithFormat:NSLS(@"kSendFlowerWithCoinsMessage"), price, [ConfigManager getFlowerAwardExp], [ConfigManager getFlowerAwardAmount]];
    }
    CAAnimationGroup* animationGroup = nil;
    if (rolling) {
        animationGroup =  [DrawGameAnimationManager createThrowItemAnimation:flowerImageView inViewController:superController];
    }else{
        animationGroup = [AnimationManager scaleMissAnimation:MISSING_TIME scale:4 delegate:superController];
    }
    
    //    [animationGroup setValue:ANIM_KEY_SEND_FLOWER forKey:DRAW_ANIM];
    [AnimationPlayer showView:flowerImageView inView:superController.view animation:animationGroup completion:^(BOOL finished) {
        completion(finished);
        if (shouldShowTips) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:msg delayTime:2 isHappy:YES atHorizon:POP_MESSAGE_HORIZON_OFFSET];
        }
     
    }];
    
}



+ (void)showThrowTomato:(UIImageView*)tomatoImageView 
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling
{
    [self showThrowTomato:tomatoImageView animInController:superController rolling:rolling itemEnough:YES shouldShowTips:YES completion:^(BOOL finished) {
        
    }];
}

+ (void)showThrowFlower:(UIImageView*)flowerImageView 
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling
{
    
    [self showThrowFlower:flowerImageView animInController:superController rolling:rolling itemEnough:YES shouldShowTips:YES completion:^(BOOL finished) {
        
    }];
}



+ (void)showReceiveFlower:(UIImageView*)flowerImageView 
    animationInController:(UIViewController*)viewController 
{
    CGPoint point = CGPointMake(viewController.view.center.x-RADIUS+(rand()%(2*RADIUS)), viewController.view.center.y-RADIUS+(rand()%(2*RADIUS)));
    [flowerImageView setCenter:point];

    
    CAAnimation* rolling = [AnimationManager rotateAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* disMiss = [AnimationManager disappearAnimationWithDuration:THROWING_TIME];
    CAAnimation* zoom = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:3 duration:THROWING_TIME delegate:viewController removeCompeleted:YES];
    [zoom setValue:ANIM_KEY_RECEIVE_FLOWER forKey:DRAW_ANIM];
    
    flowerImageView.layer.opacity = 0;
    [flowerImageView.layer addAnimation:rolling forKey:@"rolling"];
    [flowerImageView.layer addAnimation:disMiss forKey:@"disMiss"];
    [flowerImageView.layer addAnimation:zoom forKey:@"zoom"];
}
+ (void)showReceiveTomato:(UIImageView*)tomatoImageView  
    animaitonInController:(UIViewController*)viewController 
{
    tomatoImageView.layer.opacity = 0;
    CGPoint point = CGPointMake(viewController.view.center.x-RADIUS+(rand()%(2*RADIUS)), viewController.view.center.y-RADIUS+(rand()%(2*RADIUS)));
    [tomatoImageView setCenter:point];
    
    CAAnimation* rolling = [AnimationManager rotateAnimationWithRoundCount:ROATE_RATE*THROWING_TIME duration:THROWING_TIME];
    CAAnimation* disMiss = [AnimationManager disappearAnimationWithDuration:THROWING_TIME];
    CAAnimation* zoom = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:3 duration:THROWING_TIME delegate:viewController removeCompeleted:YES];
    [zoom setValue:ANIM_KEY_RECEIVE_TOMATO forKey:DRAW_ANIM];
    
    [tomatoImageView.layer addAnimation:rolling forKey:@"rolling"];
    [tomatoImageView.layer addAnimation:disMiss forKey:@"disMiss"];
    [tomatoImageView.layer addAnimation:zoom forKey:@"zoom"];
}

+ (void)animation:(CAAnimation *)anim didStopWithFlag:(BOOL)flag
{
    NSString* key = [anim valueForKey:DRAW_ANIM];
    if ([key isEqualToString:ANIM_KEY_RECEIVE_FLOWER]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kReceiveFlowerMessage"),REWARD_EXP, REWARD_COINS] delayTime:2 isHappy:YES atHorizon:POP_MESSAGE_HORIZON_OFFSET];
        //        [self popupMessage:[NSString stringWithFormat:NSLS(@"kReceiveFlowerMessage"),REWARD_EXP, REWARD_COINS] title:nil];
    }
    if ([key isEqualToString:ANIM_KEY_RECEIVE_TOMATO]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kReceiveTomatoMessage"),REWARD_EXP, REWARD_COINS] delayTime:2 isHappy:NO atHorizon:POP_MESSAGE_HORIZON_OFFSET];
        
    }
    if ([key isEqualToString:ANIM_KEY_SEND_FLOWER]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kSendFlowerMessage"),REWARD_EXP, REWARD_COINS] delayTime:2 isHappy:YES atHorizon:POP_MESSAGE_HORIZON_OFFSET];

    }
    if ([key isEqualToString:ANIM_KEY_THROW_TOMATO]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kThrowTomatoMessage"),REWARD_EXP, REWARD_COINS] delayTime:2 isHappy:YES atHorizon:POP_MESSAGE_HORIZON_OFFSET];

        
    }

}

@end
