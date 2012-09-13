//
//  RollAgainItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "RollAgainItemAction.h"
#import "DiceGamePlayController.h"
#import "AnimationManager.h"

@implementation RollAgainItemAction

- (BOOL)isShowNameAnimation
{
    return YES;
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [self rollDiceAgain:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [self rollUserBell:userId controller:controller];
}


- (void)rollDiceAgain:(DiceGamePlayController *)controller
                 view:(UIView *)view
{
    controller.myDiceListHolderView.hidden = YES;
    [self rollUserBell:_userManager.userId controller:controller];
    [controller performSelector:@selector(rollDiceEnd) withObject:nil afterDelay:1];
}

- (void)rollUserBell:(NSString *)userId
          controller:(DiceGamePlayController *)controller
{
    UIView *bell = [controller bellViewOfUser:userId];
    bell.hidden = NO;
    [bell.layer addAnimation:[AnimationManager shakeLeftAndRightFrom:10 to:10 repeatCount:10 duration:1] forKey:@"shake"];
}

@end
