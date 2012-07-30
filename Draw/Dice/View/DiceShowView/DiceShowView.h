//
//  DiceShowView.h
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"

@protocol DiceShowViewDelegate <NSObject>

@optional
- (void)didSelectedDice:(Dice *)dice;

@end

@interface DiceShowView : UIView

@property (assign, nonatomic) id<DiceShowViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame 
              dices:(NSArray *)dices
    userInterAction:(BOOL)userInterAction;


@end
