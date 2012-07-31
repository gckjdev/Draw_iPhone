//
//  DiceView.h
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"

#define DICE_WIDTH 33
#define DICE_HEIGHT 35

@interface DiceView : UIButton

- (id)initWithFrame:(CGRect)frame 
               dice:(Dice *)dice;

@end
