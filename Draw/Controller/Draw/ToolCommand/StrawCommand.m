//
//  StrawCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "StrawCommand.h"

@implementation StrawCommand
- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        [self.toolHandler changeInPenType:Eraser];
    }
    return NO;
}


- (void)showPopTipView
{
    self.showing = YES;
    [self.control setSelected:YES];
    [self.toolHandler enterStrawMode];
}

- (void)hidePopTipView
{
    self.showing = NO;
    [self.control setSelected:NO];
    [self.toolHandler enterDrawMode];
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_STRAW);
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self showPopTipView];
}

@end
