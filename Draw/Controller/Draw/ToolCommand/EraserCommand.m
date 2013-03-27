//
//  EraserCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EraserCommand.h"

@implementation EraserCommand

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        [self.toolHandler changeInPenType:Eraser];
        return YES;
    }
    return NO;
}


- (void)showPopTipView
{
    self.showing = YES;
    [self.control setSelected:YES];
}

- (void)hidePopTipView
{
    self.showing = NO;
    [self.control setSelected:NO];
    [self.toolHandler enterDrawMode];
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_ERASER);
}

@end
