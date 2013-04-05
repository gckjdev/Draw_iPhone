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
    [self.toolHandler enterEraserMode];
    [self.toolHandler changeInPenType:Eraser];
    return YES;
}


- (void)showPopTipView
{
    [self becomeActive];
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
