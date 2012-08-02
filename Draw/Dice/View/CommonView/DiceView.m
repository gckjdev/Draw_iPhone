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

@property (retain, nonatomic) UIImageView *seletedBgImageView;

@end

@implementation DiceView

@synthesize seletedBgImageView = _seletedBgImageView;

- (void)dealloc
{
    [_seletedBgImageView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
               dice:(Dice *)dice

{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setImage:[[DiceImageManager defaultManager] diceImageWithDice:dice.dice] forState:UIControlStateNormal];
        
        self.seletedBgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        self.seletedBgImageView.image = [[DiceImageManager defaultManager]diceSeletedBgImage];
        self.seletedBgImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self setImageEdgeInsets:UIEdgeInsetsMake(5, 1.5, 0, 0)];

        [self addSubview:self.seletedBgImageView];
        [self sendSubviewToBack:self.seletedBgImageView];
        
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
