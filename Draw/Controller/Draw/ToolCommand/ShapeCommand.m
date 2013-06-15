//
//  ShapeCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ShapeCommand.h"
#import "ShapeInfo.h"
#import "ImageShapeManager.h"
#import "UIBezierPath+Ext.h"
#import "UIColor+UIColorExt.h"

@interface ShapeCommand()
{
    ShapeType _currentType;
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

- (void)updateButtonImageWithStroke:(BOOL)stroke
{
    UIButton *button = (UIButton *)self.control;
    UIBezierPath *path = [[ImageShapeManager defaultManager] pathWithType:_currentType];
    UIColor *color = OPAQUE_COLOR(62, 43, 23);
    UIImage *image = stroke ? [path toStrokeImageWithColor:color] : [path toFillImageWithColor:color];
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [button setSelected:YES];
    [button setImage:image forState:UIControlStateNormal];
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

        _currentType = shape;
        [self updateButtonImageWithStroke:isStroke];

    }
}

- (void)shapeBox:(ShapeBox *)shapeBox didChangeDrawStyle:(BOOL)stroke
{
    [self.toolHandler changeShapeStroke:stroke];
    if(_currentType != 0){
        [self updateButtonImageWithStroke:stroke];
    }
}

- (void)buyItemSuccessfully:(ItemType)type
{
    [self.box reloadView];
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_SHAPE_BOX);
}


@end
