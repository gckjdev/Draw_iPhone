//
//  DrawGameAnimationManager.h
//  Draw
//
//  Created by Orange on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CAAnimation;
@class CAAnimationGroup;

#define DRAW_ANIM   @"DrawGameAnimation"

@interface DrawGameAnimationManager : NSObject

+ (void)showThrowTomato:(UIImageView*)tomatoImageView 
       animInController:(UIViewController*)superController 
                rolling:(BOOL)rolling;

+ (void)showThrowFlower:(UIImageView*)flowerImageView 
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling;

+ (void)showReceiveFlower:(UIImageView*)flowerImageView 
    animationInController:(UIViewController*)viewController;

+ (void)showReceiveTomato:(UIImageView*)tomatoImageView  
    animaitonInController:(UIViewController*)viewController;

+ (void)showBuyItem:(UIImageView*)itemImageView  

   animInController:(UIViewController*)viewController;

+ (void)animation:(CAAnimation*)anim didStopWithFlag:(BOOL)flag;

+ (CAAnimationGroup*)createThrowItemAnimation:(UIImageView*)ItemImageView inViewController:(UIViewController*)viewController;


+ (void)showThrowTomato:(UIImageView*)tomatoImageView
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling
             itemEnough:(BOOL)enough
         shouldShowTips:(BOOL)shouldShowTips
             completion:(void (^)(BOOL finished))completion;


+ (void)showThrowFlower:(UIImageView*)flowerImageView
       animInController:(UIViewController*)superController
                rolling:(BOOL)rolling
             itemEnough:(BOOL)enough
         shouldShowTips:(BOOL)shouldShowTips
             completion:(void (^)(BOOL))completion;

@end
