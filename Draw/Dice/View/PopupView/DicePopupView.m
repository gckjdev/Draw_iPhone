//
//  PopupView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DicePopupView.h"
#import "CallDiceView.h"
#import "CMPopTipView.h"

@interface DicePopupView ()

@end


@implementation DicePopupView

- (void)dealloc
{
    [super dealloc];
}

+ (void)popupCallDiceViewWithDice:(Dice *)dice
                            count:(int)count
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated
{
    UIView *callDiceView = [[[CallDiceView alloc] initWithDice:dice count:count] autorelease];
    CMPopTipView *popTipView = [[[CMPopTipView alloc] initWithCustomView:callDiceView] autorelease];
    popTipView.backgroundColor = [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.9];
    [popTipView presentPointingAtView:view inView:inView animated:animated];
    [popTipView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
}

@end
