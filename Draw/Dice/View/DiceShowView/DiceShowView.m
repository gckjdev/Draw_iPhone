//
//  DiceShowView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceShowView.h"
#import "DiceImageManager.h"

#define EDGE_WIDTH 3
#define DICE_WIDTH 33
#define DICE_HEIGHT 35

@implementation DiceShowView

- (id)initWithFrame:(CGRect)frame 
              dices:(NSArray *)dices
    userInterAction:(BOOL)userInterAction
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int i = 0;
        for (Dice *dice in dices) {
            CGRect rect = CGRectMake((EDGE_WIDTH + DICE_WIDTH) * i, 0, DICE_WIDTH, DICE_HEIGHT);     

            UIView *view = [self DiceWithFrame:rect 
                                          dice:dice.dice
                               userInterAction:userInterAction];
            
            [self addSubview:view];
        }
    }
    
    return self;
}

- (UIView *)DiceWithFrame:(CGRect)frame
                     dice:(int)dice
          userInterAction:(BOOL)userInterAction
{

    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    button.enabled = userInterAction;
    [button setImage:[[DiceImageManager defaultManager] diceImageWithDice:dice] forState:UIControlStateNormal];
    
    button addTarget:self action:@selector(@) forControlEvents:<#(UIControlEvents)#>
    
    return button;
}

- 

@end
