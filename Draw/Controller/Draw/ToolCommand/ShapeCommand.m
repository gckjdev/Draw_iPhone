//
//  ShapeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ShapeCommand.h"
#import "ShapeInfo.h"


@interface ShapeCommand()
{
    
}

@property(nonatomic, retain)ShapeBox *box;

@end


@implementation ShapeCommand

/*
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
    [self becomeActive]; 
    [self.toolHandler changeShape:type];
    [self hidePopTipView];

    UIImage * image = [ShapeInfo shapeImageForShapeType:type];
    UIButton *button = (UIButton *)self.control;
    [button setImage:image forState:UIControlStateNormal];
//    [button setSelected:YES];
   
}
*/

- (void)dealloc
{
    PPRelease(_box);
    [super dealloc];
}

- (BOOL)execute
{
    
    ShapeBox *view = [ShapeBox shapeBoxWithDelegate:self];
    UIView *spView = [[self.control theViewController] view];
    view.center = spView.center;
    [view showInView:spView];
    self.box = view;
    return YES;
}

- (void)shapeBox:(ShapeBox *)shapeBox
didSelectedShape:(ShapeType)shape
        isStroke:(BOOL)isStroke
         groudId:(ItemType)groupId
{
    if ([self canUseItem:groupId] || YES) {
        [self becomeActive];
        [self.toolHandler changeShape:shape isStroke:isStroke];

        [shapeBox dismiss];
        self.box = nil;
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.box reloadView];
}

//-(void)sendAnalyticsReport{
//    AnalyticsReport(DRAW_CLICK_DRAWBG_BOX);
//}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_SHAPE_BOX);
}


@end
