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

- (BOOL)useScene
{
    return ([_gameService.diceSession itemUseCount:_itemType] < 1);
}

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)] autorelease];
    [label setFont:[UIFont systemFontOfSize:50]];
    label.text = [Item nameForItemType:itemType];
    label.textAlignment = UITextAlignmentCenter;
    [label setBackgroundColor:[UIColor clearColor]];
    label.center = view.center;
    
    [view addSubview:label];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        label.center = [[controller bellViewOfUser:userId] center];
        label.transform = CGAffineTransformMakeScale(0.3, 0.3);
        label.alpha = 0.3;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view 
              response:(UseItemResponse *)response
{
    [self rollDiceAgain:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view 
               request:(UseItemRequest *)request
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
