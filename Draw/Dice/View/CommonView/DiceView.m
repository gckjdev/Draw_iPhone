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
    PBDice *_dice;
}

@end

@implementation DiceView

@synthesize seletedBgImageView = _seletedBgImageView;

- (void)dealloc
{
    [_dice release];
    [_seletedBgImageView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
               dice:(PBDice *)dice
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setImage:[[DiceImageManager defaultManager] diceImageWithDice:dice.dice] forState:UIControlStateNormal];
        self.dice = dice;
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [self addSubview:self.seletedBgImageView];
    }
    
    return self;
}

- (void)setDice:(PBDice *)dice
{
    if (dice == _dice) {
        return;
    }
    
    [_dice release];
    _dice = [dice retain];
    [self setImage:[[DiceImageManager defaultManager] diceImageWithDice:dice.dice] forState:UIControlStateNormal];
    
}

- (PBDice *)dice
{
    return _dice;
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
