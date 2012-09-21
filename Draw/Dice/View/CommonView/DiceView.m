//
//  DiceView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceView.h"
#import "DiceImageManager.h"
#import "CustomDiceManager.h"

@interface DiceView ()
{
    int _diceId;
    int _dice;
}

@end

@implementation DiceView

@synthesize seletedBgImageView = _seletedBgImageView;

- (void)dealloc
{
    [_seletedBgImageView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
             pbDice:(PBDice *)pbDice
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setImage:[[CustomDiceManager defaultManager] myDiceImage:pbDice.dice] forState:UIControlStateNormal];
        _diceId = pbDice.diceId;
        _dice = pbDice.dice;
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:self.seletedBgImageView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame 
               dice:(int)dice
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setImage:[[CustomDiceManager defaultManager] myDiceImage:dice] forState:UIControlStateNormal];
        _dice = dice;
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:self.seletedBgImageView];
    }
    
    return self;
}

- (void)setPBDice:(PBDice *)dice
{
    _dice = dice.dice;
    _diceId = dice.diceId;
}

- (void)setDice:(int)dice
{
    _dice = dice;
    [self setImage:[[CustomDiceManager defaultManager] myDiceImage:_dice] forState:UIControlStateNormal];
    
}

- (int)dice
{
    return _dice;
}

- (int)diceId
{
    return _diceId;
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
