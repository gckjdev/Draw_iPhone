//
//  CanvasSizeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "CanvasSizeCommand.h"

@implementation CanvasSizeCommand

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        return YES;
    }
    return NO;
}

- (UIView *)contentView
{
    CanvasRectBox *rectBox = [CanvasRectBox canvasRectBoxWithDelegate:self];
    return rectBox;
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_CANVAS_BOX);
}

- (void)canvasBox:(CanvasRectBox *)box didSelectedRect:(CGRect)rect
{
    [self.toolHandler changeCanvasRect:rect];
}

@end
