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
    pallete.sourceColor = self.drawInfo.penColor.color;
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
        
        [self.toolPanel updateRecentColorViewWithColor:self.drawInfo.penColor
                                           updateModel:YES];
 
        [self updateToolPanel];
    }
    [super hidePopTipView];
}


- (void)palette:(Palette *)palette didPickColor:(DrawColor *)color
{
    self.drawInfo.penColor = [DrawColor colorWithColor:color];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.toolPanel updateRecentColorViewWithColor:self.drawInfo.penColor updateModel:YES];
    [super popTipViewWasDismissedByUser:popTipView];
}

- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView
{
    [self.toolPanel updateRecentColorViewWithColor:self.drawInfo.penColor updateModel:YES];
    [super popTipViewWasDismissedByCallingDismissAnimatedMethod:popTipView];
}



@end
