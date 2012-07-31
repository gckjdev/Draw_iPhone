//
//  PopupView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "PopupView.h"
#import "CallDiceView.h"
#import "CMPopTipView.h"

@implementation PopupView

+ (void)popupCallDiceViewWithDice:(Dice *)dice
                            count:(int)count
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated
{
    UIView *callDiceView = [[[CallDiceView alloc] initWithDice:dice count:count] autorelease];
    CMPopTipView *popTipView = [[[CMPopTipView alloc] initWithCustomView:callDiceView] autorelease];
    [popTipView presentPointingAtView:view inView:inView animated:animated];
}

@end
