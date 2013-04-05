//
//  AddColorCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "AddColorCommand.h"
#import "ColorView.h"
#import "DrawToolPanel.h"

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

- (void)colorBox:(ColorBox *)colorBox didSelectColor:(DrawColor *)color
{
    [self.toolHandler changePenColor:color];
    [self.toolPanel updateRecentColorViewWithColor:color updateModel:YES];
    [self hidePopTipView];
//    [self.toolHandler ]
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
    TouchActionType type = self.toolHandler.drawView.touchActionType;
    [self becomeActive];    
    [self.toolHandler changePenColor:colorView.drawColor];
    [self.toolPanel updateRecentColorViewWithColor:colorView.drawColor updateModel:YES];
    if (type == TouchActionTypeShape) {
        [self.toolHandler enterShapeMode];
    }else{
        [self.toolHandler enterDrawMode];
    }
}

- (void)didBuyColorList:(NSArray *)colorList groupId:(NSInteger)groupId
{
//    [self dismissColorBoxPopTipView];
    [self hidePopTipView];
//    [self selectPen];
}


@end
