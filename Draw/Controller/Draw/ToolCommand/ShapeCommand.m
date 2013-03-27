//
//  ShapeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ShapeCommand.h"
#import "ShapeInfo.h"

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

    UIImage * image = [ShapeInfo shapeImageForShapeType:type];
    UIButton *button = (UIButton *)self.control;
    [button setImage:image forState:UIControlStateNormal];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_SHAPE_BOX);
}


@end
