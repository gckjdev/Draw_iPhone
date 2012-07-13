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

@interface DrawGameAnimationManager : NSObject

+ (void)showSendItem:(UIImageView*)ItemImageView 
    animInController:(UIViewController*)viewController;
+ (void)showReceiveFlower:(UIImageView*)flowerImageView 
    animationInController:(UIViewController*)viewController;
+ (void)showReceiveTomato:(UIImageView*)tomatoImageView  
    animaitonInController:(UIViewController*)viewController;
+ (void)showBuyItem:(UIImageView*)itemImageView  
   animInController:(UIViewController*)viewController;

@end
