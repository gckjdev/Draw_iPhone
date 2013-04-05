//
//  AlphaSliderCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "AlphaSliderCommand.h"

@implementation AlphaSliderCommand

#define VALUE(X) (ISIPAD ? 2 * X : X)
#define ALPHA_LABEL_FRAME (ISIPAD ? CGRectMake(0, 0, 40*2, 20*2) : CGRectMake(0, 0, 40, 20))
#define ALPHA_FONT_SIZE VALUE(14.0)


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
    AnalyticsReport(DRAW_CLICK_ALPHA);
}

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    if (self) {
        [(DrawSlider *)control setDelegate:self];
    }
    return self;
}


- (void)updateLabel:(UILabel *)label value:(CGFloat)value
{
    NSString *v = [NSString stringWithFormat:@"%.0f%%",value*100];
    [label setText:v];
}

- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    if ([self.control isSelected]) {
        return;
    }
    UILabel *label = (UILabel *)drawSlider.contentView;
    [self updateLabel:label value:value];  
}
- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    [[ToolCommandManager defaultManager] hideAllPopTipViewsExcept:self];
    if (![self canUseItem:ColorAlphaItem]) {
        [self.control setSelected:YES];
        return;
    }
    
    [[self superScrollView] setClipsToBounds:NO];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:ALPHA_LABEL_FRAME] autorelease];
    [label setTextAlignment:NSTextAlignmentCenter];
    [drawSlider popupWithContenView:label];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:ALPHA_FONT_SIZE]];
    UIColor *textColor = [UIColor colorWithRed:23./255. green:21./255. blue:20./255. alpha:1];
    [label setTextColor:textColor];
    [self updateLabel:label value:value];

}
- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    if ([self.control isSelected]) {
        return;
    }
    
    [[self superScrollView] setClipsToBounds:YES];
    [self.toolHandler changeAlpha:value];
    
    [drawSlider.contentView removeFromSuperview];
    [drawSlider dismissPopupView];
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.control setSelected:NO];
}

- (BOOL)execute
{
    return YES;
}

@end
