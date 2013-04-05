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

//- (void)showPopTipView
//{
//    [super showPopTipView];
//}
//
//
//- (void)hidePopTipView
//{
//    [super hidePopTipView];
////    [self.control setSelected:NO];
//}

- (UIView *)contentView
{
    return [ShapeBox shapeBoxWithDelegate:self];

}


- (void)shapeBox:(ShapeBox *)shapeBox didSelectShapeType:(ShapeType)type
{
    [self becomeActive]; 
    [self.toolHandler changeShape:type];
    [self hidePopTipView];

    UIImage * image = [ShapeInfo shapeImageForShapeType:type];
    UIButton *button = (UIButton *)self.control;
    [button setImage:image forState:UIControlStateNormal];
//    [button setSelected:YES];
   
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_SHAPE_BOX);
}


@end
