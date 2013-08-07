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
    CanvasRect *cRect = [CanvasRect canvasRectWithRect:self.drawView.bounds];
    [rectBox setSelectedRect:cRect.style];
    return rectBox;
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_CANVAS_BOX);
}

- (void)useCanvasRect:(CanvasRect *)canvasRect
{
    BOOL flag = [[self.drawView drawActionList] count] == 0;//CGRectEqualToRect(canvasRect.rect, self.drawView.bounds);
    
    if (flag) {
        [self.drawView changeRect:canvasRect.rect];
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
