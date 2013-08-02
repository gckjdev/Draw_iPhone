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
    if (ISIPHONE5) {
        return nil;
    }

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



#define WIDTH_VIEW_TAG 100
#define LABEL_TAG 101

#define SIZE [WidthView width]

- (void)updateValue:(CGFloat)value withContentView:(UIView *)contentView
{
    WidthView *width = (WidthView *)[contentView viewWithTag:WIDTH_VIEW_TAG];
    [width setWidth:value];
    
    UILabel *label = (UILabel *)[contentView viewWithTag:LABEL_TAG];
    NSString *text = [NSString stringWithFormat:@"%.0f",value];
    [label setText:text];
}

#define VALUE(X) (ISIPAD ? 2 * X : X)
#define WIDTH_FONT_SIZE VALUE(14.0)

- (UIView *)sliderContentViewWithValue:(CGFloat)value
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SIZE, SIZE * 2)];
    WidthView *width = [WidthView viewWithWidth:value];
    width.tag = WIDTH_VIEW_TAG;
    [width setSelected:YES];    
    [content addSubview:width];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, SIZE, SIZE, SIZE)] autorelease];
    label.tag = LABEL_TAG;
    [label setFont:[UIFont systemFontOfSize:WIDTH_FONT_SIZE]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [content addSubview:label];
    
    [self updateValue:value withContentView:content];
    
    return [content autorelease];
}

- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    [self updateValue:value withContentView:drawSlider.contentView];

}
- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    [[ToolCommandManager defaultManager] hideAllPopTipViewsExcept:self];
    [[self superScrollView] setClipsToBounds:NO];
    [drawSlider popupWithContenView:[self sliderContentViewWithValue:value]];

}
- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [[self superScrollView] setClipsToBounds:YES];
    [drawSlider.contentView removeFromSuperview];
    [drawSlider dismissPopupView];
    self.drawInfo.penWidth = value;
    [self updateToolPanel];
}


@end
