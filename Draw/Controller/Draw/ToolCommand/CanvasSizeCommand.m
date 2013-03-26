//
//  CanvasSizeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "CanvasSizeCommand.h"

@interface CanvasSizeCommand ()


@end

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
    CanvasRectStyle style = self.toolHandler.canvasRect.style;
    if (style == 0) {
        style = [CanvasRect defaultCanvasRectStyle];
    }
    [rectBox setSelectedRect:style];
    return rectBox;
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_CANVAS_BOX);
}

- (void)useCanvasRect:(CanvasRect *)canvasRect
{
    [self.toolHandler changeCanvasRect:canvasRect];
    [self hidePopTipView];
}

- (void)canvasBox:(CanvasRectBox *)box didSelectedRect:(CanvasRect *)rect
{
//    CanvasRect
    if ([self canUseItem:[CanvasRect itemTypeFromCanvasRectStyle:rect.style]]) {
        [self useCanvasRect:rect];
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    CanvasRectStyle style = [CanvasRect canvasRectStyleFromItemType:type];
    [self useCanvasRect:[CanvasRect canvasRectWithStyle:style]];
}

@end
