//
//  CanvasSizeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "CanvasSizeCommand.h"
#import "CommonMessageCenter.h"
#import "DrawRecoveryService.h"
#import "DrawToolUpPanel.h"

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
    [rectBox setSelectedRect:style];
    return rectBox;
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_CANVAS_BOX);
}

- (void)useCanvasRect:(CanvasRect *)canvasRect
{
    if ([self.toolHandler changeCanvasRect:canvasRect]) {
        [self hidePopTipView];
        [[DrawRecoveryService defaultService] changeCanvasSize:canvasRect.rect.size];
    }else{
        [self hidePopTipView];        
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kChangeCanvasFailed") delayTime:1.5];
    }

}

- (void)canvasBox:(CanvasRectBox *)box didSelectedRect:(CanvasRect *)rect
{
//    CanvasRect
    if ([self.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
        [((DrawToolUpPanel*)self.toolPanel) disappear];
    }
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
