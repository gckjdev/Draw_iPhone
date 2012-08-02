//
//  DiceView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceView.h"
#import "DiceImageManager.h"

@implementation DiceView

- (id)initWithFrame:(CGRect)frame 
               dice:(PBDice *)dice
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.tag = dice.diceId;
        [self setImage:[[DiceImageManager defaultManager] diceImageWithDice:dice.dice] forState:UIControlStateNormal];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
