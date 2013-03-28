//
//  WidthSliderCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "WidthSliderCommand.h"
#import "WidthView.h"

@implementation WidthSliderCommand

- (UIScrollView *)superScrollView
{
    UIView *view = self.control;
    while (view && ![view isKindOfClass:[UIScrollView class]]) {
        view = view.superview;
    }
    return (UIScrollView *)view;
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_WIDTH);
}


- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    if (self) {
        [(DrawSlider *)control setDelegate:self];
    }
    return self;
}




- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    WidthView *widthView = (WidthView *)drawSlider.contentView;
    [widthView setWidth:value];

}
- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    [[self superScrollView] setClipsToBounds:NO];
    WidthView *width = [WidthView viewWithWidth:value];
    [drawSlider popupWithContenView:width];
    [width setSelected:YES];
}
- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [[self superScrollView] setClipsToBounds:YES];
    [drawSlider.contentView removeFromSuperview];
    [drawSlider dismissPopupView];
    [self.toolHandler changeWidth:value];
}


@end
