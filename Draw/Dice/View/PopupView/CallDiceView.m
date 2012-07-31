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
#import "UIViewUtils.h"

#define DICE_VIEW_TAG 101
#define COUNT_LABEL_TAG 102

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
        diceView.tag = DICE_VIEW_TAG;
        diceView.userInteractionEnabled = NO;
        
        
        UILabel *countLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, CALL_DICE_VIEW_HEIGHT)] autorelease];
        countLabel.tag = COUNT_LABEL_TAG;
        countLabel.backgroundColor = [UIColor clearColor];
        countLabel.text = [NSString stringWithFormat:NSLS(@"%d"), count]; 
        countLabel.font = [UIFont systemFontOfSize:27];
        
        UILabel *symbolLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 12, CALL_DICE_VIEW_HEIGHT)] autorelease];
        symbolLabel.backgroundColor = [UIColor clearColor];
        symbolLabel.text = [NSString stringWithFormat:NSLS(@"x")]; 
        
        [self addSubview:countLabel];
        [self addSubview:symbolLabel];
        [self addSubview:diceView];
    }
    
    return self;
}

@end
