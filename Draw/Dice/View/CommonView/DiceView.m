//
//  DiceView.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceView.h"
#import "DiceImageManager.h"

//#define DICE_WIDTH 33
//#define DICE_HEIGHT 35

@interface DiceView ()


@end

@implementation DiceView

@synthesize seletedBgImageView = _seletedBgImageView;

- (void)dealloc
{
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
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];

        [self addSubview:self.seletedBgImageView];
        
        self.tag = dice.diceId;
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
