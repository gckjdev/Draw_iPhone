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

+ (void)showSendItem:(UIImageView*)ItemImageView 
    animInController:(UIViewController*)viewController 
             withKey:(NSString*)key;
+ (void)showReceiveFlower:(UIImageView*)flowerImageView 
    animationInController:(UIViewController*)viewController 
                  withKey:(NSString*)key;
+ (void)showReceiveTomato:(UIImageView*)tomatoImageView  
    animaitonInController:(UIViewController*)viewController 
                  withKey:(NSString*)key;
+ (void)showBuyItem:(UIImageView*)itemImageView  
   animInController:(UIViewController*)viewController;

@end
