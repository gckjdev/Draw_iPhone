//
//  DiceView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceView.h"
#import "DiceImageManager.h"


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
     customDiceType:(CustomDiceType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setImage:[[CustomDiceManager defaultManager] diceImageForType:type dice:pbDice.dice] forState:UIControlStateNormal];
        _diceId = pbDice.diceId;
        _dice = pbDice.dice;
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:self.seletedBgImageView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame 
               dice:(int)dice 
     customDiceType:(CustomDiceType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setImage:[[CustomDiceManager defaultManager] diceImageForType:type dice:dice] forState:UIControlStateNormal];
        _dice = dice;
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:self.seletedBgImageView];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame 
             pbDice:(PBDice *)pbDice 
{
    return [self initWithFrame:frame pbDice:pbDice customDiceType:CustomDiceTypeDefault];
}

- (id)initWithFrame:(CGRect)frame 
               dice:(int)dice 
{
    return [self initWithFrame:frame dice:dice customDiceType:CustomDiceTypeDefault];
}


- (void)setPBDice:(PBDice *)dice
{
    _dice = dice.dice;
    _diceId = dice.diceId;
}

- (void)setDice:(int)dice
{
    _dice = dice;
    [self setImage:[[DiceImageManager defaultManager] diceImageWithDice:_dice] forState:UIControlStateNormal];
    
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
