//
//  DiceShowView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceShowView.h"
#import "DiceView.h"
#import "DiceImageManager.h"


#define EDGE_WIDTH 3


@interface DiceShowView ()

@property (retain, nonatomic) NSArray *dices;

@end

@implementation DiceShowView

@synthesize delegate = _delegate;
@synthesize dices = _dices;

- (void)dealloc
{
    [_dices release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
              dices:(NSArray *)dices
    userInterAction:(BOOL)userInterAction
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, EDGE_WIDTH * ([dices count] - 1) + DICE_WIDTH * [dices count], DICE_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dices = dices;
        
        int i = 0;
        for (Dice *dice in dices) {
            CGRect rect = CGRectMake((EDGE_WIDTH + DICE_WIDTH) * i++, 0, DICE_WIDTH, DICE_HEIGHT);     

            UIButton *diceView = [[[DiceView alloc] initWithFrame:rect 
                                                       dice:dice] autorelease];
            [diceView addTarget:self 
                       action:@selector(clickDiceButton:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:diceView];
        }
    }
    
    return self;
}

- (void)clickDiceButton:(id)sender
{
    UIButton *button  = (UIButton *)sender;
    int diceId = button.tag;
    Dice *dice = [self findDiceWithDiceId:diceId];
    
    if ([_delegate respondsToSelector:@selector(didSelectedDice:)]) {
        [_delegate didSelectedDice:dice];
    }
}

- (Dice *)findDiceWithDiceId:(int)diceId
{
    for (Dice* dice in _dices) {
        if (diceId == dice.diceId) {
            return dice;
        }
    }
    
    return nil;
}

@end
