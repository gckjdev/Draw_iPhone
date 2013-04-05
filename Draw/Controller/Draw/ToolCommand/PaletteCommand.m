//
//  palleteCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "PaletteCommand.h"
#import "Palette.h"


@implementation PaletteCommand
- (UIView *)contentView
{
    Palette *pallete = [Palette createViewWithdelegate:self];
    if (self.toolHandler.penColor) {
        pallete.currentColor = self.toolHandler.penColor;
        [self.toolHandler changePenColor:pallete.currentColor];
    }
    return pallete;
}

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        return YES;
    }
    return NO;
}

- (void)sendAnalyticsReport
{
    AnalyticsReport(DRAW_CLICK_PALETTE);
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.control setSelected:NO];
    [self showPopTipView];
}


- (void)hidePopTipView
{
    if (self.popTipView) {
        [self.toolPanel updateRecentColorViewWithColor:self.toolHandler.penColor
                                           updateModel:YES];
    }
    [super hidePopTipView];
}

- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    TouchActionType t = self.toolHandler.touchActionType;
    [self becomeActive];
    if (t == TouchActionTypeShape) {
        [self.toolHandler enterShapeMode];
//        [self.toolPanel setShapeSelected:YES];
    }
    [self.toolHandler changePenColor:color];
}

@end
