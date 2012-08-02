//
//  DiceSelectedView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-1.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomPageControl.h"
#import "DiceShowView.h"

@protocol DiceSelectedView <NSObject>

@required
- (void)didSelectedDice:(PBDice *)dice count:(int)count;

@end

@interface DiceSelectedView : UIView <UIScrollViewDelegate, UICustomPageControlDelegate, DiceShowViewDelegate>

- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView;

- (void)setStart:(int)start 
             end:(int)end 
    lastCallDice:(int)lastCallDice;

@end
