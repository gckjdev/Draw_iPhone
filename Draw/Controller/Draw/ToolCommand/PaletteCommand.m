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

- (void)buyItemSuccessfully
{
    [self.control setSelected:NO];
    [self showPopTipView];
}


@end
