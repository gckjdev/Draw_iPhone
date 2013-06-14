//
//  ShapeTouchHandler.m
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "ShapeTouchHandler.h"

@interface ShapeTouchHandler()
{
    ShapeAction *action;
}

@end

@implementation ShapeTouchHandler

- (void)addAction:(DrawAction *)drawAction
{
    [self.drawView addDrawAction:drawAction];
}

- (void)dealloc
{
    if ((currentState != TouchStateCancel) && (currentState != TouchStateEnd)) {
        [self handleFailTouch];
    }else{
        [self reset];
    }
    PPRelease(action);
    [super dealloc];
    
}

- (void)reset
{
    PPRelease(action);
}


- (void)handlePoint:(CGPoint)point forTouchState:(TouchState)state
{
    [super handlePoint:point forTouchState:state];
    switch (state) {
        case TouchStateBegin:
        {
            handleFailed = NO;
            ShapeInfo *shape = nil;
            if (!action) {
                shape = [ShapeInfo shapeWithType:self.drawView.shapeType
                                         penType:self.drawView.penType
                                           width:self.drawView.lineWidth
                                           color:self.drawView.lineColor];
                [shape setStroke:self.drawView.strokeShape];
                action = [[ShapeAction shapeActionWithShape:shape] retain];
                shape.startPoint = shape.endPoint = point;
                [self.drawView drawDrawAction:action show:YES];
            }else{
                shape.startPoint = shape.endPoint = point;
                [self.drawView updateLastAction:action show:YES];
            }
            
            break;
        }
            
        case TouchStateEnd:
        case TouchStateMove:
        {
            if (handleFailed) {
                return;
            }
            [action addPoint:point inRect:self.drawView.bounds];
            [self.drawView updateLastAction:action show:YES];
            break;
        }
        default:
            break;
    }
    
    if (state == TouchStateCancel || state == TouchStateEnd) {
        [self.drawView addDrawAction:action];
        if (action) {
            [self.drawView clearRedoStack];
        }
        [self reset];
    }
}

- (void)handleFailTouch
{
    [super handleFailTouch];
    [self reset];
    [self.osManager cancelLastAction];
    //    [[self.osManager enteryScreen] clear];
    [self.drawView setNeedsDisplay];
}

- (DrawAction *)drawAction
{
    return action;
}

@end