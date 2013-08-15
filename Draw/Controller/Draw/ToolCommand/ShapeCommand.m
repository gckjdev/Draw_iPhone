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
//    ShapeType _currentType;
}

@property(nonatomic, retain)ShapeBox *box;

@end


@implementation ShapeCommand

- (void)dealloc
{
    PPRelease(_box);
    [super dealloc];
}

- (BOOL)execute
{
    
    ShapeBox *view = [ShapeBox shapeBoxWithDelegate:self];
    UIView *spView = [[self controller] view];
    view.center = spView.center;
    [view showInView:spView];
    self.box = view;
    [self sendAnalyticsReport];
    return YES;
}


- (void)shapeBox:(ShapeBox *)shapeBox
didSelectedShape:(ShapeType)shape
        isStroke:(BOOL)isStroke
         groudId:(ItemType)groupId
{
    if ([self canUseItem:groupId]) {
        
        [shapeBox dismiss];
        self.box = nil;
        self.drawInfo.shapeType = shape;
        self.drawInfo.strokeShape = isStroke;
        self.drawInfo.touchType = TouchActionTypeShape;
        [self updateToolPanel];
    }
}

- (void)shapeBox:(ShapeBox *)shapeBox didChangeDrawStyle:(BOOL)stroke
{
    if (self.drawInfo.shapeType != ShapeTypeNone) {
        self.drawInfo.strokeShape = stroke;
        self.drawInfo.touchType = TouchActionTypeShape;
        [self updateToolPanel];
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
