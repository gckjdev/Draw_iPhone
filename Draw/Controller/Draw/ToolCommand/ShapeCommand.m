//
//  ShapeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ShapeCommand.h"

@implementation ShapeCommand


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
    return [ShapeBox shapeBoxWithDelegate:self];

}


- (void)shapeBox:(ShapeBox *)shapeBox didSelectShapeType:(ShapeType)type
{
    [self.toolHandler changeShape:type];
    [self hidePopTipView];
    //TODO change the control view with shape type
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_SHAPE_BOX);
}


@end
