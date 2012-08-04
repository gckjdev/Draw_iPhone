//
//  OpenDiceView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-4.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "OpenDiceView.h"
#import "CMPopTipView.h"

#define CALL_DICE_POPUP_VIEW_BG_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]


@interface OpenDiceView ()

@property (retain, nonatomic) CMPopTipView *popTipView;

@end

@implementation OpenDiceView

@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_popTipView release];
    [super dealloc];
}

- (id)initWithOpenType:(int)openType
{
    CGRect rect = openType ? CGRectMake(0, 0, 25, 20) : CGRectMake(0, 0, 35, 20);
    
    if (self = [self initWithFrame:rect]) {
        self.text = openType ? @"抢开" : @"开";
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
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
