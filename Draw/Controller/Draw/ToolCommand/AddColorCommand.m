//
//  AddColorCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "AddColorCommand.h"
#import "ColorView.h"
@implementation AddColorCommand


- (UIView *)contentView
{
    return [ColorBox createViewWithdelegate:self];
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
    AnalyticsReport(DRAW_CLICK_COLOR_BOX);
}

#pragma mark-- Color Box Delegate

- (void)updateWithColor:(DrawColor *)color
{
    self.drawInfo.penColor = color;
    [self.drawInfo backToLastDrawMode];
    [self updateToolPanel];
    [self.toolPanel updateRecentColorViewWithColor:color updateModel:YES];
}

- (void)colorBox:(ColorBox *)colorBox didSelectColor:(DrawColor *)color
{
    [self updateWithColor:color];
    [self hidePopTipView];
}

- (void)didClickCloseButtonOnColorBox:(ColorBox *)colorBox
{
    [self hidePopTipView];
}

- (void)didClickMoreButtonOnColorBox:(ColorBox *)colorBox
{
    UIView *topView = [self.control theTopView];
    ColorShopView *colorShop = [ColorShopView colorShopViewWithFrame:topView.bounds];
    colorShop.delegate  = self;
    [colorShop showInView:topView animated:YES];
}


#pragma mark-- Color Shop Delegate

- (void)didPickedColorView:(ColorView *)colorView{
    [self updateWithColor:colorView.drawColor];
}

- (void)didBuyColorList:(NSArray *)colorList groupId:(NSInteger)groupId
{
    [self hidePopTipView];
}


@end
