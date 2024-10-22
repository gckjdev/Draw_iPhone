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
#import "CMPopTipView.h"
#import "GameConstants.pb.h"

@protocol DiceSelectedViewDelegate <NSObject>

@required
- (void)didSelectDice:(PBDice *)dice count:(int)count;

@end

@interface DiceSelectedView : UIView <UIScrollViewDelegate, UICustomPageControlDelegate, DiceShowViewDelegate, CMPopTipViewDelegate>

@property (assign, nonatomic) id<DiceSelectedViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView;

- (void)setLastCallDice:(int)lastCallDice
      lastCallDiceCount:(int)lastCallDiceCount
       playingUserCount:(int)playingUserCount
           maxCallCount:(int)maxCallCount;

- (void)disableUserInteraction;
- (void)enableUserInteraction;
- (void)dismiss;

@end
