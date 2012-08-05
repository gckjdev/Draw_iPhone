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
#import "FontLabel.h"
#import "CMPopTipView.h"

#define DICE_VIEW_TAG 101
#define COUNT_LABEL_TAG 102

#define CALL_DICE_VIEW_WIDTH 63
#define CALL_DICE_VIEW_HEIGHT 35

#define COUNT_LABEL_WIDTH_1 16
#define COUNT_LABEL_WIDTH_2 30
#define SYMBOL_LABEL_WIDTH 12

#define CALL_DICE_POPUP_VIEW_BG_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]


@interface CallDiceView ()

@property (retain, nonatomic) DiceView *diceView;
@property (retain, nonatomic) FontLabel *countLabel;
@property (retain, nonatomic) CMPopTipView *popTipView;

@end


@implementation CallDiceView

@synthesize diceView = _diceView;
@synthesize countLabel = _countLabel;
@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_diceView release];
    [_countLabel release];
    [_popTipView release];
    [super dealloc];
}

- (id)initWithDice:(int)dice count:(int)count
{
    int countLableWidth = (count > 9) ? COUNT_LABEL_WIDTH_2 : COUNT_LABEL_WIDTH_1;
    self = [super initWithFrame:CGRectMake(0, 0, DICE_VIEW_WIDTH + countLableWidth + SYMBOL_LABEL_WIDTH, 32)];
    if (self) {
        // Initialization code

        self.diceView = [[[DiceView alloc] initWithFrame:CGRectMake(countLableWidth + SYMBOL_LABEL_WIDTH, 0, DICE_VIEW_WIDTH, DICE_VIEW_HEIGHT)   
                                                     dice:dice] autorelease];
        _diceView.userInteractionEnabled = NO;
        
        self.countLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(0, 0, countLableWidth, CALL_DICE_VIEW_HEIGHT) fontName:@"diceFont" pointSize:27] autorelease];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.text = [NSString stringWithFormat:NSLS(@"%d"), count]; 
        _countLabel.textAlignment = UITextAlignmentCenter;
        
        FontLabel *symbolLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(countLableWidth, 0, SYMBOL_LABEL_WIDTH, CALL_DICE_VIEW_HEIGHT) fontName:@"diceFont" pointSize:20] autorelease];
        symbolLabel.backgroundColor = [UIColor clearColor];
        symbolLabel.text = [NSString stringWithFormat:NSLS(@"x")]; 
        symbolLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:_countLabel];
        [self addSubview:symbolLabel];
        [self addSubview:_diceView];
    }
    
    return self;
}

- (void)setDice:(int)dice count:(int)count
{
    [_diceView setDice:dice];
    _countLabel.text = [NSString stringWithFormat:NSLS(@"%d"), count]; 
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated
{
    [self.popTipView dismissAnimated:YES];
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self] autorelease];
    _popTipView.backgroundColor = CALL_DICE_POPUP_VIEW_BG_COLOR;
    _popTipView.disableTapToDismiss = YES;

    [_popTipView presentPointingAtView:view inView:inView animated:animated];
}

- (void)dismissAnimated:(BOOL)animated
{
    [_popTipView dismissAnimated:animated];
}


@end
