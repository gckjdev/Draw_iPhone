//
//  DicePopupViewManager.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DicePopupViewManager.h"
#import "CMPopTipView.h"
#import "CallDiceView.h"

#define CALL_DICE_POPUP_VIEW_BG_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]

@interface DicePopupViewManager ()

@property (retain, nonatomic) CMPopTipView *callDicePopupView;

- (CMPopTipView *)popTipViewWithCustomView:(UIView *)view
                          backagroundColor:(UIColor *)color;


@end

static DicePopupViewManager *_instance = nil;

@implementation DicePopupViewManager

@synthesize callDicePopupView = _callDicePopupView;

- (void)dealloc
{
    [_callDicePopupView dealloc];
    [super dealloc];
}

+ (id)defaultManager
{
    if (_instance == nil) {
        _instance = [[DicePopupViewManager alloc] init];
    }
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {

        
        
    }
    
    return self;
}

- (CMPopTipView *)popTipViewWithCustomView:(UIView *)view
                          backagroundColor:(UIColor *)color
{
    CMPopTipView *popTipView = [[[CMPopTipView alloc] initWithCustomView:view] autorelease];
    popTipView.backgroundColor = color;
    return popTipView;
}


- (void)popupCallDiceViewWithDice:(PBDice *)dice
                            count:(int)count
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated
{
    [_callDicePopupView dismissAnimated:YES];
    
    CallDiceView *callDiceView = [[[CallDiceView alloc] initWithDice:dice count:count] autorelease];
    self.callDicePopupView = [self popTipViewWithCustomView:callDiceView backagroundColor:CALL_DICE_POPUP_VIEW_BG_COLOR];    
    _callDicePopupView.disableTapToDismiss = YES;
    
    [_callDicePopupView presentPointingAtView:view inView:inView animated:animated];
//    [_callDicePopupView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
}

- (void)dismissCallDiceViewAnimated:(BOOL)animated
{
    [_callDicePopupView dismissAnimated:YES];
}


@end
