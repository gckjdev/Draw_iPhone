//
//  GridCommand.m
//  Draw
//
//  Created by gamy on 13-3-26.
//
//

#import "GridCommand.h"

@implementation GridCommand

#define MAX_GRID_COUNT ([self.drawView bounds].size.width/5.0)


- (UIView *)contentView
{
    DrawSlider *slider = [DrawSlider sliderWithMaxValue:MAX_GRID_COUNT
                                               minValue:0
                                           defaultValue:self.drawView.shareDrawInfo.gridLineNumber
                                               delegate:self];
    return slider;
}

- (BOOL)execute{
    if ([super execute]) {
        [self showPopTipView];
        self.popTipView.disableTapToDismiss = YES;
        return YES;
    }else{
        return NO;
    }
}


-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_GRID);
}

- (void)updateDegreeWithValue:(CGFloat)value slider:(DrawSlider *)slider
{
    UILabel *label = (id)slider.contentView;
    NSString *str = [NSString stringWithFormat:@"%.0f°",value];
    [label setText:str];
    self.drawView.shareDrawInfo.gridLineNumber = (NSInteger)value;    
    [self.drawView.currentLayer setNeedsDisplay];
}

- (void)drawSlider:(DrawSlider *)drawSlider didValueChange:(CGFloat)value
{
    [self updateDegreeWithValue:value slider:drawSlider];
}

#define V(X) (ISIPAD?(2*X):X)

- (void)drawSlider:(DrawSlider *)drawSlider didStartToChangeValue:(CGFloat)value
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, V(40), V(30))] autorelease];
    [label setFont:[UIFont systemFontOfSize:V(14)]];
    [label setTextColor:COLOR_BROWN];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [drawSlider popupWithContenView:label];
    [self updateDegreeWithValue:value slider:drawSlider];
}

- (void)drawSlider:(DrawSlider *)drawSlider didFinishChangeValue:(CGFloat)value
{
    [self updateDegreeWithValue:value slider:drawSlider];
    [drawSlider dismissPopupView];
}




@end
