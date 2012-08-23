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
#import "DiceFontManager.h"

#define DICE_VIEW_WIDTH     ([DeviceDetection isIPAD] ? 56 : 28 )
#define DICE_VIEW_HEIGHT    ([DeviceDetection isIPAD] ? 58 : 29 )

#define DICE_VIEW_TAG       ([DeviceDetection isIPAD] ? 202 : 101 )
#define COUNT_LABEL_TAG     ([DeviceDetection isIPAD] ? 204 : 102 )

#define CALL_DICE_VIEW_HEIGHT DICE_VIEW_HEIGHT

#define COUNT_LABEL_WIDTH_1     ([DeviceDetection isIPAD] ? 30 : 15 )
#define COUNT_LABEL_WIDTH_2     ([DeviceDetection isIPAD] ? 48 : 24 )
#define SYMBOL_LABEL_WIDTH      ([DeviceDetection isIPAD] ? 24 : 12 )

#define CALL_DICE_POPUP_VIEW_BG_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]

#define SIZE_FONT_COUNT     ([DeviceDetection isIPAD] ? 50 : 25 )
#define SIZE_FONT_SYMBOL    ([DeviceDetection isIPAD] ? 36 : 18 )

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
    self = [super initWithFrame:CGRectMake(0, 0, DICE_VIEW_WIDTH + countLableWidth + SYMBOL_LABEL_WIDTH, CALL_DICE_VIEW_HEIGHT)];
    if (self) {
        // Initialization code

        self.diceView = [[[DiceView alloc] initWithFrame:CGRectMake(countLableWidth + SYMBOL_LABEL_WIDTH, 0, DICE_VIEW_WIDTH, DICE_VIEW_HEIGHT)   
                                                     dice:dice] autorelease];
        _diceView.userInteractionEnabled = NO;
        
        self.countLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(0, 0, countLableWidth, CALL_DICE_VIEW_HEIGHT) fontName:[[DiceFontManager defaultManager] fontName] pointSize:SIZE_FONT_COUNT] autorelease];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.text = [NSString stringWithFormat:NSLS(@"%d"), count]; 
        _countLabel.textAlignment = UITextAlignmentLeft;
        
        FontLabel *symbolLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(countLableWidth, 0, SYMBOL_LABEL_WIDTH, CALL_DICE_VIEW_HEIGHT) fontName:[[DiceFontManager defaultManager] fontName] pointSize:SIZE_FONT_SYMBOL] autorelease];
        symbolLabel.backgroundColor = [UIColor clearColor];
        symbolLabel.text = [NSString stringWithFormat:NSLS(@"x")]; 
        symbolLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:_countLabel];
        [self addSubview:symbolLabel];
        [self addSubview:_diceView];
    }
    
    return self;
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated
    pointDirection:(PointDirection)pointDirection

{
    [self.popTipView dismissAnimated:YES];
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self] autorelease];
    _popTipView.backgroundColor = CALL_DICE_POPUP_VIEW_BG_COLOR;
    _popTipView.disableTapToDismiss = YES;

    [_popTipView presentPointingAtView:view inView:inView animated:animated pointDirection:pointDirection];
}

- (void)dismissAnimated:(BOOL)animated
{
    [_popTipView dismissAnimated:animated];
    self.popTipView = nil;
}


@end
