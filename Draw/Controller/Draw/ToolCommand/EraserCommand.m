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
    [self showPopTipView];
    self.drawInfo.penType = Eraser;
    self.drawInfo.touchType = TouchActionTypeDraw;
    [self sendAnalyticsReport];
    return YES;
}


- (void)showPopTipView
{
    self.showing = YES;
}

- (void)hidePopTipView
{
    self.showing = NO;
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_ERASER);
}

@end
