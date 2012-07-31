//
//  CallDiceView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CallDiceView.h"
#import "DiceView.h"
#import "LocaleUtils.h"

#define CALL_DICE_VIEW_WIDTH 63
#define CALL_DICE_VIEW_HEIGHT 35

@interface CallDiceView ()

@end

@implementation CallDiceView

- (id)initWithDice:(Dice *)dice count:(int)count
{
    self = [super initWithFrame:CGRectMake(0, 0, 63, 32)];
    if (self) {
        // Initialization code
        UIView *diceView = [[[DiceView alloc] initWithFrame:CGRectMake(36, 0, DICE_WIDTH, DICE_HEIGHT)   
                                                       dice:dice] autorelease];
        diceView.userInteractionEnabled = NO;
        
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, CALL_DICE_VIEW_WIDTH - DICE_WIDTH, CALL_DICE_VIEW_HEIGHT)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:NSLS(@"%d X "), count]; 
        
        
        [self addSubview:label];
        [self addSubview:diceView];
    }
    
    return self;
}



@end
