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
    }
}

- (UIView *)contentView
{
    return [ShapeBox shapeBoxWithDelegate:self];

}


- (void)shapeBox:(ShapeBox *)shapeBox didSelectShapeType:(ShapeType)type
{
    [self.toolHandler changeShape:type];
    //TODO change the control view with shape type
}

@end
