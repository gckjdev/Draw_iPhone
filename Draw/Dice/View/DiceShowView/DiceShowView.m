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
@property (retain, nonatomic) NSMutableArray *diceViews;

@end

@implementation DiceShowView

@synthesize delegate = _delegate;
@synthesize dices = _dices;
@synthesize diceViews = _diceViews;

- (void)dealloc
{
    [_dices release];
    [_diceViews release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
              dices:(NSArray *)dices
    userInterAction:(BOOL)userInterAction
{
    frame = CGRectMake(frame.origin.x, frame.origin.y, EDGE_WIDTH * ([dices count] - 1) + DICE_VIEW_WIDTH * [dices count], DICE_VIEW_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dices = dices;
        self.diceViews = [NSMutableArray array];
        
        int i = 0;
  
        for (PBDice *dice in dices) {
            CGRect rect = CGRectMake((EDGE_WIDTH + DICE_VIEW_WIDTH) * i++, 0, DICE_VIEW_WIDTH, DICE_VIEW_HEIGHT);     

            DiceView *diceView = [[[DiceView alloc] initWithFrame:rect 
                                                           pbDice:dice] autorelease];
            [self.diceViews addObject:diceView];
            
            if (userInterAction) {
                [diceView addTarget:self 
                             action:@selector(clickDiceButton:)
                   forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self addSubview:diceView];
        }
    }
    
    return self;
}

- (void)clickDiceButton:(id)sender
{
    [self clearSelectedBgImage];
    DiceView *diceView  = (DiceView *)sender;
    diceView.seletedBgImageView.image = [[DiceImageManager defaultManager] diceSeletedBgImage];
    
    int diceId = diceView.diceId;
    PBDice *dice = [self findDiceWithDiceId:diceId];
    
    if ([_delegate respondsToSelector:@selector(didSelectedDice:)]) {
        [_delegate didSelectedDice:dice];
    }
}

- (void)clearSelectedBgImage
{
    for (DiceView *view in _diceViews) {
        view.seletedBgImageView.image = nil;
    }
}

- (PBDice *)findDiceWithDiceId:(int)diceId
{
    for (PBDice* dice in _dices) {
        if (diceId == dice.diceId) {
            return dice;
        }
    }
    
    return nil;
}

@end
