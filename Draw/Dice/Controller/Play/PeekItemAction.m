//
//  PeekItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-12.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "PeekItemAction.h"
#import "DiceView.h"
#import "DiceGamePlayController.h"

@implementation PeekItemAction

// Left to be realize for sub class.
- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [self peekOtherUserDice:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    
}

- (void)peekOtherUserDice:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    for (PBGameUser *user in _gameService.diceSession.playingUserList) {
        if ([_userManager isMe:user.userId]) {
            continue;
        }
        
        NSArray *diceList = [_gameService.diceSession.userDiceList objectForKey:user.userId];
        PBDice *dice = [diceList objectAtIndex:[self random]];
        
        UIView *diceView = [[[DiceView alloc] initWithFrame:CGRectMake(0, 0, 24, 25) dice:dice.dice] autorelease];
        UIView *bellView = [controller bellViewOfUser:user.userId];
        diceView.center = bellView.center;
        diceView.alpha = 0;
        
        [view addSubview:diceView];
        
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            diceView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:3 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                diceView.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                    diceView.alpha = 0;
                } completion:^(BOOL finished) {
                    [diceView removeFromSuperview];
                }];
            }];
        }];
    }
}

- (int)random
{
    srand((unsigned)time(0)); 
    int ran_num = rand() % 5; 
    
    return ran_num;
}

@end
