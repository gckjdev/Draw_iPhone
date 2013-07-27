//
//  WidthPickCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "WidthPickCommand.h"

@implementation WidthPickCommand

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        return YES;
    }
    return NO;
}

- (UIView *)contentView
{
    WidthBox *box = [WidthBox widthBox];
    [box setWidthSelected:self.drawInfo.penWidth];
    box.delegate = self;
    return box;
}

- (void)widthBox:(WidthBox *)widthBox didSelectWidth:(CGFloat)width
{
    self.drawInfo.penWidth = width;
    [self updateToolPanel];
    [self hidePopTipView];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_WIDTH_BOX);
}


@end
