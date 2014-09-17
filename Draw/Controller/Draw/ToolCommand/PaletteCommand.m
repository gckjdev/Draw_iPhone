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
    Palette *pallete = [Palette paletteWithDelegate:self];
    pallete.sourceColor = self.drawView.shareDrawInfo.penColor.color;
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
        
        [self.toolPanel updateRecentColorViewWithColor:self.drawView.shareDrawInfo.penColor
                                           updateModel:YES];
 
        [self updateToolPanel];
    }
    [super hidePopTipView];
}


- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    self.drawView.shareDrawInfo.penColor = [DrawColor colorWithColor:color];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.toolPanel updateRecentColorViewWithColor:self.drawView.shareDrawInfo.penColor updateModel:YES];
    [super popTipViewWasDismissedByUser:popTipView];
}

- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    [self.toolPanel updateRecentColorViewWithColor:self.drawView.shareDrawInfo.penColor updateModel:YES];
    [super popTipViewWasDismissedByCallingDismissAnimatedMethod:popTipView];
}



@end
