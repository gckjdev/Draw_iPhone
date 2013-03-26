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
    [box setWidthSelected:self.toolHandler.width];
    box.delegate = self;
    return box;
}

- (void)widthBox:(WidthBox *)widthBox didSelectWidth:(CGFloat)width
{
    [self.toolHandler changeWidth:width];
    [self hidePopTipView];
}

@end
