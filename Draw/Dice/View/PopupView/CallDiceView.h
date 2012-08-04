//
//  CallDiceView.h
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"

@interface CallDiceView : UIView

- (id)initWithDice:(int)dice count:(int)count;

- (void)setDice:(int)dice count:(int)count;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
